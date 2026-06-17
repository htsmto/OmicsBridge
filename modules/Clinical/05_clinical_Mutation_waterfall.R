# =============================================================================
# Clinical - Mutation: Frequency Bar Plot & Kaplan-Meier Survival Plot
# File: modules/Clinical/05_clinical_Mutation_waterfall.R
# Purpose: Renders the mutation frequency bar chart and the Kaplan-Meier
#          survival plot for a user-selected gene from the frequency table.
# Edit this file when: changing plot aesthetics, survival analysis logic,
#                      or the frequency bar chart options.
# =============================================================================

mutation_waterfall_server <- function(input, output, session,
                                      ex_table, survival_table, meta_table, mutation_table, Custom_genesets,
                                      mut_freq_table, isCalculating, All_sample_flag, filtered_sample_ids) {

    ## Plots
        # Frequency plot
            # status
                Clinical_Mutation_frequency_plot_status_plot <- reactiveVal(NULL)
                output$Clinical_Mutation_frequency_plot_status_plot <- renderText({ Clinical_Mutation_frequency_plot_status_plot() })
            #

            # mutation frequency plot
                output$Clinical_Mutation_frequency_plot <- renderPlot({
                    if(isCalculating()){
                        return(NULL)
                    }

                    # when no mutation frequence table is generated
                        if(length(mut_freq_table()) == 0 || is.null(mut_freq_table())){
                            Clinical_Mutation_frequency_plot_status_plot("Please calculate the mutation frequency first.")
                            return(ggplot())
                        }
                    #

                    # when the mutation frequency table is generated
                        df_mut_num <- mut_freq_table()
                        Clinical_Mutation_frequency_plot_status_plot(NULL)

                        # based on Clinical_Mutation_frequency_plot_top_X, show the top X genes using the frequency
                        if(length(input$Clinical_Mutation_frequency_plot_top_X) == 0 ){
                            return(ggplot())
                        }
                        # if the number of genes is less than the input top X number, show all the genes
                        showing_all_genes_flag <- FALSE
                        if(dim(df_mut_num)[1] < input$Clinical_Mutation_frequency_plot_top_X){
                            df_mut_num <- df_mut_num
                            showing_all_genes_flag <- TRUE
                        }else{
                            df_mut_num <- head(df_mut_num, input$Clinical_Mutation_frequency_plot_top_X)
                        }

                        # Show the number of patients
                        if(input$Clinical_Mutation_frequency_plot_type == 'A'){

                            p <- ggplot(df_mut_num, aes(x=genes, y=Number_of_patients, fill=Number_of_patients))
                            p <- p + geom_bar(stat = 'identity')
                            if(!input$Clinical_Mutation_frequency_hide_score){
                                p <- p + geom_text(aes(label=Number_of_patients), vjust=-0.5, color='black', size=input$Clinical_Mutation_frequency_score_size)
                            }
                            if(max(df_mut_num$Number_of_patients) > 0){
                                p <- p + scale_fill_gradientn( colors = c(input$Clinical_Mutation_frequency_colour_zero,input$Clinical_Mutation_frequency_colour_high ), values = scales::rescale(c(0, max(df_mut_num$Number_of_patients))) , limits = c(0, max(df_mut_num$Number_of_patients)), name=NULL)
                            }else{
                                p <- p + scale_fill_gradientn(name=NULL)
                            }
                            p <- p + labs(y='Number of the Patients with mutations', x=NULL)


                        }else if(input$Clinical_Mutation_frequency_plot_type == 'B'){ # show the percentage
                            p <- ggplot(df_mut_num, aes(x=genes, y=Frequence, fill=Frequence))
                            p <- p + geom_bar(stat = 'identity')
                            if(!input$Clinical_Mutation_frequency_hide_score){
                                p <- p + geom_text(aes(label=Frequence), vjust=-0.5, color='black',size=input$Clinical_Mutation_frequency_score_size)
                            }
                            if(max(df_mut_num$Frequence) > 0){
                                p <- p + scale_fill_gradientn( colors = c(input$Clinical_Mutation_frequency_colour_zero,input$Clinical_Mutation_frequency_colour_high ), values = scales::rescale(c(0, max(df_mut_num$Frequence))) , limits = c(0, max(df_mut_num$Frequence)), name=NULL)
                            }else{
                                p <- p + scale_fill_gradientn(name=NULL)
                            }
                            p <- p + labs(y='Percentage of the Patients with mutations', x=NULL)
                        }
                        if(!showing_all_genes_flag){
                            p <- p + labs(x= paste0("Top ", input$Clinical_Mutation_frequency_plot_top_X ," frequently mutated genes"))
                        }
                        p <- p + theme(axis.text.y = element_text(size = input$Clinical_Mutation_frequency_title_size), axis.text.x = element_text(size = input$Clinical_Mutation_frequency_label_size))
                        p <- p + theme(axis.title.y = element_text(size = input$Clinical_Mutation_frequency_title_size), axis.title.x = element_text(size = input$Clinical_Mutation_frequency_title_size))
                        p <- p + theme(legend.key.size = unit(2, "mm"))
                        p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                        p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                        p <- p + theme(legend.text = element_text(size=input$Clinical_Mutation_frequency_legend_size))
                        if(input$Clinical_Mutation_frequency_white_background){
                            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                            p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                        }
                        p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
                        p

                }, width=reactive(input$Clinical_Mutation_frequency_fig.width), height=reactive(input$Clinical_Mutation_frequency_fig.height), res=300)
            #
        #

        # survival plot
            # status
                Clinical_Mutation_Kaplan_plot_status <- reactiveVal("Please calculate the mutation frequency first.")
                output$Clinical_Mutation_Kaplan_plot_status <- renderText({ Clinical_Mutation_Kaplan_plot_status() })
            #

            # UI
                output$Clinical_Mutation_Kaplan_choose_score_type <- renderUI({
                    if(!is.null(survival_table())){
                        suv_colnames <- colnames(survival_table())
                        col_tmp <- suv_colnames[grepl("\\.time", colnames(survival_table()), ignore.case = TRUE)]
                        col_first_parts <- sapply(strsplit(col_tmp, "\\."), `[`, 1)
                    }else{
                        col_first_parts <- NULL
                    }
                    selectInput(session$ns('Clinical_Mutation_Kaplan_choose_score_type'), 'Select the event type',  c('None'='None', col_first_parts))
                })

            #

            # Plot
                output$Clinical_Mutation_Kaplan_plot <- renderPlot({
                    if(isCalculating()){
                        return(ggplot())
                    }

                    # when no mutation frequence table is generated
                        if(length(mut_freq_table()) == 0 || is.null(mut_freq_table())){
                            Clinical_Mutation_Kaplan_plot_status("Please calculate the mutation frequency first.")
                            return(ggplot())
                        }
                    #

                    # when the mutation frequency table is generated
                        df_mut_num <- mut_freq_table()

                    # no gene is selected
                        if(length(input$Clinical_Mutation_frequency_table_rows_selected) == 0 || input$Clinical_Mutation_frequency_table_rows_selected == 'None'){
                            Clinical_Mutation_Kaplan_plot_status("Please select a gene from the table for the survival analysis.")
                            return(ggplot())
                        }

                    #

                    # when no event is selected
                        if(length(input$Clinical_Mutation_Kaplan_choose_score_type) == 0 || input$Clinical_Mutation_Kaplan_choose_score_type == 'None'){
                            Clinical_Mutation_Kaplan_plot_status("Please select an event type for the survival analysis.")
                            return(ggplot())
                        }
                    #

                    #


                    # get the group (mutant and wt) for the selected gene
                        df_OS <- survival_table()
                        gene_kaplan <- mut_freq_table()[input$Clinical_Mutation_frequency_table_rows_selected, 'genes']
                        df_mut <- mutation_table()
                        df_mut_sample <- intersect(df_OS$sample, unique(df_mut[df_mut$id == gene_kaplan,]$sample))
                        df_wt_sample <- setdiff(df_OS$sample, df_mut[df_mut$id == gene_kaplan,]$sample)

                        # if sample filetring is applied, further filter the mutant and wt sample according to the filtered sample ids
                        if(!All_sample_flag()){
                            df_mut_sample <- intersect(df_mut_sample, filtered_sample_ids())
                            df_wt_sample <- intersect(df_wt_sample, filtered_sample_ids())
                        }

                        # check
                        if(length(df_mut_sample) == 0){
                            Clinical_Mutation_Kaplan_plot_status(paste0('There is no mutated patient for this gene: ', gene_kaplan ))
                            return(ggplot())
                        }
                        if(length(df_wt_sample) == 0){
                            Clinical_Mutation_Kaplan_plot_status('There is no wild type patient for this gene.')
                            return(ggplot())
                        }

                    #

                    df_OS$group = NA
                    df_OS[df_OS$sample %in% df_mut_sample,]$group <- 'Mutation'
                    df_OS[df_OS$sample %in% df_wt_sample,]$group <- 'Wild.Type'
                    df_OS$group <- factor(df_OS$group, levels=c('Mutation', 'Wild.Type'))


                    # survival object
                    surv_obj <- Surv(time = df_OS[, paste0(input$Clinical_Mutation_Kaplan_choose_score_type, '.time')], event = df_OS[,input$Clinical_Mutation_Kaplan_choose_score_type])
                    km_fit <- survfit(surv_obj ~ group, data = df_OS)
                    km_data <- broom::tidy(km_fit)
                    cox_model <- coxph(surv_obj ~ group, data = df_OS)

                    # Hazard ratio and p
                    HR <- exp(cox_model$coefficients)
                    p_value <- summary(cox_model)$coefficients[, 5]
                    message <- paste0('P-value: ', p_value, '\n', 'HR: ', HR )
                    Clinical_Mutation_Kaplan_plot_status(paste0(gene_kaplan, ": ", length(df_mut_sample), " mutated patients and ", length(df_wt_sample), " wild type patients.", "\n", message))

                    # graph
                    km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 0.25) +
                    geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
                    labs( title = gene_kaplan, x = "Time", y = "Survival Probability", color = "") +
                    scale_color_manual(
                        values=c('group=Mutation'=input$Clinical_Mutation_Kaplan_High_colour, 'group=Wild.Type'=input$Clinical_Mutation_Kaplan_Low_colour),
                        labels=c(paste0(gene_kaplan, '-Mutation (n=', as.character(length(df_mut_sample)), ')'), paste0(gene_kaplan, '-Wild.Type (n=', as.character(length(df_wt_sample)), ')'))
                    ) +
                    scale_fill_manual(
                        values=c('group=Mutation'=input$Clinical_Mutation_Kaplan_High_colour, 'group=Wild.Type'=input$Clinical_Mutation_Kaplan_Low_colour),
                        labels=c(paste0(gene_kaplan, '-Mutation (n=', as.character(length(df_mut_sample)), ')'), paste0(gene_kaplan, '-Wild.Type (n=', as.character(length(df_wt_sample)), ')'))
                    ) +
                    guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Clinical_Mutation_Kaplan_legend_size))
                    p <- km_plot
                    p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                    p <- p + theme(axis.text = element_text(size = input$Clinical_Mutation_Kaplan_label_size))
                    p <- p + theme(axis.title = element_text(size = input$Clinical_Mutation_Kaplan_title_size))
                    # p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))
                    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    p <- p + theme(legend.key.size = unit(2, "mm"))
                    p <- p + labs(title=NULL)
                    p

                }, width=reactive(input$Clinical_Mutation_Kaplan_fig.width), height=reactive(input$Clinical_Mutation_Kaplan_fig.height), res=300)

            #
        #

    ##
}
