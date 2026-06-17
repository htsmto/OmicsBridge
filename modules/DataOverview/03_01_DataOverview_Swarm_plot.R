# =============================================================================
# DataOverview - Swarm Plot: Plot
# File: modules/DataOverview/03_01_DataOverview_Swarm_plot.R
# Purpose: Builds the ggbeeswarm plot from the per-gene expression tables,
#          handles group re-ordering, sample exclusion, and colour settings,
#          and renders the final combined panel with patchwork.
# Edit this file when: changing plot type, colour palette, axis font sizes,
#                       white-background toggle, or the group/sample filter UI.
# =============================================================================

swarm_plot_server <- function(input, output, session,
                              df_datasets,
                              df_gene_expression_map,
                              Ex_table_ready) {

    ## Plotting
        # status
            status_plot <- reactiveVal(NULL)
            output$status_plot <- renderText({status_plot()})
            status_order_group <- reactiveVal(NULL)
            output$status_order_group <- renderText({status_order_group()})
            status_exclude_sample <- reactiveVal(NULL)
            output$status_exclude_sample <- renderText({status_exclude_sample()})
        #

        # X re-oder function
            # show the list of the group names in the dataset
            output$group_name_list <- renderText({
                if(is.null(df_gene_expression_map())){
                    'Please select gene(s) to show in the swarm plot first.'
                }else{
                    groups <- unique(df_gene_expression_map()[[1]]$Group)[order(unique(df_gene_expression_map()[[1]]$Group))]
                    paste(groups, collapse='\n')
                }
            })

            # update the group order based on the user input # group_order()
            group_order <- reactiveVal(NULL)
            observe({
                if(length(input$order_group) > 0 && input$order_group == TRUE){
                    if(nchar(input$group_order_text) > 0){
                        user_group_order <- unique(unlist(strsplit(input$group_order_text, split="\n")))

                        # check if the user input group names are in the dataset
                        if(any(!(user_group_order %in% df_gene_expression_map()[[1]]$Group))){
                            not_found_groups <- user_group_order[!(user_group_order %in% df_gene_expression_map()[[1]]$Group)]
                            status_order_group(paste0("The following group(s) is/are not found in the dataset: ", paste(not_found_groups, collapse = ", "), ". \nPlease enter valid group names."))

                            # if all user input group names are not in the dataset, return NULL
                            if(length(user_group_order) == length(not_found_groups)){
                                group_order(NULL)
                                return(NULL)
                            }else{
                                valid_user_group_order <- user_group_order[!(user_group_order %in% not_found_groups)]
                                group_order(valid_user_group_order)
                            }
                        }else{
                            group_order(user_group_order)
                            status_order_group(NULL)
                        }

                    }else{
                        group_order(NULL)
                        status_order_group("Please enter the group names in the text box to re-order the X axis. \nMake sure that the group names you entered exactly match the group names in the dataset.")
                    }
                }else{
                    group_order(NULL)
                    status_order_group(NULL)
                }
            })


        # option for exluding specific samples from the plot
            excluded_samples <- reactiveVal(NULL)
            # show the list of the sample names in the dataset
            output$Exclude_sample_input_list <- renderText({
                if(length(df_datasets()) != 0 && !is.null(df_datasets())){
                    df_ex <- df_datasets()
                    samples <- grep("_(R|r)ep.+$", colnames(df_ex), value=TRUE)
                    samples <- sort(samples)
                    paste(unlist(samples), collapse='\n')
                }
            })

            # update the excluded samples based on the user input
            observe({
                if(length(input$Exclude_sample) > 0 && input$Exclude_sample == TRUE){
                    if(nchar(input$Exclude_sample_input) > 0){
                        user_excluded_samples <- unique(unlist(strsplit(input$Exclude_sample_input, split="\n")))

                        # check if the user input sample names are in the dataset
                        if(any(!(user_excluded_samples %in% colnames(df_datasets())))){
                            not_found_samples <- user_excluded_samples[!(user_excluded_samples %in% colnames(df_datasets()))]
                            status_exclude_sample(paste0("The following sample(s) is/are not found in the dataset: ", paste(not_found_samples, collapse = ", "), ". \nPlease enter valid sample names."))
                            # if all user input sample names are not in the dataset, return NULL
                            if(length(user_excluded_samples) == length(not_found_samples)){
                                excluded_samples(NULL)
                                return(NULL)
                            }else{
                                valid_user_excluded_samples <- user_excluded_samples[!(user_excluded_samples %in% not_found_samples)]
                                excluded_samples(valid_user_excluded_samples)
                            }
                        }else{
                            excluded_samples(user_excluded_samples)
                            status_exclude_sample(NULL)
                        }
                    }else{
                        excluded_samples(NULL)
                        status_exclude_sample("Please enter the sample names in the text box to exclude them from the swarm plot. \nMake sure that the sample names you entered exactly match the sample names in the dataset.")
                    }
                }else{
                    excluded_samples(NULL)
                    status_exclude_sample(NULL)
                }
            })



        # ggplot object
            swarm_plot_obj <- reactiveVal(NULL)
            observe({
                # make sure that the table is ready
                if(is.null(df_gene_expression_map())){
                    swarm_plot_obj(NULL)
                    status_plot("Please input the genes you want to show in the swarm plot first.")
                    return(NULL)
                }

                # setting
                df_gene_expression_map_tmp <- df_gene_expression_map()
                num_plots <- length(df_gene_expression_map_tmp)
                group_order_tmp <- group_order()
                excluded_samples_tmp <- excluded_samples()

                # Main plot
                plots <- lapply(seq_along(df_gene_expression_map_tmp), function(i) {
                    # get the data for the i-th gene
                    df_tmp <- df_gene_expression_map_tmp[[i]]
                    gene_tmp <- names(df_gene_expression_map_tmp)[i]

                    # if the user want to re-order the group in the X axis, change the order of the group factor based on the user input
                        if(length(group_order_tmp) > 0 && !is.null(group_order_tmp)){
                            df_tmp <- df_tmp[df_tmp$Group %in% group_order_tmp, ] # keep only the groups in the user input
                            df_tmp$Group <- factor(df_tmp$Group, levels = group_order_tmp)
                        }

                    # if the user want to exclude specific samples, remove the samples from the data
                        if(length(excluded_samples_tmp) > 0 && !is.null(excluded_samples_tmp)){
                            df_tmp <- df_tmp[!(rownames(df_tmp) %in% excluded_samples_tmp), ]
                        }

                    # baseplot. based on the settings of the colour
                        if(input$use_single_colour){ # single colour
                            p <- ggplot(df_tmp, aes(x = Group, y = Expression)) + geom_beeswarm(size=input$Pt.size, color=input$choose_single_colour)
                        }else{ # colour by group
                            p <- ggplot(df_tmp, aes(x = Group, y = Expression, color=Group)) + geom_beeswarm(size=input$Pt.size)
                            if(input$select_colour_pallete != 'None'){
                                p <- p + scale_color_viridis_d(option=input$select_colour_pallete)
                            }
                        }

                    # X axis setting
                        p <- p + theme(legend.position = 'none', axis.title.x = element_blank())
                        if(input$Xlab.font.size == 0){
                            p <- p + theme( axis.text.x = element_blank(), axis.ticks.x = element_blank())
                        }else{
                            p <- p + theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = input$Xlab.font.size), axis.ticks.x = element_line(size=0.1), axis.ticks.length.x = unit(1, "pt"))
                        }

                    # same for the Y label
                        p <- p + ylab(gene_tmp)
                        if(input$Ylab.font.size != 0){
                            p <- p + theme( axis.text.y = element_text(size = input$Ylab.font.size), axis.ticks.y = element_line(size=0.1), axis.ticks.length.y = unit(1, "pt"))
                        }else{
                            p <- p + theme( axis.text.y = element_blank(), axis.ticks.y = element_blank())
                        }

                    # graph title
                        if(input$Graph.title.font.size != 0){
                            p <- p + theme(axis.title = element_text(size = input$Graph.title.font.size))
                        }else{
                            p <- p + theme(axis.title = element_blank())
                        }

                    # if the plot is above other plot, remove the X axis text and ticks
                        if( i < num_plots){
                            p <- p + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank())
                        }

                    # grid
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))

                    # white background
                        if(input$White.background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", size=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }

                    # return
                        return(p)
                })

                # conbine the plots
                p <- wrap_plots(plots, ncol=1)

                swarm_plot_obj(p)
                status_plot(NULL)
            })
        # The final Plot
            output$Swarm_plot <- renderPlot({
                if(is.null(swarm_plot_obj())){
                    return(ggplot())
                } else {
                    swarm_plot_obj()
                }
            }, width=reactive(input$Fig.width), height=reactive(input$Fig.height), res=300)

    ##
}
