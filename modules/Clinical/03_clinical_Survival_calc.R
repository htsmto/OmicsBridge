# =============================================================================
# Clinical - Survival Analysis: Calculation
# File: modules/Clinical/03_clinical_Survival_calc.R
# Purpose: Kaplan-Meier and Cox proportional-hazards computation triggered
#          by the "Start" button. Loops over input genes, splits samples into
#          high/low groups, fits survival models, and stores results as
#          reactive values for the plot/table sub-module.
# Edit this file when: changing the KM/Cox fitting method, grouping strategy,
#                      or how error genes are handled.
# =============================================================================

survival_calc_server <- function(input, output, session, ex_table, surv_table, meta_table,
                                  survival_input_genes, top_X_percent, bottom_X_percent,
                                  top_sample_name, bottom_sample_name, All_sample_flag,
                                  filtered_sample_ids, Clinical_Survival_input_status) {

    ## Run the survival analysis when the user click the action button
        # caluculate the p and HR value and save as a table.
            isCalculating <- reactiveVal(FALSE)
            df_Suv_p_and_HR <- reactiveVal(NULL)
            plot_lists <- reactiveVal(list())
            observeEvent(input$Clinical_Survival_start, {
                isCalculating(TRUE)
                # check if the input is valid
                    # when the surv_table is not loaded, show error
                    if(is.null(surv_table())){
                        Clinical_Survival_input_status("Please select a dataset first.")
                        show_alert(title = "Error", text = "Please select a dataset first.", type = "error")
                        isCalculating(FALSE)
                        plot_lists(NULL)
                        return(NULL)
                    }

                    # input genes
                    if(input$Clinical_Survival_Split_way != 'C'){
                        if(is.null(survival_input_genes()) || length(survival_input_genes()) == 0){
                            Clinical_Survival_input_status("Please enter the input and choose the setting, and click 'Start the survival analysis'.")
                            show_alert(title = "Error", text = "Please input the gene names.", type = "error")
                            plot_lists(NULL)
                            isCalculating(FALSE)
                            return(NULL)
                        }
                        survival_input_genes <- survival_input_genes()
                    }


                    # Sample Split setting
                    if(input$Clinical_Survival_Split_way == 'A' || input$Clinical_Survival_Split_way == 'B' || input$Clinical_Survival_Split_way == 'D'){
                        if(is.null(top_X_percent()) || is.null(bottom_X_percent())){
                            Clinical_Survival_input_status("Please enter the percentage for sample split, and make sure the percentage is a number between 1 and 99")
                            show_alert(title = "Error", text = "Please enter the percentage for sample split, and make sure the percentage is a number between 1 and 100.", type = "error")
                            isCalculating(FALSE)
                            plot_lists(NULL)
                            return(NULL)
                        }
                        top_X_percent <- top_X_percent()
                        bottom_X_percent <- bottom_X_percent()
                    }else if(input$Clinical_Survival_Split_way == 'C'){
                        if(is.null(top_sample_name()) || is.null(bottom_sample_name()) || nchar(top_sample_name()) == 0 || nchar(bottom_sample_name()) == 0){
                            # Clinical_Survival_input_status("Please enter the sample names for both Group 1 and Group 2.")
                            Clinical_Survival_input_status(top_sample_name())
                            show_alert(title = "Error", text = "Please enter the sample names for both Group 1 and Group 2.", type = "error")
                            isCalculating(FALSE)
                            plot_lists(NULL)
                            return(NULL)
                        }
                        top_sample_name <- unlist(strsplit(top_sample_name(), split="\n"))
                        bottom_sample_name <- unlist(strsplit(bottom_sample_name(), split="\n"))
                    }

                    # Sample filtering setting
                    if(All_sample_flag() == FALSE){
                        if(is.null(filtered_sample_ids()) || length(filtered_sample_ids()) == 0){
                            Clinical_Survival_input_status("Please select a category for filtering the samples.")
                            show_alert(title = "Error", text = "Please select a category for filtering the samples.", type = "error")
                            isCalculating(FALSE)
                            plot_lists(NULL)
                            return(NULL)
                        }
                        filtered_sample_ids <- filtered_sample_ids()

                        # if there is only one sample, the survival analysis cannot be performed. Show error in this case.
                        if(length(filtered_sample_ids) == 1){
                            Clinical_Survival_input_status("Only one sample is selected for survival analysis, which is not valid. Please select a category with more than one sample for filtering the samples.")
                            show_alert(title = "Error", text = "Only one sample is selected for survival analysis, which is not valid. Please select a category with more than one sample for filtering the samples.", type = "error")
                            isCalculating(FALSE)
                            plot_lists(NULL)
                            return(NULL)
                        }
                    }else{
                        filtered_sample_ids <- NULL
                    }

                    # event selection
                    if(length(input$Clinical_Survival_choose_score_type) == 0 || input$Clinical_Survival_choose_score_type == 'None'){
                        Clinical_Survival_input_status("Please select the event type for survival analysis.")
                        show_alert(title = "Error", text = "Please select the event type for survival analysis.", type = "error")
                        isCalculating(FALSE)
                        plot_lists(NULL)
                        return(NULL)
                    }
                    event_type <- input$Clinical_Survival_choose_score_type
                #

                # calculate p and HR for each gene
                    df_geneEx <- ex_table()
                    df_OS <- surv_table()
                    df_meta <- meta_table()
                    df_out <- data.frame('Gene'=c(), 'P.value'=c(), 'Hazard.Ratio'=c())
                    error_genes <- c()
                    plot_lists_tmp <- list()

                    if(input$Clinical_Survival_Split_way == 'A' || input$Clinical_Survival_Split_way == 'B' || input$Clinical_Survival_Split_way == 'D'){
                        for(gene in survival_input_genes){ # gene <- survival_input_genes[1]
                            # grouping
                            # if gene is not included in the expression table
                            if(!(gene %in% rownames(df_geneEx))){
                                error_genes <- c(error_genes, gene)
                                df_tmp <- data.frame('Gene'=gene, 'P.value'=NA, 'Hazard.Ratio'=NA)
                                df_out <- rbind(df_out, df_tmp)
                                plot_lists_tmp[[gene]] <- NULL
                                next
                            }

                            # apply sample filtering
                            if(!is.null(filtered_sample_ids())){
                                df_geneEx <- df_geneEx[, colnames(df_geneEx) %in% filtered_sample_ids()]
                                df_OS <- df_OS[df_OS$sample %in% filtered_sample_ids(), ]
                            }
                            topX <- quantile(unlist(df_geneEx[gene,]), (100-top_X_percent)/100 , na.rm = T)
                            bottomY <- quantile(unlist(df_geneEx[gene,]), bottom_X_percent/100 , na.rm = T)
                            df_high_sample <- colnames(df_geneEx[,df_geneEx[gene,] >= topX])
                            df_low_sample <- colnames(df_geneEx[,df_geneEx[gene,] <= bottomY])

                            if(length(df_high_sample)==0|length(df_low_sample)==0){
                                error_genes <- c(error_genes, gene)
                                df_tmp <- data.frame('Gene'=gene, 'P.value'=NA, 'Hazard.Ratio'=NA)
                                df_out <- rbind(df_out, df_tmp)
                                plot_lists_tmp[[gene]] <- NULL
                            }else{
                                # add group
                                df_OS$group = NA
                                df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
                                df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
                                df_OS$group <- factor(df_OS$group, levels=c('Low', 'High'))
                                # survival object
                                surv_obj <- Surv(time = df_OS[, paste0(event_type, '.time')], event = df_OS[,event_type])
                                # calculate the kaplan-meier for each group
                                km_fit <- survfit(surv_obj ~ group, data = df_OS)
                                cox_model <- coxph(surv_obj ~ group, data = df_OS)
                                # Hazard ratio and p
                                HR <- exp(cox_model$coefficients)
                                p_value <- summary(cox_model)$coefficients[, 5]
                                if(input$Clinical_Survival_Split_way == 'C'){
                                    gene <- '(Custom grouping)'
                                }
                                df_tmp <- data.frame('Gene'=gene, 'P.value'=p_value, 'Hazard.Ratio'=HR)
                                df_out <- rbind(df_out, df_tmp)

                                # plot
                                km_data <- broom::tidy(km_fit)
                                km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(linewidth = 0.25) +
                                    geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
                                    labs( title = gene, x = "Time", y = event_type, color = "")
                                plot_lists_tmp[[gene]] <- km_plot
                            }

                        }
                    }else if(input$Clinical_Survival_Split_way == 'C'){
                        df_high_sample <- top_sample_name
                        df_low_sample <- bottom_sample_name

                        # check if the sample names are valid (included in the OS data)
                        df_high_sample <- df_high_sample[df_high_sample %in% df_OS$sample]
                        df_low_sample <- df_low_sample[df_low_sample %in% df_OS$sample]

                        if(length(df_high_sample)==0|length(df_low_sample)==0){
                            Clinical_Survival_input_status("None of the sample names you entered for Group 1 or Group 2 are included in the dataset. Please check your input.")
                            show_alert(title = "Error", text = "None of the sample names you entered for Group 1 or Group 2 are included in the dataset. Please check your input.", type = "error")
                            isCalculating(FALSE)
                            plot_lists(NULL)
                            return(NULL)
                        }else{
                            # add group
                            df_OS$group = NA
                            df_OS[df_OS$sample %in% df_high_sample,]$group <- 'Group1'
                            df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Group2'
                            df_OS$group <- factor(df_OS$group, levels=c('Group2', 'Group1'))
                            # survival object
                            surv_obj <- Surv(time = df_OS[, paste0(event_type, '.time')], event = df_OS[,event_type])
                            # calculate the kaplan-meier for each group
                            km_fit <- survfit(surv_obj ~ group, data = df_OS)
                            cox_model <- coxph(surv_obj ~ group, data = df_OS)
                            # Hazard ratio and p
                            HR <- exp(cox_model$coefficients)
                            p_value <- summary(cox_model)$coefficients[, 5]
                            gene <- '(Custom grouping)'

                            df_tmp <- data.frame('Gene'=gene, 'P.value'=p_value, 'Hazard.Ratio'=HR)
                            df_out <- rbind(df_out, df_tmp)

                            # plot
                            km_data <- broom::tidy(km_fit)
                            km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(linewidth = 0.25) +
                                geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
                                labs( title = gene, x = "Time", y = event_type, color = "")
                            plot_lists_tmp[[gene]] <- km_plot
                        }

                    }


                    # show the status. if there are error_genes, show the error genes and potential reason (not expressed in the dataset, cannot devide into two groups with the selected split method etc)
                    # show how many genes are successfully calculated and how many genes are not calculated due to the error
                    # show the condition of the split and filtering method
                    if(input$Clinical_Survival_Split_way != 'C'){
                        message <- paste0("The survival analysis is done for ", nrow(df_out) - length(error_genes), " gene(s).\n")
                        message <- paste0(message, "The samples are split by ", ifelse(input$Clinical_Survival_Split_way == 'A', 'median', ifelse(input$Clinical_Survival_Split_way == 'B', 'top 25% vs bottom 25%', paste0('top ', top_X_percent(), '% vs bottom ', bottom_X_percent(), '%'))), ".\n")
                    }else{
                        message <- paste0("The survival analysis is done for the custom grouping you entered.\n")
                    }

                    if(All_sample_flag() == TRUE){
                        message <- paste0(message, "All the samples are used for the survival analysis.\n")
                    }else{
                        message <- paste0(message, "Only the samples in category ", input$Clinical_Survival_frequency_filter_selection_category, " of ", input$Clinical_Survival_frequency_filter_selection, " are used for the survival analysis.\n")
                    }
                    if(length(error_genes) > 0){
                        message <- paste0(message, "These genes failed to be calculated: \n", paste(error_genes, collapse = ', '), "\n\nThe potential reason: \n1)these genes are not expressed in the dataset \n2)cannot be divided into two groups with the selected split method due to its expression distribution.")
                    }
                    Clinical_Survival_input_status(message)

                    df_out <- df_out[order(df_out$Hazard.Ratio, decreasing = TRUE), ]
                    df_Suv_p_and_HR(df_out)
                    plot_lists(plot_lists_tmp)
                    isCalculating(FALSE)


            })

        #

    ##

    return(list(
        isCalculating = isCalculating,
        df_Suv_p_and_HR = df_Suv_p_and_HR,
        plot_lists = plot_lists
    ))
}
