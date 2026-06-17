# =============================================================================
# DataOverview - GO / Pathway Enrichment: Table
# File: modules/DataOverview/04_02_DataOverview_GO_table.R
# Purpose: Displays the GO/KEGG enrichment result table and provides a
#          download handler for the full result set.
# Edit this file when: changing the table columns shown, page length,
#                       or download format for the enrichment results.
# =============================================================================

go_table_server <- function(input, output, session, goResult, isCalculating) {

    ## Result table
        # status
            GO_goTable_status <- reactiveVal(NULL)
            output$GO_goTable_status <- renderText({ GO_goTable_status() })
        #

        # Show the table
            output$GO_goTable <- DT::renderDataTable({
            if (isCalculating()) {
                tmp <- data.frame(Category = character(0), Generatio = character(0), pvalue = numeric(0), pvalue.adjust = numeric(0), Count = numeric(0))
                return(datatable(tmp) )
            }else{
                if(length(goResult()) == 0 || is.null(goResult())){
                    GO_goTable_status("The results table of GO/KEGG analysis will be shown here.")
                    tmp <- data.frame(Category = character(0), Generatio = character(0), pvalue = numeric(0), pvalue.adjust = numeric(0), Count = numeric(0))
                    return(datatable(tmp))
                }
                else{
                    GO_goTable_status(NULL)
                    return(datatable(as.data.frame(goResult()), option=list(scrollX=TRUE, pageLength = 10, scrollY=TRUE )) )
                }
            }
            })
        #
    ##
}
