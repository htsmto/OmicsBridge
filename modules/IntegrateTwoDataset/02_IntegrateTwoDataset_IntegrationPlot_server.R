# =============================================================================
# IntegrateTwoDataset - Integration Plot Server
# File: modules/IntegrateTwoDataset/02_IntegrateTwoDataset_IntegrationPlot_server.R
# Purpose: Renders a correlation / concordance scatter plot comparing per-gene
#          statistics (e.g. log2FC, mean expression) between the two selected
#          datasets. Supports gene highlighting and brush selection.
# Edit this file when: changing the integration metric, plot style,
#                       or how the two datasets are aligned by gene ID.
# =============================================================================

IntegrateTwoDataset_IntegrationPlot_server <- function(input, output, session, data1_plus_data2) {

    # Load custom genesets (static snapshot; consistent with other modules)
    Custom_genesets <- data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T, check.names=FALSE))

    # --- [1] Axis / colour UI -------------------------------------------------
    # Dynamic selectInputs populated from column names of the merged dataset.

    output$Integrate_data1_plus_2_Scat.X <- renderUI({
        X_axis_name <- if (!is.null(data1_plus_data2())) colnames(data1_plus_data2()) else c()
        selectInput(session$ns('Integrate_data1_plus_2_Scat.X'), 'X', c('None'='None', X_axis_name), selected="None")
    })

    output$Integrate_data1_plus_2_Scat.Y <- renderUI({
        Y_axis_name <- if (!is.null(data1_plus_data2())) colnames(data1_plus_data2()) else c()
        selectInput(session$ns('Integrate_data1_plus_2_Scat.Y'), 'Y', c('None'='None', Y_axis_name))
    })

    output$Integrate_data1_plus_2_Scat.colour <- renderUI({
        col_name <- if (!is.null(data1_plus_data2())) colnames(data1_plus_data2()) else c()
        selectInput(session$ns('Integrate_data1_plus_2_Scat.colour'), 'Colour', c('None'='None', col_name))
    })

    # --- [2] Gene highlight UI ------------------------------------------------

    # Manual gene text input
    output$Integrate_data1_plus_2_target_gene <- renderUI({
        textAreaInput(session$ns("Integrate_data1_plus_2_target_gene"), "Enter genes names",
            placeholder="GeneA\nGeneB\nGeneC", width='100%')
    })

    # --- [3] Pathway gene filter ----------------------------------------------

    # Load a GMT gene set collection when the pathway filter checkbox is enabled
    Integrate_data1_plus_2_plot_Gene_set <- reactive({
        if (!input$Integrate_data1_plus_2_plot_use_geneset) return(NULL)
        sel <- input$Integrate_data1_plus_2_plot_pathway_dataset_select
        if (is.null(sel) || sel == 'Custom gene sets') return(NULL)
        if (sel == 'HALLMARK (human)') {
            gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt')
        } else if (sel == 'HALLMARK (mouse)') {
            gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt')
        } else if (sel == 'Custom (GMT file)') {
            tmp <- input$Integrate_data1_plus_2_plot_upload_custom_pathway_file
            if (is.null(tmp)) return(NULL)
            gsc <- getGmt(tmp$datapath)
        } else {
            return(NULL)
        }
        gsc
    })

    output$Integrate_data1_plus_2_plot_select_pathway <- renderUI({
        gene_sets_names <- c()
        if (!is.null(Integrate_data1_plus_2_plot_Gene_set())) {
            for (i in 1:length(Integrate_data1_plus_2_plot_Gene_set())) {
                gene_sets_names <- c(gene_sets_names, Integrate_data1_plus_2_plot_Gene_set()@.Data[[i]]@setName)
            }
        }
        selectInput(session$ns('Integrate_data1_plus_2_plot_select_pathway'), 'Select a geneset',
            c('None'='None', gene_sets_names))
    })
    outputOptions(output, "Integrate_data1_plus_2_plot_select_pathway", suspendWhenHidden=FALSE)

    # Custom gene sets picker for filtering
    output$Integrate_data1_plus_2_plot_custom_geneset_select <- renderUI({
        selectInput(session$ns('Integrate_data1_plus_2_plot_custom_geneset_select'), 'Select a custom gene set',
            c('None'='None', Custom_genesets$Geneset.name))
    })
    outputOptions(output, "Integrate_data1_plus_2_plot_custom_geneset_select", suspendWhenHidden=FALSE)

    # --- [4] Filtered gene reactive -------------------------------------------
    # Returns a subset of data1_plus_data2 based on threshold / pathway filters.

    Integrate_data1_plus_2_plot_filtered <- reactive({
        df_main_plot <- data1_plus_data2()
        if (is.null(df_main_plot)) return(NULL)
        if (is.null(input$Integrate_data1_plus_2_Scat.X) || is.null(input$Integrate_data1_plus_2_Scat.Y)) return(NULL)
        if (input$Integrate_data1_plus_2_Scat.X == 'None' || input$Integrate_data1_plus_2_Scat.Y == 'None') return(NULL)

        x_select <- input$Integrate_data1_plus_2_plot_xselect
        y_select <- input$Integrate_data1_plus_2_plot_yselect

        if (!input$Integrate_data1_plus_2_plot_use_geneset && x_select == 'E' && y_select == 'E') return(NULL)

        if (!is.numeric(input$Integrate_data1_plus_2_plot_xthr1) && x_select %in% c('A','C','D')) return(NULL)
        if (!is.numeric(input$Integrate_data1_plus_2_plot_xthr2) && x_select %in% c('B','C','D')) return(NULL)
        if (!is.numeric(input$Integrate_data1_plus_2_plot_ythr1) && y_select %in% c('A','C','D')) return(NULL)
        if (!is.numeric(input$Integrate_data1_plus_2_plot_ythr2) && y_select %in% c('B','C','D')) return(NULL)

        if (input$Integrate_data1_plus_2_plot_use_geneset) {
            sel <- input$Integrate_data1_plus_2_plot_pathway_dataset_select
            if (!is.null(sel) && sel == 'Custom gene sets') {
                picked <- input$Integrate_data1_plus_2_plot_custom_geneset_select
                if (is.null(picked) || picked == 'None') return(NULL)
                genes_in_set <- strsplit(Custom_genesets[Custom_genesets$Geneset.name == picked, ]$Genes, split=', ')[[1]]
                df_main_plot <- df_main_plot[df_main_plot$id %in% genes_in_set, ]
            } else {
                if (is.null(input$Integrate_data1_plus_2_plot_select_pathway) ||
                    input$Integrate_data1_plus_2_plot_select_pathway == 'None') return(NULL)
                genes_in_the_pathway <- Integrate_data1_plus_2_plot_Gene_set()[[input$Integrate_data1_plus_2_plot_select_pathway]]@geneIds
                df_main_plot <- df_main_plot[df_main_plot$id %in% genes_in_the_pathway, ]
            }
        }

        if (nrow(df_main_plot) != 0) {
            switch(x_select,
                "A" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.X] >= input$Integrate_data1_plus_2_plot_xthr1, ] },
                "B" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.X] <= input$Integrate_data1_plus_2_plot_xthr2, ] },
                "C" = { df_main_plot <- df_main_plot[(df_main_plot[input$Integrate_data1_plus_2_Scat.X] <= input$Integrate_data1_plus_2_plot_xthr1 & df_main_plot[input$Integrate_data1_plus_2_Scat.X] >= input$Integrate_data1_plus_2_plot_xthr2), ] },
                "D" = { df_main_plot <- df_main_plot[(df_main_plot[input$Integrate_data1_plus_2_Scat.X] >= input$Integrate_data1_plus_2_plot_xthr1 | df_main_plot[input$Integrate_data1_plus_2_Scat.X] <= input$Integrate_data1_plus_2_plot_xthr2), ] }
            )
            switch(y_select,
                "A" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >= input$Integrate_data1_plus_2_plot_ythr1, ] },
                "B" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <= input$Integrate_data1_plus_2_plot_ythr2, ] },
                "C" = { df_main_plot <- df_main_plot[(df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <= input$Integrate_data1_plus_2_plot_ythr1 & df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >= input$Integrate_data1_plus_2_plot_ythr2), ] },
                "D" = { df_main_plot <- df_main_plot[(df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >= input$Integrate_data1_plus_2_plot_ythr1 | df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <= input$Integrate_data1_plus_2_plot_ythr2), ] }
            )
        }
        return(df_main_plot)
    })

    # --- [5] Filter summary text ----------------------------------------------
    # Shows how many genes pass the current threshold / geneset filter.

    output$Integrate_data1_plus_2_filter_summary <- renderText({
        filtered <- Integrate_data1_plus_2_plot_filtered()
        x_sel <- input$Integrate_data1_plus_2_plot_xselect
        y_sel <- input$Integrate_data1_plus_2_plot_yselect
        use_geneset <- isTRUE(input$Integrate_data1_plus_2_plot_use_geneset)

        if (is.null(filtered)) {
            if (use_geneset || (!is.null(x_sel) && x_sel != 'E') || (!is.null(y_sel) && y_sel != 'E')) {
                return("0 genes highlighted (no data or thresholds not met)")
            }
            return("Set X/Y thresholds or enable pathway/gene set filtering to highlight genes.")
        }
        n <- nrow(filtered)

        # Build a description of the active conditions
        conditions <- c()
        if (use_geneset) {
            sel <- input$Integrate_data1_plus_2_plot_pathway_dataset_select
            if (!is.null(sel)) {
                if (sel == 'Custom gene sets') {
                    picked <- input$Integrate_data1_plus_2_plot_custom_geneset_select
                    if (!is.null(picked) && picked != 'None') conditions <- c(conditions, paste0("gene set: ", picked))
                } else {
                    pathway <- input$Integrate_data1_plus_2_plot_select_pathway
                    if (!is.null(pathway) && pathway != 'None') conditions <- c(conditions, paste0("pathway: ", pathway))
                }
            }
        }
        if (!is.null(x_sel) && x_sel != 'E') {
            x_label <- switch(x_sel,
                "A" = paste0("X > ", input$Integrate_data1_plus_2_plot_xthr1),
                "B" = paste0("X < ", input$Integrate_data1_plus_2_plot_xthr2),
                "C" = paste0(input$Integrate_data1_plus_2_plot_xthr2, " < X < ", input$Integrate_data1_plus_2_plot_xthr1),
                "D" = paste0("X < ", input$Integrate_data1_plus_2_plot_xthr2, " or X > ", input$Integrate_data1_plus_2_plot_xthr1)
            )
            conditions <- c(conditions, x_label)
        }
        if (!is.null(y_sel) && y_sel != 'E') {
            y_label <- switch(y_sel,
                "A" = paste0("Y > ", input$Integrate_data1_plus_2_plot_ythr1),
                "B" = paste0("Y < ", input$Integrate_data1_plus_2_plot_ythr2),
                "C" = paste0(input$Integrate_data1_plus_2_plot_ythr2, " < Y < ", input$Integrate_data1_plus_2_plot_ythr1),
                "D" = paste0("Y < ", input$Integrate_data1_plus_2_plot_ythr2, " or Y > ", input$Integrate_data1_plus_2_plot_ythr1)
            )
            conditions <- c(conditions, y_label)
        }

        if (length(conditions) == 0) {
            return("Set X/Y thresholds or enable pathway/gene set filtering to highlight genes.")
        }
        paste0(n, " gene(s) highlighted  [", paste(conditions, collapse=" & "), "]")
    })

    # --- [6] Main scatter plot ------------------------------------------------

    output$Integrate_data1_plus_2_plot <- renderPlot({
        df_main_plot <- data1_plus_data2()
        if (is.null(df_main_plot)) {
            output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the Data1 and the Data2."})
            return(ggplot())
        }
        if (is.null(input$Integrate_data1_plus_2_Scat.X) || is.null(input$Integrate_data1_plus_2_Scat.Y) ||
            input$Integrate_data1_plus_2_Scat.X == 'None' || input$Integrate_data1_plus_2_Scat.Y == 'None') {
            output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the X and the Y."})
            return(ggplot())
        }

        output$Integrate_data1_plus_2_plot_status <- renderText({NULL})

        # Base scatter plot with optional colour mapping
        if (is.null(input$Integrate_data1_plus_2_Scat.colour) || input$Integrate_data1_plus_2_Scat.colour == 'None') {
            p <- ggplot(df_main_plot,
                aes(x=.data[[input$Integrate_data1_plus_2_Scat.X]], y=.data[[input$Integrate_data1_plus_2_Scat.Y]]))
        } else {
            p <- ggplot(df_main_plot,
                aes(x=.data[[input$Integrate_data1_plus_2_Scat.X]], y=.data[[input$Integrate_data1_plus_2_Scat.Y]],
                    color=.data[[input$Integrate_data1_plus_2_Scat.colour]]))

            values_for_colours <- df_main_plot[, input$Integrate_data1_plus_2_Scat.colour]
            values_for_colours <- values_for_colours[!is.na(values_for_colours)]
            if (min(values_for_colours) < 0) {
                if (max(values_for_colours) >= 0) {
                    tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                    p <- p + scale_color_gradientn(colors=c("blue","white","red"), values=scales::rescale(c(-tmp,0,tmp)), limits=c(-tmp,tmp), name=input$Integrate_data1_plus_2_Scat.colour)
                    p <- p + scale_fill_gradientn(colors=c("blue","white","red"),  values=scales::rescale(c(-tmp,0,tmp)), limits=c(-tmp,tmp), name=input$Integrate_data1_plus_2_Scat.colour)
                } else {
                    p <- p + scale_color_gradientn(colors=c("blue","white"), values=scales::rescale(c(min(values_for_colours),0), limits=c(min(values_for_colours),0)), name=input$Integrate_data1_plus_2_Scat.colour)
                    p <- p + scale_fill_gradientn(colors=c("blue","white"),  values=scales::rescale(c(min(values_for_colours),0), limits=c(min(values_for_colours),0)), name=input$Integrate_data1_plus_2_Scat.colour)
                }
            } else {
                p <- p + scale_color_gradientn(colors=c("white","red"), values=scales::rescale(c(0,max(values_for_colours))), limits=c(0,max(values_for_colours)), name=input$Integrate_data1_plus_2_Scat.colour)
                p <- p + scale_fill_gradientn(colors=c("white","red"),  values=scales::rescale(c(0,max(values_for_colours))), limits=c(0,max(values_for_colours)), name=input$Integrate_data1_plus_2_Scat.colour)
            }
        }
        p <- p + geom_point(size=input$Integrate_data1_plus_2_dot_label_size)

        # Label brushed points
        tryCatch({
            res <- brushedPoints(df_main_plot, input$Integrate_data1_plus_2_plot_brush,
                xvar=input$Integrate_data1_plus_2_Scat.X, yvar=input$Integrate_data1_plus_2_Scat.Y)
            p <- p + geom_text_repel(data=res, color='black', aes(label=id),
                size=input$Integrate_data1_plus_2_id_size, segment.size=0.2, max.overlaps=70)
        }, error=function(e){NULL})

        # Threshold lines and highlight filtered genes
        if (!is.null(Integrate_data1_plus_2_plot_filtered())) {
            Integrate_outliers <- Integrate_data1_plus_2_plot_filtered()
            if (input$Integrate_data1_plus_2_plot_xselect == 'A') {
                p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr1, linetype='dotted', linewidth=0.2)
            } else if (input$Integrate_data1_plus_2_plot_xselect == 'B') {
                p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr2, linetype='dotted', linewidth=0.2)
            } else if (input$Integrate_data1_plus_2_plot_xselect %in% c('C','D')) {
                p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr1, linetype='dotted', linewidth=0.2)
                p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr2, linetype='dotted', linewidth=0.2)
            }
            if (input$Integrate_data1_plus_2_plot_yselect == 'A') {
                p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr1, linetype='dotted', linewidth=0.2)
            } else if (input$Integrate_data1_plus_2_plot_yselect == 'B') {
                p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr2, linetype='dotted', linewidth=0.2)
            } else if (input$Integrate_data1_plus_2_plot_yselect %in% c('C','D')) {
                p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr1, linetype='dotted', linewidth=0.2)
                p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr2, linetype='dotted', linewidth=0.2)
            }
            p <- p + geom_point(data=df_main_plot[df_main_plot$id %in% Integrate_outliers$id,],
                color=input$Integrate_data1_plus_2_plot_filter_colour, size=input$Integrate_data1_plus_2_highlight_dot_size)
            if (!input$Integrate_data1_plus_2_plot_filter_label) {
                p <- p + geom_text_repel(data=df_main_plot[df_main_plot$id %in% Integrate_outliers$id,],
                    color=input$Integrate_data1_plus_2_plot_filter_colour, aes(label=id),
                    size=input$Integrate_data1_plus_2_id_size, max.overlaps=50, segment.size=0.2)
            }
        }

        # Highlight user-specified genes (manual text input only)
        if (!is.null(input$Integrate_data1_plus_2_target_gene) && nchar(input$Integrate_data1_plus_2_target_gene) != 0) {
            manual_genes <- unlist(strsplit(input$Integrate_data1_plus_2_target_gene, split="\n"))
            p <- p + geom_point(data=df_main_plot[df_main_plot$id %in% manual_genes,],
                color=input$Integrate_data1_plus_2_target_gene_colour, size=input$Integrate_data1_plus_2_highlight_dot_size)
            if (input$Integrate_data1_plus_2_show_gene_name) {
                p <- p + geom_text_repel(data=df_main_plot[df_main_plot$id %in% manual_genes,],
                    color=input$Integrate_data1_plus_2_target_gene_colour, aes(label=id),
                    size=input$Integrate_data1_plus_2_id_size, max.overlaps=20, segment.size=0.2)
            }
        }

        # Axis and theme settings
        p <- p + theme(legend.text=element_text(size=4), legend.title=element_text(size=4)) +
            guides(color=guide_colourbar(barwidth=0.5, barheight=2))
        p <- p + theme(
            axis.text.y=element_text(size=input$Integrate_data1_plus_2_XY_label_size),
            axis.text.x=element_text(size=input$Integrate_data1_plus_2_XY_label_size),
            axis.title.y=element_text(size=input$Integrate_data1_plus_2_XY_title_size),
            axis.title.x=element_text(size=input$Integrate_data1_plus_2_XY_title_size)
        )
        p <- p + theme(panel.grid.major=element_line(linewidth=0.1), panel.grid.minor=element_line(linewidth=0.05))
        p <- p + theme(legend.key.size=unit(0.2, "mm"))
        if (input$Integrate_data1_plus_2_white_background) {
            p <- p + theme(panel.grid=element_blank(), panel.border=element_blank(),
                axis.line=element_line(color='black', linewidth=0.1))
            p <- p + theme(panel.background=element_rect(fill="white", linewidth=0))
            p <- p + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
        }
        p <- p + theme(axis.ticks=element_line(linewidth=0.1), axis.ticks.length=unit(0.5, "pt"))
        if (input$Integrate_data1_plus_2_draw_y_x) {
            p <- p + geom_abline(intercept=0, slope=1, color="black", linetype="dashed", linewidth=0.2)
        }
        if (input$Integrate_data1_plus_2_draw_y_minusx) {
            p <- p + geom_abline(intercept=0, slope=-1, color="black", linetype="dashed", linewidth=0.2)
        }
        p

    }, width=reactive(input$Integrate_data1_plus_2_fig.width), height=reactive(input$Integrate_data1_plus_2_fig.height), res=300)

    # --- [7] Filtered genes table and download --------------------------------

    output$Integrate_data1_plus_2_filtered_status <- renderText({
        "Please set the Data1 and Data2, and set X and Y on the left."
    })
    output$Integrate_data1_plus_2_filtered <- renderDataTable({
        if (length(Integrate_data1_plus_2_plot_filtered()) == 0 ||
            is.null(Integrate_data1_plus_2_plot_filtered()) ||
            nrow(Integrate_data1_plus_2_plot_filtered()) == 0) {
            output$Integrate_data1_plus_2_filtered_status <- renderText({"The genes passed the filtering will be shown here."})
        } else {
            output$Integrate_data1_plus_2_filtered_status <- renderText({NULL})
        }
        datatable(data.frame(Integrate_data1_plus_2_plot_filtered()), options=list(scrollX=TRUE, scrollY=TRUE, pageLength=10))
    })

    output$Integrate_data1_plus_2_filtered_download <- downloadHandler(
        filename=function(){"Integrate_data1_data2_filtered.tsv"},
        content=function(fname){ write.table(Integrate_data1_plus_2_plot_filtered(), fname, sep='\t', row.names=FALSE, quote=FALSE) }
    )

    output$Integrate_data1_plus_2_filtered_gene_list <- renderText({
        if (is.null(Integrate_data1_plus_2_plot_filtered())) return(NULL)
        paste(na.omit(Integrate_data1_plus_2_plot_filtered()$id), collapse="\n")
    })

    # --- [8] Brush-selected area table and download ---------------------------

    output$Integrate_data1_plus_2_selected <- renderDataTable({
        req(data1_plus_data2(), input$Integrate_data1_plus_2_Scat.X, input$Integrate_data1_plus_2_Scat.Y)
        res <- brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush,
            xvar=input$Integrate_data1_plus_2_Scat.X, yvar=input$Integrate_data1_plus_2_Scat.Y)
        datatable(data.frame(res), options=list(scrollX=TRUE, scrollY=TRUE, pageLength=10))
    })

    output$Integrate_data1_plus_2_selected_download <- downloadHandler(
        filename=function(){"Integrate_data1_data2.tsv"},
        content=function(fname){
            write.table(brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush,
                xvar=input$Integrate_data1_plus_2_Scat.X, yvar=input$Integrate_data1_plus_2_Scat.Y),
                fname, sep='\t', row.names=FALSE, quote=FALSE)
        }
    )

    output$Integrate_data1_plus_2_selected_gene_list <- renderText({
        if (is.null(data1_plus_data2())) return(NULL)
        req(input$Integrate_data1_plus_2_Scat.X, input$Integrate_data1_plus_2_Scat.Y)
        res <- brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush,
            xvar=input$Integrate_data1_plus_2_Scat.X, yvar=input$Integrate_data1_plus_2_Scat.Y)
        paste(na.omit(res$id), collapse="\n")
    })
}
