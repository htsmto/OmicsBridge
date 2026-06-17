# =============================================================================
# Database Module Wrapper
# File: modules/Database_module.R
# Purpose: UI and Server entry points for the "Database and Data Upload" tab.
#          This module is always initialised at startup (it is not lazy-loaded)
#          because users may need it before navigating anywhere else.
#
# Edit this file when:
#   - Adding a new database sub-panel (table view, upload form, etc.)
#   - Changing which libraries the database tab requires
# =============================================================================

# --- [1] Library + UI source -------------------------------------------------
# libraries_Database.R is sourced here (not in app.R) because it is specific
# to this module. 00_Database_ui.R sources the two sub-panel UI files.
source("libraries/libraries_Database.R")
source("modules/Database/00_Database_ui.R")


# --- [2] UI entry point -------------------------------------------------------
databaseModuleUI <- function(id) {
  ns <- NS(id)
  database_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called immediately at app startup from app.R (not lazy-loaded).
# Server files are sourced inside here so they are only parsed after the
# library is available.
databaseModuleServer <- function(id) {

  # --- [3-1] Source server files -------------------------------------------
  source("modules/Database/01_Database_TableView_server.R", local = TRUE)
  source("modules/Database/02_Database_Upload_server.R",    local = TRUE)

  # --- [3-2] Shared constants -----------------------------------------------
  colour_pallets <- c("viridis", "magma", "plasma", "inferno", "cividis")

  moduleServer(id, function(input, output, session) {

    # --- [3-3] Sub-module servers -------------------------------------------
    database_tableview_Server(input, output, session)
    database_upload_Server(input, output, session)
  })
}
