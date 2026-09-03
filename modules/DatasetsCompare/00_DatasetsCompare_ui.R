source("modules/DatasetsCompare/01_DatasetsCompare_DataSelection_ui.R")
source("modules/DatasetsCompare/02_DatasetsCompare_GetOverlap_ui.R")
source("modules/DatasetsCompare/03_DatasetsCompare_CompareOneGene_ui.R")



DatasetsCompare_UI <- function(ns) {
    tabItem( tabName='Compare_across_datasets',
        h2(' Compare Across Datasets'),
        box(width=12, collapsible=TRUE, title=strong('Dataset Selection'), status='info',solidHeader = TRUE,
            DatasetsCompare_DataSelection_UI(ns)
        ),
        box(width=12, title=strong('Analysis'), status='primary',solidHeader = TRUE,
            h4(''),
            tabsetPanel(
                tabPanel(strong("Get the Overlap"),
                    DatasetsCompare_GetOverlap_UI(ns)
                ),
                tabPanel(strong("Compare One Gene"),
                    DatasetsCompare_CompareOneGene_UI(ns)    
                )
            )
        )
    )
}