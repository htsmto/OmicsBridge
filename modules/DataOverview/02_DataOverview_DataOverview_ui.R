source("modules/DataOverview/03_01_DataOverview_Swarm_ui.R")
source("modules/DataOverview/03_02_DataOverview_Correlation_ui.R")
source("modules/DataOverview/03_03_DataOverview_heatmap_ui.R")
source("modules/DataOverview/03_04_DataOverview_PCA_ui.R")
source("modules/DataOverview/04_01_DataOverview_MainPlot_ui.R")
source("modules/DataOverview/04_01_DataOverview_MainPlot_DisplayOption_ui.R")
source("modules/DataOverview/04_01_DataOverview_MainPlot_Tables_ui.R")
source("modules/DataOverview/04_02_DataOverview_GO_ui.R")
source("modules/DataOverview/04_03_DataOverview_GESA_ui.R")
source("modules/DataOverview/04_04_DataOverview_TF_ui.R")

dataoverview_dataoverview_UI <- function(ns){
    box(width=12, title=strong('Overview and Analysis'), status = "primary", solidHeader = TRUE,
        htmlOutput(ns('show_Overview_html'))

    )
}

show_Overview_server <- function(input, output, session, Dataset_dataclass){
    # print the Dataset_dataclass for debugging
    output$show_Overview_html <- renderUI({
        if(length(Dataset_dataclass()) == 0 || is.null(Dataset_dataclass())){
            return(NULL)
        }

        # when a count data is selected
        if(Dataset_dataclass() == 'A'){
            tabsetPanel(
                ## data table
                tabPanel(strong("Data Table"), h4(''), 
                    box(width=12, status='warning', title=strong('Data table'), collapsible=TRUE,
                        fluidRow(
                            column(12, verbatimTextOutput(session$ns('Count_data_DataTable_status'))),
                            column(12, withSpinner(DT::dataTableOutput(session$ns("Count_data_DataTable")), type=5, color='#0dc5c1'))
                        )
                    )
                ),

                ## swarm plot
                tabPanel(strong("Swarm plot"), dataoverview_swarm_UI(session$ns)),

                ## two genes correlation
                tabPanel(strong("Genes correlation"), dataoverview_correlation_UI(session$ns)),

                ## heatmap
                tabPanel(strong("Heatmap"), dataoverview_heatmap_UI(session$ns)),

                ## PCA
                tabPanel(strong("PCA"), dataoverview_pca_UI(session$ns))
            )



        }else if(Dataset_dataclass() == 'B'){
            tabsetPanel(
                ## data table
                tabPanel("Data Table", h4(''), 
                    box(width=12, status='warning', title=strong('Data table'), collapsible=TRUE, 
                        fluidRow(
                            column(12, verbatimTextOutput(session$ns('DataTable_status'))),
                            column(12, withSpinner(DT::dataTableOutput(session$ns("DataTable")), type=5, color='#0dc5c1') )
                        )
                        
                    )
                ),

                ## Plot
                tabPanel(strong("Plot & Downstream Analysis"),

                    ## Main plot part
                    fluidRow(
                        ## Main Plot
                        column(6, DataOverview_MainPlot_ui(session$ns) ),
                        
                        ## Display Options
                        column(6, DataOverview_MainPlot_DisplayOption_ui(session$ns) )
                    ),

                    ## display the selected area information
                    fluidRow(
                        ## display tables
                        column(12, DataOverview_MainPlot_Tables_ui(session$ns) )
                    ),


                    ## Downstream analysis
                    fluidRow(
                        
                        column(12,
                            box( title='Downstream analysis', collapsible=TRUE, status='primary',  width=12, collapsed=FALSE, solidHeader = TRUE,
                                tabsetPanel(

                                    ## GO/KEGG analysis 
                                    tabPanel(strong('GO/KEGG analysis'), DataOverview_GO_ui(session$ns)),

                                    ## GSEA analysis
                                    tabPanel(strong('GSEA analysis'), DataOverview_GSEA_ui(session$ns)),

                                    ## TF activity inference
                                    tabPanel(strong('TF activity inference'), DataOverview_TF_ui(session$ns))
                                )
                            )
                        )
                    )
                )
            )


        }else{
            verbatimTextOutput(session$ns('Data_noselect_message'))
        }



    })
}

