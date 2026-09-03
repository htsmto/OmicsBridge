clinical_ViewData_ui <- function(ns){
    tabsetPanel(
        # show a gene expression table
        # by default, only show the first 1000 headers, but allow users to show everything 
        tabPanel("Gene Expression",
            box(width=12,
                fluidRow(
                    column(12, h5('')),
                    column(12, verbatimTextOutput(ns('Clinical_View_Geneexpression_status')) ),
                    column(12, radioButtons(ns('Clinical_View_EX_show_number'), '', c("Show the first 1000 headers"='A', 'Show everything (the server will be overloaded depending on the size of the data)'='B'), selected='A')),
                    column(12, DT::dataTableOutput(ns("Clinical_View_Geneexpression")))
                )
            )
        ),

        # show a clinical data table
        tabPanel("Survival", 
            box(width=12,
                fluidRow(
                    column(12, h5('')),
                    column(12, verbatimTextOutput(ns('Clinical_View_Survival_status')) ),
                    column(12, DT::dataTableOutput(ns("Clinical_View_Survival")) )
                )
            )
        ),

        # Show a meta data
        tabPanel("Metadata",
            box(width=12,
                # data table
                fluidRow(
                    column(12, h5('')),
                    column(12, verbatimTextOutput(ns('Clinical_View_MetaData_status')) ),
                    column(12, DT::dataTableOutput(ns("Clinical_View_MetaData")) ),
                    column(12, h2(''))
                ),
                # add a new metadata column or delete a metadata column
                fluidRow(
                    column(12, h4("")),
                    # add a new metadata column
                    column(12, 
                        fluidRow(
                            column(2, 
                                h5('\n'),
                                materialSwitch(ns('Clinical_view_edit_metadata'), strong('Add a new metadata column'), value=FALSE, status='primary')
                            ),
                            column(10, helpText('If you want to add a new metadata column, please click the switch on the left and fill in the new column name and values.'))
                        )
                    ),
                    column(12,  htmlOutput(ns('Clinical_view_edit_metadata_ui')) ),

                    # delete a metadata column
                    column(12,
                        fluidRow(
                            column(2, 
                                h5('\n'),
                                materialSwitch(ns('Clinical_view_delete_metadata_switch'), strong('Delete a metadata column'), value=FALSE, status='primary')
                            ),
                            column(10, helpText('If you want to delete a metadata column, please click the switch on the left and select the column you want to delete.'))
                        )
                    ),
                    column(12,
                        htmlOutput(ns('Clinical_view_delete_metadata_ui'))
                        # conditionalPanel(condition = paste0("input['", ns('Clinical_view_delete_metadata_switch'), "] == true"),
                        #     fluidRow(
                        #         column(4, htmlOutput(ns('Clinical_view_delete_metadata_select'))),
                        #         column(4, verbatimTextOutput(ns('Clinical_view_delete_metadata_status'))),
                        #         column(4, actionButton(ns('Clinical_view_delete_metadata_confirm'), 'Delete the column', style="color: #ffffff; background-color: #40454d; border-color: #bd0000"))
                        #    )
                        # )
                    )
                )
            )
        ),

        # Show a mutation data
        tabPanel("Mutation Data",
            box(width=12,
                fluidRow(
                    column(12, h5('')),
                    column(12, verbatimTextOutput(ns('Clinical_View_mutation_status') )),
                    column(12, DT::dataTableOutput(ns("Clinical_View_Mutation") ))
                )
            )
        )
    )
}