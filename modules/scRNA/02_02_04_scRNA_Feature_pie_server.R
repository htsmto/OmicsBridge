# =============================================================================
# scRNA - Cell-Type Proportion Pie Chart Server
# File: modules/scRNA/02_02_04_scRNA_Feature_pie_server.R
# Purpose: Computes and renders a pie chart of cell-type proportions per
#          sample or condition based on cluster assignments in the Seurat object.
# Edit this file when: changing the grouping variable for proportion calculation,
#                       colour scheme, or switching to a stacked bar chart.
# =============================================================================

suppressMessages(library(reshape2))
suppressMessages(library(cowplot))

scRNA_Feature_server_pie  <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
     ## status
        # status object
            scRNA_fraction_status <- reactiveVal(NULL)
            output$scRNA_fraction_status <- renderText({ scRNA_fraction_status() })

    ##

    ## UI
        # group.by options
            output$scRNA_fraction_groupBy <- renderUI({
                if(length(is.null(Seurat_object())) == 0 || is.null(Seurat_object())){
                    selectInput(session$ns('scRNA_fraction_groupBy'), 'Group by:', c('None'='None') )
                }else{
                    meta <- Seurat_object()@meta.data
                    selectInput(session$ns('scRNA_fraction_groupBy'), 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )  
                }
            })

        # when you choose groups to show
            # selectable table
            All_group_names <- reactiveVal(NULL)
            output$scRNA_PieChart_select_group_table <- renderDataTable({
                if(!input$scRNA_PieChart_select_group || length(input$scRNA_fraction_groupBy) == 0){
                    All_group_names(NULL)
                    return(NULL)
                }else{
                    if(input$scRNA_fraction_groupBy == 'None'){
                        # show a message in a table
                        tmp <- data.frame('Group name'='Please select a group', stringsAsFactors = FALSE)
                        All_group_names(NULL)
                        datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)   
                    }else{
                        tmp0 <- unique(Seurat_object()@meta.data[,input$scRNA_fraction_groupBy])
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
            generate_pie_chart <- function(gene, group.by, Seurat_expression, Seurat_meta){
                # check if the gene is in the dataset 
                # gene_exist_flag. TRUE: the gene is in the dataset; FALSE: the gene is not in the dataset
                # groupby_exsit_flag. 0: the group.by variable is not selected; 1: the group.by variable is selected but not valid; 2: the group.by variable is selected and valid

                if(!(gene %in% rownames(Seurat_expression))){
                    gene_exist_flag <- FALSE
                    groupby_exsit_flag <- 0
                    p <- ggplot()
                    return(list(p = p, gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag))
                }else{
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
                            # make a table for the fraction of expressing and non-expressing cells in each group
                            ex_gene <- Seurat_expression[gene,] 
                            groups <- unique(Seurat_meta[,group.by])

                            # if the user has selected specific groups to show, only show those groups
                            if(input$scRNA_PieChart_select_group){
                                if(length(input$scRNA_PieChart_select_group_table_rows_selected) > 0){
                                    groups <- All_group_names()[input$scRNA_PieChart_select_group_table_rows_selected]
                                }
                            }

                            df_fraction <- data.frame('Group'=c(), 'Expressing' = c(), 'Non.expressing'=c())
                            for ( group in groups ){
                                cells <- rownames(Seurat_meta[Seurat_meta[,group.by] == group,])
                                ex_gene_group <- ex_gene[cells]
                                num_expressed <- length(ex_gene_group[ex_gene_group>0])
                                num_non_expressed <- length(ex_gene_group[ex_gene_group==0])
                                df_fraction <- rbind(df_fraction, list('Group'=c(group), 'Expressing' = c(num_expressed), 'Non.expressing'=c(num_non_expressed)))
                            }

                            # plot
                            df_fraction_melt <- melt(df_fraction, id.vars='Group')
                            df_fraction_melt$variable <- factor(df_fraction_melt$variable, levels = c('Expressing', 'Non.expressing'))
                            plots <- list()
                            for (group in unique(df_fraction_melt$Group)){
                                df_plot_tmp <- df_fraction_melt[df_fraction_melt$Group == group,]
                                df_plot_tmp <- df_plot_tmp %>% mutate(fraction = value/sum(value), label=paste0(value, "(", round(fraction*100), "%)"))
                                p_tmp <- ggplot(df_plot_tmp, aes(x="", y=value, fill=variable)) + geom_bar(stat='identity', width=1) + coord_polar(theta='y')
                                p_tmp <- p_tmp + scale_fill_manual(values=c("Expressing" = input$scRNA_fraction_expressing_colour, "Non.expressing"= input$scRNA_fraction_non_expressing_colour))
                                if(!input$scRNA_fraction_hide_label){
                                p_tmp <- p_tmp + geom_text(aes(y=value/2 + c(0, cumsum(value)[-length(value)]), label=label), size=input$scRNA_fraction_label_size)
                                }
                                p_tmp <- p_tmp + theme_void() + ggtitle(group)
                                p_tmp <- p_tmp + theme(plot.title=element_text(size=input$scRNA_fraction_group_name_size))
                                if(!input$scRNA_fraction_hide_legend){
                                p_tmp <- p_tmp + theme(legend.text=element_text(size=input$scRNA_fraction_legend_size), legend.title=element_text(size=input$scRNA_fraction_legend_size))
                                p_tmp <- p_tmp + labs(fill=gene)
                                }else{
                                p_tmp <- p_tmp + theme(legend.position = 'none')
                                }
                                plots[[length(plots) + 1]] <- p_tmp
                            }
                            p <- plot_grid(plotlist = plots)
                        }
                    }
                }
                return(list(p = p, gene_exist_flag = gene_exist_flag, groupby_exsit_flag = groupby_exsit_flag))
            }
        #

        # plot
            output$scRNA_fraction_piechart <- renderPlot({
                if(!is.null(Seurat_object())){
                    # input is not ready at all
                    if(!Input_is_ready()){
                        scRNA_fraction_status('Please select a dataset and input genes first')
                        return(ggplot())
                    }

                    # Get the gene list to be plotted
                    if(Input_is_ready() == 1){ # the gene is inputted manually
                        target_gene_for_scRNA_fraction <- gene_list_mannual()
                    }else if(Input_is_ready() == 2){ # the gene is from custom geneset
                        target_gene_for_scRNA_fraction <- gene_list_custom()
                    }       

                    # if no gene is selected in the table
                    if(length(input$scRNA_FeaturePlot_gene_table_rows_selected) == 0){
                        scRNA_fraction_status('Please select a gene from the table to show its pie chart.')
                        return(ggplot())
                    }

                    # get the selected gene
                    gene <- target_gene_for_scRNA_fraction[input$scRNA_FeaturePlot_gene_table_rows_selected]

                    # draw a pie chart for the selected gene
                    Seurat_expression <- GetAssayData(object = Seurat_object(), assay = "RNA", layer = "data")
                    Seurat_meta <- Seurat_object()@meta.data
                    group.by <- input$scRNA_fraction_groupBy
                    res <- generate_pie_chart(gene, group.by, Seurat_expression, Seurat_meta ) # generate_pie_chart <- function(gene, group.by, Seurat_expression, Seurat_meta)

                    # plot
                    if(res$gene_exist_flag == TRUE){
                        if(res$groupby_exsit_flag == 2){
                            scRNA_fraction_status(NULL)
                            p <- res$p  
                            return(p)

                        }else if(res$groupby_exsit_flag == 1){
                            scRNA_fraction_status(paste0("The 'Group by' variable has too many unique values. Probably, it is not a categorical variable. \nPlease select a variable with fewer unique values for the pie chart."))
                            return(ggplot())
                        }else if(res$groupby_exsit_flag == 0){
                            scRNA_fraction_status('Please select a "Group by" variable to show the pie chart.')
                            return(ggplot())
                        }
                    }else{
                        scRNA_fraction_status(paste0("The gene ", gene, " is not found in the dataset. Please check the gene name and try again or select another gene."))
                        return(ggplot())
                    }


                }else{
                    scRNA_fraction_status('Please select a dataset first')
                    return(ggplot())
                }

            }, width=reactive(input$scRNA_fraction_fig.width), height=reactive(input$scRNA_fraction_fig.height))

        #
    


    ##

}