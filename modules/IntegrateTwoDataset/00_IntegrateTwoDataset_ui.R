source("modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_ui.R")
source("modules/IntegrateTwoDataset/02_IntegrateTwoDataset_IntegrationPlot_ui.R")

IntegrateTwoDataset_UI <- function(ns) {
  tabItem(tabName = "Integrate_two_dataset",
    h2(' Integrate two datasets'),
    IntegrateTwoDataset_SideBySide_UI(ns),
    IntegrateTwoDataset_IntegrationPlot_UI(ns)
  )
}
