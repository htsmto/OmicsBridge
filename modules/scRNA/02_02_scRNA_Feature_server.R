# =============================================================================
# scRNA - Feature Input Server
# File: modules/scRNA/02_02_scRNA_Feature_server.R
# Purpose: Handles gene list input for all Feature sub-servers (manual text
#          or custom gene set). Returns the gene list and a flag indicating
#          whether input is valid. Shared by UMAP, Violin, Dot, Pie, AUC.
# Edit this file when: changing how gene lists are validated or how custom
#                       gene sets are parsed for scRNA visualisation.
# =============================================================================

scRNA_Feature_server  <- function(input, output, session, Custom_genesets) {
    ## status
        # status object
            scRNA_FeaturePlot_status_gene_input <- reactiveVal('Please input a gene name.')
            scRNA_FeaturePlot_status_plot <- reactiveVal(NULL)

        # show status
            output$scRNA_FeaturePlot_status_gene_input <- renderText({ scRNA_FeaturePlot_status_gene_input() })
            output$scRNA_FeaturePlot_status_plot <- renderText({ scRNA_FeaturePlot_status_plot() })

    ##

    ## initial variables
        # Seurat_object is loaded from an upper server function
        gene_list_mannual <- reactiveVal(NULL)
        gene_list_custom <- reactiveVal(NULL)
        Input_is_ready <- reactiveVal(0) # 0: no input, 1: manual gene input, 2: custom geneset gene input
        Seurat_ex <- reactiveVal(NULL)
        Seurat_umap <- reactiveVal(NULL)
    ## 

    ## Input genes setting
        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$scRNA_FeaturePlot_gene <- renderUI({ textAreaInput(session$ns("scRNA_FeaturePlot_gene"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset) > 0 && input$scRNA_FeaturePlot_gene_from_custom_geneset == TRUE){
                    shinyjs::disable("scRNA_FeaturePlot_gene")
                } else {
                    shinyjs::enable("scRNA_FeaturePlot_gene")
                }
            })

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$scRNA_FeaturePlot_gene_from_custom_geneset_select <- renderUI({
                if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset) > 0 && input$scRNA_FeaturePlot_gene_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets$Geneset.name)
                    selectInput(session$ns('scRNA_FeaturePlot_gene_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })
        
        # show the list of the genes in a table  (scRNA_FeaturePlot_gene_table)
            # manually inputted genes
                observe({
                    if(length(input$scRNA_FeaturePlot_gene) > 0){
                        # This work only when the user choose to input gene manually
                        if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset) == 0 || input$scRNA_FeaturePlot_gene_from_custom_geneset == FALSE){
                            # when nothing is inputted or the genes names are just spaces (' ')
                            if(all(grepl("^\\s*$", input$scRNA_FeaturePlot_gene))){
                                scRNA_FeaturePlot_status_gene_input('Please enter gene names in the box above, one gene per line.')
                                gene_list_mannual(NULL)
                                return(NULL)
                            }

                            # when there are gene names inputted
                            genes_tmp <- unique(unlist(strsplit(input$scRNA_FeaturePlot_gene, split="\n")))
                            genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                            gene_list_mannual(genes_tmp)
                            scRNA_FeaturePlot_status_gene_input(paste0("You have manually input ", length(gene_list_mannual()), " gene(s)."))
                        }
                    }
                })

            # genes from custom geneset
                observe({
                    if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset) > 0 && input$scRNA_FeaturePlot_gene_from_custom_geneset == TRUE){
                        if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset_select) == 0 || input$scRNA_FeaturePlot_gene_from_custom_geneset_select == 'None'){
                            scRNA_FeaturePlot_status_gene_input("Please select a custom geneset above first.")
                            gene_list_custom(NULL)
                            return(NULL)
                        }else{
                            genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$scRNA_FeaturePlot_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                            gene_list_custom(genes)
                            scRNA_FeaturePlot_status_gene_input(paste0("You have input ", length(gene_list_custom()), " gene(s) from your selected custom geneset."))
                        }
                    }
                }) 

            # show the gene list in a table
                output$scRNA_FeaturePlot_gene_table <- renderDataTable({
                    if(length(input$scRNA_FeaturePlot_gene_from_custom_geneset) > 0 && input$scRNA_FeaturePlot_gene_from_custom_geneset == TRUE){
                        if(is.null(gene_list_custom())){
                            Input_is_ready(0)
                            return(NULL)
                        } else {
                            Input_is_ready(2)
                            datatable( data.frame(Gene = gene_list_custom()), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE) 
                            # datatable(data.frame(Gene = gene_list_custom()), selection = list(mode='multiple'), options = list(scrollX = TRUE, pageLength = 5 ), rownames = FALSE) # , options = list(scrollX = TRUE, scrollY=TRUE)
                        }
                    } else {
                        if(is.null(gene_list_mannual())){
                            Input_is_ready(0)
                            return(NULL)
                        } else {
                            Input_is_ready(1)
                            datatable( data.frame(Gene = gene_list_mannual()), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE) 
                            # datatable(data.frame(Gene = gene_list_mannual()), selection = list(mode='multiple'), options = list(scrollX = TRUE, pageLength = 5 ), rownames = FALSE)
                        } 
                    }
                })

    ## 

    return(list(flag=Input_is_ready, gene_list_mannual=gene_list_mannual, gene_list_custom=gene_list_custom))

    # ## Plot
    #     # function for showing one gene's expression
    #         gene_expression_map <- function(ex, umap, gene){
    #             # check if the gene is in the dataset 
    #             if(gene %in% rownames(ex)){
    #                 gene_exist_flag <- TRUE
    #                 ex_gene <- ex[gene,]

    #                 # make a table
    #                 gene_ex_data <- data.frame(umap, ex_gene)
    #                 colnames(gene_ex_data) <- c("UMAP_1","UMAP_2","Gene" )

    #                 # scatter plot  
    #                 p1 <- ggplot(gene_ex_data,aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=gene_ex_data[gene_ex_data$Gene == 0,] , size = input$scRNA_FeaturePlot_dot_size_bg, color= input$scRNA_FeaturePlot_zero_colour)
    #                 p1 <- p1 + geom_point(data=gene_ex_data[gene_ex_data$Gene > 0,] , size = input$scRNA_FeaturePlot_dot_size, aes(color= Gene))
    #                 p1 <- p1 + scale_color_gradient(low  = input$scRNA_FeaturePlot_lowest_colour, high = input$scRNA_FeaturePlot_highest_colour)
    #                 p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_FeaturePlot_XY_label.font.size), axis.title = element_text(size=input$scRNA_FeaturePlot_XY_title.font.size))
    #                 p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_FeaturePlot_legend_size), legend.title = element_text(size=input$scRNA_FeaturePlot_legend_size))
    #                 p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_FeaturePlot_graph.title.font.size)) 
    #                 p1 <- p1 + ggtitle(gene)
    #                 p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
    #                 p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
    #                 p1 <- p1 + theme(legend.key.size = unit(2, "mm"))
    #                 if(input$scRNA_FeaturePlot_white_background){
    #                     p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
    #                     p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
    #                     p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    #                 }
    #             }else{ # if not, return a plot with only the UMAP but no gene expression shown.
    #                 gene_exist_flag <- FALSE
    #                 p1 <- ggplot()
    #             }
    #             return(list(p1 = p1, gene_exist_flag = gene_exist_flag))
    #         }    

    #     #

    #     # update the expression and the umap matrix
    #         observe({
    #             if(!is.null(Seurat_object())){
    #                 Seurat_ex(GetAssayData(object = Seurat_object(), assay = "RNA", slot = "data"))
    #                 Seurat_umap(as.data.frame(Seurat_object()@reductions$umap@cell.embeddings))
    #             }
    #         })

    #     # draw UMAP2 (gene expression feature map)
    #         output$scRNA_FeaturePlot_plot <- renderPlot({
    #             if(!is.null(Seurat_object())){
    #                 Seurat_object <- Seurat_object()

    #                 if(Input_is_ready() == 0){ # input is not ready at all
    #                     scRNA_FeaturePlot_status_plot('A feature plot will be displayed here. Please input the gene(s).')
    #                     return(ggplot())
    #                 }

    #                 # Get the gene list to be plotted
    #                 if(Input_is_ready() == 1){ # the gene is inputted manually
    #                     target_gene_for_scRNA_featurePlot <- gene_list_mannual()
    #                 }else if(Input_is_ready() == 2){ # the gene is from custom geneset
    #                     target_gene_for_scRNA_featurePlot <- gene_list_custom()
    #                 }

    #                 # if no gene is selected in the table
    #                 if(length(input$scRNA_FeaturePlot_gene_table_rows_selected) == 0){
    #                     scRNA_FeaturePlot_status_plot('Please select a gene from the table to show its feature plot.')
    #                     return(ggplot())
    #                 }

    #                 # get the selected gene
    #                 gene <- target_gene_for_scRNA_featurePlot[input$scRNA_FeaturePlot_gene_table_rows_selected]
                    
    #                 # draw the feature plot for the selected gene
    #                 res <- gene_expression_map(Seurat_ex(), Seurat_umap(), gene)
    #                 if(res$gene_exist_flag == TRUE){
    #                     scRNA_FeaturePlot_status_plot(NULL)
    #                     return(res$p1)
    #                 }else{
    #                     scRNA_FeaturePlot_status_plot(paste0("The gene ", gene, " is not found in the dataset. Please check the gene name and try again or select another gene."))
    #                     return(ggplot())
    #                 }
    #             }else{
    #                 # when not data is selected or the Seurat object is not loaded successfully, show status messages and an empty plot.
    #                 scRNA_FeaturePlot_status_plot('Please select a dataset first')
    #                 return(ggplot())
    #             }
    #         }, width=reactive(input$scRNA_FeaturePlot_fig.width), height=reactive(input$scRNA_FeaturePlot_fig.height), res=300)
    #     #

    # ##

}