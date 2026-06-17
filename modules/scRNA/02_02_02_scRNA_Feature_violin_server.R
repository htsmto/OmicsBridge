# =============================================================================
# scRNA - Feature Violin Plot Server
# File: modules/scRNA/02_02_02_scRNA_Feature_violin_server.R
# Purpose: Renders per-cluster violin plots for selected genes using
#          Seurat's VlnPlot. Supports grouping by any metadata column.
# Edit this file when: changing the grouping variable, adding jitter points,
#                       or modifying the violin plot aesthetics.
# =============================================================================

scRNA_Feature_server_violin  <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
     ## status
        # status object
            scRNA_VlnPlot_vln_status <- reactiveVal(NULL)
            output$scRNA_VlnPlot_vln_status <- renderText({ scRNA_VlnPlot_vln_status() })

    ##

    ## UI
        # group.by options
            output$scRNA_VlnPlot_groupBy <- renderUI({
                if(length(is.null(Seurat_object())) == 0 || is.null(Seurat_object())){
                    selectInput(session$ns('scRNA_VlnPlot_groupBy'), 'Group by:', c('None'='None') )
                }else{
                    meta <- Seurat_object()@meta.data
                    selectInput(session$ns('scRNA_VlnPlot_groupBy'), 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )  
                }
            })

        # when you choose groups to show
            # selectable table
            All_group_names <- reactiveVal(NULL)
            output$scRNA_VlnPlot_vln_select_group_table <- renderDataTable({
                if(!input$scRNA_VlnPlot_vln_select_group || length(input$scRNA_VlnPlot_groupBy) == 0){
                    All_group_names(NULL)
                    return(NULL)
                }else{
                    if(input$scRNA_VlnPlot_groupBy == 'None'){
                        # show a message in a table
                        tmp <- data.frame('Group name'='Please select a group', stringsAsFactors = FALSE)
                        All_group_names(NULL)
                        datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)   
                    }else{
                        tmp0 <- unique(Seurat_object()@meta.data[,input$scRNA_VlnPlot_groupBy])
                        if(length(tmp0) > 60){
                            tmp <- data.frame('Group name'='Too many groups. Probably this is not a categorical variable. \nPlease select another group.by variable', stringsAsFactors = FALSE)
                            All_group_names(NULL)
                            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)   
                        }else{
                            tmp0 <- tmp0[order(tmp0)]
                            tmp <- data.frame('Group name'=tmp0, stringsAsFactors = FALSE)
                            All_group_names(tmp0)
                            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)   
                        }
                    }
                }
            })

        # 
    ##  

    ## Plot a violin plot
        # function for showing one gene's expression
            generate_violin_gene <- function(Gene, Seurat_expression, Seurat_meta, group.by){
                # check if the gene is in the dataset 
                if(Gene %in% rownames(Seurat_expression)){
                    gene_exist_flag <- TRUE

                    # if the group.by is not selected
                    if(group.by == 'None' || is.null(group.by)){
                        groupby_exsit_flag <- 0 # 0 means the group.by variable is not selected
                        p <- ggplot()
                    }else {
                       groupby_exsit_flag <- 2 # 2 means the group.by variable is selected and has a reasonable number of unique values
                    
                        # if the groups are too many, probably it is not a categorical variable, show a message and do not plot
                        if(length(unique(Seurat_meta[,group.by])) > 60){
                            groupby_exsit_flag <- 1 # 1 means the group.by variable is selected but has too many unique values (probably not a categorical variable)
                            p <- ggplot()
                        }else{

                            # extract the expression of the gene, the group.by information, and the barcode information, and merge them together for plotting.
                            One_Gene_ex <- data.frame((Seurat_expression[Gene,]))
                            colnames(One_Gene_ex) <- Gene # head(One_Gene_ex)
                            One_Gene_ex$barcode <- rownames(One_Gene_ex)
                            meta <- Seurat_meta # head(meta)
                            meta$barcode <- rownames(meta)
                            meta <- merge(meta, One_Gene_ex, by='barcode')
                            meta <- meta[c('barcode', group.by, Gene)] # head(meta)

                            # if the user choose to select groups to show in the violin plot, 
                            if(input$scRNA_VlnPlot_vln_select_group){
                                # when nothing is selected, use all
                                if(length(input$scRNA_VlnPlot_vln_select_group_table_rows_selected) == 0){
                                    meta <- meta  
                                }else{
                                    All_group_names <- All_group_names()
                                    selected_group_names <- All_group_names[input$scRNA_VlnPlot_vln_select_group_table_rows_selected]
                                    meta <- meta[meta[,group.by] %in% selected_group_names,]
                                }
                            }

                            # plot               
                            p <- ggplot(meta, aes(x=.data[[group.by]], y=.data[[Gene]], fill=.data[[group.by]]))+ geom_violin(trim = FALSE, size=0.2)
                
                        }
                    }
                }else{
                    gene_exist_flag <- FALSE
                    groupby_exsit_flag <- 0
                    p <- ggplot()
                }

                # return the plot and the flag
                return(list(p = p, gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag))
            }
 

        # Plot
            output$scRNA_VlnPlot_vln <- renderPlot({
                if(!is.null(Seurat_object())){
                    Seurat_object <- Seurat_object()

                    # input is not ready at all
                    if(Input_is_ready() == 0){ 
                        scRNA_VlnPlot_vln_status('A violin plot will be displayed here. Please input the gene(s).')
                        return(ggplot())
                    }

                    # Get the gene list to be plotted
                    if(Input_is_ready() == 1){ # the gene is inputted manually
                        target_gene_for_scRNA_VlnPlot <- gene_list_mannual()
                    }else if(Input_is_ready() == 2){ # the gene is from custom geneset
                        target_gene_for_scRNA_VlnPlot <- gene_list_custom()
                    }                    


                    # if no gene is selected in the table
                    if(length(input$scRNA_FeaturePlot_gene_table_rows_selected) == 0){
                        scRNA_VlnPlot_vln_status('Please select a gene from the table to show its violin plot.')
                        return(ggplot())
                    }

                    # get the selected gene
                    gene <- target_gene_for_scRNA_VlnPlot[input$scRNA_FeaturePlot_gene_table_rows_selected]

                    # draw the feature plot for the selected gene
                    Seurat_expression <- GetAssayData(object = Seurat_object(), assay = "RNA", layer = "data")
                    Seurat_meta <- Seurat_object()@meta.data
                    group.by <- input$scRNA_VlnPlot_groupBy
                    res <- generate_violin_gene(gene, Seurat_expression, Seurat_meta, group.by) # function(gene, Seurat_expression, Seurat_meta, group.by)


                    if(res$gene_exist_flag == TRUE){
                        if(res$groupby_exsit_flag == 2){
                            scRNA_VlnPlot_vln_status(NULL)
                            p <- res$p

                            # graph setting
                            if(!(input$scRNA_vln_vln_hide_jitter)){
                                p <- p +  geom_jitter(width=0.2, height=0, size=0.05)
                            }
                            p <- p + theme(legend.text=element_text(size=input$scRNA_vln_vln_legend_size), legend.title=element_text(size=input$scRNA_vln_vln_legend_size))
                            p <- p + theme(axis.text.x = element_text(size=input$scRNA_vln_vln_X_label_size), axis.text.y = element_text(size=input$scRNA_vln_vln_Y_label_size))
                            p <- p + theme(axis.title = element_text(size=input$scRNA_vln_vln_Y_title_size))
                            p <- p + xlab(input$scRNA_VlnPlot_groupBy) + scale_y_continuous(limits = c(0, NA))
                            p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                            p <- p + theme(legend.key.size = unit(1.5, "mm"))
                            p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))  
                            if(input$scRNA_vln_vln_white_back){
                                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                            }
                            if(input$scRNA_vln_vln_rotate_x){
                                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                            }
                            ylim1 <- ifelse(is.numeric(input$scRNA_vln_vln_ylim_min), input$scRNA_vln_vln_ylim_min, NA)
                            ylim2 <- ifelse(is.numeric(input$scRNA_vln_vln_ylim_max), input$scRNA_vln_vln_ylim_max, NA)
                            p <- p + coord_cartesian( ylim=c(ylim1, ylim2))        
                            return(p)

                        }else if(res$groupby_exsit_flag == 1){
                            scRNA_VlnPlot_vln_status(paste0("The 'Group by' variable has too many unique values. Probably, it is not a categorical variable. \nPlease select a variable with fewer unique values for the violin plot."))
                            return(ggplot())
                        }else if(res$groupby_exsit_flag == 0){
                            scRNA_VlnPlot_vln_status('Please select a "Group by" variable to show the violin plot.')
                            return(ggplot())
                        }
                    }else{
                        scRNA_VlnPlot_vln_status(paste0("The gene ", gene, " is not found in the dataset. Please check the gene name and try again or select another gene."))
                        return(ggplot())
                    }


                }else{
                    # when no data is selected or the Seurat object is not loaded successfully, show status messages and an empty plot.
                    scRNA_VlnPlot_vln_status('Please select a dataset first')
                    return(ggplot())
                }
            },width=reactive(input$scRNA_vln_vln_fig.width), height=reactive(input$scRNA_vln_vln_fig.height), res=300)


}