# =============================================================================
# DatasetsCompare - Gene Overlap: Calculation
# File: modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_calc.R
# Purpose: Handles dataset selection UI, overlap computation (top/bottom X%
#          thresholding across datasets), and produces overlapped_genes_table.
# Edit this file when: changing how genes are matched across datasets, the
#                       threshold logic, or the score column selection UI.
# =============================================================================

get_overlap_calc_server <- function(input, output, session, selected_datasets_table) {
    ## status / initial settings
        # status
            Compare_dataset_get_overview_status_input <- reactiveVal(NULL)
            output$Compare_dataset_get_overview_status_input <- renderText({ Compare_dataset_get_overview_status_input() })
        #

    ## Input
        # status
            observe({
                if(is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    Compare_dataset_get_overview_status_input('Please select datasets to compare in the previous step.')
                } else {
                    Compare_dataset_get_overview_status_input(paste0('You have selected ', nrow(selected_datasets_table()), ' datasets for comparison.'))
                }
            })

        #

        # chosse the score for comparison
            output$Compare_dataset_get_overview_select_score <- renderUI({
                # if nothing is selected
                if(is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    selectInput(session$ns('Compare_dataset_get_overview_select_score'), 'Select a score for ranking', c('--Please select datasets--'= 'None'))
                } else {
                    # if there are datasets selected.
                    # this assume that the datasets with the same data type have the same column names
                    # read the first dataset to get the column names for selection
                    selected_datasets_table <- selected_datasets_table()
                    data_ex_tmp <- read.table(selected_datasets_table$Path[1], sep='\t', header=T,check.names = FALSE)
                    y_names <- unique(colnames(data_ex_tmp))
                    rm(data_ex_tmp)
                    selectInput(session$ns('Compare_dataset_get_overview_select_score'), 'Select a score for ranking', c('None'= 'None', y_names))
                }
            })

        #


    ## Start investingating the overlap
        # status
            Compare_dataset_get_overview_status <- reactiveVal(NULL)
            output$Compare_dataset_get_overview_status <- renderText({ Compare_dataset_get_overview_status() })

        # start
            overlapped_genes_table <- reactiveVal(NULL)
            isCalculating_ovelap_hit <- reactiveVal(FALSE)
            observeEvent(input$Compare_dataset_get_overview_start, {
                isCalculating_ovelap_hit(TRUE)

                # when noting is selected
                if(is.null(selected_datasets_table()) || nrow(selected_datasets_table()) == 0){
                    show_alert(title = "Error", text = "Please select datasets to compare first.", type = "error")
                    Compare_dataset_get_overview_status('Please select datasets to compare first.')
                    isCalculating_ovelap_hit(FALSE)
                    return()
                }

                # when only one dataset is selected
                if(nrow(selected_datasets_table()) == 1){
                    show_alert(title = "Error", text = "Please select at least two datasets to compare.", type = "error")
                    Compare_dataset_get_overview_status('Please select at least two datasets to compare.')
                    isCalculating_ovelap_hit(FALSE)
                    return()
                }

                # when a score is not set
                if(length(input$Compare_dataset_get_overview_select_score) == 0 || input$Compare_dataset_get_overview_select_score == 'None'){
                    show_alert(title = "Error", text = "Please select a score for ranking.", type = "error")
                    Compare_dataset_get_overview_status('Please select a score for ranking.')
                    isCalculating_ovelap_hit(FALSE)
                    return()
                }

                # data loading. load each dataset, get the score column selected by users, make a dataframe with gene and the selected score.
                # the merged dataframe has gene name as rownames and the selected score in each dataset as columns.
                    Compare_dataset_get_overview_status('Loading data...')
                    selected_datasets_table <- selected_datasets_table()
                    score_column <- input$Compare_dataset_get_overview_select_score
                    data_for_comparing <- data.frame()
                    selected_column_not_found_dataset <- c()
                    for(i in 1:nrow(selected_datasets_table)){
                        # if the dataset file does not exist, skip this dataset and show warning later
                        if(!file.exists(selected_datasets_table$Path[i])){
                            selected_column_not_found_dataset <- c(selected_column_not_found_dataset, selected_datasets_table$Dataset[i])
                            next()
                        }
                        data_tmp <- read.table(selected_datasets_table$Path[i], sep='\t', header=T, check.names = FALSE)
                        data_tmp <- replace_infinite_values_df(data_tmp)

                        # if the selected score column does not exist in the dataset, skip this dataset and show warning later
                        if(!(score_column %in% colnames(data_tmp))){
                            selected_column_not_found_dataset <- c(selected_column_not_found_dataset, selected_datasets_table$Dataset[i])
                            next()
                        }

                        data_tmp <- data_tmp[, c('id', score_column)]
                        colnames(data_tmp) <- c('id', selected_datasets_table$Dataset[i])
                        if(nrow(data_for_comparing) == 0){
                            data_for_comparing <- data_tmp
                        } else {
                            data_for_comparing <- merge(data_for_comparing, data_tmp, by='id', all=TRUE)
                        }
                    }

                    # show the error message if any dataset is skipped
                    if(length(selected_column_not_found_dataset) > 0){
                        error_dataset_message <- paste0("The following datasets are skipped because the selected score column is not found or the dataset file is not found: ", paste(selected_column_not_found_dataset, collapse=', '))
                    }else{
                        error_dataset_message <- NULL
                    }

                    # if after loading data, there is no dataset left for comparison, show error and return
                    if(ncol(data_for_comparing) <= 1){
                        show_alert(title = "Error", text = paste0("No dataset is available for comparison. ", error_dataset_message), type = "error")
                        Compare_dataset_get_overview_status('No dataset is available for comparison. The selected score column is not found or the dataset files are not found. \nPlease check your dataset files and the selected score column.')
                        isCalculating_ovelap_hit(FALSE)
                        return()
                    }

                    # Check if the gene is in the top/bottom X% in each dataset, and count how many times each gene is in the top/bottom X% across the datasets.
                    threshold_percent <- input$Compare_dataset_get_overview_threshold
                    direction <- input$Compare_dataset_get_overview_direction
                    for(i in 2:ncol(data_for_comparing)){
                        score_vector <- data_for_comparing[, i]
                        names(score_vector) <- data_for_comparing$id
                        if(direction == 'Top X%'){
                            threshold_value <- quantile(score_vector, probs = 1 - threshold_percent/100, na.rm = TRUE)
                            # if the score is higher than the threshold value, keep the score. if not, change it to NA.
                            data_for_comparing[, i] <- ifelse(data_for_comparing[, i] >= threshold_value, data_for_comparing[, i], NA)
                        } else {
                            threshold_value <- quantile(score_vector, probs = threshold_percent/100, na.rm = TRUE)
                            # if the score is lower than the threshold value, keep the score. if not, change it to NA.
                            data_for_comparing[, i] <- ifelse(data_for_comparing[, i] <= threshold_value, data_for_comparing[, i], NA)
                        }
                    }

                    # for each gene, count how many times it is in the top/bottom X% across the datasets.
                    data_for_comparing$Overlap_times <- apply(data_for_comparing[, -1], 1, function(x) sum(!is.na(x)))
                    data_for_comparing <- data_for_comparing[order(data_for_comparing$Overlap_times, decreasing = TRUE), ]

                    # order the columns: gene id, overlap times, score in each dataset,
                    data_for_comparing <- data_for_comparing[, c('id', 'Overlap_times', colnames(data_for_comparing)[2:(ncol(data_for_comparing)-1)])]

                    # show only the genes with overlap times more than the threshold set for display
                    if(input$Compare_dataset_get_overview_threshold_for_display > 0){
                        data_for_comparing <- data_for_comparing[data_for_comparing$Overlap_times >= input$Compare_dataset_get_overview_threshold_for_display, ]
                    }
                    rownames(data_for_comparing) <- NULL
                    overlapped_genes_table(data_for_comparing)

                    # show the conditions
                    threshold_message <- if(direction == 'Top X%'){
                        paste0("ranked in the top ", threshold_percent, "%")
                    } else {
                        paste0("ranked in the bottom ", threshold_percent, "%")
                    }
                    cond_message <- paste0("You are showing the genes that are: \n", threshold_message, " \nwith the score of ", score_column, " \nin at least ", input$Compare_dataset_get_overview_threshold_for_display, " datasets. \n")

                    # show all the status
                    if(!is.null(error_dataset_message)){
                        Compare_dataset_get_overview_status(paste0("Comparison is done. ", cond_message, "\nHowever, ", error_dataset_message))
                    } else {
                        Compare_dataset_get_overview_status(paste0("Comparison is done. ", cond_message))
                    }

                    isCalculating_ovelap_hit(FALSE)
            })

        #

    return(list(
        overlapped_genes_table   = overlapped_genes_table,
        isCalculating_ovelap_hit = isCalculating_ovelap_hit
    ))
}
