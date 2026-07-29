clinical_CompareCohorts_server <- function(input, output, session, Clinical_dataset, Custom_genesets) {

    ## Cohort selection table
    output$Compare_across_cohorts_cohort_table <- renderDataTable({
        cohorts_list <- Clinical_dataset()$Database.Name
        datatable(data.frame(Cohort = cohorts_list),
                  selection = list(mode = 'multiple'),
                  options = list(scrollX = TRUE, pageLength = 10,
                                 buttons = c('selectAll', 'selectNone'),
                                 dom = 'Blfrtip', rowId = 0))
    })

    ## Custom geneset selector
    output$Compare_across_cohorts_gene_from_custom_geneset_select <- renderUI({
        if (input$Compare_across_cohorts_gene_from_custom_geneset) {
            gene_sets_names <- Custom_genesets()$Geneset.name
            selectInput(session$ns('Compare_across_cohorts_gene_from_custom_geneset_select'),
                        'Select a custom geneset',
                        c('None' = 'None', gene_sets_names))
        } else {
            NULL
        }
    })
    outputOptions(output, "Compare_across_cohorts_gene_from_custom_geneset_select", suspendWhenHidden = FALSE)

    ## Disable textarea when custom geneset toggle is ON
    observe({
        if (length(input$Compare_across_cohorts_gene_from_custom_geneset) > 0 &&
            input$Compare_across_cohorts_gene_from_custom_geneset == TRUE) {
            shinyjs::disable("Compare_across_cohorts_gene")
        } else {
            shinyjs::enable("Compare_across_cohorts_gene")
        }
    })

    ## Gene list reactive
    gene_list <- reactive({
        if (input$Compare_across_cohorts_gene_from_custom_geneset) {
            sel <- input$Compare_across_cohorts_gene_from_custom_geneset_select
            if (length(sel) == 0 || sel == 'None') {
                output$Compare_across_cohorts_gene_table_status <- renderText({"Please select a custom gene set."})
                return(NULL)
            }
            genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% sel, ]$Genes, split = ', ')[[1]]
            return(data.frame(Gene = genes))
        } else {
            if (nchar(input$Compare_across_cohorts_gene) == 0) {
                output$Compare_across_cohorts_gene_table_status <- renderText({"Please enter genes line by line."})
                return(NULL)
            } else {
                genes <- unlist(strsplit(input$Compare_across_cohorts_gene, split = "\n"))
                return(data.frame(Gene = genes))
            }
        }
    })

    ## Gene table
    output$Compare_across_cohorts_gene_table <- renderDataTable({
        if (is.null(gene_list())) {
            datatable(data.frame(), selection = list(mode = 'single'),
                      options = list(scrollX = TRUE, pageLength = 10))
        } else {
            output$Compare_across_cohorts_gene_table_status <- renderText({NULL})
            datatable(gene_list(), selection = list(mode = 'single'),
                      options = list(scrollX = TRUE, pageLength = 10))
        }
    })
    output$Compare_across_cohorts_input_status <- renderText({'Please select a gene and cohorts to compare (more than one) below'})

    ## ---- Mutation Frequency ------------------------------------------------

    output$Compare_across_cohorts_mut_freq_plot_status <- renderText({'A plot for mutation counts or frequencies will be shown here'})
    output$Compare_across_cohorts_mut_freq_table_status <- renderText({'A table for mutation counts or frequencies will be shown here.'})
    outputOptions(output, "Compare_across_cohorts_mut_freq_plot_status", suspendWhenHidden = FALSE)
    outputOptions(output, "Compare_across_cohorts_mut_freq_table_status", suspendWhenHidden = FALSE)

    isCalculating_comp_coh_mut <- reactiveVal(FALSE)
    triggered_comp_coh_mut     <- reactiveVal(FALSE)
    Compare_cohort_mut_table   <- reactiveVal()

    observeEvent(input$Compare_across_cohorts_mut_freq_start, {
        isCalculating_comp_coh_mut(TRUE)
        triggered_comp_coh_mut(TRUE)

        if (length(input$Compare_across_cohorts_gene_table_rows_selected) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({'Please select a gene'})
            show_alert(title = 'Error.', text = 'Please select a gene.', type = 'error')
            Compare_cohort_mut_table(NULL)
            isCalculating_comp_coh_mut(FALSE)
            return()
        } else if (length(input$Compare_across_cohorts_cohort_table_rows_selected) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({'Please select cohorts (more than one)'})
            show_alert(title = 'Error.', text = 'Please select cohorts (more than one).', type = 'error')
            Compare_cohort_mut_table(NULL)
            isCalculating_comp_coh_mut(FALSE)
            return()
        }

        cohorts <- Clinical_dataset()[input$Compare_across_cohorts_cohort_table_rows_selected, ]$Database.Name
        gene    <- gene_list()[input$Compare_across_cohorts_gene_table_rows_selected, ]
        df_out  <- data.frame(Cohort = c(), Mutation.Patients = c(), Frequency = c())

        for (cohort in cohorts) {
            mut_path <- Clinical_dataset()[Clinical_dataset()$Database.Name == cohort, ]$Mutation_path
            if (file.exists(mut_path)) {
                mut <- data.frame(read.delim(mut_path, header = TRUE, check.names = FALSE))
                if (gene %in% mut$id) {
                    mut_gene <- mut[mut$id == gene, ]
                    df_tmp <- data.frame(
                        Cohort            = cohort,
                        Mutation.Patients = length(unique(mut_gene$sample)),
                        Frequency         = round(length(unique(mut_gene$sample)) / length(unique(mut$sample)) * 100, 2)
                    )
                    df_out <- rbind(df_out, df_tmp)
                }
                rm(mut, mut_gene)
            }
        }

        if (nrow(df_out) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({"None of the cohorts has a mutation of the selected gene. Please check the gene name for typos or extra spaces."})
            show_alert(title = 'Error.', text = 'None of the cohorts has a mutation of the selected gene.', type = 'error')
            Compare_cohort_mut_table(NULL)
        } else {
            output$Compare_across_cohorts_input_status <- renderText({NULL})
            Compare_cohort_mut_table(df_out)
        }
        isCalculating_comp_coh_mut(FALSE)
    })

    output$Compare_across_cohorts_mut_freq_table <- renderDataTable({
        if (is.null(Compare_cohort_mut_table())) {
            output$Compare_across_cohorts_mut_freq_table_status <- renderText({'A table for mutation counts or frequencies will be shown here.'})
            tmp <- data.frame(list('Cohort' = character(0), 'Mutation counts' = character(0), 'Percent' = character(0)), stringsAsFactors = FALSE)
            datatable(tmp, options = list(scrollX = TRUE, pageLength = 10, fixedColumns = list(leftColumns = 1)), rownames = TRUE)
        } else {
            output$Compare_across_cohorts_mut_freq_table_status <- renderText({NULL})
            datatable(Compare_cohort_mut_table(), options = list(scrollX = TRUE, pageLength = 5, fixedColumns = list(leftColumns = 1)), rownames = TRUE)
        }
    })
    outputOptions(output, "Compare_across_cohorts_mut_freq_table", suspendWhenHidden = FALSE)

    output$Compare_across_cohorts_mut_freq_plot <- renderPlot({
        if (!triggered_comp_coh_mut()) return(ggplot())
        if (isCalculating_comp_coh_mut()) return(ggplot())
        if (is.null(Compare_cohort_mut_table())) {
            output$Compare_across_cohorts_mut_freq_plot_status <- renderText({'A plot for mutation counts or frequencies will be shown here'})
            return(ggplot())
        }

        df_tmp <- Compare_cohort_mut_table()
        if (input$Compare_across_cohorts_mut_freq_plot_type == 'A') {
            df_tmp       <- df_tmp[order(df_tmp$Mutation.Patients, decreasing = TRUE), ]
            df_tmp$Cohort <- factor(df_tmp$Cohort, levels = df_tmp$Cohort)
            p <- ggplot(df_tmp, aes(x = Cohort, y = Mutation.Patients, fill = Mutation.Patients))
        } else {
            df_tmp       <- df_tmp[order(df_tmp$Frequency, decreasing = TRUE), ]
            df_tmp$Cohort <- factor(df_tmp$Cohort, levels = df_tmp$Cohort)
            p <- ggplot(df_tmp, aes(x = Cohort, y = Frequency, fill = Frequency))
        }

        p <- p + geom_bar(stat = "identity")

        if (!input$Compare_across_cohorts_mut_hide_score) {
            label_col <- if (input$Compare_across_cohorts_mut_freq_plot_type == 'A') "Mutation.Patients" else "Frequency"
            p <- p + geom_text(aes(label = .data[[label_col]]), vjust = -0.5, color = 'black',
                               size = input$Compare_across_cohorts_mut_score_size)
        }

        max_val <- if (input$Compare_across_cohorts_mut_freq_plot_type == 'A') max(df_tmp$Mutation.Patients) else max(df_tmp$Frequency)
        if (max_val > 0) {
            p <- p + scale_fill_gradientn(
                colors = c(input$Compare_across_cohorts_mut_colour_zero, input$Compare_across_cohorts_mut_colour_high),
                values = scales::rescale(c(0, max_val)),
                limits = c(0, max_val),
                name   = NULL
            )
        } else {
            p <- p + scale_fill_gradientn(name = NULL)
        }

        p <- p + theme(axis.text   = element_text(size = input$Compare_across_cohorts_mut_label_size))
        p <- p + theme(axis.title  = element_text(size = input$Compare_across_cohorts_mut_title_size))
        p <- p + theme(legend.text = element_text(size = input$Compare_across_cohorts_mut_legend_size))
        p <- p + theme(legend.key.size = unit(2, "mm"))
        p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
        p <- p + theme(axis.ticks = element_line(linewidth = 0.1), axis.ticks.length = unit(0.5, "pt"))
        if (input$Compare_across_cohorts_mut_white_background) {
            p <- p + theme(panel.grid = element_blank(), panel.border = element_blank(),
                           axis.line = element_line(color = 'black', linewidth = 0.1),
                           panel.background = element_rect(fill = "white", size = 0))
        }
        p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
        output$Compare_across_cohorts_mut_freq_plot_status <- renderText({NULL})
        p
    },
    width  = reactive(input$Compare_across_cohorts_mut_fig.width),
    height = reactive(input$Compare_across_cohorts_mut_fig.height),
    res    = 300)

    ## ---- Gene Expression ---------------------------------------------------

    isCalculating_comp_coh_gx <- reactiveVal(FALSE)
    triggered_comp_coh_gx     <- reactiveVal(FALSE)
    Compare_cohort_gx_table   <- reactiveVal()

    observeEvent(input$Compare_across_cohorts_gx_start, {
        isCalculating_comp_coh_gx(TRUE)
        triggered_comp_coh_gx(TRUE)

        if (length(input$Compare_across_cohorts_gene_table_rows_selected) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({'Please select a gene'})
            show_alert(title = 'Error.', text = 'Please select a gene.', type = 'error')
            Compare_cohort_gx_table(NULL)
            isCalculating_comp_coh_gx(FALSE)
            return()
        } else if (length(input$Compare_across_cohorts_cohort_table_rows_selected) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({'Please select cohorts (more than one)'})
            show_alert(title = 'Error.', text = 'Please select cohorts (more than one).', type = 'error')
            Compare_cohort_gx_table(NULL)
            isCalculating_comp_coh_gx(FALSE)
            return()
        }

        cohorts <- Clinical_dataset()[input$Compare_across_cohorts_cohort_table_rows_selected, ]$Database.Name
        gene    <- gene_list()[input$Compare_across_cohorts_gene_table_rows_selected, ]
        df_out  <- data.frame(Cohort = c(), Expression = c())

        for (cohort in cohorts) {
            gx_path <- Clinical_dataset()[Clinical_dataset()$Database.Name == cohort, ]$Expression_path
            if (file.exists(gx_path)) {
                gx <- data.frame(read.delim(gx_path, header = TRUE, check.names = FALSE))
                if (gene %in% gx$id) {
                    gx_gene        <- gx[gx$id == gene, ]
                    gx_gene        <- gx_gene[!names(gx_gene) %in% 'id']
                    gx_gene        <- na.omit(gx_gene)
                    df_tmp         <- data.frame(Expression = as.numeric(gx_gene))
                    df_tmp$Cohort  <- cohort
                    df_out         <- rbind(df_out, df_tmp)
                }
                rm(gx, gx_gene)
            }
        }

        if (nrow(df_out) == 0) {
            output$Compare_across_cohorts_input_status <- renderText({"None of the cohorts has the selected gene. Please check the gene name for typos or extra spaces."})
            show_alert(title = 'Error.', text = 'None of the cohorts has the selected gene.', type = 'error')
            Compare_cohort_gx_table(NULL)
        } else {
            output$Compare_across_cohorts_input_status <- renderText({NULL})
            Compare_cohort_gx_table(df_out)
        }
        isCalculating_comp_coh_gx(FALSE)
    })

    output$Compare_across_cohorts_gx_plot <- renderPlot({
        if (!triggered_comp_coh_gx()) return(ggplot())
        if (isCalculating_comp_coh_gx()) return(ggplot())
        if (is.null(Compare_cohort_gx_table())) {
            output$Compare_across_cohorts_gx_plot_status <- renderText({'A plot for gene expression across cohorts will be shown here'})
            return(ggplot())
        }

        df_tmp      <- Compare_cohort_gx_table()
        med_order   <- names(sort(tapply(df_tmp$Expression, df_tmp$Cohort, median), decreasing = TRUE))
        df_tmp$Cohort <- factor(df_tmp$Cohort, levels = med_order)

        p <- ggplot(df_tmp, aes(x = Cohort, y = Expression, fill = Cohort))
        p <- p + geom_boxplot(size = 0.2, outlier.size = 0.5)
        p <- p + theme(axis.text   = element_text(size = input$Compare_across_cohorts_gx_label_size))
        p <- p + theme(axis.title  = element_text(size = input$Compare_across_cohorts_gx_title_size))
        p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
        p <- p + theme(axis.ticks = element_line(linewidth = 0.1), axis.ticks.length = unit(0.5, "pt"))
        p <- p + theme(legend.position = 'none')
        if (input$Compare_across_cohorts_gx_white_background) {
            p <- p + theme(panel.grid = element_blank(), panel.border = element_blank(),
                           axis.line = element_line(color = 'black', linewidth = 0.1),
                           panel.background = element_rect(fill = "white", size = 0))
        }
        p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
        output$Compare_across_cohorts_gx_plot_status <- renderText({NULL})
        p
    },
    width  = reactive(input$Compare_across_cohorts_gx_fig.width),
    height = reactive(input$Compare_across_cohorts_gx_fig.height),
    res    = 300)
}
