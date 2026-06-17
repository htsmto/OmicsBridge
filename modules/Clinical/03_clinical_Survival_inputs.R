# =============================================================================
# Clinical - Survival Analysis: Inputs and Settings
# File: modules/Clinical/03_clinical_Survival_inputs.R
# Purpose: Reactive gene input (manual + custom geneset), sample split
#          strategy selection, sample filtering, and event type selection.
#          Returns reactive values consumed by the calculation sub-module.
# Edit this file when: changing input controls, gene validation logic, or
#                      sample split/filter options.
# =============================================================================

survival_inputs_server <- function(input, output, session, ex_table, surv_table, meta_table, Custom_genesets) {
    ## Inputs and Settings ----
        ## status
            Clinical_Survival_genes_status <- reactiveVal(NULL)
            Clinical_Survival_input_status <- reactiveVal('Please enter the input and choose the setting, and click \'Start the survival analysis\'.')
            output$Clinical_Survival_genes_status <- renderText({ Clinical_Survival_genes_status() })
            output$Clinical_Survival_input_status <- renderText({ Clinical_Survival_input_status() })

        #

        ## Input genes setting
            survival_input_genes <- reactiveVal(NULL)
            # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
                output$Clinical_Survival_genes <- renderUI({ textAreaInput(session$ns("Clinical_Survival_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
                observe({
                    if(length(input$Clinical_Survival_genes_from_custom_geneset) > 0 && input$Clinical_Survival_genes_from_custom_geneset == TRUE){
                        shinyjs::disable("Clinical_Survival_genes")
                    } else {
                        shinyjs::enable("Clinical_Survival_genes")
                    }
                })

            #

            # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
                output$Clinical_Survival_genes_from_custom_geneset_select <- renderUI({
                    if(length(input$Clinical_Survival_genes_from_custom_geneset) > 0 && input$Clinical_Survival_genes_from_custom_geneset == TRUE){
                        gene_sets_names <- c(Custom_genesets$Geneset.name)
                        selectInput(session$ns('Clinical_Survival_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                    } else {
                        return(NULL)
                    }
                })

            #

            # set the survival_input_genes reactive value according to the manual input or the custom geneset selection
                # manually inputted genes
                    observe({
                        if(length(input$Clinical_Survival_genes) > 0){
                            # This work only when the user choose to input gene manually
                            if(length(input$Clinical_Survival_genes_from_custom_geneset) == 0 || input$Clinical_Survival_genes_from_custom_geneset == FALSE){
                                # when nothing is inputted or the genes names are just spaces (' ')
                                if(all(grepl("^\\s*$", input$Clinical_Survival_genes))){
                                    Clinical_Survival_genes_status('Please enter gene names in the box above, one gene per line.')
                                    survival_input_genes(NULL)
                                    return(NULL)
                                }

                                # when there are gene names inputted
                                genes_tmp <- unique(unlist(strsplit(input$Clinical_Survival_genes, split="\n")))
                                genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                                survival_input_genes(genes_tmp)
                                Clinical_Survival_genes_status(paste0("You have manually input ", length(survival_input_genes()), " gene(s)."))
                            }
                        }
                    })

                #

                # genes from custom geneset
                    observe({
                        if(length(input$Clinical_Survival_genes_from_custom_geneset) > 0 && input$Clinical_Survival_genes_from_custom_geneset == TRUE){
                            if(length(input$Clinical_Survival_genes_from_custom_geneset_select) == 0 || input$Clinical_Survival_genes_from_custom_geneset_select == 'None'){
                                Clinical_Survival_genes_status("Please select a custom geneset above first.")
                                survival_input_genes(NULL)
                                return(NULL)
                            }else{
                                genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$Clinical_Survival_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                                survival_input_genes(genes)
                                Clinical_Survival_genes_status(paste0("You have input ", length(survival_input_genes()), " gene(s) from your selected custom geneset."))
                            }
                        }
                    })

                #

            #

        ##

        ## Sample Split setting
            top_X_percent <- reactiveVal(NULL)
            bottom_X_percent <- reactiveVal(NULL)
            top_sample_name <- reactiveVal(NULL)
            bottom_sample_name <- reactiveVal(NULL)
            observe({
                if(length(input$Clinical_Survival_Split_way) != 0 ){
                    if(input$Clinical_Survival_Split_way == 'C'){
                        top_X_percent(NULL)
                        bottom_X_percent(NULL)
                        top_sample_name(paste(input$Clinical_Survival_Split_Group1, collapse = '\n'))
                        bottom_sample_name(paste(input$Clinical_Survival_Split_Group2, collapse = '\n'))
                    }else if(input$Clinical_Survival_Split_way == 'A'){
                        top_sample_name(NULL)
                        bottom_sample_name(NULL)
                        top_X_percent(50)
                        bottom_X_percent(50)
                    }else if(input$Clinical_Survival_Split_way == 'B'){
                        top_sample_name(NULL)
                        bottom_sample_name(NULL)
                        top_X_percent(25)
                        bottom_X_percent(25)
                    }else if(input$Clinical_Survival_Split_way == 'D'){
                        top_sample_name(NULL)
                        bottom_sample_name(NULL)
                        # check if the input is valid for custom grouping
                        # the input should be 1-99
                        if(nchar(input$Clinical_Survival_Split_Group1_perc) == 0 || nchar(input$Clinical_Survival_Split_Group2_perc) == 0){
                            top_X_percent(NULL)
                            bottom_X_percent(NULL)
                        }else{
                            if(!grepl("^[1-9]$|^[1-9][0-9]$|^100$", input$Clinical_Survival_Split_Group1_perc) || !grepl("^[1-9]$|^[1-9][0-9]$|^100$", input$Clinical_Survival_Split_Group2_perc)){
                                top_X_percent(NULL)
                                bottom_X_percent(NULL)
                            }else{
                                top_X_percent(as.numeric(input$Clinical_Survival_Split_Group1_perc))
                                bottom_X_percent(as.numeric(input$Clinical_Survival_Split_Group2_perc))
                            }
                        }
                    }
                }

            })

        ##

        ## Sample filtering setting
            # status
                Clinical_Survival_frequency_filter_selection_number <- reactiveVal(NULL)
                output$Clinical_Survival_frequency_filter_selection_number <- renderText({ Clinical_Survival_frequency_filter_selection_number() })
            #

            # variables
                All_sample_flag <- reactiveVal(TRUE) # default use all the samples for survival analysis
                filtered_sample_ids <- reactiveVal(NULL) # store the filtered sample ids when users choose to use a specific category of samples for survival analysis
            #

            # when users choose a category for filtering, show the category selection dropdown
                # group selection dropdown
                    output$Clinical_Survival_frequency_filter_selection <- renderUI({
                        if(!is.null(meta_table())){
                            if(length(input$Clinical_Survival_frequency_filter) > 0 && input$Clinical_Survival_frequency_filter == 'B'){
                                selectInput(session$ns("Clinical_Survival_frequency_filter_selection"), "Filtering by:", c('None'='None', colnames(meta_table())))
                            }else{
                                selectInput(session$ns("Clinical_Survival_frequency_filter_selection"), "Filtering by:", c('None'='None'))
                            }
                        }else{
                            selectInput(session$ns("Clinical_Survival_frequency_filter_selection"), "Filtering by:", c('None'='None'))
                        }
                    })
                #

                # category selection dropdown
                    output$Clinical_Survival_frequency_filter_selection_category <- renderUI({
                        if(length(input$Clinical_Survival_frequency_filter_selection)==0 || is.null(input$Clinical_Survival_frequency_filter_selection) ||  input$Clinical_Survival_frequency_filter_selection == 'None'){
                            selectInput(session$ns("Clinical_Survival_frequency_filter_selection_category"), "Category:", c('None'='None'))
                        }else{
                            selectInput(session$ns("Clinical_Survival_frequency_filter_selection_category"), "Category:", c('None'='None', unique(meta_table()[,input$Clinical_Survival_frequency_filter_selection])))
                        }
                    })
                #

                # show the number of samples. When no filtering, show the number of all the samples
                    observe({
                        if(!is.null(meta_table())){
                            if(length(input$Clinical_Survival_frequency_filter) > 0 && input$Clinical_Survival_frequency_filter == 'A'){
                                All_sample_flag(TRUE)
                                Clinical_Survival_frequency_filter_selection_number(paste0("The total number of samples is ", nrow(meta_table()), "."))
                            }else if(length(input$Clinical_Survival_frequency_filter) > 0 && input$Clinical_Survival_frequency_filter == 'B'){
                                All_sample_flag(FALSE)
                                if(length(input$Clinical_Survival_frequency_filter_selection) > 0 && input$Clinical_Survival_frequency_filter_selection != 'None' && length(input$Clinical_Survival_frequency_filter_selection_category) > 0 && input$Clinical_Survival_frequency_filter_selection_category != 'None'){
                                    num <- nrow(meta_table()[meta_table()[,input$Clinical_Survival_frequency_filter_selection] %in% input$Clinical_Survival_frequency_filter_selection_category, ])
                                    filtered_sample_ids(meta_table()[meta_table()[,input$Clinical_Survival_frequency_filter_selection] %in% input$Clinical_Survival_frequency_filter_selection_category, ]$sample)
                                    Clinical_Survival_frequency_filter_selection_number(paste0("You have chosen to use the samples in category ", input$Clinical_Survival_frequency_filter_selection_category, " of ", input$Clinical_Survival_frequency_filter_selection, " for the survival analysis. \nThe number of the selected samples is ", num, "."))
                                }else{
                                    filtered_sample_ids(NULL)
                                    Clinical_Survival_frequency_filter_selection_number("Please select a category for filtering.")
                                }
                            }else{
                                Clinical_Survival_frequency_filter_selection_number(NULL)
                            }
                        }else{
                            Clinical_Survival_frequency_filter_selection_number(NULL)
                        }
                    })
                #
            #
        ##

        ## Event selection
            # choose which event to evaluate (OS, PFS, etc)
                output$Clinical_Survival_choose_score_type <- renderUI({
                    if(!is.null(surv_table())){
                        suv_colnames <- colnames(surv_table())
                        col_tmp <- suv_colnames[grepl("\\.time", suv_colnames, ignore.case = TRUE)]
                        col_first_parts <- sapply(strsplit(col_tmp, "\\."), `[`, 1)
                    }else{
                        col_first_parts <- NULL
                    }
                    selectInput(session$ns('Clinical_Survival_choose_score_type'), 'Select the event type',  c('None'='None', col_first_parts))
                })
            #

        ##
    ##

    return(list(
        survival_input_genes = survival_input_genes,
        top_X_percent = top_X_percent,
        bottom_X_percent = bottom_X_percent,
        top_sample_name = top_sample_name,
        bottom_sample_name = bottom_sample_name,
        All_sample_flag = All_sample_flag,
        filtered_sample_ids = filtered_sample_ids,
        Clinical_Survival_input_status = Clinical_Survival_input_status
    ))
}
