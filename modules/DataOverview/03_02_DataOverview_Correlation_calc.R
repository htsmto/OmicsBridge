# =============================================================================
# DataOverview - Correlation Analysis: Calculation
# File: modules/DataOverview/03_02_DataOverview_Correlation_calc.R
# Purpose: Handles gene input (manual text or custom geneset), sample
#          selection, and pairwise correlation matrix computation via
#          Hmisc::rcorr (Pearson / Spearman / Kendall).
# Edit this file when: changing the correlation method, input validation,
#                       sample filtering, or log-transformation logic.
# =============================================================================

correlation_calc_server <- function(input, output, session, df_ex, Custom_geneset) {
    ## Input and Settings ----
        Two_gene_corr_input_gene <- reactiveVal(NULL)

        # status
            Two_gene_corr_genes_status <- reactiveVal(NULL)
            output$Two_gene_corr_genes_status <- renderText({ Two_gene_corr_genes_status() })
        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$Two_gene_corr_input <- renderUI({ textAreaInput(session$ns("Two_gene_corr_input"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$Two_gene_corr_input_from_custom_geneset) > 0 && input$Two_gene_corr_input_from_custom_geneset == TRUE){
                    shinyjs::disable("Two_gene_corr_input")
                } else {
                    shinyjs::enable("Two_gene_corr_input")
                }
            })

        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$Two_gene_corr_input_from_custom_geneset_select <- renderUI({
                if(length(input$Two_gene_corr_input_from_custom_geneset) > 0 && input$Two_gene_corr_input_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_geneset()$Geneset.name)
                    selectInput(session$ns('Two_gene_corr_input_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })

        #

        # set the GeneCorrelation_input_genes reactive value according to the manual input or the custom geneset selection
            # manually inputted genes
                observe({
                    if(length(input$Two_gene_corr_input) > 0){
                        # This work only when the user choose to input gene manually
                        if(length(input$Two_gene_corr_input_from_custom_geneset) == 0 || input$Two_gene_corr_input_from_custom_geneset == FALSE){
                            # when nothing is inputted or the genes names are just spaces (' ')
                            if(all(grepl("^\\s*$", input$Two_gene_corr_input))){
                                Two_gene_corr_genes_status('Please enter gene names in the box above, one gene per line.')
                                Two_gene_corr_input_gene(NULL)
                                return(NULL)
                            }

                            # when there are gene names inputted
                            genes_tmp <- unique(unlist(strsplit(input$Two_gene_corr_input, split="\n")))
                            genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                            Two_gene_corr_input_gene(genes_tmp)
                            Two_gene_corr_genes_status(paste0("You have manually input ", length(Two_gene_corr_input_gene()), " gene(s)."))
                        }
                    }
                })

            #

            # genes from custom geneset
                observe({
                    if(length(input$Two_gene_corr_input_from_custom_geneset) > 0 && input$Two_gene_corr_input_from_custom_geneset == TRUE){
                        if(length(input$Two_gene_corr_input_from_custom_geneset_select) == 0 || input$Two_gene_corr_input_from_custom_geneset_select == 'None'){
                            Two_gene_corr_genes_status("Please select a custom geneset above first.")
                            Two_gene_corr_input_gene(NULL)
                            return(NULL)
                        }else{
                            genes <- strsplit(Custom_geneset()[Custom_geneset()$Geneset.name %in% input$Two_gene_corr_input_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                            Two_gene_corr_input_gene(genes)
                            Two_gene_corr_genes_status(paste0("You have input ", length(Two_gene_corr_input_gene()), " gene(s) from your selected custom geneset."))
                        }
                    }
                })

            #

        #
    ##

    ## Sample selection
        # status
            Two_gene_corr_sample_table_status <- reactiveVal(NULL)
            output$Two_gene_corr_sample_table_status <- renderText({ Two_gene_corr_sample_table_status() })
        #

        # sample table
            Two_gene_corr_sample_table_tmp <- reactiveVal(NULL)
            observe({
                if(is.null(df_ex())){
                    Two_gene_corr_sample_table_tmp(NULL)
                    return(NULL)
                }else{
                    samples <- colnames(df_ex())[!(colnames(df_ex())=='id')]
                    Two_gene_corr_sample_table_tmp(data.frame(Sample_name=samples[order(samples)]))
                }
            })
        #

        # show the sample table for selection
            output$Two_gene_corr_sample_table <- renderDataTable({
                datatable( Two_gene_corr_sample_table_tmp(), selection='none', extensions=c('Select', 'Buttons', 'Scroller', 'RowReorder'),
                    options = list(
                        select=list(style="multi", items='row'), rowReorder = TRUE, order = list(c(0 , 'asc')),
                        scroller=TRUE, deferRender=TRUE, scrollY=200,
                        dom='Blfrtip', buttons=c('selectAll', 'selectNone'), pageLength = 10)
                    )
            },server = FALSE)
        #

        # Sample selection
            Selected_samples <- reactiveVal(NULL)
            observe({
                # when no sample table
                if(is.null(Two_gene_corr_sample_table_tmp())){
                    Selected_samples(NULL)
                    Two_gene_corr_sample_table_status("No sample is available for selection. Please check your input data.")
                    return(NULL)
                }

                # when sample table is available but no sample is selected
                if(length(input$Two_gene_corr_sample_table_rows_selected) == 0){
                    Selected_samples(NULL)
                    Two_gene_corr_sample_table_status("Please select samples from the table below.")
                    return(NULL)
                }

                # when sample(s) is selected, show the number of selected samples
                selected_samples <- Two_gene_corr_sample_table_tmp()[input$Two_gene_corr_sample_table_rows_selected, ,drop=FALSE ]$Sample_name
                Selected_samples(selected_samples)
                Two_gene_corr_sample_table_status(paste0(length(Selected_samples()), " sample(s) selected."))
                return(NULL)

            })
        #
    ##

    ## correlation method
        Correlation_method <- reactiveVal(NULL)
        observe({
            if(length(input$Two_gene_corr_Correlation_method) > 0){
                Correlation_method(input$Two_gene_corr_Correlation_method)
            }
        })

    ##

    ## Calculate the correlation across the input genes
        # extract the sub expression matrix based on the input gene
        # calculate the gene correlation matrix
        # export a list of a correlation table for each gene, and the correlation of all the genes

        # status
            Two_gene_corr_status <- reactiveVal(NULL)
            output$Two_gene_corr_status <- renderText({ Two_gene_corr_status() })

        #

        # calculate
            Correlation_result_list <- reactiveVal(NULL)
            df_ex_for_correlation <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            observeEvent(input$Two_gene_corr_start_pairwise, {
                # check if the dataset is loaded
                    if(length(df_ex())== 0 || is.null(df_ex())){
                        Two_gene_corr_status("Please select a dataset first.")
                        show_alert(title = "Error", text = "Please select a dataset first.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                GeneCorrelation_input_genes <- Two_gene_corr_input_gene()[Two_gene_corr_input_gene() != ""] # remove empty gene names if there are any
                # when no input
                    if(is.null(GeneCorrelation_input_genes) || length(GeneCorrelation_input_genes) == 0){
                        Two_gene_corr_status("Please input genes for correlation analysis.")
                        show_alert(title = "Error", text = "Please input genes for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # when only one gene is input
                    if(length(GeneCorrelation_input_genes) == 1){
                        Two_gene_corr_status("Please input at least two genes for correlation analysis.")
                        show_alert(title = "Error", text = "Please input at least two genes for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #


                # check the valid input gene (the genes included in the expression matrix)
                    valid_genes <- GeneCorrelation_input_genes[GeneCorrelation_input_genes %in% df_ex()$id]
                    not_found_gene <- GeneCorrelation_input_genes[!GeneCorrelation_input_genes %in% df_ex()$id]
                    if(length(valid_genes) == 0){
                        Two_gene_corr_status("None of the input genes are included in the expression dataset. Please check your input.")
                        show_alert(title = "Error", text = "None of the input genes are included in the expression dataset. Please check your input.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # sample selection. No sample is selected
                    if(length(Selected_samples()) == 0){
                        Two_gene_corr_status("No sample is selected. Please select samples for correlation analysis.")
                        show_alert(title = "Error", text = "No sample is selected. Please select samples for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #

                # Only ≤4 sample is selected
                    if(length(Selected_samples()) <= 4){
                        Two_gene_corr_status("Only a few samples are selected. Please select at least 5 samples for correlation analysis.")
                        show_alert(title = "Error", text = "Only a few samples are selected. Please select at least 5 samples for correlation analysis.", type = "error")
                        isCalculating(FALSE)
                        Correlation_result_list(NULL)
                        return(NULL)
                    }
                #


                # extract the expression table.
                    df_ex_for_correlation <- df_ex()[df_ex()$id %in% valid_genes, , drop=FALSE]

                    # if any ids are duplicated, add a suffix (.1, .2, etc.) to make them unique, because the correlation calculation cannot be done when there are duplicated row names
                        if(any(duplicated(df_ex_for_correlation$id))){
                            df_ex_for_correlation$id <- make.unique(df_ex_for_correlation$id)
                        }
                    rownames(df_ex_for_correlation) <- df_ex_for_correlation$id
                    df_ex_for_correlation <- df_ex_for_correlation[, -which(colnames(df_ex_for_correlation) == "id"), drop=FALSE]
                    df_ex_for_correlation <- df_ex_for_correlation[, Selected_samples(), drop=FALSE]

                    # if the user choose to use log scale, transform the data to log scale. Add a small number (0.01) to avoid log(0)
                        if(length(input$Two_gene_corr_log) > 0 && input$Two_gene_corr_log == TRUE){
                            df_ex_for_correlation <- log2(df_ex_for_correlation + 1)
                        }
                #

                df_ex_for_correlation(df_ex_for_correlation)
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
                    message <- paste0("Correlation calculation is done for ", length(valid_genes), " genes across ", dim(df_ex_for_correlation)[2], " sample(s).")
                    if(length(not_found_gene) > 0){
                        message <- paste0(message, "\nThe following gene(s) are not included in the expression dataset and thus not included in the correlation analysis: \n", paste(not_found_gene, collapse = ", "), "")
                    }
                    Two_gene_corr_status(message)

                    isCalculating(FALSE)
                    return(NULL)

                #

            })

        #
    ##

    return(list(
        Correlation_result_list  = Correlation_result_list,
        df_ex_for_correlation    = df_ex_for_correlation,
        isCalculating            = isCalculating
    ))
}
