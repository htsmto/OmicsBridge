# =============================================================================
# Clinical - Mutation: Data Loading & Preparation
# File: modules/Clinical/05_clinical_Mutation_data.R
# Purpose: Handles gene input resolution, sample filtering, mutation frequency
#          calculation, and the frequency summary table. Returns reactive values
#          shared by the plot sub-modules.
# Edit this file when: changing MAF parsing logic, gene-list resolution, sample
#                      filtering behaviour, or the frequency calculation itself.
# =============================================================================

mutation_data_server <- function(input, output, session, ex_table, survival_table, meta_table, mutation_table, Custom_genesets) {

    ## Input genes setting ----
        Mutation_input_genes <- reactiveVal(NULL)
        # status
            Clinical_Mutation_genes_status <- reactiveVal(NULL)
            output$Clinical_Mutation_genes_status <- renderText({ Clinical_Mutation_genes_status() })
        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$Clinical_Mutation_genes <- renderUI({ textAreaInput(session$ns("Clinical_Mutation_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$Clinical_Mutation_genes_from_custom_geneset) > 0 && input$Clinical_Mutation_genes_from_custom_geneset == TRUE){
                    shinyjs::disable("Clinical_Mutation_genes")
                } else if (length(input$Clinical_Mutation_genes_from_the_cohort) > 0 && input$Clinical_Mutation_genes_from_the_cohort == TRUE){
                    shinyjs::disable("Clinical_Mutation_genes")
                } else {
                    shinyjs::enable("Clinical_Mutation_genes")
                }
            })

        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$Clinical_Mutation_genes_from_custom_geneset_select <- renderUI({
                if(length(input$Clinical_Mutation_genes_from_custom_geneset) > 0 && input$Clinical_Mutation_genes_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets()$Geneset.name)
                    selectInput(session$ns('Clinical_Mutation_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })

        #

        # use all the genes from the selected cohort
            # custom gene switch button and this button should be mutually exclusive.
                observeEvent(input$Clinical_Mutation_genes_from_the_cohort, {
                    if (input$Clinical_Mutation_genes_from_the_cohort) {
                        updateMaterialSwitch(session, "Clinical_Mutation_genes_from_custom_geneset", value = FALSE)
                        updateSelectInput(session, 'Clinical_Mutation_genes_from_custom_geneset_select', selected = "None")
                    }
                }, ignoreInit = TRUE)

                observeEvent(input$Clinical_Mutation_genes_from_custom_geneset, {
                    if (input$Clinical_Mutation_genes_from_custom_geneset) {
                        updateMaterialSwitch(session, "Clinical_Mutation_genes_from_the_cohort", value = FALSE)
                    }
                }, ignoreInit = TRUE)
            #
        #

        # set the Mutation_input_genes reactive value according to the manual input or the custom geneset selection
            # manually inputted genes
                observe({
                    if(length(input$Clinical_Mutation_genes) == 0 || length(input$Clinical_Mutation_genes_from_custom_geneset) == 0 || length(input$Clinical_Mutation_genes_from_the_cohort) == 0){
                        Mutation_input_genes(NULL)
                        Clinical_Mutation_genes_status(NULL)
                        return(NULL)
                    }else if(input$Clinical_Mutation_genes_from_custom_geneset == FALSE && input$Clinical_Mutation_genes_from_the_cohort == FALSE){
                        # custom select: off, all genes: off -> manual

                        if(all(grepl("^\\s*$", input$Clinical_Mutation_genes))){
                            Clinical_Mutation_genes_status('Please enter gene names in the box above, one gene per line.')
                            Mutation_input_genes(NULL)
                            return(NULL)
                        }

                        # when there are gene names inputted
                        genes_tmp <- unique(unlist(strsplit(input$Clinical_Mutation_genes, split="\n")))
                        genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                        Mutation_input_genes(genes_tmp)
                        Clinical_Mutation_genes_status(paste0("You have manually input ", length(Mutation_input_genes()), " gene(s)."))

                    }else if(input$Clinical_Mutation_genes_from_custom_geneset == TRUE && input$Clinical_Mutation_genes_from_the_cohort == FALSE){
                        # custom select: on -> custom geneset
                        if(length(input$Clinical_Mutation_genes_from_custom_geneset_select) == 0 || input$Clinical_Mutation_genes_from_custom_geneset_select == 'None'){
                            Clinical_Mutation_genes_status("Please select a custom geneset above first.")
                            Mutation_input_genes(NULL)
                            return(NULL)
                        }else{
                            genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% input$Clinical_Mutation_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                            Mutation_input_genes(genes)
                            Clinical_Mutation_genes_status(paste0("You have input ", length(Mutation_input_genes()), " gene(s) from your selected custom geneset."))
                        }
                    }else if(input$Clinical_Mutation_genes_from_custom_geneset == FALSE && input$Clinical_Mutation_genes_from_the_cohort == TRUE){
                        # all genes: on -> cohort genes
                        if(is.null(mutation_table())){
                            Clinical_Mutation_genes_status("No mutation data is loaded. Please check your data input.")
                            Mutation_input_genes(NULL)
                            return(NULL)
                        }
                        genes <- unique(mutation_table()$id)
                        Mutation_input_genes(genes)
                        Clinical_Mutation_genes_status(paste0("You have chosen to use all the genes from the cohort. \nThe number of the genes is ", length(unique(genes)), "."))
                    }


                })

            #

            # gene from the cohort
                observe({
                    if(length(input$Clinical_Mutation_genes_from_the_cohort) > 0 && input$Clinical_Mutation_genes_from_the_cohort == TRUE){
                        if(is.null(mutation_table())){
                            Clinical_Mutation_genes_status("No mutation data is loaded. Please check your data input.")
                            Mutation_input_genes(NULL)
                            return(NULL)
                        }
                        genes <- unique(mutation_table()$id)
                        Mutation_input_genes(genes)
                        Clinical_Mutation_genes_status(paste0("You have chosen to use all the genes from the cohort. \nThe number of the genes is ", length(unique(genes)), "."))
                    }else{
                        Mutation_input_genes(NULL)
                        return(NULL)
                    }

                })

            #

        #

    ##

    ## Sample filtering setting
            # status
                Clinical_Mutation_frequency_filter_selection_number <- reactiveVal(NULL)
                output$Clinical_Mutation_frequency_filter_selection_number <- renderText({ Clinical_Mutation_frequency_filter_selection_number() })
            #

            # variables
                All_sample_flag <- reactiveVal(TRUE) # default use all the samples for survival analysis
                filtered_sample_ids_reactive <- reactiveVal(NULL) # store the filtered sample ids when users choose to use a specific category of samples for survival analysis
            #

            # when users choose a category for filtering, show the category selection dropdown
                # group selection dropdown
                    output$Clinical_Mutation_frequency_filter_selection <- renderUI({
                        if(length(input$Clinical_Mutation_frequency_filter) == 0 || input$Clinical_Mutation_frequency_filter == 'A'){
                            return(NULL)
                        }else{
                            selectInput(session$ns("Clinical_Mutation_frequency_filter_selection"), "Filtering by:", c('None'='None', colnames(meta_table())))
                        }
                    })
                #

                # category selection dropdown
                    output$Clinical_Mutation_frequency_filter_selection_category <- renderUI({
                        if(length(input$Clinical_Mutation_frequency_filter) == 0 || input$Clinical_Mutation_frequency_filter == 'A'){
                            return(NULL)
                        }else{
                            if(length(input$Clinical_Mutation_frequency_filter_selection) == 0 || is.null(input$Clinical_Mutation_frequency_filter_selection) ||  input$Clinical_Mutation_frequency_filter_selection == 'None'){
                                selectInput(session$ns("Clinical_Mutation_frequency_filter_selection_category"), "Category:", c('None'='None'))
                            }else{
                                selectInput(session$ns("Clinical_Mutation_frequency_filter_selection_category"), "Category:", c('None'='None', unique(meta_table()[,input$Clinical_Mutation_frequency_filter_selection])))
                            }
                        }
                    })
                #

                # show the number of samples. When no filtering, show the number of all the samples
                    observe({
                        if(!is.null(meta_table())){
                            if(length(input$Clinical_Mutation_frequency_filter) > 0 && input$Clinical_Mutation_frequency_filter == 'A'){
                                Clinical_Mutation_frequency_filter_selection_number(paste0("The total number of samples is ", nrow(meta_table()), "."))

                            }else if(length(input$Clinical_Mutation_frequency_filter) > 0 && input$Clinical_Mutation_frequency_filter == 'B'){
                                if(length(input$Clinical_Mutation_frequency_filter_selection) > 0 && input$Clinical_Mutation_frequency_filter_selection != 'None' && length(input$Clinical_Mutation_frequency_filter_selection_category) > 0 && input$Clinical_Mutation_frequency_filter_selection_category != 'None'){
                                    num <- nrow(meta_table()[meta_table()[,input$Clinical_Mutation_frequency_filter_selection] %in% input$Clinical_Mutation_frequency_filter_selection_category, ])
                                    filtered_sample_ids_reactive(meta_table()[meta_table()[,input$Clinical_Mutation_frequency_filter_selection] %in% input$Clinical_Mutation_frequency_filter_selection_category, ]$sample)
                                    Clinical_Mutation_frequency_filter_selection_number(paste0("You have chosen to use the samples in category ", input$Clinical_Mutation_frequency_filter_selection_category, " of ", input$Clinical_Mutation_frequency_filter_selection, " for the correlation analysis. \nThe number of the selected samples is ", num, "."))
                                }else{
                                    filtered_sample_ids_reactive(NULL)
                                    Clinical_Mutation_frequency_filter_selection_number("Please select a category for filtering.")
                                }
                            }else{
                                Clinical_Mutation_frequency_filter_selection_number(NULL)
                            }
                        }else{
                            Clinical_Mutation_frequency_filter_selection_number(NULL)
                        }
                    })
                #
            #

    ##

    ## mutation frequency calculation
        # status
            Clinical_Mutation_frequency_plot_status <- reactiveVal(NULL)
            output$Clinical_Mutation_frequency_plot_status <- renderText({ Clinical_Mutation_frequency_plot_status() })
        #

        # start
        # Create the table when clicking the start button
            isCalculating <- reactiveVal(FALSE)
            mut_freq_table <- reactiveVal(NULL)
            filtered_sample_ids <- reactiveVal(NULL)
            observeEvent(input$Clinical_Mutation_plot_start,{
                isCalculating(TRUE)
                df_mut <- mutation_table()


                # check if the mutation data is loaded
                    if(is.null(df_mut)){
                        Clinical_Mutation_frequency_plot_status("No mutation data is loaded. Please select a dataset or check your data input.")
                        show_alert(title = "Error", text = "No mutation data is loaded. Please select a dataset or check your data input.", type = "error")
                        isCalculating(FALSE)
                        mut_freq_table(NULL)
                        return(NULL)
                    }
                #

                # check your input gene
                    if(length(Mutation_input_genes()) == 0 || is.null(Mutation_input_genes())){
                        Clinical_Mutation_frequency_plot_status("No gene is selected for mutation frequency calculation. Please set the input genes.")
                        show_alert(title = "Error", text = "No gene is selected for mutation frequency calculation. Please set the input genes.", type = "error")
                        isCalculating(FALSE)
                        mut_freq_table(NULL)
                        return(NULL)
                    }
                #

                # check if there are mutation data for the input genes
                    found_input_gene <- Mutation_input_genes()[Mutation_input_genes() %in% df_mut$id]
                    not_found_input_gene <- Mutation_input_genes()[!Mutation_input_genes() %in% df_mut$id]
                    if(length(found_input_gene) == 0){
                        Clinical_Mutation_frequency_plot_status("No mutation data is found for your input genes. This is because your input gene name is wrong or no mutation was reported in the samples for all the selected genes.")
                        show_alert(title = "Error", text = "No mutation data is found for your input genes. Please check your input genes or data.", type = "error")
                        isCalculating(FALSE)
                        mut_freq_table(NULL)
                        return(NULL)
                    }
                #

                # filter the mutation data according to the sample filtering setting
                    if(length(input$Clinical_Mutation_frequency_filter) > 0 && input$Clinical_Mutation_frequency_filter == 'A'){
                        All_sample_flag(TRUE)
                        df_mut <- df_mut
                    }else{
                        All_sample_flag(FALSE)

                        # if no category is selected for filtering, show an error message
                        if((input$Clinical_Mutation_frequency_filter_selection_category) == 0 || input$Clinical_Mutation_frequency_filter_selection_category == 'None'){
                            Clinical_Mutation_frequency_plot_status("Please select a category for filtering the samples.")
                            show_alert(title = "Error", text = "Please select a category for filtering the samples.", type = "error")
                            isCalculating(FALSE)
                            mut_freq_table(NULL)
                            return(NULL)
                        }

                        filtered_sample_ids(filtered_sample_ids_reactive())
                        df_mut <- df_mut[df_mut$sample %in% filtered_sample_ids_reactive(), ]
                    }
                #

                # count the frquency
                df_mut_num <- data.frame(genes=found_input_gene, 'Number_of_patients'=0)
                for ( gene in found_input_gene){
                    df_mut_num[df_mut_num$genes == gene, ]$Number_of_patients <- length(unique(df_mut[df_mut$id == gene, ]$sample))
                }
                df_mut_num$Frequence <- round(df_mut_num$Number_of_patients/length(unique(df_mut$sample)) * 100, 2)
                df_mut_num <- df_mut_num[order(df_mut_num$Number_of_patients, decreasing = T),]
                df_mut_num$genes <- factor(df_mut_num$genes, levels=df_mut_num$genes)
                rownames(df_mut_num) <- NULL
                mut_freq_table(df_mut_num)

                # show the final status
                # show the user: number of genes that were assessed, total number of samples used for the calculation
                # if there are input genes that are not found in the mutation data, show the number of genes that are not found and their names.
                message <- paste0("You have calculated the mutation frequency for ", length(found_input_gene), " gene(s) in ", length(unique(df_mut$sample)), " sample(s).")
                if(length(not_found_input_gene) > 0){
                    message <- paste0(message, "\nThere are ", length(not_found_input_gene), " gene(s) that are not found in the mutation data: ", paste(not_found_input_gene, collapse = ", "), ". \nThis could be because the gene names you inputted are wrong or no mutation was reported in the samples for these genes.")
                }
                Clinical_Mutation_frequency_plot_status(message)


                isCalculating(FALSE)
                return(NULL)
            })
        #
    ##

    ## show the table
        # status
            Clinical_Mutation_frequency_plot_status_table <- reactiveVal("Please calculate the mutation frequency first.")
            output$Clinical_Mutation_frequency_plot_status_table <- renderText({ Clinical_Mutation_frequency_plot_status_table() })
        #

        # show a table
          output$Clinical_Mutation_frequency_table <- DT::renderDataTable({
            if(isCalculating()){
                return(NULL)
            }

            if(is.null(mut_freq_table())){
                Clinical_Mutation_frequency_plot_status_table("Please calculate the mutation frequency first.")
                tmp <- data.frame('genes'=character(0), 'Number_of_patients'=numeric(0), 'Frequence'=numeric(0))
                datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }else{
                Clinical_Mutation_frequency_plot_status_table(NULL)
                datatable(mut_freq_table(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }

          })
        #

    ##

    # Return shared reactive values for use by plot sub-modules
    list(
        mut_freq_table         = mut_freq_table,
        isCalculating          = isCalculating,
        All_sample_flag        = All_sample_flag,
        filtered_sample_ids    = filtered_sample_ids
    )
}
