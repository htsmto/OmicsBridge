# =============================================================================
# Wiki Document Server
# File: modules/wiki_document/00_wiki_document_server.R
# Purpose: Renders the project wiki / documentation pages from markdown files.
#          Provides navigation between sections and renders content as HTML.
# Edit this file when: changing the documentation source path or rendering
#                       approach (e.g. switching from includeMarkdown to shiny::HTML).
# =============================================================================

wiki_document_Server <- function(input, output, session) {
    # show the sessionInfo
        session_info_data <- reactiveVal(paste(capture.output(sessionInfo()), collapse = "\n"))

        observeEvent(input$session_info_refresh, {
            session_info_data(paste(capture.output(sessionInfo()), collapse = "\n"))
        })

        output$session_info <- renderText({
            session_info_data()
        })

}