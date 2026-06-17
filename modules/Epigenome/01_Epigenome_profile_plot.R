# =============================================================================
# Epigenome - Profile Plot: Plot
# File: modules/Epigenome/01_Epigenome_profile_plot.R
# Purpose: EnrichedHeatmap rendering. Consumes reactive values from the data
#          sub-module (heatmap_data_list, isCalculating).
# Edit this file when: changing the profile plot style, colour scale,
#                       annotation layout, or adding a download handler.
# =============================================================================

epigenome_profile_plot_server <- function(input, output, session, heatmap_data_list, isCalculating) {

    ## Plot
        # plot
            output$Profile_Plot_Plot <- renderPlot({
                if (isCalculating()) {
                    return(ggplot())
                }

                else{

                    if(is.null(heatmap_data_list())){
                        return(ggplot())
                    }


                    else{
                        heatmap_data_list <- heatmap_data_list()

                        col_fun <- colorRamp2(breaks = c(0, max(unlist(lapply(heatmap_data_list, function(x) quantile(x,0.98))))), colors=c(input$Profile_Plot_min_col, input$Profile_Plot_max_col))

                        # grid の新規ページを作成（これがないと描画されない可能性あり）
                        grid.newpage()

                        # Main heatmap legend (The one on the right)
                        coverage_legend <- Legend(
                            col_fun = col_fun, title = "Norm.Coverage",
                            title_gp = grid::gpar(fontsize=input$Profile_Plot_legend_font_size ),
                            labels_gp = grid::gpar(fontsize=input$Profile_Plot_legend_font_size ) ,
                            legend_height = grid::unit( (5 + 0.1 * input$Profile_Plot_legend_font_size) , "mm"),
                            legend_width = grid::unit(input$Profile_Plot_legend_font_size, 'mm')
                        )

                        # ヒートマップ作成
                        ymax <- max(sapply(heatmap_data_list, function(x) {
                            max(colMeans(x, na.rm = TRUE))  # or another summary stat depending on your data
                        }))
                        top_anno <- HeatmapAnnotation(
                            enriched = anno_enriched(
                                gp = gpar(col = input$Profile_Plot_line_col),
                                pos_line_gp = gpar(lwd=0.5,lty = 2),
                                axis_param = list(
                                    gp = grid::gpar(fontsize = input$Profile_Plot_label_size_up)
                                ),
                                ylim = c(0, ymax)
                            ),
                            show_annotation_name = FALSE,
                            height=unit(input$Profile_Plot_top_annot_height , 'cm')
                        )
                        heatmaps <- lapply(seq_along(heatmap_data_list), function(i) {
                            EnrichedHeatmap(
                                heatmap_data_list[[i]],
                                column_title = gsub("(.{10})", "\\1\n", names(heatmap_data_list)[i]),
                                pos_line_gp = gpar(lwd = 0.5,lty = 2),
                                col = col_fun, use_raster = TRUE,
                                show_heatmap_legend = FALSE,
                                column_title_gp = grid::gpar(fontsize = input$Profile_Plot_column_font_size),
                                axis_name_gp = grid::gpar(fontsize = input$Profile_Plot_label_size_main),
                                top_annotation = top_anno
                                # border_gp = gpar(lwd=20)
                            )
                        })
                        # output$Profile_Plot_status <- renderText({'test3'})

                        # heatmapsが空でないことを確認
                        if(length(heatmaps) == 0){
                            Profile_Plot_status('error')
                            return(ggplot())
                        }else{
                            # output$Profile_Plot_status <- renderText({NULL})

                            # 複数のヒートマップを組み合わせる
                            p <- Reduce("+", heatmaps)

                            # grid.draw() を使って描画
                            draw(
                                p,  annotation_legend_side = "top",
                                heatmap_legend_list = list(coverage_legend), heatmap_legend_side = "right"
                            )
                        }
                    }
                }
            }, width = reactive(input$Profile_Plot_fig.width), height = reactive(input$Profile_Plot_fig.height), res=300)
        #
    ##
}
