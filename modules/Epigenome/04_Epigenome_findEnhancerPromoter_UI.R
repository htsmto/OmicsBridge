# =============================================================================
# Epigenome - Find Enhancer/Promoter: UI
# File: modules/Epigenome/04_Epigenome_findEnhancerPromoter_UI.R
# Purpose: UI layout for the "Find Enhancer/Promoter" sub-panel. Calculates
#          the correlation between RNA-seq gene expression and ATAC-seq peak
#          intensity for specified genes across matched samples.
#
# Edit this file when:
#   - Adding or removing input controls for dataset selection or parameters
#   - Changing the results layout (correlation table, data tables, plots)
#   - Adjusting the gene/peak list display section
# =============================================================================

Epigenome_findEnhancerPromoter_UI <- function(ns) {
  tagList(
    h4(''),
    fluidRow(
      column(5,
        box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
          fluidRow(
            column(12,
              fluidRow(
                column(12,
                  helpText("This tool calculates the correlation between RNA-seq gene expression and ATAC-seq peak intensity for a specified gene across matched samples.")
                ),
                column(12, h2('')),
                column(10, htmlOutput(ns('Enhancer_Find_data_select_RNAseq'))),
                column(2,
                  fluidRow(
                    column(12, h2('') ),
                    column(12,
                      div(id='filterin_dropdown',
                        dropdownButton(
                          fluidRow(
                            column(12, h4(strong("Dataset filtering"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_RNAseq_Seuqenced_by"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_RNAseq_Experiments"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_RNAseq_Data_type")))
                          ), circle = FALSE, status = "info", icon = icon("sliders"), width = "300px", tooltip = tooltipOptions(title = "Dataset filtering")
                        )
                      )
                    )
                  )
                ),
                column(12, helpText("The column names of the RNAseq data:")),
                column(12, verbatimTextOutput(ns('Enhancer_Find_data_select_RNAseq_SampleNames'))),
              )
            ),
            column(12,
              fluidRow(
                column(10, htmlOutput(ns('Enhancer_Find_data_select_ATACseq'))),
                column(2,
                  fluidRow(
                    column(12, h2('') ),
                    column(12,
                      div(id='filterin_dropdown',
                        dropdownButton(
                          fluidRow(
                            column(12, h4(strong("Dataset filtering"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_ATACseq_Seuqenced_by"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_ATACseq_Experiments"))),
                            column(12, htmlOutput(ns("Enhancer_Find_data_select_ATACseq_Data_type")))
                          ), circle = FALSE, status = "info", icon = icon("sliders"), width = "300px", tooltip = tooltipOptions(title = "Dataset filtering")
                        ),
                      )
                    )
                  )
                ),
                column(12, helpText("The column names of the ATACseq data:")),
                column(12, verbatimTextOutput(ns('Enhancer_Find_data_select_ATACseq_SampleNames'))),
              )
            ),
            column(12,
              fluidRow(
                column(12, h2(' ')),
                column(12,
                  helpText(HTML(
                    "Below, enter matching sample names from the RNA-seq and ATAC-seq tables. <br>
                    One pair per line, separated by a comma. At least 3 pairs are required. <br>
                    <br>
                    Example: <br>
                    \tSample1_RNA_Rep1,Sample1_ATAC_Rep1"
                  ))
                ),
                column(12, textAreaInput(ns('Enhancer_Find_sample_select'), 'Enter sample names (RNA_sample,ATAC_sample)', placeholder = 'Name in RNAseq,Name.in.ATACseq \nSample1_RNA_Rep1,Sample1_ATAC_Rep1\nSample2_RNA_Rep1,Sample2_ATAC_Rep1')),
                column(12, verbatimTextOutput(ns('Enhancer_Find_sample_status'))),
                column(12, textAreaInput(ns('Enhancer_Find_input_gene'), 'Enter genes (line by line)', placeholder='Gene1\nGene2\nGene3')),
                column(12, materialSwitch(ns('Enhancer_Find_use_custom_geneset'), 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                column(12,
                  conditionalPanel(
                    condition = paste0("input['", ns('Enhancer_Find_use_custom_geneset'), "'] == true"),
                    htmlOutput(ns('Enhancer_Find_custom_geneset_select'))
                  )
                ),
                column(12, verbatimTextOutput(ns('Enhancer_Find_gene_status')))
              )
            ),
            column(12,
              fluidRow(
                column(12, h2('')),
                column(12, radioButtons(ns("Enhancer_Find_calculation_type"), "Calculation type", choices = c('pearson', 'spearman'), selected='spearman', inline=TRUE )),
                column(6, numericInput(ns('Enhancer_Find_extend_length'), 'See ±Xbp around the gene', value=100000, min=0, step=100)),
                column(6, h3(''))
              ),
              fluidRow(
                column(12, materialSwitch(ns('Enhancer_Find_chr_focus'), 'Check only the same chromosomes of the target genes', value=TRUE, status='info') ),
                column(12, helpText('Note: If this is NOT checked, it takes very long time to calculate the correlation.')),
                column(12, h3('')),
                column(12, actionButton(ns('Enhancer_Find_start'), 'Find enhancers/promoters', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
              )
            )
          )
        )
      ),
      column(7,
        fluidRow(
          column(12,
            box(width=12, title='Results', status='warning', collapsible = TRUE,
              # Three tabs: 1) Correlation result, 2) RNAseq data table, 3) ATACseq data table
              tabsetPanel(
                tabPanel('Correlation result',
                  h4(''),
                  fluidRow(
                    column(12, verbatimTextOutput(ns('Enhancer_Find_table_status')) ),
                    column(12, withSpinner(DT::dataTableOutput(ns('Enhancer_Find_table')), type = 5, color = "#0dc5c1") ),
                    column(12, h4('')),
                    column(12, downloadButton(ns('Enhancer_Find_table_status_download'), "Download this table")),
                    column(12, h4('')),
                    column(10, verbatimTextOutput(ns('Enhancer_Find_table_plot_status'))),
                    column(2,
                      dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_fig.width'), label='Fig width', min=300, max=3000, value=600, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_fig.height'), label='Fig height (heatmap part)', min=300, max=3000, value=600, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_font_size'), label='X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_label_font_size'), label='X/Y label font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_title_size'), label='Graph title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_table_plot_legend_font_size'), label='Label size', min=0.1, max=5, value=1, step=0.1))
                        ),
                        fluidRow(
                          column(6, materialSwitch(ns('Enhancer_Find_table_plot_label'), 'Hide labels', status = "success")),
                          column(6, materialSwitch(ns('Enhancer_Find_table_plot_correlation'), 'Show the correlation line', status = "success")),
                          column(6, colourpicker::colourInput(ns('Enhancer_Find_table_plot_point_col'), 'Point colour', value='blue')),
                        ),
                        circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px", tooltip = tooltipOptions(title = "Plot Options")
                      )
                    ),
                    column(12, withSpinner(plotOutput(ns("Enhancer_Find_table_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                  )
                ),
                tabPanel('RNAseq data table',
                  h4(''),
                  fluidRow(
                    column(12, verbatimTextOutput(ns('Enhancer_Find_RNAseq_data_status')) ),
                    column(12, withSpinner(DT::dataTableOutput(ns('Enhancer_Find_RNAseq_data_table')), type = 5, color = "#0dc5c1") ),
                    column(12, h4('')),
                    column(10, verbatimTextOutput(ns('Enhancer_Find_RNAseq_data_plot_status'))),
                    column(2,
                      dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_plot_fig.width'), label='Fig width', min=300, max=3000, value=1000, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_plot_fig.height'), label='Fig height (heatmap part)', min=300, max=3000, value=900, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_plot_font_size'), label='X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_plot_label_font_size'), label='X/Y label font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_plot_title_size'), label='Graph title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_RNAseq_data_legend_size'), label='Legend size', min=0.1, max=10, value=4, step=0.1))
                        ),
                        fluidRow(
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_RNAseq_data_plot_max_col'), 'Point colour', value='red')),
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_RNAseq_data_plot_min_col'), 'Point colour', value='blue')),
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_RNAseq_data_plot_mid_col'), 'Point colour', value='white')),
                        ),
                        circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px", tooltip = tooltipOptions(title = "Plot Options")
                      )
                    ),
                    column(12, withSpinner(plotOutput(ns("Enhancer_Find_RNAseq_data_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                  )
                ),
                tabPanel('ATACseq data table',
                  h4(''),
                  fluidRow(
                    column(12, verbatimTextOutput(ns('Enhancer_Find_ATACseq_data_status')) ),
                    column(12, withSpinner(DT::dataTableOutput(ns('Enhancer_Find_ATACseq_data_table')), type = 5, color = "#0dc5c1") ),
                    column(10, verbatimTextOutput(ns('Enhancer_Find_ATACseq_data_plot_status'))),
                    column(2,
                      dropdownButton( h4(strong("Plot Options")),
                        fluidRow(
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_plot_fig.width'), label='Fig width', min=300, max=3000, value=1000, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_plot_fig.height'), label='Fig height (heatmap part)', min=300, max=3000, value=900, step=10)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_plot_font_size'), label='X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_plot_label_font_size'), label='X/Y label font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_plot_title_size'), label='Graph title font size', min=0.1, max=10, value=4, step=0.1)),
                          column(6, sliderInput(inputId = ns('Enhancer_Find_ATACseq_data_legend_size'), label='Legend size', min=0.1, max=10, value=4, step=0.1))
                        ),
                        fluidRow(
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_ATACseq_data_plot_max_col'), 'Point colour', value='red')),
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_ATACseq_data_plot_min_col'), 'Point colour', value='blue')),
                          column(4, colourpicker::colourInput(ns('Enhancer_Find_ATACseq_data_plot_mid_col'), 'Point colour', value='white')),
                        ),
                        circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px", tooltip = tooltipOptions(title = "Plot Options")
                      )
                    ),
                    column(12, withSpinner(plotOutput(ns("Enhancer_Find_ATACseq_data_plot"), width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                  )
                )
              )
            )
          ),
          column(12,
            box(width=12, title='Show the potential enhancer/promoter list', status='danger', collapsible = TRUE,
              fluidRow(
                column(4,
                  fluidRow(
                    column(12, htmlOutput(ns('Enhancer_Find_gene_selection'))),
                    column(12, numericInput(ns('Enhancer_Find_show_list_threshold'), 'P-value threshold', value=0.05, min=0, step=0.001))
                  )
                ),
                column(8,
                  fluidRow(
                    column(12, h2('')),
                    column(9, verbatimTextOutput(ns('Enhancer_Find_gene_correlated_peak_list')))
                  ))
              )
            )
          )
        )
      )
    )
  )
}
