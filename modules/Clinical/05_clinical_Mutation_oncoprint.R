# =============================================================================
# Clinical - Mutation: Expression Comparison
# File: modules/Clinical/05_clinical_Mutation_oncoprint.R
# Purpose: Compares gene expression between mutation-positive and wild-type
#          sample groups. Handles gene input resolution for the expression
#          comparison genes, renders the selection table, and renders the
#          comparison plot (boxplot / violin / beeswarm / violin+jitter).
# Edit this file when: changing the expression comparison plot type options,
#                      statistical test, or gene input logic for this section.
# =============================================================================

mutation_oncoprint_server <- function(input, output, session,
                                      ex_table, survival_table, meta_table, mutation_table, Custom_genesets,
                                      mut_freq_table, isCalculating, All_sample_flag, filtered_sample_ids) {

    # Expression comparison
        # input
            # status
                Clinical_Mutation_Gene_expression_genes_input_status <- reactiveVal()
                output$Clinical_Mutation_Gene_expression_genes_input_status <- renderText({ Clinical_Mutation_Gene_expression_genes_input_status() })
            #

            # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
                output$Clinical_Mutation_Gene_expression_geneInput <- renderUI({ textAreaInput(session$ns("Clinical_Mutation_Gene_expression_geneInput"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
                observe({
                    if(length(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset) > 0 && input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset == TRUE){
                        shinyjs::disable("Clinical_Mutation_Gene_expression_geneInput")
                    } else if (length(input$Clinical_Mutation_Gene_expression_geneInput_from_the_cohort) > 0 && input$Clinical_Mutation_Gene_expression_geneInput_from_the_cohort == TRUE){
                        shinyjs::disable("Clinical_Mutation_Gene_expression_geneInput")
                    } else {
                        shinyjs::enable("Clinical_Mutation_Gene_expression_geneInput")
                    }
                })

            #

            # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
                output$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select <- renderUI({
                    if(length(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset) > 0 && input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset == TRUE){
                        gene_sets_names <- c(Custom_genesets()$Geneset.name)
                        selectInput(session$ns('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                    } else {
                        return(NULL)
                    }
                })

            #

            # set the Mutation_input_genes reactive value according to the manual input or the custom geneset selection
                Mutation_gene_comapre_input_genes <- reactiveVal(NULL)
                # manually inputted genes
                    observe({
                        if(length(input$Clinical_Mutation_Gene_expression_geneInput) > 0){
                            # This work only when the user choose to input gene manually
                            if(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset == FALSE){
                                # when nothing is inputted or the genes names are just spaces (' ')
                                if(all(grepl("^\\s*$", input$Clinical_Mutation_Gene_expression_geneInput))){
                                    Mutation_gene_comapre_input_genes(NULL)
                                    Clinical_Mutation_Gene_expression_genes_input_status('Please enter gene names in the box above, one gene per line.')
                                    return(NULL)
                                }

                                # when there are gene names inputted
                                genes_tmp <- unique(unlist(strsplit(input$Clinical_Mutation_Gene_expression_geneInput, split="\n")))
                                genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                                Mutation_gene_comapre_input_genes(genes_tmp)
                                Clinical_Mutation_Gene_expression_genes_input_status(paste0("You have manually input ", length(Mutation_gene_comapre_input_genes()), " gene(s)."))
                            }
                        }
                    })

                #

                # genes from custom geneset
                    observe({
                        if(length(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset) > 0 && input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset == TRUE){
                            if(length(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select) == 0 || input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select == 'None'){
                                Clinical_Mutation_Gene_expression_genes_input_status("Please select a custom geneset above first.")
                                Mutation_gene_comapre_input_genes(NULL)
                                return(NULL)
                            }else{
                                genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                                Mutation_gene_comapre_input_genes(genes)
                                Clinical_Mutation_Gene_expression_genes_input_status(paste0("You have input ", length(Mutation_gene_comapre_input_genes()), " gene(s) from your selected custom geneset."))
                            }
                        }
                    })

                #


            #

        #

        # input gene table
            # status
                Clinical_Mutation_Gene_expression_geneInput_selecttable_status <- reactiveVal()
                output$Clinical_Mutation_Gene_expression_geneInput_selecttable_status <- renderText({ Clinical_Mutation_Gene_expression_geneInput_selecttable_status() })
            #

            # show the input gene table
                output$Clinical_Mutation_Gene_expression_geneInput_selecttable <- DT::renderDataTable({
                    if(length(Mutation_gene_comapre_input_genes()) == 0 || is.null(Mutation_gene_comapre_input_genes())){
                        Clinical_Mutation_Gene_expression_geneInput_selecttable_status("No gene is selected. Please set the input genes.")
                        tmp <- data.frame('Input genes'=character(0))
                        datatable(tmp, options = list(scrollX = TRUE, pageLength = 10), selection = list(mode='single'))
                    }else{
                        Clinical_Mutation_Gene_expression_geneInput_selecttable_status(NULL)
                        df <- data.frame('Input genes'=Mutation_gene_comapre_input_genes())
                        datatable(df, options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE, selection = list(mode='single'))
                    }
                })
            #
        #

        # comparison plot
            # status
                Clinical_Mutation_Gene_expression_geneInput_plot_status <- reactiveVal()
                output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({ Clinical_Mutation_Gene_expression_geneInput_plot_status() })
            #

            # plot
                output$Clinical_Mutation_Gene_expression_geneInput_plot <- renderPlot({
                    # when no mutation frequency table is generated
                        if(length(mut_freq_table()) == 0 || is.null(mut_freq_table())){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("Please calculate the mutation frequency first.")
                            return(ggplot())
                        }
                    #

                    # when the mutation frequency table is generated, but no gene is selected for comparison
                        if(length(input$Clinical_Mutation_frequency_table_rows_selected) == 0 || input$Clinical_Mutation_frequency_table_rows_selected == 'None'){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("Please select a gene from the frequency table for the expression comparison.")
                            return(ggplot())
                        }
                    #

                    # when the mutation frequency table is generated and a gene is selected for comparison, but no gene is selected for checking the expression
                        if(length(input$Clinical_Mutation_Gene_expression_geneInput_selecttable_rows_selected) == 0 || input$Clinical_Mutation_Gene_expression_geneInput_selecttable_rows_selected == 'None'){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("Please select a gene from the input gene table for the expression comparison between mutated and wild type samples of the selected gene.")
                            return(ggplot())
                        }
                    #

                    # when the mutation frequency table is generated, a gene is selected for comparison, and a gene is selected for checking the expression, but no plot type is selected
                        if(length(input$Clinical_Mutation_Gene_expression_plot_type) == 0 || input$Clinical_Mutation_Gene_expression_plot_type == 'None'){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("Please select a plot type for the expression comparison between mutated and wild type samples  of the selected gene.")
                            return(ggplot())
                        }
                    #

                    # genes
                        gene_selected_from_frquency_table <- mut_freq_table()[input$Clinical_Mutation_frequency_table_rows_selected, ]$genes
                        gene_ex <- Mutation_gene_comapre_input_genes()[input$Clinical_Mutation_Gene_expression_geneInput_selecttable_rows_selected]
                    #

                    # get the group (WT and Mutant)
                        df_mut <- mutation_table()
                        df_geneEx <- ex_table()

                        # if samples were filtered by meta data
                        if(All_sample_flag() == FALSE){
                            df_mut <- df_mut[df_mut$sample %in% filtered_sample_ids(), ]
                            df_geneEx <- df_geneEx[, intersect(colnames(df_geneEx), filtered_sample_ids())]
                        }

                        # if the gene is not in the expression table
                        if(!(gene_ex %in% rownames(df_geneEx))){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status(paste0("The gene you selected for expression comparison (", gene_ex, ") is not found in the expression data. \nPlease select another gene or check your expression data."))
                            return(ggplot())
                        }

                        df_mut_sample <- unique(intersect(colnames(df_geneEx), df_mut[df_mut$id == gene_selected_from_frquency_table, ]$sample))
                        df_wt_sample <- setdiff(colnames(df_geneEx), df_mut_sample)
                        Clinical_Mutation_Gene_expression_geneInput_plot_status(paste(df_wt_sample, collapse = ", "))

                        # if either of them are empty, show the message and do not plot
                        if(length(df_mut_sample) == 0){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("There is no mutated sample for the selected gene. Please select another gene for comparison or check your mutation data.")
                            return(ggplot())
                        }
                        if(length(df_wt_sample) == 0){
                            Clinical_Mutation_Gene_expression_geneInput_plot_status("There is no wild type sample for the selected gene. Please select another gene for comparison or check your mutation data.")
                            return(ggplot())
                        }
                    #

                    # get the expression data and do the test
                        mut_ex <- df_geneEx[gene_ex,df_mut_sample]
                        wt_ex <- df_geneEx[gene_ex,df_wt_sample]

                        test_res <- wilcox.test(as.numeric(mut_ex), as.numeric(wt_ex))
                        # show the comparison detail and statistic result
                        message <- paste0("You are comparing the expression of ", gene_ex, " \nbetween samples with mutation in ", gene_selected_from_frquency_table, " (n=", length(df_mut_sample), ") and samples without mutation in ", gene_selected_from_frquency_table, " (n=", length(df_wt_sample), ").")
                        message_result <- paste0('Statistic (Wilcox test): ', test_res$statistic, '\n', 'P-value: ', test_res$p.value)
                        Clinical_Mutation_Gene_expression_geneInput_plot_status(paste(message, "\n", message_result))
                    #

                    # plot
                        df_mut_ex <- data.frame('Expression'=as.numeric(mut_ex), 'Group'='Mutation')
                        df_wt_ex <- data.frame('Expression'=as.numeric(wt_ex), 'Group'='Wild.type')
                        df_out <- rbind(df_mut_ex, df_wt_ex)
                        df_out$Group <- factor(df_out$Group, levels=c('Mutation','Wild.type'))

                        p <- ggplot(df_out, aes(x=Group, y=Expression, fill=Group))
                        if(input$Clinical_Mutation_Gene_expression_plot_type == 'A'){ # boxplot
                            p <- p + geom_boxplot(size=0.2, outlier.size=0.5)
                        }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'B'){
                            p <- p + geom_violin(trim = FALSE, size=0.2)
                        }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'C'){
                            p <- ggplot(df_out, aes(x=Group, y=Expression, color=Group))
                            p <- p + geom_beeswarm(size=input$Clinical_Mutation_Gene_expression_dot.size)
                        }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'D'){
                            p <- p + geom_violin(trim = FALSE, size=0.2)
                            p <- p + geom_jitter(width=0.1, height=0, size=input$Clinical_Mutation_Gene_expression_dot.size)
                        }
                            p <- p + scale_fill_manual(name= NULL,
                            labels = c(paste0(gene_selected_from_frquency_table, '-Mutation (', length(df_mut_sample), ')'), paste0(gene_selected_from_frquency_table, '-Wild.type (', length(df_wt_sample), ')')),
                            values = c('Mutation' = input$Clinical_Mutation_Gene_expression_col_mut, 'Wild.type' = input$Clinical_Mutation_Gene_expression_col_wt )
                        )
                        if(input$Clinical_Mutation_Gene_expression_plot_type == 'C'){
                        p <- p + scale_color_manual(name= NULL,
                            labels = c(paste0(gene_selected_from_frquency_table, '-Mutation (', length(df_mut_sample), ')'), paste0(gene_selected_from_frquency_table, '-Wild.type (', length(df_wt_sample), ')')),
                            values = c('Mutation' = input$Clinical_Mutation_Gene_expression_col_mut, 'Wild.type' = input$Clinical_Mutation_Gene_expression_col_wt )
                        )
                        }
                        p <- p + theme(legend.position = "top", legend.box.margin = margin(t = -10, b = 0))
                        p <- p + theme(axis.text = element_text(size = input$Clinical_Mutation_Gene_expression_XY_label.font.size))
                        p <- p + theme(axis.title = element_text(size = input$Clinical_Mutation_Gene_expression_XY_title.font.size))
                        p <- p + ggtitle(gene_ex) + theme(plot.title = element_text(size = input$Clinical_Mutation_Gene_expression_title.font.size))
                        p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                        p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        p <- p + theme(legend.key.size = unit(1.5, "mm"))
                        p <- p + theme(legend.text = element_text(size=input$Clinical_Mutation_Gene_expression_legend.font.size), legend.title = element_text(size=input$Clinical_Mutation_Gene_expression_legend.font.size))
                        if(input$Clinical_Mutation_Gene_expression_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p

                    #

                }, width=reactive(input$Clinical_Mutation_Gene_expression_fig.width), height=reactive(input$Clinical_Mutation_Gene_expression_fig.height), res=300)
            #
        #


    ##
}
