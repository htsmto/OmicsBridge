# =============================================================================
# IntegrateTwoDataset - Side-By-Side View: Plot Rendering
# File: modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_plot.R
# Purpose: Renders the two scatter plots (Data1 and Data2) side-by-side with
#          cross-dataset gene highlighting and threshold line overlays.
# Edit this file when: changing scatter plot appearance, highlighting logic,
#                       threshold line display, or plot axis/label settings.
# =============================================================================

side_by_side_plot_server <- function(input, output, session, df_data1, df_data2, data1_outliers, data2_outliers) {
    # data plot
        # status
            Integrate_data1_plot_status <- reactiveVal(NULL)
            Integrate_data2_plot_status <- reactiveVal(NULL)
            output$Integrate_data1_plot_status <- renderText({ Integrate_data1_plot_status() })
            output$Integrate_data2_plot_status <- renderText({ Integrate_data2_plot_status() })
        #

        # X and Y (data1 and data2)
            Select_x <- function(df_tmp, object_name){
                if(length(df_tmp) == 0 || is.null(df_tmp)){
                    X_axis_name <- c()
                }else{
                    X_axis_name <- colnames(df_tmp)
                }
                selectInput(session$ns(object_name), 'x', c('None'='None', X_axis_name))
            }
            Select_y <- function(df_tmp, object_name){
                if(length(df_tmp) == 0 || is.null(df_tmp)){
                    Y_axis_name <- c()
                }else{
                    Y_axis_name <- colnames(df_tmp)
                }
                selectInput(session$ns(object_name), 'y', c('None'='None', Y_axis_name))
            }

            output$Integrate_data1_Scat.X <- renderUI({ Select_x(df_data1(), 'Integrate_data1_Scat.X') })
            output$Integrate_data2_Scat.X <- renderUI({ Select_x(df_data2(), 'Integrate_data2_Scat.X') })
            output$Integrate_data1_Scat.Y <- renderUI({ Select_y(df_data1(), 'Integrate_data1_Scat.Y') })
            output$Integrate_data2_Scat.Y <- renderUI({ Select_y(df_data2(), 'Integrate_data2_Scat.Y') })
        #

        # show selected gene numbers
            Integrate_data1_selected_gene_num <- reactiveVal(NULL)
            Integrate_data2_selected_gene_num <- reactiveVal(NULL)
            output$Integrate_data1_selected_gene_num <- renderText({ Integrate_data1_selected_gene_num() })
            output$Integrate_data2_selected_gene_num <- renderText({ Integrate_data2_selected_gene_num() })

            show_select_status <- function(method, X_filter, Y_filter, X1, X2, Y1, Y2){
                if(method=='B'){
                    return("Select genes by brushing points on the plot.")
                }else{
                    X_status <- switch(X_filter,
                        "A" = 'X: None; ',
                        "B" = paste0('X > ', X1, '; '),
                        "C" = paste0('X < ', X2, '; '),
                        "D" = paste0('X > ', X2, ' & X < ', X1, '; '),
                        "E" = paste0('X < ', X2, ' | X > ', X1, '; '),
                    )
                    Y_status <- switch(Y_filter,
                        "A" = 'Y: None.',
                        "B" = paste0('Y > ', Y1, '.'),
                        "C" = paste0('Y < ', Y2, '.'),
                        "D" = paste0('Y > ', Y2, ' & Y < ', Y1, '.'),
                        "E" = paste0('Y < ', Y2, ' | Y > ', Y1, '.'),
                    )
                    return(paste0("Select genes by ", X_status, Y_status))
                }
            }

            observe({
                if(length(data1_outliers()) == 0 || is.null(data1_outliers())){
                    Integrate_data1_selected_gene_num("Slected gene numbers: 0\n\n(Please load a dataset, and select the X and Y. \nThen  select genes on the plot.)")
                }else{
                    # show the number of selected genes, the thresholds and the method used for selection can be added in the future.
                    method_and_setting <- show_select_status(input$Integrate_data1_Gene_selection, input$Integrate_data1_thr_X_method, input$Integrate_data1_thr_Y_method, input$Integrate_data1_thr_X1, input$Integrate_data1_thr_X2, input$Integrate_data1_thr_Y1, input$Integrate_data1_thr_Y2)
                    Integrate_data1_selected_gene_num(paste0('Slected gene numbers: ', length(data1_outliers()$id), '\n\n', method_and_setting))
                }
            })

            observe({
                if(length(data2_outliers()) == 0 || is.null(data2_outliers())){
                    Integrate_data2_selected_gene_num("Slected gene numbers: 0\n\n(Please load a dataset, and select the X and Y. \nThen  select genes on the plot.)" )
                }else{
                    method_and_setting <- show_select_status(input$Integrate_data2_Gene_selection, input$Integrate_data2_thr_X_method, input$Integrate_data2_thr_Y_method, input$Integrate_data2_thr_X1, input$Integrate_data2_thr_X2, input$Integrate_data2_thr_Y1, input$Integrate_data2_thr_Y2)
                    Integrate_data2_selected_gene_num(paste0('Slected gene numbers: ', length(data2_outliers()$id), '\n\n', method_and_setting))
                }
            })

        #

        # function for the scatter plot
            plot_scatter_plot <- function(df_main_plot, Selected_x, Selected_y, outliers, mapped_thr_X, mapped_thr_Y, highligh_colour, show_label, plot_size, highlight_plot_size, highlight_label_size  ){
                # when the data is not loaded
                if(length(Selected_x) ==0 || length(Selected_y) == 0 || Selected_x == 'None' ||Selected_y == 'None'){
                    return(ggplot())

                }else{
                    p <- ggplot(df_main_plot, aes(x = .data[[Selected_x]], y = .data[[Selected_y]])) + geom_point(size = plot_size)

                    # highlight the selected genes on the plot
                    if(!is.null(outliers)){
                        p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% outliers$id,], color=highligh_colour , size = highlight_plot_size)

                        # show labels of selected genes
                        if(show_label==1){
                            p <- p + geom_text_repel(data =  df_main_plot[df_main_plot$id %in% outliers$id,],  color = highligh_colour, aes(label = id), size = highlight_label_size, segment.size=0.2, max.overlaps=60)
                        }
                    }
                }
                p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p
            }

        #

        # plot1
            output$Integrate_data1_plot <- renderPlot({

                if(length(input$Integrate_data1_Scat.X) == 0 || length(input$Integrate_data1_Scat.Y) ==0||  input$Integrate_data1_Scat.X == 'None' || input$Integrate_data1_Scat.Y == 'None'){
                    Integrate_data1_plot_status("Please select a dataset, X and Y.")
                    return(ggplot())
                }else{
                    Integrate_data1_plot_status(NULL)
                    if(input$Integrate_data_map_direction == 'A'){
                        # data1 is the main plot, data2 is the mapped plot
                        if(input$Integrate_data1_hide_labels){
                            p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                        }else{
                            p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                        }

                        # add threshold lines for data1
                        if(input$Integrate_data1_Gene_selection == 'A' & !input$Integrate_data1_hide_threshold){
                            if(length(input$Integrate_data1_thr_X_method)==0 || length(input$Integrate_data1_thr_Y_method)==0){
                                Integrate_data1_plot_status({"Please check the filtering method is correctly set. Choose one from 'X,Y filter'."})
                                return(ggplot())
                            }
                            switch(input$Integrate_data1_thr_X_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', linewidth=0.2),
                            )
                            switch(input$Integrate_data1_thr_Y_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', linewidth=0.2),
                            )
                        }
                    }else { # data2 is the main plot, data1 is the mapped plot
                        # if the mapped plot has no X or Y, then no genes can be selected on the main plot, and no genes will be highlighted on the main plot.
                        if(input$Integrate_data2_Scat.X == 'None' | input$Integrate_data2_Scat.Y == 'None'){
                            if(input$Integrate_data1_hide_labels){
                                p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                            }else{
                                p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                            }

                        }else{
                            df_tmp <- switch(input$Integrate_data_mapped_thr_X_method,
                                "A" = data2_outliers(),
                                "B" = data2_outliers()[data2_outliers()$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X1, ]$id, ],
                                "C" = data2_outliers()[data2_outliers()$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X2, ]$id, ],
                                "D" = data2_outliers()[data2_outliers()$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X2 & df_data1()[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X1, ]$id, ],
                                "E" = data2_outliers()[data2_outliers()$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X2 | df_data1()[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X1, ]$id, ],
                            )
                            df_tmp <- switch(input$Integrate_data_mapped_thr_Y_method,
                                "A" = df_tmp,
                                "B" = df_tmp[df_tmp$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ]$id, ],
                                "C" = df_tmp[df_tmp$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y2, ]$id, ],
                                "D" = df_tmp[df_tmp$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y2 & df_data1()[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y1, ]$id, ],
                                "E" = df_tmp[df_tmp$id %in% df_data1()[df_data1()[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y2 | df_data1()[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ]$id, ],
                            )
                            if(input$Integrate_data1_hide_labels){
                                p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, df_tmp, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                            }else{
                                p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, df_tmp, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)
                            }
                            if(!input$Integrate_data_mapped_hide_threshold){
                                switch(input$Integrate_data_mapped_thr_X_method,
                                    'A' = p <- p,
                                    'B' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2),
                                    'C' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                    'D' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                    'E' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                )
                                switch(input$Integrate_data_mapped_thr_Y_method,
                                    'A' = p <- p,
                                    'B' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2),
                                    'C' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                    'D' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                    'E' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                )
                            }
                        }
                    }
                    p <- p + theme(axis.text = element_text(size = input$Integrate_data1_label.font.size), axis.title = element_text(size = input$Integrate_data1_title.font.size))
                    if(input$Integrate_data1_while_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p
                }
            }, width=reactive(input$Integrate_data1_fig.width), height=reactive(input$Integrate_data1_fig.height), res=300)
        #

        # plot2
            output$Integrate_data2_plot <- renderPlot({
                if(length(input$Integrate_data2_Scat.X) == 0 || length(input$Integrate_data2_Scat.Y)==0 || input$Integrate_data2_Scat.X == 'None' ||  input$Integrate_data2_Scat.Y== 'None'){
                    Integrate_data2_plot_status("Please select a dataset, X and Y.")
                    return(ggplot())
                }else{
                    Integrate_data2_plot_status(NULL)

                    if(input$Integrate_data_map_direction == 'A'){
                        if(input$Integrate_data1_Scat.X == 'None' | input$Integrate_data1_Scat.Y == 'None'){
                            if(input$Integrate_data2_hide_labels){
                                p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                            }else{
                                p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                            }

                        }else{
                            df_tmp <- switch(input$Integrate_data_mapped_thr_X_method,
                                "A" = data1_outliers(),
                                "B" = data1_outliers()[data1_outliers()$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1, ]$id, ],
                                "C" = data1_outliers()[data1_outliers()$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2, ]$id, ],
                                "D" = data1_outliers()[data1_outliers()$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X2 & df_data2()[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X1, ]$id, ],
                                "E" = data1_outliers()[data1_outliers()$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2 | df_data2()[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1, ]$id, ],
                            )
                            df_tmp <- switch(input$Integrate_data_mapped_thr_Y_method,
                                "A" = df_tmp,
                                "B" = df_tmp[df_tmp$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ]$id, ],
                                "C" = df_tmp[df_tmp$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2, ]$id, ],
                                "D" = df_tmp[df_tmp$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y2 & df_data2()[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y1, ]$id, ],
                                "E" = df_tmp[df_tmp$id %in% df_data2()[df_data2()[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2 | df_data2()[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ]$id, ],
                            )
                            if(input$Integrate_data2_hide_labels){
                                p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, df_tmp, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                            }else{
                                p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, df_tmp, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                            }
                            if(!input$Integrate_data_mapped_hide_threshold){
                                switch(input$Integrate_data_mapped_thr_X_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', linewidth=0.2),
                                )
                                switch(input$Integrate_data_mapped_thr_Y_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', linewidth=0.2),
                                )
                            }
                        }
                    } else {
                        if(input$Integrate_data2_hide_labels){
                            p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                        }else{
                            p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size)
                        }
                        if(input$Integrate_data2_Gene_selection == 'A' & !input$Integrate_data2_hide_threshold){
                            if(length(input$Integrate_data2_thr_X_method)==0 | length(input$Integrate_data2_thr_Y_method)==0 ){
                                output$Integrate_data1_plot_status <- renderText({"Please select one from 'X/Y filter'."})
                                return(NULL)
                            }
                            switch(input$Integrate_data2_thr_X_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', linewidth=0.2) + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', linewidth=0.2),
                            )
                            switch(input$Integrate_data2_thr_Y_method,
                                'A' = p <- p,
                                'B' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', linewidth=0.2),
                                'C' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', linewidth=0.2),
                                'D' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', linewidth=0.2),
                                'E' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', linewidth=0.2) + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', linewidth=0.2),
                            )
                        }
                    }
                    p <- p + theme(axis.text = element_text(size = input$Integrate_data2_label.font.size), axis.title = element_text(size = input$Integrate_data2_title.font.size))
                    if(input$Integrate_data2_while_background){
                        p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p
                }
            }, width=reactive(input$Integrate_data2_fig.width), height=reactive(input$Integrate_data2_fig.height), res=300)
        #

    #
}
