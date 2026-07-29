# =============================================================================
# Clinical - Signature: Plot & Table Rendering
# File: modules/Clinical/07_clinical_Signature_plot.R
# Purpose: Renders the result table, KM survival plot, score comparison
#          (box/violin/swarm) plot, and score distribution histogram.
# Edit this file when: changing plot types, adding new visualisations,
#                      or modifying the survival analysis display.
# =============================================================================

signature_plot_server <- function(input, output, session, meta_table, surv_table,
                                  signature_table, isCalculating,
                                  All_sample_flag, filtered_sample_ids_reactive) {

    ## Table
        # status
            Signature_analysis_status <- reactiveVal(NULL)
            output$Signature_analysis_status <- renderText({ Signature_analysis_status() })
        #

        # show the result table
            output$Signature_result_table <- DT::renderDataTable({
                if(isCalculating()){
                    Signature_analysis_status('Calculating the signature score...')
                    df_test <- data.frame('Sample'=character(0), 'Signature.score'=numeric(0), stringsAsFactors = FALSE)
                }else{
                    if(is.null(signature_table())){
                        Signature_analysis_status('Calculate the signature score first. The result table will be displayed here.')
                        df_test <- data.frame('Sample'=character(0), 'Signature.score'=numeric(0), stringsAsFactors = FALSE)
                    }else{
                        Signature_analysis_status(NULL)
                        df_test <- signature_table()
                    }
                }
                datatable(df_test, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE)
            })
        #
    ##

    ## Plots
        # Survival
            # status
                Signature_Survival_detail <- reactiveVal(NULL)
                output$Signature_Survival_detail <- renderText({ Signature_Survival_detail() })
            #

            # UI
                output$Signature_Survival_select_event_type <- renderUI({
                    if(!is.null(surv_table())){
                        suv_colnames <- colnames(surv_table())
                        col_tmp <- suv_colnames[grepl("\\.time", suv_colnames, ignore.case = TRUE)]
                        col_first_parts <- sapply(strsplit(col_tmp, "\\."), `[`, 1)
                    }else{
                        col_first_parts <- NULL
                    }
                    selectInput(session$ns('Signature_Survival_select_event_type'), 'Select the event type',  c('None'='None', col_first_parts))
                })

                output$Signature_Survival_cutoff_method_note <- renderUI({
                    if(input$Signature_Survival_cutoff_method == 'C'){
                        return(
                            fluidRow(
                                column(6, numericInput(session$ns('Signature_Survival_Split_Group1_perc'), 'Top X%:', value=25, min=0, max=100, step=1) ),
                                column(6, numericInput(session$ns('Signature_Survival_Split_Group2_perc'), 'Bottom Y%:', value=25, min=0, max=100, step=1) )
                            )
                        )
                    }else{
                        return(NULL)
                    }
                })

            # Plot
                output$Signature_Survival_plot <- renderPlot({
                    if(isCalculating()){
                        Signature_Survival_detail('Calculating the signature score...')
                        return(ggplot())
                    }

                    # check if the signature score table is available
                        if(is.null(signature_table())){
                            Signature_Survival_detail('Calculate the signature score first, then the survival plot will be displayed here.')
                            return(ggplot())
                        }
                    #

                    # check if the survival data and clinical data are available
                        if(is.null(surv_table())){
                            Signature_Survival_detail('The clinical data is not available. The survival plot cannot be generated.')
                            return(ggplot())
                        }
                    #

                    # check if the event type for survival analysis is selected
                        if(length(input$Signature_Survival_select_event_type) == 0 || input$Signature_Survival_select_event_type == 'None'){
                            Signature_Survival_detail('Please select an event type for survival analysis.')
                            return(ggplot())
                        }
                    #

                    # if user choose to use TopX% and BottomY%, check the validity of the input.
                    # X+Y cannot exceed 100. No input cannot be acceptable
                        if(input$Signature_Survival_cutoff_method == 'C'){
                            if(length(input$Signature_Survival_Split_Group1_perc) == 0 || length(input$Signature_Survival_Split_Group2_perc) == 0 || is.na(input$Signature_Survival_Split_Group1_perc) || is.na(input$Signature_Survival_Split_Group2_perc) || is.null(input$Signature_Survival_Split_Group1_perc) || is.null(input$Signature_Survival_Split_Group2_perc)){
                                Signature_Survival_detail('Please input the percentage for Top X% and Bottom Y%.')
                                return(ggplot())
                            }else if(input$Signature_Survival_Split_Group1_perc + input$Signature_Survival_Split_Group2_perc >= 100){
                                Signature_Survival_detail('The sum of Top X% and Bottom Y% cannot exceed 100%. Please adjust your input.')
                                return(ggplot())
                            }else if(input$Signature_Survival_Split_Group1_perc <= 0 || input$Signature_Survival_Split_Group2_perc <= 0){
                                Signature_Survival_detail('The percentage for Top X% and Bottom Y% should be greater than 0. Please adjust your input.')
                                return(ggplot())
                            }
                        }
                    #

                    # do the survival analysis
                        # column(12, radioButtons(ns('Signature_Survival_cutoff_method'), 'Split the samples by:', choices = c('Median'='A', 'Top25% vs Bottom 25%'='B', 'Top X% vs Bottom Y%'='C'), selected='A' )),
                        # cutoff method: median -> X=Y=50, top/bottom 25% -> X=Y=25, top/bottom X/Y% -> X=input$Signature_Survival_Split_Group1_perc, Y=input$Signature_Survival_Split_Group2_perc
                        cutoff_method <- input$Signature_Survival_cutoff_method
                        if(cutoff_method == 'A'){
                            group1_perc <- 50
                            group2_perc <- 50
                        }else if(cutoff_method == 'B'){
                            group1_perc <- 25
                            group2_perc <- 25
                        }else if(cutoff_method == 'C'){
                            group1_perc <- input$Signature_Survival_Split_Group1_perc
                            group2_perc <- input$Signature_Survival_Split_Group2_perc
                        }

                        df_OS <- surv_table()
                        signature_table <- signature_table()
                        topX <- quantile(unlist(signature_table[, 'Signature.score']), (100-group1_perc)/100 , na.rm = T)
                        bottomY <- quantile(unlist(signature_table[, 'Signature.score']), group2_perc/100 , na.rm = T)
                        df_high_sample <- signature_table[signature_table[, 'Signature.score'] >= topX,]$Sample
                        df_low_sample <- signature_table[signature_table[, 'Signature.score'] <= bottomY,]$Sample

                        event_type <- input$Signature_Survival_select_event_type
                        df_OS$group = NA
                        df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
                        df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
                        df_OS$group <- factor(df_OS$group, levels=c('Low', 'High'))
                        # if there are samples with NA group, remove them
                        df_OS <- df_OS[!is.na(df_OS$group), ]

                        # if there are less than 2 samples in any group, show message and skip the survival analysis
                        if(length(df_high_sample) < 2 || length(df_low_sample) < 2){
                            Signature_Survival_detail('There are less than 2 samples in one of the groups. Survival analysis cannot be performed. \nPlease adjust the cutoff method or the percentage for Top X% and Bottom Y%.')
                            return(ggplot())
                        }

                        # survival object
                        surv_obj <- Surv(time = df_OS[, paste0(event_type, '.time')], event = df_OS[,event_type])
                        # calculate the kaplan-meier for each group
                        km_fit <- survfit(surv_obj ~ group, data = df_OS)
                        cox_model <- coxph(surv_obj ~ group, data = df_OS)
                        # Hazard ratio and p
                        HR <- exp(cox_model$coefficients)
                        p_value <- summary(cox_model)$coefficients[, 5]
                            Signature_Survival_detail(paste0("Hazard Ratio (High vs Low): ", round(HR, 3), "\nP-value: ", signif(p_value, 3), "\n\n", "Number of samples in High group: ", length(df_high_sample), "\nNumber of samples in Low group: ", length(df_low_sample)))
                        # plot
                        km_data <- broom::tidy(km_fit)
                        km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 0.25) +
                            geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
                            labs( title = 'Signature score', x = "Time", y = "Survival Probability", color = "") +
                            scale_color_manual(
                                values=c('group=High'=input$Signature_Survival_plot_High_colour, 'group=Low'=input$Signature_Survival_plot_Low_colour),
                                labels=c(paste0('High (n=', as.character(length(df_high_sample)), ')'), paste0('Low (n=', as.character(length(df_low_sample)), ')'))
                            ) +
                            scale_fill_manual(
                                values=c('group=High'=input$Signature_Survival_plot_High_colour, 'group=Low'=input$Signature_Survival_plot_Low_colour),
                                labels=c(paste0('High (n=', as.character(length(df_high_sample)), ')'), paste0('Low (n=', as.character(length(df_low_sample)), ')'))
                            ) +
                            guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Signature_Survival_plot_legend_size))
                        p <- km_plot
                        p <- p + theme(axis.text = element_text(size = input$Signature_Survival_plot_label_size))
                        p <- p + theme(axis.title = element_text(size = input$Signature_Survival_plot_title_size))
                        p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                        p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        p <- p + theme(legend.key.size = unit(1, "mm"))
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", size=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        p <- p + labs(title=NULL)
                        p
                }, width=reactive(input$Signature_Survival_plot_fig.width), height=reactive(input$Signature_Survival_plot_fig.height), res=300)

            #

        #

        # Score comparison
            # Input and settings
                # status
                    Signature_subtype_subtype_number <- reactiveVal(NULL)
                    output$Signature_subtype_subtype_number <- renderText({ Signature_subtype_subtype_number() })
                #

                # group by
                    output$Signature_subtype_groupBy <- renderUI({
                        if(length(meta_table()) == 0 || is.null(meta_table())){
                            selectInput(session$ns('Signature_subtype_groupBy'), 'Group by', c('--Please choose a cohort first--'='None'))
                        }else{
                            if(All_sample_flag()){
                                meta_table_tmp <- meta_table()
                                selectInput(session$ns('Signature_subtype_groupBy'), 'Group by', c('None'='None', colnames(meta_table())))
                            }else{
                                meta_table_tmp <- meta_table()[meta_table()$sample %in% filtered_sample_ids_reactive(), ]
                                selectInput(session$ns('Signature_subtype_groupBy'), 'Group by', c('None'='None', colnames(meta_table())))
                            }

                        }
                    })
                #

                # check how many subtypes there are
                    observe({
                        if(length(input$Signature_subtype_groupBy) == 0 || input$Signature_subtype_groupBy =='None'){
                            Signature_subtype_subtype_number('Please select a category for grouping the samples.')
                        }else{
                            tmp <- unlist(unique(meta_table()[input$Signature_subtype_groupBy]))
                            tmp <- tmp[tmp!='']
                            tmp <- na.omit(tmp) # length(meta_table[group_by][is.na(meta_table[group_by])])
                            num_blanck <- length(meta_table()[input$Signature_subtype_groupBy][meta_table()[input$Signature_subtype_groupBy]==''])
                            num_na <- length(meta_table()[input$Signature_subtype_groupBy][is.na(meta_table()[input$Signature_subtype_groupBy])])
                            num_nd <- num_blanck + num_na
                            Signature_subtype_subtype_number(paste0("There are ", length(tmp), " subtypes in total. (", num_nd, " samples with blank or NA value)"))
                        }
                    })

                #


                # when the user choose to use only two subtypes
                    Signature_subtype_choose_two_subtypes_only_select_status <- reactiveVal(NULL)
                    output$Signature_subtype_choose_two_subtypes_only_select_status <- renderText({ Signature_subtype_choose_two_subtypes_only_select_status() })
                    two_subtype_only_flag <- reactiveVal(FALSE)

                    output$Signature_subtype_choose_two_subtypes_only_select <- renderUI({
                        if(length(input$Signature_subtype_choose_two_subtypes_only) == 0 || input$Signature_subtype_choose_two_subtypes_only == FALSE){
                            Signature_subtype_choose_two_subtypes_only_select_status(NULL)
                            two_subtype_only_flag(FALSE)
                            return(NULL)
                        } else {
                            if(length(input$Signature_subtype_groupBy) == 0 || input$Signature_subtype_groupBy =='None'){
                                Signature_subtype_choose_two_subtypes_only_select_status('Please select a category for grouping the samples first.')
                                two_subtype_only_flag(FALSE)
                                return(NULL)
                            }else{
                                group_by_category <- input$Signature_subtype_groupBy
                                if(All_sample_flag()){
                                    meta_table_tmp <- meta_table()
                                }else{
                                    meta_table_tmp <- meta_table()[meta_table()$sample %in% filtered_sample_ids_reactive(), ]
                                }
                                subtypes <- unique(meta_table_tmp[, group_by_category])
                                subtypes <- subtypes[!grepl("^\\s*$", subtypes)] # remove blank subtypes
                                subtypes <- subtypes[!is.na(subtypes)] # remove NA subtypes
                                if(length(subtypes) <= 2){
                                    Signature_subtype_choose_two_subtypes_only_select_status('Not enough subtypes to compare.')
                                    two_subtype_only_flag(FALSE)
                                    return(NULL)
                                }else{
                                    Signature_subtype_choose_two_subtypes_only_select_status(NULL)
                                    two_subtype_only_flag(TRUE)
                                    fluidRow(
                                        column(6, selectInput(session$ns('Signature_subtype_choose_two_subtypes_only_select_1'), 'Select subtype 1', c('None'='None', subtypes))),
                                        column(6, selectInput(session$ns('Signature_subtype_choose_two_subtypes_only_select_2'), 'Select subtype 2', c('None'='None', subtypes)))
                                    )
                                }
                            }
                        }
                    })
                #
            #

            # start
                # status
                    Signature_subtype_note <- reactiveVal(NULL)
                    output$Signature_subtype_note <- renderText({ Signature_subtype_note() })
                #

                # start
                    isCalculating_subtype_test <- reactiveVal(FALSE)
                    Signature_subtype_test <- reactiveVal(NULL)
                    observeEvent(input$Signature_subtype_start, {
                        isCalculating_subtype_test(TRUE)

                        # check if the signature score table is available
                            if(is.null(signature_table())){
                                show_alert(title='Error.', text='Please calculate the signature score first.', type='error')
                                Signature_subtype_note("Please start calulating the score first.")
                                Signature_subtype_test(NULL)
                                isCalculating_subtype_test(FALSE)
                                return(NULL)
                            }
                        #


                        signature_table <- signature_table() # head(signature_table)
                        # meta, subtype
                        df_meta <- meta_table()
                        # df_meta$sample <- gsub('\\.', '-', df_meta$sample)
                        group_by <- input$Signature_subtype_groupBy # group_by <- 'gender'

                        # check if the group by category is selected
                        if(length(group_by) == 0 || group_by == 'None'){
                            show_alert(title='Error.', text='Please select a group to compare.', type='error')
                            Signature_subtype_note("Please select a group to compare.")
                            Signature_subtype_test(NULL)
                            isCalculating_subtype_test(FALSE)
                            return(NULL)
                        }

                        # extract the sample and group information from the meta data.
                        df_meta_subtype <- df_meta[, c('sample', group_by)] # head(df_meta_subtype)
                        df_meta_subtype <- df_meta_subtype[!is.na(df_meta_subtype[,group_by]),]
                        df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] != '',]
                        df_meta_subtype[,group_by] <- as.character(df_meta_subtype[,group_by])

                        # if the user choose to use only two subtypes, check if the two subtypes are selected and valid
                        if(two_subtype_only_flag()){
                            subtype1 <- input$Signature_subtype_choose_two_subtypes_only_select_1
                            subtype2 <- input$Signature_subtype_choose_two_subtypes_only_select_2
                            df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] %in% c(subtype1, subtype2), ]
                            if(length(unique(df_meta_subtype[,group_by])) < 2){
                                show_alert(title='Error.', text='Please select two different subtypes for comparison.', type='error')
                                Signature_subtype_note("Please select two different subtypes for comparison.")
                                Signature_subtype_test(NULL)
                                isCalculating_subtype_test(FALSE)
                                return(NULL)
                            }
                        }


                        # merge the extracted metadata with the score table
                        colnames(signature_table) <- c('sample', 'score') # head(signature_table)
                        df_tmp <- merge(signature_table, df_meta_subtype, by='sample') # head(df_tmp)
                        df_out <- df_tmp

                        # perform the statistical test
                        # show the number of samples in each group, p  and statistic value
                        if(length(unique(unlist(df_out[,group_by]))) >= 3){
                            df_test_tmp <- tryCatch({
                                df_out$.group_by_col <- df_out[[group_by]]
                                kruskal.test(as.formula(paste('score', '~', '.group_by_col')), data=df_out) # str(df_test)
                            }, error = function(e){
                                show_alert(title='Error.', text=paste0('An error occurred while running the statistical test: ', conditionMessage(e)), type='error')
                                Signature_subtype_note(paste0('An error occurred while running the statistical test: ', conditionMessage(e)))
                                Signature_subtype_test(NULL)
                                isCalculating_subtype_test(FALSE)
                                NULL
                            })
                            if(is.null(df_test_tmp)){
                                return(NULL)
                            }
                            p <- df_test_tmp$p.value
                            statistic <- df_test_tmp$statistic
                            # the number of samples in each group
                            message <- "Number of samples in each group: \n"
                            for(g in unique(unlist(df_out[,group_by]))){
                                num <- length(df_out[df_out[,group_by] == g,]$sample)
                                message <- paste0(message, g, ": ", num, "\n")
                            }
                            message <- paste0(message, "\nP-value: ", p, '\n', 'Statistic (Kruskal-Wallis): ', statistic)
                            Signature_subtype_note(message)
                        }else if(length(unique(unlist(df_out[,group_by]))) == 2){
                            group1 <- df_out[df_out[,group_by] == unique(unlist(df_out[,group_by]))[1],]$score
                            group2 <- df_out[df_out[,group_by] == unique(unlist(df_out[,group_by]))[2],]$score
                            df_test_tmp <- wilcox.test(group1, group2) # str(df_test)
                            p <- df_test_tmp$p.value
                            statistic <- df_test_tmp$statistic
                            message <- "Number of samples in each group: \n"
                            for(g in unique(unlist(df_out[,group_by]))){
                                num <- length(df_out[df_out[,group_by] == g,]$sample)
                                message <- paste0(message, g, ": ", num, "\n")
                            }
                            message <- paste0(message, "\nP-value: ", p, '\n', 'Statistic (Wilcoxon): ', statistic)
                            Signature_subtype_note(message)

                        }else{
                            show_alert(title='Error.', text='There is no sub groups for the selected category. Please try with other categories.', type='error')
                            Signature_subtype_note("There is no sub groups for the selected category. Please try with other categories.")
                            Signature_subtype_test(NULL)
                            isCalculating_subtype_test(FALSE)
                            return(NULL)
                        }
                        Signature_subtype_test(df_out)
                        isCalculating_subtype_test(FALSE)
                        return(NULL)

                    })
                #

            # Plot
                output$Signature_subtype_plot <- renderPlot({
                    if(isCalculating_subtype_test()){
                        return(ggplot())
                    }

                    if(length(Signature_subtype_test()) == 0 || is.null(Signature_subtype_test())){
                        return(ggplot())
                    }

                    df_out_tmp <- Signature_subtype_test()
                    group_by <- colnames(df_out_tmp)[3]
                    if(input$Signature_subtype_use_single_colour){
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=.data[['score']]))
                    }else{
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=.data[['score']], fill=.data[[group_by]]))
                    }
                    if(input$Signature_subtype_figtype == 'A'){  # boxplot
                        if(input$Signature_subtype_use_single_colour){
                            p <- p + geom_boxplot(fill=input$Signature_subtype_use_single_colour_select, size=0.2, outlier.size=0.5)
                        }else{
                            p <- p + geom_boxplot(color='black', size=0.2, outlier.size=0.5)
                            if(input$Signature_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Signature_subtype_figtype == 'B'){ # violin plot
                        if(input$Signature_subtype_use_single_colour){
                            p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_use_single_colour_select, size=0.2)
                        }else{
                            p <- p + geom_violin(color='black',trim = FALSE, size=0.2)
                            if(input$Signature_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Signature_subtype_figtype == 'C'){ # swarm plot
                        p <- ggplot(df_out_tmp, aes(x=.data[[group_by]], y=.data[['score']], color=.data[[group_by]]))
                        if(input$Signature_subtype_use_single_colour){
                            p <- p + geom_beeswarm(size=input$Signature_subtype_dot.size,color=input$Signature_subtype_use_single_colour_select)
                        }else{
                            p <- p + geom_beeswarm(size=input$Signature_subtype_dot.size)
                            if(input$Signature_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_color_viridis_d(option=input$Signature_subtype_select_colour_pallete)
                            }
                        }
                    }else if(input$Signature_subtype_figtype == 'D'){ # swarm plot + violin plot
                        if(input$Signature_subtype_use_single_colour){
                            p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_use_single_colour_select, size=0.2)
                        }else{
                            p <- p + geom_violin(trim = FALSE, size=0.2)
                            if(input$Signature_subtype_select_colour_pallete != 'None'){
                                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
                            }
                        }
                        p <- p + geom_jitter(width=0.1, height=0, size=input$Signature_subtype_dot.size)
                    }
                    if(input$Signature_subtype_rotate_x){
                        p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                    }
                    p <- p + theme(axis.text.y = element_text(size = input$Signature_subtype_XY_label.font.size), axis.text.x = element_text(size = input$Signature_subtype_XY_label.font.size))
                    p <- p + theme(axis.title.y = element_text(size = input$Signature_subtype_XY_title.font.size), axis.title.x = element_text(size = input$Signature_subtype_XY_title.font.size))
                    p <- p + theme(legend.position = 'none')
                    p <- p + theme(plot.title = element_text(size = input$Signature_subtype_title.font.size))
                    p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    if(input$Signature_subtype_white_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", size=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p
                }, width=reactive(input$Signature_subtype_fig.width), height=reactive(input$Signature_subtype_fig.height), res=300)
            #

            # plot option UI
                output$Signature_subtype_use_single_colour_ui <- renderUI({
                    if(length(input$Signature_subtype_use_single_colour) == 0 || input$Signature_subtype_use_single_colour == FALSE){
                        return(NULL)
                    } else {
                        colourpicker::colourInput(session$ns('Signature_subtype_use_single_colour_select'), 'Choose a colour', value='#000000')
                    }
                })
        #

        # histogram
            # status
                Signature_score_distribution_status <- reactiveVal(NULL)
                output$Signature_score_distribution_status <- renderText({ Signature_score_distribution_status() })

            # plot
                output$Signature_score_distribution_plot <- renderPlot({
                    if(isCalculating()){
                        Signature_score_distribution_status('Calculating the signature score...')
                        return(ggplot())
                    }

                    if(length(signature_table()) == 0 || is.null(signature_table())){
                        Signature_score_distribution_status('Calculate the signature score first, then the distribution plot will be displayed here.')
                        return(ggplot())
                    }

                    signature_table <- signature_table()
                    Signature_score_distribution_status(NULL)
                    p <- ggplot(signature_table, aes(x=.data[[colnames(signature_table)[2]]]))
                    p <- p + geom_histogram(fill=input$Signature_score_distribution_colour, alpha=0.6, bins=input$Signature_score_distribution_bin_num)
                    p <- p + theme(axis.text = element_text(size = input$Signature_score_distribution_label_size))
                    p <- p + theme(axis.title = element_text(size = input$Signature_score_distribution_title_size))
                    p <- p + theme(plot.title = element_text(size = input$Signature_score_distribution_graphtitle_size))
                    p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    if(input$Signature_score_distribution_white_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", size=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p
                }, width=reactive(input$Signature_score_distributionfig.width), height=reactive(input$Signature_score_distribution_fig.height), res=300)


        #

}
