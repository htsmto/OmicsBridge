# =============================================================================
# DataOverview - Heatmap: Clustering
# File: modules/DataOverview/03_03_DataOverview_heatmap_clustering.R
# Purpose: Applies k-means clustering to the standardised expression matrix
#          and builds the cluster-annotated gene expression table used for
#          heatmap rendering.
# Edit this file when: changing the clustering method, cluster number
#                       validation, or how cluster assignments are stored.
# =============================================================================

heatmap_clustering_server <- function(input, output, session,
                                      ex_datafreme_for_heatmap,
                                      Input_genes_used,
                                      Data_Overview_heatmap_status) {

    ## Clustering
        clustered_heatmap_ex <- reactiveVal(NULL)
        observe({
            if(is.null(ex_datafreme_for_heatmap())){
                clustered_heatmap_ex(NULL)
                return(NULL)
            }

            df_ex <- ex_datafreme_for_heatmap()

            set.seed(123)
            if(input$Cluster_num > length(Input_genes_used())){
                Data_Overview_heatmap_status('The cluster number exceeds the number of genes. Please chosse a lower cluster number.')
                clustered_heatmap_ex(NULL)
                return(NULL)
            }else{
                Data_Overview_heatmap_status(NULL)
            }
            km <- kmeans(t(df_ex), centers = input$Cluster_num, nstart = 25)
            clusters <- as.data.frame(km$cluster)
            colnames(clusters) <- "Cluster"

            # combine the cluster number and the expression table
            gene_expression_matrix <- as.data.frame(t(df_ex))
            gene_expression_matrix$Cluster <- clusters$Cluster
            new_colnames <- c('Cluster', colnames(gene_expression_matrix)[1:dim(gene_expression_matrix)[2]-1])
            gene_expression_matrix <- gene_expression_matrix[,new_colnames]
            clustered_heatmap_ex(gene_expression_matrix)
        })
    ##

    return(list(
        clustered_heatmap_ex = clustered_heatmap_ex
    ))
}
