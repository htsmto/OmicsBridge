# =============================================================================
# scRNA - UMAP Plot Server
# File: modules/scRNA/02_01_scRNA_UMAP_server.R
# Purpose: Loads the selected Seurat object from disk (ReadRDS) and renders
#          a UMAP coloured by cluster identity, cell type, or a metadata column.
#          Returns the loaded Seurat object as a reactive value consumed by
#          all Feature sub-servers.
# Edit this file when: changing the UMAP reduction used (umap vs tsne),
#                       the colour scheme, or how the Seurat object is loaded.
# Libraries required: Seurat (loaded via app.R before this module is called)
# =============================================================================

scRNA_UMAP_server  <- function(input, output, session, Dataset) {
    ## Data loading
        # database
            # Dataset <- data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE))

        # Umap plot / status
            scRNA_UMAP1_status <- reactiveVal('A Umap plot of the selected dataset will be shown here.')
            scRNA_UMAP1_groupBy_status <- reactiveVal(NULL)
            selected_dataset <- reactiveVal(NULL)
            Seurat_object <- reactiveVal(NULL)

        # flag
            isSelected <- reactiveVal(FALSE)
            DataLoading <- reactiveVal(FALSE)

        # umap
            ggplot_umap <- reactiveVal(NULL)

        # data selection
            observe({
                if(!is.null(input$scRNA_data_select) && input$scRNA_data_select != 'None'){
                    selected_dataset(input$scRNA_data_select)
                }else{
                    selected_dataset(NULL)
                }
            })

        # data loading
            # if 'None' is selected, reset everything. Otherwise, try loading the data of the selected dataset.
            observeEvent(is.null(selected_dataset()) || selected_dataset() == 'None', {
                # reset
                isSelected(FALSE)
                DataLoading(FALSE)
                scRNA_UMAP1_status('A Umap plot of the selected dataset will be shown here.')
                scRNA_UMAP1_groupBy_status(NULL)
                Seurat_object(NULL)
                ggplot_umap(NULL)
            })

            # when a dataset is selected
            observeEvent(selected_dataset(), {
                # flag
                isSelected(TRUE)
                DataLoading(TRUE)
                selected_dataset <- selected_dataset()

                # if the file is not found, show an error message and reset the flag.
                filepath <- Dataset()[Dataset()$Dataset == selected_dataset, ]$Path
                if(!file.exists(filepath)){
                    scRNA_UMAP1_status(paste0('Error: The file for the selected dataset (', selected_dataset, ') is not found. \nPlease check the file path and try again.'))
                    DataLoading(FALSE)
                    return(NULL)
                }

                # try loading scRNA from a RDS file. If there is an error, show an error message and reset the flag.
                tryCatch({
                    scRNA_UMAP1_status(NULL)
                    DataLoading(FALSE)
                    Seurat_object(readRDS(filepath))
                    return(NULL)
                }, error = function(e){
                    scRNA_UMAP1_status(paste0('Error: Failed to load the file for the selected dataset (', selected_dataset, '). \nPlease check if the file is a valid RDS file and try again.'))
                    DataLoading(FALSE)
                    return(NULL) 
                })
 
            })

        # show status
            output$scRNA_UMAP1_status <- renderText({ scRNA_UMAP1_status() })
            output$scRNA_UMAP1_groupBy_status <- renderText({ scRNA_UMAP1_groupBy_status() })

    ##

    ## UMAP plot
        # select group.by
            output$scRNA_UMAP1_groupBy <- renderUI({
                Seurat_obj <- Seurat_object()
                
                # check if Seurat object is loaded
                if(!is.null(Seurat_obj)){
                    meta <- Seurat_obj@meta.data
                    selectInput(session$ns('scRNA_UMAP1_groupBy'), 'Colour by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
                }else{
                    selectInput(session$ns('scRNA_UMAP1_groupBy'), 'Colour by:', c('--Select a dataset first--'='None') )
                }
            })

        # when highlighting a specific group
            output$scRNA_UMAP1_highlight_group_select <- renderUI({
                Seurat_obj <- Seurat_object()

                # check if Seurat object is loaded
                if(!is.null(Seurat_obj)){

                    # check if group.by is selected
                    if(!is.null(input$scRNA_UMAP1_highlight_group)){
                        if(input$scRNA_UMAP1_groupBy != 'None'){
                            if( length(unique(Seurat_obj@meta.data[,input$scRNA_UMAP1_groupBy])) > 100 ){ # when the number of groups is larger than 100, do not show the group selection dropdown to avoid performance issue. 
                                selectInput(session$ns('scRNA_UMAP1_highlight_group_select'), 'Select the highlighted group:', c('--Set the "Colour by" option--'='None') )
                            }else{
                                # get the categoies of the selected group.by variable to show in the dropdown. 
                                meta <- Seurat_obj@meta.data
                                groups <- as.character(meta[,input$scRNA_UMAP1_groupBy])
                                
                                # when the groups can be converted to numeric, sort them as numeric. Otherwise, sort them as character.
                                suppressWarnings({
                                    groups_vals <- as.numeric(groups) 
                                })
                                if(all(!is.na(groups_vals))){
                                    groups <- sort(unique(groups_vals))
                                }else{
                                    groups <- sort(unique(groups))
                                }

                                # set the choices
                                selectInput(session$ns('scRNA_UMAP1_highlight_group_select'), 'Select the highlighted group:', c('None'='None', groups) )
                            }
                        }else{
                            selectInput(session$ns('scRNA_UMAP1_highlight_group_select'), 'Select the highlighted group:', c('--Set the "Colour by" option--'='None') )
                        }
                    }else{
                        selectInput(session$ns('scRNA_UMAP1_highlight_group_select'), 'Select the highlighted group:', c('--Set the "Colour by" option--'='None') )
                    }
                }else{
                    selectInput(session$ns('scRNA_UMAP1_highlight_group_select'), 'Select the highlighted group:', c('--Select a dataset first--'='None') )
                }
            })

        # umap object
            observe({
                # data should be loaded
                if(is.null(Seurat_object())){
                    ggplot_umap(NULL)
                    return(NULL)
                }

                # get umap tmp data
                Seurat_obj <- Seurat_object()

                # when no group.by variable is selected, just show the original UMAP plot. Colour is gray.
                if(is.null(input$scRNA_UMAP1_groupBy) || input$scRNA_UMAP1_groupBy == 'None'){
                    p_tmp <- DimPlot(Seurat_obj,reduction = "umap")

                    # show a gray plot
                    scRNA_UMAP1_status('Please select a grouping variable to colour the UMAP plot. ("Colour by" option)')
                    p1 <- ggplot(p_tmp$data, aes(x = .data[[colnames(p_tmp$data)[1]]], y = .data[[colnames(p_tmp$data)[2]]]))
                    p1 <- p1+ geom_point(color='#827f7f', size=input$scRNA_umap1_graph_dot_size)
                    
                }else if( length(unique(Seurat_obj@meta.data[,input$scRNA_UMAP1_groupBy])) > 60 ){ # when there are too many categories in the selected group
                    scRNA_UMAP1_status("Too many categories in the selected group. Probably this is not a categorical variable. Please select another group.")
                    scRNA_UMAP1_groupBy_status("Too many categories in the selected group. Probably this is not a categorical variable.  \nPlease select another group.")
                    p1 <- ggplot(p_tmp$data, aes(x = .data[[colnames(p_tmp$data)[1]]], y = .data[[colnames(p_tmp$data)[2]]]))
                    p1 <- p1+ geom_point(color='#827f7f', size=input$scRNA_umap1_graph_dot_size)
                    
                }else{
                    # if it is okay
                    scRNA_UMAP1_status(NULL)
                    p_tmp <- DimPlot(Seurat_obj,reduction = "umap",group.by = c(input$scRNA_UMAP1_groupBy))

                    # if highlight a specific group
                    if(input$scRNA_UMAP1_highlight_group){
                        
                        # when no group is selected
                        if(length(input$scRNA_UMAP1_highlight_group_select) == 0 || input$scRNA_UMAP1_highlight_group_select == 'None'){
                            scRNA_UMAP1_groupBy_status('Please select a group to highlight.')
                            p1 <- ggplot(p_tmp$data, aes(x = .data[[colnames(p_tmp$data)[1]]], y = .data[[colnames(p_tmp$data)[2]]]))
                            p1 <- p1+ geom_point(color='#827f7f', size=input$scRNA_umap1_graph_dot_size)
                            
                        }else{ # when a group is selected
                            scRNA_UMAP1_groupBy_status(NULL)
                            p_tmp_data <- p_tmp$data
                            p_tmp_data$col <- ifelse(p_tmp_data[,colnames(p_tmp_data)[3]] == input$scRNA_UMAP1_highlight_group_select, input$scRNA_UMAP1_highlight_group_highlight, input$scRNA_UMAP1_highlight_group_background)
                            p1 <- ggplot(p_tmp_data, aes(x = .data[[colnames(p_tmp_data)[1]]], y = .data[[colnames(p_tmp_data)[2]]]))
                            p1 <- p1 + geom_point(size=input$scRNA_umap1_graph_dot_size, aes(color=col), data=p_tmp_data[p_tmp_data$col == input$scRNA_UMAP1_highlight_group_background,])
                            p1 <- p1 + geom_point(size=input$scRNA_umap1_graph_dot_size, aes(color=col), data=p_tmp_data[p_tmp_data$col == input$scRNA_UMAP1_highlight_group_highlight,]) + scale_color_identity()
                            p1 <- p1 + ggtitle(paste0(input$scRNA_UMAP1_groupBy, ' – ', input$scRNA_UMAP1_highlight_group_select))
                        }
                    }else{
                        scRNA_UMAP1_groupBy_status(NULL)
                        p1 <- ggplot(p_tmp$data, aes(x = .data[[colnames(p_tmp$data)[1]]], y = .data[[colnames(p_tmp$data)[2]]], color = .data[[colnames(p_tmp$data)[3]]])) + geom_point(size=input$scRNA_umap1_graph_dot_size)
                    }

                }


                # other settings
                p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap1_XY_label), axis.title = element_text(size=input$scRNA_umap1_XY_title))
                p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap1_legend_size), legend.title = element_text(size=input$scRNA_umap1_legend_size))
                p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap1_graph_title)) 
                p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p1 <- p1 + theme(legend.key.size=unit(0.01, 'mm'))

                # white background
                if(input$scRNA_umap1_white_background){
                    p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                    p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
                    p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                }                

                # update reactive value
                ggplot_umap(p1)
            })

        # render UMAP plot
            output$scRNA_UMAP1 <- renderPlot({
                # when data is loading
                if(DataLoading()){
                    return(ggplot())
                }else{
                    if(is.null(ggplot_umap())){
                        return(ggplot())
                    }else{
                        return(ggplot_umap())
                    }
                }
            },  width=reactive(input$scRNA_umap1_fig.width), height=reactive(input$scRNA_umap1_fig.height), res=300)
    ##

    ## export an Seurat object
        return(Seurat_object)

    ##
}
