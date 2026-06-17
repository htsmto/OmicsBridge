# =============================================================================
# Clinical - Signature: Calculation
# File: modules/Clinical/07_clinical_Signature_calc.R
# Purpose: Accepts gene input/settings and computes per-sample signature scores
#          (ssGSEA or GSVA) from user-supplied gene lists.
# Edit this file when: changing the scoring method, gene input handling,
#                      or sample filtering logic before score calculation.
# =============================================================================

signature_calc_server <- function(input, output, session, Gene_expression, surv_table, meta_table, Custom_genesets) {
    ## Inputs and settings ----
        ## Input genes
            Signature_gene <- reactiveVal(NULL)

            # status
                Signature_genes_status <- reactiveVal(NULL)
                output$Signature_genes_status <- renderText({ Signature_genes_status() })
            #

            # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
                output$Signature_genes <- renderUI({ textAreaInput(session$ns("Signature_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
                observe({
                    if(length(input$Signature_genes_from_custom_geneset) > 0 && input$Signature_genes_from_custom_geneset == TRUE){
                        shinyjs::disable("Signature_genes")
                    } else {
                        shinyjs::enable("Signature_genes")
                    }
                })

            #

            # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
                output$Signature_genes_from_custom_geneset_select <- renderUI({
                    if(length(input$Signature_genes_from_custom_geneset) > 0 && input$Signature_genes_from_custom_geneset == TRUE){
                        gene_sets_names <- c(Custom_genesets$Geneset.name)
                        selectInput(session$ns('Signature_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                    } else {
                        return(NULL)
                    }
                })

            #

            # Set the input genes
                observe({
                    if(length(input$Signature_genes) == 0 || length(input$Signature_genes_from_custom_geneset) == 0){
                        Signature_gene(NULL)
                        Signature_genes_status(NULL)
                        return(NULL)
                    }else if(input$Signature_genes_from_custom_geneset == FALSE){
                        # custom select: off -> manual

                        if(all(grepl("^\\s*$", input$Signature_genes))){
                            Signature_genes_status('Please enter gene names in the box above, one gene per line.')
                            Signature_gene(NULL)
                            return(NULL)
                        }

                        # when there are gene names inputted
                        genes_tmp <- unique(unlist(strsplit(input$Signature_genes, split="\n")))
                        genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                        Signature_gene(genes_tmp)
                        Signature_genes_status(paste0("You have manually input ", length(Signature_gene()), " gene(s)."))

                    }else if(input$Signature_genes_from_custom_geneset == TRUE){
                        # custom select: on -> custom geneset
                        if(length(input$Signature_genes_from_custom_geneset_select) == 0 || input$Signature_genes_from_custom_geneset_select == 'None'){
                            Signature_genes_status("Please select a custom geneset above first.")
                            Signature_gene(NULL)
                            return(NULL)
                        }

                        genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$Signature_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                        Signature_gene(genes)
                        Signature_genes_status(paste0("You have input ", length(Signature_gene()), " gene(s) from your selected custom geneset."))

                    }
                })
            #
        ##

        ## Sample filtering setting
            # status
                Signature_filter_selection_number <- reactiveVal(NULL)
                output$Signature_filter_selection_number <- renderText({ Signature_filter_selection_number() })
            #

            # variables
                All_sample_flag <- reactiveVal(TRUE) # default use all the samples for survival analysis
                filtered_sample_ids_reactive <- reactiveVal(NULL) # store the filtered sample ids when users choose to use a specific category of samples for survival analysis
            #

            # when users choose a category for filtering, show the category selection dropdown
                # group selection dropdown
                    output$Signature_filter_selection <- renderUI({
                        if(length(input$Signature_filter) == 0 || input$Signature_filter == 'A'){
                            return(NULL)
                        }else{
                            selectInput(session$ns("Signature_filter_selection"), "Filtering by:", c('None'='None', colnames(meta_table())))
                        }
                    })
                #

                # category selection dropdown
                    output$Signature_filter_selection_category <- renderUI({
                        if(length(input$Signature_filter) == 0 || input$Signature_filter == 'A'){
                            return(NULL)
                        }else{
                            if(length(input$Signature_filter_selection) == 0 || is.null(input$Signature_filter_selection) ||  input$Signature_filter_selection == 'None'){
                                selectInput(session$ns("Signature_filter_selection_category"), "Category:", c('None'='None'))
                            }else{
                                selectInput(session$ns("Signature_filter_selection_category"), "Category:", c('None'='None', unique(meta_table()[,input$Signature_filter_selection])))
                            }
                        }
                    })
                #

                # show the number of samples. When no filtering, show the number of all the samples
                    observe({
                        if(!is.null(meta_table())){
                            if(length(input$Signature_filter) > 0 && input$Signature_filter == 'A'){
                                Signature_filter_selection_number(paste0("The total number of samples is ", nrow(meta_table()), "."))

                            }else if(length(input$Signature_filter) > 0 && input$Signature_filter == 'B'){
                                if(length(input$Signature_filter_selection) > 0 && input$Signature_filter_selection != 'None' && length(input$Signature_filter_selection_category) > 0 && input$Signature_filter_selection_category != 'None'){
                                    num <- nrow(meta_table()[meta_table()[,input$Signature_filter_selection] %in% input$Signature_filter_selection_category, ])
                                    filtered_sample_ids_reactive(meta_table()[meta_table()[,input$Signature_filter_selection] %in% input$Signature_filter_selection_category, ]$sample)
                                    Signature_filter_selection_number(paste0("You have chosen to use the samples in category ", input$Signature_filter_selection_category, " of ", input$Signature_filter_selection, " for the correlation analysis. \nThe number of the selected samples is ", num, "."))
                                }else{
                                    filtered_sample_ids_reactive(NULL)
                                    Signature_filter_selection_number("Please select a category for filtering.")
                                }
                            }else{
                                Signature_filter_selection_number(NULL)
                            }
                        }else{
                            Signature_filter_selection_number(NULL)
                        }
                    })
                #
            #

        ##
    ##

    ## calculate the score
        # status
            Signature_input_selection_status <- reactiveVal(NULL)
            output$Signature_input_selection_status <- renderText({ Signature_input_selection_status() })
        #

        # start button
            signature_table <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            filtered_sample_ids <- reactiveVal(NULL)
            observeEvent(input$Signature_start, {
                isCalculating(TRUE)
                # check if the gene expression table are available.
                    if(is.null(Gene_expression())){
                        show_alert(title='Error.',text='The gene expression data is not available.', type='error')
                        Signature_input_selection_status('Error: Gene expression data is not available.')
                        signature_table(NULL)
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # check if the input genes are available.
                    if(is.null(Signature_gene()) || length(Signature_gene()) == 0){
                        show_alert(title='Error.',text='The input gene list is empty. Please input gene names manually or select a custom geneset.', type='error')
                        Signature_input_selection_status('Error: The input gene list is empty. Please input gene names manually or select a custom geneset.')
                        signature_table(NULL)
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #
                genes <- Signature_gene()
                df_geneEx <- Gene_expression()
                df_geneEx[is.na(df_geneEx)] <- 0
                found_genes <- intersect(genes, rownames(df_geneEx))
                not_found_genes <- setdiff(genes, rownames(df_geneEx))

                # when no gene can be found, show error message
                    if(length(found_genes) == 0){
                        show_alert(title='Error.',text='None of the input genes can be found in the gene expression data. Please check your input.', type='error')
                        Signature_input_selection_status('Error: None of the input genes can be found in the gene expression data. Please check your input.')
                        signature_table(NULL)
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # if the user selected to fiter the samples by a specific category, check if the filtered sample list is available
                    if(length(input$Signature_filter) > 0 && input$Signature_filter == 'B'){
                        if(is.null(filtered_sample_ids_reactive())){
                            show_alert(title='Error.',text='You have chosen to filter the samples by a specific category. Please select a category for filtering to get the filtered sample list.', type='error')
                            Signature_input_selection_status('Error: You have chosen to filter the samples by a specific category. Please select a category for filtering to get the filtered sample list.')
                            signature_table(NULL)
                            isCalculating(FALSE)
                            return(NULL)
                        }else{
                            # filter the gene expression table by the filtered sample ids
                            # check if there are samples left after filtering


                            if(length(intersect(colnames(df_geneEx), filtered_sample_ids_reactive())) == 0){
                                show_alert(title='Error.',text='There are no gene expression samples left after sample filtering.', type='error')
                                Signature_input_selection_status('There are no gene expression samples left after sample filtering. Please choose a different category for filtering or choose to use all samples.')
                                signature_table(NULL)
                                isCalculating(FALSE)
                                return(NULL)
                            }
                            df_geneEx <- df_geneEx[, colnames(df_geneEx) %in% filtered_sample_ids_reactive(), drop=FALSE]
                            filtered_sample_ids(filtered_sample_ids_reactive())
                            All_sample_flag(FALSE)

                        }
                    }else{
                        All_sample_flag(TRUE)
                        filtered_sample_ids(NULL)
                    }

                # method is not selected
                    if(length(input$Signature_input_score_type) == 0){
                        show_alert(title='Error.',text='Please select a method for calculating the signature score.', type='error')
                        Signature_input_selection_status('Error: Please select a method for calculating the signature score.')
                        signature_table(NULL)
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                gene_set <- list(selected_gene_set=found_genes) # gene_set <- list(selected_gene_set=c('CXCL10', 'CXCL9'))
                method <- input$Signature_input_score_type # method='ssgsea'
                if(method=='ssGSEA'){
                    signaturePar <- ssgseaParam(as.matrix(df_geneEx), gene_set)
                }else if(method == 'GSVA'){
                    signaturePar <- gsvaParam(as.matrix(df_geneEx), gene_set)
                }
                signature_gsva <- gsva(signaturePar)
                signature_gsva_table <- data.frame(t(data.frame(signature_gsva, check.names=FALSE)), check.names=FALSE)
                signature_gsva_table$Sample <- rownames(signature_gsva_table)
                signature_gsva_table <- signature_gsva_table[order(signature_gsva_table$selected_gene_set, decreasing = T),]
                signature_gsva_table <- signature_gsva_table[, c('Sample', 'selected_gene_set')]
                colnames(signature_gsva_table)[2] <- 'Signature.score'
                rownames(signature_gsva_table) <- NULL
                # show message. how many genes were used. which genes were not found, which method was used in how many samples
                    msg <- paste0("Signature score calculated using method ", method, ". \n", length(found_genes), " out of ", length(genes), " genes were found and used for the calculation in ", nrow(signature_gsva_table), " samples.\n")
                    if(length(not_found_genes) > 0){
                        msg <- paste0(msg, "\nThe following ", length(not_found_genes), " gene(s) were not found in the gene expression data and thus not used: \n", paste(not_found_genes, collapse=', '), ".")
                    }
                    Signature_input_selection_status(msg)


                signature_table(signature_gsva_table)
                isCalculating(FALSE)
                return()
            })

    ##

    # Return reactive values needed by plot server
    list(
        signature_table        = signature_table,
        isCalculating          = isCalculating,
        All_sample_flag        = All_sample_flag,
        filtered_sample_ids_reactive = filtered_sample_ids_reactive
    )
}
