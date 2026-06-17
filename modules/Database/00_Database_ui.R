source("modules/Database/01_Database_TableView_ui.R")
source("modules/Database/02_Database_Upload_ui.R")

database_UI <- function(ns) {
  tabItem(tabName = "Database",
    h2(' Database and Data Upload'),
    database_tableview_UI(ns),
    database_upload_UI(ns)
  )
}
