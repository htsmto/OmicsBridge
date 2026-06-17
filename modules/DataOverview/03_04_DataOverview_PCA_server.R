# =============================================================================
# DataOverview - PCA Server
# File: modules/DataOverview/03_04_DataOverview_PCA_server.R
# Purpose: Performs Principal Component Analysis on the expression matrix and
#          renders an interactive PCA scatter plot. Supports selecting which
#          PCs to plot, colouring by metadata, and a variance-explained chart.
# Edit this file when: changing the PCA method, the number of top variable
#                       genes used, or the plot aesthetics.
# =============================================================================

dataoverview_pca_Server <- function(input, output, session, df_ex){
    # status
        Data_Overview_PCA_status <- reactiveVal(NULL)
        output$Data_Overview_PCA_status <- renderText({ Data_Overview_PCA_status() })
    #

    # ui
        # Sample name list
            output$Data_Overview_PCA_Sample_list <- renderText({
                df_ex <- df_ex()
                samples <- colnames(df_ex)[colnames(df_ex) != 'id']
                samples <- samples[order(samples)]
                paste(unlist(samples), collapse='\n')
            })
    #

    # group definition table
        group_define_table <- reactiveVal(NULL)
        input_samples <- reactiveVal(NULL)
        Data_Overview_PCA_Setting_group_define_status <- reactiveVal(NULL)
        output$Data_Overview_PCA_Setting_group_define_status <- renderText({ Data_Overview_PCA_Setting_group_define_status() })
        observe({
            if(length(input$Data_Overview_PCA_Setting) == 0 || is.null(input$Data_Overview_PCA_Setting)){
                return(NULL)
            }
            df_ex <- df_ex()
            if(input$Data_Overview_PCA_Setting=='A'){ # use all the samples
                samples <- colnames(df_ex)[colnames(df_ex) != 'id']
                Group <- c()
                tmp_tmp <- strsplit(as.character(samples), '_')
                for (i in tmp_tmp){
                    tmp <- ''
                    for(j in 1:(length(i)-1)){
                    tmp <- paste0(tmp, i[j],'_')
                    }
                    tmp <- substr(tmp, 1, nchar(tmp)-1)
                    Group <- c(Group, tmp)
                }
                df_sample_group <- data.frame('sample'=samples, 'Group'=Group)
                input_samples(samples)
                group_define_table(df_sample_group)
                return(NULL)
            }else{
                # when nothing is input (input$Data_Overview_PCA_Setting_group_define)
                Data_Overview_PCA_Setting_group_define_status('Please enter the group description.')
                if(nchar(input$Data_Overview_PCA_Setting_group_define)==0){
                    group_define_table(NULL)
                    input_samples(NULL)
                    return(NULL)
                }
                
                df_sample_group <- data.frame('sample'=c(), 'Group'=c())
                for ( sample_group in unlist(strsplit(input$Data_Overview_PCA_Setting_group_define, split = "\n"))){
                    # The input should be like this: 'Sample1_rep1,Group1' (sample name and group name separated by comma, each sample in a new line)
                    # sample_group='Sample1_rep1,Group1'
                    # if the input is not in the correct format, show an error message
                    if(length(strsplit(sample_group, split=',')[[1]]) != 2){
                        Data_Overview_PCA_Setting_group_define_status('The group description is not in the correct format. Please check your input.')
                        group_define_table(NULL)
                        input_samples(NULL)
                        return(NULL)
                    }
                    sample_tmp <- strsplit(sample_group, split=',')[[1]][1]
                    group_tmp <- strsplit(sample_group, split=',')[[1]][2]
                    df_sample_group_tmp <- data.frame('sample'=c(sample_tmp), 'Group'=c(group_tmp))
                    df_sample_group <- rbind(df_sample_group, df_sample_group_tmp)
                }
                if( anyDuplicated(df_sample_group$sample)>0){
                    Data_Overview_PCA_Setting_group_define_status('There are duplicated sample names. Please check your input.')
                    group_define_table(NULL)
                    input_samples(NULL)
                    return(NULL)
                }

                # check if the inputted sample names are in the dataset
                samples <- df_sample_group$sample
                samples_intersect <- intersect(samples, colnames(df_ex)) # colnames(df_ex)[1:3, 1:3]
                if(length(samples_intersect)==0){
                    Data_Overview_PCA_Setting_group_define_status('None of the inputted sample names are in the dataset. Please check your input.')
                    group_define_table(NULL)
                    input_samples(NULL)
                    return(NULL)
                }
                df_sample_group <- df_sample_group[df_sample_group$sample %in% samples_intersect, ]
                
                Data_Overview_PCA_Setting_group_define_status(NULL)
                input_samples(df_sample_group$sample)
                group_define_table(df_sample_group)
                return(NULL)
            }


        })
    #
    

    # Calculate PCA
        PCA_table <- reactiveVal(NULL)
        isCalculating <- reactiveVal(FALSE)
        x_lab <- reactiveVal(NULL)
        y_lab <- reactiveVal(NULL)
        observeEvent(input$Data_Overview_PCA_Start, {
            isCalculating(TRUE)
            df_ex <- df_ex()

            # if there is no data, return NULL
            if(length(df_ex) == 0 || is.null(df_ex)){
                show_alert(title='Error.',text='There is no data to perform PCA. Please re-upload the data and try again.', type='error')
                Data_Overview_PCA_status("There is no data to perform PCA. Please re-upload the data and try again.")
                PCA_table(NULL)
                isCalculating(FALSE)
                return(NULL)
            }
            rownames(df_ex) <- df_ex$id

            # if no samples
             if(length(input_samples()) == 0 || is.null(input_samples())){
                show_alert(title='Error.',text='There are no samples to perform PCA. Please check the setting for the sample input.', type='error')
                Data_Overview_PCA_status("There are no samples to perform PCA. Please check the setting for the sample input.")
                PCA_table(NULL)
                isCalculating(FALSE)
                return(NULL)
            }

            # exclude the column names id
            df_ex <- df_ex[,(colnames(df_ex) != 'id')]

            # replace NA with 0
            df_ex[is.na(df_ex)] <- 0

            samples <- input_samples()
            samples_intersect <- intersect(samples, colnames(df_ex)) # colnames(df_ex)[1:3, 1:3]            
            df_ex <- df_ex[,samples_intersect]

            # remove row expressed in less than 5*number of samples
            df2 <- df_ex[(rowSums(df_ex) > 5*dim(df_ex)[2]),] # dim(df2)
            df3 <- data.frame(t(df2)) # df3[1:3, 1:3]

            # PCA or tSNE or UMAP
            if(input$Data_Overview_PCA_plot_type == 'A'){ # PCA
                df3$sample <- rownames(df3)
                df3 <- df3[order(df3$sample),] # head(df3)
                pca_res <- prcomp(df3[, colnames(df3) != 'sample'], scale. = TRUE) 
                pca_df <- data.frame(pca_res[5]$x[, 1:2]) 
                pca_df$sample <- rownames(pca_df)
                x_lab('PC1')
                y_lab('PC2')
            }else if(input$Data_Overview_PCA_plot_type == 'B'){ # tSNE
                library(Rtsne)
                set.seed(42)
                tsne_res <- tryCatch(
                    {
                        Rtsne(df3, perplexity = input$Data_Overview_PCA_tSNE_perplexity)
                    },
                    error = function(e) {
                        message("t-SNE failed: ", e$message)
                        NULL   # return NULL if it fails
                    }
                )
                # Put into a dataframe
                if(is.null(tsne_res)){
                    show_alert(title='Error.',text='tSNE failed. Please try changing the perplexity value.', type='error')
                    Data_Overview_PCA_status("tSNE failed. Please try changing the perplexity value.")
                    PCA_table(NULL)
                    isCalculating(FALSE)
                    return(NULL)
                }
                tsne_df <- data.frame( PC1 = tsne_res$Y[,1], PC2 = tsne_res$Y[,2], sample = rownames(df3))
                rownames(tsne_df) <- rownames(df3)
                pca_df <- tsne_df
                x_lab('tSNE1')
                y_lab('tSNE2')
            }else if(input$Data_Overview_PCA_plot_type == 'C'){ # UMAP
                library(umap)
                # Run UMAP
                umap_res <- umap(df3)

                # Put into a dataframe for ggplot
                umap_df <- data.frame(PC1 = umap_res$layout[,1], PC2 = umap_res$layout[,2], sample = rownames(df3))
                pca_df <- umap_df
                x_lab('UMAP1')
                y_lab('UMAP2')
            }

            # merge with group_define_table
            if(!is.null(group_define_table())){
                pca_df <- merge(pca_df, group_define_table(), by='sample', all.x=TRUE)
            }else{
                # error
                show_alert(title='Error.',text='There are no group information. Please check the setting for the sample input.', type='error')
                Data_Overview_PCA_status("There are no group information. Please check the setting for the sample input.")
                PCA_table(NULL)
                isCalculating(FALSE)
                return(NULL)
            }

            PCA_table(pca_df)
            isCalculating(FALSE)
            return(NULL)


        })

    #

    # plot
        Data_Overview_PCA_status <- reactiveVal("There is no PCA result to plot. Please click the 'Start' button to perform PCA.")
        output$Data_Overview_PCA_status <- renderText({ Data_Overview_PCA_status() })

        output$Data_Overview_PCA_plot <- renderPlot({
            if(isCalculating()){
                return(ggplot())
            }
            pca_df <- PCA_table()
            if(is.null(pca_df)){
                return(ggplot())
            }

            Data_Overview_PCA_status(NULL)
            if(input$Data_Overview_PCA_change_colour_by_group){
                p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample, color=Group)) + geom_point(size=input$Data_Overview_PCA_point_size) 
                p <- p + theme(legend.text = element_text(size=input$Data_Overview_PCA_legend_size), legend.title=element_blank())
            }else{
             p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample)) + geom_point(size=input$Data_Overview_PCA_point_size) 
            }
            if(!input$Data_Overview_PCA_label_hide){
                p <- p + geom_text_repel(data = pca_df,  color = 'black', aes(label = sample), size = input$Data_Overview_PCA_label_size, max.overlaps = Inf, segment.size=0.2)
            }
            p <- p + xlab(x_lab()) + ylab(y_lab())
            p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
            p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
            p <- p + theme(panel.grid.major = element_line(linewidth = 0.1), panel.grid.minor = element_line(linewidth = 0.05))  
            p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p <- p + theme(legend.key.size = unit(2, "mm"))
            if(input$Data_Overview_PCA_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            }
            p
        }, width=reactive(input$Data_Overview_PCA_fig.width), height = reactive(input$Data_Overview_PCA_fig.height), res=300)

    #

    # show the selected sample names
        # Selected sample names
        output$Data_Overview_PCA_plot_selected_names <- renderText({
            if(length(PCA_table())==0 || is.null(PCA_table())){
                return(NULL)
            }else{
                res <- brushedPoints(PCA_table(), input$plot_brush_PCA, xvar = input$PC1, yvar = input$PC2)
                if(nrow(res) == 0){
                    return("The samples names of the selected points in the graph will be shown here.")
                }
                paste(unlist(res$sample), collapse='\n')
            }
        })
    #

}