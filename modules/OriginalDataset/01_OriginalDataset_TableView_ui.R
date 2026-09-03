original_geneset_tableview_UI <- function(ns) {
  box(width=12, title=strong('Custom Gene Sets'), status='primary', collapsible = TRUE, solidHeader = TRUE,
    fluidRow(
      column(12,DT::dataTableOutput(ns("Original_geneset_DataBaseTable"))),
      column(2, actionButton(ns('Original_geneset_save_dt'), 'Save changes', style="width:240px; background-color: #1328A8; color: white;")),
      column(2, actionButton(ns('Original_geneset_delete_row'), 'Delete selected gene sets', style="width:240px; color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")),
      column(2, actionButton(ns('Original_geneset_Reload'), 'Refresh list', style="width:240px; color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")),
      column(6, verbatimTextOutput(ns('Original_geneset_status'))),
      
      column(12, helpText('Note: The dataset name (the first column) cannot be edited.'))
    )
  )
}