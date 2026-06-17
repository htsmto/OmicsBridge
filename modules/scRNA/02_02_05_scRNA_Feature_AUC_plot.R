# =============================================================================
# scRNA - AUCell Gene Set Activity: Plot
# File: modules/scRNA/02_02_05_scRNA_Feature_AUC_plot.R
# Purpose: UMAP and violin plot rendering with AUC score overlay. Consumes
#          reactive values from the calc sub-module (umap_AUC, violin_AUC,
#          isCalculating).
# Edit this file when: changing the UMAP colour scale for AUC values, the
#                       violin plot style, or adding new plot types.
# =============================================================================

scrna_auc_plot_server <- function(input, output, session, Seurat_object, umap_AUC, violin_AUC, isCalculating) {

    ## status
        scRNA_FeaturePlot_gene_signature_status <- reactiveVal(NULL)
        scRNA_violin_gene_signature_status <- reactiveVal(NULL)
        output$scRNA_FeaturePlot_gene_signature_status <- renderText({ scRNA_FeaturePlot_gene_signature_status() })
        output$scRNA_violin_gene_signature_status <- renderText({ scRNA_violin_gene_signature_status() })
    ##

    ## UI setting  (for violin)
        # group.by options
            output$scRNA_violin_gene_signature_groupby <- renderUI({
                if(length(is.null(Seurat_object())) == 0 || is.null(Seurat_object())){
                    selectInput(session$ns('scRNA_violin_gene_signature_groupby'), 'Group by:', c('None'='None') )
                }else{
                    meta <- Seurat_object()@meta.data
                    selectInput(session$ns('scRNA_violin_gene_signature_groupby'), 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
                }
            })

        #

        # when you choose groups to show
            # selectable table
            All_group_names <- reactiveVal(NULL)
            output$scRNA_violin_gene_signature_select_group_table <- renderDataTable({
                if(!input$scRNA_violin_gene_signature_select_group || length(input$scRNA_violin_gene_signature_groupby) == 0){
                    All_group_names(NULL)
                    return(NULL)
                }else{
                    if(input$scRNA_violin_gene_signature_groupby == 'None'){
                        # show a message in a table
                        tmp <- data.frame('Group name'='Please select a group', stringsAsFactors = FALSE)
                        All_group_names(NULL)
                        datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE), rownames = FALSE)
                    }else{
                        tmp0 <- unique(Seurat_object()@meta.data[,input$scRNA_violin_gene_signature_groupby])
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

    ## plot
        # umap plot
            output$scRNA_FeaturePlot_gene_signature_plot <- renderPlot({
                # when a Seurat object is not loaded
                if(isCalculating()){
                    return(ggplot()) # display a spinner while calculating
                }

                if(is.null(Seurat_object())){
                    scRNA_FeaturePlot_gene_signature_status('Please select a dataset first')
                    return(ggplot())


                }

                if(is.null(umap_AUC())){ # when AUC is not calculated yet
                    scRNA_FeaturePlot_gene_signature_status('Please calculate the signature score first.')
                    return(ggplot())


                }else{
                    # when AUC is calculated and ready to plot
                    scRNA_FeaturePlot_gene_signature_status(NULL)

                    # plot
                    p1 <- ggplot(umap_AUC(),aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=umap_AUC()[umap_AUC()$AUC.score == 0,] , size = input$scRNA_FeaturePlot_gene_signature_dot_size_bg, color= input$scRNA_FeaturePlot_gene_signature_zero_colour)
                    p1 <- p1 + geom_point(data=umap_AUC()[umap_AUC()$AUC.score > 0,] , size = input$scRNA_FeaturePlot_gene_signature_dot_size, aes(color= AUC.score))
                    p1 <- p1 + scale_color_gradient(low  = input$scRNA_FeaturePlot_gene_signature_lowest_colour, high = input$scRNA_FeaturePlot_gene_signature_highest_colour)
                    p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_FeaturePlot_gene_signature_XY_label.font.size), axis.title = element_text(size=input$scRNA_FeaturePlot_gene_signature_XY_title.font.size))
                    p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_FeaturePlot_gene_signature_legend_size), legend.title = element_text(size=input$scRNA_FeaturePlot_gene_signature_legend_size))
                    p1 <- p1 + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                    p1 <- p1 + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p1 <- p1 + theme(legend.key.size = unit(2, "mm"))
                    if(input$scRNA_FeaturePlot_gene_signature_white_background){
                        p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                        p1 <- p1 + theme(panel.background = element_rect(fill="white", linewidth=0))
                        p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    p1
                }

            }, width=reactive(input$scRNA_FeaturePlot_gene_signature_fig.width), height=reactive(input$scRNA_FeaturePlot_gene_signature_fig.height), res=300)

        #

        # violin plot

            # function for showing one gene's expression
                generate_violin_gene <- function(violin_AUC, group.by){ # violin_AUC() is the meta data with AUC score merged in
                    # flag
                    AUC_score_exist_flag <- FALSE
                    groupby_exsit_flag <- 0 # 0 means the group.by variable is not selected, 1 means the group.by variable is selected but has too many unique values (probably not a categorical variable), 2 means the group.by variable is selected and has a reasonable number of unique values

                    # check if violin_AUC is not null
                    if(is.null(violin_AUC)){
                        AUC_score_exist_flag <- FALSE
                        groupby_exsit_flag <- 0
                        p <- ggplot()
                    }else{
                        AUC_score_exist_flag <- TRUE

                        # if the group.by is not selected
                        if(group.by == 'None' || is.null(group.by)){
                            groupby_exsit_flag <- 0 # 0 means the group.by variable is not selected
                            p <- ggplot()
                        }else {
                           groupby_exsit_flag <- 2 # 2 means the group.by variable is selected and has a reasonable number of unique values

                            # if the groups are too many, probably it is not a categorical variable, show a message and do not plot
                            if(length(unique(violin_AUC[,group.by])) > 60){
                                groupby_exsit_flag <- 1 # 1 means the group.by variable is selected but has too many unique values (probably not a categorical variable)
                                p <- ggplot()

                            }else{ # ready
                                groupby_exsit_flag <- 2

                                # extract the AUC score, the group.by information, and the barcode information
                                meta <- violin_AUC[c('barcode', group.by, 'Custom')] # head(meta)

                                # if the user choose to select groups to show in the violin plot,
                                if(input$scRNA_violin_gene_signature_select_group){
                                    # when nothing is selected, use all
                                    if(length(input$scRNA_violin_gene_signature_select_group_table_rows_selected) == 0){
                                        meta <- meta
                                    }else{
                                        All_group_names <- All_group_names()
                                        selected_group_names <- All_group_names[input$scRNA_violin_gene_signature_select_group_table_rows_selected]
                                        meta <- meta[meta[,group.by] %in% selected_group_names,]
                                    }
                                }

                                p <- ggplot(meta, aes(x=.data[[group.by]], y=.data[['Custom']], fill=.data[[group.by]]))+ geom_violin(trim = FALSE, linewidth=0.2)
                            }
                        }
                    }
                    return(list(p = p, AUC_score_exist_flag = AUC_score_exist_flag, groupby_exsit_flag = groupby_exsit_flag))
                }

            #

            # Plot
                output$scRNA_violin_gene_signature_plot <- renderPlot({
                    # when AUC is being calculated
                    if(isCalculating()){
                        while(TRUE){
                            return(ggplot()) # display a spinner while calculating
                        }
                    }

                    if(!is.null(Seurat_object())){
                        Seurat_object <- Seurat_object()

                        # when AUC is not calculated yet
                        if(is.null(violin_AUC())){
                            scRNA_violin_gene_signature_status('Please calculate the signature score first.')
                            return(ggplot())
                        }


                        # when AUC is calculated and ready to plot, try generating the violin plot with the selected group.by
                        group.by <- input$scRNA_violin_gene_signature_groupby
                        res <- generate_violin_gene(violin_AUC(), group.by) # generate_violin_gene <- function(violin_AUC, group.by). return(list(p = p, AUC_score_exist_flag = AUC_score_exist_flag, groupby_exsit_flag = groupby_exsit_flag))


                        if(res$groupby_exsit_flag == 2){
                            scRNA_violin_gene_signature_status(NULL)
                            p <- res$p

                            # graph setting
                            if(!(input$scRNA_violin_gene_signature_hide_jitter)){
                                p <- p +  geom_jitter(width=0.2, height=0, size=0.05)
                            }
                            p <- p + theme(legend.text=element_text(size=input$scRNA_violin_gene_signature_legend_size), legend.title=element_text(size=input$scRNA_violin_gene_signature_legend_size))
                            p <- p + theme(axis.text.x = element_text(size=input$scRNA_violin_gene_signature_XY_label.font.size), axis.text.y = element_text(size=input$scRNA_violin_gene_signature_XY_label.font.size))
                            p <- p + theme(axis.title = element_text(size=input$scRNA_violin_gene_signature_XY_title.font.size))
                            p <- p + xlab(input$scRNA_violin_gene_signature_groupby) + scale_y_continuous(limits = c(0, NA))
                            p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                            p <- p + theme(legend.key.size = unit(1.5, "mm"))
                            p <- p + ylab('AUC score')
                            p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))
                            if(input$scRNA_violin_gene_signature_white_background){
                                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                            }
                            if(input$scRNA_violin_gene_signature_rotate_x){
                                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                            }
                            ylim1 <- ifelse(is.numeric(input$scRNA_violin_gene_signature_ylim_min), input$scRNA_violin_gene_signature_ylim_min, NA)
                            ylim2 <- ifelse(is.numeric(input$scRNA_violin_gene_signature_ylim_max), input$scRNA_violin_gene_signature_ylim_max, NA)
                            p <- p + coord_cartesian( ylim=c(ylim1, ylim2))
                            return(p)

                        }else if(res$groupby_exsit_flag == 1){
                            scRNA_violin_gene_signature_status(paste0("The 'Group by' variable has too many unique values. Probably, it is not a categorical variable. \nPlease select a variable with fewer unique values for the violin plot."))
                            return(ggplot())
                        }else if(res$groupby_exsit_flag == 0){
                            scRNA_violin_gene_signature_status('Please select a "Group by" variable to show the violin plot.')
                            return(ggplot())
                        }

                    }else{
                        # when no data is selected or the Seurat object is not loaded successfully, show status messages and an empty plot.
                        scRNA_violin_gene_signature_status('Please select a dataset first')
                        return(ggplot())
                    }
                },width=reactive(input$scRNA_violin_gene_signature_fig.width), height=reactive(input$scRNA_violin_gene_signature_fig.height), res=300)

        #
}
