# =============================================================================
# Clinical - Gene Correlation: Calculation
# File: modules/Clinical/04_clinical_GeneCorrelation_calc.R
# Purpose: Handles gene input, sample filtering settings, correlation method
#          selection, and computes the pairwise correlation matrix using
#          Hmisc::rcorr. Returns reactive results consumed by the plot sub-server.
# Edit this file when: changing the correlation method, gene input logic,
#                       or sample filtering behaviour.
# Libraries required: reshape2 (loaded via libraries_Clinical.R)
# =============================================================================

gene_correlation_calc_server <- function(input, output, session, ex_table, meta_table, Custom_genesets) {
    ## Input genes setting
        GeneCorrelation_input_genes <- reactiveVal(NULL)
        # status
            Clinical_GeneCorrelation_genes_status <- reactiveVal(NULL)
            output$Clinical_GeneCorrelation_genes_status <- renderText({ Clinical_GeneCorrelation_genes_status() })
        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$Clinical_GeneCorrelation_genes <- renderUI({ textAreaInput(session$ns("Clinical_GeneCorrelation_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$Clinical_GeneCorrelation_genes_from_custom_geneset) > 0 && input$Clinical_GeneCorrelation_genes_from_custom_geneset == TRUE){
                    shinyjs::disable("Clinical_GeneCorrelation_genes")
                } else {
                    shinyjs::enable("Clinical_GeneCorrelation_genes")
                }
            })

        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$Clinical_GeneCorrelation_genes_from_custom_geneset_select <- renderUI({
                if(length(input$Clinical_GeneCorrelation_genes_from_custom_geneset) > 0 && input$Clinical_GeneCorrelation_genes_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets$Geneset.name)
                    selectInput(session$ns('Clinical_GeneCorrelation_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })

        #

        # set the GeneCorrelation_input_genes reactive value according to the manual input or the custom geneset selection
            # manually inputted genes
                observe({
                    if(length(input$Clinical_GeneCorrelation_genes) > 0){
                        # This work only when the user choose to input gene manually
                        if(length(input$Clinical_GeneCorrelation_genes_from_custom_geneset) == 0 || input$Clinical_GeneCorrelation_genes_from_custom_geneset == FALSE){
                            # when nothing is inputted or the genes names are just spaces (' ')
                            if(all(grepl("^\\s*$", input$Clinical_GeneCorrelation_genes))){
                                Clinical_GeneCorrelation_genes_status('Please enter gene names in the box above, one gene per line.')
                                GeneCorrelation_input_genes(NULL)
                                return(NULL)
                            }

                            # when there are gene names inputted
                            genes_tmp <- unique(unlist(strsplit(input$Clinical_GeneCorrelation_genes, split="\n")))
                            genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                            GeneCorrelation_input_genes(genes_tmp)
                            Clinical_GeneCorrelation_genes_status(paste0("You have manually input ", length(GeneCorrelation_input_genes()), " gene(s)."))
                        }
                    }
                })

            #

            # genes from custom geneset
                observe({
                    if(length(input$Clinical_GeneCorrelation_genes_from_custom_geneset) > 0 && input$Clinical_GeneCorrelation_genes_from_custom_geneset == TRUE){
                        if(length(input$Clinical_GeneCorrelation_genes_from_custom_geneset_select) == 0 || input$Clinical_GeneCorrelation_genes_from_custom_geneset_select == 'None'){
                            Clinical_GeneCorrelation_genes_status("Please select a custom geneset above first.")
                            GeneCorrelation_input_genes(NULL)
                            return(NULL)
                        }else{
                            genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$Clinical_GeneCorrelation_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                            GeneCorrelation_input_genes(genes)
                            Clinical_GeneCorrelation_genes_status(paste0("You have input ", length(GeneCorrelation_input_genes()), " gene(s) from your selected custom geneset."))
                        }
                    }
                })

            #

        ##

    ##

    ## Sample filtering setting
            # status
                Clinical_Gene_correlation_frequency_filter_selection_number <- reactiveVal(NULL)
                output$Clinical_Gene_correlation_frequency_filter_selection_number <- renderText({ Clinical_Gene_correlation_frequency_filter_selection_number() })
            #

            # variables
                All_sample_flag <- reactiveVal(TRUE) # default use all the samples for survival analysis
                filtered_sample_ids <- reactiveVal(NULL) # store the filtered sample ids when users choose to use a specific category of samples for survival analysis
            #

            # when users choose a category for filtering, show the category selection dropdown
                # group selection dropdown
                    output$Clinical_Gene_correlation_frequency_filter_selection <- renderUI({
                        if(length(input$Clinical_Gene_correlation_frequency_filter) == 0 || input$Clinical_Gene_correlation_frequency_filter == 'A'){
                            return(NULL)
                        }else{
                            selectInput(session$ns("Clinical_Gene_correlation_frequency_filter_selection"), "Filtering by:", c('None'='None', colnames(meta_table())))
                        }
                    })
                #

                # category selection dropdown
                    output$Clinical_Gene_correlation_frequency_filter_selection_category <- renderUI({
                        if(length(input$Clinical_Gene_correlation_frequency_filter) == 0 || input$Clinical_Gene_correlation_frequency_filter == 'A'){
                            return(NULL)
                        }else{
                            if(length(input$Clinical_Gene_correlation_frequency_filter_selection) == 0 || is.null(input$Clinical_Gene_correlation_frequency_filter_selection) ||  input$Clinical_Gene_correlation_frequency_filter_selection == 'None'){
                                selectInput(session$ns("Clinical_Gene_correlation_frequency_filter_selection_category"), "Category:", c('None'='None'))
                            }else{
                                selectInput(session$ns("Clinical_Gene_correlation_frequency_filter_selection_category"), "Category:", c('None'='None', unique(meta_table()[,input$Clinical_Gene_correlation_frequency_filter_selection])))
                            }
                        }
                    })
                #

                # show the number of samples. When no filtering, show the number of all the samples
                    observe({
                        if(!is.null(meta_table())){
                            if(length(input$Clinical_Gene_correlation_frequency_filter) > 0 && input$Clinical_Gene_correlation_frequency_filter == 'A'){
                                All_sample_flag(TRUE)
                                Clinical_Gene_correlation_frequency_filter_selection_number(paste0("The total number of samples is ", nrow(meta_table()), "."))

                            }else if(length(input$Clinical_Gene_correlation_frequency_filter) > 0 && input$Clinical_Gene_correlation_frequency_filter == 'B'){
                                All_sample_flag(FALSE)
                                if(length(input$Clinical_Gene_correlation_frequency_filter_selection) > 0 && input$Clinical_Gene_correlation_frequency_filter_selection != 'None' && length(input$Clinical_Gene_correlation_frequency_filter_selection_category) > 0 && input$Clinical_Gene_correlation_frequency_filter_selection_category != 'None'){
                                    num <- nrow(meta_table()[meta_table()[,input$Clinical_Gene_correlation_frequency_filter_selection] %in% input$Clinical_Gene_correlation_frequency_filter_selection_category, ])
                                    filtered_sample_ids(meta_table()[meta_table()[,input$Clinical_Gene_correlation_frequency_filter_selection] %in% input$Clinical_Gene_correlation_frequency_filter_selection_category, ]$sample)
                                    Clinical_Gene_correlation_frequency_filter_selection_number(paste0("You have chosen to use the samples in category ", input$Clinical_Gene_correlation_frequency_filter_selection_category, " of ", input$Clinical_Gene_correlation_frequency_filter_selection, " for the correlation analysis. \nThe number of the selected samples is ", num, "."))
                                }else{
                                    filtered_sample_ids(NULL)
                                    Clinical_Gene_correlation_frequency_filter_selection_number("Please select a category for filtering.")
                                }
                            }else{
                                Clinical_Gene_correlation_frequency_filter_selection_number(NULL)
                            }
                        }else{
                            Clinical_Gene_correlation_frequency_filter_selection_number(NULL)
                        }
                    })
                #
            #

    ##

    ## correlation method
        Correlation_method <- reactiveVal(NULL)
        observe({
            if(length(input$Gene_correlation_Correlation_method) > 0){
                Correlation_method(input$Gene_correlation_Correlation_method)
            }
        })

    ##

    ## Calculate the correlation across the input genes
        # extract the sub expression matrix based on the input gene
        # calculate the gene correlation matrix
        # export a list of a correlation table for each gene, and the correlation of all the genes

        # status
            Gene_correlation_all_status <- reactiveVal(NULL)
            output$Gene_correlation_all_status <- renderText({ Gene_correlation_all_status() })

        #

        # calculate
            Correlation_result_list <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            observeEvent(input$Gene_correlation_start, {
                # check if the dataset is loaded
                    if(length(ex_table())== 0 || is.null(ex_table())){
                        Gene_correlation_all_status("Please select a dataset first.")
                        show_alert(title = "Error", text = "Please select a dataset first.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                GeneCorrelation_input_genes <- GeneCorrelation_input_genes()[GeneCorrelation_input_genes() != ""] # remove empty gene names if there are any
                # when no input
                    if(is.null(GeneCorrelation_input_genes) || length(GeneCorrelation_input_genes) == 0){
                        Gene_correlation_all_status("Please input genes for correlation analysis.")
                        show_alert(title = "Error", text = "Please input genes for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # when only one gene is input
                    if(length(GeneCorrelation_input_genes) == 1){
                        Gene_correlation_all_status("Please input at least two genes for correlation analysis.")
                        show_alert(title = "Error", text = "Please input at least two genes for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #


                # check the valid input gene (the genes included in the expression matrix)
                    valid_genes <- GeneCorrelation_input_genes[GeneCorrelation_input_genes %in% rownames(ex_table())]
                    not_found_gene <- GeneCorrelation_input_genes[!GeneCorrelation_input_genes %in% rownames(ex_table())]
                    if(length(valid_genes) == 0){
                        Gene_correlation_all_status("None of the input genes are included in the expression dataset. Please check your input.")
                        show_alert(title = "Error", text = "None of the input genes are included in the expression dataset. Please check your input.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # when sample filtering setting is on but no category is selected for filtering
                    if(length(input$Clinical_Gene_correlation_frequency_filter) > 0 && input$Clinical_Gene_correlation_frequency_filter == 'B' && (length(input$Clinical_Gene_correlation_frequency_filter_selection) == 0 || input$Clinical_Gene_correlation_frequency_filter_selection == 'None' || length(input$Clinical_Gene_correlation_frequency_filter_selection_category) == 0 || input$Clinical_Gene_correlation_frequency_filter_selection_category == 'None')){
                        Gene_correlation_all_status("Please select a category for sample filtering.")
                        show_alert(title = "Error", text = "Please select a category for sample filtering.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # when there is only one sample after the filtering
                    if(All_sample_flag() == FALSE && !is.null(filtered_sample_ids()) && length(filtered_sample_ids()) <= 1){
                        Gene_correlation_all_status("The number of samples for correlation analysis is 1 after the filtering. Please select a different category for filtering or choose to use all the samples.")
                        show_alert(title = "Error", text = "The number of samples for correlation analysis is 1 after the filtering. Please select a different category for filtering or choose to use all the samples.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # extract the expression table. If the sample filtering setting is on, extract the filtered samples
                    df_ex_for_correlation <- ex_table()[valid_genes, , drop=FALSE]
                    if(All_sample_flag() == FALSE && !is.null(filtered_sample_ids())){
                        df_ex_for_correlation <- df_ex_for_correlation[, colnames(df_ex_for_correlation) %in% filtered_sample_ids(), drop=FALSE]
                    }else{
                        df_ex_for_correlation <- df_ex_for_correlation
                    }
                #

                # calculate the correlation
                    res <- Hmisc::rcorr(as.matrix(t(df_ex_for_correlation)), type = Correlation_method())
                    cor_all <- res$r
                    cor_p <- res$P
                #

                # make a table for each gene. Each table should contain r and p
                    result_list <- list()
                    for(gene in valid_genes){
                        gene_result <- data.frame(Gene = colnames(cor_all), Correlation = cor_all[gene, ], P_value = cor_p[gene, ])
                        gene_result <- gene_result[order(abs(gene_result$Correlation), decreasing = TRUE), ]
                        rownames(gene_result) <- NULL
                        result_list[[gene]] <- gene_result
                    }
                    result_list[['All_genes_correlation']] <- cor_all
                    result_list[['All_genes_p_value']] <- cor_p
                    Correlation_result_list(result_list)

                #

                # return the lists and show the status. If there are error genes, show them
                    message <- paste0("Correlation calculation is done for ", length(valid_genes), " gene(s) across ", dim(df_ex_for_correlation)[2], " sample(s).")
                    if(length(not_found_gene) > 0){
                        message <- paste0(message, "\nThe following gene(s) are not included in the expression dataset and thus not included in the correlation analysis: \n", paste(not_found_gene, collapse = ", "), "")
                    }
                    Gene_correlation_all_status(message)

                    isCalculating(FALSE)
                    return(NULL)

                #

            })

        #
    ##

    return(list(
        Correlation_result_list = Correlation_result_list,
        isCalculating           = isCalculating,
        All_sample_flag         = All_sample_flag,
        filtered_sample_ids     = filtered_sample_ids
    ))
}
