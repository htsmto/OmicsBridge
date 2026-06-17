source("modules/scRNA/01_scRNA_DataSelection_ui.R")
source("modules/scRNA/02_scRNA_Anlysis_ui.R")

scRNA_UI <- function(ns) {
  tabItem(tabName = "scRNA",
    h2('scRNA'),
    scRNA_DataSelection_ui(ns),
    scRNA_Anlysis_ui(ns)
  )
}
