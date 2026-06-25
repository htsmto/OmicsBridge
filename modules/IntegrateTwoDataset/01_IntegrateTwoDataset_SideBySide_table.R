# =============================================================================
# IntegrateTwoDataset - Side-By-Side View: Result Table & Download
# File: modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_table.R
# Purpose: Builds the merged Data1+Data2 table, computes the overlapping gene
#          table after mapped-side threshold filtering, renders the DT output,
#          provides the download handler, and lists gene names as text.
# Edit this file when: changing merge logic, overlap filtering, table columns,
#                       download format, or the gene-list text output.
# =============================================================================

side_by_side_table_server <- function(input, output, session, df_data1, df_data2, data1_outliers, data2_outliers) {
    # table
        # plot1 + plot2 table
            data1_plus_data2 <- reactiveVal(NULL)
            observe({
                # data should be loaded for both datasets
                    if(length(df_data1()) == 0 || length(df_data2()) == 0 || is.null(df_data1()) || is.null(df_data2())){
                        data1_plus_data2(NULL)
                        return(NULL)
                    }

                #
                    df1 <- df_data1()
                    df2 <- df_data2()
                    colnames(df1) <- paste0('Data1_', colnames(df1))
                    colnames(df2) <- paste0('Data2_', colnames(df2))
                    colnames(df1) <- gsub('Data1_id', 'id', colnames(df1))
                    colnames(df2) <- gsub('Data2_id', 'id', colnames(df2))
                    df_tmp <- merge(df1, df2, by='id')
                    data1_plus_data2(df_tmp)
                    return(NULL)

            })
        #

        # get the overlapped gene table
            Integrate_Overlapped_gene_table_tmp <- reactiveVal(NULL)
            observe({
                # genes from the mapping side
                    if(input$Integrate_data_map_direction == 'A'){
                        if(length(data1_outliers()) == 0 || is.null(data1_outliers())){
                            Integrate_Overlapped_gene_table_tmp(NULL)
                            return(NULL)
                        }
                        gene_from_mapping_side <- data1_outliers()$id
                        df_tmp <- df_data2()[df_data2()$id %in% gene_from_mapping_side,] # take the genes in the mapped side for further filtering
                    }else{
                        if(length(data2_outliers()) == 0 || is.null(data2_outliers())){
                            Integrate_Overlapped_gene_table_tmp(NULL)
                            return(NULL)
                        }
                        gene_from_mapping_side <- data2_outliers()$id
                        df_tmp <- df_data1()[df_data1()$id %in% gene_from_mapping_side,] # take the genes in the mapped side for further filtering
                    }
                #

                # both datasets' x/y axes must be selected before the overlap table can be built
                # (right after a dataset is (re)selected, its x/y selectors briefly default to 'None')
                    axis_selections <- c(input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y)
                    if(length(axis_selections) < 4 || any(axis_selections == 'None')){
                        Integrate_Overlapped_gene_table_tmp(NULL)
                        return(NULL)
                    }
                #

                # apply the filtering in the mapped side
                    df_tmp <- switch(input$Integrate_data_mapped_thr_X_method,
                        "A" = df_tmp,
                        "B" = df_tmp[df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1, ],
                        "C" = df_tmp[df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2, ],
                        "D" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X2) & (df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X1), ],
                        "E" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2) | (df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1), ],
                    )
                    df_tmp <- switch(input$Integrate_data_mapped_thr_Y_method,
                        "A" = df_tmp,
                        "B" = df_tmp[df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ],
                        "C" = df_tmp[df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2, ],
                        "D" = df_tmp[(df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y2) & (df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y1), ],
                        "E" = df_tmp[(df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2) | (df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1), ],
                    )
                    overlapped_gene <- df_tmp$id
                #

                # extract the overlapped gene table
                    df_overlapped_gene_tmp <- data1_plus_data2()[data1_plus_data2()$id %in% overlapped_gene,]
                    columns <- c('id', paste0('Data1_', input$Integrate_data1_Scat.X), paste0('Data1_', input$Integrate_data1_Scat.Y), paste0('Data2_', input$Integrate_data2_Scat.X), paste0('Data2_', input$Integrate_data2_Scat.Y))
                    df_overlapped_gene_tmp <- df_overlapped_gene_tmp[, columns]
                    Integrate_Overlapped_gene_table_tmp(df_overlapped_gene_tmp)


            })

        #

        # display the table
            Integrate_Overlapped_gene_table_status <- reactiveVal(NULL)
            output$Integrate_Overlapped_gene_table_status <- renderText({Integrate_Overlapped_gene_table_status()})
            output$Integrate_Overlapped_gene_table <- renderDataTable({
                # when nothing to show
                    if(length(Integrate_Overlapped_gene_table_tmp()) == 0 || is.null(Integrate_Overlapped_gene_table_tmp())){
                        output$Integrate_Overlapped_gene_table_status <- renderText({'Please set up the threshold of Data1 and Data2 above first.'})
                        return(NULL)
                    }
                #

                # there is a table but no genes in the table
                    if(dim(Integrate_Overlapped_gene_table_tmp())[1]==0){
                        Integrate_Overlapped_gene_table_status('No overlap genes. Please change the thrshold.')
                        return(NULL)
                    }else{
                        Integrate_Overlapped_gene_table_status(NULL)
                        datatable( data.frame(Integrate_Overlapped_gene_table_tmp()),  options = list(scrollX = TRUE, pageLength = 10), rownames=FALSE)
                    }
                #

            })
        #

        # Download the integrated table
            output$Integrate_Overlapped_gene_table_download <- downloadHandler(
                filename = function(){"Overlap_filtered_gene_data1_and_data2.tsv"},
                content = function(fname){ write.table(Integrate_Overlapped_gene_table_tmp(), fname, sep='\t', quote=F) }
            )
        #

        # list up the gene names
            output$Integrate_Overlapped_gene_list <- renderText({
                if(length(Integrate_Overlapped_gene_table_tmp()) == 0 || is.null(Integrate_Overlapped_gene_table_tmp())){
                    return('Please set up the threshold of Data1 and Data2 above first.')
                }else if(dim(Integrate_Overlapped_gene_table_tmp())[1]==0){
                    return('No overlap genes. Please change the thrshold.')
                }else {
                    paste(na.omit(Integrate_Overlapped_gene_table_tmp()$id), collapse = "\n")
                }
            })
        #

    #

    ## return data1_plus_data2 for downstream consumers
        return(data1_plus_data2)
    ##
}
