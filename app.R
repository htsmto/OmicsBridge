#### Load packages and setting ####
  suppressMessages(library(shiny))
  suppressMessages(library(shinydashboard))
  suppressMessages(library(ggplot2))
  suppressMessages(library(ggbeeswarm))
  suppressMessages(library(patchwork))
  suppressMessages(library(igraph))
  suppressMessages(library(tidyr))
  suppressMessages(library(dplyr))
  suppressMessages(library(DT))
  suppressMessages(library(ggrepel))
  suppressMessages(library(GSEABase)) # BiocManager::install("GSEABase")
  suppressMessages(library(GSVA)) # BiocManager::install('GSVA')
  suppressMessages(library(tibble))
  suppressMessages(library(fgsea))
  suppressMessages(library(clusterProfiler)) # BiocManager::install("clusterProfiler")
  suppressMessages(library(org.Hs.eg.db)) # BiocManager::install("org.Hs.eg.db")
  suppressMessages(library(org.Mm.eg.db)) # BiocManager::install("org.Mm.eg.db")
  suppressMessages(library(forcats))
  suppressMessages(library(decoupleR))  # BiocManager::install("decoupleR")
  suppressMessages(library(igvShiny)) # BiocManager::install("igvShiny")
  suppressMessages(library(GenomicAlignments)) # BiocManager::install("GenomicAlignments")
  suppressMessages(library(colourpicker))
  suppressMessages(library(stringr))
  suppressMessages(library(Cairo))

  options(shiny.maxRequestSize = 1000*1024^2)
  options(shiny.usecairo=TRUE)
  options(scipen = 10)
  set.seed(123)
  options(scipen = 10)
  set.seed(123)
  # colour_pallets <- c('Set1', 'Set2', 'Set3', 'Accent', 'Dark2', 'Paired', 'Pastel1', 'Pastel2', 'Blues', 'BuGn', 'BuPu', 'GnBu', 'Greens', 'Greys', 'Oranges', 'OrRd', 'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu', 'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd', 'BrBG', 'PiYG', 'PRGn', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral')
  colour_pallets <- c('viridis', 'magma', 'plasma', 'inferno', 'cividis')
  human_mouse_biomart_data <- read.table('data/biomart_comparison_chart.tsv', sep='\t',header=T)
####


##############################################################################
ui <- fluidPage(

  # Setting for put the login object in the center of the page
  tags$head(
      tags$style(HTML("
          .centered-container { display: flex; justify-content: center; align-items: center; height: 80vh; }
          .login-box { width: 300px; padding: 20px; border: 1px solid #ccc; border-radius: 8px; box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1); background-color: #f9f9f9; }
          #Original_geneset_DataBaseTable table.dataTable tbody tr { height: 50px !important; }
      "))
  ),

  dashboardPage(
    dashboardHeader(
      title=NULL,
      titleWidth = 0,
      tags$li(
        class = "dropdown",
        tags$div(class = "custom-title", "OmicsBridge"),
        style="position: absolute; left: 50%; transform: translateX(-50%); top: 20%; font-family: 'Hachi Maru Pop', sans-serif !important;",
      ),
      tags$li(
        span(
          textOutput('user_name_display'),
          style='color: white;'
        ),
        class = "dropdown",
        style="margin-right: 30px"
      )
    ),

    ### Side bar ####
      dashboardSidebar(width = 300, collapsed = TRUE, 
        sidebarMenu(
          menuItem("Home", tabName='home', icon=icon('home')),
          menuItem("Database", tabName='Database', icon=icon('table')),
          menuItem("Data Overview", tabName='Data_Overview', icon=icon('chart-bar')),
          menuItem("Gene sets", tabName='Original_geneset', icon=icon('chart-bar')),
          menuItem("Compare across datasets", tabName='Compare_across_datasets', icon=icon('chart-bar')),
          menuItem("Integrate two data", tabName='Integrate_two_dataset', icon=icon('chart-bar')),
          menuItem("Clinical data", tabName='Clinical_dataset', icon=icon('chart-bar')),
          menuItem("scRNA", tabName='scRNA', icon=icon('chart-bar')),
          menuItem("Genome browser (IGV)", tabName='igv', icon=icon('chart-bar')),
          menuItem("Tools", tabName='Tools', icon=icon('chart-bar')),
          menuItem("Wiki(Document)", tabName='wiki_document', icon=icon('chart-bar'))
        ),
        tags$div(
          style = "position: absolute; bottom: 10px; width: 100%; text-align: center;",
          tags$img(src = 'DKFZ_blue.png', width= "80%")
        )
      ),
    ###

    # Main body
    dashboardBody(
      ## website illustration setting
        tags$head(tags$style(HTML("
          .main-header .sidebar-toggle::after {
            content: ' MENU';
            font-size: 22px;
            color: white;
            padding-left: 5px;
            font-family: Helvetica, Arial, serif !important;
            font-weight: bold;
          }         
          .custom-title-container {
            flex-grow: 1;
            text-align: center;
          }
          .custom-title {
            font-size: 36px !important;  
            font-weight: bold !important; 
            color: #FFFFFF !important;  
            text-align: center !important;
            font-family: 'Hachi Maru Pop', sans-serif !important;
          }
          .main-header {
            background-color: #042bca !important;
            height: 65px !important; 
            align-items: center !important;
            padding: 0; 
          }
          .main-header .navbar {
            background-color: #042bca  !important;
          }
          .main-header .logo {
            background-color: #042bca !important;
            font-family: Helvetica, Arial, serif !important;
            font-weight: bold !important;
          }
          .main-sidebar {
            background-color: #FFFFFF !important;
            top: 20px !important;
            font-size: 18px;
          }
          body {
            font-family: Helvetica, Arial, serif !important;
          }
          h1, h2, h3, h4, h5, h6 {
            font-family: Helvetica, Arial, serif !important;
          }
          .shiny-input-container, .shiny-output-container {
            font-family: Helvetica, Arial, serif !important;
          }
          .sidebar-menu > li > a {
            color: #000000 !important;
          }
          .sidebar-menu > li > a:hover {
            color: #FFFFFF !important;
          }
          .sidebar-menu .active a{
            color: #2100dc !important;
            background-color: #c3e1ff !important;
            font-weight: bold !important;
          }
          .content-wrapper {
            background-color:#f1f8ff !important;
            top: 20px !important;
          }
        "))),
      ##
      tabItems(
        #### Home ####
          tabItem( tabName='home',
            tags$div(
              style='align=center; align-items:center; justify-content: center',
              HTML("
                <h2 style='text-align: center; font-family: Helvetica, Arial, serif !important; font-size: 26px;'><u><b>
                  Unlock the Full Potential of Your Omics Data
                </b></u></h2>
                <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                  Acquiring and analysing multiple omics datasets is now common practice, even in labs without a strong bioinformatics background. <br>
                  However, integrating and managing large, multidimensional datasets remains a challenge, often leading to underutilised data and missed discoveries.
                </p>
                <br>
                <h2 style='text-align: center; font-family: Helvetica, Arial, serif !important; font-size: 26px;'><u><b>
                  Why Use Our Interface?
                </b></u></h2>
                <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                  🔹 Seamless Data Integration – Combine datasets from multiple omics layers to uncover hidden biological insights. <br>
                  🔹 Custom Gene Sets – Define key genes from clinical or functional data and apply them across experiments. <br>
                  🔹 Comparative Analysis – Identify trends and reproducibility by comparing numerical scores across datasets. <br>
                  🔹 Clinical Relevance Exploration – Evaluate genes in patient cohorts to assess therapeutic significance. <br>
                  🔹 Interactive Visualisations & Quick Analysis – Adjust thresholds, filter data, and perform GO analysis or GSEA—no coding required.
                </p>
                <br>
                <h2 style='text-align: center; font-family: Helvetica, Arial, serif !important; font-size: 26px;'><u><b>
                  Stay Organised & Maximise Your Research
                </b></u></h2>
                <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                  Our platform also functions as a centralised database, ensuring stress-free access to your datasets at any time.
                </p>
                <br>
              ")
            ),
            tags$div(
              style='display: flex; align-items: center; align="center"',
              tags$img(src="interface_overview.png", style='width:1200px; margin-left:auto !important; margin-right:auto !important')
            ),
            tags$div(
              HTML("
                <br>
                <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                  Make your data work for you. Start uncovering meaningful biological connections today.
                </p>
              ")
            )
            # uiOutput("home_md")
          ),
        #### Database ####
          tabItem( tabName='Database',
            h2('Database Information'),
            ## Data Table ##
            box(title='List of the datasets', width=12, status='primary',
              fluidRow(column(3, htmlOutput("Data_type_filter")), column(3, htmlOutput("Seuqenced_by_filter"))),
              DT::dataTableOutput("DataBaseTable"),
              fluidRow( column(1, actionButton('save_dt', 'Save changes')), column(2, actionButton('delete_row', 'Delete selected data')), column(7, verbatimTextOutput('status')) )
            ),
            ## Data Upload ##
            box(width=12,  collapsible=TRUE, title='Data upload',status='primary',
              tags$style(HTML("
                /* font, size etc for the toggle title */
                summary {
                  font-weight: bold;  
                  color: #007bff;  
                  cursor: pointer;  /* qulick available */
                  padding: 5px;
                  background-color: #f0f0f0;  
                  border-radius: 5px;
                }
                
                details[open] div {
                  background-color: #e9fffe;  
                  padding: 10px;
                  border-radius: 5px;
                }
                
                /* setting for listing up */
                ul {
                  list-style-type: disc;  /* round  shape */
                  margin-left: 20px;  /* indent to left */
                }
                li {
                  margin-bottom: 5px;  /* space between lines */
                }
              ")),              
              tags$details(
                tags$summary("Quick upload guide ▼"),  # クリックすると開閉されるタイトル
                div(
                  # 箇条書きのリスト
                  tags$ul(
                    tags$li("Make sure that the column name containing gene names is set 'id'."),
                    tags$li("The boxes with * are mandatory."),
                    tags$li("Avoid special characters; use only alphabets, numbers, underscores and dots."),
                    tags$li("Dataset name must be unique."),
                    tags$li("In case uploading a count data, it is recommended that the columns are set to Sample_Rep#. See wiki for more information.")
                  )
                )
              ),
              h4(""),
              h4(""),
              fluidRow( column(4, fileInput("upload_file", "Upload a file"))),
              fluidRow( column(2, textAreaInput("upload_dataset_name", "Dataset name *")), column(2, textAreaInput("upload_Experiment", "Experiment name *")), column(2, textAreaInput("upload_data_from", "Data from *")), column(2, textAreaInput("upload_data_type", "Data type *")), column(2, textAreaInput("upload_cell_line", "Cell line")), column(2, textAreaInput("upload_when", "Wann")) ),
              fluidRow( column(3, selectInput('upload_Data_Class', 'Data Class *', c('A: Count data/Expression matrix'='A', 'B: Comparison data (Any table contain log fold change velues)'='B', 'C: single cell RNA'='C' ), selected='B')), 
                conditionalPanel(
                  condition = 'input.upload_Data_Class=="B"',
                  column(2, textAreaInput("upload_Control_group", "Control group name")), 
                  column(2, textAreaInput("upload_Treatment_group", "Treatment group name"))
                )
              ),
              fluidRow( column(4, textAreaInput("upload_description", "Description")) ),
              fluidRow( column(2, actionButton('upload_data', 'Add to the dataset')), column(6, verbatimTextOutput('status_upload'))),
              fluidRow(
                column(12, h4('Preview:')),
                column(12, dataTableOutput("upload_data_preview"))
              )
            )
          ),
        #### Data_Overview ####
          tabItem( tabName='Data_Overview',
            h2('Data Overview'),
            ##### Data selection #####
              box(width=12, collapsible=TRUE, title='Dataset Selection', status='primary',
                fluidRow(
                  column(7, htmlOutput("Dataset_select")),
                  column(4, h5('Dataset detail:'), verbatimTextOutput('Dataset_detail'))
                ),
                h5('Dataset filtering'),
                fluidRow( column(2, htmlOutput("Seuqenced_by")), column(5, htmlOutput("Experiments")), column(4, htmlOutput("Data_type")) )
              ),
            ##### Plot #####
            box(width=12, status='primary',
              ###### Message when nothing is selected
                conditionalPanel(
                  condition = "output.Data_class != 'A' & output.Data_class != 'B'",
                  verbatimTextOutput('Data_Overview_plot')
                ),
              ###### when Count talbe is slected. (table, swarm plot, heatmap) ######
                conditionalPanel(
                  condition = "output.Data_class == 'A'",
                  tabsetPanel(
                    ####### table #######
                      tabPanel("Data Table", box(width=12, status='primary', verbatimTextOutput('Count_data_DataTable_status'), DT::dataTableOutput("Count_data_DataTable")) ),
                    ####### swarm plot #######  
                      tabPanel("Swarm plot", 
                        box(status='primary', width=8,
                          column(4,
                            fluidRow(
                              column(12, textAreaInput("target_gene_for_RNA", "Enter genes")),
                              h5('Choose the row from the table blow:'),
                              column(12,  dataTableOutput("target_gene_for_RNA_table") ),
                            )
                          ),
                          column(8,
                            fluidRow(
                              verbatimTextOutput('Gene_ex_swarm_status'),
                              column(12, plotOutput("Gene_ex_swarm", width="100%", height="100%")),
                              column(12, checkboxInput("order_group", "Re-order the X axis (group names)", value=FALSE)),
                              column(12, conditionalPanel( condition = "input.order_group == true",  textAreaInput("group_order", "Enter the group name line by line") )),
                              column(12, conditionalPanel( condition = "input.order_group == true", h5('List of the available group names'), verbatimTextOutput("Data_Overview_Swarm_group_name_list") ))
                            )
                          )
                        ),
                        box(title='Expression scores',collapsible=TRUE, status='primary', width=4, 
                          dataTableOutput("outFile_expression"),
                          downloadButton('outFile_expression_download',"Download this table")
                        ),
                        box(title='Plot option', collapsible=TRUE,  width=12, collapsed = TRUE,
                          fluidRow(
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_fig.width', label='fig width', min=300, max=3000, value=500, step=10)),
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_pt.size', 'Point size', min=1, max=10, value=5, step=0.5)),
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_xlab.font.size', label='X label size', min=1, max=20, value=10, step=1)),
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_ylab.font.size', label='Y label size', min=1, max=20, value=10, step=1)),
                            column(4, sliderInput(inputId = 'Data_Overview_Swarm_graph.title.font.size', 'Graph title font size', min=1, max=40, value=10, step=1))
                          ),
                          fluidRow(
                            column(4, checkboxInput('Data_Overview_Swarm_white_background', 'Use white background', value=FALSE))
                          ),
                          fluidRow(
                            column(3, checkboxInput('Data_Overview_Swarm_change_colour_pallete', 'Change the colour pallete', value=FALSE)),
                            conditionalPanel(
                              condition = "input.Data_Overview_Swarm_change_colour_pallete == true",
                              column(3, selectInput('Data_Overview_Swarm_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                            )
                          ),
                          fluidRow(
                            column(3, checkboxInput('Data_Overview_Swarm_use_single_colour', 'Use a single colour', value=FALSE)),
                            conditionalPanel(
                              condition = "input.Data_Overview_Swarm_use_single_colour == true",
                              column(3, colourInput('Data_Overview_Swarm_choose_single_colour', 'Choose a colour', value='#000000'))
                            )
                          ),                  
                        )
                      ),
                    ####### heatmap #######  
                      tabPanel("Heatmap", 
                        box(collapsible=TRUE, status='primary', width=12,
                          fluidRow(
                            column(3, 
                              fluidRow(
                                column(12, radioButtons('Data_Overview_heatmap_target_gene_type', 'Genes from', choices = c('Text input'='A', 'Custom Gene Sets'='B', 'HALLMARK (Human)'='C', 'HALLMARK (Mouse)'='D', 'input a gmt file'='E'), selected='A')),
                                column(12, verbatimTextOutput('Data_Overview_heatmap_target_gene_type_status')),
                                conditionalPanel(
                                  condition = "input.Data_Overview_heatmap_target_gene_type == 'A'",
                                  column(12, textAreaInput("Data_Overview_heatmap_target_genes", "Enter genes"))
                                ),
                                conditionalPanel(
                                  condition = "input.Data_Overview_heatmap_target_gene_type != 'A'",
                                  conditionalPanel(
                                    condition = "input.Data_Overview_heatmap_target_gene_type == 'E'",
                                    column(12, fileInput("Data_Overview_heatmap_target_upload_custom_pathway", "Upload a gmt file"))
                                  ),
                                  column(12, htmlOutput("Data_Overview_heatmap_target_select_geneset"))
                                ),
                                h4('Choose the samples to use below:'),
                                column(12,  dataTableOutput("Data_Overview_heatmap_sample_table"))
                              )),
                            column(9, 
                              fluidRow(
                                column(5, sliderInput(inputId = 'Cluster_num', label='Cluster number', min=1, max=20, value=1, step=1))
                              ),
                              actionButton('Gene_Overview_heatmap_start', 'Generate a heatmap'),
                              h4(''),
                              verbatimTextOutput('Data_Overview_heatmap_status'),
                              plotOutput("Data_Overview_heatmap_plot", width="100%", height="100%")
                            )
                          )
                        ),
                        box(title='Plot options', collapsible=TRUE, status='primary', width=12, collapsed=TRUE,
                          fluidRow(
                            column(6, sliderInput(inputId = 'Data_Overview_heatmap_fig.width', label='fig width', min=300, max=3000, value=1000, step=10)),
                            column(6, sliderInput(inputId = 'Data_Overview_heatmap_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                            column(6, sliderInput(inputId = 'Data_Overview_heatmap_xlab.font.size', label='X label size', min=1, max=20, value=6, step=1)),
                            column(6, sliderInput(inputId = 'Data_Overview_heatmap_ylab.font.size', label='Y label size', min=1, max=20, value=10, step=1)),
                            column(4, colourInput(inputId = 'Data_Overview_heatmap_col_high', 'Colour for the highest value', value='red')),
                            column(4, colourInput(inputId = 'Data_Overview_heatmap_col_low', 'Colour for the lowest value', value='blue')),
                            column(4, colourInput(inputId = 'Data_Overview_heatmap_col_mid', 'Colour for value = 0', value='white')),
                            column(4, checkboxInput('Data_Overview_heatmap_white_background', 'Use white background', value=FALSE))
                          )
                        ),
                        box(title='Expression scores', collapsible=TRUE, status='primary', width=12, 
                          dataTableOutput("Data_Overview_heatmap_expression"),
                          downloadButton('Data_Overview_heatmap_expression_download',"Download this table")
                        )
                      ),
                    ####### PCA ####### 
                      tabPanel("PCA plot",
                        box(width=8, title='Plot', collapsible = TRUE,
                          verbatimTextOutput('Data_Overview_PCA_status'),
                          plotOutput("Data_Overview_PCA_plot", width="100%", height="100%"),
                          # dataTableOutput("Data_Overview_PCA_plot_tmp")
                        ),
                        box(width=4, title="Settings", collapsible = TRUE,  
                          radioButtons('Data_Overview_PCA_Setting', 'Please chosse', choices = c('Default setting'='A', 'Define the groups'='B'), selected='A'),
                          conditionalPanel(
                            condition = "input.Data_Overview_PCA_Setting == 'B'",
                            h4("Please specify the sample names and their group names that you want to use as the following example."),
                            h4("Ex.)"),
                            h4("    Sample1_rep1,Group1"),
                            h4("    Sample1_rep2,Group1"),
                            h4("    Sample2_rep1,Group2"),
                            h4("    ..."),
                            textAreaInput("Data_Overview_PCA_Setting_group_define", "Enter the group description")
                          ),
                          actionButton('Data_Overview_PCA_Start', 'Generate a PCA plot'),
                          h3(""),
                          tags$details(
                            tags$summary("List of sample names ▼"),  # クリックすると開閉されるタイトル
                            div(
                              verbatimTextOutput('Data_Overview_PCA_Sample_list')
                            )
                          ),
                        ),
                        box(width=8, title='Plot options', collapsible = TRUE, collapsed = TRUE,
                          fluidRow(
                            column(6, sliderInput(inputId = 'Data_Overview_PCA_fig.width', label='fig width', min=300, max=3000, value=850, step=10)),
                            column(6, sliderInput(inputId = 'Data_Overview_PCA_fig.height', label='fig height', min=300, max=3000, value=750, step=10))
                          ),
                          fluidRow(
                            column(6, sliderInput(inputId = 'Data_Overview_PCA_xy.font.size', label='X/Y label size', min=10, max=40, value=15, step=1)),
                            column(6, sliderInput(inputId = 'Data_Overview_PCA_xy.title.size', label='Y/Y title size', min=10, max=40, value=20, step=1))
                          ),
                          fluidRow(
                            column(4, sliderInput(inputId = 'Data_Overview_PCA_point_size', 'Points size', min=1, max=20, value=5, step=1)),
                            column(4, sliderInput(inputId = 'Data_Overview_PCA_label_size', 'Sample label side', min=1, max=20, value=3, step=1)),
                            column(4, sliderInput(inputId = 'Data_Overview_PCA_legend_size', 'Legend size', min=10, max=40, value=15, step=1))
                          ),
                          fluidRow(
                            column(4, checkboxInput('Data_Overview_PCA_change_colour_by_group', 'Colour by groups', value=TRUE)),
                            column(4, checkboxInput('Data_Overview_PCA_label_hide', 'Hide labels', value=FALSE)),
                            column(4, checkboxInput('Data_Overview_PCA_white_background', 'Use white background', value=FALSE))
                          )
                        )
                      )
                    #
                  )
                ),
              ###### when type B is slected ######
                conditionalPanel(
                  condition = "output.Data_class == 'B'",
                  tabsetPanel(
                    ####### Table #######
                      tabPanel("Data Table", box(width=12, status='primary', DT::dataTableOutput("DataTable")) ),  
                    ####### Plot #######  
                      tabPanel("Plot",
                        box(title='Main plot', collapsible=TRUE, status='primary', width=6,
                          verbatimTextOutput('Gene_ex_status'),
                          plotOutput("Gene_ex", brush = "plot_brush", width="100%", height="100%"),
                          conditionalPanel(
                            condition = " input.show_outliers_bar_plot == true ",
                            plotOutput("Gene_ex_barplot", width="100%", height="100%", hover=hoverOpts("barplot_plot_hover")),
                            verbatimTextOutput("hover_info")
                          )
                        ),
                        conditionalPanel(
                          condition = "output.Data_class == 'B'",
                          box( title='Display Options',  collapsible=TRUE, status='primary',width=6,
                            # select x and y
                            fluidRow( 
                              column(3, htmlOutput("Scat.X")), 
                              column(3, htmlOutput("Scat.Y")),
                              column(4, checkboxInput('while_background', 'Use white background', value=FALSE))
                            ),
                            # when highlighting specific genes
                            fluidRow(
                              column(4, textAreaInput("target_gene", "Enter gene(s) of interest (line by line)")),
                              column(4, checkboxInput("show_label", "show gene names", value=FALSE)),
                              column(4, checkboxInput("show_entered_gene_info", "show information as a table", value=FALSE)),
                              column(4, checkboxInput("interesting_gene_colour", "change the highlight colour", value=FALSE)),
                              conditionalPanel(
                                condition = "input.interesting_gene_colour == true",
                                  column(4, colourInput('interesting_gene_colour_id', 'select colour:', value='red'))
                              )
                            ),
                            verbatimTextOutput('Scatter_interesting_gene_status'),
                            checkboxInput('show_outliers', 'Show outliers', value=FALSE),
                            checkboxInput('show_pathway', 'Show pathway genes', value=FALSE),
                            checkboxInput('Plot_Gene_set', 'Show custom genesets', value=FALSE),
                            # outlier option
                            conditionalPanel(
                              condition = "input.show_outliers == true",
                              box(width=12,
                                fluidRow(
                                  column(12, radioButtons("How_to_filter", "How to filter:", choices = c("Show top/bottom N % (default: 10%)"="A", "Custom threshold setting"="B"), selected='B')),
                                ),
                                conditionalPanel(
                                  condition = "input.How_to_filter == 'A'",
                                  fluidRow(
                                    column(6, sliderInput('Overviwe_Top_threshold', 'The threshold for Top hits (%)', min=0, max=100, value=10, step=1)),
                                    column(6, sliderInput('Overviwe_Bottom_threshold', 'The threshold for Bottom hits (%)', min=0, max=100, value=10, step=1)),
                                    column(6, sliderInput('Overviwe_Top_bottom_Y_threshold', 'The threshold for Y axis', min=0, max=20, value=0, step=0.1))
                                  )
                                ),
                                conditionalPanel(
                                  condition = "input.How_to_filter == 'B'",
                                  fluidRow(
                                    column(4, radioButtons("Direction", "Use", choices = c("both positive & negative side"='A', "only positive side"='B', "only negative side"='C'), selected='B')),
                                    column(4, 
                                      fluidRow(column(12, sliderInput('x_threshold', 'The threshold for X axis (positive)', min=0, max=10, value=1, step=0.1))),
                                      fluidRow(column(12, sliderInput('x_threshold_neg', 'The threshold for X axis (negative)', min=0, max=10, value=1, step=0.1)))
                                    ),
                                    column(4, sliderInput('y_threshold', 'The threshold for Y axis', min=0, max=20, value=1.3, step=0.1))                                    
                                  )
                                ),
                                fluidRow(
                                  column(3, checkboxInput('hide_gene_label', 'Hide labels', value=FALSE)),
                                  column(3, checkboxInput("outlier_gene_colour", "change the colour", value=FALSE)),
                                  conditionalPanel(
                                    condition = "input.outlier_gene_colour == true",
                                      column(3, colourInput('outlier_gene_colour_id', 'Positive side:', value='#0000CD')),
                                      column(3, colourInput('outlier_gene_colour_id_negative', 'Negative side:', value='#FF8C00'))
                                  )
                                ),
                                fluidRow(
                                  column(4, checkboxInput('show_threhold_lines', 'Show the threshold lines', value=FALSE)),
                                  column(8, checkboxInput('show_information', 'Show the filtered genes information', value=FALSE))
                                ),
                                fluidRow(
                                  column(4, checkboxInput('show_outliers_bar_plot', 'Show in a bar plot', value=FALSE)),
                                  conditionalPanel(
                                    condition = " input.show_outliers_bar_plot == true ",
                                    column(4, radioButtons('show_outliers_bar_colour', 'Colour by:', choices = c("X", "Y", "None")), selecetd='None'),
                                    column(4, checkboxInput('show_outliers_rotate_x', 'Rotate x axis lable in the bar plot'))
                                  )
                                )
                              )
                            ),
                            # show pathway genes                      
                            conditionalPanel(
                              condition = "input.show_pathway == true",
                              box(width=12,
                                fluidRow(
                                  column(4, radioButtons("pathway_dataset_select", "pathways from:", choices = c("HALLMARK (human)", "HALLMARK (mouse)", "Custom"))),
                                  column(8,
                                    fluidRow(
                                      column(12, conditionalPanel( condition = "input.pathway_dataset_select == 'Custom'", column(4, fileInput("upload_custom_pathway_file", "Upload a gmt file")) )),
                                      column(12, htmlOutput("select_pathway"))
                                    )
                                  )
                                ),
                                fluidRow(
                                  column(4, checkboxInput('hide_gene_label_pathway', 'Hide labels', value=FALSE)),
                                  column(4, checkboxInput('show_information_pathway', 'Show the genes information', value=FALSE))
                                ),
                                fluidRow(
                                  column(4, checkboxInput("pathway_gene_colour", "change the colour", value=FALSE)),
                                  conditionalPanel(
                                    condition = "input.pathway_gene_colour == true",
                                      column(4, colourInput('pathway_gene_colour_id', 'select colour:', value='#FF00FF'))
                                  )
                                )
                              )
                            ),
                            # show custom gene sets
                            conditionalPanel(
                              condition = "input.Plot_Gene_set == true",
                              box(width=12, 
                                fluidRow(
                                  column(8, htmlOutput("Plot_Gene_set_select_geneset")),
                                ),
                                fluidRow(
                                  column(4, checkboxInput('Plot_Gene_sethide_gene_label', 'Hide labels', value=FALSE)),
                                  column(4, checkboxInput('Plot_Gene_setshow_information', 'Show the genes information', value=FALSE))
                                ),
                                fluidRow(
                                  column(4, checkboxInput("Plot_Gene_set_pathway_gene_colour", "change the colour", value=FALSE)),
                                  conditionalPanel(
                                    condition = "input.Plot_Gene_set_pathway_gene_colour == true",
                                      column(4, colourInput('Plot_Gene_set_pathway_gene_colour_id', 'select colour:', value='#fcc203'))
                                  )
                                )
                              )
                            ),
                            # Main plot visualisation function
                            box( title='Main Plot Graph Options',  collapsible=TRUE, status='primary',width=12, collapsed=TRUE,
                              fluidRow(
                                column(6,sliderInput('fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                column(6,sliderInput('fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                column(6, sliderInput('pt.size', 'Point size', min=0.1, max=10, value=1, step=0.1)),
                                column(6, sliderInput('high.pt.size', 'Highlighted points size', min=0.1, max=10, value=3, step=0.1)),
                                column(6, sliderInput('high.label.size', 'Highlighted labels size', min=1, max=20, value=5, step=1)),
                                column(6, sliderInput('label.font.size', 'X/Y label font size', min=1, max=40, value=10, step=1)),
                                column(6, sliderInput('title.font.size', 'X/Y title font size', min=1, max=40, value=10, step=1)),
                                # column(4, sliderInput('graph.title.font.size', 'Graph title font size', min=1, max=40, value=10, step=1))
                              )
                            ),
                          )                  
                        ),
                      # display the genes of interest (table)
                      conditionalPanel(
                        condition = "input.show_entered_gene_info == true",
                        box(title='Information of genes of interest', collapsible=TRUE, status='primary', width=12,
                          dataTableOutput("Interesting_gene_outFile"),
                          downloadButton('Interesting_gene_download',"Download this table")
                        )
                      ),
                      # display the filtered area (table)
                      conditionalPanel(
                        condition = "input.show_outliers == true & input.show_information == true",
                        box(title='Outliers Information', collapsible=TRUE, status='primary', width=12,
                          dataTableOutput("outFile3"),
                          fluidRow(
                            column(2, downloadButton('filtered_download',"Download this table")),
                            column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('filtered_gene_list') ))
                          )
                        )
                      ),
                      # display the pathway genes (table)
                      conditionalPanel(
                        condition = "input.show_pathway == true & input.show_information_pathway== true",
                        box(title='Pathway Genes Information', collapsible=TRUE, status='primary', width=12,
                          dataTableOutput("outFile3_pathway"),
                          fluidRow(
                            column(2, downloadButton('pathway_download',"Download this table")),
                            column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('pathway_gene_list'))),
                          )
                        )
                      ),
                      # display the custom gene sets (table)
                      conditionalPanel(
                        condition = "input.Plot_Gene_set == true & input.Plot_Gene_setshow_information== true",
                        box(title='Custom Gene Sets Information', collapsible=TRUE, status='primary', width=12,
                          dataTableOutput("outFile3_custom_geneset"),
                          fluidRow(
                            column(2, downloadButton('custom_geneset_download',"Download this table")),
                            column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Custom_geneset_gene_list')))
                          )
                        )
                      ),
                      # display the information in a selection (table)
                      box( title='Selected Area Information', collapsible=TRUE, status='primary', width=12, 
                        dataTableOutput("outFile2"),
                        fluidRow(
                          column(2, downloadButton('selected_download',"Download this table")),
                          column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('selected_gene_list') ))
                        ),
                      ),
                      # Downstream analysis
                      box( title='Downstream analysis', collapsible=TRUE, status='primary',  width=12, collapsed=TRUE,
                        tabsetPanel(
                          tabPanel('GO analysis',
                            box(title='Settings', collapsible=TRUE, width=4,
                              fluidRow(
                                column(4, radioButtons("GO_input_type", "Input genes for GO analysis", choices = c("Text input", "Use filtered genes", "Use selected genes"), selected="Text input")),
                                conditionalPanel( condition = "input.GO_input_type == 'Text input'", column(8, textAreaInput("GO_input_geneList", "Enter gene list (one gene per line, Gene symbol)")) )
                              ),
                              fluidRow(
                                column(4, radioButtons("GO_species", "Select Species", choices = c("Human", "Mouse")),selecetd="Human"),
                                column(4, radioButtons("GO_database", "Select Database", choices = c("GO", "KEGG")), selecetd='GO'),
                                conditionalPanel( condition = "input.GO_database == 'GO'", column(4, radioButtons("GO_ontology", "Select Ontology", choices = c("BP", "MF", "CC")), selected="BP") )
                              ),
                              fluidRow( column(4, actionButton("GO_start", "Start GO Analysis")) ),
                              fluidRow( h5(span('This takes 1~3 minutes depending on the size of the input. Please be patient.', style="color: orange;")) ),
                              box(title='Plot options',collapsible=TRUE, width=12, collapsed = T,
                                fluidRow(
                                  column(12, sliderInput('GO_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                                  column(12, sliderInput('GO_fig.height','Fig height', min=300, max=3000, value=1000, step=10)),
                                ),
                                fluidRow(
                                  column(12, sliderInput('GO_fig.category_show_number','Number of categories to show', min=5, max=50, value=10, step=1)),
                                  column(12, sliderInput('GO_xtitle.font.size', 'X title font size', min=10, max=60, value=20, step=1))
                                ),
                                fluidRow(
                                  column(12, sliderInput('GO_ylab.font.size', 'Y labels size', min=10, max=40, value=15, step=1)),
                                  column(12, sliderInput('GO_xlab.font.size', 'X label font size', min=10, max=40, value=15, step=1))
                                )
                              )
                            ),
                            box(title='Plots', collapsible=TRUE, width=8,
                              verbatimTextOutput('GO_go_status'),
                              tabsetPanel(
                                tabPanel("Table", DT::dataTableOutput("GO_goTable", width="100%", height="100%"),  downloadButton('GO_goTable_download',"Download this table")),
                                tabPanel("Bar Plot", plotOutput("GO_goPlot", width="100%", height="100%")),
                                tabPanel("Bubble Plot", plotOutput("GO_goBubblePlot", width="100%", height="100%")),
                                tabPanel("Network plot", plotOutput("GO_netPlot", width="100%", height="100%"))
                              )
                            )
                          ),
                          tabPanel('GSEA analysis',
                            box(width=12, collapsible=TRUE, title='Settings',
                              fluidRow(
                                column(5,
                                  fluidRow(
                                    column(5, radioButtons("GSEA_pathway_dataset_select", "pathways from:", choices = c("HALLMARK (human)"='B', "HALLMARK (mouse)"='C', "Upload a gmt file (other gene sets)"='D', "Calculate the enrichment of one gene set"='E'), selected="B")),
                                    column(6, htmlOutput("GSEA_select_score")),
                                    conditionalPanel( condition = "input.GSEA_pathway_dataset_select == 'D'", column(7, fileInput("GSEA_upload_custom_pathway_file", "Upload a gmt file")) ),
                                    conditionalPanel( condition = "input.GSEA_pathway_dataset_select == 'E'", 
                                      column(7, 
                                        fluidRow(
                                          column(12, radioButtons('GSEA_pathway_dataset_select_one_geneset_select', '', choices=c("Choose from the Custom Gene sets"= 'A', "Text input"='B'), selected='A')),
                                          column(12, conditionalPanel(condition = "input.GSEA_pathway_dataset_select_one_geneset_select == 'A'", htmlOutput('GSEA_pathway_dataset_select_one_geneset_select_from_custom_set'))),
                                          column(12, conditionalPanel(condition = "input.GSEA_pathway_dataset_select_one_geneset_select == 'B'", textAreaInput('GSEA_pathway_dataset_select_one_geneset_select_from_text', 'Enter genes (line by line)')))
                                        )
                                      )
                                    )
                                  ),
                                  fluidRow( column(6, actionButton("GSEA_start", "Start GESA Analysis")) ),
                                  verbatimTextOutput('GSEA_analysis_status'),
                                ),
                                column(7,
                                  box(title='Plot options',collapsible=TRUE, width=12,  collapsed=TRUE,
                                    fluidRow(
                                      column(4, sliderInput('GSEA_fig.width', 'Fig width', min=300, max=3000, value=800, step=10)),
                                      column(4, sliderInput('GSEA_fig.height','Fig height', min=300, max=3000, value=500, step=10))
                                    ),
                                    fluidRow(
                                      column(4, sliderInput('GSEA_lab.font.size', 'X/Y labels size', min=1, max=30, value=15, step=1)),
                                      column(4, sliderInput('GSEA_title.font.size', 'X/Y title font size', min=1, max=40, value=20, step=1)),
                                      column(4, sliderInput('GSEA_graph_title.font.size', 'Graph title font size', min=1, max=40, value=15, step=1))
                                    )
                                  )
                                )
                              )
                            ),
                            box(title='Plots', collapsible=TRUE, width=12,
                              fluidRow(
                                column(4, h4('GSEA results table'), 
                                  DT::dataTableOutput("GSEA_goTable", width="100%", height="100%"), 
                                  downloadButton('GSEA_download',"Download this table")
                                ),
                                column(8, 
                                  verbatimTextOutput('GSEA_plot_status'),
                                  plotOutput("GSEA_plot", width="100%", height="100%"),
                                  verbatimTextOutput('GSEA_status'))
                              )
                            )
                          ),
                          tabPanel('TF activity inference',
                            h4('(DecoupleR analysis. Available only for RNAseq DEG data processed from DESeq2)'),
                            box(title='Settings', collapsible=TRUE, width=3,
                              fluidRow(column(12, sliderInput('DecoupeR_TF_number', 'Number of TF to display', min=10, max=200, value=50, step=1))),
                              h3(),
                              fluidRow(column(12, actionButton("DecoupeR_start", "Start DecoupeR Analysis"))),
                              h3(),
                              box(width=12, title="Plot options", collapsible = TRUE, collapsed = TRUE,
                                fluidRow(
                                  column(12, sliderInput('DecoupeR_fig.width', 'Fig width', min=500, max=4000, value=1000, step=10)),
                                  column(12, sliderInput('DecoupeR_fig.height','Fig height', min=300, max=3000, value=500, step=10))
                                ),
                                fluidRow(
                                  column(12, sliderInput('DecoupeR_lab.font.size', 'X/Y labels size', min=1, max=30, value=15, step=1)),
                                  column(12, sliderInput('DecoupeR_title.font.size', 'X/Y title font size', min=1, max=40, value=20, step=1)),
                                ),
                                fluidRow(
                                  column(12, colourInput('DecoupeR_colour_high', 'High activity colour:', value='indianred')),
                                  column(12, colourInput('DecoupeR_colour_low', 'Low activity colour:', value='darkblue')),
                                  column(12, colourInput('DecoupeR_colour_mid', 'Zero activity colour:', value='whitesmoke'))
                                )
                              )
                            ),
                            box(title='Plots', collapsible=TRUE, width=9,
                              verbatimTextOutput('DecoupeR_plot_status'),
                              tabsetPanel(
                                tabPanel("DecoupeR Plot",
                                  plotOutput("DecoupeR_plot", width="100%", height="100%")
                                ),
                                tabPanel("Table", 
                                  DT::dataTableOutput("DecoupeR_Table", width="100%", height="100%"),
                                  downloadButton('DecoupeR_Table_download',"Download this table")
                                )
                              )
                            )
                          )
                        )
                      )
                    )

                  )
                )
              ###
            )
          ),
        #### Original_geneset ####
          tabItem( tabName='Original_geneset',
            h2('Custom Genesets Information'),
            box(width=12, title='Custom Gene Sets', status='primary', collapsible = TRUE,
              fluidRow(column(3, htmlOutput("Original_geneset_filter_Cell"))),
              DT::dataTableOutput("Original_geneset_DataBaseTable"),
              fluidRow( column(2, actionButton('Original_geneset_save_dt', 'Save changes')), column(2, actionButton('Original_geneset_delete_row', 'Delete selected data')), column(2, verbatimTextOutput('Original_geneset_status')) )
            ),
            box(width=12, title='Add a Gene Set', status='primary', collapsible = TRUE,
              tags$details(
                tags$summary("Quick upload guide ▼"),  # クリックすると開閉されるタイトル
                div(
                  # 箇条書きのリスト
                  tags$ul(
                    tags$li("The Geneset name and the list of the genes are mandatory. Others are optional. and must be unique."),
                    tags$li("The Geneset name must be unique."),
                    tags$li("Avoid special characters; use only alphabets, numbers, underscores and dots."),
                  )
                )
              ),
              h3(''),
              fluidRow( 
                column(2, textAreaInput("Original_geneset_upload_Geneset_name", "Geneset name *")), 
                column(2, textAreaInput("Original_geneset_upload_cell_line", "Cell line/Cell type")), 
                column(2, textAreaInput("Original_geneset_upload_data_generated_from", "Data source")),
                column(2, textAreaInput("Original_geneset_upload_when", "Wann")) 
              ),
              fluidRow( 
                column(4, textAreaInput("Original_geneset_upload_genes", "Genes (line by line) (Gene symbol) *")), 
                column(4, textAreaInput("Original_geneset_upload_description", "Description"))
              ),
              fluidRow( column(2, actionButton('Original_geneset_upload_data', 'Add the geneset to the list')), column(5, verbatimTextOutput('Original_geneset_status_upload')))
            )
          ),
        #### Compare_across_datasets ####
          tabItem( tabName='Compare_across_datasets',
            h2('Compare across datasets'),
            #####
            box(width=12, collapsible=TRUE, title='Dataset selection',
              fluidRow( column(8, htmlOutput("choose_data_type")) ),
              h4('Dataset setect'),
              verbatimTextOutput('Compare_dataset_selection_status'),
              fluidRow( column(12, dataTableOutput("all_dataset"))),
              h5('Filtering'),
              fluidRow(
                column(4,htmlOutput("Compare_dataset_filtering_Data_from")),
                column(4,htmlOutput("Compare_dataset_filtering_Experiment")),
              ) 
            ),
            box(width=12, title='Anlaysis',
              tabsetPanel(
                ## Overlap the hits
                tabPanel("Get the overlap",
                  box(width=12, title='Filtering criteria', collapsible = TRUE,
                    fluidRow(
                      column(3, htmlOutput('Compare_dataset_get_overview_select_score')),
                      column(2, radioButtons('Compare_dataset_get_overview_direction', 'Direction:', choices=c('Top X%', 'Bottom X%'))),
                      column(3, 
                        fluidRow(
                          column(12, sliderInput('Compare_dataset_get_overview_threshold', 'Threshold X(%)=', min=0, max=100, value=5, step=1)),
                          column(12, numericInput('Compare_dataset_get_overview_threshold_for_display', 'Show genes whose Overlap_time is more than:', value=0, min=0, max=1000, step=1))
                        )
                      ),
                      column(3, actionButton('Compare_dataset_get_overview_start', 'Investigate the overlap'))
                    )
                  ),
                  box(width=12, title='Overlapped hits', collapsible = TRUE,
                    fluidRow( 
                      verbatimTextOutput('Compare_dataset_get_overview_status'),
                      column(12, dataTableOutput("Compare_dataset_get_overview_overlap")),
                      fluidRow(
                        column(2, downloadButton('Compare_dataset_get_overview_download',"Download this table")),
                        column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Compare_dataset_get_overview_list') ))
                      )
                    )
                  ),
                  box(width=12, title='barplot', collapsible = TRUE,
                    verbatimTextOutput('Compare_dataset_get_overview_barplot_status'),
                    fluidRow( column(12,  plotOutput("Compare_dataset_get_overview_barplot", width="100%", height="100%")))
                  ),
                  box(width=12, collapsible=TRUE, title='Plot options', collapsed=TRUE,
                    fluidRow(
                      column(4,sliderInput('Compare_dataset_get_overview_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                      column(4,sliderInput('Compare_dataset_get_overview_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                    ),
                    fluidRow(
                      column(4, sliderInput('Compare_dataset_get_overview_label.font.size', 'X/Y label font size', min=1, max=40, value=15, step=1)),
                      column(4, sliderInput('Compare_dataset_get_overview_title.font.size', 'X/Y title font size', min=1, max=40, value=15, step=1)),
                      column(4, sliderInput('Compare_dataset_get_overview_graph.title.font.size', 'Graph title font size', min=1, max=40, value=15, step=1))
                    ),
                    fluidRow(
                      column(4, colourInput('Compare_dataset_get_overview_highest_colour', 'Colour for the highest value', value='red')),
                      column(4, colourInput('Compare_dataset_get_overview_lowest_colour', 'Colour for the lowest value', value='blue')),
                      column(4, colourInput('Compare_dataset_get_overview_zero_colour', 'Colour for zero', value='white')),
                      column(4, checkboxInput('Compare_dataset_get_overview_white_background', 'Use white background', value=FALSE))
                    )

                  )
                ),
                ## Compare the one gene
                tabPanel("Compare one gene",
                  box(width=12, collapsible=TRUE, title='Analysis options',
                    fluidRow( 
                      column(3, textAreaInput("target_gene_for_comparing", "Enter genes (line by line)")),
                      column(3,htmlOutput("Choose_datasets_y")),
                      column(3,htmlOutput("Choose_datasets_colour")),
                    ),
                    fluidRow( column(4, actionButton("comparison_start", "Start Analysis")))
                  ),
                  box(width=12, collapsible=TRUE, title='Plot',
                    verbatimTextOutput('Gene_comparing_status'),
                    fluidRow(
                      column(2, 
                        h4('Select a gene below:'),
                        dataTableOutput("Gene_comparing_gene_list_table"),
                      ),
                      column(10, 
                        h4('Comparing plot') ,
                          verbatimTextOutput('Gene_comparing_plot_status'),
                        plotOutput("Gene_comparing_plot", width="100%", height="100%"),
                        fluidRow( column(5,radioButtons("bar_or_scatter", "Plot type", choices = c( "Scatter plot", "Bar plot"), selected='Bar plot')) )
                      )
                    )
                  ),
                  box(width=4, collapsible=TRUE, title='Data information',  
                    dataTableOutput("dataframe_comparing_dataset"),
                    downloadButton('comparing_dataset_download',"Download this table")
                  ),
                  box(width=8, collapsible=TRUE, title='Plot options', collapsed=TRUE,
                    fluidRow(
                      column(4,sliderInput('Compare_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                      column(4,sliderInput('Compare_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                      column(4, sliderInput('Compare_pt.size', 'Point size', min=0.1, max=10, value=3, step=0.1))
                    ),
                    fluidRow(
                      column(4, sliderInput('Compare_label.font.size', 'X/Y label font size', min=1, max=40, value=15, step=1)),
                      column(4, sliderInput('Compare_title.font.size', 'X/Y title font size', min=1, max=40, value=15, step=1)),
                      column(4, sliderInput('Compare_graph.title.font.size', 'Graph title font size', min=1, max=40, value=15, step=1))
                    ),
                    fluidRow(
                      column(4, colourInput('Compare_highest_colour', 'Colour for the highest value', value='red')),
                      column(4, colourInput('Compare_lowest_colour', 'Colour for the lowest value', value='blue')),
                      column(4, colourInput('Compare_zero_colour', 'Colour for zero', value='white')),
                      column(4, checkboxInput('Compare_white_background', 'Use white background', value=FALSE))
                    )
                  )
                )
              )
            )
          ),  
        #### Integrate_two_dataset ####
          tabItem( tabName='Integrate_two_dataset', 
            h2('Integrate two datasets'),
            box(width=12, title='Data exchanging', collapsible=TRUE, 
              box(width=12, title='Direction',
                radioButtons("Integrate_data_map_direction", "", choices = c('See the selected genes from Data1 onto Data2'='A', 'See the selected genes from Data2 onto Data1'='B'), selected='A')
              ),
              box(width=6, title='Data1',
                fluidRow( column(10, htmlOutput("Integrate_data1_select")) ),
                h5('Datase filtering'),
                fluidRow( column(4, htmlOutput("Integrate_data1_Seuqenced_by")), column(4, htmlOutput("Integrate_data1_Experiments")), column(4, htmlOutput("Integrate_data1_Data_type")) ),
                fluidRow( column(4, htmlOutput("Integrate_data1_Scat.X")), column(4, htmlOutput("Integrate_data1_Scat.Y"))),
                verbatimTextOutput('Integrate_data1_plot_status'),
                plotOutput("Integrate_data1_plot", brush = "Integrate_data1_plot_brush", width="100%", height="100%"),
                conditionalPanel(
                  condition = "input.Integrate_data_map_direction == 'A' ",
                  box(title='Gene selection', collapsible=TRUE, width=12,
                    fluidRow(
                      column(4, radioButtons("Integrate_data1_Gene_selection", "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),
                      conditionalPanel(
                        condition= "input.Integrate_data1_Gene_selection == 'A' ",
                        column(4, radioButtons("Integrate_data1_Direction", "Use", choices = c("both positive/negative genes", "only positive genes", "only negative genes"), selected='only positive genes')),
                        column(4, 
                          fluidRow(
                            column(12, sliderInput('Integrate_data1_x_threshold', 'The threshold for X axis', min=0, max=15, value=1, step=0.1)),
                            column(12, sliderInput('Integrate_data1_y_threshold', 'The threshold for Y axis', min=0, max=20, value=1.3, step=0.1))
                          )
                        )
                      ),
                      column(10, verbatimTextOutput('Integrate_data1_selected_gene_num'))
                    )
                  )
                ),
                box(title='Figure option', collapsible=TRUE, width=12, collapsed=TRUE,
                  fluidRow(
                    column(6,sliderInput('Integrate_data1_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                    column(6,sliderInput('Integrate_data1_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                  )
                )
              ),
              box(width=6, title='Data2',
                fluidRow( column(10, htmlOutput("Integrate_data2_select")) ),
                h5('Datase filtering'),
                fluidRow( column(4, htmlOutput("Integrate_data2_Seuqenced_by")), column(4, htmlOutput("Integrate_data2_Experiments")), column(4, htmlOutput("Integrate_data2_Data_type")) ),
                fluidRow( column(4, htmlOutput("Integrate_data2_Scat.X")), column(4, htmlOutput("Integrate_data2_Scat.Y"))),
                verbatimTextOutput('Integrate_data2_plot_status'),
                plotOutput("Integrate_data2_plot", brush = "Integrate_data2_plot_brush", width="100%", height="100%"),
                conditionalPanel(
                  condition = "input.Integrate_data_map_direction == 'B' ",
                  box(title='Gene selection', collapsible=TRUE, width=12,
                    fluidRow(
                      column(4, radioButtons("Integrate_data2_Gene_selection", "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),
                      conditionalPanel(
                        condition= "input.Integrate_data2_Gene_selection == 'A' ",
                        column(4, radioButtons("Integrate_data2_Direction", "Use", choices = c("both positive/negative genes", "only positive genes", "only negative genes"), selected='only positive genes')),
                        column(4, 
                          fluidRow(
                            column(12, sliderInput('Integrate_data2_x_threshold', 'The threshold for X axis', min=0, max=15, value=1, step=0.1)),
                            column(12, sliderInput('Integrate_data2_y_threshold', 'The threshold for Y axis', min=0, max=20, value=1.3, step=0.1))
                          )
                        )
                      ),
                      column(10, verbatimTextOutput('Integrate_data2_selected_gene_num'))
                    )
                  )
                ),
                box(title='Figure option', collapsible=TRUE, width=12,  collapsed=TRUE,
                  fluidRow(
                    column(6,sliderInput('Integrate_data2_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                    column(6,sliderInput('Integrate_data2_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                  )
                )
              ),
              box(width=12, title='Overlap genes',
                fluidRow(
                  column(4, sliderInput('Integrate_data_mapped_x_threshold', 'The threshold for X axis (mapped side)', min=0, max=15, value=1, step=0.1)),
                  column(4, sliderInput('Integrate_data_mapped_y_threshold', 'The threshold for Y axis (mapped side)', min=0, max=15, value=1, step=0.1)),
                  column(3, checkboxInput('Integrate_data_mapped_show_threshold', 'Show the threshold in the plot', value=TRUE)),
                ),
                dataTableOutput("Integrate_Overlapped_gene_table"),
                verbatimTextOutput('Integrate_Overlapped_gene_table_status'),
                fluidRow(
                  column(2, downloadButton('Integrate_Overlapped_gene_table_download',"Download this table")),
                  column(3, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Integrate_Overlapped_gene_list') ))
                )
                
              )
            ),
            box(width=12, title='Integration Plot', collapsible=TRUE, 
              box(width=6, title='Plot', 
                fluidRow( 
                  column(6, htmlOutput("Integrate_data1_plus_2_Scat.X")), 
                  column(6, htmlOutput("Integrate_data1_plus_2_Scat.Y")),
                ),
                fluidRow(
                  column(6, htmlOutput("Integrate_data1_plus_2_Scat.colour"))
                ),
                verbatimTextOutput('Integrate_data1_plus_2_plot_status'),
                plotOutput("Integrate_data1_plus_2_plot", brush = "Integrate_data1_plus_2_plot_brush", width="100%", height="100%")
              ),
              box(width=6, title='Data', collapsible=TRUE,
                fluidRow(
                  column(4, textAreaInput("Integrate_data1_plus_2_target_gene", "Enter gene(s) of interest (line by line)"))
                ),
                h4('Selected area'),
                dataTableOutput("Integrate_data1_plus_2_selected"),
                fluidRow(
                  column(2, downloadButton('Integrate_data1_plus_2_selected_download',"Download this table")),
                  column(4, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Integrate_data1_plus_2_selected_gene_list') ))
                )
              ),
              box(title='Figure option', collapsible=TRUE, width=12,  collapsed=TRUE,
                fluidRow(
                  column(4,sliderInput('Integrate_data1_plus_2_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                  column(4,sliderInput('Integrate_data1_plus_2_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                ),
                fluidRow(
                  column(4,sliderInput('Integrate_data1_plus_2_XY_label_size', 'X/Y label size', min=3, max=30, value=10, step=1)),
                  column(4,sliderInput('Integrate_data1_plus_2_XY_title_size', 'X/Y title size', min=3, max=30, value=10, step=1)),
                ),
                fluidRow(
                  column(4,sliderInput('Integrate_data1_plus_2_dot_label_size', 'Point size', min=0.1, max=10, value=1, step=0.1)),
                  column(4,sliderInput('Integrate_data1_plus_2_id_size', 'Label size', min=1, max=20, value=5, step=1)),
                  column(4,sliderInput('Integrate_data1_plus_2_highlight_dot_size', 'Highlighted points size', min=0.1, max=10, value=3, step=0.1)),
                ),
                fluidRow(
                  column(4, checkboxInput('Integrate_data1_plus_2_white_background', 'Use white background', value=FALSE))
                )
              )
            )
          ),
        #### Clinical_dataset ####
          tabItem( tabName = 'Clinical_dataset',
            h2('Clinical data'),
            ##### Dataset selection #####
              box(width=12, title='Data selection',
                fluidRow( 
                  column(4, htmlOutput("Clinical_data_select")) ,
                  column(4, h5('Dataset detail:'), verbatimTextOutput('Clinical_Dataset_detail'))
                ),
              ),
            ##### Analysis part #####
              box(width=12,
                tabsetPanel(
                  ###### view database ######
                    tabPanel("View the data",
                      tabsetPanel(
                        tabPanel("Gene expression", 
                          verbatimTextOutput('Clinical_View_Geneexpression_status'), 
                          radioButtons('Clinical_View_EX_show_number', '', c("Show the first 1000 headers"='A', 'Show everything (the server will be overloaded depending on the size of the data)'='B'), selected='A'),
                          DT::dataTableOutput("Clinical_View_Geneexpression")),
                        tabPanel("Survival", verbatimTextOutput('Clinical_View_Survival_status'), DT::dataTableOutput("Clinical_View_Survival")),
                        tabPanel("Meta data", verbatimTextOutput('Clinical_View_MetaData_status'), DT::dataTableOutput("Clinical_View_MetaData"))
                      )
                    ),
                  ###### Survival analysis ######
                    tabPanel("Survival analysis",
                      box(width=12,
                        fluidRow(
                          column(3, 
                            textAreaInput('Clinical_Survival_genes', 'Enter genes'),
                            checkboxInput('Clinical_Survival_genes_from_custom_geneset', 'or use the genes from the custom gene sets', value=FALSE),
                            conditionalPanel(
                              condition = "input.Clinical_Survival_genes_from_custom_geneset == true",
                              htmlOutput('Clinical_Survival_genes_from_custom_geneset_select')
                            )
                          ),
                          column(3, radioButtons('Clinical_Survival_Split_way', 'Split the samples by:', choices = c('Median'='A', 'Top 25% vs Bottom 25%'='B'),selected='A')),
                          column(2, actionButton('Clinical_Survival_start', 'Start the survival analysis'))
                        )
                      ),
                      box(width=12,
                        fluidRow(
                          column(4, 
                            h4('Hazard Ratios'),  
                            verbatimTextOutput('Clinical_Survial_table_status'),
                            dataTableOutput("Clinical_Survial_table"),
                            downloadButton('Clinical_Survial_table_download',"Download this table")
                          ),
                          column(8, 
                            tabsetPanel(
                              tabPanel("Kaplan-Meier curve",
                                verbatimTextOutput('Clinical_Survial_plot_error_catch'), 
                                plotOutput("Clinical_Survial_plot", width="100%", height="100%"),
                                box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  fluidRow(
                                    column(4,sliderInput('Clinical_Survial_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(4,sliderInput('Clinical_Survial_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                  ),
                                  fluidRow(
                                    column(4,sliderInput('Clinical_Survial_label_size', 'X/Y label size', min=10, max=40, value=15, step=1)),
                                    column(4,sliderInput('Clinical_Survial_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                    column(4,sliderInput('Clinical_Survial_legend_size', 'legend size', min=10, max=40, value=20, step=1)),
                                  ),
                                  fluidRow(
                                    column(3, colourInput('Clinical_Survial_High_colour', 'Colour for the "High" group:', value='#ec00ec')),
                                    column(3, colourInput('Clinical_Survial_Low_colour', 'Colour for the "Low" group:', value='#00aaff')),
                                  )
                                )
                              ),
                              tabPanel("Expression distribution",
                                verbatimTextOutput('Clinical_Survial_plot_distribution_status'), 
                                plotOutput("Clinical_Survial_distribution_plot", width="100%", height="100%"),
                                box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  fluidRow(
                                    column(4,sliderInput('Clinical_Survial_distribution_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                    column(4,sliderInput('Clinical_Survial_distribution_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                  ),
                                  fluidRow(
                                    column(4,sliderInput('Clinical_Survial_distribution_label_size', 'X/Y label size', min=10, max=40, value=15, step=1)),
                                    column(4,sliderInput('Clinical_Survial_distribution_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                    column(4,sliderInput('Clinical_Survial_distribution_graphtitle_size', 'Graph title size', min=10, max=40, value=20, step=1)),
                                  ),
                                  fluidRow(
                                    column(3, colourInput('Clinical_Survial_distribution_colour', 'Colour:', value='#006FED')),
                                    column(3, sliderInput('Clinical_Survial_distribution_bin_num', 'Bin number', min=10, max=100, value=20, step=1)),
                                    column(2, checkboxInput('Clinical_Survial_distribution_white_background', 'Use white background', value=FALSE))
                                  )
                                )
                              )
                            )
                          ),
                        )
                      ),

                    ),
                  ###### Gene correlation ######
                    tabPanel("Gene correlation",
                      box(width=12, 
                        fluidPage(
                          column(4, 
                            radioButtons('Gene_correlation_genes_comparison_type', 'Explore type', choices=c("Explore one gene's correlation with all the genes"='A', "Explore one gene's correlation with specific genes"='B'),selected='B'),
                            fluidRow(
                              column(6, 
                                conditionalPanel(
                                  condition="input.Gene_correlation_genes_comparison_type == 'A'",
                                  h5(span('This calculates the correlation with all the genes. It takes 2~4 minutes. Please be patient.', style="color: orange;"))
                                ),
                                textAreaInput('Gene_correlation_genes', 'Enter *ONE* gene (Y-axis)')
                              ),
                              conditionalPanel(
                                condition="input.Gene_correlation_genes_comparison_type == 'B'",
                                column(6, 
                                  textAreaInput('Gene_correlation_genes_y', 'Enter genes (X-axis)'),
                                  checkboxInput('Gene_correlation_genes_y_from_custom_geneset', 'or use the genes from the custom gene sets', value=FALSE),
                                  conditionalPanel(
                                    condition = "input.Gene_correlation_genes_y_from_custom_geneset == true",
                                    htmlOutput('Gene_correlation_genes_y_from_custom_geneset_select')
                                  )
                                )
                              ),
                            )
                          ), 
                          column(2, radioButtons('Gene_correlation_Corralation_method', 'Method for correlation', choices = c('pearson', 'spearman'),selected='pearson')),
                          column(2, 
                            actionButton("Gene_correlation_start", "Calculate the correlation")
                          )
                        )
                      ),
                      box(width=12, 
                        fluidPage(
                          column(4, 
                            h4('Correlation'), 
                            DT::dataTableOutput("Gene_correlation_table"),
                            downloadButton('Gene_correlation_table_download',"Download this table")
                          ),
                          column(8, h4('Scatter plot'), 
                            verbatimTextOutput('Gene_correlation_error_catch'), 
                            plotOutput("Gene_correlation_scatter_plot", width="100%", height="100%"),
                            h4(),
                            box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                              fluidRow(
                                column(6,sliderInput('Gene_correlation_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                column(6,sliderInput('Gene_correlation_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                              ),
                              fluidRow(
                                column(6,sliderInput('Gene_correlation_label_size', 'X/Y label size', min=10, max=40, value=20, step=1)),
                                column(6,sliderInput('Gene_correlation_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                              ),
                              fluidRow(
                                column(3, colourInput('Gene_correlation_colour', 'Colour of the dots:', value='#ec00ec')),
                                column(2, checkboxInput('Gene_correlation_show_correlation_line', 'Show the correlation line')),
                                column(2, checkboxInput('Gene_correlation_white_background', 'Use white background', value=FALSE))
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Gene expression compare ######
                    tabPanel("Gene expression acrosss subtype",
                      box(width=12,
                        fluidRow(
                          column(3, textAreaInput('Expression_subtype_genes', 'Enter genes')),
                          column(3, 
                            htmlOutput('Expression_subtype_groupBy'), 
                            verbatimTextOutput('Expression_subtype_subtype_number'),
                            h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: orange;"))
                          ), 
                          column(2, actionButton('Expression_subtype_start', 'Start comparing')),
                          column(2, radioButtons('Expression_subtype_figtype', 'Figure type:', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A'))
                        )
                      ),
                      box(width=12,
                        fluidRow(
                          column(4, h4('Test Results'),  
                            # verbatimTextOutput('Expression_subtype_test_status'),
                            dataTableOutput("Expression_subtype_table"),
                            downloadButton('Expression_subtype_table_download',"Download this table")
                          ),
                          column(8, h4('Plot'), 
                            verbatimTextOutput('Expression_subtype_error_catch'), 
                            plotOutput("Expression_subtype_plot", width="100%", height="100%"),
                            verbatimTextOutput('Expression_subtype_note'), 
                            h4(),
                            box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                              fluidRow(
                                column(4,sliderInput('Expression_subtype_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                column(4,sliderInput('Expression_subtype_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                column(4, sliderInput('Expression_subtype_dot.size', 'Dot size (swarm plot)', min=1, max=20, value=3, step=1))
                              ),
                              fluidRow(
                                column(4, sliderInput('Expression_subtype_XY_label.font.size', 'X/Y labels size', min=10, max=40, value=20, step=1)),
                                column(4, sliderInput('Expression_subtype_XY_title.font.size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                column(4, sliderInput('Expression_subtype_title.font.size', 'Graph title font size', min=10, max=40, value=20))
                              ),
                              fluidRow(
                                column(3, checkboxInput('Expression_subtype_white_background', 'Use white background', value=FALSE)),
                                column(3, checkboxInput('Expression_subtype_rotate_x', 'Rotate X axis label', value=FALSE))
                              ),
                              fluidRow(
                                column(3, checkboxInput('Expression_subtype_change_colour_pallete', 'Change the colour pallete', value=FALSE)),
                                conditionalPanel(
                                  condition = "input.Expression_subtype_change_colour_pallete == true",
                                  column(3, selectInput('Expression_subtype_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                )
                              ),
                              fluidRow(
                                column(3, checkboxInput('Expression_subtype_use_single_colour', 'Use a single colour', value=FALSE)),
                                conditionalPanel(
                                  condition = "input.Expression_subtype_use_single_colour == true",
                                  column(3, colourInput('Expression_subtype_choose_single_colour', 'Choose a colour', value='#000000'))
                                )
                              ) 
                            )
                          ) 
                        )
                      ),

                    ),
                  ###### Signature analysis
                    tabPanel("Signature analysis",
                      box(width=12, title='Signature selction', collapsible = TRUE, 
                        fluidRow(
                          column(3, 
                            radioButtons('Signature_input_selection', 'Input', choices = c('Choose from the custom gene sets'='A', 'Text input'='B'), selected='A')
                          ),
                          column(3,
                            conditionalPanel(
                              condition = "input.Signature_input_selection == 'A'",
                              htmlOutput('Signature_input_selection_custom_geneset_select')
                            ),
                            conditionalPanel(
                              condition = "input.Signature_input_selection == 'B'",
                              textAreaInput('Signature_input_selection_text_input', "Enter genes (line by line)")
                            ),
                            conditionalPanel(
                              condition = "input.Signature_input_selection != 'A' & input.Signature_input_selection != 'B'",
                              verbatimTextOutput('Signature_input_selection_status'),
                            )
                          ),
                          column(2,  radioButtons('Signature_input_score_type', 'Calculation method', choices = c('GSVA', 'ssGSEA'), selected='GSVA')),
                          column(2, actionButton('Signature_start', 'Start calculating the signature score') )
                        )
                      ),
                      box(width=12, title='Results',
                        fluidRow(
                          column(4, 
                            h4('Signature score'),  
                            verbatimTextOutput('Signature_analysis_status'), 
                            dataTableOutput("Signature_result_table"),
                            downloadButton('Signature_result_table_download',"Download this table")
                          ),
                          column(8, 
                            tabsetPanel(
                              tabPanel('Survival analysis',
                                fluidRow(
                                  h4(""),
                                  column(12, radioButtons('Signature_Survival_cutoff_method', 'Split the samples by:', choices = c('Median'='A', 'Top25% vs Bottom 25%'='B'), selected='A')),
                                  column(12, plotOutput("Signature_Survival_plot", width="100%", height="100%")),
                                  column(12, verbatimTextOutput('Signature_Survival_detail')),
                                  box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                    fluidRow(
                                      column(4,sliderInput('Signature_Survival_plot_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                      column(4,sliderInput('Signature_Survival_plot_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                    ),
                                    fluidRow(
                                      column(4,sliderInput('Signature_Survival_plot_label_size', 'X/Y label size', min=10, max=40, value=15, step=1)),
                                      column(4,sliderInput('Signature_Survival_plot_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                      column(4,sliderInput('Signature_Survival_plot_legend_size', 'legend size', min=10, max=40, value=20, step=1)),
                                    ),
                                    fluidRow(
                                      column(2, colourInput('Signature_Survival_plot_High_colour', 'Colour for the "High" group:', value='#ec00ec')),
                                      column(2, colourInput('Signature_Survival_plot_Low_colour', 'Colour for the "Low" group:', value='#00aaff')),
                                    )
                                  )
                                )
                              ),
                              tabPanel('Score comparison',
                                fluidRow(
                                  column(5, 
                                    htmlOutput('Signature_subtype_groupBy'), 
                                    verbatimTextOutput('Signature_subtype_subtype_number'),
                                    h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: orange;"))
                                  ), 
                                  column(2, h3(""), actionButton('Signature_subtype_start', 'Show plot')),
                                  column(2, radioButtons('Signature_subtype_figtype', 'Figure type:', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A'))
                                ),
                                fluidRow(
                                  column(12, plotOutput("Signature_subtype_plot", width="100%", height="100%")),
                                  column(12, verbatimTextOutput('Signature_subtype_note'))
                                ),
                                box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  fluidRow(
                                    column(4,sliderInput('Signature_subtype_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(4,sliderInput('Signature_subtype_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                  ),
                                  fluidRow(
                                    column(4, sliderInput('Signature_subtype_XY_label.font.size', 'X/Y labels size', min=10, max=40, value=20, step=1)),
                                    column(4, sliderInput('Signature_subtype_XY_title.font.size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                    column(4, sliderInput('Signature_subtype_title.font.size', 'Graph title font size', min=10, max=40, value=20))
                                  ),
                                  fluidRow(
                                    column(4, sliderInput('Signature_subtype_dot.size', 'Dot size (swarm plot)', min=1, max=20, value=3, step=1))
                                  ),
                                  fluidRow(
                                    column(3, checkboxInput('Signature_subtype_white_background', 'Use white background', value=FALSE)),
                                    column(3, checkboxInput('Signature_subtype_rotate_x', 'Rotate X axis label', value=FALSE))
                                  ),
                                  fluidRow(
                                    column(3, checkboxInput('Signature_subtype_change_colour_pallete', 'Change the colour pallete', value=FALSE)),
                                    conditionalPanel(
                                      condition = "input.Signature_subtype_change_colour_pallete == true",
                                      column(3, selectInput('Signature_subtype_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                    )
                                  ),
                                  fluidRow(
                                    column(3, checkboxInput('Signature_subtype_use_single_colour', 'Use a single colour', value=FALSE)),
                                    conditionalPanel(
                                      condition = "input.Signature_subtype_use_single_colour == true",
                                      column(3, colourInput('Signature_subtype_choose_single_colour', 'Choose a colour', value='#000000'))
                                    )
                                  ) 
                                )
                              ),
                              tabPanel('Distribution',
                                verbatimTextOutput('Signature_score_distribution_status'), 
                                plotOutput("Signature_score_distribution_plot", width="100%", height="100%"),
                                box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  fluidRow(
                                    column(6,sliderInput('Signature_score_distributionfig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                    column(6,sliderInput('Signature_score_distribution_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                  ),
                                  fluidRow(
                                    column(6,sliderInput('Signature_score_distribution_label_size', 'X/Y label size', min=10, max=40, value=15, step=1)),
                                    column(6,sliderInput('Signature_score_distribution_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                  ),
                                  fluidRow(
                                    column(3, colourInput('Signature_score_distribution_colour', 'Colour:', value='#006FED')),
                                    column(4, sliderInput('Signature_score_distribution_bin_num', 'Bin number', min=10, max=100, value=50, step=1)),
                                    column(2, checkboxInput('Signature_score_distribution_white_background', 'Use white background', value=FALSE))
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Deconvolution
                    tabPanel("Deconvolution analysis",
                      box(width=12, title='Deconvodution',collapsible=TRUE,
                        fluidRow(
                          column(2,
                            radioButtons("Deconvodution_tool_select", "Choose a method:", choices=c('MCPcounter', 'xCell'), selected='MCPcounter'),
                            actionButton("Deconvodution_start", "Start deconvolution")
                          ),
                          column(10,
                            h4('Deconvolution Result:'),
                            verbatimTextOutput('Deconvodution_status'),
                            dataTableOutput("Deconvodution_results"),
                            downloadButton('Deconvodution_result_download',"Download this table")
                          )
                        )
                      ),
                      box(width=12, title='Futher analysis',
                        tabsetPanel(
                          tabPanel("Correlation with genes",
                            fluidRow(
                              column(3, 
                                h3(''),
                                textAreaInput('Deconvodution_Gene_correlation_genes', 'Enter genes'),
                                checkboxInput('Deconvodution_Gene_correlation_from_custom_geneset', 'or use the genes from the custom gene sets', value=FALSE),
                                conditionalPanel(
                                  condition = "input.Deconvodution_Gene_correlation_from_custom_geneset == true",
                                  htmlOutput('Deconvodution_Gene_correlation_from_custom_geneset_select')
                                )
                              ),
                              column(3,
                                h3(''),
                                htmlOutput('Deconvodution_Gene_correlation_select_celltype')
                              ),
                              column(2,
                                h3(''),
                                radioButtons('Deconvodution_Gene_correlation_method', 'Method for correlation', choices=c('pearson', 'spearman'), selected='pearson')
                              ),
                              column(2,
                                h3(''),
                                actionButton('Deconvodution_Gene_correlation_start', 'Calculate the correlation')
                              )
                            ),
                            fluidRow(
                              column(4, 
                                h4('Correlation'),
                                dataTableOutput("Deconvodution_Gene_correlation_table"),
                                downloadButton('Deconvodution_Gene_correlation_table_download',"Download this table")
                              ),
                              column(8, h4('Plot'),
                                verbatimTextOutput('Deconvodution_Gene_correlation_status'),
                                plotOutput("Deconvodution_Gene_correlation_plot", width="100%", height="100%"),
                                box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  fluidRow(
                                    column(4,sliderInput('Deconvodution_Gene_correlation_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                    column(4,sliderInput('Deconvodution_Gene_correlation_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                  ),
                                  fluidRow(
                                    column(4,sliderInput('Deconvodution_Gene_correlation_label_size', 'X/Y label size', min=10, max=40, value=20, step=1)),
                                    column(4,sliderInput('Deconvodution_Gene_correlation_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                  ),
                                  fluidRow(
                                    column(3, colourInput('Deconvodution_Gene_correlation_colour', 'Colour of the dots:', value='#ec00ec')),
                                    column(2, checkboxInput('Deconvodution_Gene_correlation_show_correlation_line', 'Show the correlation line')),
                                    column(2, checkboxInput('Deconvodution_Gene_correlation_white_background', 'Use white background', value=FALSE))
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Add new cohort ######
                    tabPanel("Cohort database",
                      box(width=12, title='Registed cohort', collapsible = TRUE,
                        DT::dataTableOutput("Cohort_DataBaseTable"),
                        fluidRow( column(1, actionButton('Cohort_DataBase_save_dt', 'Save changes')), column(2, actionButton('Cohort_DataBase_delete_row', 'Delete selected data')), column(7, verbatimTextOutput('Cohort_DataBase_status')) )
                      ),
                      box(width=12, title='Upload',collapsible = TRUE,
                        tags$details(
                          tags$summary("Quick upload guide ▼"),  # クリックすると開閉されるタイトル
                          div(
                            tags$ul(
                              tags$li("Make sure that the column name sample names (or patients IDs) is set 'sample'."),
                              tags$li("The fist column of the gene expression file must be the samples"),
                              tags$li("The Cohort name is mandatory and must be unique."),
                              tags$li("Avoid special characters; use only alphabets, numbers, underscores and dots."),
                            )
                          )
                        ),
                        h3(""),
                        fluidRow( column(4, fileInput("new_cohort_upload_GE", "Upload a Gene expression file"))),
                        fluidRow( column(4, fileInput("new_cohort_upload_sur", "Upload a survival data file"))),
                        fluidRow( column(4, fileInput("new_cohort_upload_meta", "Upload a metadaata file"))),
                        fluidRow( 
                          column(4, textAreaInput("new_cohort_upload_dataset_name", "Cohort Name*")),
                          column(4, textAreaInput("new_cohort_upload_description", "Description")) 
                        ),
                        fluidRow( column(2, actionButton('new_cohort_upload_data', 'Add a new cohort')), column(6, verbatimTextOutput('new_cohort_status'))),
                        h3(''),
                        fluidRow( 
                          h4('Preview (Expression table)'),
                          column(12, dataTableOutput("new_cohort_upload_GE_preview")),
                          h4('Preview (Survival data)'),
                          column(12, dataTableOutput("new_cohort_upload_sur_preview")),
                          h4('Preview (Meta data)'),
                          column(12, dataTableOutput("new_cohort_upload_meta_preview"))
                        ),
                      )
                    ),
                )
              )
            ###
          ),
        #### scRNA ####
          tabItem( tabName='scRNA',
            h2('scRNA'),
            #### dataset selection ####
              box( width=12, title='Dataset selection',
                fluidRow( 
                  column(6, htmlOutput("scRNA_data_select")) ,
                  column(4, h5('Dataset detail:'), verbatimTextOutput('scRNA_data_Dataset_detail'))
                )
              ),
            #### UMAP & Feature plot ####
              box(width=12, title='Data Overview',
                box(width=12, title='Umap plot', collapsible = TRUE, status = 'primary',
                  fluidRow(
                    # Plot1
                    column(8,
                      verbatimTextOutput('scRNA_UMAP1_status'),
                      fluidRow(
                        column(12, plotOutput("scRNA_UMAP1", brush = "scRNA_UMAP1_brush", width="100%", height="100%")),
                        column(4, htmlOutput("scRNA_UMAP1_groupBy"))
                      )
                    ),
                    column(4,
                      box(width=12, title='Plot options', collapsible = TRUE, collapsed = TRUE,
                        sliderInput('scRNA_umap1_fig.width', 'Fig width', min=300, max=3000, value=700, step=10),
                        sliderInput('scRNA_umap1_fig.height', 'Fig height', min=300, max=3000, value=500, step=10),
                        sliderInput('scRNA_umap1_XY_label', 'XY label size', min=10, max=40, value=15, step=1),
                        sliderInput('scRNA_umap1_XY_title', 'XY title size', min=10, max=40, value=20, step=1),
                        sliderInput('scRNA_umap1_legend_size', 'Legend size', min=10, max=40, value=15, step=1),
                        sliderInput('scRNA_umap1_graph_title', 'Graph title size', min=10, max=40, value=20, step=1)
                      )
                    )
                  )
                ),
                box(width=12, title='Gene Feature plot', collapsible = TRUE, status = 'primary',
                  fluidRow(
                    column(4, textAreaInput("scRNA_UMAP2_gene", "Enter genes names (line by line)"))
                  ),
                  fluidRow(
                    # plot2
                    column(8,
                      fluidRow(
                        column(4, h4('Select a gene below:'), DT::dataTableOutput("scRNA_UMAP2_gene_table"), verbatimTextOutput('scRNA_UMAP2_gene_input_status')),
                        column(8, h4('Feature plot'), verbatimTextOutput('Feature_Plot_status_catch'), plotOutput("scRNA_UMAP2", brush = "scRNA_UMAP2_brush", width="100%", height="100%")),
                      )
                    ),
                    column(4,
                      box(width=12, title='Plot options', collapsible = TRUE, collapsed = TRUE,
                        sliderInput('scRNA_umap2_fig.width', 'Fig width (Feature plot)', min=300, max=3000, value=500, step=10),
                        sliderInput('scRNA_umap2_fig.height', 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10),
                        sliderInput('scRNA_umap2_XY_label.font.size', 'X/Y label font size', min=5, max=40, value=15, step=1),
                        sliderInput('scRNA_umap2_XY_title.font.size', 'X/Y title font size', min=5, max=40, value=15, step=1),
                        sliderInput('scRNA_umap2_graph.title.font.size', 'Graph title font size', min=5, max=40, value=15, step=1),
                        sliderInput('scRNA_umap2_legend_size', 'Legend font size', min=5, max=40, value=15, step=1),
                        colourInput('scRNA_umap2_highest_colour', 'Colour for the highest expression', value='red'),
                        colourInput('scRNA_umap2_lowest_colour', 'Colour for the lowest expression', value='white'),
                        colourInput('scRNA_umap2_zero_colour', 'Colour for zero (background)', value='#676767'),
                        checkboxInput('scRNA_umap2_while_background', 'Use white background', value=FALSE)
                      )
                    )
                  )
                )
              ),
            #### Other plot ####
              box(width=12, title='Other plots', collapsible = TRUE, collapsed = TRUE,
                tabsetPanel(
                  tabPanel("Dot/Ridge/Vlnplot",
                    box(width=12, title='Gene expression across groups', collapsible = TRUE, status = 'primary',
                      fluidRow(
                        column(8,
                          fluidRow(
                            column(4, textAreaInput("scRNA_VlnPlot_gene", "Enter genes name")),
                            column(3, radioButtons("scRNA_Vln_figType", "Visualisation type", choices = c('Vln Plot'='A', 'Ridge Plot'='B', 'Dot Plot'='C'), selected='C')),
                            column(4, htmlOutput("scRNA_VlnPlot_groupBy"))
                            # column(3, htmlOutput("scRNA_VlnPlot_splitBy"))
                          ),
                          fluidRow(
                            verbatimTextOutput('scRNA_VlnPlot_status'),
                            column(12,  plotOutput("scRNA_VlnPlot", width="100%", height="100%"))
                          )
                        ),
                        column(4,
                          box(width=12, title='Plot options', collapsible = TRUE, collapsed = TRUE,
                            column(12,sliderInput('scRNA_vln_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                            column(12,sliderInput('scRNA_vln_fig.height', 'Fig height', min=300, max=3000, value=500, step=1)),
                            column(12,sliderInput('scRNA_vln_label_size', 'X/Y label size', min=3, max=30, value=10, step=1)),
                            column(12,sliderInput('scRNA_vln_legend_size', 'legend size', min=3, max=30, value=10, step=1))
                          ) 
                        )
                      )
                    ),
                  ),
                  tabPanel("Pie chart",
                    box(width=12, title='Fraction of the cells expressing a gene', collapsible = TRUE, status = 'primary',
                      fluidRow(
                        column(8,
                          fluidRow(
                            column(4, textAreaInput("scRNA_fraction_gene", "Enter genes name")),
                            column(3, htmlOutput("scRNA_fraction_groupBy")),
                          ), 
                          fluidRow(
                            column(3,  h4('Select a gene below:'), DT::dataTableOutput("scRNA_fraction_gene_table"), verbatimTextOutput('scRNA_fraction_gene_input_status')),
                            column(9,  h4('Pie Chart'), verbatimTextOutput('scRNA_fraction_status'),plotOutput("scRNA_fraction_piechart", width="100%", height="100%"))
                          )
                        ),
                        column(4,
                          box(width=12, title='Plot options', collapsible = TRUE, collapsed = TRUE,
                            column(12,sliderInput('scRNA_fraction_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                            column(12,sliderInput('scRNA_fraction_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                            column(12,sliderInput('scRNA_fraction_label_size', 'Label size', min=1, max=30, value=4, step=1)),
                            column(12,sliderInput('scRNA_fraction_group_name_size', 'Group name size', min=10, max=40, value=15, step=1)),
                            column(12,sliderInput('scRNA_fraction_legend_size', 'Legend size', min=3, max=30, value=10, step=1)),
                            column(12,colourInput('scRNA_fraction_expressing_colour', "Colour for 'Expressing'",  value='#3467ff')),
                            column(12,colourInput('scRNA_fraction_non_expressing_colour', "Colour for 'Non.expressing'", value='#f3fbff')),
                            column(12, checkboxInput('scRNA_fraction_hide_legend', 'Hide legends', value=FALSE)),
                            column(12, checkboxInput('scRNA_fraction_hide_label', 'Hide labels', value=FALSE))
                          )
                        )
                      )
                    )
                  ),
                )
                # Vln plot


              )
          ),
        #### IGV ####
          tabItem( tabName='igv',
            box( width=12, title='Data selection',
              fluidRow( 
                column(2, radioButtons("igv_data_type", "Data type", choices = c('BED' = 'D', 'BAM' = 'E'), selected='D')),
                column(3, htmlOutput("igv_data_select")),
                column(1, h5('Click here'), actionButton("igv_data_add", "View in IGV")),
                column(4, h5('Dataset detail:'), verbatimTextOutput('igv_Dataset_detail'))
              ),
              h5('Dataset filter'),
              fluidRow(
                column(3, htmlOutput("igv_data_DataFrom")),
                column(3, htmlOutput("igv_data_Experiment"))
              )
            ),
            box( width=12, title='IGV', 
              igvShinyOutput("igv", height = "1000px")
            )
          ),
        #### Tools ####
          tabItem( tabName='Tools',
            h2('Tools'),
            tabsetPanel(
              tabPanel('Human <=> Mouse',
                box(width=12, 
                  h3("Convert Huamns genes with Mouse genes."),
                  fluidRow(
                    column(3, radioButtons("human_mouse_convert_direction", "Human <=> Mouse direction", choices = c('Convert mouse genes to human genes' = 'A', 'Convert human genes to mouse genes' = 'B'), selected='A')),
                    column(2, radioButtons("human_mouse_convert_input_type", "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A')),
                    column(2, radioButtons("human_mouse_convert_output_type", "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A'))
                  ),
                  fluidRow(
                    column(5, textAreaInput('human_mouse_convert_input_gene', 'Enter genes (line by line)')),
                  ),
                  actionButton('human_mouse_convert_start', 'convert genes'),
                  fluidRow(
                    column(7, h4('Conversion table'), DT::dataTableOutput('human_mouse_convert_table')),
                    column(5, h4('List of converted genes'), verbatimTextOutput('human_mouse_convert_result'))
                  )
                )
              ),
              tabPanel('Gene symbol <=> Ensembl',
                box(width=12, 
                h3("Convert Ensemble gene ids with Gene symbols."),
                  fluidRow(
                    column(2, radioButtons("Gene_Ensembl_spieces", "Species", choices=c("Human"='A', "Mouse"='B'), selected="A")),
                    column(2, radioButtons("Gene_Ensembl_input_type", "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='B')),
                    column(2, radioButtons("Gene_Ensembl_output_type", "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A'))
                  ),
                  fluidRow(
                    column(5, textAreaInput('Gene_Ensembl_input_gene', 'Enter genes (line by line)')),
                  ),
                  actionButton('Gene_Ensembl_convert_start', 'convert genes'),
                  fluidRow(
                    column(7, h4('Conversion table'), DT::dataTableOutput('Gene_Ensembl_convert_table')),
                    column(5, h4('List of converted genes'), verbatimTextOutput('Gene_Ensembl_convert_result'))
                  )
                )
              ),
              tabPanel('Find gene loci',
                box(width=12,
                  h3("Find the genomic loci"),
                  fluidRow(
                    column(6, radioButtons("Find_genome_loci_direction", "Choose the method", choices = c('Input genes and find the coordinates' = 'A', 'Input coordinates and find the genes' = 'B'), selected='A')),
                  ),
                  fluidRow(
                    column(5, textAreaInput('Find_genome_loci_input', 'Enter gene names or coordinates (line by line)')),
                  ),
                  fluidRow(
                    column(4, actionButton('Find_genome_loci_start', 'Find'),)
                  ),
                  fluidRow(
                    column(7, h4('Results table'), DT::dataTableOutput('Find_genome_loci_table')),
                    column(5, h4('List of genes/coordinates'), verbatimTextOutput('Find_genome_loci_table_gene_names'))
                  )
                )
              )
            )
          ),
        #### wiki-document ####
          tabItem( tabName='wiki_document',
            tabsetPanel(
                tabPanel("Introduction", box(width=12, uiOutput("Introduction_md"))),
                tabPanel("Database", box(width=12, uiOutput("Database_md"))),
                tabPanel("Data_Overview", box(width=12, uiOutput("Data_Overview_md"))),
                tabPanel("Gene Set", box(width=12, uiOutput("Gene_set_md"))),
                tabPanel("Compare acorss datasets", box(width=12, uiOutput("Compare_acorss_datasets_md"))),
                tabPanel("Clinical data", box(width=12, uiOutput("Cilinical_data_md"))),
                tabPanel("Integration", box(width=12, uiOutput("integrate_two_md"))),
                tabPanel("scRNA", box(width=12, uiOutput("scRNA_md"))),
                tabPanel("IGV", box(width=12, uiOutput("igv_md"))),
                tabPanel("Tools", box(width=12, uiOutput("Tools_md"))),
                tabPanel("FAQ", box(width=12, uiOutput("FAQ_md")))
            )
          )
      ),
      h4(tags$div("Last updated on 25th. Feb, 2025 ", style = "text-align: right;"))
    )
  )
)



##############################################################################
server <- function(input, output, session) {

  ### Information Tab ##############################################################################
  
    #### Show the data list ####
      Dataset <- reactiveVal({
        tmp <- read.delim('data/Database.tsv', sep='\t', header=T)
        data.frame(tmp)
      })
      output$Data_type_filter <- renderUI({ 
        tmp <- Dataset()
        selectInput('Data_type_filter', 'Data type', c(All= 'None', unique(tmp$Data.type)))
      })
      output$Seuqenced_by_filter <- renderUI({ 
        tmp <- Dataset()
        selectInput('Seuqenced_by_filter', 'Data from', c(All= 'None', unique(tmp$Data.from)))
      })
      output$DataBaseTable <- DT::renderDataTable({ 
        data_table_tmp <- Dataset()[order(Dataset()$Added.When, decreasing =T),]
        data_table_tmp <- data_table_tmp[,c( "Dataset", "Data.type", "CellLine", "Data.from", "When", 'Experiment', 'Control.group', 'Treatment.group', "Data.Class", "Description")] 
        if(!is.null(input$Data_type_filter) && input$Data_type_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.type == input$Data_type_filter, ] }
        else if(!is.null(input$Seuqenced_by_filter) && input$Seuqenced_by_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Seuqenced_by_filter,] }
        datatable(data_table_tmp, 
          selection='none', extensions=c('Select'), 
          options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 25 , dom='Blfrtip', rowId=0), 
          editable='cell') 
      },server = FALSE)

    #### allow editing the information ####
      observeEvent(input$DataBaseTable_cell_edit,{
        info <- input$DataBaseTable_cell_edit
        # output$status <- renderText(paste(as.character(info$row), as.character(info$col), as.character(info$value)))
        tmp <- Dataset()
        a <- tmp[info$row, info$col]
        tmp[info$row, info$col] <- info$value
        # if(info$col == 6 | info$col == 4){
        #   save_path <- file.path('00_Expression_data_all', tmp[info$row, 'Data.from'], tmp[info$row, 'Experiment'], strsplit(tmp[info$row, 'Path'], '/')[[1]][length(strsplit(tmp[info$row, 'Path'], '/')[[1]])])
        #   dir.create(file.path('00_Expression_data_all', tmp[info$row, 'Data.from'], tmp[info$row, 'Experiment']), recursive=T, showWarnings = T)
        #   file.copy(tmp[info$row, 'Path'], save_path)
        #   file.remove(tmp[info$row, 'Path'])
        #   tmp[info$row,'Path'] <- save_path
        # }
        output$status <- renderText(paste0("'",a, "'", ' -> ', "'", info$value ,"'" ))
        tmp <- tmp[order(tmp$Added.When,decreasing =T),]
        Dataset(tmp)
        replaceData(dataTableProxy('Dataset'), Dataset(), resetPaging=F)
      })

    #### save changes when you push the button ####
      observeEvent(input$save_dt,{
        write.table(Dataset(), 'Database.tsv', row.names=F, sep='\t', quote=F)
        output$status <- renderText('saved!')
      })

    #### delete the data when you push the button ####
      observeEvent(input$delete_row, {
        tmp <- Dataset()
        tmp2 <- Dataset()
        if(!is.null(input$Data_type_filter) && input$Data_type_filter != 'None'){ tmp2 <- tmp2[tmp2$Data.type == input$Data_type_filter, ] }
        else if(!is.null(input$Seuqenced_by_filter) && input$Seuqenced_by_filter != 'None'){ tmp2 <- tmp2[tmp2$Data.from == input$Seuqenced_by_filter,] }
        selected_row <- input$DataBaseTable_rows_selected
        if(!is.null(selected_row) && length(selected_row) > 0){
          filepaths <- tmp2[selected_row,]$Path
          tmp <- tmp[!tmp$Dataset %in% tmp2[selected_row,]$Dataset,]
          # delete the file(s)
          for (filepath in filepaths){
            file.remove(filepath)
          }
          Dataset(tmp)
          replaceData(dataTableProxy('Dataset'), Dataset(), resetPaging=F)
          write.table(Dataset(), 'Database.tsv', row.names=F, sep='\t', quote=F)
          output$status <- renderText('Deleted!')
        }else{
          output$status <- renderText('No row selecetd!')
        }
      })

    #### data upload ####
      output$upload_data_preview <- renderDataTable({ 
        req(input$upload_file)
        gx_table <- read.table(input$upload_file$datapath, sep='\t', header=T)
        if(!'id' %in% colnames(gx_table)){
          output$status_upload <- renderText("The column name containing gene names in the input file has to be set 'id'.")
        }
        datatable( head(gx_table, 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
      })

      observeEvent(input$upload_data,{
        if(is.null(input$upload_file)){
          output$status_upload <- renderText('Please upload a file!')
        }
        req(input$upload_file)
        uploaded_file <- input$upload_file
        # detail
        dataset.name.upload <- unlist(strsplit(input$upload_dataset_name, split = "\n"))[1]
        data.type.upload <- unlist(strsplit(input$upload_data_type, split = "\n"))[1]
        cellline.upload <- unlist(strsplit(input$upload_cell_line, split = "\n"))[1]
        Data.from.upload <- unlist(strsplit(input$upload_data_from, split = "\n"))[1]
        Data.from.upload <- gsub(' ', '_', Data.from.upload)
        When.upload <- unlist(strsplit(input$upload_when, split = "\n"))[1]
        Description <- unlist(strsplit(input$upload_description, split = "\n"))[1]
        Experiment.upload <- unlist(strsplit(input$upload_Experiment, split = "\n"))[1]
        Experiment.upload <- gsub(' ', '_', Experiment.upload)
        Control.group.upload <- unlist(strsplit(input$upload_Control_group, split = "\n"))[1]
        Treatment.group.upload <- unlist(strsplit(input$upload_Treatment_group, split = "\n"))[1]
        Data.Class.upload <- input$upload_Data_Class
        if(nchar(input$upload_dataset_name)==0 | nchar(input$upload_data_from)==0 | nchar(input$upload_Experiment)==0 | nchar(input$upload_data_type)==0 ){
          output$status_upload <- renderText('* is a mandatory filed!')
        }
        else if(dataset.name.upload %in% Dataset()$Dataset){
          output$status_upload <- renderText('The Dataset name is duplicated!')
        }else if (str_detect(Experiment.upload, "[;/,()\\[\\]!@#$%]")) {
          output$status_upload <- renderText('The Experiment name cannot contain "/ , ( ) [ ] ! # @ $ %"!')
        }
        else if (str_detect(Data.from.upload, "[;/,()\\[\\]!@#$%]")) {
          output$status_upload <- renderText('The Data.from cannot contain "/ , ( ) [ ] ! # @ $ %"!')
        }else{
          gx_table <- read.table(input$upload_file$datapath, sep='\t', header=T)
          if(!'id' %in% colnames(gx_table)){
            output$status_upload <- renderText("The column name containing gene names in the input file has to be set 'id'.")            
          }else{
            time_stamp <- as.character(Sys.time())  
            Year <- format(Sys.time(), "%Y")
            date <- format(Sys.time(), "%m.%d")
            # path
            # a <- gsub(' ', '_', Data.from.upload); b <- gsub(' ', '_', Experiment.upload)
            filname <- paste0(format(Sys.time(), "%H.%M.%S"), '-', uploaded_file$name )
            save_path <- file.path('00_Expression_data_all', Year, date, filname)
            dir.create(file.path('00_Expression_data_all', Year, date), recursive=T, showWarnings = T)
            # save
            file.copy(uploaded_file$datapath, save_path)

            tmp <- Dataset()
            tmp <- add_row(tmp, Dataset=dataset.name.upload ,Data.type=data.type.upload ,CellLine=cellline.upload ,Data.from=Data.from.upload , Experiment=Experiment.upload, Control.group=Control.group.upload, Treatment.group=Treatment.group.upload, Data.Class=Data.Class.upload, When=When.upload ,Path=save_path ,  Description=Description, Added.When = time_stamp)
            tmp <- tmp[order(tmp$Added.When, decreasing =T),]
            Dataset(tmp)
            replaceData(dataTableProxy('Dataset'), Dataset(), resetPaging=F)
            write.table(Dataset(), 'data/Database.tsv', row.names=F, sep='\t', quote=F)
            output$status_upload <- renderText('uploaded!')
          }
        }

      })
  ###

  ### Gene sets Tab ################################################################################

    #### Show the data list ####
      Original_geneset_lsit <- reactiveVal({data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T))})
      output$Original_geneset_DataBaseTable <-  DT::renderDataTable({
        data_table_tmp <- Original_geneset_lsit()[order(Original_geneset_lsit()$Added.When, decreasing =T),]
        data_table_tmp <- data_table_tmp[,c('Geneset.name','Description','Cell.type','Data.source', 'Genes')]
        datatable(data_table_tmp, 
          selection='none', extensions=c('Select'), 
          options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 25 , dom='Blfrtip', rowId=0), 
          editable='cell') 
      },server = FALSE)

    #### allow editing the information ####
      observeEvent(input$Original_geneset_DataBaseTable_cell_edit,{
        info <- input$Original_geneset_DataBaseTable_cell_edit
        tmp <- Original_geneset_lsit()
        tmp[info$row, info$col] <- info$value
        output$Original_geneset_status <- renderText(paste(info$row, info$col,info$value ))
        tmp <- tmp[order(tmp$Added.When,decreasing =T),]
        Original_geneset_lsit(tmp)
        replaceData(dataTableProxy('Original_geneset_lsit'), Original_geneset_lsit(), resetPaging=F)
      })

    #### save changes when you push the button ####
      observeEvent(input$Original_geneset_save_dt,{
        write.table(Original_geneset_lsit(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)
        output$Original_geneset_status <- renderText('saved!')
      })

    #### delete the data when you push the button ####
      observeEvent(input$Original_geneset_delete_row, {
        tmp <- Original_geneset_lsit()
        tmp2 <- Original_geneset_lsit()
        selected_row <- input$Original_geneset_DataBaseTable_rows_selected
        if(!is.null(selected_row) && length(selected_row) > 0){
          tmp <- tmp[!tmp$Geneset.name %in% tmp2[selected_row,]$Geneset.name,]
          Original_geneset_lsit(tmp)
          replaceData(dataTableProxy('Original_geneset_lsit'), Original_geneset_lsit(), resetPaging=F)
          write.table(Original_geneset_lsit(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)
          output$status <- renderText('Deleted!')
        }else{
          output$status <- renderText('No row selecetd!')
        }
      })

    #### Add a new geneset ####
      observeEvent(input$Original_geneset_upload_data,{
        # detail
        geneset.name.upload <- unlist(strsplit(input$Original_geneset_upload_Geneset_name, split = "\n"))[1]
        Cell.type.upload <- unlist(strsplit(input$Original_geneset_upload_cell_line, split = "\n"))[1]
        data.source.upload <- unlist(strsplit(input$Original_geneset_upload_data_generated_from, split = "\n"))[1]
        When.upload <- unlist(strsplit(input$Original_geneset_upload_when, split = "\n"))[1]
        Description <- unlist(strsplit(input$Original_geneset_upload_description, split = "\n"))[1]
        genes <- ''
        for (key in unlist(strsplit(input$Original_geneset_upload_genes, split = "\n"))){
          if(genes != ''){
            genes <- paste(genes, key, sep=', ')
          }else{
            genes <- key
          }
        }
        time_stamp <- as.character(Sys.time())  
        
        if(geneset.name.upload %in% Original_geneset_lsit()$Geneset.name){
          output$Original_geneset_status_upload <- renderText('The Geneset name is duplicated!')
        }else if(is.null(genes) || genes == ''){
          output$Original_geneset_status_upload <- renderText('Please Enter the names of the genes')
        }else{
          tmp <- Original_geneset_lsit()
          tmp <- add_row(tmp, Geneset.name=geneset.name.upload , Description=Description , Cell.type=Cell.type.upload , Data.source=data.source.upload , Genes=genes, Added.When=time_stamp)
          tmp <- tmp[order(tmp$Added.When, decreasing =T),]
          Original_geneset_lsit(tmp)
          replaceData(dataTableProxy('Original_geneset_lsit'), Original_geneset_lsit(), resetPaging=F)
          write.table(Original_geneset_lsit(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)
          output$Original_geneset_status_upload <- renderText('uploaded!')
        }

      })
  ###
  
  ### Data overview ################################################################################

    #### Dataset selection ####
      ##### Filtering for a Dataset selection #####
        output$Seuqenced_by <- renderUI({ 
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          selectInput('Seuqenced_by', 'Data from', c('None'= 'None', unique(df_tmp$Data.from)))
        })
        output$Experiments <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}}
          # if(!is.null(input$Data_type) & input$Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}
          selectInput('Experiments', 'Experiment', c('None'= 'None', unique(df_tmp$Experiment)))
        })
        output$Data_type <- renderUI({ 
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]} }
          if(!is.null(input$Experiments)) { if(input$Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}}
          selectInput('Data_type', 'Data type', c('None'= 'None', unique(df_tmp$Data.type)))
        })
      
      ##### Select a dataset #####
        output$Dataset_select <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Data_type)) { if(input$Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}}
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}}
          if(!is.null(input$Experiments)) { if(input$Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}}
          selectInput('Dataset_select', 'Dataset select', c('None'='None', unique(df_tmp$Dataset)) )
        })

        output$Data_class <- reactive({
          df_tmp <- Dataset()
          df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Data.Class
        })
        outputOptions(output, 'Data_class', suspendWhenHidden=FALSE)

        Data_class <- reactive({
          df_tmp <- Dataset()
          df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Data.Class
        })

        Dataoverview_Data_type <- reactive({
          df_tmp <- Dataset()
          df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Data.type
        })

        output$Dataset_detail <- renderText({
          df_tmp <- Dataset()
          if(!is.null(input$Dataset_select) && input$Dataset_select != 'None'){
            paste0('Data.from: ', as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Data.from), '\n', 
                  'Experiment: ', as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Experiment), '\n', 
                  'Data.type: ' , as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Data.type), '\n', 
                  'When: ' , as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$When), '\n', 
                  'Control.group: ' , as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Control.group), '\n',
                  'Treatment.group: ' , as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Treatment.group), '\n',
                  'Description: ' , as.character(df_tmp[df_tmp$Dataset == input$Dataset_select, ]$Description), '\n'
                  )
          }else{
            'Please select a dataset.'
          }
        })
    ####

    #### Data Table ####
      ##### expression table #####
        # some files (DEG files) have Inf value. This is a function for replacing a Inf value with a biggest finite value
        replace_inf_with_largest_values <- function(values){ 
            values[is.infinite(values)] <- max(values[values != Inf]) * 1.1 
            return(values)
        }
        # load data
        df <- reactive({
          if(length(input$Dataset_select)!=0){
            if(input$Dataset_select!= 'None'){
              path <- Dataset()[Dataset()$Dataset == input$Dataset_select, ]$Path
              if(length(path) == 0){
                output$Count_data_DataTable_status <- renderText({"The file is not found. Please upload the data again."})
                return(NULL)
              }
              if(!file.exists(path)){
                output$Count_data_DataTable_status <- renderText({"The file is not found. Please upload the data again."})
                return(NULL)
              }
              output$Count_data_DataTable_status <- renderText({NULL})
              df_tmp <- read.table(path, sep='\t', header=T)
              if(colnames(df_tmp)[1] == 'X'){ colnames(df_tmp)[1] <- 'id'}
              if("X.log10.pvalue." %in% colnames(df_tmp)){ df_tmp$X.log10.pvalue. <- replace_inf_with_largest_values(df_tmp$X.log10.pvalue.) }
              if("X.log10.padj." %in% colnames(df_tmp)){ df_tmp$X.log10.padj. <- replace_inf_with_largest_values(df_tmp$X.log10.padj.) }
              numeric_cols <- names(df_tmp)[!(names(df_tmp) %in% 'id')]
              df_tmp[numeric_cols] <- lapply(df_tmp[numeric_cols], as.numeric)
              df_tmp[is.na(df_tmp)]<-0
              df_tmp
            }else{
              return(NULL)
            }
          }else{
            return(NULL)
          }
        })
        # when nothing is selected
        output$Data_Overview_plot <- renderText({"Please select a dataset above"})  

        # display expression data
        output$DataTable <- DT::renderDataTable({ datatable( data.frame(df()), options = list(scrollX = TRUE, pageLength = 20 )) })
        output$Count_data_DataTable <- DT::renderDataTable({ datatable( data.frame(df()), options = list(scrollX = TRUE, pageLength = 20 )) })


      ##### Plot #####
        ###### necessary parameters / option #####
          output$Scat.X <- renderUI({ 
            if(!is.null(df())){ X_axis_name <- names(df()) }
            else{ X_axis_name <- c() }
            # default selected x name CRISPR screening (gRNA LFC)
            if(Dataoverview_Data_type() == 'CRISPR screening' || Dataoverview_Data_type() == 'CRISPR-a screening'){ selectInput('scat.x', 'x', c('None'='None', X_axis_name), selected='logFC') }
            else if(Dataoverview_Data_type() == 'ORF screening'){ selectInput('scat.x', 'x', c('None'='None', X_axis_name), selected='log10_total_count') }
            else if(Dataoverview_Data_type() == 'RNAseq (DEG)'){ selectInput('scat.x', 'x', c('None'='None', X_axis_name), selected='log2FoldChange') }
            else if(Dataoverview_Data_type() == 'CRISPR screening (gRNA LFC)'){ selectInput('scat.x', 'x', c('None'='None', X_axis_name), selected='LFC') }
            else if(Dataoverview_Data_type() == 'CRISPR screening (gRNA LFC, norm by NTgRNA)'){ selectInput('scat.x', 'x', c('None'='None', X_axis_name), selected='LFC') }
            else{selectInput('scat.x', 'x', c('None'='None', X_axis_name))}
          })
          output$Scat.Y <- renderUI({ 
            if(!is.null(df())){ Y_axis_name <- names(df()) }
            else{ Y_axis_name <- c() }
            # default selected x name
            if(Dataoverview_Data_type() == 'CRISPR screening' ){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='log10_score') }
            else if(Dataoverview_Data_type() == 'CRISPR-a screening'){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='log10_Score') }
            else if(Dataoverview_Data_type() == 'ORF screening'){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='log2LFC') }
            else if(Dataoverview_Data_type() == 'RNAseq (DEG)'){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='X.log10.padj.') }
            else if(Dataoverview_Data_type() == 'CRISPR screening (gRNA LFC)'){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='X.log10.p.value') }
            else if(Dataoverview_Data_type() == 'CRISPR screening (gRNA LFC, norm by NTgRNA)'){ selectInput('scat.y', 'y', c('None'='None', Y_axis_name), selected='X.log10.p.value') }
            else{selectInput('scat.y', 'y', c('None'='None', Y_axis_name))}
          })

          # the outliers checkbox and the pathway genes checkbox are exclusive each other
          observeEvent(input$show_outliers, { 
            if(input$show_outliers){ updateCheckboxInput(session, "show_pathway", value=FALSE)}
            if(input$show_outliers){ updateCheckboxInput(session, "Plot_Gene_set", value=FALSE)}
          })
          observeEvent(input$show_pathway, { 
            if(input$show_pathway){ updateCheckboxInput(session, "show_outliers", value=FALSE)}
            if(input$show_pathway){ updateCheckboxInput(session, "Plot_Gene_set", value=FALSE)}
          })
          observeEvent(input$Plot_Gene_set, { 
            if(input$Plot_Gene_set){ updateCheckboxInput(session, "show_outliers", value=FALSE)}
            if(input$Plot_Gene_set){ updateCheckboxInput(session, "show_pathway", value=FALSE)}
          })

        ###### Interesting genes #####
          # Genes of interest
          df_genes_interest <- reactive({
            df_main_plot <- df()
            df_tmp <- df_main_plot[df_main_plot$id %in% unlist(strsplit(input$target_gene, split = "\n")),] 
            return(df_tmp)
          })

          # diplay only genes of interest
          output$Interesting_gene_outFile <- renderDataTable({ 
            req(input$show_entered_gene_info)
            # df_main_plot <- df()
            if(input$show_entered_gene_info){ 
              datatable( data.frame(df_genes_interest()),  options = list(scrollX = TRUE, pageLength = 10 )) 
            }
          })
          
          # download the table
          output$Interesting_gene_download <- downloadHandler(
            filename = function(){"Interesting_gene_table.csv"}, 
            content = function(fname){ write.csv(df_genes_interest(), fname) }
          )

        ###### outliers ######
          # get the table
          df_outliers <- reactive({
            df_main_plot <- df()
            req(input$show_outliers)
            if(input$show_outliers){
              if(input$How_to_filter == 'A'){
                df_main_plot <- df_main_plot[df_main_plot[input$scat.y] >= input$Overviwe_Top_bottom_Y_threshold,]
                X_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x]>=0], 1-(input$Overviwe_Top_threshold/100))
                Y_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x]<=0], input$Overviwe_Bottom_threshold/100)
                df_main_plot[((df_main_plot[input$scat.x] > X_thr | df_main_plot[input$scat.x] < Y_thr)), ]
              }else if(input$How_to_filter == 'B'){
                switch(input$Direction,
                  "A" = df_main_plot[((df_main_plot[input$scat.x] >= input$x_threshold | df_main_plot[input$scat.x] <= -input$x_threshold_neg) & df_main_plot[input$scat.y] >= input$y_threshold), ],
                  "B" = df_main_plot[(df_main_plot[input$scat.x] >= input$x_threshold & df_main_plot[input$scat.y] >= input$y_threshold), ],
                  "C" = df_main_plot[(df_main_plot[input$scat.x] <= -input$x_threshold_neg & df_main_plot[input$scat.y] >= input$y_threshold), ])
              }
            }else if (input$show_pathway) {
                df_main_plot[df_main_plot$id %in% genes_in_the_pathway(),]
            }
          })
          # diplay the filtered genes' information
          output$outFile3 <- renderDataTable({ datatable( data.frame(df_outliers()), options = list(scrollX = TRUE, pageLength = 10 )) })

          # download the filtered gene table
          output$filtered_download <- downloadHandler(
            filename = function(){"filtered_gene_table.csv"}, 
            content = function(fname){ write.csv(df_outliers(), fname) }
          )

          # show the list of the gene names
          output$filtered_gene_list <- renderText({
            paste(na.omit(df_outliers()$id), collapse = "\n")
          })

        ###### pathway analysis ######
          # load a gmt file and select the pathway
          Gene_set <- reactive({
            req(input$show_pathway)
            if(input$pathway_dataset_select == 'HALLMARK (human)'){ gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt') }
            else if(input$pathway_dataset_select == 'HALLMARK (mouse)'){ gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt') } 
            else if(input$pathway_dataset_select == 'Custom'){ 
              tmp <- input$upload_custom_pathway_file
              if (is.null(tmp)){ gsc <- NULL }
              else { gsc <- getGmt(tmp$datapath)}
            }
            gsc
          })

          # select pathway
          output$select_pathway <- renderUI({
            gene_sets_names <- c()
            if(!is.null(Gene_set())){
              for ( i in 1:length(Gene_set())){ gene_sets_names <- c(gene_sets_names, Gene_set()@.Data[[i]]@setName)}
            }
            selectInput('select_pathway', 'Select a geneset',  c('None'='None', gene_sets_names))  
          })

          # list of the genes in the pathway
          genes_in_the_pathway <- reactive({ 
            if(input$select_pathway == 'None'){ c('None') }
            else{ Gene_set()[[input$select_pathway]]@geneIds }
          })

          # Show pathway genes information as a table
          df_outliers_pathway <- reactive({
            df_main_plot <- df()
            req(input$show_pathway)
            if(input$show_pathway) { df_main_plot[df_main_plot$id %in% genes_in_the_pathway(),] }
          })

          # diplay the pathway genes' information
          output$outFile3_pathway <- renderDataTable({ datatable( data.frame(df_outliers_pathway()),options = list(scrollX = TRUE, pageLength = 10)) })

          # download the pathway gene table
          output$pathway_download <- downloadHandler(
            filename = function(){"pathway_gene_table.csv"}, 
            content = function(fname){ write.csv(df_outliers_pathway(), fname) }
          )

          # list up the gene names
          output$pathway_gene_list <- renderText({
            paste(na.omit(df_outliers_pathway()$id), collapse = "\n")
          })

        ###### Gene set ######
          # select a custom geneset
          output$Plot_Gene_set_select_geneset <- renderUI({
            gene_sets_names <- c()
            gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
            selectInput('Plot_Gene_set_select_geneset', 'Select your custom geneset',  c('None'='None', gene_sets_names))  
          })

          # dataframe only with the genes in the selected custom geneset
          df_genes_custom_geneset <- reactive({
            df_main_plot <- df()
            if(input$Plot_Gene_set_select_geneset != 'None'){
              target_genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Plot_Gene_set_select_geneset, ]$Genes, split=', ')[[1]]
              df_tmp <- df_main_plot[df_main_plot$id %in% target_genes,] 
              return(df_tmp)
            }else{
              return(NULL)
            }
          })

          # diplay only genes of interest
          output$outFile3_custom_geneset <- renderDataTable({ 
            req(input$Plot_Gene_setshow_information)
            if(input$Plot_Gene_setshow_information){ 
              datatable( data.frame(df_genes_custom_geneset()),  options = list(scrollX = TRUE, pageLength = 10 )) 
            }
          })
          
          # download the table
          output$custom_geneset_download <- downloadHandler(
            filename = function(){"Custom_geneset_gene_table.tsv"}, 
            content = function(fname){ write.table(df_genes_custom_geneset(), fname, sep='\t', row.names=F, quote=F) }
          )

          # list up the gene names
          output$Custom_geneset_gene_list <- renderText({
            paste(na.omit(df_genes_custom_geneset()$id), collapse = "\n")
          })

        ###### Swarmplot ######
          # For count table matrix (RNA, protein), data frame of the expression of a specific gene for generating a swarmplot
          
          # inputted_gene_list
          target_gene_for_RNA_table_tmp <- reactive({data.frame(Input=unique(unlist(strsplit(input$target_gene_for_RNA, split = "\n"))))})
          output$target_gene_for_RNA_table <- renderDataTable({
            datatable( target_gene_for_RNA_table_tmp(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
          })
          
          # prepare a dataframe
          df_gene <- reactive({
            if(Data_class() == 'A'){
              if(nchar(input$target_gene_for_RNA)==0){
                output$Gene_ex_swarm_status <- renderText({'Please enter genes.'})
              }else{
                output$Gene_ex_swarm_status <- NULL
              }
              req(input$target_gene_for_RNA)
              if(nchar(input$target_gene_for_RNA)==0){return(NULL)}
              else{
                Gene <- target_gene_for_RNA_table_tmp()[input$target_gene_for_RNA_table_rows_selected,]
                if(length(Gene)>0){
                  if(Gene %in% df()$id){
                    gene_num <- which(df()$id==Gene)
                    df_gene <- data.frame(t(df()[gene_num,2:dim(df())[2]])) 
                    colnames(df_gene) <- c('Expression')
                    Group <- c()
                    for (i in strsplit(rownames(df_gene), '_')){
                      tmp <- ''
                      for(j in 1:(length(i)-1)){
                        tmp <- paste0(tmp, i[j],'_')
                      }
                      tmp <- substr(tmp, 1, nchar(tmp)-1)
                      Group <- c(Group, tmp)
                    }
                    df_gene$Group <- Group
                    return(df_gene)
                  }else{
                    output$Gene_ex_swarm_status <- renderText({'The inputted gene is not in this data. \nPlease make sure the gene name is correct and do not have unnecessary spaces.'})
                    return(NULL)
                  }
                }else{
                  output$Gene_ex_swarm_status <- renderText({'Please select a row from the table'})
                  return(NULL)
                }
              }
            }
          })

          # display the data frame    
          output$outFile_expression <- renderDataTable({ 
            req(input$target_gene_for_RNA)
            datatable( data.frame(df_gene()), options = list(scrollX = TRUE, scrollY = TRUE)) 
          })
          
          # list of the groups
          output$Data_Overview_Swarm_group_name_list <- renderText({
            if(length(input$target_gene_for_RNA_table_rows_selected) == 0){
              NULL
            }else{
              tmp <- ""
              groups <- unique(df_gene()$Group)[order(unique(df_gene()$Group))]
              for (group in groups){
                tmp <- paste0(tmp, group , '\n')
              }
              tmp
            }
          })

          # colour option are mutually exclusive (use pallete or use a single colour)
          observeEvent(input$Data_Overview_Swarm_change_colour_pallete, { 
            if(input$Data_Overview_Swarm_change_colour_pallete){ updateCheckboxInput(session, "Data_Overview_Swarm_use_single_colour", value=FALSE)}
          })
          observeEvent(input$Data_Overview_Swarm_use_single_colour, { 
            if(input$Data_Overview_Swarm_use_single_colour){ updateCheckboxInput(session, "Data_Overview_Swarm_change_colour_pallete", value=FALSE)}
          })

          # plot
          output$Gene_ex_swarm <- renderPlot({
            
            if(is.null(input$Dataset_select) || input$Dataset_select=='None'){
              return(NULL)
            }else{
              Gene <- target_gene_for_RNA_table_tmp()[input$target_gene_for_RNA_table_rows_selected,]
              df_tmp <- df_gene()
              if(!is.null(df_tmp)){
                if(input$order_group){
                  selected_group <- intersect(unlist(strsplit(input$group_order, split = "\n")), df_tmp$Group)
                  df_tmp <- df_tmp[df_tmp$Group %in% selected_group,]
                  df_tmp$Group <- factor(df_tmp$Group, levels = c(selected_group))
                } 
                # p <- ggplot(df_tmp, aes(x = Group, y = Expression)) + geom_quasirandom(size=input$Data_Overview_Swarm_pt.size)
                # p <- ggplot(df_tmp, aes(x = Group, y = Expression, fill=Group)) + geom_point(size=input$Data_Overview_Swarm_pt.size, position=position_jitter(width=0.2))
                if(input$Data_Overview_Swarm_use_single_colour){
                  p <- ggplot(df_tmp, aes(x = Group, y = Expression)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size, color=input$Data_Overview_Swarm_choose_single_colour)
                }else{
                  p <- ggplot(df_tmp, aes(x = Group, y = Expression, color=Group)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size)
                  if(input$Data_Overview_Swarm_select_colour_pallete != 'None'){
                    p <- p + scale_color_viridis_d(option=input$Data_Overview_Swarm_select_colour_pallete) #(palette = input$Data_Overview_Swarm_select_colour_pallete)
                  }
                }
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle(Gene)+ theme(legend.position = 'none')
                p <- p + theme(axis.title = element_blank()) + theme(plot.title = element_text(size = input$Data_Overview_Swarm_graph.title.font.size))
                p <- p + theme(axis.text.y = element_text(size = input$Data_Overview_Swarm_ylab.font.size), axis.text.x = element_text(size = input$Data_Overview_Swarm_xlab.font.size))
                # column(12, sliderInput(inputId = 'Data_Overview_Swarm_pt.size', 'Point size', min=1, max=10, value=2))
              }else{
                return(NULL)
              }
            }
            if(input$Data_Overview_Swarm_white_background){
              p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
            }
            p
          }, width=reactive(input$Data_Overview_Swarm_fig.width), height=reactive(input$Data_Overview_Swarm_fig.height))

          # download the table
          output$outFile_expression_download <- downloadHandler(
          filename = function(){"One_Gene_expression.tsv"}, 
          content = function(fname){ write.table(df_gene(), fname, sep='\t',  quote=F) }
          )

        ###### Scatter plot ######
          # main plot for overvirw
          output$Gene_ex <- renderPlot({
            # No data is selected
            if(length(input$Dataset_select)==0){
              output$Gene_ex_status <- renderText({'Please select a dataset'})
              return(NULL)              
            }
            if(is.null(input$Dataset_select) || input$Dataset_select=='None'){
              output$Gene_ex_status <- renderText({'Please select a dataset'})
              return(NULL)
            }
            if(is.null(df())){
              output$Gene_ex_status <- renderText({"The file is not found. Please upload the data again."})
              return(NULL)
            }
            # scatter plot
            else{
              # create a ggplot object
              df_main_plot <- df()
              if( is.null(input$scat.x) || is.null(input$scat.y) ){ 
                output$Gene_ex_status <- renderText({'Please select the X and Y.'})
                return(NULL)
              }
              else if( input$scat.x == 'None' ||input$scat.y == 'None'){ 
                output$Gene_ex_status <- renderText({'Please select the X and Y.'})
                return(NULL)
              }
              else{ 
                output$Gene_ex_status <- renderText({NULL})
                p <- ggplot(df_main_plot, aes_string(x = input$scat.x, y = input$scat.y)) + geom_point(size = input$pt.size) 

              }
              # show outliers or show pathway genes # column(3, colourInput('outlier_gene_colour_id_negative', 'Negative side:', value='#FF8C00'))
              if(input$show_outliers){
                outliers <- df_outliers()
                p <- p + geom_point(data = outliers[outliers[input$scat.x]>=0,], color=input$outlier_gene_colour_id , size = input$high.pt.size)
                p <- p + geom_point(data = outliers[outliers[input$scat.x]<=0,], color=input$outlier_gene_colour_id_negative , size = input$high.pt.size)
                if(input$hide_gene_label == FALSE){
                  p <- p + geom_text_repel(data = outliers[outliers[input$scat.x]>=0,],  color = input$outlier_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps = 20)
                  p <- p + geom_text_repel(data = outliers[outliers[input$scat.x]<=0,],  color = input$outlier_gene_colour_id_negative, aes(label = id), size = input$high.label.size, max.overlaps = 20)
                }
                if(input$show_threhold_lines){
                  if(input$Direction == 'A' || input$Direction == 'B'){p <- p + geom_vline(xintercept=input$x_threshold, linetype='dotted')}
                  if(input$Direction == 'A' || input$Direction == 'C'){p <- p + geom_vline(xintercept=-input$x_threshold_neg, linetype='dotted')}
                  p <- p + geom_hline(yintercept=input$y_threshold, linetype='dotted')
                } 
              }else if(input$show_pathway){
                if(length(input$select_pathway)!= 0){
                  if(!is.null(input$select_pathway) & input$select_pathway != 'None'){
                    outliers_pathway <- df_outliers_pathway()
                    p <- p + geom_point(data = outliers_pathway, color=input$pathway_gene_colour_id , size = input$high.pt.size)
                    if(input$hide_gene_label_pathway==FALSE){ p <- p + geom_text_repel(data = outliers_pathway,  color = input$pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 20) }
                  }
                }
              }else if(input$Plot_Gene_set){
                if(length(input$select_pathway)!= 0){
                  if(!is.null(input$Plot_Gene_set_select_geneset) & input$Plot_Gene_set_select_geneset != 'None'){
                    custom_geneset <- df_genes_custom_geneset()
                    p <- p + geom_point(data = custom_geneset, color=input$Plot_Gene_set_pathway_gene_colour_id , size = input$high.pt.size)
                    if(input$Plot_Gene_sethide_gene_label==FALSE){ p <- p + geom_text_repel(data = custom_geneset,  color = input$Plot_Gene_set_pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 20) }
                  }
                }
              }
              # highlight some genes of interest
              if(nchar(input$target_gene) > 0){
                p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$target_gene, split = "\n")),], color=input$interesting_gene_colour_id , size = input$high.pt.size)
                undetected_genes <- setdiff(unlist(strsplit(input$target_gene, split = "\n")), df_main_plot$id)
                undetected_genes <- undetected_genes[undetected_genes!= '']
                if(length(undetected_genes) > 0){
                  output$Scatter_interesting_gene_status <- renderText({
                    tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                    genes_tmp <- ''
                    for (a in undetected_genes){
                      genes_tmp <- paste0(genes_tmp, a, ',')
                    }
                    genes_tmp <- substr(genes_tmp, 1, nchar(genes_tmp)-1)
                    paste0(tmp, genes_tmp)
                  })
                }else{
                  output$Scatter_interesting_gene_status <- renderText({NULL})
                }
                if(input$show_label){ p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$target_gene, split = "\n")),],  color = input$interesting_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps=20) }
              }else{
                output$Scatter_interesting_gene_status <- renderText({NULL})
              }
            }
            tryCatch(
              expr = {
                res <- brushedPoints(df(), input$plot_brush)
                p <- p + geom_text_repel(data = res,  color = 'black', aes(label = id), size = input$high.label.size,)
              },
              error = function(e){NULL}
            )
            p <- p + theme(axis.text.y = element_text(size = input$label.font.size), axis.text.x = element_text(size = input$label.font.size))
            p <- p + theme(axis.title.y = element_text(size = input$title.font.size), axis.title.x = element_text(size = input$title.font.size))
            if(input$while_background){
              p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
            }
            p
          }, width=reactive(input$fig.width), height=reactive(input$fig.height))

          # the selected genes' information
          Overview_selected_table <- reactive({
            req(input$plot_brush)
            if(Dataset()[Dataset()$Dataset == input$Dataset_select, 'Data.Class'] == 'B'){ 
              res <- brushedPoints(df(), input$plot_brush) 
              return(res)
            }else{return(NULL)}
          })

          # display the selected genes info as a table
          output$outFile2 <- renderDataTable({
            datatable( data.frame(Overview_selected_table()), options = list(scrollX = TRUE, pageLength = 10))
          })         

          # download the selected genes' infor
          output$selected_download <- downloadHandler(
            filename = function(){"selected_gene_table.tsv"},   
            content = function(fname){ write.table(Overview_selected_table(), fname, sep='\t', quote=F, row.names=F) }
          )

          # show the list of the gene names
          output$selected_gene_list <- renderText({
            if(is.null(Overview_selected_table)){return(NULL)}
            else{
              paste(na.omit(Overview_selected_table()$id), collapse = "\n")
            }
          })

          ## show a bar plot for the filtered genes
          # plotOutput("Gene_ex_barplot", width="100%", height="100%", hover=hoverOpts("barplot_plot_hover")),
          output$Gene_ex_barplot <- renderPlot({
            req(input$show_outliers_bar_plot)
            outliers <- df_outliers()
            outliers <- outliers[order(outliers[, input$scat.x], decreasing=T), ]
            outliers[,'id'] <- factor(outliers[,'id'], levels = c(outliers[,'id']))
            switch(input$show_outliers_bar_colour, 
              "X" = fill_option <- input$scat.x,
              "Y" = fill_option <- input$scat.y,
              "None" = fill_option <- NA)
            if(!is.null(input$target_gene) && input$target_gene!= "" ){
              highligh_category <- unlist(strsplit(input$target_gene, split = "\n"))
              outliers <- outliers %>% mutate(fill_colour = ifelse(id %in% highligh_category, 'red', 'gray'))
              p <- ggplot(outliers, aes_string(x= "id", y=input$scat.x, fill= 'fill_colour')) + scale_fill_identity()
            }else{
              if(is.na(fill_option)){
                p <- ggplot(outliers, aes_string(x= "id", y=input$scat.x))
              }else{
                p <- ggplot(outliers, aes_string(x= "id", y=input$scat.x, fill=fill_option))
              }
              if(!is.na(fill_option)){
                values_for_colours <- outliers[,fill_option][!is.na(outliers[,fill_option])]
                if( min(values_for_colours)<0 ){
                  if( max(values_for_colours)>=0 ){
                    tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                    p <- p + scale_color_gradientn( colors = c("blue", "white", "red"), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=fill_option)
                    p <- p + scale_fill_gradientn( colors = c("blue", "white", "red"), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=fill_option)
                  }else{
                    p <- p + scale_color_gradientn( colors = c("blue", "white"), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=fill_option)
                    p <- p + scale_fill_gradientn( colors = c("blue", "white"), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=fill_option)
                  }
                }else{
                  p <- p + scale_color_gradientn( colors = c("white", "red"), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=fill_option)
                  p <- p + scale_fill_gradientn( colors = c("white", "red"), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=fill_option)
                }
              }
            }
            if(input$show_outliers_rotate_x){
              p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
            }
            p <- p + geom_bar(stat='identity')
            p 
          }, width=reactive(input$fig.width), height=reactive(input$fig.height))


        ###### GO analysis ######
          # Choose the genes used in GO analysis
          GO_analysis_genes <- reactive({
            if(input$GO_input_type == 'Text input'){
              if(nchar(input$GO_input_geneList) > 0){
                unlist(strsplit(input$GO_input_geneList, split = "\n"))
              }else{
                return(NULL)
              }
            }
            else if(input$show_outliers & input$GO_input_type == 'Use filtered genes'){df_outliers()$id}
            else if(!is.null(input$plot_brush) & input$GO_input_type == 'Use selected genes'){brushedPoints(df(), input$plot_brush)$id}
            else {return(NULL)}
          })

          # Do GO analysis
          goResult <- eventReactive(input$GO_start, {
            if(is.null(GO_analysis_genes()) || length(GO_analysis_genes()) == 0){
              if(input$GO_input_type == 'Use filtered genes'){
                if(!input$show_outliers){
                  output$GO_go_status <- renderText({'Please filter the genes in the plot first. ("Show outliers" button)'})
                  return(NULL)    
                }
              }else if(input$GO_input_type == 'Text input'){
                output$GO_go_status <- renderText({'Please enter genes names. (Make sure that names are gene symbols and do not contain unnecessary spaces.)'})
              }
              output$GO_go_status <- renderText({'Please input the genes correctly.'})
              return(NULL)
            }
            genes <- GO_analysis_genes()
            genes <- genes[genes!='']
            if(length(genes) == 0){
              output$GO_go_status <- renderText({'Please input the genes correctly. \nPlease make sure the gene names are correct and do not contain unnecessary spaces.'})
              return(NULL)
            }
            geneList_ENTREZID <- tryCatch(
                bitr(genes, fromType="SYMBOL", toType="ENTREZID", OrgDb=ifelse(input$GO_species == "Human", "org.Hs.eg.db", "org.Mm.eg.db"))$ENTREZID,
                # bitr(c('FCRL1'), fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")$ENTREZID,
                error=function(e){
                  output$GO_go_status <- renderText({'Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.'})
                  return(NULL)
                }
              )
            if(is.null(geneList_ENTREZID)==TRUE){
              output$GO_go_status <- renderText({'Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.'})
              return(NULL)
            }
            output$GO_go_status <- renderText({NULL})
            if(input$GO_database == 'GO'){
              if(input$GO_species == 'Human'){ df_GO_base = as.data.frame(org.Hs.egGO)}
              else if(input$GO_species == 'Mouse'){ df_GO_base = as.data.frame(org.Mm.egGO) }
              go_gene_universe_list = unique(sort(df_GO_base$gene_id))
              output$GO_go_status <- renderText({NULL})
              out <- enrichGO(gene = geneList_ENTREZID, universe = go_gene_universe_list, OrgDb = ifelse(input$GO_species == "Human", "org.Hs.eg.db", "org.Mm.eg.db"), ont = input$GO_ontology, pAdjustMethod = "BH", pvalueCutoff = 1, qvalueCutoff = 1, readable = TRUE)
              if(is.null(out)){
                output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                return(NULL)
              }else{
                out
              }
            }else if(input$GO_database == 'KEGG'){
              if(input$GO_species == 'Human'){
                kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'hsa', pvalueCutoff = 1, qvalueCutoff = 1)
                if(is.null(kk_ORA)){
                  output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                  return(NULL)
                }else{
                  output$GO_go_status <- renderText({NULL})
                  kk_ORA <- setReadable(kk_ORA, 'org.Hs.eg.db', 'ENTREZID')
                  kk_ORA
                }
              }else if(input$GO_species == 'Mouse'){
                kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'mmu', pvalueCutoff = 1, qvalueCutoff = 1)
                if(is.null(kk_ORA)){
                  output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                  return(NULL)
                }else{
                  output$GO_go_status <- renderText({NULL})
                  kk_ORA <- setReadable(kk_ORA, 'org.Mm.eg.db', 'ENTREZID')
                  kk_ORA
                }
              }
            }else{
              output$GO_go_status <- renderText({'Please select the database (and the ontology) correctly.'})
              return(NULL)
            }
          })  

          output$GO_go_status <- renderText({NULL})
          outputOptions(output, "GO_go_status", suspendWhenHidden=FALSE)

          ## Plots and display the table ##
          # Goplot 
          output$GO_goPlot <- renderPlot({
            if(is.null(goResult())){ggplot()}
            else{barplot(goResult(), showCategory=input$GO_fig.category_show_number)  + theme(axis.text.y = element_text(size = input$GO_ylab.font.size), axis.text.x = element_text(size = input$GO_xlab.font.size), axis.title.x = element_text(size=input$GO_xtitle.font.size))}
          }, width=reactive(input$GO_fig.width), height=reactive(input$GO_fig.height))
          # GoBubblePlot
          output$GO_goBubblePlot <- renderPlot({
            if(is.null(goResult())){ ggplot() }
            else{ dotplot(goResult(), showCategory=input$GO_fig.category_show_number) + theme(axis.text.y = element_text(size = input$GO_ylab.font.size), axis.text.x = element_text(size = input$GO_xlab.font.size), axis.title.x = element_text(size=input$GO_xtitle.font.size)) }
          }, width=reactive(input$GO_fig.width), height=reactive(input$GO_fig.height))
          # Show the table
          output$GO_goTable <- DT::renderDataTable({
            if(is.null(goResult())){ datatable(NULL) }
            else{ datatable(as.data.frame(goResult()), option=list(scrollX=TRUE, pageLength = 10, scrollY=TRUE )) }
          })
          # table download button
          output$GO_goTable_download <- downloadHandler(
            filename = function(){"GO_table_results.csv"}, 
            content = function(fname){ write.csv(as.data.frame(goResult()), fname) }
          )
          # network plot
          output$GO_netPlot <- renderPlot({
            if(is.null(goResult())){ ggplot() }
            else{ cnetplot(goResult()) }
          }, width=reactive(input$GO_fig.width), height=reactive(input$GO_fig.height))

          outputOptions(output, "GO_goPlot", suspendWhenHidden=FALSE)
          outputOptions(output, "GO_goBubblePlot", suspendWhenHidden=FALSE) 
          outputOptions(output, "GO_goTable", suspendWhenHidden=FALSE) 
          outputOptions(output, "GO_netPlot", suspendWhenHidden=FALSE) 
        
        ###### GSEA analysis ######
          # select gene set
          GSEA_Gene_set <- reactive({
            if(input$GSEA_pathway_dataset_select == 'B'){ gsc <- gmtPathways('data/h.all.v2023.2.Hs.symbols.gmt') }
            else if(input$GSEA_pathway_dataset_select == 'C'){ gsc <- gmtPathways('data/mh.all.v2023.2.Mm.symbols.gmt') } 
            else if(input$GSEA_pathway_dataset_select == 'D'){ 
              tmp <- input$GSEA_upload_custom_pathway_file
              if (is.null(tmp)){ 
                output$GSEA_analysis_status <- renderText({'Please upload a gmt file.'})
                gsc <- NULL 
              }
              else { gsc <- gmtPathways(tmp$datapath)}
            }else if(input$GSEA_pathway_dataset_select == 'E'){
              if(length(input$GSEA_pathway_dataset_select_one_geneset_select) == 0){
                output$GSEA_analysis_status <- renderText({'Please select which pathway data to use.'})
                gsc <- NULL 
              }else if(input$GSEA_pathway_dataset_select_one_geneset_select == 'A'){
                genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set, ]$Genes, split=', ')[[1]]
                gsc <- list('Selected custom gene set' = genes)
              }else if(input$GSEA_pathway_dataset_select_one_geneset_select == 'B'){
                genes <- unlist(strsplit(input$GSEA_pathway_dataset_select_one_geneset_select_from_text, split = "\n"))
                gsc <- list('Inputted gene set' = genes) # genes <- c('CXCL10', 'CXCL9')
              }
            }
            gsc
          }) 

          # when chooseing from the custom gene set
          output$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set <- renderUI({
            gene_sets_names <- c()
            gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
            selectInput('GSEA_pathway_dataset_select_one_geneset_select_from_custom_set', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
          })

          # which score to use for the GSEA
          output$GSEA_select_score <- renderUI({ 
            # req(input$GSEA_pathway_dataset_select)
            if(length(Dataoverview_Data_type())!=0){
              if(Dataoverview_Data_type() == 'CRISPR screening' ){ selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df())), selected='logFC')  }
              else if(Dataoverview_Data_type() == 'CRISPR-a screening' ){ selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df())), selected='logFC')  }
              else if(Dataoverview_Data_type() == 'ORF screening' ){ selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df())), selected='log2LFC')  }
              else if(Dataoverview_Data_type() == 'RNAseq (DEG)' ){ selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df())), selected='Log2FoldChange')  }
              else{ selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df())))  }
              selectInput('GSEA_select_score', 'Use the score of:', c('None'='None', colnames(df()))) 
            }
          })
          outputOptions(output, "GSEA_select_score", suspendWhenHidden=FALSE)

          output$GSEA_status <- renderText({NULL})
          output$GSEA_plot_status <- renderText({NULL})
          output$GSEA_analysis_status <- renderText({NULL})
          outputOptions(output, "GSEA_status", suspendWhenHidden=FALSE)
          outputOptions(output, "GSEA_plot_status", suspendWhenHidden=FALSE) 
          outputOptions(output, "GSEA_analysis_status", suspendWhenHidden=FALSE) 

          # main part of GSEA calculation
          GSEA_results <- eventReactive(input$GSEA_start, {
            # when the ranking score is not selected
            if(input$GSEA_select_score=='None'){
              output$GSEA_analysis_status <- renderText({'Please choose the score for the analysis'})
              return(NULL)
            }
            # when the ranking score is not numeric
            ranked_genes <- df()[,input$GSEA_select_score]
            if(!is.numeric(ranked_genes)){
              output$GSEA_analysis_status <- renderText({'The selected score is not numeric, and cannot be used for the GSEA analysis. Please choose another.'})
              return(NULL)
            }
            output$GSEA_analysis_status <- renderText({NULL})
            names(ranked_genes) <- df()$id
            # output$GSEA_status <- renderText({ 'AAA' })
            if(is.null(GSEA_Gene_set())){
              return(NULL)
            }
            fgseaRes2 <- fgsea(pathways = GSEA_Gene_set(), stats = ranked_genes, minSize = 1, maxSize = 5000)
            if(dim(fgseaRes2)[1] == 0){
              output$GSEA_analysis_status <- renderText({
                tmp <- "No pathway was able to calculate the GSEA score to this dataset.\n"
                tmp <- paste0(tmp, "Potential cause:\n")
                tmp <- paste0(tmp, "- Using differnet species\n")
                tmp <- paste0(tmp, "- The gene names in the dataset are not gene symbol\n")
                tmp <- paste0(tmp, "- No overlap between the genes in the dataset and the genes in the pathwas\n")
                tmp <- paste0(tmp, "- The size of the gene set is too small\n")
                tmp
              }) 
              return(NULL)
            }
            fgseaRes2 <- data.frame(fgseaRes2[order(pval), ])
            # output$GSEA_plot_status_tmp <- renderText({dim(fgseaRes2)})
            fgseaRes2 <- fgseaRes2[c('pathway', 'pval', 'padj', 'log2err', 'ES', 'NES', 'size')]
            fgseaRes2$GSEA_select_score <- input$GSEA_select_score
            fgseaRes2
          })
          GSEA_Gene_set_after_start <- eventReactive(input$GSEA_start, {
            GSEA_Gene_set()
          })

          # outputOptions(output, "GSEA_results", suspendWhenHidden=FALSE)

          # dispaly the table
          output$GSEA_goTable <- DT::renderDataTable({
            if(is.null(GSEA_results())){ data.frame() }
            else{ 
              tmp <- as.data.frame(GSEA_results())
              datatable(tmp[, c('pathway', 'pval', 'padj', 'log2err', 'ES', 'NES', 'size')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }
          })
          outputOptions(output, "GSEA_goTable", suspendWhenHidden=FALSE)

          # download button
          output$GSEA_download <- downloadHandler(
            filename = function(){"GSEA_results.csv"}, 
            content = function(fname){ write.csv(as.data.frame(GSEA_results()), fname) }
          )

          # GSEA plot
          output$GSEA_plot <- renderPlot({
            if(is.null(GSEA_results())){
              output$GSEA_status <- renderText({NULL})
              NULL 
            }
            else{
              if(length(input$GSEA_goTable_rows_selected) == 0){
                output$GSEA_plot_status <- renderText({'Please select the pathway (row) from the GSEA results table'})
                output$GSEA_status <- renderText({NULL})
                return(NULL)
              }
              output$GSEA_plot_status <- renderText({NULL})
              GSEA_select_score <- GSEA_results()[,'GSEA_select_score'][1]
              ranked_genes <- df()[,GSEA_select_score]
              names(ranked_genes) <- df()$id
              selected_pathway <- GSEA_results()[input$GSEA_goTable_rows_selected,]$pathway
              p <- plotEnrichment(GSEA_Gene_set_after_start()[[selected_pathway]],ranked_genes) + labs(title=selected_pathway)
              p <- p + theme(axis.text=element_text(size=input$GSEA_lab.font.size), axis.title=element_text(size=input$GSEA_title.font.size))
              p <- p + theme(plot.title = element_text(size = input$GSEA_graph_title.font.size))
              output$GSEA_status <- renderText({ 
                paste0('P value: ', as.character(GSEA_results()[GSEA_results()$pathway==selected_pathway,]$pval), '\n', 
                  'adjusted-P value: ', as.character(GSEA_results()[GSEA_results()$pathway==selected_pathway,]$padj), '\n', 
                  'ES: ', as.character(GSEA_results()[GSEA_results()$pathway==selected_pathway,]$ES), '\n', 
                  'NES: ', as.character(GSEA_results()[GSEA_results()$pathway==selected_pathway,]$NES), '\n', 
                  'size: ', as.character(GSEA_results()[GSEA_results()$pathway==selected_pathway,]$size))
              })
              p
            }
          }, width=reactive(input$GSEA_fig.width), height=reactive(input$GSEA_fig.height))
          outputOptions(output, "GSEA_plot", suspendWhenHidden=FALSE)



        ###### TF activity inference (DecoupleR) ######
          output$DecoupeR_plot_status <- renderText({'Please note that this is only applicable to the RANseq DEG data processed by DESeq2.'})
          outputOptions(output, "DecoupeR_plot_status", suspendWhenHidden=FALSE)
          # Run decoupeR
          DecoupeR_TF_table_all <- eventReactive(input$DecoupeR_start, {
            df_LFC <- df()
            rownames(df_LFC) <- df_LFC$id
            if(!'stat' %in% colnames(df_LFC)){
              output$DecoupeR_plot_status <- renderText({'The input data is not the RANseq DEG data processed by DESeq2, and cannot applicable to this function.'})
              return(NULL)
            }
            output$DecoupeR_plot_status <- renderText({NULL})
            contrast_acts <- run_ulm(mat=df_LFC[, 'stat', drop=FALSE], net=net, .source='source', .target='target', .mor='mor', minsize = 5)
            
            return(contrast_acts)
          })

          # output table
          DecoupeR_TF_table <- reactive({
            f_contrast_acts <- DecoupeR_TF_table_all() %>% mutate(rnk = NA)
            msk <- f_contrast_acts$score > 0
            f_contrast_acts[msk, 'rnk'] <- rank(-f_contrast_acts[msk, 'score'])
            f_contrast_acts[!msk, 'rnk'] <- rank(-abs(f_contrast_acts[!msk, 'score']))
            tfs <- f_contrast_acts %>% arrange(rnk) %>% head(input$DecoupeR_TF_number) %>% pull(source)
            f_contrast_acts <- f_contrast_acts %>% filter(source %in% tfs)
            return(f_contrast_acts)
          })

          # table display
          output$DecoupeR_Table <- DT::renderDataTable({
            if(is.null(DecoupeR_TF_table_all())){ data.frame() }
            else{ datatable(as.data.frame(DecoupeR_TF_table_all()), options = list(scrollX = TRUE)) }
          })
          outputOptions(output, "DecoupeR_Table", suspendWhenHidden=FALSE)

          # download the table
          output$DecoupeR_Table_download <- downloadHandler(
          filename = function(){"decoupleR.tsv"}, 
          content = function(fname){ write.table(DecoupeR_TF_table_all(), fname, sep='\t', row.names=F, quote=F) }
          )

                                  # column(12, colourInput('DecoupeR_colour_high', 'High activity colour:', value='red')),
                                  # column(12, colourInput('DecoupeR_colour_low', 'Low activity colour:', value='red')),
                                  # column(12, colourInput('DecoupeR_colour_mid', 'Mid activity colour:', value='red'))

          # plot low = 
          output$DecoupeR_plot <- renderPlot({
            p <- ggplot(DecoupeR_TF_table(), aes(x = reorder(source, score), y = score)) + geom_bar(aes(fill = score), stat = "identity")
            p <- p + scale_fill_gradient2(low = input$DecoupeR_colour_low, high = input$DecoupeR_colour_high, mid = input$DecoupeR_colour_mid, midpoint = 0) + theme_minimal()
            p <- p + theme(axis.title = element_text(face = "bold", size = 12), axis.text.x = element_text(angle = 45, hjust = 1, size =10, face= "bold"),
                axis.text.y = element_text(size =10, face= "bold"), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + xlab("TFs")
            p <- p + theme(axis.text=element_text(size=input$DecoupeR_lab.font.size), axis.title=element_text(size=input$DecoupeR_title.font.size))
            p
          }, width=reactive(input$DecoupeR_fig.width), height=reactive(input$DecoupeR_fig.height))
          outputOptions(output, "DecoupeR_plot", suspendWhenHidden=FALSE)
          

        ###### heatmap for the count table ######
          # verbatimTextOutput('Data_Overview_heatmap_status'),
          # genes for the heatmap
          output$Data_Overview_heatmap_target_select_geneset <- renderUI({
            if(length(input$Data_Overview_heatmap_target_gene_type)==0){
              output$Data_Overview_heatmap_target_gene_type_status <- renderText({"Please select one from 'Gene from'"})
              return(NULL)
            }
            output$Data_Overview_heatmap_target_gene_type_status <- renderText({NULL})
            if(input$Data_Overview_heatmap_target_gene_type == 'B'){
              gene_sets_names <- c()
              gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
              selectInput('Data_Overview_heatmap_target_select_geneset', 'Select a geneset',  c('None'='None', gene_sets_names))  
            }else if (input$Data_Overview_heatmap_target_gene_type == 'C') {
              gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt')
              gene_sets_names <- c()
              for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
              selectInput('Data_Overview_heatmap_target_select_geneset', 'Select a geneset',  c('None'='None', gene_sets_names))  
            }else if (input$Data_Overview_heatmap_target_gene_type == 'D') {
              gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt')
              gene_sets_names <- c()
              for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
              selectInput('Data_Overview_heatmap_target_select_geneset', 'Select a geneset',  c('None'='None', gene_sets_names)) 
            }else if (input$Data_Overview_heatmap_target_gene_type == 'E'){
              tmp <- input$Data_Overview_heatmap_target_upload_custom_pathway
              if (is.null(tmp)){ 
                selectInput('Data_Overview_heatmap_target_select_geneset', 'Select a geneset',  c('None'='None'))
              }else{
                gsc <- getGmt(tmp$datapath)
                gene_sets_names <- c()
                for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
                selectInput('Data_Overview_heatmap_target_select_geneset', 'Select a geneset',  c('None'='None', gene_sets_names)) 
              }
            }
          })

          genes_for_heatmap <- reactive({
            if(length(input$Data_Overview_heatmap_target_gene_type)==0){
              output$Data_Overview_heatmap_target_gene_type_status <- renderText({"Please select one from 'Gene from'"})
              return(NULL)
            }
            output$Data_Overview_heatmap_target_gene_type_status <- renderText({NULL})
            if(input$Data_Overview_heatmap_target_gene_type == 'A'){
              unlist(strsplit(input$Data_Overview_heatmap_target_genes, split = "\n"))
            }else if(input$Data_Overview_heatmap_target_gene_type == 'B') {
              if(input$Data_Overview_heatmap_target_select_geneset != 'None'){
                unlist(strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Data_Overview_heatmap_target_select_geneset, ]$Genes, split=', '))
              }else{
                return(NULL)
              }
            }else if(input$Data_Overview_heatmap_target_gene_type == 'C'){
              if(input$Data_Overview_heatmap_target_select_geneset != 'None'){
                gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt')
                gsc[[input$Data_Overview_heatmap_target_select_geneset]]@geneIds
              }else{
                return(NULL)
              }            
            }else if(input$Data_Overview_heatmap_target_gene_type == 'D'){
              if(input$Data_Overview_heatmap_target_select_geneset != 'None'){
                gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt')
                gsc[[input$Data_Overview_heatmap_target_select_geneset]]@geneIds
              }else{
                return(NULL)
              }            
            }else if(input$Data_Overview_heatmap_target_gene_type == 'E'){
              if(input$Data_Overview_heatmap_target_select_geneset != 'None'){
                tmp <- input$Data_Overview_heatmap_target_upload_custom_pathway
                gsc <- getGmt(tmp$datapath)
                gsc[[input$Data_Overview_heatmap_target_select_geneset]]@geneIds
              }else{
                return(NULL)
              }  
            }
          })

          # samples to use
          Data_Overview_heatmap_sample_table_tmp <- reactive({
            samples <- colnames(df())[!(colnames(df())=='id')]
            data.frame(Sample_name=samples[order(samples)])
          })
          output$Data_Overview_heatmap_sample_table <- renderDataTable({
            datatable( Data_Overview_heatmap_sample_table_tmp(), selection='none', extensions=c('Select', 'Buttons'),
              options = list(
                select=list(style="multi", items='row'),
                scrollX = TRUE, scrollY=TRUE,
                dom='Blfrtip', rowId=0, buttons=c('selectAll', 'selectNone') )) 
          },server = FALSE)


          # function for standardise the table
          sd_table <- function(df_ex){
            for (key in colnames(df_ex)){
                tmp <- df_ex[,key] - mean(df_ex[,key])
                tmp <- tmp/sd(tmp)
                df_ex[,key] <- tmp
            }
            return(df_ex)
          }

          # heatmap table
          ex_datafreme_for_heatmap <- eventReactive(input$Gene_Overview_heatmap_start, {
            if(is.null(genes_for_heatmap)){
              output$Data_Overview_heatmap_status <- renderText('Please enter/choose genes.')
              return(NULL)
            }else{
              output$Data_Overview_heatmap_status <- NULL
              df_ex <- df()
              # extract the target genes
              if(length(df_ex$id[df_ex$id %in% genes_for_heatmap()]) == 0){
                # output$Data_Overview_heatmap_status <- renderText(paste(genes_for_heatmap(), 'None of the inputted genes are in the data.', sep='\n'))
                output$Data_Overview_heatmap_status <- renderText('None of the inputted genes are in the data.')
                return(NULL)
              }else{
                df_ex <- df_ex[df_ex$id %in% genes_for_heatmap(),] 
                rownames(df_ex) <- df_ex$id
                df_ex <- df_ex[,2:dim(df_ex)[2]] ## select which samples are included
                selected_samples <- Data_Overview_heatmap_sample_table_tmp()[input$Data_Overview_heatmap_sample_table_rows_selected,]
                if(length(selected_samples)==0){
                  output$Data_Overview_heatmap_status <- renderText("Please select the Sample_names.")
                  return(NULL)
                }else{
                  df_ex <- df_ex[,selected_samples]
                  df_ex <- data.frame(t(df_ex))
                  # standardise
                  df_ex <- sd_table(df_ex)
                  df_ex <- df_ex %>% select_if(~ !any(is.na(.)))
                  # clustering
                  set.seed(123)
                  if(input$Cluster_num > length(genes_for_heatmap())){
                    output$Data_Overview_heatmap_status <- renderText('The cluster number exceeds the number of genes. Please chosse a lower cluster number.')
                    return(NULL)
                  }else{
                    km <- kmeans(t(df_ex), centers = input$Cluster_num, nstart = 25)
                    clusters <- as.data.frame(km$cluster)
                    colnames(clusters) <- "Cluster"
                    # combine the cluster number and the expression table
                    gene_expression_matrix <- as.data.frame(t(df_ex))
                    gene_expression_matrix$Cluster <- clusters$Cluster
                    new_colnames <- c('Cluster', colnames(gene_expression_matrix)[1:dim(gene_expression_matrix)[2]-1])
                    gene_expression_matrix <- gene_expression_matrix[,new_colnames]
                    return(gene_expression_matrix)
                  }
                }
              }
            }
          })

          # heatmap plot
          output$Data_Overview_heatmap_plot <- renderPlot({
            if(!is.null(ex_datafreme_for_heatmap())){
              gene_expression_matrix <- ex_datafreme_for_heatmap()
              cols <- colnames(gene_expression_matrix)
              cols <- cols[2:length(cols)]
              cols <- cols[order(cols)]
              df_2 <- t(gene_expression_matrix[,cols]) # head(df_2)
              df5 <- data.frame(df_2)
              df5$sample <- rownames(df5) 
              df_target_order <- rownames(gene_expression_matrix[order(gene_expression_matrix$Cluster),])
              df5 <- pivot_longer(data = df5, cols = -c(sample), names_to = "Genes", values_to = "value") # head(df5)
              df5$Genes <- factor(x = df5$Genes, levels = df_target_order, ordered = TRUE)
              df5$sample <- factor(x = df5$sample, levels =  cols, ordered = TRUE)
              p <- ggplot(data = df5, aes(x = Genes, y = sample)) + geom_tile(aes(fill = value)) +
                  scale_fill_gradient2(low=input$Data_Overview_heatmap_col_low, high=input$Data_Overview_heatmap_col_high,mid=input$Data_Overview_heatmap_col_mid, midpoint=0) +
                  theme(axis.text.y = element_text(size = input$Data_Overview_heatmap_ylab.font.size), axis.text.x = element_text(size = input$Data_Overview_heatmap_xlab.font.size))
              p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
              p <- p + xlab('') + ylab('')
              if(input$Data_Overview_heatmap_white_background){
                  p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
              }
              p
            }else{
              return(NULL)
            }
          }, width=reactive(input$Data_Overview_heatmap_fig.width), height=reactive(input$Data_Overview_heatmap_fig.height))

          # display the standardised table
          output$Data_Overview_heatmap_expression <- DT::renderDataTable({
            if(is.null(ex_datafreme_for_heatmap())){ data.frame() }
            else{ datatable(as.data.frame(ex_datafreme_for_heatmap()), options = list(scrollX = TRUE)) }
          })

          # Download the standardised table
          output$Data_Overview_heatmap_expression_download <- downloadHandler(
            filename = function(){"Heatmap_expression_tablle.tsv"}, 
            content = function(fname){ write.table(ex_datafreme_for_heatmap(), fname, sep='\t', quote=F) }
          )

        ###### PCA plot ######
          output$Data_Overview_PCA_status <- renderText({"Please go to the Settings on the right and start analysis."})
          PCA_table <- eventReactive(input$Data_Overview_PCA_Start, {
            output$Data_Overview_PCA_status <- renderText({NULL})
            df_ex <- df()
            # df_ex <- read.table('/home/h023o/ShinyApps/in_house_screening/00_Expression_data_all/Helena/Human_T_cell_activation_Vora/all_cnt_FeatureCounts_cpm_gene.tsv', sep='\t', header=T)
            rownames(df_ex) <- df_ex$id
            df_ex <- df_ex[,2:dim(df_ex)[2]] # df_ex[1:3, 1:3]
            df_ex[is.na(df_ex)] <- 0
            if(input$Data_Overview_PCA_Setting=='B'){
              if(nchar(input$Data_Overview_PCA_Setting_group_define)==0){
                output$Data_Overview_PCA_status <- renderText({"Please enter the group descriptions."})
                return(NULL)
              }
              df_sample_group <- data.frame('Sample'=c(), 'Grounp'=c())
              for ( sample_group in unlist(strsplit(input$Data_Overview_PCA_Setting_group_define, split = "\n"))){
                # sample_group='Sample1_rep1,Group1'
                sample_tmp <- strsplit(sample_group, split=',')[[1]][1]
                group_tmp <- strsplit(sample_group, split=',')[[1]][2]
                df_sample_group_tmp <- data.frame('Sample'=c(sample_tmp), 'Grounp'=c(group_tmp))
                df_sample_group <- rbind(df_sample_group, df_sample_group_tmp)
              }
              if( anyDuplicated(df_sample_group$Sample)>0){
                output$Data_Overview_PCA_status <- renderText({"There are duplicated sample names."})
                return(NULL)
              }
              output$Data_Overview_PCA_plot_tmp <- renderDataTable({
                datatable(df_sample_group)
              })
              samples <- df_sample_group$Sample
              samples_intersect <- intersect(samples, colnames(df_ex)) # colnames(df_ex)[1:3, 1:3]
              if(length(samples_intersect)==0){
                output$Data_Overview_PCA_status <- renderText({"Non of the inputted sample names are in the dataset. \nPlease check the sample names are correct and do not contain unnecessary spaces."})
                return(NULL)
              }
              df_ex <- df_ex[,samples_intersect]
            }
            df2 <- df_ex[(rowSums(df_ex) > 5*dim(df_ex)[2]),] # dim(df2)
            df3 <- data.frame(t(df2)) # df3[1:3, 1:3]
            df3$sample <- rownames(df3)
            df3 <- df3[order(df3$sample),] 
            pca_res <- prcomp(df3[, colnames(df3) != 'sample'], scale. = TRUE) 
            pca_df <- data.frame(pca_res[5]$x[, 1:2]) # head(pca_df)
            pca_df$sample <- rownames(pca_df)
            if(input$Data_Overview_PCA_Setting=='B'){
              Group <- c()
              for (i in rownames(pca_df)){
                tmp <- df_sample_group[df_sample_group$Sample == i, ]$Grounp
                Group <- c(Group, tmp)
              }
              pca_df$Group <- Group
            }else{
              Group <- c()
              for (i in strsplit(rownames(pca_df), '_')){
                tmp <- ''
                for(j in 1:(length(i)-1)){
                  tmp <- paste0(tmp, i[j],'_')
                }
                tmp <- substr(tmp, 1, nchar(tmp)-1)
                Group <- c(Group, tmp)
              }
              pca_df$Group <- Group
            }
            pca_df
          })

          output$Data_Overview_PCA_plot <- renderPlot({
            pca_df <- PCA_table()
            if(is.null(pca_df)){
              return(NULL)
            }
            if(input$Data_Overview_PCA_change_colour_by_group){
              p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample, color=Group)) + geom_point(size=input$Data_Overview_PCA_point_size) 
              p <- p + theme(legend.text = element_text(size=input$Data_Overview_PCA_legend_size), legend.title=element_blank())
            }else{
              p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample)) + geom_point(size=input$Data_Overview_PCA_point_size) 
            }
            if(!input$Data_Overview_PCA_label_hide){
              p <- p + geom_text_repel(data = pca_df,  color = 'black', aes(label = sample), size = input$Data_Overview_PCA_label_size, max.overlaps = Inf)
            }
            p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
            p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
            if(input$Data_Overview_PCA_white_background){
                p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
            }
            p
          }, width=reactive(input$Data_Overview_PCA_fig.width), height = reactive(input$Data_Overview_PCA_fig.height))
        
          output$Data_Overview_PCA_Sample_list <- renderText({
            df_ex <- df()
            samples <- colnames(df_ex)[2:dim(df_ex)[2]]
            samples <- samples[order(samples)]
            paste(unlist(samples), collapse='\n')
          })
          # output$Data_Overview_PCA_Sample_list <- renderText({"hoge"})
          
      #####
    ####
  ####

  ### Compare across datasets ######################################################################

    #### data selection
      # choose data type
      output$choose_data_type <- renderUI({
        df_tmp <- Dataset()
        selectInput('choose_data_type', 'Data type', c('None'='None', unique(df_tmp[df_tmp$Data.Class == 'B',]$Data.type)))
      })

      output$Compare_dataset_selection_status <- renderText({
        if(length(input$choose_data_type)==0){
          "Please select the data type first."
        }else if(input$choose_data_type == 'None'){
          "Please select the data type first."
        }else{
          NULL
        }
      })

      # selectinon filtering
      # data from who
      output$Compare_dataset_filtering_Data_from <- renderUI({
        data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        tmp <- data_tmp$Data.from
        selectInput('Compare_dataset_filtering_Data_from', 'Data from', c('None'= 'None', tmp))
      })
      # data from which experiment
      output$Compare_dataset_filtering_Experiment <- renderUI({
        data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        if(length(input$Compare_dataset_filtering_Data_from)!= 0){
          if(input$Compare_dataset_filtering_Data_from != 'None'){ data_tmp <- data_tmp[data_tmp$Data.from == input$Compare_dataset_filtering_Data_from,] }
        }
        tmp <- data_tmp$Experiment
        selectInput('Compare_dataset_filtering_Experiment', 'Experiment', c('None'= 'None', tmp))
      })

      # list of the all datasets from which you select the dataset
      output$all_dataset <- DT::renderDataTable({ 
        data_table_tmp <- Dataset()[,c( "Dataset", "Data.type", "Experiment",  "Data.from", "When", "Description")] 
        data_table_tmp <- data_table_tmp[data_table_tmp$Data.type == input$choose_data_type, ] 
        if(length(input$Compare_dataset_filtering_Data_from)!=0){
          if(!is.null(input$Compare_dataset_filtering_Data_from) && input$Compare_dataset_filtering_Data_from!= 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] }
        }
        if(length(input$Compare_dataset_filtering_Experiment)!=0){
          if(!is.null(input$Compare_dataset_filtering_Experiment) && input$Compare_dataset_filtering_Experiment!= 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] }
        }
        datatable(data_table_tmp, 
          selection='none', extensions=c('Select', 'Buttons'), 
          options = list( select=list(style="multi", items='row'), 
            scrollX = TRUE, pageLength = 10, 
            dom='Blfrtip', rowId=0, buttons=c('selectAll', 'selectNone') ))
      },server = FALSE)


    #### Dataset comparison
      # chosse the score for comparison
      output$Choose_datasets_y <- renderUI({ 
        if(length(input$choose_data_type)!=0){
          if(input$choose_data_type != 'None'){
            data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T)
            y_names <- unique(colnames(data_ex_tmp))
            rm(data_ex_tmp)
            selectInput('Choose_datasets_y', 'Y axis', c('None'= 'None', y_names))
          }else{
            selectInput('Choose_datasets_y', 'Y axis', c('None'= 'None'))
          }
        }else{
          selectInput('Choose_datasets_y', 'Y axis', c('None'= 'None'))
        }
      })
      output$Choose_datasets_colour <- renderUI({ 
        if(length(input$choose_data_type)!=0){
          if(input$choose_data_type != 'None'){
            data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T)
            col_names <- unique(colnames(data_ex_tmp))
            rm(data_ex_tmp)
            selectInput('Choose_datasets_colour', 'Colour', c('None'= 'None', col_names))
          }else{
            selectInput('Choose_datasets_colour', 'Colour', c('None'= 'None'))
          }
        }else{
          selectInput('Choose_datasets_colour', 'Colour', c('None'= 'None'))
        }
      })

      # Start comparing the score
      df_compare_prepare <- eventReactive(input$comparison_start,{
        data_table_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        if(!is.null(input$Compare_dataset_filtering_Data_from) && input$Compare_dataset_filtering_Data_from != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] }
        if(!is.null(input$Compare_dataset_filtering_Experiment) && input$Compare_dataset_filtering_Experiment != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] }
        # when datasets are not selected
        if(length(input$all_dataset_rows_selected) == 0){
          output$Gene_comparing_status <- renderText({"Please select the datasets first."})
          return(NULL)
        }
        datasets_for_compare <- data_table_tmp[input$all_dataset_rows_selected,]$Dataset
        # when no genes are specified
        if(nchar(input$target_gene_for_comparing) == 0){
          output$Gene_comparing_status <- renderText({"Please enter the gene names."})
          return(NULL)
        }
        Genes_to_be_shown_list <- unlist(strsplit(input$target_gene_for_comparing, split = "\n"))
        # when Y is not selected
        if(input$Choose_datasets_y == 'None'){
          output$Gene_comparing_status <- renderText({"Please select the Y-axis."})
          return(NULL)
        }
        output$Gene_comparing_status <- renderText({NULL})
        Y_axis <- input$Choose_datasets_y
        undetected_genes <- c()
        # start extract the scores for each gene
        if(input$Choose_datasets_colour == 'None'){
          df_Y_tmp <- data.frame(id = Genes_to_be_shown_list) 
          for (dataset in datasets_for_compare){
            df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T)
            if(colnames(df_tmp_tmp)[1] == 'X'){colnames(df_tmp_tmp)[1]='id'}
            df_tmp_tmp_Y <- df_tmp_tmp[df_tmp_tmp$id %in% Genes_to_be_shown_list, c('id', Y_axis)]
            colnames(df_tmp_tmp_Y)[2] <- dataset 
            df_Y_tmp <- merge(df_Y_tmp, df_tmp_tmp_Y, by='id', all.x=TRUE)
            rm(df_tmp_tmp)
          }
          df_Y_tmp$type <- 'Y'
          return(df_Y_tmp)
        }else{
          df_Y_tmp <- data.frame(id = Genes_to_be_shown_list) 
          df_col_tmp <- data.frame(id = Genes_to_be_shown_list)
          col <- input$Choose_datasets_colour
          for (dataset in datasets_for_compare){
            df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T)
            if(colnames(df_tmp_tmp)[1] == 'X'){colnames(df_tmp_tmp)[1]='id'}
            df_tmp_tmp_Y <- df_tmp_tmp[df_tmp_tmp$id %in% Genes_to_be_shown_list, c('id', Y_axis)]
            df_tmp_tmp_col <- df_tmp_tmp[df_tmp_tmp$id %in% Genes_to_be_shown_list, c('id', col)]
            colnames(df_tmp_tmp_Y)[2] <- dataset 
            colnames(df_tmp_tmp_col)[2] <- dataset 
            df_Y_tmp <- merge(df_Y_tmp, df_tmp_tmp_Y, by='id', all.x=TRUE)
            df_col_tmp <- merge(df_col_tmp, df_tmp_tmp_col, by='id', all.x=TRUE)
            rm(df_tmp_tmp)
          }
          df_Y_tmp$type <- 'Y'
          df_col_tmp$type <- 'col'
          # df_Y_col_tmp <- merge(df_Y_tmp, df_col_tmp, by='id')
          df_Y_col_tmp <- rbind(df_Y_tmp, df_col_tmp)
          return(df_Y_col_tmp)
        }        
      })

      # select a gene from a table
      output$Gene_comparing_gene_list_table <- DT::renderDataTable({
        if(is.null(df_compare_prepare())){
          return(NULL)
        }else{
          tmp <- data.frame('Input'=unique(df_compare_prepare()$id))
          datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE))
        }
      })

      # table for the plop
      df_compare <- reactive({
        if(is.null(df_compare_prepare())){
          return(NULL)
        }
        tmp <- data.frame('Input'=unique(df_compare_prepare()$id))
        if(length(input$Gene_comparing_gene_list_table_rows_selected) == 0){
          output$Gene_comparing_plot_status <- renderText({"Please select a gene (row) from the table"})
          return(NULL)
        }
        gene <- tmp[input$Gene_comparing_gene_list_table_rows_selected,]
        output$Gene_comparing_plot_status <- renderText({NULL})
        df_compare_tmp <- df_compare_prepare()[df_compare_prepare()$id==gene,2:dim(df_compare_prepare())[2]] # 
        # df_compare_tmp <- df_Y_tmp[df_Y_tmp$id == 'CXCL10', 2:dim(df_Y_tmp)[2]]
        df_compare_tmp_Y <- data.frame(t(df_compare_tmp[df_compare_tmp$type == 'Y',]))
        colnames(df_compare_tmp_Y) <- c(input$Choose_datasets_y)  # colnames(df_compare_tmp_Y) <- c(Y_axis)
        df_compare_tmp_Y$dataset <- rownames(df_compare_tmp_Y)
        if('col' %in% df_compare_tmp$type){
          df_compare_tmp_col <- data.frame(t(df_compare_tmp[df_compare_tmp$type == 'col',]))
          colnames(df_compare_tmp_col) <- c('Colour')
          df_compare_tmp_col$dataset <- rownames(df_compare_tmp_col)
          df_compare <- merge(df_compare_tmp_Y, df_compare_tmp_col, by='dataset')
          df_compare[,'Colour'] <- as.numeric(df_compare[,'Colour'])
        }else{
          df_compare <- df_compare_tmp_Y
        }
        df_compare <- df_compare[df_compare$dataset != 'type',]
        df_compare[,input$Choose_datasets_y] <- as.numeric(df_compare[,input$Choose_datasets_y])
        df_compare <- df_compare[order(df_compare[,input$Choose_datasets_y], decreasing = T), ]
        # df_compare$dataset <- factor(df_compare$dataset, levels=df_compare$dataset)
        return(df_compare)

      })

      # display the result table
      output$dataframe_comparing_dataset <- renderDataTable({
        if(is.null(df_compare()) || dim(df_compare())[1] != 0){
          datatable( data.frame(df_compare()), options = list(scrollX = TRUE, pageLength = 5 ))
        }else{
          datatable( data.frame(), options = list(scrollX = TRUE, pageLength = 5 ))
        }
      })

      # download the table
      output$comparing_dataset_download <- downloadHandler(
        filename = function(){"comparing_score_across_dataset.tsv"}, 
        content = function(fname){ write.table(df_compare(), fname, sep='\t', quote=F) }
      )

      # main plot for comparison
      output$Gene_comparing_plot <- renderPlot({
        if(is.null(df_compare())){
          return(NULL)
        }
        df_compare <- df_compare()
        df_compare <- na.omit(df_compare)
        if(dim(df_compare)[1]==0){
          output$Gene_comparing_plot_status <- renderText({"Non of the dataests included the inputted gene. Pleas make sure the gene name is correct and does not contain unnecessary spaces."})
          return(NULL)
        }
        output$Gene_comparing_plot_status <- renderText({NULL})
        df_compare <- df_compare[order(df_compare[,input$Choose_datasets_y], decreasing = T),]
        df_compare$dataset <- factor(df_compare$dataset, levels=df_compare$dataset)
        if(is.null(df_compare()) || dim(df_compare)[1] == 0) { return(ggplot()) }
        # # if the colour option is set, change the colour of the plot
        # if(is.null(input$Choose_datasets_y) || input$Choose_datasets_y == 'None') { return(ggplot()) }
        else if(!is.na(colnames(df_compare)[3])){ p <- ggplot(df_compare, aes_string(x = 'dataset', y = input$Choose_datasets_y, fill='Colour', color = 'Colour')) }
        else if(!is.na(colnames(df_compare)[2])){ p <- ggplot(df_compare, aes_string(x = 'dataset', y = input$Choose_datasets_y)) }
        # either a scatter plot or a bar plot
        if(input$bar_or_scatter == "Scatter plot"){ p <- p + geom_point(size = input$Compare_pt.size) }
        else if (input$bar_or_scatter == "Bar plot") { p <- p + geom_bar(stat = "identity") }
        # change the color scale ( only when colour option is selected )
        if(!is.na(colnames(df_compare)[3])){
          values_for_colours <- df_compare$Colour[!is.na(df_compare$Colour)]
          if( min(values_for_colours)<0 ){
            if( max(values_for_colours)>=0 ){
              tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
              p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Choose_datasets_colour)
              p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Choose_datasets_colour)
            }else{
              p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(df_compare$Colour), 0)  , limits = c(c(min(df_compare$Colour), 0)) ), name=input$Choose_datasets_colour)
              p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(df_compare$Colour), 0)  , limits = c(c(min(df_compare$Colour), 0)) ), name=input$Choose_datasets_colour)
            }
          }else{
            p <- p + scale_color_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(df_compare$Colour)))  , limits = c(0,max(df_compare$Colour)) , name=input$Choose_datasets_colour)
            p <- p + scale_fill_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(df_compare$Colour)))  , limits = c(0,max(df_compare$Colour)) , name=input$Choose_datasets_colour)
          }
        }
        p <- p + geom_hline(yintercept=0, linetype='dotted')
        p <- p + ggtitle(colnames(df_compare)[1])
        p <- p + labs(x= 'Datasets',  y = input$Choose_datasets_y)
        p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_graph.title.font.size))
        p <- p + theme(axis.text.y = element_text(size = input$Compare_label.font.size), axis.text.x = element_text(size = input$Compare_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_title.font.size), axis.title.x = element_text(size = input$Compare_title.font.size))
        tmp <- data.frame('Input'=unique(df_compare_prepare()$id))
        gene <- tmp[input$Gene_comparing_gene_list_table_rows_selected,]
        p <- p + ggtitle(gene)
        if(input$Compare_white_background){
            p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
        }
        p
      }, width=reactive(input$Compare_fig.width), height=reactive(input$Compare_fig.height))

    #### investigate the overlap
      # chosse the score for comparison
      output$Compare_dataset_get_overview_select_score <- renderUI({ 
        if(!is.null(input$choose_data_type)){
          if(input$choose_data_type != 'None'){
            data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T)
            y_names <- unique(colnames(data_ex_tmp))
            rm(data_ex_tmp)
            if(input$choose_data_type  == 'CRISPR screening'){ selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None', y_names) , selected='logFC') }
            else if(input$choose_data_type  == 'CRISPR screening (gRNA LFC)'){ selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None', y_names) , selected='LFC') }
            else if(input$choose_data_type  == 'CRISPR screening (gRNA LFC, norm by NTgRNA)'){ selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None', y_names) , selected='LFC') }
            else {selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None', y_names))}
          }else{
            selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None'))
          }
        }else{
          selectInput('Compare_dataset_get_overview_select_score', 'Select a score for ranking', c('None'= 'None'))
        }
      })

      # check the overlap
      df_compare_overlapped_hit <- eventReactive(input$Compare_dataset_get_overview_start, {
        # datasets slection
        data_table_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        if(!is.null(input$Compare_dataset_filtering_Data_from) && input$Compare_dataset_filtering_Data_from != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] }
        if(!is.null(input$Compare_dataset_filtering_Experiment) && input$Compare_dataset_filtering_Experiment != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] }
        datasets_for_compare <- data_table_tmp[input$all_dataset_rows_selected,]$Dataset
        if(length(datasets_for_compare)==0){
          output$Compare_dataset_get_overview_status <- renderText({"Please select the datasets"})
          return(NULL)
        }
        # if a score for ranking is not set
        else if(input$Compare_dataset_get_overview_select_score == 'None' || is.null(input$Compare_dataset_get_overview_select_score)){
          output$Compare_dataset_get_overview_status <- renderText({"Please select the score for ranking"})
          return(NULL)
        }else{
          output$Compare_dataset_get_overview_status <- renderText({NULL})
          sorted_score <- input$Compare_dataset_get_overview_select_score
          df_tmp <- data.frame()    
          i=0
          for (dataset in datasets_for_compare){
            df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T)
            if(colnames(df_tmp_tmp)[1] == 'X'){colnames(df_tmp_tmp)[1]='id'}
            df_tmp_tmp_sorted <- df_tmp_tmp[,c('id', sorted_score)][order(df_tmp_tmp[,sorted_score], decreasing = T),] # head(df_tmp_tmp_sorted)
            # get the threshold score
            # and if the score does not meet the threshold, the score will be replaced by NA
            if(input$Compare_dataset_get_overview_direction == 'Top X%'){
              if(length(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]>0])==0){
                df_tmp_tmp_sorted[,sorted_score] <- NA  
              }else{
                thr <- quantile(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]>0], 1-(input$Compare_dataset_get_overview_threshold/100))
                df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score] < thr] <- NA
              }
            }else{
              if(length(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]<0])==0){
                df_tmp_tmp_sorted[,sorted_score] <- NA  
              }else{
                thr <- quantile(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]<0], input$Compare_dataset_get_overview_threshold/100 )
                df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score] > thr] <- NA
              }
            }
            # merge into one dataframe
            colnames(df_tmp_tmp_sorted) <- c('id', paste(sorted_score, dataset, sep='.'))
            if(i==0){
              df_tmp <- df_tmp_tmp_sorted
            }else{
              df_tmp <- merge(df_tmp, df_tmp_tmp_sorted, by='id')
            }
            rm(df_tmp_tmp)
            i = i+1
          }
          # count how many times it appeared accorss the selected datasets
          df_tmp$Overlap_times <- dim(df_tmp)[2] - 1 - rowSums(is.na(df_tmp))        
          df_tmp <- df_tmp[order(df_tmp$Overlap_times, decreasing = T),]
          cols <- colnames(df_tmp)
          df_tmp <- df_tmp[, c('id', 'Overlap_times', cols[3:length(cols)-1])]
          thr <- input$Compare_dataset_get_overview_threshold_for_display
          df_tmp <- df_tmp[df_tmp$Overlap_times >= thr,]
          df_tmp # head(df_tmp)
        }

      })

      # display the table
      output$Compare_dataset_get_overview_overlap <- DT::renderDataTable({
        if(!is.null(df_compare_overlapped_hit())){
          tmp <- df_compare_overlapped_hit()
          rownames(tmp) <- NULL
        }else{
          tmp <- data.frame()
        }
        datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
      })

      # download the table
      output$Compare_dataset_get_overview_download <- downloadHandler(
        filename = function(){"Overlap_hit.tsv"}, 
        content = function(fname){ write.table(df_compare_overlapped_hit(), fname, sep='\t', quote=F, row.names=F) }
      )

      # list up the gene names
      output$Compare_dataset_get_overview_list <- renderText({
        paste(na.omit(df_compare_overlapped_hit()$id), collapse = "\n")
      })

      # show the bar plot
      output$Compare_dataset_get_overview_barplot <- renderPlot({
        if(!is.null(df_compare_overlapped_hit())){
          if(length(input$Compare_dataset_get_overview_overlap_rows_selected)>0){
            output$Compare_dataset_get_overview_barplot_status <- NULL
            data_to_show <- df_compare_overlapped_hit()[input$Compare_dataset_get_overview_overlap_rows_selected,]
            gene <- data_to_show$id
            df_plot <- na.omit(data.frame(t(data_to_show[,3:dim(data_to_show)[2]])))
            colnames(df_plot) <- c('Score')
            df_plot$sample <- rownames(df_plot)
            df_plot <- df_plot[order(df_plot$Score, decreasing = T),]
            df_plot$sample <- factor(df_plot$sample, levels=df_plot$sample)
            p <- ggplot(df_plot, aes_string(x= "sample", y="Score", fill="Score")) + geom_bar(stat='identity')
            values_for_colours <- df_plot[,'Score']     
                        # column(4, colourInput('Compare_dataset_get_overview_highest_colour', 'Colour for the highest value', value='red')),
                        # column(4, colourInput('Compare_dataset_get_overview_lowest_colour', 'Colour for the lowest value', value='blue')),
                        # column(4, colourInput('Compare_dataset_get_overview_zero_colour', 'Colour for zero', value='white'))           
            if( min(values_for_colours)<0 ){
              if( max(values_for_colours)>=0 ){
                tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Compare_dataset_get_overview_select_score)
                p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Compare_dataset_get_overview_select_score)
              }else{
                p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=input$Compare_dataset_get_overview_select_score)
                p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=input$Compare_dataset_get_overview_select_score)
              }
            }else{
              p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Compare_dataset_get_overview_select_score)
              p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Compare_dataset_get_overview_select_score)
            }
            p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_dataset_get_overview_graph.title.font.size))
            p <- p + theme(axis.text.y = element_text(size = input$Compare_dataset_get_overview_label.font.size), axis.text.x = element_text(size = input$Compare_dataset_get_overview_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_dataset_get_overview_title.font.size), axis.title.x = element_text(size = input$Compare_dataset_get_overview_title.font.size))
            if(input$Compare_dataset_get_overview_white_background){
                p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
            }
            p
          }else{
            output$Compare_dataset_get_overview_barplot_status <- renderText({'Please select a row from the table'})
            return(NULL)
          }
        }
      }, width=reactive(input$Compare_dataset_get_overview_fig.width), height=reactive(input$Compare_dataset_get_overview_fig.height))

        # p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_graph.title.font.size))
        # p


                      # fluidRow(
                      #   column(4, sliderInput('Compare_dataset_get_overview_label.font.size', 'X/Y label font size', min=1, max=40, value=15)),
                      #   column(4, sliderInput('Compare_dataset_get_overview_title.font.size', 'X/Y title font size', min=1, max=40, value=15)),
                      #   column(4, sliderInput('Compare_dataset_get_overview_graph.title.font.size', 'Graph title font size', min=1, max=40, value=15))
                      # )
    ###
  ###

  ### Integrate two datasets #######################################################################

    #### functions for dataset selection 
      # data from who
      Seuqenced_by_select_button_creation <- function(df_tmp,Name){
        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
        selectInput(Name, 'Data from', c('None'= 'None', unique(df_tmp$Data.from)))
      }

      # data from which experiment
      Experiments_select_button_creation <- function(df_tmp,Name,Seuqenced_by ){
        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
        if(length(Seuqenced_by) != 0 ){
          if(Seuqenced_by!='None') { df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by, ]}
        }
        selectInput(Name, 'Experiment', c('None'= 'None', unique(df_tmp$Experiment)))
      }

      # data type
      Data_type_select_button_creation <- function(df_tmp,Name,Seuqenced_by, Experiments ){
        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
        if(length(Seuqenced_by)!=0){
          if(Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by,]} 
        }
        if(length(Experiments)!=0){
          if(Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == Experiments,]}
        }
        selectInput(Name, 'Data type', c('None'= 'None', unique(df_tmp$Data.type)))
      }

      # dataset selection
      dataset_select_button_creation <- function(df_tmp, Name, Seuqenced_by, Experiments, Data_type ){ 
        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
        if(length(Seuqenced_by)!= 0){
          if(Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by,]}
        }
        if(length(Experiments)!=0){
          if(Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == Experiments,]}
        }
        if(length(Data_type)!=0){
          if(Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == Data_type,]}
        }
        selectInput(Name, 'Dataset select', c('None'='None', unique(df_tmp$Dataset))) 
      }

    #### Dataset selection 
      # dataset1
      output$Integrate_data1_Seuqenced_by <- renderUI({ Seuqenced_by_select_button_creation(Dataset(), 'Integrate_data1_Seuqenced_by') })
      output$Integrate_data1_Experiments <- renderUI({ Experiments_select_button_creation(Dataset(), 'Integrate_data1_Experiments', input$Integrate_data1_Seuqenced_by) })
      output$Integrate_data1_Data_type <- renderUI({ Data_type_select_button_creation(Dataset(), 'Integrate_data1_Data_type', input$Integrate_data1_Seuqenced_by, input$Integrate_data1_Experiments) })
      output$Integrate_data1_select <- renderUI({ dataset_select_button_creation(Dataset(), 'Integrate_data1_select', input$Integrate_data1_Seuqenced_by, input$Integrate_data1_Experiments, input$Integrate_data1_Data_type) })

      # dataset2
      output$Integrate_data2_Seuqenced_by <- renderUI({ Seuqenced_by_select_button_creation(Dataset(), 'Integrate_data2_Seuqenced_by') })
      output$Integrate_data2_Experiments <- renderUI({ Experiments_select_button_creation(Dataset(), 'Integrate_data2_Experiments', input$Integrate_data2_Seuqenced_by) })
      output$Integrate_data2_Data_type <- renderUI({ Data_type_select_button_creation(Dataset(), 'Integrate_data2_Data_type', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments) })
      output$Integrate_data2_select <- renderUI({ dataset_select_button_creation(Dataset(), 'Integrate_data2_select', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments, input$Integrate_data2_Data_type) })


    #### dataset load
      data_load <- function(selected_data){
        if(!is.null(selected_data) && selected_data!= 'None'){
          path <- Dataset()[Dataset()$Dataset == selected_data, ]$Path
          df_tmp <- read.table(path, sep='\t', header=T)
          if(colnames(df_tmp)[1] == 'X'){ colnames(df_tmp)[1] <- 'id'}
          if("X.log10.pvalue." %in% colnames(df_tmp)){ df_tmp$X.log10.pvalue. <- replace_inf_with_largest_values(df_tmp$X.log10.pvalue.) }
          if("X.log10.padj." %in% colnames(df_tmp)){ df_tmp$X.log10.padj. <- replace_inf_with_largest_values(df_tmp$X.log10.padj.) }
          df_tmp
        }else{
          return(NULL)
        }    
      }
      df_data1 <- reactive({ data_load(input$Integrate_data1_select) })
      df_data2 <- reactive({ data_load(input$Integrate_data2_select) })

    #### Data visualisation
      ##### Decide x and y
        Select_x <- function(df_tmp, object_name){
          if(!is.null(df_tmp)){ X_axis_name <- colnames(df_tmp) }
          else{ X_axis_name <- c() }
          selectInput(object_name, 'x', c('None'='None', X_axis_name))
        }
        Select_y <- function(df_tmp, object_name){
          if(!is.null(df_tmp)){ Y_axis_name <- colnames(df_tmp) }
          else{ Y_axis_name <- c() }
          selectInput(object_name, 'y', c('None'='None', Y_axis_name))
        }
        output$Integrate_data1_Scat.X <- renderUI({ Select_x(df_data1(), 'Integrate_data1_Scat.X') })
        output$Integrate_data2_Scat.X <- renderUI({ Select_x(df_data2(), 'Integrate_data2_Scat.X') })
        output$Integrate_data1_Scat.Y <- renderUI({ Select_y(df_data1(), 'Integrate_data1_Scat.Y') })
        output$Integrate_data2_Scat.Y <- renderUI({ Select_y(df_data2(), 'Integrate_data2_Scat.Y') })

      ##### get outliers (filtered genes)
        get_outliers <- function(df_main_plot, Direction, selected_x, selected_y, x_threshold, y_threshold, method, brush_point){
          if(is.null(df_main_plot)){
            return(NULL)
          }
          if(selected_x=='None' | selected_y=='None'){
            return(NULL)
          }
          if(method=='A'){
            switch(Direction,
              "both positive/negative genes" = df_main_plot[((df_main_plot[selected_x] > x_threshold | df_main_plot[selected_x] < -x_threshold) & df_main_plot[selected_y] > y_threshold), ],
              "only positive genes" = df_main_plot[(df_main_plot[selected_x] > x_threshold & df_main_plot[selected_y] > y_threshold), ],
              "only negative genes" = df_main_plot[(df_main_plot[selected_x] < -x_threshold & df_main_plot[selected_y] > y_threshold), ])
          }else{
            brushedPoints(df_main_plot, brush_point)
          }
        }
        data1_outliers <- reactive({ get_outliers(df_data1(), input$Integrate_data1_Direction, input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, input$Integrate_data1_x_threshold, input$Integrate_data1_y_threshold, input$Integrate_data1_Gene_selection, input$Integrate_data1_plot_brush) })
        data2_outliers <- reactive({ get_outliers(df_data2(), input$Integrate_data2_Direction, input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, input$Integrate_data2_x_threshold, input$Integrate_data2_y_threshold, input$Integrate_data2_Gene_selection, input$Integrate_data2_plot_brush) })

        output$Integrate_data1_selected_gene_num <- renderText({
          tryCatch(paste0('Slected gene numbers: ', length(data1_outliers()$id)),
            error = function(e){
              return(NULL)
            })
        })
        output$Integrate_data2_selected_gene_num <- renderText({
          tryCatch(paste0('Slected gene numbers: ', length(data2_outliers()$id)),
            error = function(e){
              return(NULL)
            })
        })

      ##### plot
        # function for the scatter plot
        plot_scatter_plot <- function(df_main_plot, Selected_x, Selected_y, outliers, mapped_thr_X, mapped_thr_Y,  direction, thr_show ){
          if((Selected_x == 'None') ||(Selected_y == 'None')){ return(NULL) }
          else{ 
            p <- ggplot(df_main_plot, aes_string(x = Selected_x, y = Selected_y)) + geom_point(size = 1) 
            if(!is.null(outliers)){
              if(!'id' %in% rownames(outliers)){
                p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% outliers$id,], color='#ee00fa' , size = input$high.pt.size)
                p <- p + geom_text_repel(data =  df_main_plot[df_main_plot$id %in% outliers$id,],  color = "#ee00fa", aes(label = id), size = input$high.label.size)
              }
            }
            if(thr_show == 1){
              if(input$Integrate_data_mapped_show_threshold){
                if(direction == 'both positive/negative genes' || direction == 'only positive genes'){p <- p + geom_vline(xintercept=mapped_thr_X, linetype='dotted')}
                if(direction == 'both positive/negative genes' || direction == 'only negative genes'){p <- p + geom_vline(xintercept=-mapped_thr_X, linetype='dotted')}
                p <- p + geom_hline(yintercept=mapped_thr_Y, linetype='dotted')
              }            
            }
          }
          p
        }    

        # plot1
        output$Integrate_data1_plot <- renderPlot({
          if(length(input$Integrate_data1_Scat.X) ==0 | length(input$Integrate_data1_Scat.Y)==0 ){
            return(NULL)
          }
          if(input$Integrate_data1_Scat.X == 'None' | input$Integrate_data1_Scat.Y == 'None'){
            output$Integrate_data1_plot_status <- renderText({"Please select the X and Y."})
            return(NULL)
          }else{
            output$Integrate_data1_plot_status <- renderText({NULL})
            if(input$Integrate_data_map_direction == 'A'){ 
              plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_Direction, 0) 
            }else { 
              if(input$Integrate_data2_Scat.X == 'None' | input$Integrate_data2_Scat.Y == 'None'){
                plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data2_Direction,1) 
              }else{
                plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data2_Direction,1)  
              }
              
            }
          }
        }, width=reactive(input$Integrate_data1_fig.width), height=reactive(input$Integrate_data1_fig.height))

        # plot2
        output$Integrate_data2_plot <- renderPlot({
          if(length(input$Integrate_data2_Scat.X) == 0 |  length(input$Integrate_data2_Scat.Y)== 0){
            return(NULL)
          }
          if(input$Integrate_data2_Scat.X == 'None' |  input$Integrate_data2_Scat.Y== 'None'){
            output$Integrate_data2_plot_status <- renderText({"Please select the X and Y."})
          }else{
            output$Integrate_data2_plot_status <- renderText({NULL})
            if(input$Integrate_data_map_direction == 'A'){ 
              if(input$Integrate_data1_Scat.X == 'None' | input$Integrate_data1_Scat.Y == 'None'){
                plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_Direction, 1) 
              }else{
                plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_Direction, 1) 
              }
            }   
            else { plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_Direction, 0) }
          }
        }, width=reactive(input$Integrate_data2_fig.width), height=reactive(input$Integrate_data2_fig.height))

        # plot1 + plot2 table
        data1_plus_data2 <- reactive({
          if(!is.null(df_data1()) && !is.null(df_data2())){
            df1 <- df_data1()
            df2 <- df_data2()
            colnames(df1) <- paste0('Data1_', colnames(df1))
            colnames(df2) <- paste0('Data2_', colnames(df2))
            colnames(df1) <- gsub('Data1_id', 'id', colnames(df1))
            colnames(df2) <- gsub('Data2_id', 'id', colnames(df2))
            df_tmp <- merge(df1, df2, by='id')
            return(df_tmp)
          }else{
            return(NULL)
          }
        })

        # show the overlapped gene table
        Integrate_Overlapped_gene_table_tmp <- reactive({
          tryCatch({
            # genes from the mapping side
            if(input$Integrate_data_map_direction == 'A'){
              gene_from_mapping_side <- data1_outliers()$id
            }else{
              gene_from_mapping_side <- data2_outliers()$id
            }
            # which genes pass the filtering in the mapped side
            if(input$Integrate_data_map_direction == 'A'){
              df_tmp <- df_data2()[df_data2()$id %in% gene_from_mapping_side,]
              df_tmp <- switch(input$Integrate_data1_Direction,
                "both positive/negative genes" = df_tmp[((df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_x_threshold | df_tmp[input$Integrate_data2_Scat.X] < -input$Integrate_data_mapped_x_threshold) & df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_y_threshold), ],
                "only positive genes" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_x_threshold & df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_y_threshold), ],
                "only negative genes" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] < -input$Integrate_data_mapped_x_threshold & df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_y_threshold), ])
              overlapped_gene <- df_tmp$id
            }else{
              df_tmp <- df_data1()[df_data1()$id %in% gene_from_mapping_side,]
              df_tmp <- switch(input$Integrate_data2_Direction,
                "both positive/negative genes" = df_tmp[((df_tmp[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_x_threshold | df_tmp[input$Integrate_data1_Scat.X] < -input$Integrate_data_mapped_x_threshold) & df_tmp[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_y_threshold), ],
                "only positive genes" = df_tmp[(df_tmp[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_x_threshold & df_tmp[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_y_threshold), ],
                "only negative genes" = df_tmp[(df_tmp[input$Integrate_data1_Scat.X] < -input$Integrate_data_mapped_x_threshold & df_tmp[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_y_threshold), ])
              overlapped_gene <- df_tmp$id
            }
            df_overlapped_gene_tmp <- data1_plus_data2()[data1_plus_data2()$id %in% overlapped_gene,]
            columns <- c('id', paste0('Data1_', input$Integrate_data1_Scat.X), paste0('Data1_', input$Integrate_data1_Scat.Y), paste0('Data2_', input$Integrate_data2_Scat.X), paste0('Data2_', input$Integrate_data2_Scat.Y))
            df_overlapped_gene_tmp <- df_overlapped_gene_tmp[, columns]
            # output$Integrate_Overlapped_gene_table_status <- renderText({NULL})
            # datatable( data.frame(df_overlapped_gene_tmp),  options = list(scrollX = TRUE, pageLength = 10))  
            return(df_overlapped_gene_tmp)
          },
          error=function(e){
            # output$Integrate_Overlapped_gene_table_status <- renderText({'Please set up Data1 and Data2'})
            return(NULL)
          })
        })

        # display the table
        output$Integrate_Overlapped_gene_table <- renderDataTable({
          if(!is.null(Integrate_Overlapped_gene_table_tmp())){
            output$Integrate_Overlapped_gene_table_status <- renderText({NULL})
            datatable( data.frame(Integrate_Overlapped_gene_table_tmp()),  options = list(scrollX = TRUE, pageLength = 10))  
          }else{
            output$Integrate_Overlapped_gene_table_status <- renderText({'Please set up Data1 and Data2'})
            return(NULL)
          }
          
        })

        # Download the standardised table
        output$Integrate_Overlapped_gene_table_download <- downloadHandler(
          filename = function(){"Overlap_filtered_gene_data1_and_data2.tsv"}, 
          content = function(fname){ write.table(Integrate_Overlapped_gene_table_tmp(), fname, sep='\t', quote=F) }
        )

        # list up the gene names
        output$Integrate_Overlapped_gene_list <- renderText({
          paste(na.omit(Integrate_Overlapped_gene_table_tmp()$id), collapse = "\n")
        })

      ##### plot the integrated figure
        # X axis
        output$Integrate_data1_plus_2_Scat.X <- renderUI({
          if(!is.null(data1_plus_data2())){ X_axis_name <- colnames(data1_plus_data2()) }
          else{ X_axis_name <- c() }
          selectInput('Integrate_data1_plus_2_Scat.X', 'X', c('None'='None', X_axis_name), selected = "")
        })

        # Y axis
        output$Integrate_data1_plus_2_Scat.Y <- renderUI({
          if(!is.null(data1_plus_data2())){ Y_axis_name <- colnames(data1_plus_data2()) }
          else{ Y_axis_name <- c() }
          selectInput('Integrate_data1_plus_2_Scat.Y', 'Y', c('None'='None', Y_axis_name))
        })

        # colour
        output$Integrate_data1_plus_2_Scat.colour <- renderUI({
          if(!is.null(data1_plus_data2())){ col_name <- colnames(data1_plus_data2()) }
          else{ col_name <- c() }
          selectInput('Integrate_data1_plus_2_Scat.colour', 'Colour', c('None'='None', col_name))
        })

        # plot
        output$Integrate_data1_plus_2_plot <- renderPlot({
          df_main_plot <- data1_plus_data2()
          if(is.null(df_main_plot)){ 
            output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the Data1 and the Data2."})
            return(NULL) 
          }
          if((input$Integrate_data1_plus_2_Scat.X == 'None') || (input$Integrate_data1_plus_2_Scat.Y == 'None')){ 
            output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the X and the Y."})
            return(NULL)  
          }
          else{ 
            output$Integrate_data1_plus_2_plot_status <- renderText({NULL})
            if(is.null(input$Integrate_data1_plus_2_Scat.colour) || input$Integrate_data1_plus_2_Scat.colour == 'None'){
              p <- ggplot(df_main_plot, aes_string(x = input$Integrate_data1_plus_2_Scat.X, y = input$Integrate_data1_plus_2_Scat.Y))
            }else{
              p <- ggplot(df_main_plot, aes_string(x = input$Integrate_data1_plus_2_Scat.X, y = input$Integrate_data1_plus_2_Scat.Y, color = input$Integrate_data1_plus_2_Scat.colour))

              values_for_colours <- df_main_plot[,input$Integrate_data1_plus_2_Scat.colour][!is.na(df_main_plot[,input$Integrate_data1_plus_2_Scat.colour])]
              if( min(values_for_colours)<0 ){
                if( max(values_for_colours)>=0 ){
                  tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                  p <- p + scale_color_gradientn( colors = c("blue", "white", "red"), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Integrate_data1_plus_2_Scat.colour)
                  p <- p + scale_fill_gradientn( colors = c("blue", "white", "red"), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=input$Integrate_data1_plus_2_Scat.colour)
                }else{
                  p <- p + scale_color_gradientn( colors = c("blue", "white"), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=input$Integrate_data1_plus_2_Scat.colour)
                  p <- p + scale_fill_gradientn( colors = c("blue", "white"), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=input$Integrate_data1_plus_2_Scat.colour)
                }
              }else{
                p <- p + scale_color_gradientn( colors = c("white", "red"), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Integrate_data1_plus_2_Scat.colour)
                p <- p + scale_fill_gradientn( colors = c("white", "red"), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Integrate_data1_plus_2_Scat.colour)
              }
            }
            p <- p + geom_point(size = input$Integrate_data1_plus_2_dot_label_size) 
          }
          tryCatch(
            expr = {
              res <- brushedPoints(df_main_plot, input$Integrate_data1_plus_2_plot_brush)
              p <- p + geom_text_repel(data = res,  color = 'black', aes(label = id), size=input$Integrate_data1_plus_2_id_size)
            },
            error = function(e){NULL}
          )
          if(!is.null(input$Integrate_data1_plus_2_target_gene) && input$Integrate_data1_plus_2_target_gene!=""){
            p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$Integrate_data1_plus_2_target_gene, split = "\n")),], color='red' , size = input$Integrate_data1_plus_2_highlight_dot_size)
            p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$Integrate_data1_plus_2_target_gene, split = "\n")),],  color = "red", aes(label = id), size = input$Integrate_data1_plus_2_id_size, max.overlaps=20) 
          }
          if(input$Integrate_data1_plus_2_white_background){
              p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
          }
          p <- p + theme(axis.text.y = element_text(size = input$Integrate_data1_plus_2_XY_label_size), axis.text.x = element_text(size = input$Integrate_data1_plus_2_XY_label_size))
          p <- p + theme(axis.title.y = element_text(size = input$Integrate_data1_plus_2_XY_title_size), axis.title.x = element_text(size = input$Integrate_data1_plus_2_XY_title_size))
          p
        }, width=reactive(input$Integrate_data1_plus_2_fig.width), height=reactive(input$Integrate_data1_plus_2_fig.height))

                    # column(4,sliderInput('Integrate_data1_plus_2_dot_label_size', 'Point size', min=0.1, max=10, value=1, step=0.1)),
                    # column(4,sliderInput('Integrate_data1_plus_2_id_size', 'Label size', min=1, max=20, value=5, step=1)),
                    # column(4,sliderInput('Integrate_data1_plus_2_highlight_dot_size', 'Highlighted points size', min=0.1, max=10, value=3, step=0.1)),

        # display the selected area
        output$Integrate_data1_plus_2_selected <- renderDataTable({
          res <- brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush) 
          datatable( data.frame(res), options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10))
        })

        # download the table
        output$Integrate_data1_plus_2_selected_download <- downloadHandler(
          filename = function(){"Integrate_data1_data2.tsv"}, 
          content = function(fname){ write.table(data1_plus_data2(), fname, sep='\t', row.names=F, quote=F) }
        )

        # list up the gene names
        output$Integrate_data1_plus_2_selected_gene_list <- renderText({
          paste(na.omit(data1_plus_data2()$id), collapse = "\n")
        })


  ###

  ### scRNA ########################################################################################
    suppressMessages(library(Seurat))
    suppressMessages(library(reshape2))
    suppressMessages(library(cowplot))

    #### data selection
      output$scRNA_data_select <- renderUI({ selectInput('scRNA_data_select', 'Select a scRNA data', c('None'='None', Dataset()[Dataset()$Data.Class == 'C',]$Dataset)) })
      output$scRNA_data_Dataset_detail <- renderText({
        df_tmp <- Dataset()
        if(!is.null(input$scRNA_data_select) && input$scRNA_data_select != 'None'){
          paste0('Data.from: ', as.character(df_tmp[df_tmp$Dataset == input$scRNA_data_select, ]$Data.from), '\n', 
                'Experiment: ', as.character(df_tmp[df_tmp$Dataset == input$scRNA_data_select, ]$Experiment), '\n', 
                'When: ' , as.character(df_tmp[df_tmp$Dataset == input$scRNA_data_select, ]$When), '\n', 
                'Description: ' , as.character(df_tmp[df_tmp$Dataset == input$scRNA_data_select, ]$Description), '\n'
                )
        }else{
          'Please select a dataset.'
        }
      })
    #### load Seurat object
      Seurat_obj <- reactive({ 
        if(length(input$scRNA_data_select) == 0){
          return(NULL)
        }
        if(input$scRNA_data_select == 'None'){
          output$scRNA_UMAP1_status <- renderText({"Please select a dataset."})
          return(NULL)
        }
        tryCatch({
            Seurat_obj <- readRDS(  Dataset()[Dataset()$Dataset == input$scRNA_data_select,]$Path[1] )  
            if('umap' %in% names(Seurat_obj@reductions)){
              Seurat_obj
            }else{
              output$scRNA_UMAP1_status <- renderText({"The UMAP reduction is not calculated in the data. Please run RunUMAP()."})
              return(NULL)  
            }
          }, error=function(e){ 
            output$scRNA_UMAP1_status <- renderText({"Cannot load the Seurat object. \nPlease check if the data was processed correctly."})
            return(NULL) 
          }
        )
      })
      Seurat_umap <- reactive({ as.data.frame(Seurat_obj()@reductions$umap@cell.embeddings) })
      Seurat_expression <- reactive({ GetAssayData(object = Seurat_obj(), assay = "RNA", slot = "data") })

    #### generate UMAP
      # select group.by
      output$scRNA_UMAP1_groupBy <- renderUI({
        if(!is.null(Seurat_obj())){
          meta <- Seurat_obj()@meta.data
          selectInput('scRNA_UMAP1_groupBy', 'Colour by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
        }else{
          selectInput('scRNA_UMAP1_groupBy', 'Colour by:', c('None'='None') )
        }
      })

      # draw a umap
      output$scRNA_UMAP1 <- renderPlot({
        if(is.null(input$scRNA_UMAP1_groupBy) || input$scRNA_UMAP1_groupBy == 'None'){
          output$scRNA_UMAP1_status <- renderText({"Please select a dataset."})
          return(NULL)
        }else{
          output$scRNA_UMAP1_status <- renderText({NULL})
          p1 <- DimPlot(Seurat_obj(),reduction = "umap",group.by = c(input$scRNA_UMAP1_groupBy))
          p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap1_XY_label), axis.title = element_text(size=input$scRNA_umap1_XY_title))
          p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap1_legend_size), legend.title = element_text(size=input$scRNA_umap1_legend_size))
          p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap1_graph_title)) 
          p1
        }
      }, width=reactive(input$scRNA_umap1_fig.width), height=reactive(input$scRNA_umap1_fig.height))

    #### Feature plot
      # function for showing one gene's expression
      gene_expression_map_noGene <- function(ex, umap){
          gene_ex_data <- data.frame(umap)
          colnames(gene_ex_data) <- c("UMAP_1","UMAP_2")
          p1 <- ggplot(gene_ex_data,aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=gene_ex_data, size = 1, color= input$scRNA_umap2_zero_colour)
          p1 <- p1 + theme(axis.text = element_text(size=20), axis.title = element_text(size=20), legend.text = element_text(size=20), legend.title = element_text(size=20), plot.title = element_text(size=20)) 
          p1
      }
      gene_expression_map <- function(ex, umap, gene){
        if(gene %in% rownames(ex)){
          ex_gene <- ex[gene,]
          gene_ex_data <- data.frame(umap, ex_gene)
          colnames(gene_ex_data) <- c("UMAP_1","UMAP_2","Gene" )
          p1 <- ggplot(gene_ex_data,aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=gene_ex_data[gene_ex_data$Gene == 0,] , size = 1, color= input$scRNA_umap2_zero_colour)
          p1 <- p1 + geom_point(data=gene_ex_data[gene_ex_data$Gene > 0,] , size = 1, aes(color= Gene))
          p1 <- p1 + scale_color_gradient(low  = input$scRNA_umap2_lowest_colour, high = input$scRNA_umap2_highest_colour)
          p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap2_XY_label.font.size), axis.title = element_text(size=input$scRNA_umap2_XY_title.font.size))
          p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap2_legend_size), legend.title = element_text(size=input$scRNA_umap2_legend_size))
          p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap2_graph.title.font.size)) 
          p1 <- p1 + ggtitle(gene)
          if(input$scRNA_umap2_while_background){
            p1 <- p1 + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
          }
        }else{
          p1 <- gene_expression_map_noGene(ex, umap)
        }
        p1
      }

      # input gene talbe
      target_gene_for_scRNA_featurePlot <- reactive({
        if(!is.null(Seurat_obj())){
          if(nchar(input$scRNA_UMAP2_gene) >0){
            genes <- unique(unlist(strsplit(input$scRNA_UMAP2_gene, split = "\n")))
            genes2 <- intersect(genes,rownames(Seurat_obj()) ) 
            diff_gene <- setdiff(genes,rownames(Seurat_obj()))
            if(length(diff_gene) > 0){
              output$scRNA_UMAP2_gene_input_status <- renderText({
                tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                genes_tmp <- ''
                for (a in diff_gene){
                  genes_tmp <- paste0(genes_tmp, a, ',')
                }
                genes_tmp <- substr(genes_tmp, 1, nchar(genes_tmp)-1)
                paste0(tmp, genes_tmp)
              })
            }else{
              output$scRNA_UMAP2_gene_input_status <- renderText({NULL})
            }
            data.frame(Input=genes2)
          }else{
            output$scRNA_UMAP2_gene_input_status <- renderText({NULL})
            data.frame()
          }
        }else{
          return(NULL)
        }

      })
      output$scRNA_UMAP2_gene_table <- renderDataTable({
        datatable( target_gene_for_scRNA_featurePlot(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
      })

      # draw UMAP2 (gene expression feature map)
      output$scRNA_UMAP2 <- renderPlot({
        if(!is.null(Seurat_obj())){
          if(input$scRNA_UMAP2_gene == '' || is.null(input$scRNA_UMAP2_gene) ){
            output$Feature_Plot_status_catch <- renderText({'Please enter genes'})
            # p <- gene_expression_map_noGene(Seurat_expression(), Seurat_umap())
          }else{
            if(length(input$scRNA_UMAP2_gene_table_rows_selected)>0){
              output$Feature_Plot_status_catch <- renderText({NULL})
              gene <- target_gene_for_scRNA_featurePlot()[input$scRNA_UMAP2_gene_table_rows_selected,]
              p <- gene_expression_map(Seurat_expression(), Seurat_umap(), gene )    
              p
            }else{
              output$Feature_Plot_status_catch <- renderText({'Please select a gene'})
            }
          }
        }else{
          output$Feature_Plot_status_catch <- renderText({'Please select a dataset'})
          # p <- ggplot()
        }
        # p
      }, width=reactive(input$scRNA_umap2_fig.width), height=reactive(input$scRNA_umap2_fig.height))

    #### Vlnplot
      # select grou.by
      output$scRNA_VlnPlot_groupBy <- renderUI({
        if(length(input$scRNA_data_select) != 0){
          if(input$scRNA_data_select != 'None'){
            if(!is.null(Seurat_obj())){
              meta <- Seurat_obj()@meta.data
              selectInput('scRNA_VlnPlot_groupBy', 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
            }else{
              selectInput('scRNA_VlnPlot_groupBy', 'Group by:', c('None'='None') )  
            }
          }else{
            selectInput('scRNA_VlnPlot_groupBy', 'Group by:', c('None'='None') )
          }
        }
      })
      outputOptions(output, "scRNA_VlnPlot_groupBy", suspendWhenHidden=FALSE)

      output$scRNA_VlnPlot_status <- renderText({NULL})
      outputOptions(output, "scRNA_VlnPlot_status", suspendWhenHidden=FALSE)

      # plot violin plot or RidgePlot or DotPlot
      output$scRNA_VlnPlot <- renderPlot({
        if(length( Seurat_obj()) == 0){
          return(NULL)
        }
        seurat_obj_tmp <-  Seurat_obj()
        if(is.null(seurat_obj_tmp) || input$scRNA_data_select == 'None'){
          output$scRNA_VlnPlot_status <- renderText({"Please select a dataset"})
          return(NULL)
        }else{
          output$scRNA_VlnPlot_status <- renderText({NULL})
          if(input$scRNA_VlnPlot_groupBy != 'None' ){
            gene_features <- unique(unlist(strsplit(input$scRNA_VlnPlot_gene, split = "\n")))
            if(nchar(input$scRNA_VlnPlot_gene)==0){
              output$scRNA_VlnPlot_status <- renderText({"Please enter genes."})
              return(NULL)
            }
            output$scRNA_VlnPlot_status <- renderText({NULL})
            gene_features <- gene_features[gene_features!= '']
            gene_features <- gene_features[gene_features %in% rownames(seurat_obj_tmp)]
            if(length(gene_features) != 0){   
              seurat_obj_tmp <- SetIdent(seurat_obj_tmp, value = input$scRNA_VlnPlot_groupBy)
              if(input$scRNA_Vln_figType == 'A'){
                p <- VlnPlot(object = seurat_obj_tmp, features = gene_features, raster=FALSE, group.by=input$scRNA_VlnPlot_groupBy)
              }else if(input$scRNA_Vln_figType == 'B'){
                p <- RidgePlot(seurat_obj_tmp, features = gene_features, ncol=1)
              }else{
                p <- DotPlot(seurat_obj_tmp, features = gene_features) + RotatedAxis()
              }
              p <- p + theme(axis.title=element_blank())
            }else{
              output$scRNA_VlnPlot_status <- renderText({"Non of the inputted genes are detected in the dataset. \nPlease check if the names are correct and do not include unnecessary spaces. "})
              return(NULL)
            }
          }else{
            output$scRNA_VlnPlot_status <- renderText({"Please select the category for grouping ('Group by')."})
            return(NULL)
          }
        }
        p <- p + theme(legend.text=element_text(size=input$scRNA_vln_legend_size), legend.title=element_text(size=input$scRNA_vln_legend_size))
        p <- p + theme(axis.text = element_text(size=input$scRNA_vln_label_size), axis.title = element_text(size=input$scRNA_vln_label_size))
        p
      }, width=reactive(input$scRNA_vln_fig.width), height=reactive(input$scRNA_vln_fig.height))
      outputOptions(output, "scRNA_VlnPlot", suspendWhenHidden=FALSE)

                              # column(12,sliderInput('scRNA_vln_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                              # column(12,sliderInput('scRNA_vln_fig.height', 'Fig height', min=300, max=3000, value=500, step=1)),
                              # column(12,sliderInput('scRNA_vln_label_size', 'X/Y label size', min=3, max=30, value=10, step=1)),
                              # column(12,sliderInput('scRNA_vln_legend_size', 'legend size', min=3, max=30, value=10, step=1))

    #### Fraction of the cells expressing a certain gene

      # gene to investigate
      # fraction_gene <- reactive({ unlist(strsplit(input$scRNA_fraction_gene, split = "\n"))[1] })
      target_gene_for_scRNA_fraction <- reactive({
        if(!is.null(Seurat_obj())){
          if(nchar(input$scRNA_fraction_gene) >0){
            genes <- unique(unlist(strsplit(input$scRNA_fraction_gene, split = "\n")))
            genes2 <- intersect(genes,rownames(Seurat_obj()) ) 
            diff_gene <- setdiff(genes,rownames(Seurat_obj()))
            if(length(diff_gene) > 0){
              output$scRNA_fraction_gene_input_status <- renderText({
                tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                genes_tmp <- ''
                for (a in diff_gene){
                  genes_tmp <- paste0(genes_tmp, a, ',')
                }
                genes_tmp <- substr(genes_tmp, 1, nchar(genes_tmp)-1)
                paste0(tmp, genes_tmp)
              })
            }else{
              output$scRNA_fraction_gene_input_status <- renderText({NULL})
            }
            data.frame(Input=genes2)
          }else{
            output$scRNA_fraction_gene_input_status <- renderText({NULL})
            data.frame()
          }
        }else{
          return(NULL)
        }

      })
      output$scRNA_fraction_gene_table <- renderDataTable({
        datatable( target_gene_for_scRNA_fraction(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
      })
      outputOptions(output, "scRNA_fraction_gene_table", suspendWhenHidden=FALSE)

      # select the group
      output$scRNA_fraction_groupBy <- renderUI({
        if(length(input$scRNA_data_select)==0){
          return(NULL)
        }
        if(input$scRNA_data_select != 'None'){
          if(!is.null(Seurat_obj())){
            meta <- Seurat_obj()@meta.data
            selectInput('scRNA_fraction_groupBy', 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
          }
        }else{
          selectInput('scRNA_fraction_groupBy', 'Group by:', c('None'='None') )
        }
      })
      outputOptions(output, "scRNA_fraction_groupBy", suspendWhenHidden=FALSE)

      output$scRNA_fraction_status <- renderText({NULL})
      outputOptions(output, "scRNA_fraction_status", suspendWhenHidden=FALSE)


      # prepare the table for generating pie charts
      fraction_gene_group <- reactive({
        if(length(input$scRNA_data_select)==0){
          return(NULL)
        }
        if(input$scRNA_data_select == 'None'){
          output$scRNA_fraction_status <- renderText({'Please select a dataset'})
          return(NULL)
        }
        if(length(input$scRNA_fraction_gene_table_rows_selected)>0){
          fraction_gene <- target_gene_for_scRNA_fraction()[input$scRNA_fraction_gene_table_rows_selected,] 
        }else{
          output$scRNA_fraction_status <- renderText({'Please select a gene'})
          return(NULL)
        }
        output$scRNA_fraction_status <- renderText({NULL})
        meta <- Seurat_obj()@meta.data
        ex <- Seurat_expression()
        ex_gene <- ex[fraction_gene,] 
        if(input$scRNA_fraction_groupBy == 'None'){
          output$scRNA_fraction_status <- renderText({'Please select a category for grouping ("Group by")'})
          return(NULL)
        }
        output$scRNA_fraction_status <- renderText({NULL})
        groups <- unique(meta[,input$scRNA_fraction_groupBy])
        df_fraction <- data.frame('Group'=c(), 'Expressing' = c(), 'Non.expressing'=c())
        for ( group in groups ){
          cells <- rownames(meta[meta[,input$scRNA_fraction_groupBy] == group,])
          ex_gene_group <- ex_gene[cells]
          num_expressed <- length(ex_gene_group[ex_gene_group>0])
          num_non_expressed <- length(ex_gene_group[ex_gene_group==0])
          df_fraction <- rbind(df_fraction, list('Group'=c(group), 'Expressing' = c(num_expressed), 'Non.expressing'=c(num_non_expressed)))
        }
        return(df_fraction)
      })

      # draw pie chart
      output$scRNA_fraction_piechart <- renderPlot({
        if(length(fraction_gene_group())==0){
          return(NULL)
        }
        df_fraction <- fraction_gene_group()
        if(is.null(df_fraction)){
          return(NULL)
        }
        melt(df_fraction, id.vars='Group')
        df_fraction_melt <- melt(df_fraction, id.vars='Group')
        df_fraction_melt$variable <- factor(df_fraction_melt$variable, levels = c('Expressing', 'Non.expressing'))
        plots <- list()
        for (group in unique(df_fraction_melt$Group)){
          df_plot_tmp <- df_fraction_melt[df_fraction_melt$Group == group,]
          df_plot_tmp <- df_plot_tmp %>% mutate(fraction = value/sum(value), label=paste0(value, "(", round(fraction*100), "%)"))
          p_tmp <- ggplot(df_plot_tmp, aes(x="", y=value, fill=variable)) + geom_bar(stat='identity', width=1) + coord_polar(theta='y')
          p_tmp <- p_tmp + scale_fill_manual(values=c("Expressing" = input$scRNA_fraction_expressing_colour, "Non.expressing"= input$scRNA_fraction_non_expressing_colour))
          if(!input$scRNA_fraction_hide_label){
            p_tmp <- p_tmp + geom_text(aes(y=value/2 + c(0, cumsum(value)[-length(value)]), label=label), size=input$scRNA_fraction_label_size)
          }
          p_tmp <- p_tmp + theme_void() + ggtitle(group)
          p_tmp <- p_tmp + theme(plot.title=element_text(size=input$scRNA_fraction_group_name_size))
          if(!input$scRNA_fraction_hide_legend){
            p_tmp <- p_tmp + theme(legend.text=element_text(size=input$scRNA_fraction_legend_size), legend.title=element_text(size=input$scRNA_fraction_legend_size))
            p_tmp <- p_tmp + labs(fill=target_gene_for_scRNA_fraction()[input$scRNA_fraction_gene_table_rows_selected,])
          }else{
            p_tmp <- p_tmp + theme(legend.position = 'none')
          }
          plots[[length(plots) + 1]] <- p_tmp
        }
        p <- plot_grid(plotlist = plots)
        p
      }, width=reactive(input$scRNA_fraction_fig.width), height=reactive(input$scRNA_fraction_fig.height))
      outputOptions(output, "scRNA_fraction_piechart", suspendWhenHidden=FALSE)


  ###

  ### igv ##########################################################################################
    # suppressMessages(library(igvShiny))
    # suppressMessages(library(GenomicAlignments))

    #### data selection
      # data from who
      output$igv_data_DataFrom <- renderUI({  selectInput('igv_data_DataFrom', 'Data from', c('None'='None', Dataset()[Dataset()$Data.Class == input$igv_data_type,]$Data.from)) })

      # data from which experiment
      output$igv_data_Experiment <- renderUI({  
        tmp <- Dataset()[Dataset()$Data.Class == input$igv_data_type,]
        if(!is.null(input$igv_data_DataFrom) && input$igv_data_DataFrom != 'None'){ tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] }
        selectInput('igv_data_Experiment', 'Experiment', c('None'='None', tmp$Experiment)) 
      })

      # data selection
      output$igv_data_select <- renderUI({ 
        tmp <- Dataset()[Dataset()$Data.Class == input$igv_data_type,]
        if(!is.null(input$igv_data_DataFrom) && input$igv_data_DataFrom != 'None'){ tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] }
        if(!is.null(input$igv_data_Experiment) && input$igv_data_Experiment != 'None'){ tmp <-tmp[tmp$Experiment == input$igv_data_Experiment,] }
        selectInput('igv_data_select', 'Select dataset to see in IGV', c('None'='None', tmp$Dataset)) 
      })

      # show the detail
      output$igv_Dataset_detail <- renderText({
        df_tmp <- Dataset()
        if(!is.null(input$igv_data_select) && input$igv_data_select != 'None'){
          paste0('Data.from: ', as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Data.from), '\n', 
                'Experiment: ', as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Experiment), '\n', 
                'Data.type: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Data.type), '\n', 
                'When: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$When), '\n', 
                'Description: ' , as.character(df_tmp[df_tmp$Dataset == input$igv_data_select, ]$Description), '\n'
                )
        }else{
          'Please select a dataset.'
        }
      })

      # change the header of the bed file
      bed_data <- reactive({ 
        path <- Dataset()[Dataset()$Dataset == input$igv_data_select, ]$Path
        tmp <- read.table(path, sep='\t') # head(bed_data)
        colnames(tmp)[1] <- 'chrom'
        colnames(tmp)[2] <- 'start'
        colnames(tmp)[3] <- 'end'
        colnames(tmp)[5] <- 'score'
        return(tmp)
      })
      
    #### start igv
    
    # igv initiation
    output$igv <- renderIgvShiny({
      options <- parseAndValidateGenomeSpec(genomeName="hg38")
      igvShiny(options)  # Initialize IGV with hg38 genome
    })

    # add bed file to view
    observeEvent(input$igv_data_add, {
      # Track information for the BAM file
      loadBedTrack(session, id="igv", trackName=input$igv_data_select, tbl=bed_data())
      
      # Add the BAM track to the IGV viewer
      # session$sendCustomMessage(type = "addTrack", track)
    })
  ###

  ### Clinical_data ################################################################################

    #### Clinical data loading ####
      Cliniacal_dataset <- reactiveVal({data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T))})
      output$Clinical_data_select <- renderUI({ selectInput('Clinical_data_select', 'Select a clinical data', c('None'='None', Cliniacal_dataset()$Database.Name)) })
      output$Clinical_Dataset_detail <- renderText({
        df_tmp <- Cliniacal_dataset()
        if(!is.null(input$Clinical_data_select) && input$Clinical_data_select != 'None'){
          paste0('Description: ' , as.character(df_tmp[df_tmp$Database.Name == input$Clinical_data_select, ]$Description), '\n' )
        }else{
          'Please select a dataset.'
        }
      })

      Clinical_gene_expression <- reactive({
        if(!is.null(input$Clinical_data_select) && input$Clinical_data_select != 'None'){
          path <- Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Expression_path
          if(!file.exists(path)){
            output$Clinical_View_Geneexpression_status <- renderText({'The file does not exsit. \nDid you download and deploy the folloeing files? \nhttps://d250-shiny2.inet.dkfz-heidelberg.de/users/h023o/in_house_screening/00_Clinical_dataset.tar.gz \n \n or, please upload the data again. '})  
            return(NULL)
          }
          tmp <- read.table(path, sep='\t', header=T, row.names=1)
          output$Clinical_View_Geneexpression_status <- renderText({
            paste0('Number of genes: ', dim(tmp)[1], '\n', 'Number of samples: ' , dim(tmp)[2])
          })
          data.frame(tmp)
        }else{
          output$Clinical_View_Geneexpression_status <- renderText({'Please select a dataset.'})
          NULL
        }
      })
      Clinical_surival <- reactive({
        if(!is.null(input$Clinical_data_select) && input$Clinical_data_select != 'None'){
          output$Clinical_View_Survival_status <- renderText({NULL})
          path=Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Survival_path
          if(!file.exists(path)){
            output$Clinical_View_Survival_status <- renderText({'The file does not exsit. \nDid you download and deploy the folloeing files? \nXXX \n \n or, please upload the data again. '})  
            return(NULL)
          }
          data.frame(read.delim(path, header=T))
        }else{
          output$Clinical_View_Survival_status <- renderText({'Please select a dataset.'})
          NULL
        }
      })  
      Clinical_meta <- reactive({
        if(!is.null(input$Clinical_data_select) && input$Clinical_data_select != 'None'){
          output$Clinical_View_MetaData_status <- renderText({NULL})
          path=Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Meta_path
          if(!file.exists(path)){
            output$Clinical_View_MetaData_status <- renderText({'The file does not exsit. \nDid you download and deploy the folloeing files? \nXXX \n \n or, please upload the data again. '})  
            return(NULL)
          }
          data.frame(read.delim(path, header=T))
        }else{
          output$Clinical_View_MetaData_status <- renderText({'Please select a dataset.'})
          NULL
        }
      })  

    #### display the table of the data (gene expression, survival, metadata) ####
      output$Clinical_View_Geneexpression <- DT::renderDataTable({
        # radioButtons('Clinical_View_EX_show_number', '', c("Show the first 1000 headers"='A', 'Show everything (the server will be overloaded depending on the size of the data)'='B'), selected='A'),
        if(is.null( Clinical_gene_expression())){
          return(NULL)
        }
        if(input$Clinical_View_EX_show_number == 'B'){
          tmp <- Clinical_gene_expression()
        }else{
          tmp <- head(Clinical_gene_expression(),1000)
        }
        datatable(tmp, options = list(scrollX = TRUE, pageLength = 10, server=TRUE))
      })
      output$Clinical_View_Survival <- DT::renderDataTable({
        datatable(Clinical_surival(), options = list(scrollX = TRUE, pageLength = 10))
      })
      output$Clinical_View_MetaData <- DT::renderDataTable({
        datatable(Clinical_meta(), options = list(scrollX = TRUE, pageLength = 10))
      })

    #### Survival analysis ####
      suppressMessages(library(survival))
      suppressMessages(library(survminer))

      ##### Calculate the p and HR #####
        # when using a custom gene set
        output$Clinical_Survival_genes_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c()
          gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
          selectInput('Clinical_Survival_genes_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
        })
        outputOptions(output, "Clinical_Survival_genes_from_custom_geneset_select", suspendWhenHidden=FALSE)

        df_Suv_p_and_HR <- eventReactive(input$Clinical_Survival_start, {
          if(input$Clinical_data_select=='None'){
            output$Clinical_Survial_table_status <- renderText({"Please select the clinical dataset"})
            return(NULL)
          }
          df_geneEx <- Clinical_gene_expression()
          df_OS <- Clinical_surival()
          if(input$Clinical_Survival_genes_from_custom_geneset){
            if(input$Clinical_Survival_genes_from_custom_geneset_select == 'None'){
              output$Clinical_Survial_table_status <- renderText({"Please select a custom gene set."})
              return(NULL)
            }
            genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Clinical_Survival_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
          }else{
            if(nchar(input$Clinical_Survival_genes)== 0 ){
              output$Clinical_Survial_table_status <- renderText({"Please enter genes"})
              return(NULL)
            }
            genes <- unlist(strsplit(input$Clinical_Survival_genes, '\n'))
          }
          genes <- intersect(genes, rownames(df_geneEx))
          if(length(genes) == 0){
            output$Clinical_Survial_table_status <- renderText({"None of the inputted genes are not in the dataset. \nPlease make sure the gene names are correct and does not include unnecessary spaces."})
            return(NULL)
          }

          df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          # genes <- unlist(strsplit(input$Clinical_Survival_genes, split = "\n")) # genes <- c('CXCL10', 'CXCL9')
          df_out <- data.frame('Gene'=c(), 'P.value'=c(), 'Hazard.Ratio'=c())
          error_genes <- c()
          output$Clinical_Survial_table_status <- renderText({NULL})
          for (gene in genes){ # gene <- genes[1]
            if(gene!=''){ 
              if(!(gene %in% rownames(df_geneEx))){
                df_tmp <- data.frame('Gene'=gene, 'P.value'=NA, 'Hazard.Ratio'=NA)
                df_out <- rbind(df_out, df_tmp)
              }else{
                if(input$Clinical_Survival_Split_way == 'A'){
                  med <- median(unlist(df_geneEx[gene,]))
                  df_high_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene,] >= med]))
                  df_low_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene,] < med]))
                }else{
                  top25 <- quantile(unlist(df_geneEx[gene,]), 0.75)
                  bottom25 <- quantile(unlist(df_geneEx[gene,]), 0.25)
                  df_high_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene,] >= top25]))
                  df_low_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene,] <= bottom25]))
                }
                if(length(df_high_sample)==0|length(df_low_sample)==0){
                  error_genes <- c(error_genes, gene)
                }else{
                  # add group
                  df_OS$group = NA
                  df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
                  df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
                  df_OS$group <- factor(df_OS$group, levels=c('Low', 'High'))
                  # survival object
                  surv_obj <- Surv(time = df_OS$OS.time, event = df_OS$OS)
                  # calculate the kaplan-meier for each group
                  km_fit <- survfit(surv_obj ~ group, data = df_OS)
                  cox_model <- coxph(surv_obj ~ group, data = df_OS)
                  # Hazard ratio and p
                  HR <- exp(cox_model$coefficients)
                  p_value <- summary(cox_model)$coefficients[, 5]
                  df_tmp <- data.frame('Gene'=gene, 'P.value'=p_value, 'Hazard.Ratio'=HR)
                  df_out <- rbind(df_out, df_tmp)
                }
              }
            }
          }
          if(length(error_genes)>0){
            output$Clinical_Survial_table_status <- renderText({
              tmp <- 'Cannot divide the samples into high/low for the following these with the selected method. \nThe expressions may be too small: \n'
              for (key in error_genes){
                tmp <- paste(tmp, key, sep='\n')
              }
              tmp
            })
          }else{
            output$Clinical_Survial_table_status <- renderText({NULL})
          }
          if(dim(df_out)[1]==0){
            output$Clinical_Survial_table_status <- renderText({'None of the inputted genes are not in the dataset.'})
            return(NULL)
          }else{
            df_out <- df_out[order(df_out$Hazard.Ratio, decreasing = T),]
            df_out$method <- input$Clinical_Survival_Split_way
            return(df_out)
          }

        })
        output$Clinical_Survial_table <- DT::renderDataTable({
          tmp <- df_Suv_p_and_HR()[, c('Gene', 'P.value', 'Hazard.Ratio')]
          rownames(tmp) <- NULL
          datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        })
        
        # download the table
        output$Clinical_Survial_table_download <- downloadHandler(
        filename = function(){"Survival_analysis.tsv"}, 
        content = function(fname){ write.table(df_Suv_p_and_HR(), fname, sep='\t', row.names=F, quote=F) }
        )

      ##### plot a Kaplan meier #####
        # output$Clinical_Survial_plot_Geneselect <- renderUI({ 
        #   selectInput('Clinical_Survial_plot_Geneselect', 'Gene', c('None'='None', unlist(strsplit(input$Clinical_Survival_genes, split = "\n")))) 
        # })
        output$Clinical_Survial_plot <- renderPlot({
          df_geneEx <- Clinical_gene_expression()
          df_OS <- Clinical_surival()
          df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          if(is.null(df_Suv_p_and_HR())==TRUE){
            output$Clinical_Survial_plot_error_catch <- renderText({NULL})
            return(NULL)
          }
          # gene_kaplan <- input$Clinical_Survial_plot_Geneselect
          if(length(input$Clinical_Survial_table_rows_selected)==0){
            output$Clinical_Survial_plot_error_catch <- renderText({'Please select a gene from the table.'})
            return(NULL)
          }
          output$Clinical_Survial_plot_error_catch <- renderText({NULL})
          gene_kaplan <- df_Suv_p_and_HR()[input$Clinical_Survial_table_rows_selected,]$Gene
          if(df_Suv_p_and_HR()$method[1] == 'A'){
            med <- median(unlist(df_geneEx[gene_kaplan,]))
            df_high_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene_kaplan,] >= med]))
            df_low_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene_kaplan,] < med]))
          }else{
            top25 <- quantile(unlist(df_geneEx[gene_kaplan,]), 0.75)
            bottom25 <- quantile(unlist(df_geneEx[gene_kaplan,]), 0.25)
            df_high_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene_kaplan,] >= top25]))
            df_low_sample <- gsub('\\.', '-', colnames(df_geneEx[,df_geneEx[gene_kaplan,] <= bottom25]))
          }
          df_OS$group = NA
          df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
          df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
          df_OS$group <- factor(df_OS$group, levels=c('High', 'Low'))

          # survival object
          surv_obj <- Surv(time = df_OS$OS.time, event = df_OS$OS)
          km_fit <- survfit(surv_obj ~ group, data = df_OS)
          km_data <- broom::tidy(km_fit)
          # graph
          km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 1) + 
            geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
            labs( title = gene_kaplan, x = "Time", y = "Survival Probability", color = "") +
            scale_color_manual(
              values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
              labels=c(paste0(gene_kaplan, '-High (n=', as.character(length(df_high_sample)), ')'), paste0(gene_kaplan, '-Low (n=', as.character(length(df_low_sample)), ')'))
            ) + 
            scale_fill_manual(
              values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
              labels=c(paste0(gene_kaplan, '-High (n=', as.character(length(df_high_sample)), ')'), paste0(gene_kaplan, '-Low (n=', as.character(length(df_low_sample)), ')'))
            ) +
            guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Clinical_Survial_legend_size)) 
          p <- km_plot
          p <- p + theme(axis.text.y = element_text(size = input$Clinical_Survial_label_size), axis.text.x = element_text(size = input$Clinical_Survial_label_size))
          p <- p + theme(axis.title.y = element_text(size = input$Clinical_Survial_title_size), axis.title.x = element_text(size = input$Clinical_Survial_title_size))

          p

        }, width=reactive(input$Clinical_Survial_fig.width), height=reactive(input$Clinical_Survial_fig.height))
      ##### distribution #####
        output$Clinical_Survial_distribution_plot <- renderPlot({
          if(is.null(df_Suv_p_and_HR())==TRUE){
            output$Clinical_Survial_plot_distribution_status <- renderText({NULL})
            return(NULL)
          }
          # gene_kaplan <- input$Clinical_Survial_plot_Geneselect
          if(length(input$Clinical_Survial_table_rows_selected)==0){
            output$Clinical_Survial_plot_distribution_status <- renderText({'Please select a gene from the table.'})
            return(NULL)
          }
          output$Clinical_Survial_plot_distribution_status <- renderText({NULL})
          gene_histgram <- df_Suv_p_and_HR()[input$Clinical_Survial_table_rows_selected,]$Gene
          df_geneEx <- Clinical_gene_expression()[gene_histgram,]
          df_geneEx_t <- data.frame(t(df_geneEx))
          p <- ggplot(df_geneEx_t, aes_string(x=gene_histgram))
          p <- p + geom_histogram(fill=input$Clinical_Survial_distribution_colour, alpha=0.6, bins=input$Clinical_Survial_distribution_bin_num)
          p <- p + ggtitle(gene_histgram)
          p <- p + xlab('Expression')
          p <- p + theme(axis.text = element_text(size = input$Clinical_Survial_distribution_label_size))
          p <- p + theme(axis.title = element_text(size = input$Clinical_Survial_distribution_title_size))
          p <- p + theme(plot.title = element_text(size = input$Clinical_Survial_distribution_graphtitle_size))
          if(input$Clinical_Survial_distribution_white_background){
            p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
          }
          p
        }, width=reactive(input$Clinical_Survial_distribution_fig.width), height=reactive(input$Clinical_Survial_distribution_fig.height))

    #### Gene corralation ####
      ##### Calculate the correlation #####
        # when using a custom gene set
        output$Gene_correlation_genes_y_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c()
          gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
          selectInput('Gene_correlation_genes_y_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
        })
        outputOptions(output, "Gene_correlation_genes_y_from_custom_geneset_select", suspendWhenHidden=FALSE)

        df_gene_correlation <- eventReactive(input$Gene_correlation_start, {
          renderText({NULL})
          if(input$Clinical_data_select == 'None'){
            output$Gene_correlation_error_catch <- renderText({'Please select the database.'})
            return(NULL)
          }
          if(nchar(input$Gene_correlation_genes)==0){
            output$Gene_correlation_error_catch <- renderText({'Please enter a gene name for the Y axis.'})
            return(NULL)
          }
          gene <-  unlist(strsplit(input$Gene_correlation_genes, split = "\n"))[1]
          df_geneEx <- Clinical_gene_expression()
          if(!gene %in% rownames(df_geneEx)){
            output$Gene_correlation_error_catch <- renderText({'The inputted gene is not in the dataset.\nPlease make sure the gene name is correct and does not include unnecessary spaces.'})
            return(NULL)
          }
          if(length(input$Gene_correlation_Corralation_method) == 0){
            output$Gene_correlation_error_catch <- renderText({'Please choose the Method for correlation'})
            return(NULL)
          }
          if(length(input$Gene_correlation_genes_comparison_type)==0){
            output$Gene_correlation_error_catch <- renderText({'Please choose the Explore type'})
            return(NULL)
          }
          if(input$Gene_correlation_genes_comparison_type == 'A'){
            genes_to_compare <- rownames(df_geneEx)
          }else if(input$Gene_correlation_genes_comparison_type == 'B'){
            if(input$Gene_correlation_genes_y_from_custom_geneset){
              if(input$Gene_correlation_genes_y_from_custom_geneset_select == 'None'){
                output$Gene_correlation_error_catch <- renderText({"Please select a custom gene set."})
                return(NULL)
              }
              genes_to_compare <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Gene_correlation_genes_y_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
            }else{
              if(nchar(input$Gene_correlation_genes_y)== 0 ){
                output$Gene_correlation_error_catch <- renderText({"Please enter genes for the X axis"})
                return(NULL)
              }
              genes_to_compare <- unlist(strsplit(input$Gene_correlation_genes_y, '\n'))
            }
            # if(nchar(input$Gene_correlation_genes_y)==0){
            #   output$Gene_correlation_error_catch <- renderText({'Please enter genes for Y-axis.'})
            #   return(NULL)
            # }
            # genes_to_compare <- unlist(strsplit(input$Gene_correlation_genes_y, split = "\n"))
            genes_to_compare <- intersect(genes_to_compare, rownames(df_geneEx))
            if(length(genes_to_compare) == 0){
              output$Gene_correlation_error_catch <- renderText({'The inputted genes (for Y-axis) are not in the dataset.\nPlease make sure the gene names are correct and do not include unnecessary spaces.'})
              return(NULL)
            }
          }
          df_cor_out <- data.frame(Gene=c(), r=c(), p=c())
          a <- unlist(df_geneEx[gene,])
          for ( gene2 in genes_to_compare){
            b <- unlist(df_geneEx[gene2,])
            c <- cor.test(a, b, method=input$Gene_correlation_Corralation_method)
            r <- c$estimate
            p <- c$p.value
            df_cor_tmp <- data.frame(Gene=gene2, r=r, p=p)
            df_cor_out <- rbind(df_cor_out, df_cor_tmp)
          }
          df_cor_out <- df_cor_out[order(df_cor_out$r, decreasing = T),] # head(df_cor_out)
          rownames(df_cor_out) <- NULL
          df_cor_out$target <- gene
          df_cor_out
        })
      ##### Plot the correlation by a scatter plot #####
        output$Gene_correlation_table <- DT::renderDataTable({
          datatable(df_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        })
        output$Gene_correlation_scatter_plot <- renderPlot({
          if(is.null(df_gene_correlation())){
            # output$Gene_correlation_error_catch <- renderText({'Please start the analysis.'})
            return(NULL)
          }else{
            if(length(input$Gene_correlation_table_rows_selected)>0){
              output$Gene_correlation_error_catch <- renderText({NULL})
              # Gene1 <- unlist(strsplit(input$Gene_correlation_genes, split = "\n"))[1]
              Gene2 <- df_gene_correlation()$target[1]
              Gene1 <- df_gene_correlation()[input$Gene_correlation_table_rows_selected,]$Gene
              df_geneEx <- Clinical_gene_expression()
              scatter_data <- data.frame(Gene1=unlist(df_geneEx[Gene1, ]), Gene2=unlist(df_geneEx[Gene2, ]), Sample=colnames(df_geneEx)) # head(scatter_data)
              p <- ggplot(scatter_data, aes(x=Gene1, y=Gene2))
              p <- p + geom_point(size=3, color=input$Gene_correlation_colour, alpha=0.7)
              if(input$Gene_correlation_show_correlation_line){
                p <- p + geom_smooth(method='lm', se=TRUE, color=input$Gene_correlation_colour)
              }
              p <- p + labs(x=Gene1, y=Gene2)
              p <- p + theme(axis.text.y = element_text(size = input$Gene_correlation_label_size), axis.text.x = element_text(size = input$Gene_correlation_label_size))
              p <- p + theme(axis.title.y = element_text(size = input$Gene_correlation_title_size), axis.title.x = element_text(size = input$Gene_correlation_title_size))
              if(input$Gene_correlation_white_background){
                p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
              }
              p
            }else{
              output$Gene_correlation_error_catch <- renderText('Please select a gene from the table.')
              return(NULL)
            }
          }
          p
        }, width=reactive(input$Gene_correlation_fig.width), height=reactive(input$Gene_correlation_fig.height))

        # download the table
        output$Gene_correlation_table_download <- downloadHandler(
          filename = function(){"Gene_correlation_in_cohort.tsv"}, 
          content = function(fname){ write.table(df_gene_correlation(), fname, sep='\t', row.names=F, quote=F) }
        )

    #### Expression across subtypes ####
      # select "Groupby"
      output$Expression_subtype_groupBy <- renderUI({ selectInput('Expression_subtype_groupBy', 'Group by', c('None'='None', colnames(Clinical_meta()))) })

      # check how many subtypes there are
      output$Expression_subtype_subtype_number <- renderText({
        if(input$Expression_subtype_groupBy =='None'){
          NULL
        }else{
          tmp <- unlist(unique(Clinical_meta()[input$Expression_subtype_groupBy]))
          tmp <- tmp[tmp!='']
          tmp <- na.omit(tmp) # length(Clinical_meta[group_by][is.na(Clinical_meta[group_by])])
          num_blanck <- length(Clinical_meta()[input$Expression_subtype_groupBy][Clinical_meta()[input$Expression_subtype_groupBy]==''])
          num_na <- length(Clinical_meta()[input$Expression_subtype_groupBy][is.na(Clinical_meta()[input$Expression_subtype_groupBy])])
          num_nd <- num_blanck + num_na
          paste0('Number of subtypes: ', length(tmp), '\nNumber of NA or no data: ', num_nd)
        }
      })

      # pivot table for test
      Expression_subtype_for_test <- eventReactive(input$Expression_subtype_start,{
        if(input$Clinical_data_select == 'None'){
          output$Expression_subtype_error_catch <- renderText({'Please select a dataset first.'})
          return(NULL)
        }
        # expression
        df_geneEx <- Clinical_gene_expression() 
        if(nchar(input$Expression_subtype_genes)==0){
          output$Expression_subtype_error_catch <- renderText({"Please enter genes."})
          return(NULL)
        }  
        genes <- unlist(strsplit(input$Expression_subtype_genes, split = "\n")) # genes <- c('RERE', 'PHF7')
        genes <- intersect(genes, rownames(df_geneEx))
        if(length(genes)==0){
          output$Expression_subtype_error_catch <- renderText({"None of the inputted genes are included in the dataset. \nPlease make sure the gene names are correct and do not include unnecessary spaces."})
          return(NULL)
        }
        df_gene_EX_gene <- data.frame(t(df_geneEx[genes,])) # head(df_gene_EX_gene)genes='CXCL10'
        df_gene_EX_gene$sample <- gsub('\\.', '-', rownames(df_gene_EX_gene)) 
        colnames(df_gene_EX_gene) <- gsub('\\.', '-', colnames(df_gene_EX_gene)) 
        # meta, subtype
        df_meta <- Clinical_meta()
        df_meta$sample <- gsub('\\.', '-', df_meta$sample)
        group_by <- input$Expression_subtype_groupBy # group_by <- 'GRADE'
        if(group_by == 'None'){
          output$Expression_subtype_error_catch <- renderText({"Please select a group to compare."})
          return(NULL)
        }
        df_meta_subtype <- df_meta[, c('sample', group_by)] # head(df_meta_subtype)
        df_meta_subtype <- df_meta_subtype[!is.na(df_meta_subtype[,group_by]),]
        df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] != '',]
        df_meta_subtype[,group_by] <- as.character(df_meta_subtype[,group_by])
        # merge
        df_tmp <- merge(df_gene_EX_gene, df_meta_subtype, by='sample') # head(df_tmp)
        # df_out[,group_by] <- as.character(df_out[,group_by])
        df_out <- df_tmp %>% pivot_longer(cols=all_of(genes), names_to='Genes', values_to='Expression') # head(df_out)
        
        return(df_out)

      })
      
      # test results
      Expression_subtype_test <- reactive({
        if(is.null(Expression_subtype_for_test())){
          return(NULL)
        }else{
          df_out <- Expression_subtype_for_test() # head(df_out)
          # group_by <- input$Expression_subtype_groupBy
          group_by <- colnames(df_out)[2]
          if(length(unique(unlist(df_out[,group_by]))) >= 3){
            df_test <- data.frame('Gene'=c(), 'Statistic (Kruskal-Wallis)'=c(), 'P.value'=c())
            genes <- unique(unlist(df_out[,'Genes']))
            for (gene in genes){
              # kruskal.test
              df_out_tmp <- df_out[df_out$Genes == gene,]
              df_test_tmp <- kruskal.test(as.formula(paste('Expression', '~', group_by)), data=df_out_tmp) # str(df_test)
              p <- df_test_tmp$p.value
              statistic <- df_test_tmp$statistic
              tmp <- data.frame('Gene'=gene, 'Statistic (Kruskal-Wallis)'=statistic, 'P.value'=p)
              df_test <- rbind(df_test, tmp)
            }          
            # # dunntest
            # library(FSA) #install.packages('FSA')
            # dunnTest(as.formula(paste('Expression', '~', group_by)), data=df_out_tmp, method='bonferroni')
          }else if(length(unique(unlist(df_out[,group_by]))) == 2){
            df_test <- data.frame('Gene'=c(), 'Statistic (Wilcoxon)'=c(), 'P.value'=c())
            genes <- unique(unlist(df_out[,'Genes']))
            for (gene in genes){
              # wilcox.test
              df_out_tmp <- df_out[df_out$Genes == gene,]
              group1 <- df_out_tmp[df_out_tmp[,group_by] == unique(unlist(df_out[,group_by]))[1],]$Expression
              group2 <- df_out_tmp[df_out_tmp[,group_by] == unique(unlist(df_out[,group_by]))[2],]$Expression
              df_test_tmp <- wilcox.test(group1, group2) # str(df_test)
              p <- df_test_tmp$p.value
              statistic <- df_test_tmp$statistic
              tmp <- data.frame('Gene'=gene, 'Statistic (Wilcoxon)'=statistic, 'P.value'=p)
              df_test <- rbind(df_test, tmp)
            }          
          }else{
            output$Expression_subtype_error_catch <- renderText({"There is no sub groups for the selected category. Please try with other categories."})
            return(NULL)
          }
          rownames(df_test) <- NULL
          df_test <- df_test[order(df_test$P.value),]
          df_test$group_by <- group_by
          return(df_test)
        }
      })
      output$Expression_subtype_table <- DT::renderDataTable({
        if(is.null(Expression_subtype_test())){
          df_test <- data.frame()  
        }else{
          df_test <- Expression_subtype_test()[,1:3]
        }
        datatable(df_test, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
      })

      # download the table
      output$Expression_subtype_table_download <- downloadHandler(
        filename = function(){"Expression_across_subtype.tsv"}, 
        content = function(fname){ write.table(Expression_subtype_test(), fname, sep='\t', row.names=F, quote=F) }
      )

      # colour option are mutually exclusive (use pallete or use a single colour)
      observeEvent(input$Expression_subtype_change_colour_pallete, { 
        if(input$Expression_subtype_change_colour_pallete){ updateCheckboxInput(session, "Expression_subtype_use_single_colour", value=FALSE)}
      })
      observeEvent(input$Expression_subtype_use_single_colour, { 
        if(input$Expression_subtype_use_single_colour){ updateCheckboxInput(session, "Expression_subtype_change_colour_pallete", value=FALSE)}
      })

      # boxplot or swarm plt or vlnplot
      output$Expression_subtype_plot <- renderPlot({
        if(is.null(Expression_subtype_test())){
          return(NULL)
        }
        if(length(input$Expression_subtype_table_rows_selected)==0){
          output$Expression_subtype_error_catch <- renderText({'Please select a gene (row) from the result table.'})
          return(NULL)
        }
        output$Expression_subtype_error_catch <- renderText({NULL})
        gene <- Expression_subtype_test()[input$Expression_subtype_table_rows_selected,]$Gene
        df_out <- Expression_subtype_for_test()
        number_each_group <- 'The number of data in each subtypes. \n'
        for (nm in names(table(df_out[,colnames(df_out)[2]]))){
          number_each_group <- paste0(number_each_group, nm , ': ', table(df_out[,colnames(df_out)[2]])[nm], '\n')
        }
        # group_by <- input$Expression_subtype_groupBy
        group_by <- colnames(df_out)[2]
        df_out_tmp <- df_out[df_out$Genes == gene,] # head(df_out_tmp)
        output$Expression_subtype_note <- renderText({
          number_each_group
        })
        # 'Expression_subtype_figtype', 'Figure type:', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C'), selected='A'))
        if(input$Expression_subtype_use_single_colour){
          p <- ggplot(df_out_tmp, aes_string(x=group_by, y='Expression'))
        }else{
          p <- ggplot(df_out_tmp, aes_string(x=group_by, y='Expression', fill=group_by))
        }
        if(input$Expression_subtype_figtype == 'A'){  # boxplot
          if(input$Expression_subtype_use_single_colour){
            p <- p + geom_boxplot(fill=input$Expression_subtype_choose_single_colour)
          }else{
            p <- p + geom_boxplot(color='black')
            if(input$Expression_subtype_select_colour_pallete != 'None'){
              p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
            }
          }
        }else if(input$Expression_subtype_figtype == 'B'){ # violin plot
          if(input$Expression_subtype_use_single_colour){
            p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour)
          }else{
            p <- p + geom_violin(color='black',trim = FALSE)
            if(input$Expression_subtype_select_colour_pallete != 'None'){
              p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
            }
          }
        }else if(input$Expression_subtype_figtype == 'C'){ # swarm plot
          p <- ggplot(df_out_tmp, aes_string(x=group_by, y='Expression', color=group_by))
          if(input$Expression_subtype_use_single_colour){
            p <- p + geom_beeswarm(size=input$Expression_subtype_dot.size,color=input$Expression_subtype_choose_single_colour)
          }else{
            p <- p + geom_beeswarm(size=input$Expression_subtype_dot.size)
            if(input$Expression_subtype_select_colour_pallete != 'None'){
              p <- p + scale_color_viridis_d(option=input$Expression_subtype_select_colour_pallete)
            }
          }
        }else if(input$Expression_subtype_figtype == 'D'){ # swarm plot + violin plot
          if(input$Expression_subtype_use_single_colour){
            p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour)
          }else{
            p <- p + geom_violin(trim = FALSE)
            if(input$Expression_subtype_select_colour_pallete != 'None'){
              p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
            }
          }
          p <- p + geom_jitter(width=0.1, height=0, size=input$Expression_subtype_dot.size)
        }
        if(input$Expression_subtype_rotate_x){
          p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
        }
        p <- p + theme(axis.text.y = element_text(size = input$Expression_subtype_XY_label.font.size), axis.text.x = element_text(size = input$Expression_subtype_XY_label.font.size))
        p <- p + theme(axis.title.y = element_text(size = input$Expression_subtype_XY_title.font.size), axis.title.x = element_text(size = input$Expression_subtype_XY_title.font.size))
        p <- p + theme(legend.position = 'none')
        p <- p + ggtitle(gene) + theme(plot.title = element_text(size = input$Expression_subtype_title.font.size))
        if(input$Expression_subtype_white_background){
            p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
        }
        p
      }, width=reactive(input$Expression_subtype_fig.width), height=reactive(input$Expression_subtype_fig.height))

    #### Upload ####
      # in case that the gx file has duplicated id names
      new_cohort_upload_GE_table <- reactive({NULL})
      new_cohort_upload_GE_table <- reactive({
        output$new_cohort_status <- renderText({NULL})
        req(input$new_cohort_upload_GE)
        gx_table <- read.table(input$new_cohort_upload_GE$datapath, sep='\t', header=T)
        if(!'id' %in% colnames(gx_table)){
          output$new_cohort_status <- renderText({'The gene expression table does not have "id" in its header.'})
        }
        duplicated_gene <- unique(gx_table$id[duplicated(gx_table$id)])
        if(length(duplicated_gene)==0){
          output$new_cohort_upload_GE_preview <- renderDataTable({
            datatable( head(gx_table, 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
          })
          return(gx_table)
        }else{
          output$new_cohort_status <- renderText({'The gene expression table has duplicated genes. The expression assigned to the same gene names will be merged.'})
          No_duplicated <- gx_table[!gx_table$id %in% duplicated_gene,]
          Duplicated <- gx_table[gx_table$id %in% duplicated_gene,]
          Duplicated <- Duplicated %>%
            group_by(id) %>%
            summarise(across(.cols = everything(), .fns = sum, na.rm = TRUE))
          Duplicated <- data.frame(Duplicated)
          df2 <- rbind(No_duplicated, Duplicated)
          return(df2)
        }
      })

      output$new_cohort_upload_GE_preview <- renderDataTable({
        if(length(new_cohort_upload_GE_table())==0){
          return(NULL)
        }else{
          datatable( head(new_cohort_upload_GE_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
        }
      })

      output$new_cohort_upload_sur_preview <- renderDataTable({
        req(input$new_cohort_upload_sur)
        tmp <- read.table(input$new_cohort_upload_sur$datapath, sep='\t', header=T)
        datatable( head(tmp, 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
      })

      output$new_cohort_upload_meta_preview <- renderDataTable({
        req(input$new_cohort_upload_meta)
        tmp <- read.table(input$new_cohort_upload_meta$datapath, sep='\t', header=T)
        datatable( head(tmp, 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
      })

      observeEvent(input$new_cohort_upload_data,{
        if(is.null(input$new_cohort_upload_GE) | is.null(input$new_cohort_upload_sur) | is.null(input$new_cohort_upload_meta) ){
          output$new_cohort_status <- renderText({'Please upload all the files!'})
        }else{
          if(nchar(input$new_cohort_upload_dataset_name)==0 ){
            output$new_cohort_status <- renderText('* is a mandatory filed!')
          }else{
            cohort_name <- gsub(' ', '_', input$new_cohort_upload_dataset_name)
            if(cohort_name %in% Cliniacal_dataset()$Database.Name){
              output$new_cohort_status <- renderText('The Cohort name is duplicated!')
            }else if (str_detect(cohort_name, "[;/,()\\[\\]!@#$%]")) {
              output$new_cohort_status <- renderText('The Cohort name cannot contain "/ , ( ) [ ] ! # @ $ %"!')
            }else{
              time_stamp <- as.character(Sys.time()) 
              dir.create(file.path('00_Clinical_dataset', cohort_name), recursive=T, showWarnings = F)
              save_path_ge <- file.path('00_Clinical_dataset', cohort_name, input$new_cohort_upload_GE$name)
              save_path_cli <- file.path('00_Clinical_dataset', cohort_name, input$new_cohort_upload_sur$name)
              save_path_meta <- file.path('00_Clinical_dataset', cohort_name, input$new_cohort_upload_meta$name)
              Description <- unlist(strsplit(input$new_cohort_upload_description, split = "\n"))[1]

              # in case there are duplicated genes
              error=0
              gx_table <- read.table(input$new_cohort_upload_GE$datapath, sep='\t', header=T)
              if(!'id' %in% colnames(gx_table)){
                output$new_cohort_status <- renderText('The gene expression table does not have "id" in its header.')
                error= 1
              }
              suv_table <- read.table(input$new_cohort_upload_sur$datapath, sep='\t', header=T)
              if(!'sample' %in% colnames(suv_table)){
                output$new_cohort_status <- renderText('The survival table does not have "sample" in its header.')
                error= 1
              }
              meta_table <- read.table(input$new_cohort_upload_meta$datapath, sep='\t', header=T)
              if(!'sample' %in% colnames(meta_table)){
                output$new_cohort_status <- renderText('The meta data does not have "sample" in its header.')
                error= 1
              }
              if(error == 0){
                duplicated_gene <- unique(gx_table$id[duplicated(gx_table$id)])
                if(length(duplicated_gene)==0){
                  file.copy(input$new_cohort_upload_GE$datapath, save_path_ge)
                }else{
                  output$new_cohort_status <- renderText({'The gene expression table has duplicated genes. The expression assigned to the same gene names will be merged.'})
                  No_duplicated <- gx_table[!gx_table$id %in% duplicated_gene,]
                  Duplicated <- gx_table[gx_table$id %in% duplicated_gene,]
                  Duplicated <- Duplicated %>%
                    group_by(id) %>%
                    summarise(across(.cols = everything(), .fns = sum, na.rm = TRUE))
                  Duplicated <- data.frame(Duplicated)
                  df2 <- rbind(No_duplicated, Duplicated)
                  write.table(df2, save_path_ge, sep='\t', row.names=F)
                  # output$new_cohort_status <- renderText({'The gene expression table has duplicated genes. The expression assigned to the same gene names were merged.'})
                  # return(NULL)
                }

                # save
                file.copy(input$new_cohort_upload_sur$datapath, save_path_cli)
                file.copy(input$new_cohort_upload_meta$datapath, save_path_meta)

                tmp <- Cliniacal_dataset()
                tmp <- add_row(tmp, Database.Name=cohort_name , 
                  Description=	Description,
                  Expression_path= save_path_ge,
                  Survival_path= save_path_cli,
                  Meta_path= save_path_meta,
                  added.when= time_stamp)
                tmp <- tmp[order(tmp$added.when, decreasing =T),]
                Cliniacal_dataset(tmp)
                replaceData(dataTableProxy('Cliniacal_dataset'), Cliniacal_dataset(), resetPaging=F)
                write.table(Cliniacal_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
                output$new_cohort_status <- renderText('uploaded!')
              }
            }
          }
        }  
      })

    #### Cohort database
      output$Cohort_DataBaseTable <- DT::renderDataTable({ 
          data_table_tmp <- Cliniacal_dataset()[order(Cliniacal_dataset()$added.when, decreasing =T),]
          data_table_tmp <- data_table_tmp[,c( "Database.Name", "Description")] 
          datatable(data_table_tmp, 
            selection='none', extensions=c('Select'), 
            options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0), 
            editable='cell') 
        },server = FALSE)
      # allow editing the information 
                        #       DT::dataTableOutput("Cohort_DataBaseTable"),
                        # fluidRow( column(1, actionButton('Cohort_DataBase_save_dt', 'Save changes')), column(2, actionButton('Cohort_DataBase_delete_row', 'Delete selected data')), column(7, verbatimTextOutput('Cohort_DataBase_status')) )
      observeEvent(input$Cohort_DataBaseTable_cell_edit,{
        info <- input$Cohort_DataBaseTable_cell_edit
        tmp <- Cliniacal_dataset()
        tmp[info$row, info$col] <- info$value
        output$Cohort_DataBase_status <- renderText(paste(info$row, info$col,info$value ))
        tmp <- tmp[order(tmp$added.when,decreasing =T),]
        Cliniacal_dataset(tmp)
        replaceData(dataTableProxy('Cliniacal_dataset'), Cliniacal_dataset(), resetPaging=F)
      })
      # save changes when you push the button ####
      observeEvent(input$Cohort_DataBase_save_dt,{
        write.table(Cliniacal_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
        output$Cohort_DataBase_status <- renderText('saved!')
      })
      # delete the data when you push the button ####
      observeEvent(input$Cohort_DataBase_delete_row, {
        tmp <- Cliniacal_dataset()
        tmp2 <- Cliniacal_dataset()
        selected_row <- input$Cohort_DataBaseTable_rows_selected
        if(!is.null(selected_row) && length(selected_row) > 0){
          GE_filepaths <- tmp2[selected_row,]$Expression_path
          suv_filepaths <- tmp2[selected_row,]$Survival_path
          meta_filepaths <- tmp2[selected_row,]$Meta_path
          tmp <- tmp[!tmp$Database.Name %in% tmp2[selected_row,]$Database.Name,]
          # delete the file(s)
          for (filepath in GE_filepaths){
            file.remove(filepath)
          }
          for (filepath in suv_filepaths){
            file.remove(filepath)
          }
          for (filepath in meta_filepaths){
            file.remove(filepath)
          }
          Cliniacal_dataset(tmp)
          replaceData(dataTableProxy('Cliniacal_dataset'), Cliniacal_dataset(), resetPaging=F)
          write.table(Cliniacal_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
          output$Cohort_DataBase_status <- renderText('Deleted!')
        }else{
          output$Cohort_DataBase_status <- renderText('No row selecetd!')
        }
      })
    #### Signature analysis
      # select a geneset
      output$Signature_input_selection_custom_geneset_select <- renderUI({
        req(input$Signature_input_selection=='A')
        gene_sets_names <- c()
        gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
        selectInput('Signature_input_selection_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
      })
      output$Signature_input_selection_status <- renderText({"Please choose an Input."})

      # signature score calculation
      singature_table <- eventReactive(input$Signature_start,{
        if(input$Clinical_data_select == 'None'){
          output$Signature_analysis_status <- renderText({'Please select a dataset first.'})
          return(NULL)
        }
        # when no proper input
        df_geneEx <- Clinical_gene_expression() 
        if(input$Signature_input_selection=='A'){
          if(input$Signature_input_selection_custom_geneset_select == 'None'){
            output$Signature_analysis_status <- renderText({'Please select a gene set'})
            return(NULL)
          }else{
            genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Signature_input_selection_custom_geneset_select, ]$Genes, split=', ')[[1]]
            genes <- intersect(genes, rownames(df_geneEx))
            if(length(genes)==0){
              output$Signature_analysis_status <- renderText({'None of the genes in the selected gene sets are in the dataset. \nPlease change the gene set.'})    
              return(NULL)
            }
          }
        }else{
          if(nchar(input$Signature_input_selection_text_input)==0){
            output$Signature_analysis_status <- renderText({'Please enter genes'})
            return(NULL)
          }else{
            genes <- unlist(strsplit(input$Signature_input_selection_text_input, split = "\n"))
            genes <- intersect(genes, rownames(df_geneEx))
            if(length(genes)==0){
              output$Signature_analysis_status <- renderText({'None of the inputted genes are in the dataset. \nPlease check if the gene names are correct and do not have unneccesary spaces.'})    
              return(NULL)
            }
          }
        }
        # method is not selected
        if(length(input$Signature_input_score_type)==0){
          output$Signature_analysis_status <- renderText({'Please select the Calculation method.'})
        }
        output$Signature_analysis_status <- renderText({NULL})
        gene_set <- list(selected_gene_set=genes) # gene_set <- list(selected_gene_set=c('CXCL10', 'CXCL9'))
        df_geneEx[is.na(df_geneEx)] <- 0
        method <- input$Signature_input_score_type # method='ssgsea'
        if(method=='ssGSEA'){
          signaturePar <- ssgseaParam(as.matrix(df_geneEx), gene_set)
        }else if(method == 'GSVA'){
          signaturePar <- gsvaParam(as.matrix(df_geneEx), gene_set)
        }
        signature_gsva <- gsva(signaturePar)
        signature_gsva_table <- data.frame(t(data.frame(signature_gsva)))
        signature_gsva_table$Sample <- gsub('\\.', '-', rownames(signature_gsva_table))
        signature_gsva_table <- signature_gsva_table[order(signature_gsva_table$selected_gene_set, decreasing = T),]
        signature_gsva_table <- signature_gsva_table[, c('Sample', 'selected_gene_set')]
        colnames(signature_gsva_table)[2] <- 'Signature.score'
        rownames(signature_gsva_table) <- NULL

        return(signature_gsva_table)
      })

      # show table
      output$Signature_result_table <- DT::renderDataTable({
        if(is.null(singature_table())){
          df_test <- data.frame()  
        }else{
          df_test <- singature_table()
        }
        datatable(df_test, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
      })

      # download the table
      output$Signature_result_table_download <- downloadHandler(
        filename = function(){"Signature.tsv"}, 
        content = function(fname){ write.table(singature_table(), fname, sep='\t', row.names=F, quote=F) }
      )

      # survival analysis
      output$Signature_Survival_detail <- renderText({"Please start calulating the score first."})
      output$Signature_Survival_plot <- renderPlot({
        if(is.null(singature_table())){
          return(NULL)
        }else{
          singature_table <- singature_table()
        }
        df_OS <- Clinical_surival()
        df_OS$sample <- gsub('\\.', '-', df_OS$sample)
        if(is.null(singature_table)){
          output$Signature_Survival_detail <- renderText({"Please start calulating the score first."})
          return(NULL)
        }
        output$Signature_Survival_detail <- renderText({NULL})
        Sig_scores <- singature_table[,'Signature.score']
        if(input$Signature_Survival_cutoff_method == 'A'){
          med <- median(Sig_scores)
          df_high_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] >= med, ]$Sample)
          df_low_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] < med, ]$Sample)
        }else{
          top25 <- quantile(Sig_scores, 0.75)
          bottom25 <- quantile(Sig_scores, 0.25)
          df_high_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] >= top25,]$Sample)
          df_low_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] <= bottom25,]$Sample)
        }
        if(length(df_high_sample)==0 | length(df_low_sample)==0){
          output$Signature_Survival_detail <- renderText({"The samples cannot divide into two using the selected split method."})
          return(NULL)
        }
        df_OS$group = NA
        df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
        df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
        df_OS$group <- factor(df_OS$group, levels=c('Low', 'High'))

        # survival object
        surv_obj <- Surv(time = df_OS$OS.time, event = df_OS$OS)
        km_fit <- survfit(surv_obj ~ group, data = df_OS)
        cox_model <- coxph(surv_obj ~ group, data = df_OS)
        km_data <- broom::tidy(km_fit)
        # Hazard ratio and p
        HR <- exp(cox_model$coefficients)
        p_value <- summary(cox_model)$coefficients[, 5]
        output$Signature_Survival_detail <- renderText({
          paste0('HR: ', HR, '\n', 'P-value:', p_value)
        })
        # graph
        km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 1) + 
          geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
          labs( title = 'Signature score', x = "Time", y = "Survival Probability", color = "") +
          scale_color_manual(
            values=c('group=High'=input$Signature_Survival_plot_High_colour, 'group=Low'=input$Signature_Survival_plot_Low_colour),
            labels=c(paste0('High (n=', as.character(length(df_high_sample)), ')'), paste0('Low (n=', as.character(length(df_low_sample)), ')'))
          ) + 
          scale_fill_manual(
            values=c('group=High'=input$Signature_Survival_plot_High_colour, 'group=Low'=input$Signature_Survival_plot_Low_colour),
            labels=c(paste0('High (n=', as.character(length(df_high_sample)), ')'), paste0('Low (n=', as.character(length(df_low_sample)), ')'))
          ) +
          guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Signature_Survival_plot_legend_size)) 
        p <- km_plot
        p <- p + theme(axis.text = element_text(size = input$Signature_Survival_plot_label_size))
        p <- p + theme(axis.title = element_text(size = input$Signature_Survival_plot_title_size))

        p

      }, width=reactive(input$Signature_Survival_plot_fig.width), height=reactive(input$Signature_Survival_plot_fig.height))

      ## compare subtypes
      # select group
      output$Signature_subtype_groupBy <- renderUI({ selectInput('Signature_subtype_groupBy', 'Group by', c('None'='None', colnames(Clinical_meta()))) })
      # check how many subtypes there are
      output$Signature_subtype_subtype_number <- renderText({
        if(input$Signature_subtype_groupBy =='None'){
          NULL
        }else{
          tmp <- unlist(unique(Clinical_meta()[input$Signature_subtype_groupBy]))
          tmp <- tmp[tmp!='']
          tmp <- na.omit(tmp) # length(Clinical_meta[group_by][is.na(Clinical_meta[group_by])])
          num_blanck <- length(Clinical_meta()[input$Signature_subtype_groupBy][Clinical_meta()[input$Signature_subtype_groupBy]==''])
          num_na <- length(Clinical_meta()[input$Signature_subtype_groupBy][is.na(Clinical_meta()[input$Signature_subtype_groupBy])])
          num_nd <- num_blanck + num_na
          paste0('Number of subtypes: ', length(tmp), '\nNumber of NA or no data: ', num_nd)
        }
      })

      # test 
      output$Signature_subtype_note <- renderText({"Please start calulating the score first."})
      Signature_subtype_test <- eventReactive(input$Signature_subtype_start,{
        # output$Signature_subtype_note <- renderText({"hoge"})
        if(input$Clinical_data_select == 'None'){
          # output$Expression_subtype_error_catch <- renderText({'Please select a dataset first.'})
          return(NULL)
        }
        if(is.null(singature_table())){
          # output$Signature_subtype_note <- renderText({"Please start calulating the score first."})
          output$Signature_subtype_note <- renderText({"hoge"})
          return(NULL)
        }
        singature_table <- singature_table() # head(singature_table)
        # meta, subtype
        df_meta <- Clinical_meta()
        df_meta$sample <- gsub('\\.', '-', df_meta$sample)
        group_by <- input$Signature_subtype_groupBy # group_by <- 'gender'
        if(group_by == 'None'){
          output$Signature_subtype_note <- renderText({"Please select a group to compare."})
          return(NULL)
        }
        df_meta_subtype <- df_meta[, c('sample', group_by)] # head(df_meta_subtype)
        df_meta_subtype <- df_meta_subtype[!is.na(df_meta_subtype[,group_by]),]
        df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] != '',]
        df_meta_subtype[,group_by] <- as.character(df_meta_subtype[,group_by])
        # merge
        colnames(singature_table) <- c('sample', 'score') # head(singature_table)
        df_tmp <- merge(singature_table, df_meta_subtype, by='sample') # head(df_tmp)
        df_out <- df_tmp
        if(length(unique(unlist(df_out[,group_by]))) >= 3){
          df_test_tmp <- kruskal.test(as.formula(paste('score', '~', group_by)), data=df_out) # str(df_test)
          p <- df_test_tmp$p.value
          statistic <- df_test_tmp$statistic
          output$Signature_subtype_note <- renderText({
            paste0('P-value: ', p, '\n', 'Statistic (Kruskal-Wallis): ', statistic)
          })    
          # # dunntest
          # library(FSA) #install.packages('FSA')
          # dunnTest(as.formula(paste('Expression', '~', group_by)), data=df_out_tmp, method='bonferroni')
        }else if(length(unique(unlist(df_out[,group_by]))) == 2){
          group1 <- df_out[df_out[,group_by] == unique(unlist(df_out[,group_by]))[1],]$score
          group2 <- df_out[df_out[,group_by] == unique(unlist(df_out[,group_by]))[2],]$score
          df_test_tmp <- wilcox.test(group1, group2) # str(df_test)
          p <- df_test_tmp$p.value
          statistic <- df_test_tmp$statistic
          output$Signature_subtype_note <- renderText({
            paste0('P-value: ', p, '\n', 'Statistic (Wilcoxon): ', statistic)
          })
        }else{
          output$Signature_subtype_note <- renderText({"There is no sub groups for the selected category. Please try with other categories."})
          return(NULL)
        }
        return(df_out)

      })
        
      # plot
      output$Signature_subtype_plot <- renderPlot({
          if(is.null(Signature_subtype_test())){
            return(NULL)
          }
          df_out_tmp <- Signature_subtype_test()
          group_by <- colnames(df_out_tmp)[3]
          if(input$Signature_subtype_use_single_colour){
            p <- ggplot(df_out_tmp, aes_string(x=group_by, y='score'))
          }else{
            p <- ggplot(df_out_tmp, aes_string(x=group_by, y='score', fill=group_by))
          }
          if(input$Signature_subtype_figtype == 'A'){  # boxplot
            if(input$Signature_subtype_use_single_colour){
              p <- p + geom_boxplot(fill=input$Signature_subtype_choose_single_colour)
            }else{
              p <- p + geom_boxplot(color='black')
              if(input$Signature_subtype_select_colour_pallete != 'None'){
                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
              }
            }
          }else if(input$Signature_subtype_figtype == 'B'){ # violin plot
            if(input$Signature_subtype_use_single_colour){
              p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_choose_single_colour)
            }else{
              p <- p + geom_violin(color='black',trim = FALSE)
              if(input$Signature_subtype_select_colour_pallete != 'None'){
                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
              }
            }
          }else if(input$Signature_subtype_figtype == 'C'){ # swarm plot
            p <- ggplot(df_out_tmp, aes_string(x=group_by, y='score', color=group_by))
            if(input$Signature_subtype_use_single_colour){
              p <- p + geom_beeswarm(size=input$Signature_subtype_dot.size,color=input$Signature_subtype_choose_single_colour)
            }else{
              p <- p + geom_beeswarm(size=input$Signature_subtype_dot.size)
              if(input$Signature_subtype_select_colour_pallete != 'None'){
                p <- p + scale_color_viridis_d(option=input$Signature_subtype_select_colour_pallete)
              }
            }
          }else if(input$Signature_subtype_figtype == 'D'){ # swarm plot + violin plot
            if(input$Signature_subtype_use_single_colour){
              p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_choose_single_colour)
            }else{
              p <- p + geom_violin(trim = FALSE)
              if(input$Signature_subtype_select_colour_pallete != 'None'){
                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
              }
            }
            p <- p + geom_jitter(width=0.1, height=0, size=input$Signature_subtype_dot.size)
          }
          if(input$Signature_subtype_rotate_x){
            p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
          }
          p <- p + theme(axis.text.y = element_text(size = input$Signature_subtype_XY_label.font.size), axis.text.x = element_text(size = input$Signature_subtype_XY_label.font.size))
          p <- p + theme(axis.title.y = element_text(size = input$Signature_subtype_XY_title.font.size), axis.title.x = element_text(size = input$Signature_subtype_XY_title.font.size))
          p <- p + theme(legend.position = 'none')
          p <- p + theme(plot.title = element_text(size = input$Signature_subtype_title.font.size))
          if(input$Signature_subtype_white_background){
              p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
          }
          p

      }, width=reactive(input$Signature_subtype_fig.width), height=reactive(input$Signature_subtype_fig.height))

      # histogram
        output$Signature_score_distribution_plot <- renderPlot({
          if(is.null(singature_table())){
            return(NULL)
          }else{
            singature_table <- singature_table()
          }
          df_OS <- Clinical_surival()
          df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          if(is.null(singature_table)){
            output$Signature_Survival_detail <- renderText({"Please start calulating the score first."})
            return(NULL)
          }
          output$Signature_score_distribution_status <- renderText({NULL})
          p <- ggplot(singature_table, aes_string(x=colnames(singature_table)[2]))
          p <- p + geom_histogram(fill=input$Signature_score_distribution_colour, alpha=0.6, bins=input$Signature_score_distribution_bin_num)
          p <- p + theme(axis.text = element_text(size = input$Signature_score_distribution_label_size))
          p <- p + theme(axis.title = element_text(size = input$Signature_score_distribution_title_size))
          p <- p + theme(plot.title = element_text(size = input$Signature_score_distribution_graphtitle_size))
          if(input$Signature_score_distribution_white_background){
            p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
          }
          p
        }, width=reactive(input$Signature_score_distributionfig.width), height=reactive(input$Signature_score_distribution_fig.height))
      ###

    #### Deconvolution
      # do deconvolution
      library(MCPcounter)
      library(xCell)
      deconv_table <- reactive({NULL})
      output$Deconvodution_status <- renderText({"Please select the dataset and the deconvolution method, and click 'Start deconvolution'."})
      deconv_table <- eventReactive(input$Deconvodution_start,{
        if(input$Clinical_data_select == 'None'){
          output$Deconvodution_status <- renderText({'Please select a dataset first.'})
          return(NULL)
        }
        if(length(input$Deconvodution_tool_select)==0){
          output$Deconvodution_status <- renderText({'Please select the method.'})
          return(NULL)
        }
        output$Deconvodution_status <- renderText({NULL})
        df_geneEx <-  Clinical_gene_expression() 
        if(input$Deconvodution_tool_select == 'MCPcounter'){
          deconv_table <-  MCPcounter.estimate(df_geneEx,featuresType="HUGO_symbols")
        }else if(input$Deconvodution_tool_select == 'xCell'){
          deconv_table <- xCellAnalysis(df_geneEx) # deconv_table[1:3, 1:3]
        }
        colnames(deconv_table) <- gsub('\\.', '-', colnames(deconv_table))
        output$Deconvodution_results <- renderDataTable({
          datatable(deconv_table, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        })
        return(deconv_table)
      })

      # when changing the cohort, data table is reset
      observeEvent(input$Clinical_data_select, {
        # deconv_table <- reactive({NULL})
        output$Deconvodution_status <- renderText({"Please select the dataset and the deconvolution method, and click 'Start deconvolution'."})
        output$Deconvodution_results <-  renderDataTable({NULL})
      }, ignoreInit=TRUE)
    

      # show table
      # output$Deconvodution_results <- renderDataTable({
      #   if(is.null(deconv_table())){
      #     df_test <- data.frame()  
      #   }else{
      #     df_test <- deconv_table()
      #   }
      #   datatable(df_test, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
      # })

      # download the table
      output$Deconvodution_result_download <- downloadHandler(
        filename = function(){"deconvolution.tsv"}, 
        content = function(fname){ write.table(deconv_table(), fname, sep='\t', row.names=F, quote=F) }
      )

      # gene correlation
      # when using a custom gene set
      output$Deconvodution_Gene_correlation_from_custom_geneset_select <- renderUI({
        gene_sets_names <- c()
        gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
        selectInput('Deconvodution_Gene_correlation_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
      })
      outputOptions(output, "Deconvodution_Gene_correlation_from_custom_geneset_select", suspendWhenHidden=FALSE)

      # select the cell type to compare
      output$Deconvodution_Gene_correlation_select_celltype <- renderUI({
        gene_sets_names <- c()
        tryCatch({
          gene_sets_names <- c(gene_sets_names, rownames(deconv_table()))  
          selectInput('Deconvodution_Gene_correlation_select_celltype', 'Select a Cell type',  c('None'='None', gene_sets_names))  
        },error=function(e){
          selectInput('Deconvodution_Gene_correlation_select_celltype', 'Select a Cell type',  c('None'='None'))  
        })
      })
      outputOptions(output, "Deconvodution_Gene_correlation_select_celltype", suspendWhenHidden=FALSE)

      # calculate p and r
      output$Deconvodution_Gene_correlation_status <- renderText({"Please do deconvolution first."})
      Deconvodution_gene_correlation <- eventReactive(input$Deconvodution_Gene_correlation_start, {
        if(input$Deconvodution_Gene_correlation_select_celltype == 'None'){
          output$Deconvodution_Gene_correlation_status <- renderText({"Please choose the cell type"})
          return(NULL)
        }
        if(input$Deconvodution_Gene_correlation_from_custom_geneset){
          if(input$Deconvodution_Gene_correlation_from_custom_geneset_select == 'None'){
            output$Deconvodution_Gene_correlation_status <- renderText({"Please select a custom gene set."})
            return(NULL)
          }
          genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Deconvodution_Gene_correlation_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
        }else{
          if(nchar(input$Deconvodution_Gene_correlation_genes)== 0 ){
            output$Deconvodution_Gene_correlation_status <- renderText({"Please enter genes"})
            return(NULL)
          }
          genes <- unlist(strsplit(input$Deconvodution_Gene_correlation_genes, '\n'))
        }
        # Cell abundunce
        if(is.null(deconv_table())){
          output$Deconvodution_Gene_correlation_status <- renderText({"Please do deconvolution first."})
          return(NULL)
        }
        deconv_table <- deconv_table() # deconv_table[1:3, 1:3]
        cell_type <- input$Deconvodution_Gene_correlation_select_celltype # cell_type <- 'aDC'
        deconv_table_cell <- deconv_table[cell_type,]
        df_geneEx <- Clinical_gene_expression() # genes <- c('CXCL10', 'CXCL9')
        sample_deconv <- gsub('\\.', '-', colnames(deconv_table))
        sample_geneEx <- gsub('\\.', '-', colnames(df_geneEx))
        if(length(intersect(sample_deconv, sample_geneEx))==0){
          output$Deconvodution_Gene_correlation_status <- renderText({'Please start from deconvolution.'})
          return(NULL)
        }
        genes <- intersect(genes, rownames(df_geneEx))
        if(length(genes) == 0){
          output$Deconvodution_Gene_correlation_status <- renderText({'The inputted gene is not in the dataset.\nPlease make sure the gene name is correct and does not include unnecessary spaces.'})
          return(NULL)
        }
        df_cor_out <- data.frame(Gene=c(), r=c(), p=c())
        if(length(input$Deconvodution_Gene_correlation_method)==0){
          output$Deconvodution_Gene_correlation_status <- renderText({'Please select the Method for correlation.'})
          return(NULL)
        }
        for ( gene2 in genes){ # gene2 = genes[1]
          gene_ex <- unlist(df_geneEx[gene2,])
          # output$Deconvodution_Gene_correlation_status <- renderText({deconv_table_cell})
          c <- cor.test(deconv_table_cell, gene_ex, method=input$Deconvodution_Gene_correlation_method)
          r <- c$estimate
          p <- c$p.value
          df_cor_tmp <- data.frame(Gene=gene2, r=r, p=p)
          df_cor_out <- rbind(df_cor_out, df_cor_tmp)
        }
        df_cor_out <- df_cor_out[order(df_cor_out$p, decreasing=F),]
        df_cor_out$cell_type <- cell_type
        rownames(df_cor_out) <- NULL
        return(df_cor_out)
      })

      # show in table
      output$Deconvodution_Gene_correlation_table <- DT::renderDataTable({
        datatable(Deconvodution_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
      })

      # download
      output$Deconvodution_Gene_correlation_table_download <- downloadHandler(
        filename = function(){"deconvoluted_Cell_type_correlation.tsv"}, 
        content = function(fname){ write.table(Deconvodution_gene_correlation(), fname, sep='\t', row.names=F, quote=F) }
      )

      # plot scatter
      output$Deconvodution_Gene_correlation_plot <- renderPlot({
        if(is.null(Deconvodution_gene_correlation())){
          # output$Gene_correlation_error_catch <- renderText({'Please start the analysis.'})
          return(NULL)
        }else{
          if(length(input$Deconvodution_Gene_correlation_table_rows_selected)>0){
            output$Deconvodution_Gene_correlation_status <- renderText({NULL})
            cell_type <- Deconvodution_gene_correlation()$cell_type[1]
            Gene2 <- Deconvodution_gene_correlation()[input$Deconvodution_Gene_correlation_table_rows_selected,]$Gene
            df_geneEx <- Clinical_gene_expression()
            deconv_table <- deconv_table() # deconv_table[1:3, 1:3]
            df_deconv_table_cell <- data.frame(deconv_table[cell_type,])
            colnames(df_deconv_table_cell) <- 'cell_type' # head(df_deconv_table_cell)
            df_deconv_table_cell$sample <- gsub('\\.', '-', rownames(df_deconv_table_cell))
            df_geneEx_selected <- data.frame(unlist(df_geneEx[Gene2, ])) # Gene2="CXCL10"
            colnames(df_geneEx_selected) <- 'Gene2' # head(df_geneEx_selected )
            df_geneEx_selected$sample <- gsub('\\.', '-', rownames(df_geneEx_selected))
            scatter_data <- merge(df_deconv_table_cell, df_geneEx_selected, by='sample') # head(df_out)
            p <- ggplot(scatter_data, aes(x=Gene2, y=cell_type))
            p <- p + geom_point(size=3, color=input$Deconvodution_Gene_correlation_colour, alpha=0.7)
            if(input$Deconvodution_Gene_correlation_show_correlation_line){
              p <- p + geom_smooth(method='lm', se=TRUE, color=input$Deconvodution_Gene_correlation_colour)
            }
            p <- p + labs(x=Gene2, y=cell_type)
            p <- p + theme(axis.text = element_text(size = input$Deconvodution_Gene_correlation_label_size))
            p <- p + theme(axis.title = element_text(size = input$Deconvodution_Gene_correlation_title_size))
            if(input$Deconvodution_Gene_correlation_white_background){
              p <- p + theme(panel.background = element_rect(fill="white", color="darkgrey"), panel.grid.major = element_line(color="lightgrey"), panel.grid.minor = element_line(color="lightgrey"))
            }
            p
          }else{
            output$Deconvodution_Gene_correlation_status <- renderText('Please select a gene from the table.')
            return(NULL)
          }
        }
        p
      }, width=reactive(input$Deconvodution_Gene_correlation_fig.width), height=reactive(input$Deconvodution_Gene_correlation_fig.height))

                                  # box(width=12, title='Graph options', collapsible = TRUE, collapsed = T,
                                  #   fluidRow(
                                  #     column(4,sliderInput('Deconvodution_Gene_correlation_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                  #     column(4,sliderInput('Deconvodution_Gene_correlation_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                  #   ),
                                  #   fluidRow(
                                  #     column(4,sliderInput('Deconvodution_Gene_correlation_label_size', 'X/Y label size', min=10, max=40, value=20, step=1)),
                                  #     column(4,sliderInput('Deconvodution_Gene_correlation_title_size', 'X/Y title size', min=10, max=40, value=20, step=1)),
                                  #   ),
                                  #   fluidRow(
                                  #     column(3, colourInput('Deconvodution_Gene_correlation_colour', 'Colour of the dots:', value='#ec00ec')),
                                  #     column(2, checkboxInput('Deconvodution_Gene_correlation_show_correlation_line', 'Show the correlation line')),
                                  #     column(2, checkboxInput('Deconvodution_Gene_correlation_white_background', 'Use white background', value=FALSE))
                                  #   )
                                  # )


  ####

  ### Tools 
    #### human to mouse, mouse to human
      # conversion table
        # human_mouse_biomart_data <- read.table('data/biomart_comparison_chart.tsv', sep='\t',header=T)
      human_mouse_convert_data <- eventReactive(input$human_mouse_convert_start,{
        if(nchar(input$human_mouse_convert_input_gene) == 0){
          output$human_mouse_convert_result <- renderText({'Please enter genes.'})
          return(NULL)
        }
        input_genes <- unlist(strsplit(input$human_mouse_convert_input_gene, '\n')) # input_genes <- c('CXCL10', 'CXCL9', 'hoge')
        converted_df <- data.frame(input=input_genes)
        if(is.null(input$human_mouse_convert_direction)){
          output$human_mouse_convert_result <- renderText({'Please select the conversion direction.'})
          return(NULL)
        }
        if(input$human_mouse_convert_direction == 'A'){
          input_column <- switch(input$human_mouse_convert_input_type,
            "A" = 'Mouse.gene.name',
            "B" = 'Mouse.gene.stable.ID',
            "C" = 'Mouse.gene.stable.ID.version'
          )
          output_column <- switch(input$human_mouse_convert_output_type,
            "A" = 'Human.Gene.name',
            "B" = 'Human.Gene.stable.ID',
            "C" = 'Human.Gene.stable.ID.version'
          )
          colnames(converted_df) <- input_column
          converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
        }else if(input$human_mouse_convert_direction == 'B'){
          input_column <- switch(input$human_mouse_convert_input_type,
            "A" = 'Human.Gene.name',
            "B" = 'Human.Gene.stable.ID',
            "C" = 'Human.Gene.stable.ID.version'
          )
          output_column <- switch(input$human_mouse_convert_output_type,
            "A" = 'Mouse.gene.name',
            "B" = 'Mouse.gene.stable.ID',
            "C" = 'Mouse.gene.stable.ID.version'
          )
          colnames(converted_df) <- input_column
          converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
        }
        # show a gene names list
        output$human_mouse_convert_result <- renderText({
          converted_genes <- converted[,output_column]
          if(length(converted_genes[!is.na(converted_genes)]) == 0){
            "Non of the input genes were able to be converted. \nPlease check the gene names are correct and do not include unnecessary spaces."
          }else{
            paste(na.omit(converted[,output_column]), collapse = "\n")
          }
        })
        return(converted)
      })
      
      output$human_mouse_convert_table <- renderDataTable({
        datatable( human_mouse_convert_data(), options = list(scrollX = TRUE, pageLength = 10 )) 
      })


    ### convert Ensembl to Gene symbol
      # conversion table
      Gene_Ensemble_convert_data <- eventReactive(input$Gene_Ensembl_convert_start,{
        if(nchar(input$Gene_Ensembl_input_gene) == 0){
          output$Gene_Ensembl_convert_result <- renderText({'Please enter genes.'})
          return(NULL)
        }
        input_genes <- unlist(strsplit(input$Gene_Ensembl_input_gene, '\n')) # input_genes <- c('CXCL10', 'CXCL9', 'hoge')
        converted_df <- data.frame(input=input_genes)
        if(input$Gene_Ensembl_spieces == 'A'){
          input_column <- switch(input$Gene_Ensembl_input_type,
            "A" = 'Human.Gene.name',
            "B" = 'Human.Gene.stable.ID',
            "C" = 'Human.Gene.stable.ID.version'
          )
          output_column <- switch(input$Gene_Ensembl_output_type,
            "A" = 'Human.Gene.name',
            "B" = 'Human.Gene.stable.ID',
            "C" = 'Human.Gene.stable.ID.version'
          )
          colnames(converted_df) <- input_column
          converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
        }else{
          input_column <- switch(input$Gene_Ensembl_input_type,
            "A" = 'Mouse.gene.name',
            "B" = 'Mouse.gene.stable.ID',
            "C" = 'Mouse.gene.stable.ID.version'
          )
          output_column <- switch(input$Gene_Ensembl_output_type,
            "A" = 'Mouse.gene.name',
            "B" = 'Mouse.gene.stable.ID',
            "C" = 'Mouse.gene.stable.ID.version'
          )
          colnames(converted_df) <- input_column
          converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
        }
        # show a gene names list
        output$Gene_Ensembl_convert_result <- renderText({
          converted_genes <- converted[,output_column]
          if(length(converted_genes[!is.na(converted_genes)]) == 0){
            "Non of the input genes were able to be converted. \nPlease check the gene names are correct and do not include unnecessary spaces."
          }else{
            paste(na.omit(converted[,output_column]), collapse = "\n")
          }
        })
        return(converted)
      })
      
      output$Gene_Ensembl_convert_table <- renderDataTable({
        datatable( Gene_Ensemble_convert_data(), options = list(scrollX = TRUE, pageLength = 10 )) 
      })
    
    ### Find the genomic loci

      Gene_coords_GRch38 <- read.table('data/Gene_coords_GRch38.tsv', sep='\t', header=T) # head(Gene_coords_GRch38)

      observeEvent(input$Find_genome_loci_start,{
        if(length(input$Find_genome_loci_direction) == 0){
          output$Find_genome_loci_table_gene_names <- renderText({'Please choose the method.'})
          return(NULL)
        }
        if(input$Find_genome_loci_direction == 'A'){
          if(nchar(input$Find_genome_loci_input) == 0){
            output$Find_genome_loci_table_gene_names <- renderText({'Please enter gene names'})
            return(NULL)
          }
          genes <- unlist(strsplit(input$Find_genome_loci_input, '\n')) # genes <- c('CXCL10', 'CXCL9')
          genes <- intersect(genes, Gene_coords_GRch38$gene_name)
          if(length(genes)==0){
            output$Find_genome_loci_table_gene_names <- renderText({'None of the inputted genes are found. \nPlease make sure that the gene names are correct and do not have unnecessary spaces.'})
            return(NULL) 
          }
          Gene_coords_GRch38_focus <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name %in% genes,]
          coord <- paste0(Gene_coords_GRch38_focus$chr, ':', Gene_coords_GRch38_focus$start, '-',  Gene_coords_GRch38_focus$end)
          output$Find_genome_loci_table_gene_names <- renderText({ paste(coord, collapse='\n') })
          output$Find_genome_loci_table <- renderDataTable({
            datatable( Gene_coords_GRch38_focus, options = list(scrollX = TRUE, pageLength = 10 )) 
          })
        }
        if(input$Find_genome_loci_direction == 'B'){
          coords <- unlist(strsplit(input$Find_genome_loci_input, '\n')) # coords <- c('chr4:76021118-76023497', 'chr10:8045378-8075198')
          Gene_coords_GRch38_focus <- data.frame('chr'=c(), 'start'=c(), 'end'=c(), 'strand'=c(), 'gene_id'=c(), 'gene_name'=c())
          for (coord in coords){
            # coord = 'chr4:76021118-76023497'
            chr <- strsplit(coord, split=':')[[1]][1]
            start_pos <- as.numeric(strsplit(strsplit(coord, split=':')[[1]][2], split='-')[[1]][1])
            end_pos <- as.numeric(strsplit(strsplit(coord, split=':')[[1]][2], split='-')[[1]][2])
            Gene_coords_GRch38_focus_tmp <- Gene_coords_GRch38[Gene_coords_GRch38$chr == chr,]
            Gene_coords_GRch38_focus_tmp <- Gene_coords_GRch38_focus_tmp[as.numeric(Gene_coords_GRch38_focus_tmp$end) >= as.numeric(start_pos),]
            Gene_coords_GRch38_focus_tmp <- Gene_coords_GRch38_focus_tmp[Gene_coords_GRch38_focus_tmp$start <= end_pos,]
            Gene_coords_GRch38_focus <- rbind(Gene_coords_GRch38_focus, Gene_coords_GRch38_focus_tmp)
          }
          if(dim(Gene_coords_GRch38_focus)[1]==0){
            output$Find_genome_loci_table_gene_names <- renderText({'No genes were found in the specified location. \nPlease make sure the formats are correct and do not include unnecessary spaces. \n(Ex. chr1:76021118-76023497)'})
            return(NULL) 
          }
          genes <- Gene_coords_GRch38_focus$gene_name
          output$Find_genome_loci_table_gene_names <- renderText({ paste(genes, collapse='\n') })
          output$Find_genome_loci_table <- renderDataTable({
            datatable( Gene_coords_GRch38_focus, options = list(scrollX = TRUE, pageLength = 10 )) 
          })
        }
      })


  ###

  ### Wiki-document ##########################
    Introduction_md <- reactiveFileReader(1000, session, "wiki/Introduction.md", readLines)
    output$Introduction_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Introduction_md(), fragment.only = TRUE))
    })

    Database_md <- reactiveFileReader(1000, session, "wiki/Database.md", readLines)
    output$Database_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Database_md(), fragment.only = TRUE))
    })

    Data_Overview_md <- reactiveFileReader(1000, session, "wiki/Data_Overview.md", readLines)
    output$Data_Overview_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Data_Overview_md(), fragment.only = TRUE))
    })

    Gene_set_md <- reactiveFileReader(1000, session, "wiki/Gene_set.md", readLines)
    output$Gene_set_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Gene_set_md(), fragment.only = TRUE))
    })

    Compare_acorss_datasets_md <- reactiveFileReader(1000, session, "wiki/Compare_acorss_datasets.md", readLines)
    output$Compare_acorss_datasets_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Compare_acorss_datasets_md(), fragment.only = TRUE))
    })

    Cilinical_data_md <- reactiveFileReader(1000, session, "wiki/Cilinical_data.md", readLines)
    output$Cilinical_data_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Cilinical_data_md(), fragment.only = TRUE))
    })

    integrate_two_md <- reactiveFileReader(1000, session, "wiki/integrate_two.md", readLines)
    output$integrate_two_md <- renderUI({
        HTML(markdown::markdownToHTML(text = integrate_two_md(), fragment.only = TRUE))
    })

    scRNA_md <- reactiveFileReader(1000, session, "wiki/scRNA.md", readLines)
    output$scRNA_md <- renderUI({
        HTML(markdown::markdownToHTML(text = scRNA_md(), fragment.only = TRUE))
    })

    igv_md <- reactiveFileReader(1000, session, "wiki/igv.md", readLines)
    output$igv_md <- renderUI({
        HTML(markdown::markdownToHTML(text = igv_md(), fragment.only = TRUE))
    })

    Tools_md <- reactiveFileReader(1000, session, "wiki/Tools.md", readLines)
    output$Tools_md <- renderUI({
        HTML(markdown::markdownToHTML(text = Tools_md(), fragment.only = TRUE))
    })

    FAQ_md <- reactiveFileReader(1000, session, "wiki/FAQ.md", readLines)
    output$FAQ_md <- renderUI({
        HTML(markdown::markdownToHTML(text = FAQ_md(), fragment.only = TRUE))
    })

}



# Run the app
shinyApp(ui, server)




