# =============================================================================
# scRNA - Feature UMAP Server
# File: modules/scRNA/02_02_01_scRNA_Feature_umap_server.R
# Purpose: Renders a UMAP coloured by expression of one or more selected genes
#          using Seurat's FeaturePlot. Splits multi-gene views into panel grids.
# Edit this file when: changing FeaturePlot options (colour scale, point size,
#                       blend mode) or layout of multi-gene grids.
# =============================================================================

scRNA_Feature_server_umap  <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
    ## status
        # status object
            scRNA_FeaturePlot_status_plot <- reactiveVal(NULL)
            output$scRNA_FeaturePlot_status_plot <- renderText({ scRNA_FeaturePlot_status_plot() })
            
    ## Plot a umap plot
        # function for showing one gene's expression
            gene_expression_map <- function(ex, umap, gene){
                # check if the gene is in the dataset 
                if(gene %in% rownames(ex)){
                    gene_exist_flag <- TRUE
                    ex_gene <- ex[gene,]

                    # make a table
                    gene_ex_data <- data.frame(umap, ex_gene)
                    colnames(gene_ex_data) <- c("UMAP_1","UMAP_2","Gene" )

                    # scatter plot  
                    p1 <- ggplot(gene_ex_data,aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=gene_ex_data[gene_ex_data$Gene == 0,] , size = input$scRNA_FeaturePlot_dot_size_bg, color= input$scRNA_FeaturePlot_zero_colour)
                    p1 <- p1 + geom_point(data=gene_ex_data[gene_ex_data$Gene > 0,] , size = input$scRNA_FeaturePlot_dot_size, aes(color= Gene))

                }else{ # if not, return a plot with only the UMAP but no gene expression shown.
                    gene_exist_flag <- FALSE
                    p1 <- ggplot()
                }
                return(list(p1 = p1, gene_exist_flag = gene_exist_flag))
            }    

        #

        # update the expression and the umap matrix
            Seurat_ex <- reactiveVal(NULL)
            Seurat_umap <- reactiveVal(NULL)        
            observe({
                if(!is.null(Seurat_object())){
                    Seurat_ex(GetAssayData(object = Seurat_object(), assay = "RNA", layer = "data"))
                    Seurat_umap(as.data.frame(Seurat_object()@reductions$umap@cell.embeddings))
                }
            })

        # draw UMAP (gene expression feature map)
            output$scRNA_FeaturePlot_plot <- renderPlot({
                if(!is.null(Seurat_object())){
                    Seurat_object <- Seurat_object()

                    if(Input_is_ready() == 0){ # input is not ready at all
                        scRNA_FeaturePlot_status_plot('A feature plot will be displayed here. Please input the gene(s).')
                        return(ggplot())
                    }

                    # Get the gene list to be plotted
                    if(Input_is_ready() == 1){ # the gene is inputted manually
                        target_gene_for_scRNA_featurePlot <- gene_list_mannual()
                    }else if(Input_is_ready() == 2){ # the gene is from custom geneset
                        target_gene_for_scRNA_featurePlot <- gene_list_custom()
                    }

                    # if no gene is selected in the table
                    if(length(input$scRNA_FeaturePlot_gene_table_rows_selected) == 0){
                        scRNA_FeaturePlot_status_plot('Please select a gene from the table to show its feature plot.')
                        return(ggplot())
                    }

                    # get the selected gene
                    gene <- target_gene_for_scRNA_featurePlot[input$scRNA_FeaturePlot_gene_table_rows_selected]
                    
                    # draw the feature plot for the selected gene
                    res <- gene_expression_map(Seurat_ex(), Seurat_umap(), gene)
                    if(res$gene_exist_flag == TRUE){
                        scRNA_FeaturePlot_status_plot(NULL)
                        p1 <- res$p1
                    }else{
                        scRNA_FeaturePlot_status_plot(paste0("The gene ", gene, " is not found in the dataset. Please check the gene name and try again or select another gene."))
                        return(ggplot())
                    }
                }else{
                    # when not data is selected or the Seurat object is not loaded successfully, show status messages and an empty plot.
                    scRNA_FeaturePlot_status_plot('Please select a dataset first')
                    return(ggplot())
                }

                # plot settings
                p1 <- p1 + scale_color_gradient(low  = input$scRNA_FeaturePlot_lowest_colour, high = input$scRNA_FeaturePlot_highest_colour)
                p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_FeaturePlot_XY_label.font.size), axis.title = element_text(size=input$scRNA_FeaturePlot_XY_title.font.size))
                p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_FeaturePlot_legend_size), legend.title = element_text(size=input$scRNA_FeaturePlot_legend_size))
                p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_FeaturePlot_graph.title.font.size)) 
                p1 <- p1 + ggtitle(gene)
                p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p1 <- p1 + theme(legend.key.size = unit(2, "mm"))
                if(input$scRNA_FeaturePlot_white_background){
                    p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                    p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
                    p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                }
                p1
            }, width=reactive(input$scRNA_FeaturePlot_fig.width), height=reactive(input$scRNA_FeaturePlot_fig.height), res=300)
        #

    ##


}