source("modules/scRNA/01_scRNA_DataSelection_ui.R")
source("modules/scRNA/02_scRNA_Analysis_ui.R")

scRNA_UI <- function(ns) {
  tabItem(tabName = "scRNA",
    h2('scRNA Data Overview'),
    scRNA_DataSelection_ui(ns),
    scRNA_Analysis_ui(ns)
  )
}
