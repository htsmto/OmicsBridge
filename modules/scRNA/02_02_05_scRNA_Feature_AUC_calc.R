# =============================================================================
# scRNA - AUCell Gene Set Activity: Calculation
# File: modules/scRNA/02_02_05_scRNA_Feature_AUC_calc.R
# Purpose: AUCell scoring calculation and preparation of data frames for
#          UMAP and violin plot rendering. Returns reactive values consumed
#          by the plot sub-module.
# Edit this file when: changing the AUC threshold, the gene set source,
#                       or the data preparation for downstream plots.
# =============================================================================

scrna_auc_calc_server <- function(input, output, session, Seurat_object, Input_is_ready, gene_list_mannual, gene_list_custom) {
    ## status
        # status object
            scRNA_FeaturePlot_gene_signature_all_status <- reactiveVal(NULL)
            output$scRNA_FeaturePlot_gene_signature_all_status <- renderText({ scRNA_FeaturePlot_gene_signature_all_status() })
        #
    ##

    ## AUC calculation
        # initialize reactive values for AUC results and calculation status
            cells_AUC_df <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            umap_AUC <- reactiveVal(NULL)
            violin_AUC <- reactiveVal(NULL)
        #

        # calculate AUC scores. Prepare the table for UMAP and Violin plot.
            observeEvent(input$scRNA_FeaturePlot_gene_signature_start,{
                isCalculating(TRUE)   # set calculating flag to TRUE

                # input is not ready at all
                if(Input_is_ready() == 0){
                    scRNA_FeaturePlot_gene_signature_all_status('Please input the gene(s).')
                    cells_AUC_df(NULL)
                    isCalculating(FALSE)
                    return()
                }

                # Get the gene list to be plotted
                if(Input_is_ready() == 1){ # the gene is inputted manually
                    target_gene_for_AUC <- gene_list_mannual()
                }else if(Input_is_ready() == 2){ # the gene is from custom geneset
                    target_gene_for_AUC <- gene_list_custom()
                }

                # check if the genes are included in the dataset. if some genes are not included, show which genes are not included.
                found_genes <- intersect(rownames(Seurat_object()), target_gene_for_AUC)
                not_found_genes <- setdiff(target_gene_for_AUC, found_genes)

                # if nothing is found, show error and return
                if(length(found_genes) == 0){
                    show_alert(title='Error.',text='None of the inputted genes are included in the dataset.', type='error')
                    scRNA_FeaturePlot_gene_signature_all_status('None of the inputted genes are included in the dataset.')
                    cells_AUC_df(NULL)
                    isCalculating(FALSE)
                    return()
                }

                # if some genes are not found, show warning but still proceed with the found genes
                if(length(not_found_genes) > 0){
                    scRNA_FeaturePlot_gene_signature_all_status(paste0('The following inputted genes are not included in the dataset and will be ignored: ', paste(not_found_genes, collapse=', ')))
                }

                # proceed with the found genes. Calculate the AUC scores
                Seurat_obj <- Seurat_object()
                GS <- list('Custom'=found_genes)
                Seurat_expression <- GetAssayData(object = Seurat_obj, assay = "RNA", layer = "data")
                cells_AUC <- AUCell_run(as(Seurat_expression, "dgCMatrix")  , GS)
                cells_AUC_df <- data.frame(t(getAUC(cells_AUC)))
                cells_AUC_df$barcode <- as.character(rownames(cells_AUC_df))

                # for the umap plot
                Seurat_umap <- as.data.frame(Seurat_obj@reductions$umap@cell.embeddings)
                Seurat_umap$barcode <- rownames(Seurat_umap)
                umap_AUC <- merge(Seurat_umap, cells_AUC_df, by='barcode')
                colnames(umap_AUC) <- c("barcode","UMAP_1", "UMAP_2","AUC.score" )

                # update the umap_AUC reactive value
                umap_AUC(umap_AUC)

                # for the violin plot
                meta <- Seurat_obj@meta.data
                meta$barcode <- as.character(rownames(meta)) # head(meta)
                meta <- merge(meta, cells_AUC_df, by='barcode')# head(meta)
                violin_AUC(meta)
                scRNA_FeaturePlot_gene_signature_all_status(NULL)
                isCalculating(FALSE)  # set calculating flag to FALSE after calculation is done
                return()

            })

        #

    ##

    return(list(
        umap_AUC = umap_AUC,
        violin_AUC = violin_AUC,
        isCalculating = isCalculating
    ))
}
