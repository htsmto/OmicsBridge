DataOverview_MainPlot_Tables_ui <- function(ns){
    fluidRow(
        column(12, 
            # display the genes of interest (table)
            conditionalPanel(condition = paste0("input['", ns("show_entered_gene_info"), "'] == true"),
                box(title='Information of genes of interest', collapsible=TRUE, status='warning',  width=12,
                    fluidRow( column(12, verbatimTextOutput(ns('Interesting_gene_outFile_status')) )),
                    fluidRow( column(12, withSpinner(dataTableOutput(ns("Interesting_gene_outFile")), type=5, color='#0dc5c1') )),
                    fluidRow( column(12, downloadButton(ns('Interesting_gene_download'),"Download this table") ))
                )
            ),


            # display the filtered area (table)
            conditionalPanel(condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'B' & input['", ns("show_information"), "'] == true"),
                box(title='Filtered genes information', collapsible=TRUE, status='warning', width=12,
                    
                    fluidRow(
                        column(12, h5('\n')),
                        column(12, verbatimTextOutput(ns('filtered_genes_status'))),
                        column(12, withSpinner(dataTableOutput(ns("filtered_gene_table")), type=5, color='#0dc5c1')),
                        column(12, h5('\n')),
                        column(3, downloadButton(ns('filtered_download'),"Download this table")),
                        column(5, 
                            box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', 
                                verbatimTextOutput(ns('filtered_gene_list')) 
                            )
                        )
                    )
                )
            ),


            # display the pathway genes (table)
            conditionalPanel(condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'C' & input['", ns("show_information_pathway"), "'] == true"),
                box(title='Pathway Genes Information', collapsible=TRUE, status='warning', width=12,
                    fluidRow(
                        column(12, h5('\n')),
                        column(12, verbatimTextOutput(ns('outFile3_pathway_status'))),
                        column(12, withSpinner(dataTableOutput(ns("outFile3_pathway")), type=5, color='#0dc5c1')),
                        column(12, h5('\n')),
                        column(3, downloadButton(ns('pathway_download'),"Download this table")),
                        column(5, 
                            box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', 
                                verbatimTextOutput(ns('pathway_gene_list'))
                            )
                        ),
                    )
                )
            ),


            # display the custom gene sets (table)
            conditionalPanel(condition = paste0("input['", ns("show_filterin_input_option"), "'] == 'D' & input['", ns("Plot_Gene_setshow_information"), "'] == true"),
                box(title='Custom Gene Sets Information', collapsible=TRUE, status='warning', width=12,
                    fluidRow(
                        column(12, h5('\n')),
                        column(12, verbatimTextOutput(ns('outFile3_custom_geneset_status'))),
                        column(12, withSpinner(dataTableOutput(ns("outFile3_custom_geneset")), type=5, color='#0dc5c1')),
                        column(12, h5('\n')),
                        column(3, downloadButton(ns('custom_geneset_download'),"Download this table")),
                        column(5, 
                            box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', 
                                verbatimTextOutput(ns('Custom_geneset_gene_list'))
                            )
                        )
                    )
                )
            ),


            # display the information in a selection (table)
            box( title='Selected Area Information', collapsible=TRUE, status='warning', width=12, 
                fluidRow(
                    column(12, h5('\n')),
                    column(12, verbatimTextOutput(ns("outFile2_status"))),
                    column(12, withSpinner(dataTableOutput(ns("outFile2")), type=5, color='#0dc5c1')),
                    column(12, h5('\n')),
                    column(3, downloadButton(ns('selected_download'),"Download this table")),
                    column(5, 
                        box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', 
                            verbatimTextOutput(ns('selected_gene_list')) 
                        )
                    )
                )
            )
        )
    )
}