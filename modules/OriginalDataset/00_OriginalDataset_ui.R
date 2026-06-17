source("modules/OriginalDataset/01_OriginalDataset_TableView_ui.R")
source("modules/OriginalDataset/02_OriginalDataset_Upload_ui.R")

original_geneset_UI <- function(ns) {
  tabItem(tabName = "Original_geneset",
    h2(' Custom Genesets Information'),
    original_geneset_tableview_UI(ns),
    original_geneset_upload_UI(ns)
  )
}
    