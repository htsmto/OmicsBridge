source("modules/scRNA/02_01_scRNA_UMAP_ui.R")
source("modules/scRNA/02_02_scRNA_Feature_ui.R")
# source("modules/scRNA/02_03_scRNA_Other_ui.R")

scRNA_Analysis_ui <- function(ns) {
    box(width=12, title='Data Overview & Analysis',status='primary', solidHeader = TRUE, collapsible=TRUE,
        tabsetPanel(
            tabPanel("Overview (UMAP)", scRNA_UMAP_ui(ns) ),
            tabPanel("Feature Plots", scRNA_Feature_ui(ns) ),
        )
    )

}