dataoverview_swarm_UI <- function(ns){
    tagList(
        fluidRow(
            column(12, h4('\n'))
        ),
        fluidRow(
            column(width = 4,
                # Inputs box
                box(status='info', width=12, title=strong('Inputs'), collapsible=TRUE,
                    fluidRow(
                        column(12, helpText(HTML("You can either input gene names manually or select a custom geneset to get the gene names. <br>Once genes are inputted, you can click the gene names in the table to select which genes to show in the swarm plot."))),
                        column(12, htmlOutput(ns("target_genes_manual"))),
                        column(12, materialSwitch(ns("target_genes_from_custom_geneset"), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                        column(12, htmlOutput(ns('target_genes_from_custom_geneset_select'))),
                        column(12, h5('Choose gene(s) from the table below:') ),
                        column(12, verbatimTextOutput(ns('status_gene')) ),
                        column(12, dataTableOutput(ns("target_gene_table")) ),
                    )
                ),

                # Expression scores box
                box(title=strong('Expression scores'),collapsible=TRUE, status='warning', width=12,
                    fluidRow(
                        column(12, helpText(HTML("This table shows the expression scores of the selected genes in the swarm plot. <br>The expression scores are log2 transformed if you choose to use a log scale in the plot options."))),
                        column(12, verbatimTextOutput(ns('status_expression')) ),
                        column(12, htmlOutput(ns('expression_score_multi_input'))),
                        column(12, dataTableOutput(ns("expression_score_table")) ),
                        column(12, downloadButton(ns('outFile_expression_download'),"Download this table")),
                    )
                )                       
            ),
            column( width = 8, 
                box(status='danger', width=12, title=strong('Swarm Plot'),collapsible=TRUE,
                    fluidRow(
                        column(12, helpText(HTML("The swarm plot shows the expression scores of the selected genes across different samples. <br>You can customize the plot using the options on the right. <br>If you want to reorder the groups in the X axis, you can turn on the 'Re-order the X axis' option and enter the group names line by line in the text area. <br>Make sure that the group names you entered exactly match the group names in the dataset."))),
                        column(10, verbatimTextOutput(ns('status_plot')) ),
                        column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                column(6, sliderInput(inputId = ns('Fig.width'), label='fig width', min=300, max=3000, value=800, step=10)),
                                column(6, sliderInput(inputId = ns('Fig.height'), label='fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput(inputId = ns('Pt.size'), 'Point size', min=0.1, max=5, value=1, step=0.1)),
                                column(6, sliderInput(inputId = ns('Xlab.font.size'), label='X label size', min=0, max=10, value=4, step=0.1)),
                                column(6, sliderInput(inputId = ns('Ylab.font.size'), label='Y label size', min=0, max=10, value=4, step=0.1)),
                                column(6, sliderInput(inputId = ns('Graph.title.font.size'), 'Y title size', min=0, max=10, value=4, step=0.1))
                                ),
                                fluidRow(
                                    column(12, materialSwitch(ns('White.background'), 'Use white background', value=FALSE, status = "success"))
                                ),
                                fluidRow(
                                    column(6, materialSwitch(ns('change_colour_pallete'), 'Change the colour pallete', value=FALSE, status = "success")),
                                    conditionalPanel(condition = paste0("input['", ns("change_colour_pallete"), "'] == true"),
                                        column(6, selectInput(ns('select_colour_pallete'), 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                    )
                                ),
                                fluidRow(
                                column(6, materialSwitch(ns('use_single_colour'), 'Use a single colour', value=FALSE, status = "success")),
                                    conditionalPanel(condition = paste0("input['", ns("use_single_colour"), "'] == true"),
                                        column(6, colourpicker::colourInput(ns('choose_single_colour'), 'Choose a colour', value='#000000'))
                                    )
                                ),  
                                circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            ),
                        ),
                        column(12, withSpinner(plotOutput(ns("Swarm_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                        column(12, h4('') ),
                        column(12, materialSwitch(ns("logsclae"), "Use a log scale (log2)", value=FALSE, status='danger')),
                        column(6,
                            fluidRow(
                                column(12, materialSwitch(ns("order_group"), "Re-order the X axis (group names)", value=FALSE, status='danger')),
                                conditionalPanel(condition = paste0("input['", ns("order_group"), "'] == true"),  
                                    column(12, helpText(HTML("Enter the group names line by line in the text area. <br>Only the groups that you listed here will be shown in the plot, and they will be ordered in the way you listed."))),
                                    column(12, textAreaInput(ns("group_order_text"), "Enter the group name", placeholder = "Group1\nGroup2\nGroup3") ),
                                    column(12, verbatimTextOutput(ns('status_order_group')) ), 
                                    column(12,
                                        tags$details(
                                        tags$summary("List of the available group names ▼ (click here)"),  # クリックすると開閉されるタイトル
                                        div(
                                            verbatimTextOutput(ns('group_name_list'))
                                        )
                                        )
                                    )
                                )
                            )
                        ),
                        column(6,
                            fluidRow(
                                column(12, materialSwitch(ns("Exclude_sample"), "Want to exclude specific samples?", value = FALSE, status='danger')),
                                conditionalPanel(condition = paste0("input['", ns("Exclude_sample"), "'] == true"),
                                    column(12, helpText(HTML("Enter the sample names to be excluded line by line in the text area. <br>Make sure that the sample names you entered exactly match the sample names in the dataset."))),
                                    column(12, textAreaInput(ns("Exclude_sample_input"), "Enter sample names to be excluded (line by line)")),
                                    column(12, verbatimTextOutput(ns('status_exclude_sample')) ),
                                    column(12,
                                        tags$details(
                                        tags$summary("List of sample names ▼ (click here)"),  # クリックすると開閉されるタイトル
                                        div(
                                            verbatimTextOutput(ns('Exclude_sample_input_list'))
                                        )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}
    # )
# }