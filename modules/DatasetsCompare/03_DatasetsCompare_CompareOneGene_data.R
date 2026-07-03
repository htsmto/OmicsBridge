# =============================================================================
# DatasetsCompare - Single Gene Comparison: Data & Input
# File: modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_data.R
# Purpose: Handles dataset selection, gene input (manual and custom geneset),
#          and data loading for cross-dataset gene comparison.
# Edit this file when: changing dataset selection logic, gene input handling,
#                       or data loading / column selection.
# =============================================================================

compare_one_gene_data_server <- function(input, output, session, selected_datasets_table, Custom_genesets) {
    ## settings and Inputs
        # status
            Compare_dataset_comparing_one_gene_status_input <- reactiveVal("Please enter genes and select the scores for Y axis and colour for comparison, and then click the 'Start Analysis' button.")
            output$Compare_dataset_comparing_one_gene_status_input <- renderText({ Compare_dataset_comparing_one_gene_status_input() })

        #

        # chosse the score for comparison (Y axis)
            output$Choose_datasets_y <- renderUI({
                # if nothing is selected
                if(is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    selectInput(session$ns('Choose_datasets_y'), 'Y axis', c('--Please select datasets--'= 'None'))
                } else {
                    # if there are datasets selected.
                    # this assume that the datasets with the same data type have the same column names
                    # read the first dataset to get the column names for selection
                    selected_datasets_table <- selected_datasets_table()
                    data_ex_tmp <- read.table(selected_datasets_table$Path[1], sep='\t', header=T,check.names = FALSE)
                    y_names <- unique(colnames(data_ex_tmp))
                    rm(data_ex_tmp)
                    selectInput(session$ns('Choose_datasets_y'), 'Y axis', c('None'= 'None', y_names))
                }
            })
        #

        # chosse the score for comparison (colour)
            output$Choose_datasets_colour <- renderUI({
                # if nothing is selected
                if(is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    selectInput(session$ns('Choose_datasets_colour'), 'Colour', c('--Please select datasets--'= 'None'))
                } else {
                    # if there are datasets selected.
                    # this assume that the datasets with the same data type have the same column names
                    # read the first dataset to get the column names for selection
                    selected_datasets_table <- selected_datasets_table()
                    data_ex_tmp <- read.table(selected_datasets_table$Path[1], sep='\t', header=T,check.names = FALSE)
                    colour_names <- unique(colnames(data_ex_tmp))
                    rm(data_ex_tmp)
                    selectInput(session$ns('Choose_datasets_colour'), 'Colour', c('None'= 'None', colour_names))
                }
            })
        #

    ## gene inputs

        # gene list input status
            gene_list_mannual <- reactiveVal(NULL)
            gene_list_custom <- reactiveVal(NULL)
            Gene_comparing_selected_gene_status <- reactiveVal(NULL)
            output$Gene_comparing_selected_gene_status <- renderText({ Gene_comparing_selected_gene_status() })

        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$target_gene_for_comparing <- renderUI({ textAreaInput(session$ns("target_gene_for_comparing"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$target_gene_for_comparing_Input_from_custom_geneset) > 0 && input$target_gene_for_comparing_Input_from_custom_geneset == TRUE){
                    shinyjs::disable("target_gene_for_comparing")
                } else {
                    shinyjs::enable("target_gene_for_comparing")
                }
            })

        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$target_gene_for_comparing_Input_from_custom_geneset_select <- renderUI({
                if(length(input$target_gene_for_comparing_Input_from_custom_geneset) > 0 && input$target_gene_for_comparing_Input_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets()$Geneset.name)
                    selectInput(session$ns('target_gene_for_comparing_Input_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })

        #

        # show the list of the genes in a table  (scRNA_FeaturePlot_gene_table)
            Input_is_ready <- reactiveVal(0) # 0: no gene input; 1: manual gene input; 2: custom geneset gene input
            # manually inputted genes
                observe({
                    if(length(input$target_gene_for_comparing) > 0){
                        # This work only when the user choose to input gene manually
                        if(length(input$target_gene_for_comparing_Input_from_custom_geneset) == 0 || input$target_gene_for_comparing_Input_from_custom_geneset == FALSE){
                            # when nothing is inputted or the genes names are just spaces (' ')
                            if(all(grepl("^\\s*$", input$target_gene_for_comparing))){
                                Input_is_ready(0)
                                # Gene_comparing_selected_gene_status('Please enter gene names in the box above, one gene per line.')
                                gene_list_mannual(NULL)
                                return(NULL)
                            }

                            # when there are gene names inputted
                            genes_tmp <- unique(unlist(strsplit(input$target_gene_for_comparing, split="\n")))
                            genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                            gene_list_mannual(genes_tmp)
                            Input_is_ready(1)
                            # Gene_comparing_selected_gene_status(paste0("You have manually input ", length(gene_list_mannual()), " gene(s)."))
                        }
                    }
                })
            #

            # genes from custom geneset
                observe({
                    if(length(input$target_gene_for_comparing_Input_from_custom_geneset) > 0 && input$target_gene_for_comparing_Input_from_custom_geneset == TRUE){
                        if(length(input$target_gene_for_comparing_Input_from_custom_geneset_select) == 0 || input$target_gene_for_comparing_Input_from_custom_geneset_select == 'None'){
                            # Gene_comparing_selected_gene_status("Please select a custom geneset above first.")
                            gene_list_custom(NULL)
                            Input_is_ready(0)
                            return(NULL)
                        }else{
                            genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% input$target_gene_for_comparing_Input_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                            gene_list_custom(genes)
                            # Gene_comparing_selected_gene_status(paste0("You have input ", length(gene_list_custom()), " gene(s) from your selected custom geneset."))
                            Input_is_ready(2)
                            return(NULL)
                        }
                    }
                })
            #


        #

    ##

    ## start analysis
        # variables
            used_genes <- reactiveVal(NULL)
            all_comapring_tables <- reactiveVal(NULL) # list of the tables for each gene containing the scores (and colour if selected) for all the datasets.
        #

        # once started
            Y_axis_name <- reactiveVal(NULL)
            colour_name <- reactiveVal(NULL)
            observeEvent(input$comparison_start, {
                # if not dataset is selected, show alert
                if(length(selected_datasets_table()) == 0 || is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    Compare_dataset_comparing_one_gene_status_input("Please select at least one dataset for comparison first.")
                    Gene_comparing_selected_gene_status("Please select at least one dataset for comparison first.")
                    show_alert(title = "No dataset selected", text = "Please select at least one dataset for comparison first.", type = "error")
                    return(NULL)
                }

                # if only one dataset is selected, show alert
                if(nrow(selected_datasets_table()) == 1){
                    Compare_dataset_comparing_one_gene_status_input("Please select at least two datasets for comparison.")
                    Gene_comparing_selected_gene_status("Please select at least two datasets for comparison.")
                    show_alert(title = "Only one dataset selected", text = "Please select at least two datasets for comparison.", type = "error")
                    return(NULL)
                }

                # check if the input is ready
                if(Input_is_ready() == 0){
                    Compare_dataset_comparing_one_gene_status_input("Please input genes for comparison first.")
                    Gene_comparing_selected_gene_status("Please input genes for comparison first.")
                    show_alert(title = "Input is not ready", text = "Please input genes for comparison first.", type = "error")
                    return(NULL)
                }


                # if Y axis is not selected, show alert
                if(length(input$Choose_datasets_y) == 0 || is.null(input$Choose_datasets_y) || input$Choose_datasets_y == 'None'){
                    Compare_dataset_comparing_one_gene_status_input("Please select a score for Y axis for comparison.")
                    Gene_comparing_selected_gene_status("Please select a score for Y axis for comparison.")
                    show_alert(title = "Y axis is not selected", text = "Please select a score for Y axis for comparison.", type = "error")
                    return(NULL)
                }

                # get the gene list for comparison
                if(Input_is_ready() == 1){
                    used_genes(gene_list_mannual())
                    Compare_dataset_comparing_one_gene_status_input(paste0("You have manually input ", length(gene_list_mannual()), " gene(s)."))
                    Gene_comparing_selected_gene_status(paste0("You have manually input ", length(gene_list_mannual()), " gene(s)."))
                } else if(Input_is_ready() == 2){
                    used_genes(gene_list_custom())
                    Compare_dataset_comparing_one_gene_status_input(paste0("You have input ", length(gene_list_custom()), " gene(s) from your selected custom geneset."))
                    Gene_comparing_selected_gene_status(paste0("You have input ", length(gene_list_custom()), " gene(s) from your selected custom geneset."))
                }


                # load the data. select the columns of y_axis and colour, store all the datafram as a list
                comparing_tables_list <- list()
                datapahs_not_exist <- c() # store the datasets with missing data file
                Yaxis_not_in_datasets <- c() # store the datasets that do not have the selected Y axis for comparison
                Colour_not_in_datasets <- c() # store the datasets that do not have the selected Colour for comparison
                selected_datasets_table <- selected_datasets_table()
                used_genes <- used_genes()
                for(i in 1:nrow(selected_datasets_table)){
                    # if the dataset does not exist, skip it and show a message later
                    if(!file.exists(selected_datasets_table$Path[i])){
                        datapahs_not_exist <- c(datapahs_not_exist, selected_datasets_table$Dataset[i])
                        next
                    }
                    data_tmp <- read.table(selected_datasets_table$Path[i], sep='\t', header=T, check.names = FALSE)
                    data_tmp <- replace_infinite_values_df(data_tmp)

                    # if the selected y axis or colour is not in the dataset, show a message later and skip this dataset
                    if(!(input$Choose_datasets_y %in% colnames(data_tmp))){
                        Yaxis_not_in_datasets <- c(Yaxis_not_in_datasets, selected_datasets_table$Dataset[i])
                        next
                    }
                    if(length(input$Choose_datasets_colour) > 0 && input$Choose_datasets_colour != 'None' && !(input$Choose_datasets_colour %in% colnames(data_tmp))){
                        Colour_not_in_datasets <- c(Colour_not_in_datasets, selected_datasets_table$Dataset[i])
                        next
                    }

                    # if there is no problem with the dataset, select the columns,
                    # if the colour is not set, just use NA
                    if(length(input$Choose_datasets_colour) > 0 && input$Choose_datasets_colour != 'None'){
                        data_tmp_sub <- data_tmp[, c('id', input$Choose_datasets_y, input$Choose_datasets_colour)]
                        colnames(data_tmp_sub) <- c('id', 'Y_axis', 'Colour')
                        Y_axis_name(input$Choose_datasets_y)
                        colour_name(input$Choose_datasets_colour)
                    } else {
                        data_tmp_sub <- data_tmp[, c('id', input$Choose_datasets_y)]
                        data_tmp_sub$Colour <- NA
                        colnames(data_tmp_sub) <- c('id', 'Y_axis', 'Colour')
                        Y_axis_name(input$Choose_datasets_y)
                        colour_name(NULL)
                    }

                    # and focus on the used genes. if the genes are not found, just fill with NA
                    data_tmp_sub <- data_tmp_sub[data_tmp_sub$id %in% used_genes, ]
                    if(nrow(data_tmp_sub) == 0){
                        data_tmp_sub <- data.frame(id = used_genes, Y_axis = NA, Colour = NA)
                    } else {
                        missing_genes <- used_genes[!used_genes %in% data_tmp_sub$id]
                        if(length(missing_genes) > 0){
                            data_tmp_sub <- rbind(data_tmp_sub, data.frame(id = missing_genes, Y_axis = NA, Colour = NA))
                        }
                    }

                    # store the table in the list
                    comparing_tables_list[[selected_datasets_table$Dataset[i]]] <- data_tmp_sub
                }

                # return the list of tables for all the datasets
                all_comapring_tables(comparing_tables_list)


            })

        #

        # show the input genes
            output$Gene_comparing_gene_list_table <- renderDataTable({
                if(is.null(used_genes()) || length(used_genes()) == 0){
                    return(NULL)
                } else {
                    datatable( data.frame(Gene = used_genes()), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)
                }
            })

        #

    ##

    return(list(
        used_genes = used_genes,
        all_comapring_tables = all_comapring_tables,
        Y_axis_name = Y_axis_name,
        colour_name = colour_name
    ))
}
