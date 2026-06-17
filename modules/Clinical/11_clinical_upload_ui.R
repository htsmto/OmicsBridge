clinical_upload_ui <- function(ns){
    tagList(
        h4(''),

        # Show already registed cohorts
        box(width=12, title='Registered cohort', collapsible = TRUE, status='primary',solidHeader = TRUE,
            DT::dataTableOutput(ns("Cohort_DataBaseTable")),
            h5(''),
            fluidRow( 
                column(2, actionButton(ns('Cohort_DataBase_save_dt'), 'Save changes',style="width:200px;color: #ffffff; background-color: #d82a2a; border-color: #bd0000")), 
                column(2, actionButton(ns('Cohort_DataBase_delete_row'), 'Delete selected data', style="width:200px;color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")), 
                column(2, actionButton(ns('Clinical_data_reload'), 'Reload the database', style="width:200px;color: #ffffff; background-color: #1C9600; border-color: #2A8708")),
                column(6, verbatimTextOutput(ns('Cohort_DataBase_status'))) 
            )
        ),

        # Upload new cohort
        box(width=12, title='Upload',collapsible = TRUE,  status='danger',solidHeader = TRUE,
            h3(""),

            # Upload box. gene expression and survival data. gene expression is mandatory
            fluidRow( 
                column(5, uiOutput(ns("new_cohort_upload_GE"))),
                column(5, uiOutput(ns("new_cohort_upload_sur"))),
                column(1, 
                    div(id='help',
                        dropdownButton( 
                        fluidRow(
                            column(12, h4(strong("Quick upload guide"))),
                            column(12, helpText(strong("- Make sure that the column name for samples (or patients IDs) is set 'sample' and for genes is set 'id'."))),
                            column(12, helpText("- The fist column of the gene expression file must be the samples.")),
                            column(12, helpText("- The Cohort name is mandatory and must be unique.")),
                            column(12, helpText("- Avoid special characters; use only alphabets, numbers, underscores and dots."))
                        ), circle = TRUE, status = "danger", icon = icon("question"), width = "900px",  tooltip = tooltipOptions(title = "Help"), right = TRUE
                        )
                    ) 
                )
            ),

            # Upload box. meta data and mutation data.
            fluidRow( 
                column(5, uiOutput(ns("new_cohort_upload_meta"))),
                column(5, uiOutput(ns("new_cohort_upload_mut"))),
            ),

            # reset button
            fluidRow( 
                column(2, actionButton(ns('new_cohort_upload_reset'), "Reset uploaded files",style="color: #ffffff; background-color: #1C9600; border-color: #2A8708"))
            ),

            # name and description of the new cohort
            fluidRow( column(12, h4('') ) ),
            fluidRow( 
                column(12, h3('') ),
                column(4, textInput(ns("new_cohort_upload_dataset_name"), "Cohort Name*")),
                column(7, textAreaInput(ns("new_cohort_upload_description"), "Description")) 
            ),

            # confirmation button and status
            fluidRow( 
                column(2, actionButton(ns('new_cohort_upload_data'), 'Add a new cohort',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" )), 
                column(6, withSpinner(verbatimTextOutput(ns('new_cohort_status')), type=5, color="#0dc5c1"))
            ),

            # preview
            fluidRow( column(12, h3('') )),
            fluidRow( 
                column(12, h4('Previews') ),
                column(12,
                tabsetPanel(
                    tabPanel('Expression table',  
                        box(width=12,
                            fluidRow(
                                column(12,  verbatimTextOutput(ns("new_cohort_upload_GE_preview_status")) ),
                                column(12,  withSpinner(dataTableOutput(ns("new_cohort_upload_GE_preview")), type=5, color="#0dc5c1") ) # withSpinner(dataTableOutput(ns("CGC_table")), type=5, color="#0dc5c1")),
                            ) 
                        )
                    ),
                    tabPanel('Survival data',  
                        box(width=12, 
                            fluidRow(
                                column(12,  verbatimTextOutput(ns("new_cohort_upload_sur_preview_status")) ),
                                column(12,  withSpinner(dataTableOutput(ns("new_cohort_upload_sur_preview")), type=5, color="#0dc5c1") )
                            ) 
                        )
                    ),
                    tabPanel('Meta data',  
                        box(width=12,
                            fluidRow(
                                column(12,  verbatimTextOutput(ns("new_cohort_upload_meta_preview_status")) ),
                                column(12,  withSpinner(dataTableOutput(ns("new_cohort_upload_meta_preview")), type=5, color="#0dc5c1") )
                            ) 
                        )
                    ),
                    tabPanel('Mutation data',  
                        box(width=12,
                            fluidRow(
                                column(12,  verbatimTextOutput(ns("new_cohort_upload_mut_preview_status")) ),
                                column(12,  withSpinner(dataTableOutput(ns("new_cohort_upload_mut_preview")), type=5, color="#0dc5c1") )
                            ) 
                        )
                    )
                )
                )
            )
        )

    )
}