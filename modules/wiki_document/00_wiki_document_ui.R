wiki_document_UI <- function(ns) {
    tagList(
        fluidRow(
            column(12, 
                tags$div(
                    HTML("
                    <br>
                    <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                        The wiki for OmicsBridge is available at 
                        <a href='https://htsmto.github.io/OmicsBridge/' target='_blank' style='color: #007ACC;'>
                        this link
                        </a>.
                    </p>
                    ")
                )
            )
        ),
        fluidRow(
            column(3, h2(' ')),
            column(6, 
                fluidRow(
                    column(12, h4(strong('Session Info'))),
                    column(12, actionButton(ns("session_info_refresh"), "Refresh Session Info")),
                    column(12, h4('')),
                    column(12, verbatimTextOutput(ns("session_info")))
                )
            ),
            column(3, h2(' '))
        )    
    )
}