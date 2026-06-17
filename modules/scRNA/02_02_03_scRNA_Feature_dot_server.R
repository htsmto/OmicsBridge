# =============================================================================
# scRNA - Feature Dot Plot Server
# File: modules/scRNA/02_02_03_scRNA_Feature_dot_server.R
# Purpose: Renders a dot plot (average expression + percent expressed) for
#          selected genes across clusters using Seurat's DotPlot.
# Edit this file when: changing the scaling method, colour gradient,
#                       or clustering order of genes/cells.
# =============================================================================

scRNA_Feature_server_dot  <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
     ## status
        # status object
            scRNA_DotPlot_dot_status <- reactiveVal(NULL)
            output$scRNA_DotPlot_dot_status <- renderText({ scRNA_DotPlot_dot_status() })

    ##

    ## UI
        # group.by options
            output$scRNA_DotPlot_groupBy <- renderUI({
                if(length(is.null(Seurat_object())) == 0 || is.null(Seurat_object())){
                    selectInput(session$ns('scRNA_DotPlot_groupBy'), 'Group by:', c('None'='None') )
                }else{
                    meta <- Seurat_object()@meta.data
                    selectInput(session$ns('scRNA_DotPlot_groupBy'), 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )  
                }
            })

        # when you choose groups to show
            # selectable table
            All_group_names <- reactiveVal(NULL)
            output$scRNA_DotPlot_dot_select_group_table <- renderDataTable({
                if(!input$scRNA_DotPlot_dot_select_group || length(input$scRNA_DotPlot_groupBy) == 0){
                    All_group_names(NULL)
                    return(NULL)
                }else{
                    if(input$scRNA_DotPlot_groupBy == 'None'){
                        # show a message in a table
                        tmp <- data.frame('Group name'='Please select a group', stringsAsFactors = FALSE)
                        All_group_names(NULL)
                        datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)   
                    }else{
                        tmp0 <- unique(Seurat_object()@meta.data[,input$scRNA_DotPlot_groupBy])
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

    ## plot a dot
        # function
            generate_dotplot <- function(genes, Seurat_object, Seurat_meta, group.by){
                # check if the gene is in the dataset , gene_exist_flag: 0 or 1 or 2. 0=no genes, 1=some genes, 2=all genes
                if(all(genes %in% rownames(Seurat_object)) == FALSE){
                    not_found_genes <- genes[!(genes %in% rownames(Seurat_object))]
                    found_gene <- genes[genes %in% rownames(Seurat_object)]

                    # if no gene is found, show which message and do not plot. If only one gene is input, show which message and do not plot. 
                    if(length(found_gene) == 0){
                        gene_exist_flag <- 0
                        groupby_exsit_flag <- 0
                        p <- ggplot()

                        return(list(gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag, not_found_genes=not_found_genes, p = p))
                    }else{
                        gene_exist_flag <- 1
                        message1 <- paste0('The following input genes are not found in the dataset: ', paste(not_found_genes, collapse = ', '), '. The rest of the genes will be plotted.')
                    }
                }else {
                    gene_exist_flag <- 2
                    not_found_genes <- NULL
                    found_gene <- genes

                }

                # if the group.by is not selected
                if(group.by == 'None' || is.null(group.by)){
                    groupby_exsit_flag <- 0 # 0 means the group.by variable is not selected
                    p <- ggplot()
                    return(list(gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag, not_found_genes=not_found_genes, p = p))
                }else {
                    groupby_exsit_flag <- 2 # 2 means the group.by variable is selected and has a reasonable number of unique values
                }

                # if the groups are too many, probably it is not a categorical variable, show a message and do not plot
                if(length(unique(Seurat_meta[,group.by])) > 60){
                    groupby_exsit_flag <- 1 # 1 means the group.by variable is selected but has too many unique values (probably not a categorical variable)
                    p <- ggplot()
                }else{
                    # start plotting
                    Seurat_object <- SetIdent(Seurat_object, value = group.by)
                    
                    # if the user has selected specific groups to show
                    if(input$scRNA_DotPlot_dot_select_group){
                        if(length(input$scRNA_DotPlot_dot_select_group_table_rows_selected) == 0){
                            p <- DotPlot(Seurat_object, features = factor(found_gene, levels=found_gene) , dot.scale=input$scRNA_dot_dotScale, cols = c(input$scRNA_dot_low_col, input$scRNA_dot_high_col)) + RotatedAxis()
                        }else{
                            selected_groups <- All_group_names()[input$scRNA_DotPlot_dot_select_group_table_rows_selected]
                            Seurat_object_subset <- subset(Seurat_object, idents = selected_groups)
                            p <- DotPlot(Seurat_object_subset, features = factor(found_gene, levels=found_gene) , dot.scale=input$scRNA_dot_dotScale, cols = c(input$scRNA_dot_low_col, input$scRNA_dot_high_col)) + RotatedAxis()
                        }
                    }else{
                        p <- DotPlot(Seurat_object, features = factor(found_gene, levels=found_gene) , dot.scale=input$scRNA_dot_dotScale, cols = c(input$scRNA_dot_low_col, input$scRNA_dot_high_col)) + RotatedAxis()
                    }
                    
                }

                return(list(gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag, not_found_genes=not_found_genes, p = p))
            }

        #

        # plot
            output$scRNA_DotPlot_dot <- renderPlot({
                if(!is.null(Seurat_object())){
                    Seurat_object <- Seurat_object()

                    # input is not ready at all
                    if(!Input_is_ready()){
                        scRNA_DotPlot_dot_status('Please select a dataset and input genes first')
                        return(ggplot())
                    }

                    # Get the gene list to be plotted
                    if(Input_is_ready() == 1){ # the gene is inputted manually
                        target_gene_for_scRNA_DotPlot <- gene_list_mannual()
                    }else if(Input_is_ready() == 2){ # the gene is from custom geneset
                        target_gene_for_scRNA_DotPlot <- gene_list_custom()
                    }       


                    # if scRNA_DotPlot_dot_show_all_genes is off and if no gene is selected in the table
                    if(length(input$scRNA_DotPlot_dot_show_all_genes) >0 && input$scRNA_DotPlot_dot_show_all_genes == FALSE ){
                        if(length(input$scRNA_FeaturePlot_gene_table_rows_selected) == 0){
                            scRNA_DotPlot_dot_status('Please select a gene from the table to show its dot plot.')
                            return(ggplot())
                        }else{
                            # get the selected gene
                            gene <- target_gene_for_scRNA_DotPlot[input$scRNA_FeaturePlot_gene_table_rows_selected]
                        }
                    }else{
                        gene <- target_gene_for_scRNA_DotPlot
                    }

                    # draw the feature plot for the selected gene
                    Seurat_meta <- Seurat_object()@meta.data
                    group.by <- input$scRNA_DotPlot_groupBy
                    res <- generate_dotplot(gene, Seurat_object(), Seurat_meta, group.by) # function(genes, Seurat_object, Seurat_meta, group.by){

                    # return(list(gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag, not_found_genes=not_found_genes, p = p))
                    # gene_exist_flag: 0=no genes, 1=some genes, 2=all genes
                    # gene_exist_flag==1 -> show which genes are not found in the dataset
                    # gene_exist_flag==0 -> if not_found_genes is only one, show the gene name. If not_found_genes is more than one, just tell that all genes are not found
                    # groupby_exsit_flag: 0=group.by variable is not selected, 1=group.by variable is selected but has too many unique values, 2=group.by variable is selected and has a reasonable number of unique values
                    
                    if(res$gene_exist_flag == 0){
                        if(length(res$not_found_genes) == 1){
                            scRNA_DotPlot_dot_status(paste0('The input gene ', res$not_found_genes, ' is not found in the dataset. Please check the gene name.'))
                        }else{
                            scRNA_DotPlot_dot_status('None of the input genes are found in the dataset. Please check the gene names.')
                        }
                        return(ggplot())
                    }else{
                        if(res$gene_exist_flag == 1){
                            message <- paste0('The following genes are not found in the dataset: ', paste(res$not_found_genes, collapse = ', '), '\n')
                        }else{
                            message <- NULL
                        }

                        if(res$groupby_exsit_flag == 0){
                            scRNA_DotPlot_dot_status(paste0(message, 'Please select a group.by variable to show the dot plot.'))
                            return(ggplot())
                        }else if(res$groupby_exsit_flag == 1){
                            scRNA_DotPlot_dot_status(paste0(message, 'The "Group by" variable has too many unique values. Probably, it is not a categorical variable. \nPlease select a variable with fewer unique values for the violin plot.'))
                            return(ggplot())
                        }else{
                            scRNA_DotPlot_dot_status(message)
                            p <- res$p
                        }
                    }                 
                }else{
                    scRNA_DotPlot_dot_status('Please select a dataset first')
                    return(ggplot())
                }
                p <- p + theme(legend.text=element_text(size=input$scRNA_dot_legend_size), legend.title=element_text(size=input$scRNA_dot_legend_size))
                p <- p + theme(axis.text.x = element_text(size=input$scRNA_dot_X_label_size), axis.text.y = element_text(size=input$scRNA_dot_Y_label_size))
                p <- p + theme(axis.title = element_text(size=input$scRNA_dot_Y_title_size))
                p <- p + ylab(input$scRNA_DotPlot_groupBy)
                p <- p + xlab(NULL)
                p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p <- p + theme(legend.key.size = unit(1.5, "mm"))
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                p
            },  width=reactive(input$scRNA_dot_fig.width), height=reactive(input$scRNA_dot_fig.height), res=300)

        #
    ##

}