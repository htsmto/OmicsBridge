# =============================================================================
# Clinical - Deconvolution: Association with Mutations (Plot & Table)
# File: modules/Clinical/08_clinical_Deconvolution_mutation_plot.R
# Purpose: Renders the Mutant vs WT test result table and the box / violin /
#          swarm / violin+swarm plot of the cell-type abundance for the selected
#          gene. Optionally splits the Mutant group by the type of mutation
#          (Amino_Acid_Change column) and shows a swarm plot.
# Edit this file when: changing the plot aesthetics, the mutation-type view,
#                      or the result table download.
# =============================================================================

deconvolution_mutation_plot_server <- function(input, output, session, Mutation_data,
                                               Deconvolution_mutation_result,
                                               isCalculating_Deconvolution_mutation,
                                               Deconvolution_mutation_plot_info) {

    ## Test result table
        # status
            Deconvolution_Mutation_table_status <- reactiveVal(NULL)
            output$Deconvolution_Mutation_table_status <- renderText({ Deconvolution_Mutation_table_status() })
        #

        # table
            output$Deconvolution_Mutation_table <- renderDataTable({
                if(isCalculating_Deconvolution_mutation() == TRUE){
                    Deconvolution_Mutation_table_status('Calculating... Please wait.')
                    return(NULL)
                } else if(is.null(Deconvolution_mutation_result()) || nrow(Deconvolution_mutation_result()) == 0){
                    Deconvolution_Mutation_table_status('No test result to show. Please click the "Start comparing" button to perform the test first.')
                    datatable(data.frame('Gene'=character(0), 'Statistic'=numeric(0), 'P.value'=numeric(0), stringsAsFactors = FALSE) , selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                } else {
                    Deconvolution_Mutation_table_status(NULL)
                    datatable(Deconvolution_mutation_result(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                }
            })
        #

        # download the table
            output$Deconvolution_Mutation_table_download <- downloadHandler(
            filename = function(){"Deconvolution_mutation_association.tsv"},
            content = function(fname){ write.table(Deconvolution_mutation_result(), fname, sep='\t', row.names=F, quote=F) }
            )
        #
    ##

    ## Mutant / WT groups for the selected gene
        # the gene selected in the result table
            selected_gene <- function(){
                if(is.null(Deconvolution_mutation_result()) || length(input$Deconvolution_Mutation_table_rows_selected) == 0){
                    return(NULL)
                }
                Deconvolution_mutation_result()[input$Deconvolution_Mutation_table_rows_selected,]$Gene
            }
        #

        # return an error message when the Mutant group cannot be split by the type of mutation, otherwise NULL
            split_by_type_error <- function(){
                gene <- selected_gene()
                if(is.null(gene)){
                    return('Please select a gene (row) from the test result table first.')
                }
                df_mut <- Mutation_data()
                if(is.null(df_mut) || !('Amino_Acid_Change' %in% colnames(df_mut))){
                    return('The mutation data does not contain the type of mutation (Amino_Acid_Change column), so the mutant group cannot be split.')
                }
                aa <- df_mut[df_mut$id %in% gene & df_mut$sample %in% Deconvolution_mutation_plot_info()$samples_used, ]$Amino_Acid_Change
                if(all(is.na(aa) | grepl("^\\s*$", aa))){
                    return(paste0('No type of mutation (Amino_Acid_Change) is recorded for ', gene, ' in the mutation data, so the mutant group cannot be split.'))
                }
                return(NULL)
            }
        #

        # make a data frame for the plot (sample, Abundance, Group)
        # by_type = TRUE: only the mutant samples, split by Amino_Acid_Change (WT is not shown).
        #   A sample with several amino acid changes in the gene -> 'Multiple'
        #   A sample with no amino acid change recorded (e.g. intron variant) -> 'No AA change'
        #   Only the top_n most frequent amino acid changes are shown; the rest -> 'Others'
            build_group_df <- function(gene, by_type, top_n = 10){
                info <- Deconvolution_mutation_plot_info()
                df_mut <- Mutation_data()
                df_mut_gene <- df_mut[df_mut$id %in% gene & df_mut$sample %in% info$samples_used, ]
                mut_samples <- unique(df_mut_gene$sample)

                df_plot <- data.frame(sample=info$samples_used, Abundance=info$abundance[info$samples_used], stringsAsFactors = FALSE)
                df_plot$Group <- ifelse(df_plot$sample %in% mut_samples, 'Mutant', 'WT')

                if(!by_type){
                    df_plot$Group <- factor(df_plot$Group, levels=c('Mutant', 'WT')) # Mutant on the left
                    return(df_plot)
                }

                aa <- trimws(as.character(df_mut_gene$Amino_Acid_Change))
                aa[is.na(aa)] <- ''
                type_per_sample <- sapply(mut_samples, function(s){
                    aa_s <- unique(aa[df_mut_gene$sample == s & aa != ''])
                    if(length(aa_s) == 0){
                        'No AA change'
                    }else if(length(aa_s) == 1){
                        aa_s
                    }else{
                        'Multiple'
                    }
                })

                # keep the top_n amino acid changes (by the number of samples, then by name), and group the rest as 'Others'
                type_counts <- table(type_per_sample)
                aa_types <- setdiff(names(type_counts), c('Multiple', 'No AA change'))
                aa_types <- aa_types[order(-type_counts[aa_types], aa_types)]
                if(length(aa_types) > top_n){
                    type_per_sample[type_per_sample %in% aa_types[-seq_len(top_n)]] <- 'Others'
                    aa_types <- aa_types[seq_len(top_n)]
                }
                # only the mutant samples are shown in the mutation-type view
                df_plot <- df_plot[df_plot$Group == 'Mutant', ]
                df_plot$Group <- type_per_sample[df_plot$sample]

                # order: amino acid changes by the number of samples, Multiple, No AA change, Others
                type_levels <- c(aa_types, intersect(c('Multiple', 'No AA change', 'Others'), type_per_sample))
                df_plot$Group <- factor(df_plot$Group, levels=type_levels)
                return(df_plot)
            }
        #

        # when the user turns on the switch (or selects another gene), check if the mutant group can be split.
        # If not, show an error message and turn off the switch.
            observeEvent(list(input$Deconvolution_Mutation_split_by_type, input$Deconvolution_Mutation_table_rows_selected), {
                if(!isTRUE(input$Deconvolution_Mutation_split_by_type)){
                    return(NULL)
                }
                error_message <- split_by_type_error()
                if(!is.null(error_message)){
                    show_alert(title='Error.', text=error_message, type='error')
                    updateMaterialSwitch(session, 'Deconvolution_Mutation_split_by_type', value = FALSE)
                }
            }, ignoreInit = TRUE)

            # the amino acid change labels are long, so rotate the X axis labels when the switch is turned on
            observeEvent(input$Deconvolution_Mutation_split_by_type, {
                if(isTRUE(input$Deconvolution_Mutation_split_by_type) && is.null(split_by_type_error())){
                    updateMaterialSwitch(session, 'Deconvolution_Mutation_rotate_x', value = TRUE)
                }
            }, ignoreInit = TRUE)
        #

        # the number of mutation types to show (the rest are grouped as 'Others')
            top_mutation_types <- function(){
                top_n <- input$Deconvolution_Mutation_top_types
                if(length(top_n) == 0 || is.na(top_n) || top_n < 1){
                    return(10)
                }
                floor(top_n)
            }
        #
    ##

    ## Plot
        # status
            Deconvolution_Mutation_plot_status <- reactiveVal(NULL)
            output$Deconvolution_Mutation_plot_status <- renderText({ Deconvolution_Mutation_plot_status() })
        #

        # plot
            output$Deconvolution_Mutation_plot <- renderPlot({
                if(isCalculating_Deconvolution_mutation() == TRUE){
                    Deconvolution_Mutation_plot_status('Calculating... Please wait.')
                    return(ggplot())
                }

                # No test results
                    if(is.null(Deconvolution_mutation_result()) || nrow(Deconvolution_mutation_result()) == 0){
                        Deconvolution_Mutation_plot_status('No test result to show. Please click the "Start comparing" button to perform the test first.')
                        return(ggplot())
                    }
                #

                # test results but no row is selected
                    if(length(input$Deconvolution_Mutation_table_rows_selected) == 0){
                        Deconvolution_Mutation_plot_status('Please select a gene (row) from the test result table to show the plot.')
                        return(ggplot())
                    }
                #

                # data for the plot
                    df_test <- Deconvolution_mutation_result()
                    gene <- selected_gene()
                    cell_type <- Deconvolution_mutation_plot_info()$cell_type
                    by_type <- isTRUE(input$Deconvolution_Mutation_split_by_type) && is.null(split_by_type_error())
                    df_plot <- build_group_df(gene, by_type, top_mutation_types())
                    n_each_group <- table(df_plot$Group)
                #

                # show the gene, cell type, the number of samples in each group and the test result
                    statistic <- df_test[input$Deconvolution_Mutation_table_rows_selected, 'Statistic (Wilcoxon)']
                    p_value <- df_test[input$Deconvolution_Mutation_table_rows_selected, 'P.value']
                    message <- paste0(
                        "Gene: ", gene, "\n",
                        "Cell type: ", cell_type, "\n",
                        "The number of samples in each group: \n",
                        paste0(names(n_each_group), ': ', n_each_group, collapse='\n'), "\n\n",
                        "Statistic (Wilcoxon, Mutant vs WT): ", statistic, "\n",
                        "P-value: ", p_value
                    )
                    if(by_type){
                        message <- paste0(message, "\n\nOnly the mutant samples are shown, split by the type of mutation (Amino_Acid_Change), as a swarm plot. \nThe statistic above is for Mutant vs WT.")
                        if('Others' %in% levels(df_plot$Group)){
                            message <- paste0(message, "\nOnly the top ", top_mutation_types(), " amino acid changes are shown. The rest are grouped as 'Others'.")
                        }
                    }
                    Deconvolution_Mutation_plot_status(message)
                #

                # colours. WT and Mutant have their own colours. In the mutation-type view, a palette can be used for the mutation types.
                    if(by_type){
                        mut_types <- levels(df_plot$Group)
                        if(length(input$Deconvolution_Mutation_select_colour_pallete) == 0 || input$Deconvolution_Mutation_select_colour_pallete == 'None'){
                            mut_colours <- rep(input$Deconvolution_Mutation_col_mut, length(mut_types))
                        }else{
                            mut_colours <- viridisLite::viridis(length(mut_types), option=input$Deconvolution_Mutation_select_colour_pallete, end=0.9)
                        }
                        colour_values <- setNames(mut_colours, mut_types)
                    }else{
                        colour_values <- c('WT'=input$Deconvolution_Mutation_col_wt, 'Mutant'=input$Deconvolution_Mutation_col_mut)
                    }
                #

                # make a plot
                    if(by_type || input$Deconvolution_Mutation_figtype == 'C'){ # swarm plot
                        p <- ggplot(df_plot, aes(x=Group, y=Abundance, color=Group))
                        # corral: keep a large group (e.g. WT) within its own column so that it does not overlap the neighbouring groups
                        p <- p + geom_beeswarm(size=input$Deconvolution_Mutation_dot.size, corral='wrap', corral.width=0.9)
                        p <- p + scale_color_manual(values = colour_values)
                    }else{
                        p <- ggplot(df_plot, aes(x=Group, y=Abundance, fill=Group))
                        if(input$Deconvolution_Mutation_figtype == 'A'){ # boxplot
                            p <- p + geom_boxplot(color='black', linewidth=0.2, outlier.size=0.5)
                        }else if(input$Deconvolution_Mutation_figtype == 'B'){ # violin plot
                            p <- p + geom_violin(color='black', trim = FALSE, linewidth=0.2)
                        }else if(input$Deconvolution_Mutation_figtype == 'D'){ # swarm plot + violin plot
                            p <- p + geom_violin(trim = FALSE, linewidth=0.2)
                            p <- p + geom_jitter(width=0.1, height=0, size=input$Deconvolution_Mutation_dot.size)
                        }
                        p <- p + scale_fill_manual(values = colour_values)
                    }
                    if(input$Deconvolution_Mutation_rotate_x){
                        p <- p + scale_x_discrete(labels = function(x) paste0(x, ' (n=', n_each_group[x], ')'))
                    }else{
                        p <- p + scale_x_discrete(labels = function(x) paste0(x, '\n(n=', n_each_group[x], ')'))
                    }
                    p <- p + labs(x = ifelse(by_type, paste0('Amino acid change of ', gene), paste0('Mutation status of ', gene)), y = paste0('Estimated abundance (', cell_type, ')'))
                    if(input$Deconvolution_Mutation_rotate_x){
                        p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                    }
                    p <- p + theme(axis.text.y = element_text(size = input$Deconvolution_Mutation_XY_label.font.size), axis.text.x = element_text(size = input$Deconvolution_Mutation_XY_label.font.size))
                    p <- p + theme(axis.title.y = element_text(size = input$Deconvolution_Mutation_XY_title.font.size), axis.title.x = element_text(size = input$Deconvolution_Mutation_XY_title.font.size))
                    p <- p + theme(legend.position = 'none')
                    p <- p + ggtitle(gene) + theme(plot.title = element_text(size = input$Deconvolution_Mutation_title.font.size))
                    p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    if(input$Deconvolution_Mutation_white_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p
                #
            }, width=reactive(input$Deconvolution_Mutation_fig.width), height=reactive(input$Deconvolution_Mutation_fig.height), res=300)
        #
    ##
}
