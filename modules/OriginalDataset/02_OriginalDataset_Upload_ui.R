original_geneset_upload_UI <- function(ns) {
  box(width=12, title=strong('Add a Gene Set'), status='danger', collapsible = TRUE, solidHeader = TRUE,
    h3(''),
    fluidRow( 
      column(4, textInput(ns("Original_geneset_upload_Geneset_name"), "Gene Set Name *")),
      column(3, textInput(ns("Original_geneset_upload_cell_line"), "Cell line/Cell type")), 
      column(3, textInput(ns("Original_geneset_upload_data_generated_from"), "Data source")),
      column(1, 
        div(id='help',
          dropdownButton( 
            fluidRow(
              column(12, h4(strong("Quick upload guide"))),
              column(12, helpText("- The gene set name and the list of the genes are mandatory.")),
              column(12, helpText("- The gene set name must be unique.")),
              column(12, helpText("- Avoid special characters; use only alphabets, numbers, spaces, underscores and dots."))
            ), circle = TRUE, status = "danger", icon = icon("question"), width = "900px",  tooltip = tooltipOptions(title = "Help"), right = TRUE
          )
        ) 
      )
    ),
    fluidRow( 
      column(4, textAreaInput(ns("Original_geneset_upload_genes"), "Genes (line by line) (Gene symbol) *")), 
      column(8, textAreaInput(ns("Original_geneset_upload_description"), "Description"))
    ),

    # action button and status text
    fluidRow( 
      column(3, actionButton(ns('Original_geneset_upload_data'), 'Add Gene Set', style="color: #ffffff; background-color: #bc2929; border-color: #e130f9")),
      column(9, verbatimTextOutput(ns('Original_geneset_status_upload')))
    )
  )
}