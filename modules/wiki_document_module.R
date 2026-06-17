# =============================================================================
# Wiki Document Module Wrapper
# File: modules/wiki_document_module.R
# Purpose: UI and Server entry points for the Wiki / Documentation tab.
#          Renders the project documentation from markdown files.
#
# Edit this file when:
#   - Changing the wiki rendering approach
#   - Adding additional documentation sources
# =============================================================================

# --- [1] UI source -----------------------------------------------------------
source("modules/wiki_document/00_wiki_document_ui.R")


# --- [2] UI entry point -------------------------------------------------------
wiki_documentModuleUI <- function(id) {
  ns <- NS(id)
  wiki_document_UI(ns)
}


# --- [3] Server entry point ---------------------------------------------------
# Called immediately at app startup from app.R (lightweight module).
wiki_documentModuleServer <- function(id) {

  # --- [3-1] Source server file -------------------------------------------
  source("modules/wiki_document/00_wiki_document_server.R", local = TRUE)

  moduleServer(id, function(input, output, session) {

    # --- [3-2] Sub-module server -------------------------------------------
    wiki_document_Server(input, output, session)
  })
}
