database_tableview_UI <- function(ns){
  box(title='Registered Datasets', width=12, status='primary', solidHeader = TRUE,
    fluidRow(
      column(3, htmlOutput(ns("Seuqenced_by_filter"))), 
      column(3, htmlOutput(ns("Experiment_filter"))), 
      column(3, htmlOutput(ns("Data_type_filter"))),
      column(2, 
        h2('\n'),
        actionButton(ns('Reload'), 'Refresh list', style="width:200px; background-color: #2C43D1; color: white;"))
    ),
    fluidRow(column(12, DT::dataTableOutput(ns("DataBaseTable")) )),
    fluidRow(
      column(12, h3('')),
      column(12,
        fluidRow(
          column(6, 
            fluidRow(
              column(6, actionButton(ns('save_dt'), 'Save changes', style="width:240px; background-color: #1328A8; color: white;")), 
              column(6, actionButton(ns('delete_row'), 'Delete selected datasets', style="width:240px; background-color: #1328A8; color: white;")), 
              column(12, h5('')),
              column(6, actionButton(ns('reset_edit'), 'Discard edits', style="width:240px; background-color: #1328A8; color: white;"))
            )
          ),
          column(6, verbatimTextOutput(ns('status')))
        )
      ),      
      column(12, helpText('Note: The dataset name (the first column) cannot be edited.'))
    )
  )
}
