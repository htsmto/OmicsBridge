# if 00_Clinical_dataset and 00_Expression_data_all directory is not in the working, stop
  if (!dir.exists('00_Clinical_dataset') || !dir.exists('00_Expression_data_all')) {
    stop("Please make sure that the directories '00_Clinical_dataset' and '00_Expression_data_all' are downloaded and deployed in the working directory.")
  }


#### Load packages and setting ####
  options(install.packages.check.source = "no")
  options(ask = FALSE)
  options(install.packages.check.source = "no")
  options(ask = FALSE)
  if(!requireNamespace('openssl', quietly = TRUE)) { install.packages('openssl', dependencies = FALSE) }
  suppressMessages(library(openssl))
  if(!requireNamespace('V8', quietly = TRUE)) { install.packages('V8', dependencies = FALSE) }
  suppressMessages(library(V8))
  if(!requireNamespace('htmlwidgets', quietly = TRUE)) { install.packages('htmlwidgets', dependencies = FALSE) }
  suppressMessages(library(htmlwidgets))
  if(!requireNamespace('shiny', quietly = TRUE)) { install.packages('shiny', dependencies = FALSE) }
  suppressMessages(library(shiny))
  if(!requireNamespace('shinyjs', quietly = TRUE)) { install.packages('shinyjs', dependencies = FALSE) }
  suppressMessages(library(shinyjs))
  if(!requireNamespace('shinydashboard', quietly = TRUE)) { install.packages('shinydashboard', dependencies = FALSE) }
  suppressMessages(library(shinydashboard))
  if(!requireNamespace('ggplot2', quietly = TRUE)) { install.packages('ggplot2', dependencies = FALSE) }
  suppressMessages(library(ggplot2))
  if(!requireNamespace('ggbeeswarm', quietly = TRUE)) { install.packages('ggbeeswarm', dependencies = FALSE) }
  suppressMessages(library(ggbeeswarm))
  if(!requireNamespace('patchwork', quietly = TRUE)) { install.packages('patchwork', dependencies = FALSE) }
  suppressMessages(library(patchwork))
  if(!requireNamespace('igraph', quietly = TRUE)) { install.packages('igraph', dependencies = FALSE) }
  suppressMessages(library(igraph))
  if(!requireNamespace('tidyr', quietly = TRUE)) { install.packages('tidyr', dependencies = FALSE) }
  suppressMessages(library(tidyr))
  if(!requireNamespace('dplyr', quietly = TRUE)) { install.packages('dplyr', dependencies = FALSE) }
  suppressMessages(library(dplyr))
  if(!requireNamespace('DT', quietly = TRUE)) { install.packages('DT', dependencies = FALSE) }
  suppressMessages(library(DT))
  if(!requireNamespace('ggrepel', quietly = TRUE)) { install.packages('ggrepel', dependencies = FALSE) }
  suppressMessages(library(ggrepel)) 
  if (!requireNamespace("GSEABase", quietly = TRUE)) { BiocManager::install("GSEABase", ask = FALSE) }
  suppressMessages(library(GSEABase)) 
  if (!requireNamespace("GSVA", quietly = TRUE)) { BiocManager::install("GSVA", ask = FALSE) }
  suppressMessages(library(GSVA))
  if (!requireNamespace("fgsea", quietly = TRUE)) { BiocManager::install("fgsea", ask = FALSE) }
  suppressMessages(library(fgsea))
  if (!requireNamespace("tibble", quietly = TRUE)) { install.packages("tibble", dependencies = FALSE) }
  suppressMessages(library(tibble))
  if (!requireNamespace("clusterProfiler", quietly = TRUE)) { BiocManager::install("clusterProfiler", ask = FALSE) }
  suppressMessages(library(clusterProfiler)) 
  if (!requireNamespace("org.Hs.eg.db", quietly = TRUE)) { BiocManager::install("org.Hs.eg.db", ask = FALSE) }
  suppressMessages(library(org.Hs.eg.db))
  if (!requireNamespace("org.Mm.eg.db", quietly = TRUE)) { BiocManager::install("org.Mm.eg.db", ask = FALSE) }
  suppressMessages(library(org.Mm.eg.db))
  if (!requireNamespace("forcats", quietly = TRUE)) { install.packages("forcats", dependencies = FALSE) }
  suppressMessages(library(forcats))
  if (!requireNamespace("igvShiny", quietly = TRUE)) { BiocManager::install("igvShiny", ask = FALSE) }
  suppressMessages(library(igvShiny))
  if (!requireNamespace("colourpicker", quietly = TRUE)) { install.packages("colourpicker", dependencies = FALSE) }
  suppressMessages(library(colourpicker))
  if (!requireNamespace("stringr", quietly = TRUE)) { install.packages("stringr", dependencies = FALSE) }
  suppressMessages(library(stringr))
  if(!requireNamespace("Cairo", quietly = TRUE)) { install.packages("Cairo", dependencies = FALSE) }
  suppressMessages(library(Cairo))
  if (!requireNamespace("shinyWidgets", quietly = TRUE)) { install.packages("shinyWidgets", dependencies = FALSE) }
  suppressMessages(library(shinyWidgets))
  if (!requireNamespace("shinycssloaders", quietly = TRUE)) { install.packages("shinycssloaders", dependencies = FALSE) }
  suppressMessages(library(shinycssloaders))
  if (!requireNamespace("ggraph", quietly = TRUE)) { install.packages("ggraph", dependencies = FALSE) }
  suppressMessages(library(ggraph))
  if (!requireNamespace("visNetwork", quietly = TRUE)) { install.packages("visNetwork", dependencies = FALSE) }
  suppressMessages(library(visNetwork))
  if(!requireNamespace("MCPcounter", quietly = TRUE)) { devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source", force = TRUE, upgrade = "never") }
  if(!requireNamespace("xCell", quietly = TRUE)) { devtools::install_github('dviraran/xCell',upgrade = "never") }

  options(shiny.maxRequestSize = 10000*1024^2)
  options(shiny.usecairo=TRUE)
  options(scipen = 10)
  set.seed(123)
  options(scipen = 10)
  set.seed(123)
  net <- readRDS('data/OmnipathR_net.rds')
  colour_pallets <- c('viridis', 'magma', 'plasma', 'inferno', 'cividis')
  human_mouse_biomart_data <- read.table('data/biomart_comparison_chart.tsv', sep='\t',header=T,check.names = FALSE)
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
        sidebarMenu(id='sidebar',
          menuItem("Home", tabName='home', icon=icon('home')),
          menuItem("Database and Data Upload", tabName='Database', icon=icon('table')),
          menuItem("Data Overview", tabName='Data_Overview', icon=icon('chart-bar')),
          menuItem("Gene sets", tabName='Original_geneset', icon=icon('chart-bar')),
          menuItem("Compare across datasets", tabName='Compare_across_datasets', icon=icon('chart-bar')),
          menuItem("Integrate two data", tabName='Integrate_two_dataset', icon=icon('chart-bar')),
          menuItem("Clinical data", tabName='Clinical_dataset', icon=icon('chart-bar')),
          menuItem("scRNA", tabName='scRNA', icon=icon('chart-bar')),
          menuItem("Epigenome Visualisation", tabName='igv', icon=icon('chart-bar')),
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
          .dropdown-menu {
            background-color: #ebffee;  /* 背景色をオレンジ色に変更 */
            border: 2px solid #00cb1e;  /* オレンジ色の実線ボーダーを追加 */
            border-radius: 5px;         /* 角を丸く */
          }
          #filterin_dropdown .dropdown-menu {
            background-color: #d4effc !important;
            border: 2px solid #52bef3 !important;
            border-radius: 5px;
          }
          #help .dropdown-menu {
            background-color: #fcecd4 !important;
            border: 2px solid #f7a62d !important;
            border-radius: 5px;
          }
        "))),
        tags$script(HTML("
          $(document).ready(function () {
            var $body = $('body');
            var $sidebar = $('.main-sidebar');
            var $toggle = $('.sidebar-toggle');

            // Expand sidebar on hover over the toggle or sidebar
            $toggle.add($sidebar).on('mouseenter', function () {
              if ($body.hasClass('sidebar-collapse')) {
                $body.removeClass('sidebar-collapse').addClass('sidebar-expanded-on-hover');
              }
            });

            // Collapse sidebar on mouse leave
            $sidebar.on('mouseleave', function () {
              if ($body.hasClass('sidebar-expanded-on-hover')) {
                $body.removeClass('sidebar-expanded-on-hover').addClass('sidebar-collapse');
              }
            });

            // Also toggle manually on MENU click
            $toggle.on('click', function () {
              $body.toggleClass('sidebar-collapse');
            });
          });
        ")),
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
                  🔹 Interactive Visualisations & Quick Analysis – Adjust thresholds, filter data, and perform GO analysis or GSEA—no coding required. <br>
                  🔹 Our platform also functions as a centralised database, ensuring stress-free access to your datasets at any time.
                </p>
                <br>
                <h2 style='text-align: center; font-family: Helvetica, Arial, serif !important; font-size: 26px;'><u><b>
                  Installing OmicsDBridge to your local PC
                </b></u></h2>
                <p style='text-align: center; font-family: Helvetica, Arial, serif; font-size: 22px;'>
                  The source code and installation guide is available at <a href='https://github.com/Immune-Regulation-in-Cancer/OmicsBridge' target='_blank' rel='noopener noreferrer'><b>this github page</b></a>. <br>
                  Please note that the data you upload to this website will be deleted once you leave the session. Please install and set up OmicsBridge to your local PC to use the full power of our interface. 
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
              h2(' Database and Data Upload'),
              ## Data Table ##
                box(title='List of the datasets', width=12, status='primary', solidHeader = TRUE,
                  fluidRow(
                    column(3, htmlOutput("Seuqenced_by_filter")), 
                    column(3, htmlOutput("Experiment_filter")), 
                    column(3, htmlOutput("Data_type_filter"))
                  ),
                  fluidRow(column(12, DT::dataTableOutput("DataBaseTable") )),
                  fluidRow(
                    column(2, actionButton('save_dt', 'Save changes', style="color: #ffffff; background-color: #bc2929; border-color: #e130f9")), 
                    column(2, actionButton('delete_row', 'Delete selected data', style="color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")), 
                    column(7, verbatimTextOutput('status')) 
                  )
                ),
              ## Data Upload ##
                box(width=12,  collapsible=TRUE, title='Data upload',status='danger', solidHeader = TRUE,
                  fluidRow( 
                    column(12, h4(strong('1. Upload a file'))),
                    column(5, fileInput("upload_file", "")),
                    column(6, h4('')),
                    column(1, 
                      div(id='help',
                        dropdownButton( 
                          fluidRow(
                            column(12, h4(strong("Data upload quick guide"))),
                            column(12, helpText(strong("- Make sure that the column name containing gene names is set 'id'."))),
                            column(12, helpText("- The boxes with * are mandatory.")),
                            column(12, helpText("- Avoid special characters; use only alphabets, numbers, underscores and dots.")),
                            column(12, helpText("- Dataset name must be unique.")),
                            column(12, helpText("- In case uploading a count data, it is recommended that the columns are set to Sample_Rep#. See wiki for more information.")),
                          ), circle = TRUE, status = "danger", icon = icon("question"), width = "900px",  tooltip = tooltipOptions(title = "Help"), right = TRUE
                        ),
                      ) 
                    )
                  ),
                  fluidRow( 
                    column(12, h4(strong("2. Fill in the dataset information"))), 
                    column(4, textInput("upload_dataset_name", HTML("Dataset name * <br/> Ex.) WT vs KO in Cell A"))), 
                    column(4, textInput("upload_Experiment", HTML("Experiment name * <br/> Ex.) Gene A KO RNAseq"))), 
                    column(4, textInput("upload_data_from", HTML("Data from * <br/> Ex.) Public data, Student A") )), 
                    column(4, 
                      # textInput("upload_data_type", HTML("Data type * <br/> Ex.) Count data, DEG data, scRNA"))
                      fluidRow(
                        column(12, htmlOutput("upload_data_type_select")),
                        column(12, uiOutput("upload_data_type")),
                      )
                    ), 
                    column(4, textInput("upload_cell_line", HTML("Cell line, Data source <br/> Ex.) THP1, PBMC"))), 
                    column(4, textInput("upload_when", HTML("When <br/> Ex.) 2025-01"))) 
                  ),
                  fluidRow( column(6, selectInput('upload_Data_Class', HTML('Data Class * <br/> Please choose one.'), c('A: Count data/Expression matrix'='A', 'B: Comparison data (Any table contain log fold change velues)'='B', 'C: single cell RNA'='C', 'D: bed/narrowPeak file from ATAC/ChIP/CUT&RUN etc'='D', 'E: bigwig file'='E' ), selected='B')), 
                    conditionalPanel(
                      condition = 'input.upload_Data_Class=="B"',
                      column(3, textInput("upload_Control_group", HTML("Control group name <br/> Ex.) Untreated, WT"))), 
                      column(3, textInput("upload_Treatment_group", HTML("Treatment group name <br/> Ex.) Treated, KO")))
                    ),
                    conditionalPanel(
                      condition = 'input.upload_Data_Class=="A"',
                      column(6, h5('')),
                      column(4, h5(span('\nIn case of uoloading a count data, please make sure that the columns are set to "SampleName_Rep#". See wiki for more information', style="color: red;"))) ,
                    )
                  ),
                  fluidRow( column(6, textAreaInput("upload_description", "Description")) ),
                  fluidRow( 
                    column(12, h4('')),
                    column(12, h4(strong("3. Click the button below"))), 
                    column(3, actionButton('upload_data', 'Add to the dataset',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")), 
                    column(9, verbatimTextOutput('status_upload'))
                  ),
                  fluidRow(
                    column(12, h4()),
                    column(12, h4('Preview:')),
                    column(9, verbatimTextOutput('upload_data_preview_status')),
                    column(12, dataTableOutput("upload_data_preview"))
                  )
                )
              ##
          ),
        #### Data_Overview ####
          tabItem( tabName='Data_Overview',
            h2(' Data Overview'),
            ##### Data selection #####
              box(width=12, collapsible=TRUE, title=strong('Dataset Selection'), status = "info", solidHeader = TRUE,
                fluidRow(
                  column(7, 
                    fluidRow(
                      column(12, htmlOutput("Dataset_select")),
                      column(12, 
                        div(id='filterin_dropdown',
                          dropdownButton( 
                            fluidRow(
                              column(12, h4(strong("Dataset filtering"))),
                              # column(12, helpText("Please filter the dataset here.")),
                              column(3, htmlOutput("Seuqenced_by")), column(5, htmlOutput("Experiments")), column(4, htmlOutput("Data_type")) 
                            ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "1300px",  tooltip = tooltipOptions(title = "Dataset filtering")
                          ),
                        ) 
                      )
                    )
                  ),
                  column(5, 
                    fluidRow(
                      column(12, h5(strong('Dataset detail:'))),
                      column(12, withSpinner(verbatimTextOutput('Dataset_detail'), type=5, color='#0dc5c1') ),
                    )
                  )
                )
              ),
            ##### Plot #####
              box(width=12, title=strong('Overview and Analysis'), status = "primary", solidHeader = TRUE,
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
                        tabPanel(strong("Data Table"), h4(''), 
                          box(width=12, status='warning', title=strong('Data table'), collapsible=TRUE, 
                            withSpinner(DT::dataTableOutput("Count_data_DataTable"), type=5, color='#0dc5c1')
                          ),
                        ),
                      ####### swarm plot #######  
                        tabPanel(strong("Swarm plot"), 
                          h4(''),
                          fluidRow(
                            column(width = 4,
                              box(status='info', width=12, title=strong('Inputs'),collapsible=TRUE,
                                fluidRow(
                                  column(12, textAreaInput("target_gene_for_RNA", "Enter gene names")),
                                  column(12, materialSwitch('target_gene_for_RNA_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                  conditionalPanel(
                                    condition = "input.target_gene_for_RNA_from_custom_geneset == true",
                                    column(12, htmlOutput('target_gene_for_RNA_from_custom_geneset_select'))
                                  ),
                                  column(12, verbatimTextOutput('Gene_ex_swarm_status_target_gene_for_RNA_table') ),
                                  column(12, h4('') ),
                                  column(12, h4('Choose gene(s) from the table blow:') ),
                                  column(12, dataTableOutput("target_gene_for_RNA_table") ),
                                )
                              ),
                              box(title=strong('Expression scores'),collapsible=TRUE, status='warning', width=12,
                                fluidRow(
                                  column(12, verbatimTextOutput('Gene_ex_swarm_status_outFile_expression') ),
                                  column(12, dataTableOutput("outFile_expression")),
                                  column(12, downloadButton('outFile_expression_download',"Download this table")),
                                )
                              )                       
                            ),
                            column( width = 8, 
                              box(status='danger', width=12, title=strong('Swarm Plot'),collapsible=TRUE,
                                fluidRow(
                                  column(10, verbatimTextOutput('Gene_ex_swarm_status') ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_fig.width', label='fig width', min=300, max=3000, value=800, step=10)),
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_pt.size', 'Point size', min=0.1, max=5, value=1, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_xlab.font.size', label='X label size', min=1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_ylab.font.size', label='Y label size', min=1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_Swarm_graph.title.font.size', 'Y title size', min=1, max=10, value=4, step=0.1))
                                      ),
                                      fluidRow(
                                        column(12, materialSwitch('Data_Overview_Swarm_white_background', 'Use white background', value=FALSE, status = "success"))
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Data_Overview_Swarm_change_colour_pallete', 'Change the colour pallete', value=FALSE, status = "success")),
                                        conditionalPanel(
                                          condition = "input.Data_Overview_Swarm_change_colour_pallete == true",
                                          column(6, selectInput('Data_Overview_Swarm_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                        )
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Data_Overview_Swarm_use_single_colour', 'Use a single colour', value=FALSE, status = "success")),
                                        conditionalPanel(
                                          condition = "input.Data_Overview_Swarm_use_single_colour == true",
                                          column(6, colourpicker::colourInput('Data_Overview_Swarm_choose_single_colour', 'Choose a colour', value='#000000'))
                                        )
                                      ),  
                                      circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    ),
                                  ),
                                  column(12, withSpinner(plotOutput("Gene_ex_swarm", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                  column(12, h4('') ),
                                  column(12, materialSwitch("Gene_ex_logsclae", "Use a log scale (log2)", value=FALSE, status='danger')),
                                  column(6,
                                    fluidRow(
                                      column(12, materialSwitch("order_group", "Re-order the X axis (group names)", value=FALSE, status='danger')),
                                      conditionalPanel( 
                                        condition = "input.order_group == true",  
                                        column(12, textAreaInput("group_order", "Enter the group name line by line") ),
                                        column(12, verbatimTextOutput('Gene_ex_swarm_status2') ), 
                                        column(12, h5('List of the available group names')),
                                        column(12, verbatimTextOutput("Data_Overview_Swarm_group_name_list") ) 
                                      )
                                    )
                                  ),
                                  column(6,
                                    fluidRow(
                                      column(12, materialSwitch("Gene_ex_swarm_exclude_sample", "Want to exclude specific samples?", value = FALSE, status='danger')),
                                      conditionalPanel(
                                        condition = "input.Gene_ex_swarm_exclude_sample == true",
                                        column(12, textAreaInput("Gene_ex_swarm_exclude_sample_input", "Enter sample names to be excluded (line by line)")),
                                        column(12, verbatimTextOutput('Gene_ex_swarm_status3') ),
                                        column(12,
                                          tags$details(
                                            tags$summary("List of sample names ▼ (click here)"),  # クリックすると開閉されるタイトル
                                            div(
                                              verbatimTextOutput('Gene_ex_swarm_exclude_sample_input_list')
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          ),
                        ),
                      ####### two genes correlation #######    
                        tabPanel(strong("Two genes correlation"),
                          h4(''),
                          fluidRow(
                            column(4,
                              box(width=12, status='info', title=strong('Inputs and Settings'), collapsible = TRUE,
                                fluidRow(
                                  column(12, radioButtons('Two_gene_corr_corr_Input', "Choose one from below:", choices=c('Enter both X and Y-axis genes'='A', 'Enter Y-axis gene and explore the correlations'='B'), selected='A')),
                                  column(12, textInput('Two_gene_corr_gene1', 'Gene1 (Y-axis)')),
                                  conditionalPanel(
                                    condition = "input.Two_gene_corr_corr_Input == 'A'",
                                    column(12, textInput('Two_gene_corr_gene2', 'Gene2 (X-axis)')),
                                  ),
                                  conditionalPanel(
                                    condition = "input.Two_gene_corr_corr_Input == 'B'",
                                    column(12, radioButtons('Two_gene_corr_gene2_list_Input', "Genes to explore are given from:", choices=c('Text input'='A', 'Custom Genesets'='B'), selected='A')),
                                    conditionalPanel(
                                      condition = "input.Two_gene_corr_gene2_list_Input == 'A'",
                                      column(12, textAreaInput('Two_gene_corr_gene2_list', 'List of genes to explore (line by line)')),                                      
                                    ),
                                    conditionalPanel(
                                      condition = "input.Two_gene_corr_gene2_list_Input == 'B'",
                                      column(12, htmlOutput('Two_gene_corr_gene2_Input_from_custom_geneset_select'))
                                    )

                                  ),
                                  column(12, radioButtons('Two_gene_corr_corr_method', "Correlation calculation method:", choices=c('pearson', 'spearman'), selected='pearson')),
                                  column(12, materialSwitch("Two_gene_corr_log", "Use log scale", value=FALSE, status='info')),
                                  column(12, h4('')),
                                  conditionalPanel(
                                    condition = "input.Two_gene_corr_corr_Input == 'B'",
                                    column(12, actionButton('Two_gene_corr_start', 'Calculate the corralations',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                    column(12, h4('')),
                                    column(12, h4('Choose a row from below:')),
                                    column(12, verbatimTextOutput('Two_gene_corr_table_status') ),
                                    column(12,  dataTableOutput("Two_gene_corr_table") ),
                                  )
                                ),
                              ),
                            ),
                            column(8,
                              box(width=12, status='danger', title=strong('Plot'), collapsible = TRUE,
                                fluidRow(
                                  column(12, verbatimTextOutput('Two_gene_corr_statusA') ),
                                  column(12, verbatimTextOutput('Two_gene_corr_statusB') ),
                                  column(10, verbatimTextOutput('Two_gene_corr_corr_score') ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6, sliderInput('Two_gene_corr_fig.width', 'Fig width', min=300, max=3000, value=800, step=10)),
                                        column(6, sliderInput('Two_gene_corr_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                        column(6, sliderInput('Two_gene_corr_pt.size', 'Point size', min=0.01, max=5, value=1, step=0.01)),
                                        column(6, sliderInput('Two_gene_corr_label.font.size', 'X/Y label font size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput('Two_gene_corr_title.font.size', 'X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput('Two_gene_corr_legend.font.size', 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, materialSwitch('Two_gene_corr_while_background', 'Use white background', value=FALSE, status = "success")),
                                      ),
                                      circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    )
                                  )
                                ),
                                fluidRow(
                                  column(12, withSpinner(plotOutput("Two_gene_corr_plot", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                  column(12, h4(""))
                                ),
                                fluidRow(
                                  column(3, materialSwitch('Two_gene_corr_plot_line', 'Show the correlation line', value=FALSE, status='danger') ),
                                  column(7, materialSwitch("Two_gene_corr_colour_grorp", "Colour by groups", value=TRUE, status='danger'))
                                ),
                                fluidRow(
                                  column(12, materialSwitch("Two_gene_corr_choose_sample", "Select samples", value=FALSE, status='danger')),
                                  conditionalPanel(
                                    condition = "input.Two_gene_corr_choose_sample",
                                    column(12, verbatimTextOutput('Two_gene_corr_status_selectsample') ),
                                    column(12, textAreaInput('Two_gene_corr_choose_sample_input', "Enter sample names (line by line)")),
                                    column(12, 
                                      h5('List of the sample names'),
                                      verbatimTextOutput('Two_gene_corr_choose_sample_input_list')
                                    )
                                  ),
                                )
                              )
                            ),
                          )
                        ),
                      ####### heatmap #######  
                        tabPanel(strong("Heatmap"), 
                          h4(''),
                          fluidRow(
                            column(4, 
                              box(width=12, collapsible=TRUE, status='info', title=strong('Inputs and Settings'),
                                fluidRow(
                                  column(12, radioButtons('Data_Overview_heatmap_target_gene_type', 'Genes from', choices = c('Text input'='A', 'Custom Gene Sets'='B', 'HALLMARK (Human)'='C', 'HALLMARK (Mouse)'='D', 'input a gmt file'='E'), selected='A')),
                                  column(12, verbatimTextOutput('Data_Overview_heatmap_target_gene_type_status')),
                                  conditionalPanel(
                                    condition = "input.Data_Overview_heatmap_target_gene_type == 'A'",
                                    column(12, textAreaInput("Data_Overview_heatmap_target_genes", "Enter genes (line by line)"))
                                  ),
                                  conditionalPanel(
                                    condition = "input.Data_Overview_heatmap_target_gene_type != 'A'",
                                    conditionalPanel(
                                      condition = "input.Data_Overview_heatmap_target_gene_type == 'E'",
                                      column(12, fileInput("Data_Overview_heatmap_target_upload_custom_pathway", "Upload a gmt file"))
                                    ),
                                    column(12, htmlOutput("Data_Overview_heatmap_target_select_geneset"))
                                  ),
                                  column(12, h4('')),
                                  column(12, h4('Choose the samples to use below:')),
                                  column(12,  dataTableOutput("Data_Overview_heatmap_sample_table")),
                                  column(12, h4('')),
                                  column(12, h4('')),
                                  column(12, actionButton('Gene_Overview_heatmap_start', 'Generate a heatmap', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                                )
                              )
                            ),
                            column(8, 
                              box(width=12, collapsible=TRUE, status='danger', title=strong('Plot'),
                                fluidRow(
                                  column(10, verbatimTextOutput('Data_Overview_heatmap_status') ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6, sliderInput(inputId = 'Data_Overview_heatmap_fig.width', label='fig width', min=300, max=3000, value=700, step=10)),
                                        column(6, sliderInput(inputId = 'Data_Overview_heatmap_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                                        column(6, sliderInput(inputId = 'Data_Overview_heatmap_xlab.font.size', label='X label size', min=0, max=10, value=1, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_heatmap_ylab.font.size', label='Y label size', min=0, max=10, value=3, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_heatmap_legend.size', label='Legend size', min=1, max=10, value=3, step=1)),
                                      ),
                                      fluidRow(
                                        column(4, colourpicker::colourInput(inputId = 'Data_Overview_heatmap_col_high', 'Colour for the highest value', value='red')),
                                        column(4, colourpicker::colourInput(inputId = 'Data_Overview_heatmap_col_low', 'Colour for the lowest value', value='blue')),
                                        column(4, colourpicker::colourInput(inputId = 'Data_Overview_heatmap_col_mid', 'Colour for value = 0', value='white')),
                                      ),
                                      fluidRow(
                                        column(12, materialSwitch('Data_Overview_heatmap_white_background', 'Use white background', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, h4('')),
                                  column(12, withSpinner(plotOutput("Data_Overview_heatmap_plot", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                  column(12, h4('')),
                                  column(9, sliderInput(inputId = 'Cluster_num', label='Cluster number', min=1, max=20, value=1, step=1)),
                                )
                              )
                            )
                          ),
                          fluidRow(
                            column(12, 
                              box(title=strong('Expression scores'), collapsible=TRUE, status='warning', width=12, 
                                fluidRow(
                                  column(12, verbatimTextOutput('Data_Overview_heatmap_expression_status') ),
                                  column(12, dataTableOutput("Data_Overview_heatmap_expression"))
                                ),
                                fluidRow(
                                  column(3, downloadButton('Data_Overview_heatmap_expression_download',"Download this table", style="color: #ffffff; background-color: #ee9d29; border-color: #e48803")),
                                  column(4, 
                                    box(width=12, title='List of the genes in each cluster.', collapsible=TRUE, collapsed=TRUE,
                                      fluidRow(column(12, htmlOutput('Data_Overview_heatmap_expression_cluster_select'))),
                                      fluidRow(column(12, verbatimTextOutput('Data_Overview_heatmap_expression_cluster_genename')))
                                    )
                                  )
                                )
                              )
                            )
                          )
                        ),
                      ####### PCA ####### 
                        tabPanel(strong("PCA plot"),
                          h4(''),
                          fluidRow(
                            column(8,
                              box(width=12, title=strong('Plot'), collapsible = TRUE, status='danger',
                                fluidRow(
                                  column(10, verbatimTextOutput('Data_Overview_PCA_status')),
                                  column(2,
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_fig.width', label='fig width', min=300, max=3000, value=800, step=10)),
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_fig.height', label='fig height', min=300, max=3000, value=600, step=10))
                                      ),
                                      fluidRow(
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_xy.font.size', label='X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_xy.title.size', label='Y/Y title size', min=0.1, max=10, value=4, step=0.1))
                                      ),
                                      fluidRow(
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_point_size', 'Points size', min=0.1, max=5, value=1, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_label_size', 'Sample label side', min=0.1, max=5, value=1, step=0.1)),
                                        column(6, sliderInput(inputId = 'Data_Overview_PCA_legend_size', 'Legend size', min=0.1, max=5, value=4, step=0.1))
                                      ),
                                      fluidRow(
                                        column(4, materialSwitch('Data_Overview_PCA_change_colour_by_group', 'Colour by groups', value=TRUE, status = "success")),
                                        column(4, materialSwitch('Data_Overview_PCA_label_hide', 'Hide labels', value=TRUE, status = "success")),
                                      ),
                                      fluidRow(
                                        column(12, materialSwitch('Data_Overview_PCA_white_background', 'Use white background', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput("Data_Overview_PCA_plot", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                )
                              )
                            ),
                            column(4, 
                              box(width=12, title=strong("Settings"), collapsible = TRUE,  status='info',
                                fluidRow(
                                  column(12, radioButtons('Data_Overview_PCA_Setting', 'Please chosse', choices = c('Default setting'='A', 'Define the groups'='B'), selected='A')),
                                  column(12,
                                    conditionalPanel(
                                      condition = "input.Data_Overview_PCA_Setting == 'B'",
                                      helpText("Please specify the sample names and their group names that you want to use as the following example."),
                                      helpText("Ex.)"),
                                      helpText("    Sample1_rep1,Group1"),
                                      helpText("    Sample1_rep2,Group1"),
                                      helpText("    Sample2_rep1,Group2"),
                                      helpText("    ..."),
                                      textAreaInput("Data_Overview_PCA_Setting_group_define", "Enter the group description"),
                                      h3(""),
                                      tags$details(
                                        tags$summary("List of sample names ▼ (click here)"),  # クリックすると開閉されるタイトル
                                        div(
                                          verbatimTextOutput('Data_Overview_PCA_Sample_list')
                                        )
                                      ),
                                      h3("")
                                    ),
                                  ),
                                  column(12, actionButton('Data_Overview_PCA_Start', 'Generate a PCA plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                )
                              )
                            )
                          )
                        )
                      #######
                    )
                  ),
                ###### when type B is slected ######
                  conditionalPanel(
                    condition = "output.Data_class == 'B'",
                    tabsetPanel(
                      ####### Table #######
                        tabPanel("Data Table", h4(''), 
                          box(width=12, status='warning', title=strong('Data table'), collapsible=TRUE, 
                            withSpinner(DT::dataTableOutput("DataTable"), type=5, color='#0dc5c1') 
                          )
                        ),  
                      ####### Plot #######  
                        tabPanel(strong("Plot & Downstream Analysis"),
                          fluidRow(column(12,  h4(''))),
                          ## main plot part
                            fluidRow(
                              column(6, 
                                box(collapsible=TRUE, status='danger', width=12, 
                                  title = div(style = "color: #c7163c; font-weight: bold;", "Main plot"), 
                                  tabsetPanel(
                                    tabPanel(strong("Scatter Plot"),
                                      fluidRow(
                                        column(12, h4('')),
                                        column(10, verbatimTextOutput('Gene_ex_status')),
                                        column(2, 
                                          dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                              column(6,sliderInput('fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                              column(6,sliderInput('fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                              column(6, sliderInput('pt.size', 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                                              column(6, sliderInput('high.pt.size', 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                                              column(6, sliderInput('high.label.size', 'Highlighted labels size', min=0.1, max=5, value=0.9, step=0.1)),
                                              column(6, sliderInput('label.font.size', 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                                              column(6, sliderInput('title.font.size', 'X/Y title font size', min=1, max=15, value=4, step=0.1))
                                              # column(4, sliderInput('graph.title.font.size', 'Graph title font size', min=1, max=40, value=10, step=1))
                                            ),
                                            fluidRow(
                                              column(12, h5('Graph display area:')),
                                              column(3, numericInput('main_plot_xlim_1', 'Min X-axis:', value=NA, step=0.1)),
                                              column(3, numericInput('main_plot_xlim_2', 'Max X-axis:', value=NA, step=0.1)),
                                              column(3, numericInput('main_plot_ylim_1', 'Min Y-axis:', value=NA, step=0.1)),
                                              column(3, numericInput('main_plot_ylim_2', 'Max Y-axis:', value=NA, step=0.1)),
                                            ),
                                            fluidRow(
                                              column(5, materialSwitch('while_background', 'Use white background', value=FALSE, status='success')),
                                              column(5, materialSwitch('main_plot_white_back_label', 'Use white background for labels', value=TRUE, status='success'))
                                            ),
                                            circle = FALSE,
                                            status = "success", 
                                            icon = icon("gear"), width = "800px", 
                                            tooltip = tooltipOptions(title = "Plot Options")
                                          ),
                                        ),
                                        column(12, h4('')),
                                        column(12, withSpinner(plotOutput("Gene_ex", brush = "plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1'))
                                      )
                                    ),
                                    tabPanel(strong('Bar Plot'),
                                      fluidRow(
                                        column(12, h4('')),
                                        column(10, verbatimTextOutput("Gene_ex_barplot_status")),
                                        column(2, 
                                          dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                              column(6, sliderInput(inputId = 'Gene_ex_barplot_fig.width', label='fig width', min=300, max=3000, value=500, step=10)),
                                              column(6, sliderInput(inputId = 'Gene_ex_barplot_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                                              column(6, sliderInput(inputId = 'Gene_ex_barplot_xlab.font.size', label='X label size', min=1, max=10, value=4, step=0.1)),
                                              column(6, sliderInput(inputId = 'Gene_ex_barplot_ylab.font.size', label='Y label size', min=1, max=10, value=4, step=0.1)),
                                              column(6, sliderInput(inputId = 'Gene_ex_barplot_graph.title.font.size', label='Y title size', min=1, max=10, value=4, step=0.1))
                                            ),
                                            fluidRow( # colour for max, 0 and min values
                                              column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_max', label='Colour for the max value:', value='red')),
                                              column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_min', label='Colour for the min value:', value='blue')),
                                              column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_0', label='Colour for the 0 value:', value='white'))
                                            ),
                                            fluidRow(
                                              # Rotate x axis lable in the bar plot
                                              column(6, materialSwitch('show_outliers_rotate_x', 'Rotate x axis lable', value=FALSE, status = "success")),
                                              column(6, materialSwitch('Gene_ex_barplot_white_background', 'Use white background', value=FALSE, status = "success"))
                                            ),
                                            circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                          )
                                        ),
                                        column(12, h4('')),
                                        column(12, withSpinner(plotOutput("Gene_ex_barplot", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                      )
                                    )
                                  )
                                )
                              ),
                              column(6, 
                                ## Display options
                                box( title=strong('Display Options'),  collapsible=TRUE, status='info',width=12,
                                  # select x and y
                                  fluidRow( 
                                    column(12, h4('Choose X and Y axis:')),
                                    column(6, htmlOutput("Scat.X")), 
                                    column(6, htmlOutput("Scat.Y")),
                                  ),
                                  # when highlighting specific genes
                                  fluidRow(
                                    column(12, h4('Highlight the genes of interest')),
                                    column(6, textAreaInput("target_gene", "Enter genes (line by line)")),
                                    column(6,
                                      fluidRow(
                                        column(12, h2('')),
                                        column(12, materialSwitch("show_label", "show gene names", value=FALSE, status='info')),
                                        column(12, materialSwitch("interesting_gene_colour", "change the highlight colour", value=FALSE, status='info')),
                                        conditionalPanel(
                                          condition = "input.interesting_gene_colour == true",
                                            column(8, colourpicker::colourInput('interesting_gene_colour_id', 'select colour:', value='red'))
                                        )
                                      )
                                    ),
                                    column(12, verbatimTextOutput('Scatter_interesting_gene_status') ),
                                  ),
                                  fluidRow(
                                    column(12, materialSwitch("main_plot_target_genes_2", "Highlight other genes with a different colour", value=FALSE, status='info')),
                                    conditionalPanel(
                                      condition = "input.main_plot_target_genes_2 == true",
                                      column(12, 
                                        fluidRow(
                                          column(6, textAreaInput("main_plot_target_genes_2_input", "Enter genes (line by line)")),
                                          column(6,
                                            fluidRow(
                                              column(12, h2('')),
                                              column(8, colourpicker::colourInput('main_plot_target_genes_2_colour', 'select colour:', value='#0066ff'))
                                            )
                                          ),
                                          column(12,  verbatimTextOutput('Scatter_interesting_gene_status2') )
                                        )
                                      )
                                    )
                                  ), 
                                  fluidRow(
                                    column(12, h3('')),
                                    column(12, materialSwitch("show_entered_gene_info", "show the highlighted genes information as a table", value=FALSE, status='info'))
                                  )
                                ), 
                                ## filtering options
                                box(width=12, collapsible=TRUE, status='info', title=strong('Highlight filterd genes or gene sets in the plot'),
                                  fluidRow(
                                    column(12, radioButtons("show_filterin_input_option", "Please Choose one below:", choices=c("None"="A", "Filtered genes"="B", "Pathway genes"="C", "Custom genesets"="D"), selected="A", inline=TRUE),)
                                  ),
                                  # Flitered genes
                                  conditionalPanel(
                                    condition = "input.show_filterin_input_option == 'B'",
                                    fluidRow(
                                      column(12, radioButtons("How_to_filter", "How to filter:", choices = c("Show top/bottom N % (default: 10%)"="A", "Custom threshold setting"="B"), selected='B')),
                                    ),
                                    conditionalPanel(
                                      condition = "input.How_to_filter == 'A'", # take top/bottom N %
                                      fluidRow(
                                        column(12, h3('')),
                                        column(6, numericInput('Overviwe_Top_threshold', 'The threshold for Top hits (%)', min=0, max=100, value=10, step=1)),
                                        column(6, numericInput('Overviwe_Bottom_threshold', 'The threshold for Bottom hits (%)', min=0, max=100, value=10, step=1)),
                                        column(6, numericInput('Overviwe_Top_bottom_Y_threshold', 'The threshold for Y axis', min=0, value=0, step=0.1)),
                                        column(12, h3(''))
                                      )
                                    ),
                                    conditionalPanel(
                                      condition = "input.How_to_filter == 'B'",
                                      fluidRow(
                                        column(12, h3('')),
                                        column(3,
                                          fluidRow(
                                            column(12, numericInput('Main_scatter_thr_X1', 'X threshold 1',  value=1, step=0.1) ),
                                            column(12, numericInput('Main_scatter_thr_X2', 'X threshold 2',  value=-1, step=0.1) )
                                          )
                                        ),
                                        column(3,
                                          fluidRow(
                                            column(12, numericInput('Main_scatter_thr_Y1', 'Y threshold 1', value=1.3, step=0.1) ),
                                            column(12, numericInput('Main_scatter_thr_Y2', 'Y threshold 2', value=0, step=0.1) )
                                          )
                                        ),
                                        column(3, radioButtons("Main_scatter_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                                        column(3, radioButtons("Main_scatter_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') ),
                                        column(12, h3('')),
                                      )
                                    ),
                                    fluidRow(
                                      column(12, h3('')),
                                      column(6, materialSwitch('hide_gene_label', 'Hide labels', value=FALSE, status='info')),
                                      column(6, materialSwitch('show_information', 'Show the filtered genes information', value=FALSE, status='info')),
                                      conditionalPanel(
                                        condition = "input.How_to_filter == 'B'",
                                        column(6, materialSwitch('show_threhold_lines', 'Show the threshold lines', value=FALSE, status='info')),
                                      ),
                                      column(12, materialSwitch("outlier_gene_colour", "change the colour", value=FALSE, status='info')),
                                      conditionalPanel(
                                        condition = "input.outlier_gene_colour == true",
                                          column(6, colourpicker::colourInput('outlier_gene_colour_id', 'Positive side:', value='#0000CD')),
                                          column(6, colourpicker::colourInput('outlier_gene_colour_id_negative', 'Negative side:', value='#FF8C00'))
                                      ),
                                      column(12, materialSwitch('show_outliers_bar_plot', 'Show in a bar plot', value=FALSE, status='info'))
                                    )
                                  ),
                                  # show pathway genes
                                  conditionalPanel(
                                    condition = "input.show_filterin_input_option == 'C'",
                                    fluidRow(
                                      column(4, radioButtons("pathway_dataset_select", "pathways from:", choices = c("HALLMARK (human)", "HALLMARK (mouse)", "Custom"))),
                                      column(8,
                                        fluidRow(
                                          column(12, 
                                            conditionalPanel( 
                                              condition = "input.pathway_dataset_select == 'Custom'", 
                                              fileInput("upload_custom_pathway_file", "Upload a gmt file")
                                            )
                                          ),
                                          column(12, htmlOutput("select_pathway"))
                                        )
                                      )
                                    ),
                                    fluidRow(
                                      column(6, materialSwitch('hide_gene_label_pathway', 'Hide labels', value=FALSE, status='info')),
                                      column(6, materialSwitch('show_information_pathway', 'Show the genes information', value=FALSE, status='info')),
                                      column(6, materialSwitch("pathway_gene_colour", "change the colour", value=FALSE, status='info')),
                                      conditionalPanel(
                                        condition = "input.pathway_gene_colour == true",
                                          column(6, colourpicker::colourInput('pathway_gene_colour_id', 'select colour:', value='#FF00FF'))
                                      ),
                                    ),
                                    fluidRow(
                                      column(6, materialSwitch('show_pathway_bar_plot', 'Show in a bar plot', value=FALSE, status='info'))
                                    ),
                                    fluidRow(
                                      column(12, materialSwitch("Main_scatter_pathway_filter", "Apply further filtering", value=FALSE, status='info') ),
                                      conditionalPanel(
                                        condition = "input.Main_scatter_pathway_filter == true",
                                        column(12, h5('Further filtering:')),
                                        column(12, 
                                          fluidRow(
                                            column(3,
                                              fluidRow(
                                                column(12, numericInput('Main_scatter_pathway_thr_X1', 'X threshold 1',  value=1, step=0.1) ), 
                                                column(12, numericInput('Main_scatter_pathway_thr_X2', 'X threshold 2',  value=-1, step=0.1) )
                                              )
                                            ),
                                            column(3,
                                              fluidRow(
                                                column(12, numericInput('Main_scatter_pathway_thr_Y1', 'Y threshold 1', value=1.3, step=0.1) ), 
                                                column(12, numericInput('Main_scatter_pathway_thr_Y2', 'Y threshold 2', value=0, step=0.1) )
                                              )
                                            ),
                                            column(3, radioButtons("Main_scatter_pathway_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                                            column(3, radioButtons("Main_scatter_pathway_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') )
                                          )
                                        )
                                      )
                                    ),

                                  ),
                                  # show custom gene sets
                                  conditionalPanel(
                                    condition = "input.show_filterin_input_option == 'D'",
                                    fluidRow(
                                      column(12, htmlOutput("Plot_Gene_set_select_geneset")),
                                      column(6, materialSwitch('Plot_Gene_sethide_gene_label', 'Hide labels', value=FALSE, status='info')),
                                      column(6, materialSwitch('Plot_Gene_setshow_information', 'Show the genes information', value=FALSE, status='info')),
                                      column(6, materialSwitch("Plot_Gene_set_pathway_gene_colour", "change the colour", value=FALSE, status='info')),
                                      conditionalPanel(
                                        condition = "input.Plot_Gene_set_pathway_gene_colour == true",
                                          column(6, colourpicker::colourInput('Plot_Gene_set_pathway_gene_colour_id', 'select colour:', value='#fcc203'))
                                      )
                                    ),
                                    fluidRow(
                                      column(6, materialSwitch('show_geneset_bar_plot', 'Show in a bar plot', value=FALSE, status='info'))
                                    ),
                                    fluidRow(column(12, materialSwitch("Main_scatter_geneset_filter", "Apply further filtering", value=FALSE, status='info') )),
                                    conditionalPanel(
                                      condition = "input.Main_scatter_geneset_filter == true",
                                      column(12, h5('Further filtering:')),
                                      column(12,
                                        fluidRow(
                                          column(3,
                                            fluidRow(
                                              column(12, numericInput('Main_scatter_geneset_thr_X1', 'X threshold 1',  value=1, step=0.1) ), 
                                              column(12, numericInput('Main_scatter_geneset_thr_X2', 'X threshold 2',  value=-1, step=0.1) )
                                            )
                                          ),
                                          column(3,
                                            fluidRow(
                                              column(12, numericInput('Main_scatter_geneset_thr_Y1', 'Y threshold 1', value=1.3, step=0.1) ), 
                                              column(12, numericInput('Main_scatter_geneset_thr_Y2', 'Y threshold 2', value=0, step=0.1) )
                                            )
                                          ),
                                          column(3, radioButtons("Main_scatter_geneset_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B') ),
                                          column(3, radioButtons("Main_scatter_geneset_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B') )
                                        )
                                      )
                                    )
                                  )
                                ),
                              ),
                            ),
                          ## display tables
                            # display the selected/filtered area
                            fluidRow(
                              column(12, 
                                # display the genes of interest (table)
                                conditionalPanel(
                                  condition = "input.show_entered_gene_info == true",
                                  box(title='Information of genes of interest', collapsible=TRUE, status='warning',  width=12,
                                    fluidRow( column(12, verbatimTextOutput('Interesting_gene_outFile_status') )),
                                    fluidRow( column(12, withSpinner(dataTableOutput("Interesting_gene_outFile"), type=5, color='#0dc5c1') )),
                                    fluidRow( column(12, downloadButton('Interesting_gene_download',"Download this table") ))
                                  )
                                ),
                                # display the filtered area (table)
                                conditionalPanel(
                                  condition = "input.show_filterin_input_option=='B' & input.show_information == true",
                                  box(title='Outliers Information', collapsible=TRUE, status='warning', width=12,
                                    withSpinner(dataTableOutput("outFile3"), type=5, color='#0dc5c1'),
                                    fluidRow(
                                      column(3, downloadButton('filtered_download',"Download this table")),
                                      column(5, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('filtered_gene_list') ))
                                    )
                                  )
                                ),
                                # display the pathway genes (table)
                                conditionalPanel(
                                  condition = "input.show_filterin_input_option=='C'  & input.show_information_pathway== true",
                                  box(title='Pathway Genes Information', collapsible=TRUE, status='warning', width=12,
                                    withSpinner(dataTableOutput("outFile3_pathway"), type=5, color='#0dc5c1'),
                                    fluidRow(
                                      column(3, downloadButton('pathway_download',"Download this table")),
                                      column(5, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('pathway_gene_list'))),
                                    )
                                  )
                                ),
                                # display the custom gene sets (table)
                                conditionalPanel(
                                  condition = "input.show_filterin_input_option=='D'  & input.Plot_Gene_setshow_information== true",
                                  box(title='Custom Gene Sets Information', collapsible=TRUE, status='warning', width=12,
                                    withSpinner(dataTableOutput("outFile3_custom_geneset"), type=5, color='#0dc5c1'),
                                    fluidRow(
                                      column(3, downloadButton('custom_geneset_download',"Download this table")),
                                      column(5, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Custom_geneset_gene_list')))
                                    )
                                  )
                                ),
                                # display the information in a selection (table)
                                box( title='Selected Area Information', collapsible=TRUE, status='warning', width=12, 
                                  fluidRow(column(12, verbatimTextOutput("outFile2_status")) ),
                                  fluidRow(column(12, h4('')) ),
                                  fluidRow(column(12, dataTableOutput("outFile2")) ),
                                  fluidRow(
                                    column(3, downloadButton('selected_download',"Download this table")),
                                    column(5, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('selected_gene_list') ))
                                  ),
                                ),
                              )
                            ), 
                          ## Downstream analysis
                            fluidRow(
                              column(12,
                                box( title='Downstream analysis', collapsible=TRUE, status='primary',  width=12, collapsed=TRUE, solidHeader = TRUE, 
                                  tabsetPanel(
                                    ## GO
                                      tabPanel(strong('GO/KEGG analysis'),
                                        fluidRow(column(12, h4(''))),
                                        box(title=strong('Settings'), collapsible=TRUE, width=4,status='primary', 
                                          fluidRow(
                                            column(12, radioButtons("GO_input_type", "Input genes for GO analysis", choices = c("Text input"='A', "Use filtered genes (Results from 'Show outliers' above)"='B', "Use selected genes (Selected area in the Main plot)"='C'), selected="A")),
                                            conditionalPanel( 
                                              condition = "input.GO_input_type == 'A'", 
                                              column(12, textAreaInput("GO_input_geneList", "Enter gene list (one gene per line, Gene symbol)")) 
                                            ),
                                            column(12, h4(''))
                                          ),
                                          fluidRow(
                                            column(6, radioButtons("GO_species", "Select Species", choices = c("Human", "Mouse")),selecetd="Human"),
                                            column(6, radioButtons("GO_database", "Select Database", choices = c("GO", "KEGG")), selecetd='GO'),
                                            conditionalPanel( condition = "input.GO_database == 'GO'", column(6, radioButtons("GO_ontology", "Select Ontology", choices = c("BP", "MF", "CC")), selected="BP") )
                                          ),
                                          fluidRow( column(4, actionButton("GO_start", "Start GO/KEGG Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")) ),
                                          fluidRow( 
                                            column(12, h5(span('This takes 1~3 minutes depending on the size of the input. Please be patient.', style="color: red;"))) ,
                                            column(12, h5('')) 
                                          )
                                        ),
                                        box(title=strong('Results & Plots'), collapsible=TRUE, width=8, status='danger', 
                                          fluidRow(
                                            column(12, h4('')),
                                            column(12, verbatimTextOutput('GO_go_status') ),
                                            column(12, h4(''))
                                          ),
                                          fluidRow(
                                            column(12, 
                                              tabsetPanel(
                                                tabPanel(strong("Table"), 
                                                  fluidRow(
                                                    column(12, h4('')),
                                                    column(12, verbatimTextOutput('GO_goTable_status') ),
                                                    column(12, withSpinner(DT::dataTableOutput("GO_goTable", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                                    column(12, downloadButton('GO_goTable_download',"Download this table") )
                                                  )
                                                ),
                                                tabPanel(strong("Bar Plot"), 
                                                  fluidRow(
                                                    column(12, h4('')),
                                                    column(10, verbatimTextOutput('GO_goPlot_status') ),
                                                    column(2, 
                                                      dropdownButton( h4(strong("Plot Options")),
                                                        fluidRow(
                                                          column(6, sliderInput('GO_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                                                          column(6, sliderInput('GO_fig.height','Fig height', min=300, max=3000, value=1000, step=10)),
                                                          column(6, sliderInput('GO_fig.category_show_number','Number of categories to show', min=5, max=50, value=10, step=1)),
                                                          column(6, sliderInput('GO_legend.size', 'Legend size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_xtitle.font.size', 'X title font size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_ylab.font.size', 'Y labels size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_xlab.font.size', 'X label font size', min=0.1, max=20, value=5, step=0.1))
                                                        ),
                                                        fluidRow(
                                                          column(6, colourpicker::colourInput('GO_bar_colour_max', 'Max colour:', value='#ffffff')),
                                                          column(6, colourpicker::colourInput('GO_bar_colour_min', 'Min colour:', value='#00c310')),
                                                          column(6, materialSwitch('GO_bar_white_background', 'Use white background', value=FALSE, status='success')),
                                                        ),
                                                        circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                                      ),
                                                    ),
                                                    column(12, withSpinner(plotOutput("GO_goPlot", width="100%", height="100%"), type=5, color='#0dc5c1'))
                                                  )
                                                ),
                                                tabPanel(strong("Bubble Plot"), 
                                                  fluidRow(
                                                    column(12, h4('')),
                                                    column(10, verbatimTextOutput('GO_goBubblePlot_status') ),
                                                    column(2, 
                                                      dropdownButton( h4(strong("Plot Options")),
                                                        fluidRow(
                                                          column(6, sliderInput('GO_Bubble_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                                                          column(6, sliderInput('GO_Bubble_fig.height','Fig height', min=300, max=3000, value=1000, step=10)),
                                                          column(6, sliderInput('GO_Bubble_fig.category_show_number','Number of categories to show', min=5, max=50, value=10, step=1)),
                                                          column(6, sliderInput('GO_Bubble_xtitle.font.size', 'X title font size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_Bubble_ylab.font.size', 'Y labels size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_Bubble_xlab.font.size', 'X label font size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_Bubble_legend.size', 'Legend size', min=0.1, max=20, value=5, step=0.1))
                                                        ),
                                                        fluidRow(
                                                          column(6, colourpicker::colourInput('GO_Bubble_colour_max', 'Max colour:', value='#ffffff')),
                                                          column(6, colourpicker::colourInput('GO_Bubble_colour_min', 'Min colour:', value='#c45f00')),
                                                          column(6, materialSwitch('GO_Bubble_white_background', 'Use white background', value=FALSE, status='success')),
                                                        ),
                                                        circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                                      ),
                                                    ),
                                                    column(12, withSpinner(plotOutput("GO_goBubblePlot", width="100%", height="100%"), type=5, color='#0dc5c1'))
                                                  )
                                                ),
                                                tabPanel(strong("Network plot"), 
                                                  fluidRow(
                                                    column(12, h4('')),
                                                    column(10, verbatimTextOutput('GO_netPlot_status_status') ),
                                                    column(2, 
                                                      dropdownButton( h4(strong("Plot Options")),
                                                        fluidRow(
                                                          column(6, sliderInput('GO_netPlot_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                                          column(6, sliderInput('GO_netPlot_fig.height','Fig height', min=300, max=3000, value=700, step=10)),
                                                          column(6, sliderInput('GO_netPlot_category_show_number', 'Number of categories to show', min=1, max=20, value=5, step=1)),
                                                          column(6, sliderInput('GO_netPlot_legend.size', 'Legend size', min=0.1, max=20, value=5, step=0.1)),
                                                          column(6, sliderInput('GO_netPlot_edge_size_term', 'Edge line width', min=0.01, max=2, value=0.2, step=0.01)),
                                                        ),
                                                        fluidRow(
                                                          column(6, sliderInput('GO_netPlot_label_size_term_term', 'Node label size (Term name)', min=0, max=5, value=2, step=0.1)),
                                                          column(6, sliderInput('GO_netPlot_label_size_term_gene', 'Node label size (Gene)', min=0, max=5, value=0, step=0.1)),
                                                          column(6, sliderInput('GO_netPlot_node_size_term', 'Node size (Term name)', min=0.1, max=10, value=2, step=0.1)),
                                                          column(6, sliderInput('GO_netPlot_node_size_gene', 'Node size (Gene)', min=0.1, max=10, value=1, step=0.1)),
                                                          # colour of the node
                                                          column(6, colourpicker::colourInput('GO_netPlot_node_colour_term', 'Node colour (Term name):', value='#d3a200')),
                                                          column(6, colourpicker::colourInput('GO_netPlot_node_colour_gene', 'Node colour (Gene):', value='#292929'))
                                                        ),
                                                        fluidRow(
                                                          column(6, materialSwitch('GO_netPlot_change_edge_colour', 'Change edge colour by terms', value=FALSE, status='success')),
                                                          column(6, materialSwitch('GO_netPlot_circle_plot', 'Circle plot', value=FALSE, status='success')),
                                                        ),
                                                        circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                                      ),
                                                    ),
                                                    column(12, withSpinner(plotOutput("GO_netPlot",  brush = "plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                                  )
                                                )
                                              ) 
                                            )
                                          )
                                        )
                                      ),
                                    ## GSEA
                                      tabPanel(strong('GSEA analysis'),
                                        h4(''),
                                        box(width=12, collapsible=TRUE, title=strong('Settings'), status='info',
                                          fluidRow(
                                            column(10,
                                              fluidRow(
                                                column(5, radioButtons("GSEA_pathway_dataset_select", "pathways from:", choices = c("HALLMARK (human)"='B', "HALLMARK (mouse)"='C', "Upload a gmt file (other gene sets)"='D', "Calculate the enrichment of one gene set"='E'), selected="B")),
                                                column(6, htmlOutput("GSEA_select_score")),
                                                conditionalPanel( 
                                                  condition = "input.GSEA_pathway_dataset_select == 'D'", 
                                                  column(7, fileInput("GSEA_upload_custom_pathway_file", "Upload a gmt file")) 
                                                ),
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
                                              fluidRow( 
                                                column(6, actionButton("GSEA_start", "Start GESA Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                                column(12, h4('')),
                                                column(12, verbatimTextOutput('GSEA_analysis_status'))
                                              )
                                            )
                                          )
                                        ),
                                        box(title=strong('GSEA results table'), collapsible=TRUE, width=4, status='warning',
                                          fluidRow( column(12, verbatimTextOutput('GSEA_goTable_status') )),
                                          fluidRow( column(12, withSpinner(DT::dataTableOutput("GSEA_goTable", width="100%", height="100%"), type=5, color='#0dc5c1') )), 
                                          fluidRow( column(12, downloadButton('GSEA_download',"Download this table") ))
                                        ),
                                        box(title=strong('Plots'), collapsible=TRUE, width=8, status='danger',
                                          fluidRow( 
                                            column(12, verbatimTextOutput('GSEA_plot_status') ),
                                            column(10, verbatimTextOutput('GSEA_status')),
                                            column(2, 
                                              dropdownButton( h4(strong("Plot Options")),
                                                fluidRow(
                                                  column(4, sliderInput('GSEA_fig.width', 'Fig width', min=300, max=3000, value=800, step=10)),
                                                  column(4, sliderInput('GSEA_fig.height','Fig height', min=300, max=3000, value=500, step=10))
                                                ),
                                                fluidRow(
                                                  column(4, sliderInput('GSEA_lab.font.size', 'X/Y labels size', min=1, max=15, value=5, step=0.1)),
                                                  column(4, sliderInput('GSEA_title.font.size', 'X/Y title font size', min=1, max=15, value=5, step=0.1)),
                                                  column(4, sliderInput('GSEA_graph_title.font.size', 'Graph title font size', min=1, max=15, value=5, step=0.1))
                                                ),
                                                fluidRow(
                                                  column(4, colourpicker::colourInput('GSEA_graph_line_colour', 'GSEA line colour:', value='green')),
                                                  column(4, colourpicker::colourInput('GSEA_graph_maxmin_line_colour', 'Max/Min line colour:', value='red'))
                                                ),
                                                circle = FALSE, status = "success", icon = icon("gear"), width = "1000px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                              ),
                                            ),
                                            column(12, withSpinner(plotOutput("GSEA_plot", width="100%", height="100%"), type=5, color='#0dc5c1') )
                                          )
                                        )
                                      ),
                                    ## TF
                                      tabPanel(strong('TF activity inference'),
                                        h4(''),
                                        fluidRow(
                                          column(12, h4('(DecoupleR analysis. Available only for RNAseq DEG data processed from DESeq2)')),
                                          column(4, 
                                            box(title='Settings', collapsible=TRUE, width=12, status='info',
                                              h3(),
                                              fluidRow(column(10, sliderInput('DecoupeR_TF_number', 'Number of TF to display', min=10, max=200, value=50, step=1))),
                                              h3(),
                                              fluidRow(column(12, actionButton("DecoupeR_start", "Start DecoupeR Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))),
                                            ),
                                          ),
                                          column(8, 
                                            box(title='Plots & Resutls', collapsible=TRUE, width=12, status='danger',
                                              fluidRow(
                                                column(12, helpText("Note: This is only applicable to the RANseq DEG data processed by DESeq2. Please see the wiki for more details.")),
                                                column(12, verbatimTextOutput('DecoupeR_plot_status') )
                                              ),
                                              tabsetPanel(
                                                tabPanel("DecoupeR Plot",
                                                  fluidRow(
                                                    column(12, h2('')),
                                                    column(10, verbatimTextOutput('DecoupeR_plot_status2') ),
                                                    column(2, 
                                                      dropdownButton( h4(strong("Plot Options")),
                                                        fluidRow(
                                                          column(6, sliderInput('DecoupeR_fig.width', 'Fig width', min=500, max=4000, value=1000, step=10)),
                                                          column(6, sliderInput('DecoupeR_fig.height','Fig height', min=300, max=3000, value=500, step=10))
                                                        ),
                                                        fluidRow(
                                                          column(6, sliderInput('DecoupeR_lab.font.size', 'X/Y labels size', min=1, max=10, value=3, step=0.1)),
                                                          column(6, sliderInput('DecoupeR_title.font.size', 'X/Y title font size', min=1, max=10, value=3, step=0.1)),
                                                          column(6, sliderInput('DecoupeR_legend.size', 'Legend size', min=1, max=10, value=3, step=0.1)),
                                                        ),
                                                        fluidRow(
                                                          column(4, colourpicker::colourInput('DecoupeR_colour_high', 'High activity colour:', value='indianred')),
                                                          column(4, colourpicker::colourInput('DecoupeR_colour_low', 'Low activity colour:', value='darkblue')),
                                                          column(4, colourpicker::colourInput('DecoupeR_colour_mid', 'Zero activity colour:', value='whitesmoke')),
                                                          column(12, materialSwitch('DecoupeR_white_background', 'Use white background', value=FALSE, status='success'))
                                                        ),
                                                        circle = FALSE, status = "success", icon = icon("gear"), right=TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                                      )
                                                    ),
                                                    column(12, withSpinner(plotOutput("DecoupeR_plot", width="100%", height="100%"), type=5, color='#0dc5c1' )  )
                                                  )
                                                ),
                                                tabPanel("Results Table", 
                                                  fluidRow(
                                                    column(12, h2('')),
                                                    column(12, verbatimTextOutput('DecoupeR_Table_status') ),
                                                    column(12, withSpinner(DT::dataTableOutput("DecoupeR_Table", width="100%", height="100%"), type=5, color='#0dc5c1'))
                                                  ),
                                                  fluidRow(
                                                    column(12, h5('')) ,
                                                    column(12, downloadButton('DecoupeR_Table_download',"Download this table") )
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    ## 
                                  )
                                )
                              )
                            )
                          ##
                        )
                      ###
                    )
                  )
                ###
              )
            ####
          ),
        #### Original_geneset ####
          tabItem( tabName='Original_geneset',
            h2(' Custom Genesets Information'),
            box(width=12, title=strong('Custom Gene Sets'), status='primary', collapsible = TRUE, solidHeader = TRUE,
              fluidRow(
                column(12,DT::dataTableOutput("Original_geneset_DataBaseTable")),
                column(2, actionButton('Original_geneset_save_dt', 'Save changes', style="color: #ffffff; background-color: #bc2929; border-color: #e130f9")),
                column(2, actionButton('Original_geneset_delete_row', 'Delete selected data', style="color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")),
                column(2, verbatimTextOutput('Original_geneset_status'))
              )
            ),
            box(width=12, title=strong('Add a Gene Set'), status='danger', collapsible = TRUE, solidHeader = TRUE,
              h3(''),
              fluidRow( 
                column(4, textInput("Original_geneset_upload_Geneset_name", "Geneset name *")), 
                column(3, textInput("Original_geneset_upload_cell_line", "Cell line/Cell type")), 
                column(3, textInput("Original_geneset_upload_data_generated_from", "Data source")),
                column(1, 
                  div(id='help',
                    dropdownButton( 
                      fluidRow(
                        column(12, h4(strong("Quick upload guide"))),
                        column(12, helpText("- The Geneset name and the list of the genes are mandatory.")),
                        column(12, helpText("- The Geneset name must be unique.")),
                        column(12, helpText("- Avoid special characters; use only alphabets, numbers, underscores and dots."))
                      ), circle = TRUE, status = "danger", icon = icon("question"), width = "900px",  tooltip = tooltipOptions(title = "Help"), right = TRUE
                    )
                  ) 
                )
              ),
              fluidRow( 
                column(4, textAreaInput("Original_geneset_upload_genes", "Genes (line by line) (Gene symbol) *")), 
                column(8, textAreaInput("Original_geneset_upload_description", "Description"))
              ),
              fluidRow( 
                column(3, actionButton('Original_geneset_upload_data', 'Add the geneset to the list', style="color: #ffffff; background-color: #bc2929; border-color: #e130f9")), 
                column(9, verbatimTextOutput('Original_geneset_status_upload'))
              )
            )
          ),
        #### Compare_across_datasets ####
          tabItem( tabName='Compare_across_datasets',
            h2(' Compare across datasets'),
            ##### Dataset selection ####
              box(width=12, collapsible=TRUE, title=strong('Dataset selection'), status='info',solidHeader = TRUE,
                fluidRow( 
                  column(6, htmlOutput("choose_data_type")),
                ),
                fluidRow(
                  column(12, h4('Setect the datasets to compare below:')),
                  column(12, verbatimTextOutput('Compare_dataset_selection_status')),
                  column(12, h4('')),
                  column(12, h4('')),
                  column(12, fluidRow( column(12, dataTableOutput("all_dataset")))),
                  column(12, 
                    div(id='filterin_dropdown',
                      dropdownButton( 
                        fluidRow(
                          column(6,htmlOutput("Compare_dataset_filtering_Data_from")),
                          column(6,htmlOutput("Compare_dataset_filtering_Experiment"))
                        ),
                        label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "1200px",  tooltip = tooltipOptions(title = "Filtering")
                      )
                    )
                  ),
                )
              ),
            ##### Analysis ####
              box(width=12, title=strong('Anlaysis'), status='primary',solidHeader = TRUE,
                h4(''),
                tabsetPanel(
                  ## Overlap the hits
                    tabPanel(strong("Get the overlap"),
                      fluidRow(
                        column(12, # Settings and Inputs
                          box(width=12, title=strong('Settings and Inputs'), collapsible = TRUE, status='info',
                            fluidRow( 
                              column(12, helpText(HTML("Please select the score for ranking (ex. LFC), choose the direction (either top or bottom), set the threshold, and click 'Investigate the Overlap'. <br>A table displaying how often each gene ranks in the top or bottom X% of the selected datasets will appear below."))) 
                            ),
                            fluidRow( column(12, h4('')) ),
                            fluidRow(
                              column(3, htmlOutput('Compare_dataset_get_overview_select_score')),
                              column(2, radioButtons('Compare_dataset_get_overview_direction', 'Direction:', choices=c('Top X%', 'Bottom X%'))),
                              column(5, 
                                fluidRow(
                                  column(12, sliderInput('Compare_dataset_get_overview_threshold', 'Threshold X(%)=', min=0, max=100, value=5, step=1)),
                                  column(7, numericInput('Compare_dataset_get_overview_threshold_for_display', 'Show genes with Overlap_time more than:', value=0, min=0, max=1000, step=1))
                                )
                              ),
                              column(3, actionButton('Compare_dataset_get_overview_start', 'Investigate the overlap',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                            )
                          ),                      
                        ),
                        column(4, # Overlapped hits
                          box(width=12, title=strong('Overlapped hits'), collapsible = TRUE, status='warning',
                            fluidRow( 
                              column(12, verbatimTextOutput('Compare_dataset_get_overview_status')),
                              column(12, withSpinner(dataTableOutput("Compare_dataset_get_overview_overlap"), type=5, color='#0dc5c1') ),
                              column(12, h2('')),
                              column(12, 
                                fluidRow(
                                  column(5, downloadButton('Compare_dataset_get_overview_download',"Download this table", style="color: #ffffff; background-color: #ee9d29; border-color: #e48803")),
                                  column(7, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Compare_dataset_get_overview_list') ))
                                )
                              )
                            )
                          ),
                        ),
                        column(8, # barplot
                          box(width=12, title=strong('barplot'), collapsible = TRUE,status='danger',
                            fluidRow(
                              column(10, verbatimTextOutput('Compare_dataset_get_overview_barplot_status')),
                              column(2,
                                dropdownButton( h4(strong("Plot Options")),
                                  fluidRow(
                                    column(6,sliderInput('Compare_dataset_get_overview_fig.width', 'Fig width', min=300, max=3000, value=800, step=10)),
                                    column(6,sliderInput('Compare_dataset_get_overview_fig.height', 'Fig height', min=300, max=3000, value=800, step=10)),
                                  ),
                                  fluidRow(
                                    column(6, sliderInput('Compare_dataset_get_overview_label.font.size', 'X/Y label font size', min=1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput('Compare_dataset_get_overview_title.font.size', 'X/Y title font size', min=1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput('Compare_dataset_get_overview_graph.title.font.size', 'Graph title font size', min=1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput('Compare_dataset_get_overview_legend_size', 'Legend font size', min=1, max=10, value=4, step=0.1))
                                  ),
                                  fluidRow(
                                    column(4, colourpicker::colourInput('Compare_dataset_get_overview_highest_colour', 'Colour for the highest value', value='red')),
                                    column(4, colourpicker::colourInput('Compare_dataset_get_overview_lowest_colour', 'Colour for the lowest value', value='blue')),
                                    column(4, colourpicker::colourInput('Compare_dataset_get_overview_zero_colour', 'Colour for zero', value='white')),
                                    column(12, materialSwitch('Compare_dataset_get_overview_white_background', 'Use white background', value=FALSE, status = "success"))
                                  ),
                                  circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                              ),
                              column(12, withSpinner(plotOutput("Compare_dataset_get_overview_barplot", width="100%", height="100%"),  type=5, color='#0dc5c1') )
                            )
                          )                      
                        )
                      )
                    ),
                  ## Compare the one gene
                    tabPanel(strong("Compare one gene"),
                      fluidRow(
                        column(12, # Settings and Inputs
                          box(width=12, collapsible=TRUE, title=strong('Settings and Inputs'), status='info',
                            fluidRow( 
                              column(12, helpText(HTML("Please enter genes here and choose which score you use for the y-axis and the colour of the plot. <br>A bar or scatter plot comparing the score (selected as Y-axis) of each gene across the selected datasets will be generated in the end."))),
                              column(5, 
                                fluidRow(
                                  column(12, textAreaInput("target_gene_for_comparing", "Enter genes (line by line)")),
                                  column(12, materialSwitch('target_gene_for_comparing_Input_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                  conditionalPanel(
                                    condition = "input.target_gene_for_comparing_Input_from_custom_geneset == true",
                                    column(12, htmlOutput('target_gene_for_comparing_Input_from_custom_geneset_select'))
                                  )
                                )
                              ),
                              column(4, 
                                fluidRow(
                                  column(12,htmlOutput("Choose_datasets_y")),
                                  column(12,htmlOutput("Choose_datasets_colour"))
                                )
                              ),
                              column(3, 
                                actionButton("comparison_start", "Start Analysis",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")
                              )
                            )
                          )
                        ),
                        column(4,
                          box(width=12, collapsible=TRUE, title=strong('Input genes'), status='primary',
                            fluidRow(
                              column(12, h5('Select a gene below:')),
                              column(12, withSpinner(dataTableOutput("Gene_comparing_gene_list_table"), type = 5, color='#0dc5c1') )
                            )
                          ),
                          box(width=12, collapsible=TRUE, title=strong('Data information'),  status='warning',
                            fluidRow(
                              column(12, withSpinner(dataTableOutput("dataframe_comparing_dataset"), type=5, color='#0dc5c1') ),
                              column(12, downloadButton('comparing_dataset_download',"Download this table"))
                            )
                          ),
                        ),
                        column(8,
                          box(width=12, collapsible=TRUE, title=strong('Plot'), status='danger',
                            fluidRow(
                              column(12, verbatimTextOutput('Gene_comparing_status')),
                              column(10, radioButtons("bar_or_scatter", "Plot type", choices = c( "Scatter plot", "Bar plot"), selected='Bar plot', inline=TRUE)),
                              column(2,
                                dropdownButton( h4(strong("Plot Options")),
                                  fluidRow(
                                    column(6, sliderInput('Compare_fig.width', 'Fig width', min=300, max=3000, value=850, step=10)),
                                    column(6, sliderInput('Compare_fig.height', 'Fig height', min=300, max=3000, value=800, step=10)),
                                    conditionalPanel(
                                      condition = "input.bar_or_scatter == 'Scatter plot'",
                                      column(6, sliderInput('Compare_pt.size', 'Point size', min=0.1, max=10, value=3, step=0.1))
                                    )
                                  ),
                                  fluidRow(
                                    column(6, sliderInput('Compare_label.font.size', 'X/Y label font size', min=1, max=10, value=4, step=1)),
                                    column(6, sliderInput('Compare_title.font.size', 'X/Y title font size', min=1, max=10, value=4, step=1)),
                                    column(6, sliderInput('Compare_graph.title.font.size', 'Graph title font size', min=1, max=15, value=4, step=1)),
                                    column(6, sliderInput('Compare_label_legend_size', 'Legend font size', min=1, max=15, value=4, step=1)),
                                  ),
                                  fluidRow(
                                    column(4, colourpicker::colourInput('Compare_highest_colour', 'Colour for the highest value', value='red')),
                                    column(4, colourpicker::colourInput('Compare_lowest_colour', 'Colour for the lowest value', value='blue')),
                                    column(4, colourpicker::colourInput('Compare_zero_colour', 'Colour for the zero value', value='white')),
                                  ),
                                  fluidRow(
                                    column(12, materialSwitch('Compare_white_background', 'Use white background', value=FALSE, status = "success"))
                                  ),
                                  circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                              ),
                              column(12, verbatimTextOutput('Gene_comparing_plot_status') ),
                              column(12, withSpinner(plotOutput("Gene_comparing_plot", width="100%", height="100%"), type=5, color='#0dc5c1'))
                            )
                          )
                        )
                      )
                    )
                  ##
                )
              )
            #####
          ),  
        #### Integrate_two_dataset ####
          tabItem( tabName='Integrate_two_dataset', 
            h2(' Integrate two datasets'),
            ## side by side plot
              box(width=12, title='Side by Side comparison', collapsible=TRUE, status='primary', solidHeader = TRUE,
                ## Direction
                  box(width=12, title='Direction', collapsible=TRUE, status='info',
                    radioButtons("Integrate_data_map_direction", "", choices = c('See the selected genes from Data1 onto Data2'='A', 'See the selected genes from Data2 onto Data1'='B'), selected='A')
                  ),
                ## Data1
                  box(width=6, title='Data1', collapsible=TRUE, status='primary',
                    ## data1 selection and setting
                      fluidRow( # data selection and filtering button
                        column(8, htmlOutput("Integrate_data1_select")),
                        column(2, 
                          fluidRow(
                            column(12, h5('')),
                            column(12, h5('')),
                            column(12, 
                              div(id='filterin_dropdown',
                                dropdownButton( 
                                  fluidRow(
                                    column(12, h4(strong("Dataset filtering"))),
                                    column(12, htmlOutput("Integrate_data1_Seuqenced_by")), 
                                    column(12, htmlOutput("Integrate_data1_Experiments")), 
                                    column(12, htmlOutput("Integrate_data1_Data_type"))   
                                  ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "400px",  tooltip = tooltipOptions(title = "Dataset filtering"), right=TRUE
                                )
                              ) 
                            )
                          )
                        )
                      ),                    
                      fluidRow( column(12, h5(strong('Please select x/y axis:')) )),
                      fluidRow(  # X/Y axis selection
                        column(4, htmlOutput("Integrate_data1_Scat.X")), 
                        column(4, htmlOutput("Integrate_data1_Scat.Y")),
                        column(4, 
                          fluidRow(
                            column(12, h4('')),
                            column(12, h4('')),
                            column(12, materialSwitch('Integrate_data1_hide_labels', 'Hide labels', value=TRUE, status='primary')),
                          )
                        )
                      ),
                    ## data1 plot
                      fluidRow( 
                        column(10, verbatimTextOutput('Integrate_data1_plot_status') ),
                        column(2,
                          dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                              column(6,sliderInput('Integrate_data1_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                              column(6,sliderInput('Integrate_data1_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                              column(6, sliderInput('Integrate_data1_pt.size', 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                              column(6, sliderInput('Integrate_data1_high.pt.size', 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                              column(6, sliderInput('Integrate_data1_high.label.size', 'Highlighted labels size', min=0.1, max=5, value=1.5, step=0.1)),
                              column(6, sliderInput('Integrate_data1_label.font.size', 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                              column(6, sliderInput('Integrate_data1_title.font.size', 'X/Y title font size', min=1, max=15, value=4, step=0.1))
                            ),
                            fluidRow(
                              column(6, materialSwitch('Integrate_data1_while_background', 'Use white background', value=TRUE, status = "success")),
                              column(6, colourpicker::colourInput('Integrate_data1_colour_id', 'highlighted dots colour:', value='red'))
                            ),
                            circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                          )
                        ),
                        column(12, withSpinner(plotOutput("Integrate_data1_plot", brush = "Integrate_data1_plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                        column(10,
                          conditionalPanel(
                            condition = "input.Integrate_data_map_direction == 'A' ",
                            div(id='filterin_dropdown',
                              dropdownButton( h4(strong("Gene selection")),
                                fluidRow(
                                  column(4, 
                                    fluidRow(
                                      column(12, radioButtons("Integrate_data1_Gene_selection", "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),
                                    )
                                  ),
                                  conditionalPanel(
                                    condition= "input.Integrate_data1_Gene_selection == 'A' ",
                                    column(8,
                                      fluidRow(
                                        column(6, fluidRow( column(12, numericInput('Integrate_data1_thr_X1', 'X1',  value=1, step=0.1) ), column(12, numericInput('Integrate_data1_thr_X2', 'X2',  value=-1, step=0.1) ) )),
                                        column(6, fluidRow( column(12, numericInput('Integrate_data1_thr_Y1', 'Y1', value=1.3, step=0.1) ), column(12, numericInput('Integrate_data1_thr_Y2', 'Y2', value=0, step=0.1) ) )),
                                        column(6, radioButtons("Integrate_data1_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B')),
                                        column(6, radioButtons("Integrate_data1_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B')),
                                        column(6, materialSwitch('Integrate_data1_hide_threshold', 'Hide threshold line', value=FALSE, status='primary')),
                                      )
                                    )
                                  ),
                                  column(10, verbatimTextOutput('Integrate_data1_selected_gene_num'))
                                ),
                                label='Gene selection', circle = FALSE, status = "primary", icon = icon("sliders"), width = "800px",  tooltip = tooltipOptions(title = "Gene selection")
                              )
                            ) 
                          )
                        )
                      )
                    ##
                  ),
                ## Data2
                  box(width=6, title='Data2', collapsible=TRUE, status='primary',
                    ## data2 selection and setting
                      fluidRow(  # data selection and filtering button
                        column(8, htmlOutput("Integrate_data2_select")),
                        column(2, 
                          fluidRow(
                            column(12, h5('')),
                            column(12, h5('')),
                            column(12, 
                              div(id='filterin_dropdown',
                                dropdownButton( 
                                  fluidRow(
                                    column(12, h4(strong("Dataset filtering"))),
                                    column(12, htmlOutput("Integrate_data2_Seuqenced_by")), 
                                    column(12, htmlOutput("Integrate_data2_Experiments")), 
                                    column(12, htmlOutput("Integrate_data2_Data_type"))   
                                  ),label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "400px",  tooltip = tooltipOptions(title = "Dataset filtering"), right=TRUE
                                )
                              ) 
                            ),
                          )
                        )
                      ),
                      fluidRow( column(12, h5(strong('Please select x/y axis:')))),
                      fluidRow( # X/Y axis selection
                        column(4, htmlOutput("Integrate_data2_Scat.X")), 
                        column(4, htmlOutput("Integrate_data2_Scat.Y")),
                        column(4,
                          fluidRow(
                            column(12, h4('')),
                            column(12, h4('')),
                            column(12, materialSwitch('Integrate_data2_hide_labels', 'Hide labels', value=TRUE, status='primary')),
                          )
                        )
                      ),
                    ## data2 plot
                      fluidRow( 
                        column(10, verbatimTextOutput('Integrate_data2_plot_status') ),
                        column(2,
                          dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                              column(6,sliderInput('Integrate_data2_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                              column(6,sliderInput('Integrate_data2_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                              column(6, sliderInput('Integrate_data2_pt.size', 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                              column(6, sliderInput('Integrate_data2_high.pt.size', 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                              column(6, sliderInput('Integrate_data2_high.label.size', 'Highlighted labels size', min=0.1, max=5, value=1.5, step=0.1)),
                              column(6, sliderInput('Integrate_data2_label.font.size', 'X/Y label font size', min=1, max=15, value=4, step=0.1)),
                              column(6, sliderInput('Integrate_data2_title.font.size', 'X/Y title font size', min=1, max=15, value=4, step=0.1)),
                            ),
                            fluidRow(
                              column(6, materialSwitch('Integrate_data2_while_background', 'Use white background', value=TRUE, status = "success")),
                              column(6, colourpicker::colourInput('Integrate_data2_colour_id', 'highlighted dots colour:', value='red'))
                            ),
                            circle = FALSE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                          )
                        ),
                        column(12, withSpinner(plotOutput("Integrate_data2_plot", brush = "Integrate_data2_plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                        column(10,
                          conditionalPanel(
                            condition = "input.Integrate_data_map_direction == 'B' ",
                            div(id='filterin_dropdown',
                              dropdownButton( h4(strong("Gene selection")),
                                fluidRow(
                                  column(4, 
                                    fluidRow(
                                      column(12, radioButtons("Integrate_data2_Gene_selection", "Method", choices = c('Use a threshold for filtering'='A', 'Manual selection'='B'), selected='A')),
                                    ),
                                  ),
                                  conditionalPanel(
                                    condition= "input.Integrate_data2_Gene_selection == 'A' ",
                                    column(8,
                                      fluidRow(
                                        column(6, fluidRow( column(12, numericInput('Integrate_data2_thr_X1', 'X1',  value=1, step=0.1) ), column(12, numericInput('Integrate_data2_thr_X2', 'X2',  value=-1, step=0.1) ) )),
                                        column(6, fluidRow( column(12, numericInput('Integrate_data2_thr_Y1', 'Y1', value=1.3, step=0.1) ), column(12, numericInput('Integrate_data2_thr_Y2', 'Y2', value=0, step=0.1) ) )),
                                        column(6, radioButtons("Integrate_data2_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='B')),
                                        column(6, radioButtons("Integrate_data2_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='B')),
                                        column(6, checkboxInput('Integrate_data2_hide_threshold', 'Hide threshold line', value=FALSE)),
                                      )
                                    )
                                  ),
                                  column(10, verbatimTextOutput('Integrate_data2_selected_gene_num'))
                                ),
                                label='Gene selection', circle = FALSE, status = "primary", icon = icon("sliders"), width = "800px",  tooltip = tooltipOptions(title = "Gene selection")
                              )
                            )   
                          )
                        )
                    ),
                    ##
                  ),
                ## display overlap genes
                  box(width=12, title='Overlap genes', collapsible=TRUE, status='warning', collapsed = TRUE,
                    fluidRow(
                      column(12, 
                        helpText(HTML('A list of genes that meet the filter settings in both datasets is displayed here.
                          <br>Please set the threshoolds for the data to which the selected genes are mapped.'))
                      )
                    ),
                    fluidRow(
                      column(12, 
                        div(id='filterin_dropdown',
                          dropdownButton( 
                            fluidRow( column(12, h4(strong('Set the filtering for the mapped side'))),
                              column(3, fluidRow( column(12, numericInput('Integrate_data_mapped_thr_X1', 'X1',  value=1, step=0.1) ), column(12, numericInput('Integrate_data_mapped_thr_X2', 'X2',  value=-1, step=0.1) ) ) ), 
                              column(3, fluidRow( column(12, numericInput('Integrate_data_mapped_thr_Y1', 'Y1',  value=1, step=0.1) ), column(12, numericInput('Integrate_data_mapped_thr_Y2', 'Y2',  value=-1, step=0.1) ) )  ),
                              column(3, radioButtons("Integrate_data_mapped_thr_X_method", "X filter", choices = c("none"='A', "X > X1"='B', "X < X2"='C', "X2 < X < X1"='D', "X < X2 or X > X1"='E'), selected='A')),
                              column(3, radioButtons("Integrate_data_mapped_thr_Y_method", "Y filter", choices = c("none"='A', "Y > Y1"='B', "Y < Y2"='C', "Y2 < Y < Y1"='D', "Y < Y2 or Y > Y1"='E'), selected='A')),
                              column(6, materialSwitch('Integrate_data_mapped_hide_threshold', 'Hide threshold line', value=FALSE, status='primary'))
                            ),label='The filtering for the mapped side', circle = FALSE, status = "primary", icon = icon("sliders"), width = "900px",  tooltip = tooltipOptions(title = "Dataset filtering")
                          )
                        ) 
                      )
                    ),
                    fluidRow(column(12, h5(''))),
                    fluidRow(
                      column(12, h4('Overlap genes table') ),
                      column(12, verbatimTextOutput('Integrate_Overlapped_gene_table_status') ),
                      column(12, dataTableOutput("Integrate_Overlapped_gene_table") ),
                    ),
                    fluidRow(
                      column(3, downloadButton('Integrate_Overlapped_gene_table_download',"Download this table")),
                      column(5, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Integrate_Overlapped_gene_list') ))
                    )
                  )
                ##
              ),
            ## integration plot
              box(width=12, title='Integration Plot', collapsible=TRUE, status='primary', solidHeader = TRUE,
                fluidRow(
                  column(6, # Plot
                    box(width=12, title='Plot', status='danger', 
                      fluidRow( 
                        column(6, htmlOutput("Integrate_data1_plus_2_Scat.X")), 
                        column(6, htmlOutput("Integrate_data1_plus_2_Scat.Y")),
                        column(6, htmlOutput("Integrate_data1_plus_2_Scat.colour"))
                      ),
                      fluidRow(
                        column(10, verbatimTextOutput('Integrate_data1_plus_2_plot_status')),
                        column(2,
                          dropdownButton( h4(strong("Plot Options")),
                            fluidRow(
                              column(6,sliderInput('Integrate_data1_plus_2_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                              column(6,sliderInput('Integrate_data1_plus_2_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                              column(6,sliderInput('Integrate_data1_plus_2_XY_label_size', 'X/Y label size', min=1, max=10, value=5, step=0.1)),
                              column(6,sliderInput('Integrate_data1_plus_2_XY_title_size', 'X/Y title size', min=1, max=10, value=5, step=0.1)),
                              column(6,sliderInput('Integrate_data1_plus_2_dot_label_size', 'Point size', min=0.01, max=5, value=0.1, step=0.01)),
                              column(6,sliderInput('Integrate_data1_plus_2_highlight_dot_size', 'Highlighted points size', min=0.01, max=5, value=0.25, step=0.01)),
                              column(6,sliderInput('Integrate_data1_plus_2_id_size', 'Label size', min=0.1, max=5, value=1, step=0.1)),
                            ),
                            fluidRow(
                              column(6, materialSwitch('Integrate_data1_plus_2_white_background', 'Use white background', value=FALSE, status='success'))
                            ),
                            circle = FALSE, status = "success", icon = icon("gear"), width = "600px",   tooltip = tooltipOptions(title = "Plot Options")
                          )
                        ),
                        column(12, withSpinner(plotOutput("Integrate_data1_plus_2_plot", brush = "Integrate_data1_plus_2_plot_brush", width="100%", height="100%"), type=5, color='#0dc5c1'))
                      )
                    )
                  ),
                  column(6,  # Display options
                    box(width=12, title='Display options', collapsible=TRUE,status='info',
                      fluidRow(
                        column(9, textAreaInput("Integrate_data1_plus_2_target_gene", "Enter gene(s) of interest (line by line)"))
                      ),
                      fluidRow(
                        column(12, materialSwitch('Integrate_data1_plus_2_target_gene_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                        conditionalPanel(
                          condition = "input.Integrate_data1_plus_2_target_gene_from_custom_geneset == true",
                          column(10, htmlOutput('Integrate_data1_plus_2_target_gene_from_custom_geneset_select'))
                        )
                      ),
                      fluidRow(
                        column(7, materialSwitch('Integrate_data1_plus_2_change_colour', 'Change colour of the selected genes', value=FALSE, status='info')),
                        conditionalPanel(
                          condition = "input.Integrate_data1_plus_2_change_colour == true",
                          column(4, colourpicker::colourInput('Integrate_data1_plus_2_target_gene_colour', 'Colour of the selected genes:', value='red'))
                        ),
                      ),
                      fluidRow(
                        column(4, materialSwitch('Integrate_data1_plus_2_show_gene_name', 'Show gene names', value=TRUE, status='info') ),
                      ),
                      fluidRow(
                        column(12, h4('Filtering')),
                        column(12, materialSwitch('Integrate_data1_plus_2_plot_use_geneset', 'Use pathway genes', value=FALSE, status='info')),
                        column(12,
                          conditionalPanel(
                            condition = "input.Integrate_data1_plus_2_plot_use_geneset == true",
                            fluidRow(
                              column(4, radioButtons("Integrate_data1_plus_2_plot_pathway_dataset_select", "pathways from:", choices = c("HALLMARK (human)", "HALLMARK (mouse)", "Custom"))),
                              column(8,
                                fluidRow(
                                  column(12, 
                                    conditionalPanel( 
                                      condition = "input.Integrate_data1_plus_2_plot_pathway_dataset_select == 'Custom'", 
                                      fileInput("Integrate_data1_plus_2_plot_upload_custom_pathway_file", "Upload a gmt file")
                                    )
                                  ),
                                  column(12, htmlOutput("Integrate_data1_plus_2_plot_select_pathway"))
                                )
                              )
                            )
                          )
                        ),
                        column(6, 
                          fluidRow(
                            column(12, numericInput('Integrate_data1_plus_2_plot_xthr1', 'X threshold 1 (X1)', value=1, step=0.1 ) ),
                            column(12, numericInput('Integrate_data1_plus_2_plot_xthr2', 'X threshold 2 (X2)', value=-1, step=0.1 ) )
                          ),
                          fluidRow(
                            column(12, radioButtons('Integrate_data1_plus_2_plot_xselect', 'Select how to filter X', choices=c("None"= "E", "X > X1" = "A", "X < X2"= "B", "X2 < X < X1"="C", "X < X2 or X > X1"="D"), selected="E"))
                          )
                        ),
                        column(6, 
                          fluidRow(
                            column(12, numericInput('Integrate_data1_plus_2_plot_ythr1', 'Y threshold 1 (Y1)', value=1, step=0.1 ) ),
                            column(12, numericInput('Integrate_data1_plus_2_plot_ythr2', 'Y threshold 2 (Y2)', value=-1, step=0.1 ) )
                          ),
                          fluidRow(
                            column(12, radioButtons('Integrate_data1_plus_2_plot_yselect', 'Select how to filter Y', choices=c("None"= "E", "Y > Y1" = "A", "Y < Y2"="B", "Y2 < Y < Y1"="C", "Y < Y2 or Y > Y1"="D"), selected="E"))
                          )
                        ),
                        column(12, materialSwitch('Integrate_data1_plus_2_plot_filter_label', 'Hide labels', value=FALSE, status='info') )
                      )
                    )
                  ),
                  column(12, # Filtered area
                    box(width=12, title='Filtered area', collapsible=TRUE, collapsed=TRUE,status='warning',
                      fluidRow(column(12, verbatimTextOutput('Integrate_data1_plus_2_filtered_status'))),
                      fluidRow(column(12, dataTableOutput("Integrate_data1_plus_2_filtered"))),
                      fluidRow(column(12, h4(''))),
                      fluidRow(
                        column(4, downloadButton('Integrate_data1_plus_2_filtered_download',"Download this table")),
                        column(4, box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Integrate_data1_plus_2_filtered_gene_list') ))
                      )
                    )
                  ),
                  column(12, #Selected area
                    box(width=12, title='Selected area', collapsible=TRUE,status='warning',
                      fluidRow(column(12, dataTableOutput("Integrate_data1_plus_2_selected"))),
                      fluidRow(
                        column(4, downloadButton('Integrate_data1_plus_2_selected_download',"Download this table")),
                        column(4, 
                          box(width=12, collapsible = TRUE, collapsed = TRUE, title='List of the genes', verbatimTextOutput('Integrate_data1_plus_2_selected_gene_list') )
                        )
                      )
                    )
                  )
                )
              )
            ##
          ),
        #### Clinical_dataset ####
          tabItem( tabName = 'Clinical_dataset',
            h2(' Clinical data'),
            ##### Dataset selection #####
              box(width=12, title='Data selection', status='info', solidHeader = TRUE,
                fluidRow( 
                  column(4, htmlOutput("Clinical_data_select")) ,
                  column(8, 
                    fluidRow(
                      column(12, h5('Dataset detail:')),
                      column(12, withSpinner(verbatimTextOutput('Clinical_Dataset_detail'), type = 5, color = "#0dc5c1" ))
                    )
                  )
                ),
              ),
            ##### Analysis part #####
              box(width=12, status='primary', solidHeader = TRUE, title='Overview and Analysis', collapsible=TRUE,
                tabsetPanel(
                  ###### view database ######
                    tabPanel(strong("View the data"),
                      tabsetPanel(
                        tabPanel("Gene expression", 
                          box(width=12,
                            fluidRow(column(12, h5(''))),
                            fluidRow(column(12, verbatimTextOutput('Clinical_View_Geneexpression_status') )), 
                            fluidRow(
                              column(12, radioButtons('Clinical_View_EX_show_number', '', c("Show the first 1000 headers"='A', 'Show everything (the server will be overloaded depending on the size of the data)'='B'), selected='A'))
                            ),
                            fluidRow(column(12, DT::dataTableOutput("Clinical_View_Geneexpression")) )
                          )
                        ),
                        tabPanel("Survival", 
                          box(width=12,
                            fluidRow(column(12, h5(''))),
                            fluidRow(column(12, verbatimTextOutput('Clinical_View_Survival_status') )), 
                            fluidRow(column(12, DT::dataTableOutput("Clinical_View_Survival") ))
                          )
                        ),
                        tabPanel("Meta data", 
                          box(width=12,
                            fluidRow(column(12, h5(''))),
                            fluidRow(column(12, verbatimTextOutput('Clinical_View_MetaData_status') )), 
                            fluidRow(column(12, DT::dataTableOutput("Clinical_View_MetaData") ))
                          )
                        ),
                        tabPanel("Mutation data", 
                          box(width=12,
                            fluidRow(column(12, h5(''))),
                            fluidRow(column(12, verbatimTextOutput('Clinical_View_mutation_status') )),
                            fluidRow(column(12, DT::dataTableOutput("Clinical_View_Mutation") ))
                          )
                        )
                      )
                    ),
                  ###### Survival analysis ######
                    tabPanel(strong("Survival analysis"),
                      fluidRow(
                        column(12,
                          box(width=12, status='info', title='Inputs and Settings',
                            fluidRow(
                              column(4, 
                                fluidRow(
                                  column(12, textAreaInput('Clinical_Survival_genes', 'Enter genes (line by line)') ),
                                  column(12, materialSwitch('Clinical_Survival_genes_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = "input.Clinical_Survival_genes_from_custom_geneset == true",
                                      htmlOutput('Clinical_Survival_genes_from_custom_geneset_select')
                                    )
                                  )
                                )                            
                              ),
                              column(5,
                                fluidRow(
                                  column(12, radioButtons('Clinical_Survival_Split_way', 'Split the samples by:', choices = c('Median'='A', 'Top 25% vs Bottom 25%'='B', 'Top X% vs Bottom Y%'='D' ,'Custom grouping (No need to enter/set genes)'='C'),selected='A') ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = "input.Clinical_Survival_Split_way == 'C'",
                                      fluidRow(
                                        column(6, textAreaInput('Clinical_Survival_Split_Group1', 'Enter sample names for Group 1 (line by line)') ),
                                        column(6, textAreaInput('Clinical_Survival_Split_Group2', 'Enter sample names for Group 2 (line by line)') )
                                      )
                                    )
                                  ),
                                  column(12,
                                    conditionalPanel(
                                      condition = "input.Clinical_Survival_Split_way == 'D'",
                                      fluidRow(
                                        column(6, numericInput('Clinical_Survival_Split_Group1_perc', 'Top X%:', value=25, min=0, max=100, step=1) ),
                                        column(6, numericInput('Clinical_Survival_Split_Group2_perc', 'Bottom Y%:', value=25, min=0, max=100, step=1) )
                                      )
                                    )
                                  )
                                )
                              ),
                              column(2,
                                fluidRow(
                                  column(12, htmlOutput('Clinical_Survival_choose_score_type')),
                                  column(12, h3('')),
                                  column(12, actionButton('Clinical_Survival_start', 'Start the survival analysis',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                                )
                              ),
                              column(1,
                                div(id='help',
                                  dropdownButton( 
                                    fluidRow(
                                      column(12, h4(strong("Quick guide"))),
                                      column(12, helpText(
                                        HTML("
                                          0. Select a cohort.<br>
                                          1. Set the input. Enter gene names in the text box or select from the custom gene sets. <br>
                                          2. Select the way to split the samples. <br>
                                          3. Select the type of event for the survival analysis. <br>
                                          4. Click the 'Start the survival analysis' button to run the analysis.<br>
                                          5. A table containing the p value and the hazard ratio for each gene will be displayed in the 'Results' section below.<br>
                                          6. By clicking a gene (row) in the table, the Kaplan-Meier curve and the histogram of the expression distribution will be displayed in the 'Plots' section.<br>                                      
                                        "))
                                      ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                  ),
                                ) 
                              )
                            ),
                            fluidRow(
                              column(8, verbatimTextOutput('Clinical_Survial_all_status') )
                            )
                          )
                        )
                      ),
                      fluidRow(
                        column(4, 
                          box(width=12, status='warning', title='Results (Hazard Ratios)',
                            fluidRow(
                              column(12, withSpinner(verbatimTextOutput('Clinical_Survial_table_status'), type = 5, color = "#0dc5c1" ) ),
                              column(12, withSpinner(dataTableOutput("Clinical_Survial_table"), type = 5, color = "#0dc5c1" ) ),
                              column(12, h4('')),
                              column(12, downloadButton('Clinical_Survial_table_download',"Download this table") )
                            )
                          )
                        ),
                        column(8, 
                          box(width=12, status='danger', title='Plots',
                            tabsetPanel(
                              tabPanel("Kaplan-Meier curve",
                                fluidRow(
                                  column(12, h4('')),
                                  column(10, verbatimTextOutput('Clinical_Survial_plot_error_catch') ),
                                  column(2,
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Survial_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Clinical_Survial_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(4,sliderInput('Clinical_Survial_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(4,sliderInput('Clinical_Survial_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(4,sliderInput('Clinical_Survial_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(5, colourpicker::colourInput('Clinical_Survial_High_colour', 'Colour for the "High" group:', value='#ec00ec')),
                                        column(5, colourpicker::colourInput('Clinical_Survial_Low_colour', 'Colour for the "Low" group:', value='#00aaff')),
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput("Clinical_Survial_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
                                )
                                
                              ),
                              tabPanel("Expression distribution (histogram)",
                                fluidRow(
                                  column(12, h4('')),
                                  column(10, verbatimTextOutput('Clinical_Survial_plot_distribution_status') ),
                                  column(2,
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Survial_distribution_fig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                        column(6,sliderInput('Clinical_Survial_distribution_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                      ),
                                      fluidRow(
                                        column(4,sliderInput('Clinical_Survial_distribution_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(4,sliderInput('Clinical_Survial_distribution_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(4,sliderInput('Clinical_Survial_distribution_graphtitle_size', 'Graph title size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(4, colourpicker::colourInput('Clinical_Survial_distribution_colour', 'Colour:', value='#006FED')),
                                        column(4, sliderInput('Clinical_Survial_distribution_bin_num', 'Bin number', min=10, max=100, value=20, step=1)),
                                        column(4, materialSwitch('Clinical_Survial_distribution_white_background', 'Use white background', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                                    ),
                                  ),
                                  column(12, withSpinner(plotOutput("Clinical_Survial_distribution_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ) ),
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Gene correlation ######
                    tabPanel(strong("Gene correlation"),
                      fluidRow(
                        column(12, 
                          box(width=12, status='info', title='Inputs and Settings',
                            fluidPage(
                              column(7, 
                                fluidRow(
                                  column(12, radioButtons('Gene_correlation_genes_comparison_type', 'Explore type', choices=c("Explore one gene's correlation with all the genes"='A', "Explore one gene's correlation with specific genes"='B'),selected='B')),
                                  column(12, 
                                    conditionalPanel(
                                      condition="input.Gene_correlation_genes_comparison_type == 'A'",
                                      h5(span('This calculates the correlation with all the genes. It takes 2~4 minutes. Please be patient.', style="color: orange;"))
                                    ) 
                                  )
                                ),
                                fluidRow(
                                  column(5, 
                                    textInput('Gene_correlation_genes', 'Enter *ONE* gene (Y-axis)')
                                  ),
                                  column(7, 
                                    conditionalPanel(
                                      condition="input.Gene_correlation_genes_comparison_type == 'B'",
                                      fluidRow(
                                        column(9, textAreaInput('Gene_correlation_genes_y', 'Enter genes (X-axis) (line by line)')),
                                        column(3, h3('')),
                                        column(12, materialSwitch('Gene_correlation_genes_y_from_custom_geneset', 'or use the genes from the custom gene sets', value=FALSE, status='info') ),
                                        conditionalPanel(
                                          condition = "input.Gene_correlation_genes_y_from_custom_geneset == true",
                                          column(12, htmlOutput('Gene_correlation_genes_y_from_custom_geneset_select'))
                                        )
                                      )
                                    )
                                  )
                                )
                              ), 
                              column(2, 
                                fluidRow(
                                  column(12, radioButtons('Gene_correlation_Corralation_method', 'Method for correlation', choices = c('pearson', 'spearman'),selected='pearson')),
                                  column(12, h4('')),
                                  column(12, h4('')),
                                  column(12, actionButton("Gene_correlation_start", "Calculate the correlation",style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                                )
                              ),
                              column(2, h4('')),
                              column(1,
                                div(id='help',
                                  dropdownButton( 
                                    fluidRow(
                                      column(12, h4(strong("Quick guide"))),
                                      column(12, 
                                        helpText(
                                          HTML("0. Select a cohort. <br>
                                            1. Select 'Explore type'. <br>
                                            2. Enter ONE gene. This gene's expression will be on the Y-axis. <br>
                                            3. Select the method for correlation. <br>
                                            4. Click the 'Calculate the correlation' button to run the analysis. <br>
                                            5. A table of the p-value and the correlation score for each gene will be displayed in the 'Correlation table' section below. <br>
                                            6. By selecting a gene in the table, a scatter plot will be displayed in the 'Scatter plot' section.
                                            ")
                                          )
                                      ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                  ),
                                )
                              )
                            ),
                            fluidRow(
                              column(8,  verbatimTextOutput('Gene_correlation_all_status') )
                            )
                          ),
                        )
                      ),
                      fluidRow(
                        column(4, 
                          box(width=12, status='warning', title='Correlation table',
                            fluidRow(
                              column(12, h4('') ),
                              column(12, withSpinner(verbatimTextOutput('Gene_correlation_table_status'), type = 5, color = "#0dc5c1" )),
                              column(12, withSpinner(DT::dataTableOutput("Gene_correlation_table"), type = 5, color = "#0dc5c1" ) ),
                              column(12, h4('') ),
                              column(12, downloadButton('Gene_correlation_table_download',"Download this table") )
                            )
                          )
                        ),
                        column(8, 
                          box(width=12, status='danger', title='Scatter plot',
                            fluidRow(
                              column(12, h4('') ),
                              column(10, verbatimTextOutput('Gene_correlation_error_catch') ),
                              column(2, 
                                dropdownButton( h4(strong("Plot Options")),
                                  fluidRow(
                                    column(6,sliderInput('Gene_correlation_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                    column(6,sliderInput('Gene_correlation_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                  ),
                                  fluidRow(
                                    column(6,sliderInput('Gene_correlation_label_size', 'X/Y label size', min=0.1, max=10, value=5, step=0.1)),
                                    column(6,sliderInput('Gene_correlation_title_size', 'X/Y title size', min=0.1, max=10, value=5, step=0.1)),
                                  ),
                                  fluidRow(
                                    column(4, colourpicker::colourInput('Gene_correlation_colour', 'Colour of the dots:', value='#ec00ec')),
                                    column(4, materialSwitch('Gene_correlation_show_correlation_line', 'Show the correlation line', value=TRUE, status = "success")),
                                    column(4, materialSwitch('Gene_correlation_white_background', 'Use white background', value=FALSE, status = "success"))
                                  ),
                                  circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                              ),
                              column(12, withSpinner(plotOutput("Gene_correlation_scatter_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
                            )
                          )
                        )
                      )
                    ),
                  ###### Mutation analysis ###### 
                    tabPanel(strong("Mutation analysis"),
                      fluidRow(
                        # Inputs
                        column(12, 
                          box(width=12,status='info', title='Inputs and Settings', collapsible=TRUE,
                            fluidRow(
                              column(4,
                                fluidRow(
                                  column(12, radioButtons('Clinical_Mutation_gene_input', 'Genes input from:', choices=c("Text input" = 'A', "Use all genes"='B', "Select from custom genesets"='C'), selected='A') ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = 'input.Clinical_Mutation_gene_input == "A"',
                                      textAreaInput('Clinical_Mutation_gene', 'Enter genes (line by line)')
                                    ),
                                  ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = 'input.Clinical_Mutation_gene_input == "C"',
                                      htmlOutput('Clinical_Mutation_gene_from_custom')
                                    )
                                  )
                                )
                              ),
                              column(4, 
                                fluidRow(
                                  column(12, radioButtons('Clinical_Mutation_frequency_filter', 'Sample filtering:', choices=c("Use all samples"='A', "Use the selected samples by a specific category"='B'), selected='A') ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = 'input.Clinical_Mutation_frequency_filter == "B"',
                                      fluidRow(
                                        column(12, htmlOutput('Clinical_Mutation_frequency_filter_selection')),
                                        column(12, htmlOutput('Clinical_Mutation_frequency_filter_selection_category')),
                                        column(12, verbatimTextOutput('Clinical_Mutation_frequency_filter_selection_number')),
                                      ),  
                                    )
                                  )
                                )
                              ),
                              column(2, 
                                fluidRow(column(12, h3(''))),
                                fluidRow(column(12, actionButton('Clinical_Mutation_plot_start', "Calculate the mutation frequency", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")))
                              ),
                              column(1, h4('')),
                              column(1,
                                div(id='help',
                                  dropdownButton( 
                                    fluidRow(
                                      column(12, h4(strong("Quick guide"))),
                                      column(12, helpText(
                                        HTML("
                                          0. Select a cohort.<br>
                                          1. Set the input. <br>
                                          2. (Optional) Filter the samples by category if needed.<br>
                                          3. Click the 'Calculate the mutation frequency'. A mutation frequency table and its bar plot will be generated below. <br>
                                          4. By clicking a gene (row) in the table, the Kaplan-Meier curve  will be displayed in the 'Survival analysis' tab in the 'Plots' section.<br>
                                          5. For the 'Gene expression' tab: <br>
                                            - Select a gene from the mutation frequency table. <br>
                                            - Set the input genes <br>
                                            - Click a gene in the table below to compare expression between the mutant and wild-type groups of the gene selected from the mutation frequency table.
                                        "))
                                      ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                  ),
                                ) 
                              ),
                              column(12, h4(''))
                            ),
                            fluidRow(
                              column(8, verbatimTextOutput('Clinical_Mutation_frequency_plot_status'))
                            )
                          ),
                        ),
                        # Results
                        column(4, 
                          box(width=12, status='warning', title='Results (Mutation Frequency table)', collapsible=TRUE,
                            fluidRow(
                              column(12, verbatimTextOutput('Clinical_Mutation_frequency_plot_status_table') ),
                              column(12, withSpinner(dataTableOutput("Clinical_Mutation_frequency_table"), type = 5, color = "#0dc5c1" ))
                            )
                          )
                        ),
                        # Plots
                        column(8, 
                          box(width=12, status='danger', title='Plots', collapsible=TRUE,
                            tabsetPanel(
                              tabPanel('Frequency Plot',
                                fluidRow(
                                  column(12, h3('')),
                                  column(6, radioButtons('Clinical_Mutation_frequency_plot_type', 'Y axis:', choices=c("Number of patients having mutations"='A', "Percentage of patients hacing mytations"='B'), selected='A') ),
                                  column(3, numericInput('Clinical_Mutation_frequency_plot_top_X', 'Show top X frequntly mutated genes:', min=1, value=15, step=1) ),
                                  column(3, h4('') ),
                                  column(10, verbatimTextOutput('Clinical_Mutation_frequency_plot_status_plot') ),
                                  column(2,
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Mutation_frequency_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                                        column(6,sliderInput('Clinical_Mutation_frequency_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Mutation_frequency_label_size', 'X label size', min=1, max=15, value=2.5, step=0.1)),
                                        column(6,sliderInput('Clinical_Mutation_frequency_title_size', 'Y lable/title size', min=1, max=15, value=5, step=0.1)),
                                        column(6,sliderInput('Clinical_Mutation_frequency_legend_size', 'Legend font size', min=1, max=15, value=4, step=0.1)),
                                        column(6,sliderInput('Clinical_Mutation_frequency_score_size', 'Score font size', min=0.1, max=5, value=1, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, colourpicker::colourInput('Clinical_Mutation_frequency_colour_high', 'Colour of the highest value:', value='#e14b22')),
                                        column(6, colourpicker::colourInput('Clinical_Mutation_frequency_colour_zero', 'Colour of 0:', value='#ffffff')),
                                        column(6, materialSwitch('Clinical_Mutation_frequency_white_background', 'Use white background', value=FALSE, status = "success")),
                                        column(6, materialSwitch('Clinical_Mutation_frequency_hide_score', 'Hide the scores', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    ),
                                  ),
                                  column(12, withSpinner(plotOutput('Clinical_Mutation_frequency_plot', width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                )
                              ),
                              tabPanel('Survival analysis (Kaplan-Meier Plot)',
                                fluidRow(
                                  column(12, h3('') ),
                                  column(10, verbatimTextOutput('Clinical_Mutation_Kaplan_plot_status') ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Mutation_Kaplan_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Clinical_Mutation_Kaplan_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Clinical_Mutation_Kaplan_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Clinical_Mutation_Kaplan_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Clinical_Mutation_Kaplan_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, colourpicker::colourInput('Clinical_Mutation_Kaplan_High_colour', 'Colour for the "High" group:', value='#ec00ec')),
                                        column(6, colourpicker::colourInput('Clinical_Mutation_Kaplan_Low_colour', 'Colour for the "Low" group:', value='#00aaff')),
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(5, htmlOutput('Clinical_Mutation_Kaplan_choose_score_type')),
                                  column(6, h4('')),
                                  column(12, withSpinner(plotOutput('Clinical_Mutation_Kaplan_plot', width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                )
                              ),
                              tabPanel('Gene expression',
                                fluidRow(
                                  column(12, h3('') ),
                                  column(12, 
                                    box(width=12, title='Input and Setting', status='info', collapsible=TRUE,
                                      fluidRow(
                                        column(5, 
                                          fluidRow(
                                            column(12, textAreaInput('Clinical_Mutation_Gene_expression_geneInput', 'Enter genes (line by line)')),
                                            column(12, materialSwitch('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                            conditionalPanel(
                                              condition = "input.Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset == true",
                                              column(12, htmlOutput('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select'))
                                            )
                                          )
                                        ),
                                        column(2, h4('')),
                                        column(5, radioButtons('Clinical_Mutation_Gene_expression_plot_type', 'Plot type', c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot' = 'D'), selected='A')),
                                      ),
                                    ),
                                  ),
                                  column(3, 
                                    box(width=12, title='Input genes table', status='primary', collapsible=TRUE,
                                      fluidRow(
                                        column(12, verbatimTextOutput("Clinical_Mutation_Gene_expression_geneInput_selecttable_status")),
                                        column(12, withSpinner(dataTableOutput("Clinical_Mutation_Gene_expression_geneInput_selecttable"), type = 5, color = "#0dc5c1" ) )
                                      )
                                    )
                                  ),
                                  column(9,
                                    box(width=12, title='Plot for Gene expression comaprison', status='danger', collapsible=TRUE,
                                      column(10, verbatimTextOutput('Clinical_Mutation_Gene_expression_geneInput_plot_status')),
                                      column(2, 
                                        dropdownButton( h4(strong("Plot Options")),
                                          fluidRow(
                                            column(6,sliderInput('Clinical_Mutation_Gene_expression_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                            column(6,sliderInput('Clinical_Mutation_Gene_expression_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                          ),                                  
                                          fluidRow(
                                            column(6, sliderInput('Clinical_Mutation_Gene_expression_dot.size', 'Dot size (swarm plot)', min=0.01, max=3, value=0.1, step=0.01)),
                                            column(6, sliderInput('Clinical_Mutation_Gene_expression_XY_label.font.size', 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput('Clinical_Mutation_Gene_expression_XY_title.font.size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput('Clinical_Mutation_Gene_expression_legend.font.size', 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                            column(6, sliderInput('Clinical_Mutation_Gene_expression_title.font.size', 'Graph title font size', min=0.1, max=10, value=4, step=0.1))
                                          ),
                                          fluidRow(
                                            column(6, colourpicker::colourInput('Clinical_Mutation_Gene_expression_col_mut', 'Colour (mutation)', value='#cd0202')),
                                            column(6, colourpicker::colourInput('Clinical_Mutation_Gene_expression_col_wt', 'Colour (wild type)', value='#3f48ee')),
                                          ),
                                          fluidRow(
                                            column(6, materialSwitch('Clinical_Mutation_Gene_expression_white_background', 'Use white background', value=FALSE, status = "success"))
                                          ),
                                          circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                        )
                                      ),
                                      column(12, withSpinner(plotOutput('Clinical_Mutation_Gene_expression_geneInput_plot', width="100%", height="100%"), type = 5, color = "#0dc5c1" ))                                      
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Gene expression compare ######
                    tabPanel(strong("Gene expression acrosss subtype"),
                      fluidRow(
                        column(12, 
                          # input
                          box(width=12, title='Input and Settings', status='info', collapsible=TRUE,
                            fluidRow(
                              column(4, 
                                fluidRow(
                                  column(12, textAreaInput('Expression_subtype_genes', 'Enter genes (line by line)')),
                                  column(12, materialSwitch('Expression_subtype_genes_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                  column(12,
                                    conditionalPanel(
                                      condition = "input.Expression_subtype_genes_from_custom_geneset == true",
                                      htmlOutput('Expression_subtype_genes_from_custom_geneset_select')
                                    )
                                  )
                                )
                              ),
                              column(4, 
                                fluidRow(
                                  column(12, htmlOutput('Expression_subtype_groupBy') ),
                                  column(12, verbatimTextOutput('Expression_subtype_subtype_number') ),
                                  column(12, h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: red;")))
                                )
                              ),
                              column(2, 
                                fluidRow(
                                  column(12, h3('') ),
                                  column(12, actionButton('Expression_subtype_start', 'Start comparing',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                                )
                              ),
                              column(1, h4('')),
                              column(1,
                                div(id='help',
                                  dropdownButton( 
                                    fluidRow(
                                      column(12, h4(strong("Quick guide"))),
                                      column(12, helpText(
                                        HTML("
                                          0. Select a cohort.<br>
                                          1. Set the input. <br>
                                          2. Select a category for grouping the samples.<br>
                                          3. Click the 'Start comparing'. A test result (table) will be shown in below. <br>
                                          4. By clicking a gene (row) in the table, a box plot (by default) will be displayed in the 'Plots' section.<br>
                                        "))
                                      ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                  ),
                                ) 
                              )
                            ),
                            fluidRow(
                              column(8, verbatimTextOutput('Expression_subtype_status'))
                            )
                          )
                        ),
                        # Results
                        column(4,
                          box(width=12, title='Test Results', status='warning', collapsible=TRUE,
                            fluidRow(
                              column(12, h4('') ),
                              column(12, verbatimTextOutput('Expression_subtype_table_status') ),
                              column(12, withSpinner(dataTableOutput("Expression_subtype_table"), type = 5, color = "#0dc5c1" )),
                              column(12, downloadButton('Expression_subtype_table_download',"Download this table") )
                            )
                          )
                        ),
                        # Plots
                        column(8, 
                          box(width=12, title='Plot', status='danger', collapsible=TRUE,
                            fluidRow(
                              column(12, verbatimTextOutput('Expression_subtype_note')), 
                              column(10, radioButtons('Expression_subtype_figtype', 'Figure type:', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A', inline=TRUE) ),
                              column(2,
                                dropdownButton( h4(strong("Plot Options")),
                                  fluidRow(
                                    column(6, sliderInput('Expression_subtype_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                    column(6, sliderInput('Expression_subtype_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                    conditionalPanel(
                                      condition = "input.Expression_subtype_figtype == 'C' || input.Expression_subtype_figtype == 'D'",
                                      column(6, sliderInput('Expression_subtype_dot.size', 'Dot size (swarm plot)', min=0.1, max=5, value=1, step=0.1))
                                    )
                                  ),
                                  fluidRow(
                                    column(6, sliderInput('Expression_subtype_XY_label.font.size', 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput('Expression_subtype_XY_title.font.size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                    column(6, sliderInput('Expression_subtype_title.font.size', 'Graph title font size', min=0.1, max=10, value=4, step=0.1))
                                  ),
                                  fluidRow(
                                    column(6, materialSwitch('Expression_subtype_white_background', 'Use white background', value=FALSE, status = "success")),
                                    column(6, materialSwitch('Expression_subtype_rotate_x', 'Rotate X axis label', value=FALSE, status = "success"))
                                  ),
                                  fluidRow(
                                    column(6, materialSwitch('Expression_subtype_change_colour_pallete', 'Change the colour pallete', value=FALSE, status = "success")),
                                    conditionalPanel(
                                      condition = "input.Expression_subtype_change_colour_pallete == true",
                                      column(6, selectInput('Expression_subtype_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                    )
                                  ),
                                  fluidRow(
                                    column(6, materialSwitch('Expression_subtype_use_single_colour', 'Use a single colour', value=FALSE, status = "success")),
                                    conditionalPanel(
                                      condition = "input.Expression_subtype_use_single_colour == true",
                                      column(6, colourpicker::colourInput('Expression_subtype_choose_single_colour', 'Choose a colour', value='#000000'))
                                    )
                                  ),
                                  circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                              ),
                              column(12, verbatimTextOutput('Expression_subtype_error_catch')), 
                              column(12, withSpinner(plotOutput("Expression_subtype_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ) )
                            )
                          )
                        )
                      )
                    ),
                  ###### Signature analysis
                    tabPanel(strong("Signature analysis"),
                      fluidRow(
                        # inputs
                        column(12,
                          box(width=12, title='Inputs and Settings', collapsible = TRUE, status='info',
                            fluidRow(
                              column(2, radioButtons('Signature_input_selection', 'Input', choices = c('Choose from the custom gene sets'='A', 'Text input'='B'), selected='A') ),
                              column(4,
                                fluidRow(
                                  column(12, 
                                    conditionalPanel(
                                      condition = "input.Signature_input_selection == 'A'",
                                      htmlOutput('Signature_input_selection_custom_geneset_select')
                                    ),
                                  ),
                                  column(12, 
                                    conditionalPanel(
                                      condition = "input.Signature_input_selection == 'B'",
                                      textAreaInput('Signature_input_selection_text_input', "Enter genes (line by line)")
                                    )
                                  )
                                )
                              ),
                              column(2, radioButtons('Signature_input_score_type', 'Calculation method', choices = c('GSVA', 'ssGSEA'), selected='GSVA') ),
                              column(3, 
                                fluidRow(
                                  column(12, h2('')),
                                  column(12, actionButton('Signature_start', 'Calculate the signature score', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                                  column(9, h5(span('Note: This takes 1~2 minutes depending on the size of the inputted genes. Please be patient.', style="color: red;")) )
                                )
                              ),
                              column(1,
                                div(id='help',
                                  dropdownButton( 
                                    fluidRow(
                                      column(12, h4(strong("Quick guide"))),
                                      column(12, helpText(
                                        HTML("
                                          0. Select a cohort.<br>
                                          1. Set the input genes. Select a custom geneset or write down the genes list. <br>
                                          2. Choose a method.<br>
                                          3. Click the 'Calculate the signature score'. A result table with the score for each sample will be shown and a Kaplan-Meier cureve and a histogran will be automatically generated (in the Survival analysis section and the Distribution section). <br>
                                          4. For the Score comparison part, select a group to compare and click 'Show Plot'.<br>
                                        "))
                                      ),
                                    ), circle = TRUE, status = "danger", icon = icon("question"), width = "600px",  tooltip = tooltipOptions(title = "Quick guide"), right = TRUE
                                  ),
                                ) 
                              ),
                              column(12, h4(''))
                            ),
                            fluidRow(
                              column(8, verbatimTextOutput('Signature_input_selection_status'))
                            )
                          )
                        ),
                        # Results
                        column(4, 
                          box(width=12, title='Results (Signature scores)', status='warning',
                            fluidRow(
                              column(12, verbatimTextOutput('Signature_analysis_status') ),
                              column(12, h2('')),
                              column(12, withSpinner(dataTableOutput("Signature_result_table") , type = 5, color = "#0dc5c1" )),
                              column(12, downloadButton('Signature_result_table_download',"Download this table") )
                            )
                          )
                        ),
                        column(8,
                          box(width=12, title='Plots', status='danger',
                            tabsetPanel(
                              tabPanel('Survival analysis (Kaplan-Meier Plot)',
                                h4(''),
                                fluidRow(
                                  column(12, h3("")),
                                  column(10, radioButtons('Signature_Survival_cutoff_method', 'Split the samples by:', choices = c('Median'='A', 'Top25% vs Bottom 25%'='B'), selected='A')),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Signature_Survival_plot_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Signature_Survival_plot_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Signature_Survival_plot_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Signature_Survival_plot_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Signature_Survival_plot_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, colourpicker::colourInput('Signature_Survival_plot_High_colour', 'Colour for the "High" group:', value='#ec00ec')),
                                        column(6, colourpicker::colourInput('Signature_Survival_plot_Low_colour', 'Colour for the "Low" group:', value='#00aaff')),
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, verbatimTextOutput('Signature_Survival_detail')),
                                  column(12, withSpinner(plotOutput("Signature_Survival_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" )),
                                  column(12, h4(""))
                                )
                              ),
                              tabPanel('Score comparison',
                                h4(''),
                                fluidRow(
                                  column(6, 
                                    fluidRow(
                                      column(12, h4('')),
                                      column(12, htmlOutput('Signature_subtype_groupBy') ),
                                      column(12, verbatimTextOutput('Signature_subtype_subtype_number') ),
                                      column(12, h5(span('Note: When there are too many subtypes, it takes longer time to visualise and the figure will be messy.', style="color: red;")) )
                                    )
                                  ), 
                                  column(3, h3('')),
                                  column(3,
                                    fluidRow(
                                      column(12, h3('')),
                                      column(12, h3('')),
                                      column(12, actionButton('Signature_subtype_start', 'Show plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                                    )
                                  )
                                ),
                                fluidRow(
                                  column(10, radioButtons('Signature_subtype_figtype', 'Figure type:', choices = c('Box plot'='A', 'Violin plot'='B', 'Swarm plot'='C', 'Violin + Swarm plot'='D'), selected='A', inline=TRUE) ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Signature_subtype_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Signature_subtype_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(6, sliderInput('Signature_subtype_XY_label.font.size', 'X/Y labels size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput('Signature_subtype_XY_title.font.size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput('Signature_subtype_title.font.size', 'Graph title font size', min=0.1, max=10, value=4, step=0.1)),
                                        conditionalPanel(
                                          condition = "input.Signature_subtype_figtype == 'C' || input.Signature_subtype_figtype == 'D'",
                                          column(6, sliderInput('Signature_subtype_dot.size', 'Dot size (swarm plot)', min=0.01, max=2, value=0.2, step=0.01))
                                        )
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Signature_subtype_white_background', 'Use white background', value=FALSE, status = "success")),
                                        column(6, materialSwitch('Signature_subtype_rotate_x', 'Rotate X axis label', value=FALSE, status = "success"))
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Signature_subtype_change_colour_pallete', 'Change the colour pallete', value=FALSE, status = "success")),
                                        conditionalPanel(
                                          condition = "input.Signature_subtype_change_colour_pallete == true",
                                          column(6, selectInput('Signature_subtype_select_colour_pallete', 'Choose a colour pallete',  c('None'='None', colour_pallets), selected = 'None'))
                                        )
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Signature_subtype_use_single_colour', 'Use a single colour', value=FALSE, status = "success")),
                                        conditionalPanel(
                                          condition = "input.Signature_subtype_use_single_colour == true",
                                          column(6, colourpicker::colourInput('Signature_subtype_choose_single_colour', 'Choose a colour', value='#000000'))
                                        )
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput("Signature_subtype_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" )),
                                  column(12, verbatimTextOutput('Signature_subtype_note'))
                                )
                              ),
                              tabPanel('Distribution (histogram)',
                                fluidRow(
                                  h4(''),
                                  column(10, verbatimTextOutput('Signature_score_distribution_status')), 
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Signature_score_distributionfig.width', 'Fig width', min=300, max=3000, value=500, step=10)),
                                        column(6,sliderInput('Signature_score_distribution_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Signature_score_distribution_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Signature_score_distribution_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, colourpicker::colourInput('Signature_score_distribution_colour', 'Colour:', value='#006FED')),
                                        column(6, sliderInput('Signature_score_distribution_bin_num', 'Bin number', min=10, max=100, value=50, step=1)),
                                        column(6, materialSwitch('Signature_score_distribution_white_background', 'Use white background', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput("Signature_score_distribution_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Deconvolution
                    tabPanel(strong("Deconvolution analysis"),
                      box(width=12, title='Deconvolution',collapsible=TRUE, status='primary',
                        fluidRow(
                          column(2,
                            fluidRow(
                              column(12, radioButtons("Deconvodution_tool_select", "Choose a method:", choices=c('MCPcounter', 'xCell'), selected='MCPcounter') ),
                              column(12, h4('')),
                              column(12, actionButton("Deconvodution_start", "Start deconvolution", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) )
                            )
                          ),
                          column(10,
                            fluidRow(
                              column(12, h4('Deconvolution Result table:') ),
                              column(12, h3('')),
                              column(12, verbatimTextOutput('Deconvodution_status') ),
                              column(12, withSpinner(dataTableOutput("Deconvodution_results"), type = 5, color = "#0dc5c1" )),
                              column(12, downloadButton('Deconvodution_result_download',"Download this table") )
                            )
                          )
                        )
                      ),
                      box(width=12, title='Futher analysis', status='primary',
                        tabsetPanel(
                          tabPanel("Correlation with genes",
                            fluidRow(
                              column(12, 
                                box(width=12, title='Input and Setting', status='info',collapsible=TRUE,
                                  fluidRow(
                                    column(4, 
                                      fluidRow(
                                        column(12, h4('') ),
                                        column(12, textAreaInput('Deconvodution_Gene_correlation_genes', 'Enter genes (line by line)') ),
                                        column(12, materialSwitch('Deconvodution_Gene_correlation_from_custom_geneset', 'or use the genes from the custom gene sets', value=FALSE, status='info') ),
                                        column(12, 
                                          conditionalPanel(
                                            condition = "input.Deconvodution_Gene_correlation_from_custom_geneset == true",
                                            htmlOutput('Deconvodution_Gene_correlation_from_custom_geneset_select')
                                          )
                                        )
                                      )
                                    ),
                                    column(3,
                                      fluidRow(
                                        column(12, h4('') ),
                                        column(12, htmlOutput('Deconvodution_Gene_correlation_select_celltype') )
                                      )
                                    ),
                                    column(3,
                                      fluidRow(
                                        column(12, h4('') ),
                                        column(12, radioButtons('Deconvodution_Gene_correlation_method', 'Method for correlation', choices=c('pearson', 'spearman'), selected='pearson')  ),
                                        column(12, h4('') ),
                                        column(12, actionButton('Deconvodution_Gene_correlation_start', 'Calculate the correlation',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" ) )
                                      )
                                    ),
                                    column(2, h4(''))
                                  ),
                                  fluidRow(
                                    column(6, verbatimTextOutput('Deconvodution_Gene_correlation_status0') )
                                  )
                                )                              
                              ),
                              column(4, 
                                box(width=12, title='Correlation table', status='warning',collapsible=TRUE,
                                  fluidRow(
                                    column(12, verbatimTextOutput('Deconvodution_Gene_correlation_status1') ),
                                    column(12, dataTableOutput("Deconvodution_Gene_correlation_table") ),
                                    column(12, downloadButton('Deconvodution_Gene_correlation_table_download',"Download this table") )
                                  )
                                )
                              ),
                              column(8,
                                box(width=12, title='Plot', status='danger', collapsible=TRUE,
                                  fluidRow(
                                    column(10, verbatimTextOutput('Deconvodution_Gene_correlation_status') ),
                                    column(2,
                                      dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                          column(6,sliderInput('Deconvodution_Gene_correlation_fig.width', 'Fig width', min=300, max=3000, value=700, step=10)),
                                          column(6,sliderInput('Deconvodution_Gene_correlation_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                        ),
                                        fluidRow(
                                          column(6,sliderInput('Deconvodution_Gene_correlation_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                          column(6,sliderInput('Deconvodution_Gene_correlation_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        ),
                                        fluidRow(
                                          column(6, colourpicker::colourInput('Deconvodution_Gene_correlation_colour', 'Colour of the dots:', value='#ec00ec')),
                                          column(6, materialSwitch('Deconvodution_Gene_correlation_show_correlation_line', 'Show the correlation line', value=TRUE, status='success')),
                                          column(6, materialSwitch('Deconvodution_Gene_correlation_white_background', 'Use white background', value=FALSE, status = "success"))
                                        ),
                                        circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                      )
                                    ),
                                    column(12, withSpinner(plotOutput("Deconvodution_Gene_correlation_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1" ))
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Compare cohorts
                    tabPanel(strong("Compare cohorts"),
                      fluidRow(
                        column(5, 
                          box(width=12, title='Inputs and Settings', status='info',
                            fluidRow(
                              column(7, textAreaInput("Compare_across_cohorts_gene", 'Enter genes (line by line)')),
                              column(12, materialSwitch('Compare_across_cohorts_gene_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                              conditionalPanel(
                                condition = "input.Compare_across_cohorts_gene_from_custom_geneset == true",
                                column(12, htmlOutput('Compare_across_cohorts_gene_from_custom_geneset_select'))
                              )
                            ),
                            fluidRow(
                              column(12, verbatimTextOutput('Compare_across_cohorts_input_status'))
                            ),
                            fluidRow(
                              h4(''),
                              column(6, 
                                fluidRow(
                                  column(12, h4(strong('Select one gene below'))),
                                  column(12, verbatimTextOutput('Compare_across_cohorts_gene_table_status')),
                                  column(12, dataTableOutput("Compare_across_cohorts_gene_table")),
                                )
                              ),
                              column(6, 
                                fluidRow(
                                  column(12, h4(strong('Select cohorts below'))),
                                  column(12, dataTableOutput("Compare_across_cohorts_cohort_table")),
                                )
                              ),
                            ),
                          ),
                        ),
                        column(7,
                          box(width=12, title='Results and Plots', status='danger',
                            tabsetPanel(
                              tabPanel('Mutation Frequency',
                                fluidRow(
                                  column(12, h4('')),
                                  column(12, h4('')),
                                  column(12, actionButton('Compare_across_cohorts_mut_freq_start', 'Compare mutation frequencies',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                  column(12, h5(span('This takes time depending on how many cohorts you use and the size of each cohort.\nNote: When using all the TCGA, it takes ~30 sec. Please be patient.', style="color: red;")) )
                                ),
                                fluidRow(
                                  column(12, h4(strong('Plot'))),
                                  column(12, verbatimTextOutput('Compare_across_cohorts_mut_freq_plot_status')),
                                  column(10, radioButtons('Compare_across_cohorts_mut_freq_plot_type', "Y axis" , choices=c('Number of patients having mutations' = 'A', 'Percentage of patients hacing mytations' = 'B'), selected='B') ),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Compare_across_cohorts_mut_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Compare_across_cohorts_mut_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Compare_across_cohorts_mut_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Compare_across_cohorts_mut_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Compare_across_cohorts_mut_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Compare_across_cohorts_mut_score_size', 'Score font size', min=0.1, max=5, value=1, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, colourpicker::colourInput('Compare_across_cohorts_mut_colour_high', 'Colour of the highest value:', value='#e14b22')),
                                        column(6, colourpicker::colourInput('Compare_across_cohorts_mut_colour_zero', 'Colour of 0:', value='#ffffff')),
                                        column(6, materialSwitch('Compare_across_cohorts_mut_white_background', 'Use white background', value=FALSE, status = "success")),
                                        column(6, materialSwitch('Compare_across_cohorts_mut_hide_score', 'Hide the scores', value=FALSE, status = "success"))
                                      ),
                                      circle = FALSE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput('Compare_across_cohorts_mut_freq_plot', width="100%", height="100%"), type=5, color='#0dc5c1'))

                                ),
                                fluidRow(
                                  column(12, h4('Table')),
                                  column(12, verbatimTextOutput('Compare_across_cohorts_mut_freq_table_status')),
                                  column(12, dataTableOutput('Compare_across_cohorts_mut_freq_table')),
                                ),
                              ),
                              tabPanel('Gene expression',
                                fluidRow(
                                  column(12, h4('')),
                                  column(12, h4('')),
                                  column(12, actionButton('Compare_across_cohorts_gx_start', 'Compare gene expressions',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")),
                                  column(12, h5(span('This takes time depending on how many cohorts you use and the size of each cohort.\nNote: When using all the TCGA, it takes ~2 min. Please be patient.', style="color: red;")) )
                                ),
                                fluidRow(
                                  column(12, h4(strong('Plot'))),
                                  column(10, verbatimTextOutput('Compare_across_cohorts_gx_plot_status')),
                                  column(2, 
                                    dropdownButton( h4(strong("Plot Options")),
                                      fluidRow(
                                        column(6,sliderInput('Compare_across_cohorts_gx_fig.width', 'Fig width', min=300, max=3000, value=750, step=10)),
                                        column(6,sliderInput('Compare_across_cohorts_gx_fig.height', 'Fig height', min=300, max=3000, value=750, step=10)),
                                      ),
                                      fluidRow(
                                        column(6,sliderInput('Compare_across_cohorts_gx_label_size', 'X/Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput('Compare_across_cohorts_gx_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                      ),
                                      fluidRow(
                                        column(6, materialSwitch('Compare_across_cohorts_gx_white_background', 'Use white background', value=FALSE, status = "success")),
                                      ),
                                      circle = FALSE, status = "success", icon = icon("gear"), width = "800px",  tooltip = tooltipOptions(title = "Plot Options"), right=TRUE
                                    )
                                  ),
                                  column(12, withSpinner(plotOutput('Compare_across_cohorts_gx_plot', width="100%", height="100%"), type=5, color='#0dc5c1'))
                                )
                              )
                            )
                          )
                        )
                      )
                    ),
                  ###### Cacner Gene Census (COSMIC)
                    tabPanel(strong("Cacner Gene Census (COSMIC)"),
                      box(width=12,title='Cacner Gene Census (COSMIC)', status='primary',
                        fluidRow(
                          column(12, 
                            helpText(HTML('We are using the <a href="https://cancer.sanger.ac.uk/census" target="_blank">Cancer Gene Census from COSMIC</a>. <br>
                              Please enter gene names below or select a gene set.<br>
                              If the genes are associated with cancer predisposition, they will appear in the table. Otherwise, the entire database will be displayed.')
                            )
                          ),
                          column(12, h2('')),
                          column(3,
                            box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                              fluidRow(
                                # column(12, h4('Genes input')),
                                column(12, h4('')),
                                column(12, textAreaInput('CGC_input_gene', 'Enter genes (line by line)')),
                                column(12, materialSwitch('CGC_input_gene_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                conditionalPanel(
                                  condition = "input.CGC_input_gene_from_custom_geneset == true",
                                  column(12, htmlOutput('CGC_input_gene_from_custom_geneset_select'))
                                )
                              )
                            )
                          ),
                          column(9, 
                            box(width=12, title='Result Table', status='warning', collapsible = TRUE,
                              fluidRow(
                                column(12, h4('')),
                                column(12, verbatimTextOutput("CGC_table_status")),
                                column(12, withSpinner(dataTableOutput("CGC_table"), type=5, color="#0dc5c1")),
                                column(12, downloadButton('CGC_table_download',"Download this table"))
                              )
                            )
                          ),
                        )

                      )
                    ),
                  ###### Add new cohort ######
                    tabPanel(strong("Cohort database"),
                      h4(''),
                      box(width=12, title='Registered cohort', collapsible = TRUE, status='primary',solidHeader = TRUE,
                        DT::dataTableOutput("Cohort_DataBaseTable"),
                        fluidRow( 
                          column(1, actionButton('Cohort_DataBase_save_dt', 'Save changes',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000")), 
                          column(2, actionButton('Cohort_DataBase_delete_row', 'Delete selected data', style="color: #ffffff; background-color: #2d3cac; border-color: #1c48fa")), 
                          column(7, verbatimTextOutput('Cohort_DataBase_status')) 
                        )
                      ),
                      box(width=12, title='Upload',collapsible = TRUE,  status='danger',solidHeader = TRUE,
                        # tags$details(
                        #   tags$summary("Quick upload guide ▼"),  # クリックすると開閉されるタイトル
                        #   div(
                        #     tags$ul(
                        #       tags$li("Make sure that the column name for samples (or patients IDs) is set 'sample' and for genes is set 'id'."),
                        #       tags$li("The fist column of the gene expression file must be the samples"),
                        #       tags$li("The Cohort name is mandatory and must be unique."),
                        #       tags$li("Avoid special characters; use only alphabets, numbers, underscores and dots."),
                        #     )
                        #   )
                        # ),
                        h3(""),
                        fluidRow( 
                          column(5, uiOutput("new_cohort_upload_GE")),
                          column(5, uiOutput("new_cohort_upload_sur")),
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
                        fluidRow( 
                          column(5, uiOutput("new_cohort_upload_meta")),
                          column(5, uiOutput("new_cohort_upload_mut")),
                        ),
                        fluidRow( column(2, actionButton('new_cohort_upload_reset', "Reset uploaded files",style="color: #ffffff; background-color: #1C9600; border-color: #2A8708"))),
                        fluidRow( column(12, h4('') ) ),
                        fluidRow( 
                          column(12, h3('') ),
                          column(4, textInput("new_cohort_upload_dataset_name", "Cohort Name*")),
                          column(7, textAreaInput("new_cohort_upload_description", "Description")) 
                        ),
                        fluidRow( column(2, actionButton('new_cohort_upload_data', 'Add a new cohort',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000" )), column(6, verbatimTextOutput('new_cohort_status'))),
                        fluidRow( column(12, h3('') )),
                        fluidRow( 
                          column(12, h4('Previews') ),
                          column(12,
                            tabsetPanel(
                              tabPanel('Expression table',  
                                box(width=12,
                                  fluidRow(
                                    column(12,  verbatimTextOutput("new_cohort_upload_GE_preview_status") ),
                                    column(12,  dataTableOutput("new_cohort_upload_GE_preview") )
                                  ) 
                                )
                              ),
                              tabPanel('Survival data',  
                                box(width=12, 
                                  fluidRow(
                                    column(12,  verbatimTextOutput("new_cohort_upload_sur_preview_status") ),
                                    column(12,  dataTableOutput("new_cohort_upload_sur_preview") )
                                  ) 
                                )
                              ),
                              tabPanel('Meta data',  
                                box(width=12,
                                  fluidRow(
                                    column(12,  verbatimTextOutput("new_cohort_upload_meta_preview_status") ),
                                    column(12,  dataTableOutput("new_cohort_upload_meta_preview") )
                                  ) 
                                )
                              ),
                              tabPanel('Mutation data',  
                                box(width=12,
                                  fluidRow(
                                    column(12,  verbatimTextOutput("new_cohort_upload_mut_preview_status") ),
                                    column(12,  dataTableOutput("new_cohort_upload_mut_preview") )
                                  ) 
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  ####
                )
              )
            ###
          ),
        #### scRNA ####
          tabItem( tabName='scRNA',
            h2('scRNA'),
            #### dataset selection ####
              box( width=12, title='Dataset selection', status='info', solidHeader = TRUE, collapsible=TRUE,
                fluidRow( 
                  column(6, htmlOutput("scRNA_data_select")) ,
                  column(6, h5('Dataset detail:'), 
                    withSpinner(verbatimTextOutput('scRNA_data_Dataset_detail'), type = 5, color = "#0dc5c1" )
                  )
                )
              ),
            #### UMAP & Feature plot & Other plots ####
              box(width=12, title='Data Overview & Analysis',status='primary', solidHeader = TRUE, collapsible=TRUE,
                tabsetPanel(
                  tabPanel("Overview (UMAP)",
                    h4(''),
                    fluidRow(
                      # Plot
                      column(8,
                        box(width=12, collapsible = TRUE, status = 'danger', title='Plot',
                          fluidRow(
                            column(10, verbatimTextOutput('scRNA_UMAP1_status')),
                            column(2,
                              dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                  column(6, sliderInput('scRNA_umap1_fig.width', 'Fig width', min=300, max=3000, value=900, step=10) ),
                                  column(6, sliderInput('scRNA_umap1_fig.height', 'Fig height', min=300, max=3000, value=700, step=10) ),
                                  column(6, sliderInput('scRNA_umap1_XY_label', 'XY label size', min=0.1, max=10, value=4, step=0.1) ),
                                  column(6, sliderInput('scRNA_umap1_XY_title', 'XY title size', min=0.1, max=10, value=4, step=0.1) ),
                                  column(6, sliderInput('scRNA_umap1_legend_size', 'Legend size', min=0.1, max=10, value=4, step=0.1) ),
                                  column(6, sliderInput('scRNA_umap1_graph_title', 'Title size', min=0.1, max=10, value=4, step=0.1) ),
                                  column(6, sliderInput('scRNA_umap1_graph_dot_size', 'Dot size', min=0.01, max=2, value=0.01, step=0.01) )
                                ),
                                fluidRow(
                                  column(6, materialSwitch('scRNA_umap1_white_background', 'Use white background', value=FALSE, status = "success") )
                                ),
                                circle = FALSE, status = "success", icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                              ),
                            ),
                            column(12, withSpinner(plotOutput("scRNA_UMAP1", brush = "scRNA_UMAP1_brush", width="100%", height="100%"), type=5, color='#0dc5c1') )
                          )
                        )
                      ),
                      # Setting
                      column(4, 
                        box(width=12, collapsible = TRUE, status = 'info', title='Setting',
                          fluidRow(
                            column(12, h4('')),
                            column(10, htmlOutput("scRNA_UMAP1_groupBy")),
                            column(12, verbatimTextOutput('scRNA_UMAP1_groupBy_status')),
                          ),
                          fluidRow(
                            column(12, materialSwitch("scRNA_UMAP1_highlight_group", 'Highlight a specific group', status = 'info')),
                            column(12, 
                              conditionalPanel(
                                condition = 'input.scRNA_UMAP1_highlight_group == true',
                                fluidRow(
                                  column(10, htmlOutput("scRNA_UMAP1_highlight_group_select"))
                                ),
                                fluidRow(
                                  column(5, colourpicker::colourInput('scRNA_UMAP1_highlight_group_background', 'Colour (background)', value='gray') ),
                                  column(5, colourpicker::colourInput('scRNA_UMAP1_highlight_group_highlight', 'Colour (highlighted group)', value='red') )
                                )
                              )
                            )
                          )
                        )
                      )

                    )
                  ),
                  tabPanel("Feature plots",
                    tabsetPanel(
                      tabPanel('Gene Feature Plot',
                        h4(''),
                        fluidRow(
                          # Inputs and Setting
                          column(4,
                            box(width=12, status='info', title='Inputs and Settings',collapsible=TRUE, 
                              fluidRow(
                                column(12, textAreaInput("scRNA_UMAP2_gene", "Enter genes names (line by line)")),
                                column(12, materialSwitch('scRNA_UMAP2_gene_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                conditionalPanel(
                                  condition = "input.scRNA_UMAP2_gene_from_custom_geneset == true",
                                  column(12, htmlOutput('scRNA_UMAP2_gene_from_custom_geneset_select'))
                                )
                              ),
                              fluidRow(
                                column(12, verbatimTextOutput('scRNA_UMAP2_gene_input_status') ),
                                column(12, h4('Select a gene below:') ),
                                column(12, DT::dataTableOutput("scRNA_UMAP2_gene_table") )
                              )
                            )
                          ),
                          column(8,
                            box(width=12, status='danger', title='Plot', 
                              fluidRow(
                                column(10, verbatimTextOutput('Feature_Plot_status_catch') ),
                                column(2, 
                                  dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                      column(6, sliderInput('scRNA_umap2_fig.width', 'Fig width', min=300, max=3000, value=900, step=10) ),
                                      column(6, sliderInput('scRNA_umap2_fig.height', 'Fig height', min=300, max=3000, value=700, step=10) ),
                                      column(6, sliderInput('scRNA_umap2_XY_label.font.size', 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                      column(6, sliderInput('scRNA_umap2_XY_title.font.size', 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                      column(6, sliderInput('scRNA_umap2_graph.title.font.size', 'Graph title font size', min=0.1, max=10, value=4, step=0.1) ),
                                      column(6, sliderInput('scRNA_umap2_legend_size', 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                      column(6, sliderInput('scRNA_umap2_dot_size', 'Dot size', min=0.01, max=2, value=0.01, step=0.01)),
                                      column(6, sliderInput('scRNA_umap2_dot_size_bg', 'Dot size (background)', min=0.01, max=2, value=0.05, step=0.01))
                                    ),
                                    fluidRow(
                                      column(4, colourpicker::colourInput('scRNA_umap2_highest_colour', 'Colour for the highest expression', value='red') ),
                                      column(4, colourpicker::colourInput('scRNA_umap2_lowest_colour', 'Colour for the lowest expression', value='white') ),
                                      column(4, colourpicker::colourInput('scRNA_umap2_zero_colour', 'Colour for zero expression (background)', value='#676767'))
                                    ),
                                    fluidRow(
                                      column(12, materialSwitch('scRNA_umap2_while_background', 'Use white background', value=FALSE, status = "success"))
                                    ),
                                    circle = FALSE, status = "success", icon = icon("gear"), width = "700px", right=TRUE, tooltip = tooltipOptions(title = "Plot Options")
                                  )
                                ),                                
                                column(12, withSpinner(plotOutput("scRNA_UMAP2", brush = "scRNA_UMAP2_brush", width="100%", height="100%"), type=5, color='#0dc5c1') )
                              )
                            )
                          )
                        )
                      ),
                      tabPanel('Gene Set Signature (AUC score) Feature Plot',
                        h4(''),
                        fluidRow(
                          # Inputs
                          column(4,
                            box(width=12, status='info', title='Inputs and Settings',collapsible=TRUE, 
                              fluidRow(
                                column(12, textAreaInput("scRNA_UMAP2_gene_signature", "Enter genes names (line by line)") ),
                                column(12, materialSwitch('scRNA_UMAP2_gene_signature_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                column(12, 
                                  conditionalPanel(
                                    condition = "input.scRNA_UMAP2_gene_signature_from_custom_geneset == true",
                                    htmlOutput('scRNA_UMAP2_gene_signature_from_custom_geneset_select')
                                  )
                                ),
                                column(12, h4('') ) ,
                                column(12, actionButton("scRNA_UMAP2_gene_signature_start", "Calculate the signature score", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                                column(12, h5(span('This takes 1~3 minutes depending on the size of the input genes and the size of the scRNA dataset. Please be patient.', style="color: red;"))) 
                              )
                            )
                          ),
                          # Plots
                          column(8,
                            box(width=12, status='danger', title='Plots',collapsible=TRUE, 
                              tabsetPanel(
                                tabPanel('Feature Plot',
                                  fluidRow(
                                    column(12, h4('') ) ,
                                    column(10, verbatimTextOutput('scRNA_UMAP2_gene_signature_status') ),
                                    column(2,
                                      dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                          column(6, sliderInput('scRNA_umap2_gene_signature_fig.width', 'Fig width (Feature plot)', min=300, max=3000, value=700, step=10) ),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_fig.height', 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10) ),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_XY_label.font.size', 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_XY_title.font.size', 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_legend_size', 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_dot_size', 'Dot size', min=0.01, max=2, value=0.01, step=0.01)),
                                          column(6, sliderInput('scRNA_umap2_gene_signature_dot_size_bg', 'Dot size (background)', min=0.01, max=2, value=0.05, step=0.01))
                                        ),
                                        fluidRow(
                                          column(4, colourpicker::colourInput('scRNA_umap2_gene_signature_highest_colour', 'Colour for the highest expression', value='#5A05F7') ),
                                          column(4, colourpicker::colourInput('scRNA_umap2_gene_signature_lowest_colour', 'Colour for the lowest expression', value='white') ),
                                          column(4, colourpicker::colourInput('scRNA_umap2_gene_signature_zero_colour', 'Colour for zero (background)', value='#676767'))
                                        ),
                                        fluidRow(
                                          column(12, materialSwitch('scRNA_umap2_gene_signature_while_background', 'Use white background', value=FALSE, status = "success"))
                                        ),
                                        circle = FALSE, status = "success", right=TRUE, icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                      ),
                                    ),
                                    column(12, withSpinner(plotOutput("scRNA_UMAP2_gene_signature_plot", width="100%", height="100%"), type=5, color='#0dc5c1') )
                                  )                            
                                ),
                                tabPanel('Violin Plot',
                                  fluidRow(
                                    column(12, h4('') ) ,
                                    column(8, htmlOutput('scRNA_violin_gene_signature_groupby') ),
                                    column(10, verbatimTextOutput('scRNA_violin_gene_signature_status')),
                                    column(2,
                                      dropdownButton( h4(strong("Plot Options")),
                                        fluidRow(
                                          column(6, sliderInput('scRNA_violin_gene_signature_fig.width', 'Fig width (Feature plot)', min=300, max=3000, value=900, step=10) ),
                                          column(6, sliderInput('scRNA_violin_gene_signature_fig.height', 'Fig height (Feature plot)', min=300, max=3000, value=600, step=10) ),
                                          column(6, sliderInput('scRNA_violin_gene_signature_XY_label.font.size', 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                          column(6, sliderInput('scRNA_violin_gene_signature_XY_title.font.size', 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                          column(6, sliderInput('scRNA_violin_gene_signature_legend_size', 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                        ),
                                        fluidRow(
                                          column(4, materialSwitch('scRNA_violin_gene_signature_while_background', 'Use white background', value=FALSE, status = "success")),
                                          column(4, materialSwitch('scRNA_violin_gene_signature_rotate_x', 'Rotate X labels', value=TRUE, status = "success")),
                                          column(4, materialSwitch('scRNA_violin_gene_signature_hide_jitter', 'Hide jitter plots', status = "success", value=TRUE)),
                                        ),
                                        circle = FALSE, status = "success", right=TRUE, icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                      )
                                    ),
                                    column(12, withSpinner(plotOutput("scRNA_violin_gene_signature_plot", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                    column(12, materialSwitch('scRNA_violin_gene_signature_select_group', 'Select the groups to show',  status = "danger")),
                                    conditionalPanel(
                                      condition = "input.scRNA_violin_gene_signature_select_group == true",
                                      column(12, h5("Select the groups to use in the violin plot below:")),
                                      column(8, DT::dataTableOutput("scRNA_violin_gene_signature_select_group_table"))
                                    ),
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  ),
                  tabPanel("Other plots",
                    tabsetPanel(
                      tabPanel("Dot Plot",
                        h4(''),
                        fluidRow(
                          column(4,
                            box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                              fluidRow(
                                column(12, textAreaInput("scRNA_DotPlot_gene", "Enter genes name (line by line)") ),
                                column(12, materialSwitch(inputId = "scRNA_DotPlot_gene_from_custom_geneset", label = "Use the genes from the custom gene sets", status = "info") ),
                                conditionalPanel(
                                  condition = "input.scRNA_DotPlot_gene_from_custom_geneset == true",
                                  column(12, htmlOutput('scRNA_DotPlot_gene_from_custom_geneset_select'))
                                ),
                                column(12, htmlOutput("scRNA_DotPlot_groupBy")),
                                column(6, actionButton('scRNA_DotPlot_start', 'Show a dot plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                              )
                            )
                          ),
                          column(8,
                            box(width=12, title='Plot', status='danger', collapsible = TRUE,
                              fluidRow(
                                column(10, verbatimTextOutput('scRNA_DotPlot_dot_status')),
                                column(2, 
                                  dropdownButton( 
                                    h4(strong("Plot Options")),
                                    fluidRow(
                                      column(6,sliderInput('scRNA_dot_fig.width', 'Fig width', min=300, max=3000, value=900, step=10)),
                                      column(6,sliderInput('scRNA_dot_fig.height', 'Fig height', min=300, max=3000, value=500, step=1)),
                                      column(6,sliderInput('scRNA_dot_X_label_size', 'X label size', min=0.1, max=10, value=2, step=0.1)),
                                      column(6,sliderInput('scRNA_dot_Y_label_size', 'Y label size', min=0.1, max=10, value=2.5, step=0.1)),
                                      column(6,sliderInput('scRNA_dot_Y_title_size', 'Y title size', min=0.1, max=10, value=4, step=0.1)),
                                      column(6,sliderInput('scRNA_dot_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1)),
                                      column(6,sliderInput('scRNA_dot_dotScale', 'Dot scale', min=0.1, max=5, value=0.9, step=0.1))
                                    ),
                                    fluidRow(
                                      column(6,colourpicker::colourInput('scRNA_dot_high_col', 'Colour (High expression)', value='blue')),
                                      column(6,colourpicker::colourInput('scRNA_dot_low_col', 'Colour (low expression)', value='lightgrey')),
                                    ),
                                    circle = FALSE,
                                    status = "success", 
                                    icon = icon("gear"), width = "700px", right=TRUE,
                                    tooltip = tooltipOptions(title = "Plot Options")
                                  )
                                ),
                                column(12, withSpinner(plotOutput("scRNA_DotPlot_dot", width="100%", height="100%"), type=5, color='#0dc5c1'))
                              )
                            )
                          )
                        )
                      ),
                      tabPanel("Violin plot",
                        h4(''),
                        fluidRow(
                          column(4, 
                            box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                              fluidRow(
                                column(12, textAreaInput("scRNA_VlnPlot_gene", "Enter genes name (line by line)") ),
                                column(12, materialSwitch(inputId = 'scRNA_VlnPlot_gene_from_custom_geneset', label = 'Use the genes from the custom gene sets', status = "info") ),
                                conditionalPanel(
                                  condition = "input.scRNA_VlnPlot_gene_from_custom_geneset == true",
                                  column(12, htmlOutput('scRNA_VlnPlot_gene_from_custom_geneset_select'))
                                ),
                                column(12, htmlOutput("scRNA_VlnPlot_groupBy")),
                                column(12, verbatimTextOutput('scRNA_VlnPlot_vln_inputsetting1')),
                                column(12, verbatimTextOutput('scRNA_VlnPlot_vln_inputsetting2')),
                                column(12, h4('')),
                                column(12, h4(strong('Select a gene below:'))),
                                column(12, DT::dataTableOutput("scRNA_vln_vln_gene_table"))
                              )
                            )
                          ),
                          column(8, 
                            box(width=12, title='Plot', status='danger', collapsible = TRUE,
                              fluidRow(
                                column(10, verbatimTextOutput('scRNA_VlnPlot_vln_status')),
                                column(2,
                                  dropdownButton( 
                                    h4(strong("Plot Options")),
                                    fluidRow(
                                      column(6,sliderInput('scRNA_vln_vln_fig.width', 'Fig width', min=300, max=3000, value=900, step=10)),
                                      column(6,sliderInput('scRNA_vln_vln_fig.height', 'Fig height', min=300, max=3000, value=500, step=1)),
                                      column(6,sliderInput('scRNA_vln_vln_X_label_size', 'X label size', min=0.1, max=10, value=3, step=0.1)),
                                      column(6,sliderInput('scRNA_vln_vln_Y_label_size', 'Y label size', min=0.1, max=10, value=4, step=0.1)),
                                      column(6,sliderInput('scRNA_vln_vln_Y_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                      column(6,sliderInput('scRNA_vln_vln_legend_size', 'legend size', min=0.1, max=10, value=4, step=0.1))
                                    ),
                                    fluidRow(
                                      column(12, h5('Graph display area:')),
                                      column(4, numericInput('scRNA_vln_vln_ylim_min', 'Min Y-axis:', value=NA, step=0.1)),
                                      column(4, numericInput('scRNA_vln_vln_ylim_max', 'Max Y-axis:', value=NA, step=0.1)),
                                    ),
                                    fluidRow(
                                      column(4, materialSwitch('scRNA_vln_vln_white_back', 'Use white background',  status = "success")),
                                      column(4, materialSwitch('scRNA_vln_vln_rotate_x', 'Rotate X labels', status = "success")),
                                      column(4, materialSwitch('scRNA_vln_vln_hide_jitter', 'Hide jitter plots', status = "success", value=TRUE)),
                                    ),
                                    circle = FALSE, status = "success", icon = icon("gear"), width = "700px", right=TRUE,
                                    tooltip = tooltipOptions(title = "Plot Options")
                                  )
                                ),
                                column(12, withSpinner(plotOutput("scRNA_VlnPlot_vln", width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                column(12, materialSwitch('scRNA_VlnPlot_vln_select_group', 'Select the groups to show',  status = "danger")),
                                conditionalPanel(
                                  condition = "input.scRNA_VlnPlot_vln_select_group == true",
                                  column(12, h5("Select the groups to use in the violin plot below:")),
                                  column(8, DT::dataTableOutput("scRNA_VlnPlot_vln_select_group_table"))
                                ),
                              )
                            )
                          )
                        )
                      ),
                      tabPanel("Pie chart",
                        h4(''),
                        fluidRow(
                          column(4,
                            box(width=12, status='info', title='Inputs and Settings',collapsible=TRUE, 
                              fluidRow(
                                column(12, textAreaInput("scRNA_fraction_gene", "Enter genes name (line by line)")),
                                column(12, materialSwitch('scRNA_fraction_Input_from_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                                column(12,
                                  conditionalPanel(
                                    condition = "input.scRNA_fraction_Input_from_custom_geneset == true",
                                    htmlOutput('scRNA_fraction_Input_from_custom_geneset_select')
                                  )
                                ),
                                column(12, htmlOutput("scRNA_fraction_groupBy")),
                                column(12, verbatimTextOutput('scRNA_fraction_gene_input_status1') ),
                                column(12, verbatimTextOutput('scRNA_fraction_gene_input_status2') ),
                                column(12, h4(strong('Select a gene below:')) ),
                                column(12, DT::dataTableOutput("scRNA_fraction_gene_table") )
                              )
                            )
                          ),
                          column(8,
                            box(width=12, status='danger', title='Plot',collapsible=TRUE, 
                              fluidRow(
                                column(10, verbatimTextOutput('scRNA_fraction_status') ),
                                column(2, 
                                  dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                      column(6,sliderInput('scRNA_fraction_fig.width', 'Fig width', min=300, max=3000, value=1000, step=10)),
                                      column(6,sliderInput('scRNA_fraction_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                      column(6,sliderInput('scRNA_fraction_label_size', 'Label size', min=1, max=30, value=4, step=1)),
                                      column(6,sliderInput('scRNA_fraction_group_name_size', 'Group name size', min=10, max=40, value=15, step=1)),
                                      column(6,sliderInput('scRNA_fraction_legend_size', 'Legend size', min=3, max=30, value=10, step=1)),
                                    ),
                                    fluidRow(
                                      column(6,colourpicker::colourInput('scRNA_fraction_expressing_colour', "Colour for 'Expressing'",  value='#3467ff')),
                                      column(6,colourpicker::colourInput('scRNA_fraction_non_expressing_colour', "Colour for 'Non.expressing'", value='#f3fbff')),
                                    ),
                                    fluidRow(
                                      column(6, materialSwitch('scRNA_fraction_hide_legend', 'Hide legends', value=FALSE, status = "success")),
                                      column(6, materialSwitch('scRNA_fraction_hide_label', 'Hide labels', value=FALSE, status = "success"))
                                    ),
                                    circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                  )
                                ),
                                column(12, withSpinner(plotOutput("scRNA_fraction_piechart", width="100%", height="100%"), type=5, color='#0dc5c1')),
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
          ),
        #### IGV ####
          tabItem( tabName='igv',
            h2(' Epigenome Visualisation'),
            box( width=12, title='IGV', status='primary',  solidHeader = TRUE,
              tabsetPanel(
                tabPanel( 'Prifile plot',
                  h4(''),
                  fluidRow(
                    column(4,
                      box(title='Inputs and Settings', width=12, status='info',
                        fluidRow(
                          column(12, htmlOutput('Profile_Plot_sample_selection')),
                          column(12, verbatimTextOutput('Profile_Plot_sample_selection_status')),
                          column(6, actionButton('Profile_Plot_sample_import', 'Import the selected sample',style="color: #ffffff; background-color: #33c481; border-color: #04915e") ),
                          column(12, h2('')),
                          column(12, h5('List of imported dataset:')),
                          column(12, helpText('The following samples are used for the profile plot.')),
                          column(12, withSpinner(DT::dataTableOutput("Profile_Plot_imported_sample_table"), type=5, color='#0dc5c1')),
                          column(6, actionButton('Profile_Plot_sample_remove', 'Remove the selected sample',style="color: #ffffff; background-color:#0e98e8; border-color: #0772b0") ),
                          column(12, h2('')),
                          column(12, numericInput('Profile_Plot_extend_length', 'Extend length', value=2000, min=0, max=10000, step=10)),
                          column(12, h5(strong('Enter the coordinates below:'))),
                          column(12, 
                            helpText(HTML("Please write the genome locus in the format of 'chr:start-end' line by line. <br>For example, 'chr1:1000000-2000000'."))
                          ),
                          column(12, textAreaInput("Profile_Plot_input_coord", ""))
                        ),
                        fluidRow(
                          column(6, actionButton('Profile_Plot_start', 'Generate a plot',style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                        )
                      )
                    ),
                    column(8,
                      box(title='Profile Plot', width=12, status='danger',
                        fluidRow(
                          column(10, verbatimTextOutput('Profile_Plot_status')),
                          column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                              fluidRow(
                                column(6, sliderInput(inputId = 'Profile_Plot_fig.width', label='Fig width', min=300, max=3000, value=600, step=10)),
                                column(6, sliderInput(inputId = 'Profile_Plot_fig.height', label='Fig height (heatmap part)', min=300, max=3000, value=1000, step=10)),
                                column(6, sliderInput(inputId = 'Profile_Plot_column_font_size', label='Sample name font size', min=0.1, max=10, value=3, step=0.1)),
                                column(6, sliderInput(inputId = 'Profile_Plot_legend_font_size', label='Legend size', min=0.1, max=10, value=3, step=0.1)),
                                column(6, sliderInput(inputId = 'Profile_Plot_label_size_up', label='Y label size (upper part)', min=0.1, max=10, value=3, step=0.1)),
                                column(6, sliderInput(inputId = 'Profile_Plot_label_size_main', label='X label size (heatmap part)', min=0.1, max=10, value=3, step=0.1)),
                                column(6, sliderInput(inputId = 'Profile_Plot_top_annot_height', label='Fig height (upper part)', min=0.1, max=5, value=1, step=0.1))
                                
                              ),  
                              fluidRow(
                                column(6, colourpicker::colourInput('Profile_Plot_max_col', 'Max colour', value='red')),
                                column(6, colourpicker::colourInput('Profile_Plot_min_col', 'Min colour', value='white')),
                                column(6, colourpicker::colourInput('Profile_Plot_line_col', 'Line colour', value='red'))                               
                              ),
                              circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            ),
                          ),
                          column(12, withSpinner(plotOutput("Profile_Plot_Plot", width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                        )
                      )
                    )
                  )
                ),
                tabPanel( 'IGV',
                  h4(''),
                  fluidRow(
                    column(4, 
                      box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                        fluidRow( 
                          # column(12, radioButtons("igv_data_type", "Data type", choices = c('BED' = 'D', 'BAM' = 'E'), selected='D')),
                          column(12, selectInput('igv_gneome_selection', 'Choose genome:', choices=c('hg38', 'hg19', 'mm10', 'mm39'), selected='hg38')),
                          column(12, htmlOutput("igv_data_select")),
                          column(12, 
                            div(id='filterin_dropdown',
                              dropdownButton( 
                                fluidRow(
                                  column(4, htmlOutput("igv_data_DataFrom")),
                                  column(4, htmlOutput("igv_data_Experiment"))
                                ),
                                label='Dataset filtering', circle = FALSE, status = "info", icon = icon("sliders"), width = "1000px",  tooltip = tooltipOptions(title = "Dataset filtering")
                              )
                            ) 
                          ),
                          column(12, h2('')),
                          column(12, 
                            fluidRow(
                              column(12, h5('Selected dataset detail:')),
                              column(12, verbatimTextOutput('igv_Dataset_detail')),
                            ),
                            fluidRow(
                              h3(''),
                              column(12, actionButton("igv_data_add", "View in IGV", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                            )
                          )
                        )
                      )
                    ),
                    column(8,
                      box(width=12, title='Plot', status='danger', collapsible = TRUE,
                        fluidRow(
                          column(12, withSpinner(igvShinyOutput("igv", height = "1000px"), type = 5, color = "#0dc5c1") )
                        )
                      )
                    )
                  )
                ),
                tabPanel('Find Enhancer/Promoter', # select RNAseq count data and ATACseq count data. input gene names. calculate the correlation with the peak, return the correlated positiosn.
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
                              column(10, htmlOutput('Enhancer_Find_data_select_RNAseq')),
                              column(2,
                                fluidRow(
                                  column(12, h2('') ),
                                  column(12, 
                                    div(id='filterin_dropdown',
                                      dropdownButton( 
                                        fluidRow(
                                          column(12, h4(strong("Dataset filtering"))),
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Seuqenced_by")), 
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Experiments")), 
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Data_type")) 
                                        ), circle = FALSE, status = "info", icon = icon("sliders"), width = "300px",  tooltip = tooltipOptions(title = "Dataset filtering")
                                      )
                                    ) 
                                  )
                                )
                              ),
                              column(12, helpText("The column names of the RNAseq data:")),
                              column(12, verbatimTextOutput('Enhancer_Find_data_select_RNAseq_SampleNames')),
                            )
                          ),
                          column(12,
                            fluidRow(
                              column(10, htmlOutput('Enhancer_Find_data_select_ATACseq')),
                              column(2,
                                fluidRow(
                                  column(12, h2('') ),
                                  column(12,
                                    div(id='filterin_dropdown',
                                      dropdownButton( 
                                        fluidRow(
                                          column(12, h4(strong("Dataset filtering"))),
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Seuqenced_by")), 
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Experiments")), 
                                          column(12, htmlOutput("Enhancer_Find_data_select_RNAseq_Data_type")) 
                                        ), circle = FALSE, status = "info", icon = icon("sliders"), width = "300px",  tooltip = tooltipOptions(title = "Dataset filtering")
                                      ),
                                    ) 
                                  )
                                )
                              ),
                              column(12, helpText("The column names of the ATACseq data:")),
                              column(12, verbatimTextOutput('Enhancer_Find_data_select_ATACseq_SampleNames')),
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
                              column(12, textAreaInput('Enhancer_Find_sample_select', 'Enter sample names (RNA_sample,ATAC_sample)', placeholder = 'Name in RNAseq,Name.in.ATACseq \nSample1_RNA_Rep1,Sample1_ATAC_Rep1\nSample2_RNA_Rep1,Sample2_ATAC_Rep1')),
                              column(12, textAreaInput('Enhancer_Find_input_gene', 'Enter genes (line by line)', placeholder='Gene1\nGene2\nGene3')),
                              column(12, materialSwitch('Enhancer_Find_use_custom_geneset', 'Use the genes from the custom gene sets', value=FALSE, status='info') ),
                              column(12, 
                                conditionalPanel(
                                  condition = "input.Enhancer_Find_use_custom_geneset == true",
                                  htmlOutput('Enhancer_Find_custom_geneset_select')
                                )
                              )
                            )
                          ),
                          column(12,
                            fluidRow(
                              column(12, h2('')),
                              column(12, radioButtons("Enhancer_Find_calculation_type", "Calculation type", choices = c('pearson', 'spearm'), selected='pearson', inline=TRUE )), 
                              column(6, numericInput('Enhancer_Find_extend_length', 'See ±Xbp around the gene', value=100000, min=0, step=100)),
                              column(6, h3(''))
                            ),
                            fluidRow(
                              column(12, materialSwitch('Enhancer_Find_chr_focus','Check only the same chromosomes of the target genes', value=TRUE, status='info') ),
                              column(12, helpText('Note: If this is NOT checked, it takes very long time to calculate the correlation.')),
                              column(12, h3('')),
                              column(12, actionButton('Enhancer_Find_start', 'Find enhancers/promoters', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                            )
                          )
                        )
                      )
                    ),
                    column(7,
                      fluidRow(
                        column(12,
                          box(width=12, title='Results', status='warning', collapsible = TRUE,
                            # three tabs. 1: Corraltion result, 2: RNAseq data table, 3: ATACseq data table
                            tabsetPanel(
                              tabPanel('Correlation result',
                                h4(''),
                                fluidRow(
                                  column(12, verbatimTextOutput('Enhancer_Find_table_status') ),
                                  column(12, withSpinner(DT::dataTableOutput('Enhancer_Find_table'), type = 5, color = "#0dc5c1") )
                                )
                              ),
                              tabPanel('RNAseq data table',
                                h4(''),
                                fluidRow(
                                  column(12, verbatimTextOutput('Enhancer_Find_RNAseq_data_status') ),
                                  column(12, withSpinner(DT::dataTableOutput('Enhancer_Find_RNAseq_data_table'), type = 5, color = "#0dc5c1") )
                                )
                              ),
                              tabPanel('ATACseq data table',
                                h4(''),
                                fluidRow(
                                  column(12, verbatimTextOutput('Enhancer_Find_ATACseq_data_status') ),
                                  column(12, withSpinner(DT::dataTableOutput('Enhancer_Find_ATACseq_data_table'), type = 5, color = "#0dc5c1") )
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
                                  column(12, htmlOutput('Enhancer_Find_gene_selection')),
                                  column(12, numericInput('Enhancer_Find_show_list_threshold', 'P-value threshold', value=0.05, min=0, step=0.001))
                                )
                              ),
                              column(8,
                                fluidRow(
                                  column(12, h2('')),
                                  column(9, verbatimTextOutput('Enhancer_Find_gene_correlated_peak_list'))
                                ))
                              
                            )
                          )
                        )
                      )
                    )
                  )
                ),
                tabPanel('Motif Scan',
                  h4(''),
                  fluidRow(
                    column(4,
                      box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                        fluidRow(
                          column(12, 
                            helpText("This tool scans for motifs in the input peaks or sequences with the MotifDb database (PWMLogn.hg19.MotifDb.Hsap), identifying potential transcription factor binding sites within the specified genomic region.")
                          ),
                          column(12, radioButtons('Motif_analysis_input_type', 'Input type', choices = c('Input peaks'='A', 'Input sequences'='B'), selected='A', inline=TRUE)),
                          conditionalPanel(
                            condition = "input.Motif_analysis_input_type == 'A'",
                            column(12, textAreaInput("Motif_analysis_input_peaks", "Enter peaks (line by line)", placeholder='chr1:1000000-2000000\nchr1:2000000-3000000')),
                            column(12, radioButtons("Motif_analysis_input_genome_type", "Genome type", choices = c('hg38', 'hg19'), selected='hg38', inline=TRUE))
                          ),
                          conditionalPanel(
                            condition = "input.Motif_analysis_input_type == 'B'",
                            column(12, textAreaInput("Motif_analysis_input_sequences", "Enter sequences (line by line)", placeholder='ATCGATCGATCG\nGCTAGCTAGCTA'))
                          ),
                          column(12, h2('')),
                          column(12, actionButton('Motif_analysis_start', 'Start motif scan', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                        )
                      )
                    ),
                    column(8,
                      fluidRow(
                        column(12, 
                          box(width=12, title='Motifs', status='warning', collapsible = TRUE,
                            fluidRow(
                              column(12, verbatimTextOutput('Motif_analysis_status') ),
                              column(12, withSpinner(DT::dataTableOutput('Motif_analysis_table'), type = 5, color = "#0dc5c1") ),
                              column(12, downloadButton('Motif_analysis_table_download', 'Download motif table', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                            )
                          )
                        )
                      ),
                      fluidRow(
                        column(12, 
                          box(width=12, title='Plot (logo)', status='danger', collapsible = TRUE,
                            fluidRow(
                              column(10, verbatimTextOutput('Motif_analysis_plot_status')),
                              column(2,
                                dropdownButton( 
                                  h4(strong("Plot Options")),
                                  fluidRow(
                                    column(6, sliderInput('Motif_analysis_fig.width', 'Fig width', min=300, max=3000, value=900, step=10)),
                                    column(6, sliderInput('Motif_analysis_fig.height', 'Fig height', min=300, max=3000, value=500, step=10)),
                                    column(6, sliderInput('Motif_analysis_plot_XY_label_size', 'X/Y label size', min=0.1, max=10, value=3, step=0.1)),
                                    column(6, sliderInput('Motif_analysis_plot_XY_title_size', 'X/Y title size', min=0.1, max=10, value=4, step=0.1))
                                  ),
                                  fluidRow(
                                    column(6, radioButtons('Motif_analysis_plot_Y_axis', 'Y axis:', choices = c('bits','prob'), selected = 'bits', inline=TRUE))
                                  ),
                                  circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                              ),
                              column(12, withSpinner(plotOutput('Motif_analysis_plot', width='100%', height='100%'), type = 5, color = "#0dc5c1") )
                            )
                          )
                        )
                      )
                    )
                  )
                ),
                tabPanel('Genome visualisation',
                  h4(''),
                  fluidRow(
                    column(4,
                      box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                        fluidRow(
                          column(12, htmlOutput('Gviz_data_select')),
                          column(12, actionButton('Gviz_data_add', 'Import data', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") )
                        )
                      )
                    ),
                    column(8,
                      box(width=12, title='Plot', status='danger', collapsible = TRUE,
                        fluidRow(
                          column(4, selectInput('Gviz_genome_selection', 'Choose genome:', choices=c('hg38', 'hg19'), selected='hg38')),
                          column(4, textInput('Gviz_chromosome_pos', 'Position', value='chr1:1000000-2000000')),
                          column(10, verbatimTextOutput('Gviz_plot_status') ),
                          column(2, 
                            dropdownButton( h4(strong("Plot Options")),
                              fluidRow(
                                column(6, sliderInput('Gviz_fig.width', 'Fig width', min=300, max=3000, value=900, step=10)),
                                column(6, sliderInput('Gviz_fig.height', 'Fig height', min=300, max=3000, value=700, step=10)),
                                column(6, sliderInput('Gviz_plot_XY_label.font.size', 'X/Y label font size', min=0.1, max=10, value=4, step=0.1)),
                                column(6, sliderInput('Gviz_plot_XY_title.font.size', 'X/Y title font size', min=0.1, max=10, value=4, step=0.1)),
                                column(6, sliderInput('Gviz_plot_legend_size', 'Legend font size', min=0.1, max=10, value=4, step=0.1))
                              ),
                              circle = FALSE, status = "success", icon = icon("gear"), right = TRUE, width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                            )
                          ),
                          column(12, withSpinner(plotOutput("Gviz_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1") ),
                          column(12, helpText(paste("Visualised by the Gviz library. Version: ", installed.packages()["Gviz", "Version"])))
                        )
                      )
                    )
                  )
                )
              )
            )
          ),
        #### Tools ####
          tabItem( tabName='Tools',
            h2(' Tools'),
            tabsetPanel(
              # Human <=> Mouse
                tabPanel(strong('Human <=> Mouse'),
                  box(width=12, status='primary',  solidHeader = TRUE, title='Convert Huamns genes with Mouse genes',
                    # h3("Convert Huamns genes with Mouse genes."),
                    fluidRow(
                      column(5,
                        box(width=12, title='Inputs and Settings', status='info', collapsible = TRUE,
                          fluidRow(
                            column(12, radioButtons("human_mouse_convert_direction", "Human <=> Mouse direction", choices = c('Convert mouse genes to human genes' = 'A', 'Convert human genes to mouse genes' = 'B'), selected='A')),
                            column(6, radioButtons("human_mouse_convert_input_type", "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A')),
                            column(6, radioButtons("human_mouse_convert_output_type", "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A')),
                            column(12, textAreaInput('human_mouse_convert_input_gene', 'Enter genes (line by line)')),
                            column(12, h4('')),
                            column(12, verbatimTextOutput('human_mouse_convert_status') ),
                            column(12, h4('')),
                            column(4, actionButton('human_mouse_convert_start', 'Convert genes', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000"))
                          )
                        )
                      ),
                      column(4,
                        box(width=12, title='Conversion Table', status='danger', collapsible = TRUE,
                          fluidRow(
                            column(12, verbatimTextOutput('human_mouse_convert_table_status')),
                            column(12, withSpinner(DT::dataTableOutput('human_mouse_convert_table'), type = 5, color = "#0dc5c1") )
                          )
                        )
                      ),
                      column(3,
                        box(width=12, title='List of converted genes', status='warning', collapsible = TRUE,
                          fluidRow(column(12, verbatimTextOutput('human_mouse_convert_result') ))
                        )
                      )
                    )
                  )
                ),
              # Gene symbol <=> Ensembl
                tabPanel(strong('Gene symbol <=> Ensembl'),
                  box(width=12, status='primary',  solidHeader = TRUE, title='Convert Ensemble gene ids with Gene symbols',
                    fluidRow(
                      column(5, 
                        box(width=12,  title='Inputs and Settings', status='info',collapsible = TRUE,
                          fluidRow(
                            column(2, radioButtons("Gene_Ensembl_spieces", "Species", choices=c("Human"='A', "Mouse"='B'), selected="A")),
                            column(4, radioButtons("Gene_Ensembl_input_type", "Input type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='B')),
                            column(4, radioButtons("Gene_Ensembl_output_type", "Output type", choices = c('Gene symbol' = 'A', 'Ensembl gene id' = 'B', 'Ensembl gene id (with version)' = 'C'), selected='A'))
                          ),
                          fluidRow(
                            column(5, textAreaInput('Gene_Ensembl_input_gene', 'Enter genes (line by line)')),
                          ),
                          h4(''),
                          fluidRow(column(12, verbatimTextOutput('Gene_Ensembl_convert_status') )),
                          fluidRow(column(12, actionButton('Gene_Ensembl_convert_start', 'Convert genes', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ))
                        )
                      ),
                      column(4, 
                        box(width=12, title='Conversion Table', status='danger',collapsible = TRUE,
                          fluidRow(
                            column(12, verbatimTextOutput('Gene_Ensembl_convert_table_status') ),
                            column(12, withSpinner(DT::dataTableOutput('Gene_Ensembl_convert_table'), type = 5, color = "#0dc5c1") )
                          )
                        )
                      ),
                      column(3, 
                        box(width=12, title='List of converted genes', status='warning',collapsible = TRUE,
                          fluidRow(
                            column(12, verbatimTextOutput('Gene_Ensembl_convert_result') )
                          )
                        )
                      )
                    )
                  )
                ),
              # Find gene loci
                tabPanel(strong('Find gene loci'),
                  box(width=12, status='primary',  solidHeader = TRUE, title='Find the genomic loci',
                    fluidRow(
                      column(5, 
                        box(width=12, title='Inputs and Settings', status= 'info',collapsible = TRUE,
                          fluidRow(
                            column(12, radioButtons("Find_genome_loci_direction", "Choose the method", choices = c('Input genes and find the coordinates' = 'A', 'Input coordinates and find the genes' = 'B'), selected='A')),
                            column(12, textAreaInput('Find_genome_loci_input', 'Enter gene names or coordinates (line by line)')),
                            column(12, h4('')),
                            column(12, verbatimTextOutput('Find_genome_loci_status') ),
                            column(4, actionButton('Find_genome_loci_start', 'Search', style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                          )
                        )
                      ),
                      column(4,
                        box(width=12, title='Search results', status='danger',collapsible = TRUE,
                          fluidRow(
                            column(12, verbatimTextOutput('Find_genome_loci_table_status') ),
                            column(12, withSpinner(DT::dataTableOutput('Find_genome_loci_table'), type = 5, color = "#0dc5c1") )
                          )
                        )
                      ),
                      column(3,
                        box(width=12, title='List of genes/coordinates', status='warning',collapsible = TRUE,
                          fluidRow(
                            column(12, verbatimTextOutput('Find_genome_loci_table_gene_names') )
                          )
                        )
                      )
                    )
                  )
                ),
              # Cross-tabulation analysis
                tabPanel(strong('Cross-tabulation analysis'),
                  box(width=12, status='primary',  solidHeader = TRUE, title='Cross-tabulation analysis',
                    # h3('Cross-tabulation analysis'),
                    fluidRow(
                      column(5,
                        fluidRow(
                          column(12, 
                            box(width=12, title='Table contents', status='info',collapsible = TRUE,
                              fluidRow(
                                column(12, h4(strong('Group Names'))),
                                column(6, textInput("Cross_tabulation_Row1", "Row - Group 1")),
                                column(6, textInput("Cross_tabulation_Row2", "Row - Group 2")),
                                column(6, textInput("Cross_tabulation_col1", "Column - Group 1")),
                                column(6, textInput("Cross_tabulation_col2", "Column - Group 2")),
                                column(12, h4(strong('Values'))),
                                column(6, numericInput("Cross_tabulation_val1", "Row-Group1 & Column-Group1", 0, min=0)),
                                column(6, numericInput("Cross_tabulation_val2", "Row-Group1 & Column-Group2", 0, min=0)),
                                column(6, numericInput("Cross_tabulation_val3", "Row-Group2 & Column-Group1", 0, min=0)),
                                column(6, numericInput("Cross_tabulation_val4", "Row-Group2 & Column-Group2", 0, min=0)),
                                column(12,h3("")),
                                hr(),
                              )
                            )
                          ),
                          column(12,
                            box(width=12,title='2x2 Table', status='warning',collapsible = TRUE,
                              fluidRow(column(12, verbatimTextOutput("cross_table_status"))),
                              fluidRow(column(12, dataTableOutput("Cross_tabulation_table")))
                            )
                          ),
                          column(12,
                            box(width=12, title='Statistic test', status='danger',collapsible = TRUE,
                              fluidRow(
                                column(12, radioButtons('cross_table_Statistic_method', "Choose a method", choices=c('Chi-squre test'='A', "Fisher's exact test" = 'B'), selected='A')),
                                column(12, verbatimTextOutput("cross_table_Statistic")),
                              )                          
                            )
                          )
                        )
                      ),
                      column(7,
                        box(width=12, title='Plot',status='danger',collapsible = TRUE,
                          fluidRow(
                            column(12, radioButtons('Cross_tabulation_plot_method', 'Choose the Plot method', choices=c(
                                'Calculate the percentile (stack bar plot)'='A', 
                                'Use the original count (stack bar plot)'='C',
                                'Use the original count (dodge bar plot)'='D'
                              ), selected='A')
                            ),
                            column(10, verbatimTextOutput("Cross_tabulation_plot_status")),
                            column(2, 
                              dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                  column(6, sliderInput('Cross_tabulation_plot.width', 'Fig width (Feature plot)', min=300, max=3000, value=500, step=10)),
                                  column(6, sliderInput('Cross_tabulation_plot.height', 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10)),
                                  column(6, sliderInput('Cross_tabulation_plot_XY_label.font.size', 'X/Y label font size', min=1, max=15, value=5, step=1)),
                                  column(6, sliderInput('Cross_tabulation_plot_XY_title.font.size', 'Y title font size', min=1, max=15, value=5, step=1)),
                                  column(6, sliderInput('Cross_tabulation_plot_legend_size', 'Legend font size', min=1, max=15, value=5, step=1)),
                                ),
                                fluidRow(
                                  column(6, colourpicker::colourInput('Cross_tabulation_plot_col1_colour', 'Colour for Column-Group 1', value='#0D00FF')),
                                  column(6, colourpicker::colourInput('Cross_tabulation_plot_col2_colour', 'Colour for Column-Group 2', value='#92D113')),
                                ),
                                fluidRow(
                                  column(6, materialSwitch('Cross_tabulation_plot_col2_colour_while_background', 'Use white background', value=FALSE, status = "success") )
                                ),
                                fluidRow(
                                  column(6, materialSwitch('Cross_tabulation_plot_rotate_x', 'Rotate X labels', value=FALSE, status = "success") ),
                                  column(6, 
                                    conditionalPanel(
                                      condition='input.Cross_tabulation_plot_rotate_x == true',
                                      numericInput("Cross_tabulation_plot_rotate_x_angle", "Angle", 45, min=0)
                                    )
                                  )
                                ),
                                circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                              )
                            ),
                            column(12, withSpinner(plotOutput("Cross_tabulation_plot",  width="100%", height="100%"), type = 5, color = "#0dc5c1"))
                          )
                        )
                      ),
                    )
                  )
                ),
              # Venn Diagram
                tabPanel(strong('Venn Diagram'),
                  box(width=12, title='Venn Diagram', status='primary',  solidHeader = TRUE,
                    fluidRow(
                      column(4,
                        box(width=12, title='Information of each group',collapsible = TRUE, status='info',
                          fluidRow(
                            column(12, radioButtons('Venn_Diagram_method', 'Choose a method', choices=c('2D Venn diagram'='A', '3D Venn diagram'='B'), selected='A')),
                            column(12, textInput("Venn_Diagram_Group1_name", "Group 1 title")),
                            column(12, textAreaInput("Venn_Diagram_Group1_element", "Group 1 element")),
                            column(12, textInput("Venn_Diagram_Group2_name", "Group 2 title")),
                            column(12, textAreaInput("Venn_Diagram_Group2_element", "Group 2 element")),
                            conditionalPanel(
                              condition = 'input.Venn_Diagram_method == "B" ||  input.Venn_Diagram_method == "C"',  
                              column(12, textInput("Venn_Diagram_Group3_name", "Group 3 title")),
                              column(12, textAreaInput("Venn_Diagram_Group3_element", "Group 3 element")),
                            )
                          ),
                          h3(),
                          fluidRow(
                            column(12, h4('Show the overlapping elements')),
                            conditionalPanel(
                              condition = 'input.Venn_Diagram_method == "A"',  
                              column(12, selectInput('Venn_Diagram_show_overlap_2D', 'Choose a category',  c('None'='None', 'in Group1 & Group2', 'only in Group1', 'only in Group2'), selected = 'None')),
                              column(12, verbatimTextOutput("Venn_Diagram_show_overlap_2D_list")),
                            ),
                            conditionalPanel(
                              condition = 'input.Venn_Diagram_method == "B"',  
                              column(12, selectInput('Venn_Diagram_show_overlap_3D', 'Choose a category',  c('None'='None', 'in Group1 & Group2 & Group3', 'in Group1 & Group2', 
                                'in Group2 & Group3', 'in Group3 and Group1', 'in Group1 & Group2 but not in Group3', 'in Group2 & Group3 but not in Group1',
                                'in Group3 and Group1 but not in Group2', 'Only in Group1','Only in Group2','Only in Group3'), selected = 'None')),
                              column(12, verbatimTextOutput("Venn_Diagram_show_overlap_3D_list")),
                            ),
                          )
                        )
                      ),
                      column(8,
                        box(width=12, title='Plot',collapsible = TRUE, status='danger',
                          fluidRow(
                            column(10, verbatimTextOutput("Venn_Diagram_status")),
                            column(2, 
                              dropdownButton( h4(strong("Plot Options")),
                                fluidRow(
                                  column(6, sliderInput('Venn_Diagram_plot.width', 'Fig width (Feature plot)', min=300, max=3000, value=500, step=10)),
                                  column(6, sliderInput('Venn_Diagram_plot.height', 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10)),
                                  column(6, sliderInput('Venn_Diagram_plot_label.font.size', 'Label font size', min=0.01, max=3, value=0.5, step=0.01)),
                                  column(6, sliderInput('Venn_Diagram_plot_legend_size', 'Legend font size', min=0.01, max=3, value=0.5, step=0.01)),
                                  column(6, colourpicker::colourInput('Venn_Diagram_plot_col1_colour', 'Colour for Column-Group 1', value='#AEECF5')),
                                  column(6, colourpicker::colourInput('Venn_Diagram_plot_col2_colour', 'Colour for Column-Group 2', value='#FFF5AB')),
                                  conditionalPanel(
                                    condition = 'input.Venn_Diagram_method == "B" ||  input.Venn_Diagram_method == "C"',
                                    column(6, colourpicker::colourInput('Venn_Diagram_plot_col3_colour', 'Colour for Column-Group 3', value='#F0A6F5')),
                                  )
                                ),
                                circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Plot Options")
                              )
                            ),
                            column(12, withSpinner(plotOutput("Venn_Diagram_plot", width="100%", height="100%"), type = 5, color = "#0dc5c1") )
                          )
                        )
                      )
                    )
                  )
                ),
              # Network plot
                tabPanel(strong('Network plot'), 
                  box(width=12, status='primary',  solidHeader = TRUE, title='Network plot',
                      # h3('Network plot'),
                      fluidRow(
                      column(4,
                        box(width=12, title='Input',collapsible = TRUE, status='info',
                          fluidRow(
                            column(12, fileInput("Network_input_file", "upload a tsv file", accept = c(".tsv")) ),
                            column(12, materialSwitch('Network_input_example', 'Use an example data', value=FALSE,  status='info') )
                          ),
                          fluidRow(
                            column(12, h4('The input data table')),
                            column(12, dataTableOutput("Network_input_table")),
                            column(12, h4(''))
                          )
                        )
                      ),
                      column(8,
                        box(width=12, title='Plot',collapsible = TRUE,status='danger',
                          fluidRow(
                            column(10, verbatimTextOutput("Network_input_table_visNet_status") ),
                            column(2, 
                              dropdownButton( h4(strong("Graph Settings")),
                                  fluidRow(
                                  column(6, selectInput("Network_input_shape_from", "The shape of node (From)", c('ellipse', 'circle', 'database', 'box', 'text', 'dot', 'star', 'triangle', 'triangleDown', 'square'), selected='ellipse')),
                                  column(6, selectInput("Network_input_shape_to", "The shape of node (To)", c('ellipse', 'circle', 'database', 'box', 'text', 'dot', 'star', 'triangle', 'triangleDown', 'square'), selected='circle')),
                                  column(6, colourpicker::colourInput("Network_input_color_from", "The color of node (From)", value='#F7AFAF' )),
                                  column(6, colourpicker::colourInput("Network_input_color_to", "The color of node (To)", value='#B2E9FF' )),
                                  column(12, materialSwitch("Network_input_arrow", "Show direction", value=FALSE,  status='info' )),
                                ),
                                circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "600px",  tooltip = tooltipOptions(title = "Graph Settings")
                              ),
                            ),
                            column(12, h4('')),
                            column(12, withSpinner(visNetworkOutput("Network_input_table_visNet" , width = "100%", height = "1000px"), type = 5, color = "#0dc5c1") )
                          )
                        )
                      )
                      )
                  )
                )
              #
            )
          ),
        #### wiki-document ####
          tabItem( tabName='wiki_document',
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
                  column(12, actionButton("session_info_refresh", "Refresh Session Info")),
                  column(12, h4('')),
                  column(12, verbatimTextOutput("session_info"))
                )
              ),
              column(3, h2(' '))
            )
          )
      ),
      h4(tags$div("Last updated on 18. July, 2025 ", style = "text-align: right;"))
    )
  )
)


rm(tags, envir = .GlobalEnv)

##############################################################################
server <- function(input, output, session) {

  ### Library loading ################
    observeEvent(input$sidebar,{
      if(input$sidebar == 'scRNA'){
        if(!requireNamespace("Seurat", quietly = TRUE)) { install.packages("Seurat", dependencies = FALSE) }
        suppressMessages(library(Seurat))
        if(!requireNamespace("reshape2", quietly = TRUE)) { install.packages("reshape2", dependencies = FALSE) }
        suppressMessages(library(reshape2))
        if(!requireNamespace("cowplot", quietly = TRUE)) { install.packages("cowplot", dependencies = FALSE) }
        suppressMessages(library(cowplot))
        if(!requireNamespace("AUCell", quietly = TRUE)) { BiocManager::install("AUCell", ask = FALSE) }
        suppressMessages(library(AUCell))
      }else if(input$sidebar == 'igv'){
        if(!requireNamespace("GenomicAlignments", quietly = TRUE)) { BiocManager::install("GenomicAlignments", ask = FALSE) }
        if(!requireNamespace("EnrichedHeatmap", quietly = TRUE)) { BiocManager::install("EnrichedHeatmap", ask = FALSE) }
        if(!requireNamespace("rtracklayer", quietly = TRUE)) { BiocManager::install("rtracklayer", ask = FALSE) }
        if(!requireNamespace("circlize", quietly = TRUE)) { install.packages("circlize", dependencies = FALSE) }
        if(!requireNamespace("Gviz", quietly = TRUE)) { BiocManager::install("Gviz", ask = FALSE) }
        if(!requireNamespace("PWMEnrich.Hsapiens.background", quietly = TRUE)) { BiocManager::install("PWMEnrich.Hsapiens.background", ask = FALSE) }
        if(!requireNamespace("seqLogo", quietly = TRUE)) { BiocManager::install("seqLogo", ask = FALSE) }
        if(!requireNamespace("PWMEnrich", quietly = TRUE)) { BiocManager::install("PWMEnrich", ask = FALSE) }
        if(!requireNamespace("ggseqlogo", quietly = TRUE)) { install.packages("ggseqlogo", dependencies = FALSE) }
        suppressMessages(library(GenomicAlignments))
        suppressMessages(library(EnrichedHeatmap))
        suppressMessages(library(rtracklayer))
        suppressMessages(library(circlize))
        # suppressMessages(library(Gviz))
        suppressMessages(library(PWMEnrich.Hsapiens.background))
        suppressMessages(library(seqLogo))
        suppressMessages(library(PWMEnrich))
        suppressMessages(library(ggseqlogo))
        if(!requireNamespace("BSgenome.Hsapiens.UCSC.hg38", quietly = TRUE)) { BiocManager::install("BSgenome.Hsapiens.UCSC.hg38", ask = FALSE) } 
        suppressMessages(library(BSgenome.Hsapiens.UCSC.hg38))
        if(!requireNamespace("BSgenome.Hsapiens.UCSC.hg19", quietly = TRUE)) { BiocManager::install("BSgenome.Hsapiens.UCSC.hg19", ask = FALSE) }
        suppressMessages(library(BSgenome.Hsapiens.UCSC.hg19))
        
        data(PWMLogn.hg19.MotifDb.Hsap)
      }else if(input$sidebar == 'Data_Overview'){
        if(!requireNamespace("decoupleR", quietly = TRUE)) { BiocManager::install("decoupleR", ask = FALSE) }
        suppressMessages(library(decoupleR))
        # suppressMessages(library(visNetwork))
        # net <- readRDS('data/OmnipathR_net.rds')
        # suppressMessages(library(clusterProfiler)) # BiocManager::install("clusterProfiler")
      }else if(input$sidebar == 'Clinical_dataset'){
        suppressMessages(library(survival))
        suppressMessages(library(survminer))
        if(!requireNamespace("MCPcounter", quietly = TRUE)) {
          devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source", force = TRUE)
        }
        suppressMessages(library(MCPcounter))
        if(!requireNamespace("xCell", quietly = TRUE)) {
          devtools::install_github('dviraran/xCell')
        }
        suppressMessages(library(xCell))
      }else if(input$sidebar == 'Tools'){
        suppressMessages(library(visNetwork))
        suppressMessages(library(eulerr))

      }
    })
  ###

  ### Information Tab ##############################################################################
  
    #### Show the data list ####
      Dataset <- reactiveVal({
        tmp <- read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)
        data.frame(tmp)
      })
      output$Data_type_filter <- renderUI({ 
        tmp <- Dataset()
        selectInput('Data_type_filter', 'Data type', c(All= 'None', unique(tmp$Data.type)))
      })
      outputOptions(output, "Data_type_filter", suspendWhenHidden=FALSE)

      output$Seuqenced_by_filter <- renderUI({ 
        tmp <- Dataset()
        selectInput('Seuqenced_by_filter', 'Data from', c(All= 'None', unique(tmp$Data.from)))
      })
      outputOptions(output, "Seuqenced_by_filter", suspendWhenHidden=FALSE)

      output$DataBaseTable <- DT::renderDataTable({ 
        data_table_tmp <- Dataset()[order(Dataset()$Added.When, decreasing =T),]
        data_table_tmp <- data_table_tmp[,c( "Dataset", "Data.type", "CellLine", "Data.from", "When", 'Experiment', 'Control.group', 'Treatment.group', "Data.Class", "Description")] 
        if(!is.null(input$Data_type_filter) && input$Data_type_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.type == input$Data_type_filter, ] }
        else if(!is.null(input$Seuqenced_by_filter) && input$Seuqenced_by_filter != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Seuqenced_by_filter,] }
        datatable(data_table_tmp, 
          selection='none', extensions=c('Select'), rownames=F,
          options = list(select=list(style="multi", items='row'), scrollX = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0), 
          editable='cell') 
      },server = FALSE)

    #### allow editing the information ####
      observeEvent(input$DataBaseTable_cell_edit,{
        info <- input$DataBaseTable_cell_edit
        # output$status <- renderText(paste(as.character(info$row), as.character(info$col), as.character(info$value)))
        tmp <- Dataset()
        a <- tmp[info$row, info$col]
        if (!is.null(info$row) && !is.null(info$col) && !is.null(info$value) &&
            info$row > 0 && info$row <= nrow(tmp) &&
            info$col > 0 && info$col <= ncol(tmp)) {
          tmp[info$row, info$col] <- info$value
        } else {
          output$status <- renderText("Invalid cell edit detected.")
        }
        output$status <- renderText(paste0("'", a, "'", ' -> ', "'", info$value ,"'" ))
        tmp <- tmp[order(tmp$Added.When,decreasing =T),]
        Dataset(tmp)
        replaceData(dataTableProxy('Dataset'), Dataset(), resetPaging=F)
      })

    #### save changes when you push the button ####
      observeEvent(input$save_dt,{
        write.table(Dataset(), 'data/Database.tsv', row.names=F, sep='\t', quote=F)
        show_alert(title='Success!', text='The changes are saved.', type='success')
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
          write.table(Dataset(), 'data/Database.tsv', row.names=F, sep='\t', quote=F)
          show_alert(title='Success!', text='The selected row(s) are deleted.', type='success')
          output$status <- renderText('Deleted!')
        }else{
          show_alert(title='Error.',text='No row selected!', type='error')
          output$status <- renderText('No row selecetd!')
        }
      })

    #### data upload ####
      # show a preview
        output$upload_data_preview_status <- renderText({"Please upload the file. The top 10 lines of the file (header) will be displayed here."})
        output$upload_data_preview <- renderDataTable({ 
          req(input$upload_file)
          extension <- strsplit(input$upload_file$datapath, '\\.')[[1]][ length(strsplit(input$upload_file$datapath, '\\.')[[1]]) ]
          if(extension == 'tsv' | extension == 'txt'){
            gx_table <- read.table(input$upload_file$datapath, sep='\t', header=T,check.names = FALSE)
            if(!'id' %in% colnames(gx_table)){
              output$status_upload <- renderText("The column name containing gene names in the input file has to be set 'id'.")
            }else{
              output$status_upload <- renderText({NULL})
            }
            output$upload_data_preview_status <- renderText({NULL})
            return(datatable( head(gx_table, 10), options = list(scrollX = TRUE, scrollY = TRUE )))
          }else{
            output$upload_data_preview_status <- renderText({"Cannot show the preview of the uploaded file due to the file type. \nEither a TSV or TXT file can be previewed."})
            return(NULL)
          }
        })

      # data type selection
        output$upload_data_type_select <- renderUI({
          selectInput("upload_data_type_select_select", HTML("Data type * <br/> Ex.) Count data, DEG data, scRNA"), choices=c('--Select from the below--', unique(Dataset()$Data.type), 'Other'), selected='None')
        })

        output$upload_data_type <- renderUI({
          if(length(input$upload_data_type_select_select) > 0){
            if(input$upload_data_type_select_select == 'Other'){
              textInput("upload_data_type_manual", "Write the data type here *")
            }
          }
        })

      # upload data upon clicking the button
        observeEvent(input$upload_data,{
          if(is.null(input$upload_file)){
            output$status_upload <- renderText('Please upload a file!')
            show_alert(title='Error.',text='Please upload a file!', type='error')
            return()
          }
          req(input$upload_file)
          uploaded_file <- input$upload_file
          # detail
          dataset.name.upload <- unlist(strsplit(input$upload_dataset_name, split = "\n"))[1]
          if(input$upload_data_type_select_select == 'Other'){
            if(nchar(input$upload_data_type_manual)==0){
              output$status_upload <- renderText('* is a mandatory filed!')
              show_alert(title='Error.',text='* is a mandatory filed!', type='error')
              return()
            }else{
              data.type.upload <- unlist(strsplit(input$upload_data_type_manual, split = "\n"))[1]
            }
          }else{
            data.type.upload <- input$upload_data_type_select_select
          }
          cellline.upload <- unlist(strsplit(input$upload_cell_line, split = "\n"))[1]
          Data.from.upload <- unlist(strsplit(input$upload_data_from, split = "\n"))[1]
          When.upload <- unlist(strsplit(input$upload_when, split = "\n"))[1]
          Description <- unlist(strsplit(input$upload_description, split = "\n"))[1]
          Experiment.upload <- unlist(strsplit(input$upload_Experiment, split = "\n"))[1]
          Control.group.upload <- unlist(strsplit(input$upload_Control_group, split = "\n"))[1]
          Treatment.group.upload <- unlist(strsplit(input$upload_Treatment_group, split = "\n"))[1]
          Data.Class.upload <- input$upload_Data_Class
          if(Data.Class.upload != 'B'){
            Control.group.upload <- ''
            Treatment.group.upload <- ''
          }
          if(nchar(input$upload_dataset_name)==0 | nchar(input$upload_data_from)==0 | nchar(input$upload_Experiment)==0 |  input$upload_data_type_select_select == '--Select from the below--' ){
            output$status_upload <- renderText('* is a mandatory filed!')
            show_alert(title='Error.',text='* is a mandatory filed!', type='error')
            return()
          }else if(dataset.name.upload %in% Dataset()$Dataset){
            output$status_upload <- renderText('The Dataset name is duplicated!')
            show_alert(title='Error.',text='The Dataset name is duplicated!', type='error')
            return()
          }else if (str_detect(dataset.name.upload, "[;/,!@#$%]")) {
            output$status_upload <- renderText('The Dataset name cannot contain "/ , ! # @ $ % " !')
            show_alert(title='Error.',text='Avoid special characters; use only alphabets, numbers, underscores and dots.', type='error')
            return()
          }else if (str_detect(Experiment.upload, "[;/,!@#$%]")) {
            output$status_upload <- renderText('The Experiment name cannot contain "/ , ! # @ $ % " !')
            show_alert(title='Error.',text='Avoid special characters; use only alphabets, numbers, underscores and dots.', type='error')
            return()
          }else if (str_detect(Data.from.upload, "[;/,!@#$%]")) {
            output$status_upload <- renderText('The Data.from cannot contain "/ , ! # @ $ % " !')
            show_alert(title='Error.',text='Avoid special characters; use only alphabets, numbers, underscores and dots.', type='error')
            return()
          }else if (str_detect(data.type.upload, "[;/,!@#$%]")) {
            output$status_upload <- renderText('The Data type cannot contain "/ , ! # @ $ % " !')
            show_alert(title='Error.',text='Avoid special characters; use only alphabets, numbers, underscores and dots.', type='error')
            return()
          }else{
            if(Data.Class.upload == 'A' | Data.Class.upload == 'B'){
              gx_table <- read.table(input$upload_file$datapath, sep='\t', header=T,check.names = FALSE)
              if(!'id' %in% colnames(gx_table)){
                output$status_upload <- renderText("The column name containing gene names in the input file has to be set 'id'.")            
                show_alert(title='Error.',text="The column name containing gene names in the input file has to be set 'id'.", type='error')
                return()
              }
            }
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
            show_alert(title='Success!!',text='The file was uploaded to OmicsBridge', type='success')
            return()
          }
        })
      
      #
  ###

  ### Gene sets Tab ################################################################################

    #### Show the data list ####
      Original_geneset_lsit <- reactiveVal({data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=T))})
      output$Original_geneset_DataBaseTable <-  DT::renderDataTable({
        data_table_tmp <- Original_geneset_lsit()[order(Original_geneset_lsit()$Added.When, decreasing =T),]
        data_table_tmp <- data_table_tmp[,c('Geneset.name','Description','Cell.type','Data.source', 'Genes')]
        datatable(data_table_tmp, 
          selection='none', extensions=c('Select'), 
          options = list(select=list(style="multi", items='row'), scrollX = TRUE,scrollY = TRUE, pageLength = 10 , dom='Blfrtip', rowId=0
            ,columnDefs = list(
              list(
                targets = c(1,5),  # 5th column, zero-based index
                render = DT::JS(
                  "function(data, type, row, meta) {",
                  "  return '<div style=\"white-space: nowrap; overflow-x: auto;\">' + data + '</div>';",
                  "}"
                )
              )
            )
          ), 
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
        show_alert(title='Change saved!',text='The custome gene sets were updated.', type='success')
        return()
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
        # When.upload <- Sys.time()
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
          show_alert(title='Error!',text='The Geneset name is duplicated.', type='error')
          return()
        }else if(is.null(genes) || genes == ''){
          output$Original_geneset_status_upload <- renderText('Please Enter the names of the genes.')
          show_alert(title='Error!',text='Please Enter the names of the genes.', type='error')
          return()
        }else{
          tmp <- Original_geneset_lsit()
          tmp <- add_row(tmp, Geneset.name=geneset.name.upload , Description=Description , Cell.type=Cell.type.upload , Data.source=data.source.upload , Genes=genes, Added.When=time_stamp)
          tmp <- tmp[order(tmp$Added.When, decreasing =T),]
          Original_geneset_lsit(tmp)
          replaceData(dataTableProxy('Original_geneset_lsit'), Original_geneset_lsit(), resetPaging=F)
          write.table(Original_geneset_lsit(), 'data/Genesets_list.tsv', row.names=F, sep='\t', quote=F)
          output$Original_geneset_status_upload <- renderText('uploaded!')
          show_alert(title='Uploaded!',text='The gene set was successfully uploaded.', type='success')
          return()
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
        outputOptions(output, "Seuqenced_by", suspendWhenHidden=FALSE)
        
        output$Experiments <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}}
          # if(!is.null(input$Data_type) & input$Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}
          selectInput('Experiments', 'Experiment', c('None'= 'None', unique(df_tmp$Experiment)))
        })
        outputOptions(output, "Experiments", suspendWhenHidden=FALSE)

        output$Data_type <- renderUI({ 
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]} }
          if(!is.null(input$Experiments)) { if(input$Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}}
          selectInput('Data_type', 'Data type', c('None'= 'None', unique(df_tmp$Data.type)))
        })
        outputOptions(output, "Data_type", suspendWhenHidden=FALSE)
      
      ##### Select a dataset #####
        output$Dataset_select <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[(df_tmp$Data.Class == 'A') | (df_tmp$Data.Class == 'B'),]
          if(!is.null(input$Data_type)) { if(input$Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}}
          if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}}
          if(!is.null(input$Experiments)) { if(input$Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}}
          selectInput('Dataset_select', 'Dataset select', c('None'='None', unique(df_tmp$Dataset)) )
        })
        outputOptions(output, "Dataset_select", suspendWhenHidden=FALSE)

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
              df_tmp <- read.table(path, sep='\t', header=T,check.names = FALSE)
              if(colnames(df_tmp)[1] == 'X'){ colnames(df_tmp)[1] <- 'id'}
              if("-log10.pvalue" %in% colnames(df_tmp)){ df_tmp[,"-log10.pvalue"] <- replace_inf_with_largest_values(df_tmp[,"-log10.pvalue"]) }
              if("-log10.padj" %in% colnames(df_tmp)){ df_tmp[,"-log10.padj"] <- replace_inf_with_largest_values(df_tmp[,"-log10.padj"]) }
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
        output$DataTable <- DT::renderDataTable({ datatable( df(), options = list(scrollX = TRUE, pageLength = 20 )) })
        output$Count_data_DataTable <- DT::renderDataTable({ datatable(df(), options = list(scrollX = TRUE, pageLength = 20 )) })


      ##### Plot #####
        ###### X and Y axis necessary parameters / option #####
          output$Scat.X <- renderUI({ 
            if(!is.null(df())){ X_axis_name <- names(df()) }
            else{ X_axis_name <- c() }
            # default selected x name CRISPR screening (gRNA LFC)
            if(length(Dataoverview_Data_type()) == 0){
              selectInput('scat.x', 'x', c('None'='None', X_axis_name))
            }else{
              selectInput('scat.x', 'x', c('None'='None', X_axis_name))
            }
          })
          outputOptions(output, "Scat.X", suspendWhenHidden=FALSE)
          
          output$Scat.Y <- renderUI({ 
            if(!is.null(df())){ Y_axis_name <- names(df()) }
            else{ Y_axis_name <- c() }
            # default selected x name
            if(length(Dataoverview_Data_type()) == 0){
              selectInput('scat.y', 'y', c('None'='None', Y_axis_name))
            }else{
              selectInput('scat.y', 'y', c('None'='None', Y_axis_name)) 
            }
          })
          outputOptions(output, "Scat.Y", suspendWhenHidden=FALSE)


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
            if(input$show_entered_gene_info){ 
              output$Interesting_gene_outFile_status <- renderText({NULL})
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
            if(input$scat.y == 'None' | input$scat.x == 'None'){
              return(NULL)
            }
            df_main_plot <- df()
            if(input$show_filterin_input_option=='B'){
              if(input$How_to_filter == 'A'){
                df_main_plot <- df_main_plot[df_main_plot[input$scat.y] >= input$Overviwe_Top_bottom_Y_threshold,]
                X_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x]>=0], 1-(input$Overviwe_Top_threshold/100), na.rm = T)
                Y_thr <- quantile(df_main_plot[input$scat.x][df_main_plot[input$scat.x]<=0], input$Overviwe_Bottom_threshold/100, na.rm = T)
                df_main_plot[((df_main_plot[input$scat.x] > X_thr | df_main_plot[input$scat.x] < Y_thr)), ]
              }else if(input$How_to_filter == 'B'){
                if(input$Main_scatter_thr_X_method == 'A' & input$Main_scatter_thr_Y_method == 'A'){
                  return(NULL)
                }
                df_main_plot_filter <- switch(input$Main_scatter_thr_X_method,
                  "A" = df_main_plot,
                  "B" = df_main_plot[df_main_plot[input$scat.x] > input$Main_scatter_thr_X1, ],
                  "C" = df_main_plot[df_main_plot[input$scat.x] < input$Main_scatter_thr_X2, ],
                  "D" = df_main_plot[(df_main_plot[input$scat.x] > input$Main_scatter_thr_X2) & (df_main_plot[input$scat.x] < input$Main_scatter_thr_X1), ],
                  "E" = df_main_plot[(df_main_plot[input$scat.x] < input$Main_scatter_thr_X2) | (df_main_plot[input$scat.x] > input$Main_scatter_thr_X1), ],
                )
                df_main_plot_filter <- switch(input$Main_scatter_thr_Y_method,
                  "A" = df_main_plot_filter,
                  "B" = df_main_plot_filter[df_main_plot_filter[input$scat.y] > input$Main_scatter_thr_Y1, ],
                  "C" = df_main_plot_filter[df_main_plot_filter[input$scat.y] < input$Main_scatter_thr_Y2, ],
                  "D" = df_main_plot_filter[(df_main_plot_filter[input$scat.y] > input$Main_scatter_thr_Y2) & (df_main_plot_filter[input$scat.y] < input$Main_scatter_thr_Y1), ],
                  "E" = df_main_plot_filter[(df_main_plot_filter[input$scat.y] < input$Main_scatter_thr_Y2) | (df_main_plot_filter[input$scat.y] > input$Main_scatter_thr_Y1), ],
                )
                df_main_plot_filter
              }
            }else{
              return(NULL)
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
            if(input$show_filterin_input_option=='C'){
              if(input$pathway_dataset_select == 'HALLMARK (human)'){ gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt') }
              else if(input$pathway_dataset_select == 'HALLMARK (mouse)'){ gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt') } 
              else if(input$pathway_dataset_select == 'Custom'){ 
                tmp <- input$upload_custom_pathway_file
                if (is.null(tmp)){ gsc <- NULL }
                else { gsc <- getGmt(tmp$datapath)}
              }
              gsc
            }else{
              return(NULL)
            }
          })

          # select pathway
          output$select_pathway <- renderUI({
            gene_sets_names <- c()
            if(!is.null(Gene_set())){
              for ( i in 1:length(Gene_set())){ gene_sets_names <- c(gene_sets_names, Gene_set()@.Data[[i]]@setName)}
            }
            selectInput('select_pathway', 'Select a geneset',  c('None'='None', gene_sets_names))  
          })
          outputOptions(output, "select_pathway", suspendWhenHidden=FALSE)

          # list of the genes in the pathway
          genes_in_the_pathway <- reactive({ 
            if(input$select_pathway == 'None'){ c('None') }
            else{ Gene_set()[[input$select_pathway]]@geneIds }
          })

          # Show pathway genes information as a table
          df_outliers_pathway <- reactive({
            df_main_plot <- df()
            if(input$show_filterin_input_option=='C') { 
              if(input$Main_scatter_pathway_filter){
                df_main_plot_pathway <- df_main_plot[df_main_plot$id %in% genes_in_the_pathway(),]
                if(input$Main_scatter_pathway_thr_X_method == 'A' & input$Main_scatter_pathway_thr_Y_method == 'A'){
                  df_main_plot_pathway
                }else{
                  df_main_plot_pathway <- switch(input$Main_scatter_pathway_thr_X_method,
                    "A" = df_main_plot_pathway,
                    "B" = df_main_plot_pathway[df_main_plot_pathway[input$scat.x] > input$Main_scatter_pathway_thr_X1, ],
                    "C" = df_main_plot_pathway[df_main_plot_pathway[input$scat.x] < input$Main_scatter_pathway_thr_X2, ],
                    "D" = df_main_plot_pathway[(df_main_plot_pathway[input$scat.x] > input$Main_scatter_pathway_thr_X2) & (df_main_plot_pathway[input$scat.x] < input$Main_scatter_pathway_thr_X1), ],
                    "E" = df_main_plot_pathway[(df_main_plot_pathway[input$scat.x] < input$Main_scatter_pathway_thr_X2) | (df_main_plot_pathway[input$scat.x] > input$Main_scatter_pathway_thr_X1), ],
                  )
                  df_main_plot_pathway <- switch(input$Main_scatter_pathway_thr_Y_method,
                    "A" = df_main_plot_pathway,
                    "B" = df_main_plot_pathway[df_main_plot_pathway[input$scat.y] > input$Main_scatter_pathway_thr_Y1, ],
                    "C" = df_main_plot_pathway[df_main_plot_pathway[input$scat.y] < input$Main_scatter_pathway_thr_Y2, ],
                    "D" = df_main_plot_pathway[(df_main_plot_pathway[input$scat.y] > input$Main_scatter_pathway_thr_Y2) & (df_main_plot_pathway[input$scat.y] < input$Main_scatter_pathway_thr_Y1), ],
                    "E" = df_main_plot_pathway[(df_main_plot_pathway[input$scat.y] < input$Main_scatter_pathway_thr_Y2) | (df_main_plot_pathway[input$scat.y] > input$Main_scatter_pathway_thr_Y1), ],
                  )
                  df_main_plot_pathway
                }
              }else{
                df_main_plot_pathway <- df_main_plot[df_main_plot$id %in% genes_in_the_pathway(),]
                df_main_plot_pathway
              }
            }
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
          outputOptions(output, "Plot_Gene_set_select_geneset", suspendWhenHidden=FALSE)

          # dataframe only with the genes in the selected custom geneset
          df_genes_custom_geneset <- reactive({
            df_main_plot <- df()
            if(input$Plot_Gene_set_select_geneset != 'None'){
              target_genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Plot_Gene_set_select_geneset, ]$Genes, split=', ')[[1]]
              df_tmp <- df_main_plot[df_main_plot$id %in% target_genes,] 
              if(input$Main_scatter_geneset_filter){
                df_tmp <- df_main_plot[df_main_plot$id %in% target_genes,] 
                if(input$Main_scatter_geneset_thr_X_method == 'A' & input$Main_scatter_geneset_thr_Y_method == 'A'){
                  return(df_tmp)
                }else{
                  df_tmp <- switch(input$Main_scatter_geneset_thr_X_method,
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$scat.x] > input$Main_scatter_geneset_thr_X1, ],
                    "C" = df_tmp[df_tmp[input$scat.x] < input$Main_scatter_geneset_thr_X2, ],
                    "D" = df_tmp[(df_tmp[input$scat.x] > input$Main_scatter_geneset_thr_X2) & (df_tmp[input$scat.x] < input$Main_scatter_geneset_thr_X1), ],
                    "E" = df_tmp[(df_tmp[input$scat.x] < input$Main_scatter_geneset_thr_X2) | (df_tmp[input$scat.x] > input$Main_scatter_geneset_thr_X1), ],
                  )
                  df_tmp <- switch(input$Main_scatter_geneset_thr_Y_method,
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$scat.y] > input$Main_scatter_geneset_thr_Y1, ],
                    "C" = df_tmp[df_tmp[input$scat.y] < input$Main_scatter_geneset_thr_Y2, ],
                    "D" = df_tmp[(df_tmp[input$scat.y] > input$Main_scatter_geneset_thr_Y2) & (df_tmp[input$scat.y] < input$Main_scatter_geneset_thr_Y1), ],
                    "E" = df_tmp[(df_tmp[input$scat.y] < input$Main_scatter_geneset_thr_Y2) | (df_tmp[input$scat.y] > input$Main_scatter_geneset_thr_Y1), ],
                  )
                  return(df_tmp)
                }
              }else{
                return(df_tmp)
              }
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
          # select from a custom gene list
            output$target_gene_for_RNA_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
              selectInput('target_gene_for_RNA_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
            outputOptions(output, "target_gene_for_RNA_from_custom_geneset_select",  suspendWhenHidden=FALSE)

          # inputted gene list
            target_gene_for_RNA_table_tmp <- reactive({
              # when from a custom geneset
              if(input$target_gene_for_RNA_from_custom_geneset){
                if(input$target_gene_for_RNA_from_custom_geneset_select == 'None'){
                  output$Gene_ex_swarm_status_target_gene_for_RNA_table <- renderText({"Please select a custom geneset above first."})
                  return(NULL)
                }else{
                  output$Gene_ex_swarm_status_target_gene_for_RNA_table <- renderText({NULL})
                  genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$target_gene_for_RNA_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                  data.frame(Input=unique(unlist(strsplit(genes, split = "\n"))))
                }
              }else{
                if(nchar(input$target_gene_for_RNA) == 0){
                  output$Gene_ex_swarm_status_target_gene_for_RNA_table <- renderText({"Please enter gene names above first."})
                  return(NULL)
                }else{
                  output$Gene_ex_swarm_status_target_gene_for_RNA_table <- renderText({NULL})
                  data.frame(Input=unique(unlist(strsplit(input$target_gene_for_RNA, split = "\n"))))
                }
              }
            })

          # Table for selecting a inputted gene
            output$target_gene_for_RNA_table <- renderDataTable({
              if(is.null(target_gene_for_RNA_table_tmp())){
                tmp <- data.frame('Genes'=character(0), stringsAsFactors = FALSE)
                datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE)) 
              }else{
                datatable( target_gene_for_RNA_table_tmp(), selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE)) 
              }
              
            })
          
          # prepare a dataframe for expression
            df_gene <- reactive({
              if(Data_class() == 'A'){ # the selected datasets has to be a count table
                if(is.null(target_gene_for_RNA_table_tmp())){ # Not input genes
                  output$Gene_ex_swarm_status_outFile_expression <- renderText({'Please set up the Inputs. \nA table for the expressions of the selected genes across samples will be shown here.'})
                  output$Gene_ex_swarm_status <- renderText({'Please set up the Inputs. \nA swarm plot will be displayed here.'})
                  return(NULL)
                }
                if(length(input$target_gene_for_RNA_table_rows_selected) == 0){ # When there are inputted genes but none is selected yet.
                  output$Gene_ex_swarm_status_outFile_expression <- renderText({'Please select one or more genes from the table in the Inputs.'})
                  output$Gene_ex_swarm_status <- renderText({'Please select one or more genes from the table in the Inputs.'})
                  return(NULL)
                }
                Gene <- target_gene_for_RNA_table_tmp()[input$target_gene_for_RNA_table_rows_selected,]
                if(length(Gene)==1){ # when single gene is selected, return an expression table
                  if(Gene %in% df()$id){ # If the gene is really in the dataset
                    gene_num <- which(df()$id==Gene)
                    target_samples <- grep("_(R|r)ep.+$", colnames(df()), value=TRUE)
                    
                    # when you want to exclude some samples
                    if(input$Gene_ex_swarm_exclude_sample){ 
                      if(nchar(input$Gene_ex_swarm_exclude_sample_input) == 0){ # when nothing is written in the text area yet.
                        output$Gene_ex_swarm_status3 <- renderText({'Please write the sample names that you want to exclude.'})
                      }else{
                        exclude_samples <- intersect(unlist(strsplit(input$Gene_ex_swarm_exclude_sample_input, split = "\n")), target_samples) 
                        not_found_exclude_samples <- setdiff(unlist(strsplit(input$Gene_ex_swarm_exclude_sample_input, split = "\n")), target_samples)

                        # when excluded samples are not in the dataset
                        if(length(not_found_exclude_samples) > 0){ # when entered group names does not exsist
                          output$Gene_ex_swarm_status3 <- renderText({
                            tmp <- paste(not_found_exclude_samples, collapse=', ')
                            paste0('The following samples are not in the dataset. \nPlease enter the right sample names. \n', tmp)
                          })
                        }else{
                          output$Gene_ex_swarm_status3 <- renderText({NULL})
                        }
                        target_samples <- setdiff(target_samples, exclude_samples) # exclude the samples
                      }
                    }

                    df_gene <- data.frame(t(df()[gene_num,target_samples])) 
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
                    df_gene$Group <- factor(Group, levels=unique(Group[order(Group)]))
                    if(input$Gene_ex_logsclae){
                      df_gene$Expression <- log2(df_gene$Expression+1)
                    }
                    output$Gene_ex_swarm_status_outFile_expression <- renderText({NULL})
                    output$Gene_ex_swarm_status <- renderText({NULL})
                    return(df_gene) 
                  }else{ # when the gene is not found in the dataset
                    output$Gene_ex_swarm_status_outFile_expression <- renderText({ paste0('The inputted gene ("', Gene, '") is not in this data. \nPlease make sure the gene name is correct and does not have unnecessary spaces.') })
                    output$Gene_ex_swarm_status <- renderText({ paste0('The inputted gene ("', Gene, '") is not in this data. \nPlease make sure the gene name is correct and does not have unnecessary spaces.') })
                    return(NULL)
                  }
                }else{ # when selecting multiple gene
                  genes_not_included = c()
                  df_gene <- data.frame('Expression' = c(), 'Group'=c(), 'Gene'= c())
                  target_samples <- grep("_(R|r)ep.+$", colnames(df()), value=TRUE)
                  # when you want to exclude some samples
                  if(input$Gene_ex_swarm_exclude_sample){ 
                    if(nchar(input$Gene_ex_swarm_exclude_sample_input) == 0){ # when nothing is written in the text area yet.
                      output$Gene_ex_swarm_status3 <- renderText({'Please write the sample names that you want to exclude.'})
                    }else{
                      exclude_samples <- intersect(unlist(strsplit(input$Gene_ex_swarm_exclude_sample_input, split = "\n")), target_samples) 
                      not_found_exclude_samples <- setdiff(unlist(strsplit(input$Gene_ex_swarm_exclude_sample_input, split = "\n")), target_samples)

                      # when excluded samples are not in the dataset
                      if(length(not_found_exclude_samples) > 0){ # when entered group names does not exsist
                        output$Gene_ex_swarm_status3 <- renderText({
                          tmp <- paste(not_found_exclude_samples, collapse=', ')
                          paste0('The following samples are not in the dataset. \nPlease enter the right sample names. \n', tmp)
                        })
                      }else{
                        output$Gene_ex_swarm_status3 <- renderText({NULL})
                      }
                      target_samples <- setdiff(target_samples, exclude_samples) # exclude the samples
                    }
                  }
                  
                  # for each gene in the inputted genes
                  for (each_gene in Gene){
                    if(each_gene %in% df()$id){
                      gene_num <- which(df()$id==each_gene)
                      df_gene_tmp <- data.frame(t(df()[gene_num,target_samples])) 
                      colnames(df_gene_tmp) <- c('Expression')
                      Group <- c()
                      for (i in strsplit(rownames(df_gene_tmp), '_')){
                        tmp <- ''
                        for(j in 1:(length(i)-1)){
                          tmp <- paste0(tmp, i[j],'_')
                        }
                        tmp <- substr(tmp, 1, nchar(tmp)-1)
                        Group <- c(Group, tmp)
                      }
                      df_gene_tmp$Group <- Group
                      df_gene_tmp$Gene <- each_gene
                      rownames(df_gene_tmp) <- NULL
                      df_gene <- rbind(df_gene, df_gene_tmp)
                    }else{
                      genes_not_included <- c(genes_not_included, each_gene)
                    }
                  }
                  if(length(genes_not_included) > 0){ # If there are genes not found in the dataset
                    genes_not_found <- paste(genes_not_included, collapse=', ')
                    output$Gene_ex_swarm_status_outFile_expression <- renderText({ paste0('The following genes are not in this data. \nPlease make sure the gene names are correct and do not have unnecessary spaces. \n', genes_not_found)})
                    output$Gene_ex_swarm_status <- renderText({ paste0('The following genes are not in this data. \nPlease make sure the gene names are correct and do not have unnecessary spaces. \n', genes_not_found)})
                  }else{
                    output$Gene_ex_swarm_status_outFile_expression <- renderText({NULL})
                    output$Gene_ex_swarm_status <- renderText({NULL})
                  }
                  if(length(df_gene)>0){
                    df_gene$Group <- factor(Group, levels=unique(Group[order(Group)]))
                    if(input$Gene_ex_logsclae){
                      df_gene$Expression <- log2(df_gene$Expression+1)
                    }
                    return(df_gene)
                  }else{
                    genes_not_found <- paste(genes_not_included, collapse=', ')
                    output$Gene_ex_swarm_status_outFile_expression <- renderText({ paste0('None of the selected genes are not found in this data. \nPlease make sure the gene names are correct and do not have unnecessary spaces. \n', genes_not_found)})
                    output$Gene_ex_swarm_status <- renderText({ paste0('None of the selected genes are not found in this data. \nPlease make sure the gene names are correct and do not have unnecessary spaces. \n', genes_not_found)})
                    return(NULL)
                  }
                }
              }else{
                return(NULL)
              }
            })

          # display the expression table
            output$outFile_expression <- renderDataTable({ 
              datatable( data.frame(df_gene()), options = list(scrollX = TRUE, scrollY = TRUE)) 
            })
          
          # list of the groups (for selecting groups when re-odering the X axis)
            output$Data_Overview_Swarm_group_name_list <- renderText({
              if(is.null(df_gene())){
                NULL
              }else{
                groups <- unique(df_gene()$Group)[order(unique(df_gene()$Group))]
                paste(groups, collapse='\n')
              }
            })

          # list of sample (in case you wnat to exclude some samples)
                                    # fluidRow(
                                    #   column(12, materialSwitch("Gene_ex_swarm_exclude_sample", "Want to exclude specific samples?", value = FALSE, status='danger')),
                                    #   conditionalPanel(
                                    #     condition = "input.Gene_ex_swarm_exclude_sample == true",
                                    #     column(12, verbatimTextOutput('Gene_ex_swarm_status3') ),
                                    #     column(12, textAreaInput("Gene_ex_swarm_exclude_sample_input", "Enter sample names (line by line)")),
                                    #     column(12, h5('List of the sample names')),
                                    #     column(12, verbatimTextOutput('Gene_ex_swarm_exclude_sample_input_list') )
                                    #   )
                                    # )
            output$Gene_ex_swarm_exclude_sample_input_list <- renderText({
              df_ex <- df()
              # sample names in the columns are XXX_Rep1, XXX_Rep2, etc. Choose these.
              samples <- grep("_(R|r)ep.+$", colnames(df_ex), value=TRUE)
              # sort
              samples <- sort(samples)
              paste(unlist(samples), collapse='\n')
            })
            output$Gene_ex_swarm_status3 <- renderText({'Hoge'})


          # colour option are mutually exclusive (use pallete or use a single colour)
            observeEvent(input$Data_Overview_Swarm_change_colour_pallete, { 
              if(input$Data_Overview_Swarm_change_colour_pallete){ updateCheckboxInput(session, "Data_Overview_Swarm_use_single_colour", value=FALSE)}
            })
            observeEvent(input$Data_Overview_Swarm_use_single_colour, { 
              if(input$Data_Overview_Swarm_use_single_colour){ updateCheckboxInput(session, "Data_Overview_Swarm_change_colour_pallete", value=FALSE)}
            })

          # plot
            output$Gene_ex_swarm <- renderPlot({
              if(is.null(df_gene())){
                return(ggplot())
              }
              df_tmp <- df_gene()
              if(input$order_group){ # When re-ordering the X axis.
                if(nchar(input$group_order) == 0){ # when nothing is written in the text area yet.
                  output$Gene_ex_swarm_status2 <- renderText({'Please write the group names that you want to use for plotting.'})
                  return(ggplot())
                }
                selected_group <- intersect(unlist(strsplit(input$group_order, split = "\n")), df_tmp$Group)
                not_found_selected_group <- setdiff(unlist(strsplit(input$group_order, split = "\n")), df_tmp$Group)
                if(length(not_found_selected_group) > 0){ # when entered group names does not exsist
                  output$Gene_ex_swarm_status2 <- renderText({
                    tmp <- paste(not_found_selected_group, collapse=', ')
                    paste0('The following groups are not in the dataset. \nPlease enter the right group names. \n', tmp)
                  })
                  if(length(selected_group) == 0){
                    return(ggplot())
                  }
                }else{
                  output$Gene_ex_swarm_status2 <- renderText({NULL})
                }
                df_tmp <- df_tmp[df_tmp$Group %in% selected_group,]
                df_tmp$Group <- factor(df_tmp$Group, levels = c(selected_group))
              }else{
                output$Gene_ex_swarm_status2 <- renderText({NULL})
              }
              Gene <- target_gene_for_RNA_table_tmp()[input$target_gene_for_RNA_table_rows_selected,]
              if(length(Gene) == 1){
                if(input$Data_Overview_Swarm_use_single_colour){
                  p <- ggplot(df_tmp, aes(x = Group, y = Expression)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size, color=input$Data_Overview_Swarm_choose_single_colour)
                }else{
                  p <- ggplot(df_tmp, aes(x = Group, y = Expression, color=Group)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size)
                  if(input$Data_Overview_Swarm_select_colour_pallete != 'None'){
                    p <- p + scale_color_viridis_d(option=input$Data_Overview_Swarm_select_colour_pallete) #(palette = input$Data_Overview_Swarm_select_colour_pallete)
                  }
                }
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+ theme(legend.position = 'none')
                p <- p + theme(axis.title.x = element_blank()) # + theme(plot.title = element_text(size = input$Data_Overview_Swarm_graph.title.font.size))
                p <- p + ylab(Gene)
              }else{
                data_list <- split(df_tmp, df_tmp$Gene)
                num_plots <- length(data_list)
                plots <- lapply(seq_along(data_list), function(i) {
                  if(input$Data_Overview_Swarm_use_single_colour){
                    p <- ggplot(data_list[[i]], aes(x=Group, y=Expression)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size, color=input$Data_Overview_Swarm_choose_single_colour)
                  }else{
                    p <- ggplot(data_list[[i]], aes(x=Group, y=Expression, color=Group)) + geom_beeswarm(size=input$Data_Overview_Swarm_pt.size)
                      if(input$Data_Overview_Swarm_select_colour_pallete != 'None'){
                        p <- p + scale_color_viridis_d(option=input$Data_Overview_Swarm_select_colour_pallete) #(palette = input$Data_Overview_Swarm_select_colour_pallete)
                      } 
                  }
                  each_gene <- data_list[[i]]$Gene[1]
                  p <- p + ylab(each_gene) + theme(axis.title.y = element_text(size = input$Data_Overview_Swarm_graph.title.font.size)) + theme(legend.position = 'none')  + theme(axis.text.y = element_text(size = input$Data_Overview_Swarm_ylab.font.size))
                  p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                  p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
                  if( i < num_plots){
                    p <- p + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank())
                  }else{
                    p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = input$Data_Overview_Swarm_xlab.font.size), axis.title.x = element_blank())
                  }
                  if(input$Data_Overview_Swarm_white_background){
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                  }
                  return(p)
                })
                p <- wrap_plots(plots, ncol=1)
              }
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.text.y = element_text(size = input$Data_Overview_Swarm_ylab.font.size), axis.text.x = element_text(size = input$Data_Overview_Swarm_xlab.font.size))
              p <- p + theme(axis.title = element_text(size = input$Data_Overview_Swarm_graph.title.font.size))
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
              if(input$Data_Overview_Swarm_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }, width=reactive(input$Data_Overview_Swarm_fig.width), height=reactive(input$Data_Overview_Swarm_fig.height), res=300)

          # download the table
            output$outFile_expression_download <- downloadHandler(
              filename = function(){"Swarm_plot.tsv"}, 
              content = function(fname){ write.table(df_gene(), fname, sep='\t',  quote=F) }
            )
          
          #

        ###### Scatter plot & bar plo ######
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
                  output$Gene_ex_status <- renderText({'Please select a dataset, X and Y.'})
                  return(ggplot())
                }
                else if( input$scat.x == 'None' ||input$scat.y == 'None'){ 
                  output$Gene_ex_status <- renderText({'Please select a dataset, X and Y.'})
                  return(ggplot())
                }
                else{ 
                  output$Gene_ex_status <- renderText({NULL})
                  p <- ggplot(df_main_plot, aes(x = .data[[input$scat.x]], y = .data[[input$scat.y]])) + geom_point(size = input$pt.size) 
                }
                # show outliers or show pathway genes # column(3, colourpicker::colourInput('outlier_gene_colour_id_negative', 'Negative side:', value='#FF8C00'))
                if(length(input$show_filterin_input_option) == 0){
                  output$Gene_ex_status <- renderText({'Please choose one method in the "Highlight filterd genes or gene sets in the plot" section.'})
                  return(ggplot())
                }
                if(input$show_filterin_input_option=='B'){
                  outliers <- df_outliers()
                  if(!is.null(outliers)){
                    p <- p + geom_point(data = outliers[outliers[input$scat.x]>=0,], color=input$outlier_gene_colour_id , size = input$high.pt.size)
                    p <- p + geom_point(data = outliers[outliers[input$scat.x]<=0,], color=input$outlier_gene_colour_id_negative , size = input$high.pt.size)
                    if(input$hide_gene_label == FALSE){
                      if(input$main_plot_white_back_label){
                        p <- p + geom_label_repel(data = outliers[outliers[input$scat.x]>=0,],  color = input$outlier_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps = 50, segment.size=0.2)
                        p <- p + geom_label_repel(data = outliers[outliers[input$scat.x]<=0,],  color = input$outlier_gene_colour_id_negative, aes(label = id), size = input$high.label.size, max.overlaps = 50, segment.size=0.2)
                      }else{
                        p <- p + geom_text_repel(data = outliers[outliers[input$scat.x]>=0,],  color = input$outlier_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps = 50, segment.size=0.2)
                        p <- p + geom_text_repel(data = outliers[outliers[input$scat.x]<=0,],  color = input$outlier_gene_colour_id_negative, aes(label = id), size = input$high.label.size, max.overlaps = 50, segment.size=0.2)
                      }
                    }
                    if(input$show_threhold_lines & input$How_to_filter == 'B'){
                      switch(input$Main_scatter_thr_X_method,
                        'B' = p <- p + geom_vline(xintercept=input$Main_scatter_thr_X1, linetype='dotted', size=0.2),
                        'C' = p <- p + geom_vline(xintercept=input$Main_scatter_thr_X2, linetype='dotted', size=0.2),
                        'D' = p <- p + geom_vline(xintercept=input$Main_scatter_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_thr_X2, linetype='dotted', size=0.2),
                        'E' = p <- p + geom_vline(xintercept=input$Main_scatter_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_thr_X2, linetype='dotted', size=0.2),
                      ) 
                      switch(input$Main_scatter_thr_Y_method,
                        'B' = p <- p + geom_hline(yintercept=input$Main_scatter_thr_Y1, linetype='dotted', size=0.2),
                        'C' = p <- p + geom_hline(yintercept=input$Main_scatter_thr_Y2, linetype='dotted', size=0.2),
                        'D' = p <- p + geom_hline(yintercept=input$Main_scatter_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_thr_Y2, linetype='dotted', size=0.2),
                        'E' = p <- p + geom_hline(yintercept=input$Main_scatter_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_thr_Y2, linetype='dotted', size=0.2),
                      ) 
                    } 
                  }
                }else if(input$show_filterin_input_option=='C'){
                  if(length(input$select_pathway)!= 0){
                    if(!is.null(input$select_pathway) & input$select_pathway != 'None'){
                      outliers_pathway <- df_outliers_pathway()
                      p <- p + geom_point(data = outliers_pathway, color=input$pathway_gene_colour_id , size = input$high.pt.size)
                      if(input$hide_gene_label_pathway==FALSE){ 
                        if(input$main_plot_white_back_label){
                          p <- p + geom_label_repel(data = outliers_pathway,  color = input$pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 40, segment.size=0.2)
                        }else{
                          p <- p + geom_text_repel(data = outliers_pathway,  color = input$pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 40, segment.size=0.2) 
                        }
                      }
                      if(input$Main_scatter_pathway_filter){
                        switch(input$Main_scatter_pathway_thr_X_method,
                          'B' = p <- p + geom_vline(xintercept=input$Main_scatter_pathway_thr_X1, linetype='dotted', size=0.2),
                          'C' = p <- p + geom_vline(xintercept=input$Main_scatter_pathway_thr_X2, linetype='dotted', size=0.2),
                          'D' = p <- p + geom_vline(xintercept=input$Main_scatter_pathway_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_pathway_thr_X2, linetype='dotted', size=0.2),
                          'E' = p <- p + geom_vline(xintercept=input$Main_scatter_pathway_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_pathway_thr_X2, linetype='dotted', size=0.2),
                        ) 
                        switch(input$Main_scatter_pathway_thr_Y_method,
                          'B' = p <- p + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y1, linetype='dotted', size=0.2),
                          'C' = p <- p + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y2, linetype='dotted', size=0.2),
                          'D' = p <- p + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y2, linetype='dotted', size=0.2),
                          'E' = p <- p + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_pathway_thr_Y2, linetype='dotted', size=0.2),
                        ) 
                        # p <- p + geom_hline(yintercept=input$y_threshold, linetype='dotted')
                      } 
                    }
                  }
                }else if(input$show_filterin_input_option=='D'){
                  if(length(input$Plot_Gene_set_select_geneset)!= 0){
                    if(!is.null(input$Plot_Gene_set_select_geneset) & input$Plot_Gene_set_select_geneset != 'None'){
                      custom_geneset <- df_genes_custom_geneset()
                      p <- p + geom_point(data = custom_geneset, color=input$Plot_Gene_set_pathway_gene_colour_id , size = input$high.pt.size)
                      if(input$Plot_Gene_sethide_gene_label==FALSE){ 
                        if(input$main_plot_white_back_label){
                          p <- p + geom_label_repel(data = custom_geneset,  color = input$Plot_Gene_set_pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 40, segment.size=0.2)
                        }else{
                          p <- p + geom_text_repel(data = custom_geneset,  color = input$Plot_Gene_set_pathway_gene_colour_id, aes(label = id), size = input$high.label.size, size = input$high.label.size, max.overlaps = 40, segment.size=0.2) 
                        }
                      }
                      if(input$Main_scatter_geneset_filter){
                        switch(input$Main_scatter_geneset_thr_X_method,
                          'B' = p <- p + geom_vline(xintercept=input$Main_scatter_geneset_thr_X1, linetype='dotted', size=0.2),
                          'C' = p <- p + geom_vline(xintercept=input$Main_scatter_geneset_thr_X2, linetype='dotted', size=0.2),
                          'D' = p <- p + geom_vline(xintercept=input$Main_scatter_geneset_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_geneset_thr_X2, linetype='dotted', size=0.2),
                          'E' = p <- p + geom_vline(xintercept=input$Main_scatter_geneset_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Main_scatter_geneset_thr_X2, linetype='dotted', size=0.2),
                        ) 
                        switch(input$Main_scatter_geneset_thr_Y_method,
                          'B' = p <- p + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y1, linetype='dotted', size=0.2),
                          'C' = p <- p + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y2, linetype='dotted', size=0.2),
                          'D' = p <- p + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y2, linetype='dotted', size=0.2),
                          'E' = p <- p + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Main_scatter_geneset_thr_Y2, linetype='dotted', size=0.2),
                        ) 
                      } 
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
                      genes_tmp <- paste(undetected_genes, collapse=', ')
                      paste0(tmp, genes_tmp)
                    })
                  }else{
                    output$Scatter_interesting_gene_status <- renderText({NULL})
                  }
                  if(input$show_label){ 
                    if(input$main_plot_white_back_label){
                      p <- p + geom_label_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$target_gene, split = "\n")),],  color = input$interesting_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps=50, segment.size=0.2) 
                    }else{
                      p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$target_gene, split = "\n")),],  color = input$interesting_gene_colour_id, aes(label = id), size = input$high.label.size, max.overlaps=50, segment.size=0.2) 
                    }
                  }
                }
                # different colour
                if(input$main_plot_target_genes_2){
                  if(nchar(input$main_plot_target_genes_2_input) > 0){
                    p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$main_plot_target_genes_2_input, split = "\n")),], color=input$main_plot_target_genes_2_colour , size = input$high.pt.size)
                    undetected_genes <- setdiff(unlist(strsplit(input$main_plot_target_genes_2_input, split = "\n")), df_main_plot$id)
                    undetected_genes <- undetected_genes[undetected_genes!= '']
                    if(length(undetected_genes) > 0){
                      output$Scatter_interesting_gene_status2 <- renderText({
                        tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                        genes_tmp <- paste(undetected_genes, collapse=', ')
                        paste0(tmp, genes_tmp)
                      })
                    }else{
                      output$Scatter_interesting_gene_status2 <- renderText({NULL})
                    }
                    if(input$show_label){ 
                      if(input$main_plot_white_back_label){
                        p <- p + geom_label_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$main_plot_target_genes_2_input, split = "\n")),],  color = input$main_plot_target_genes_2_colour, aes(label = id), size = input$high.label.size, max.overlaps=50, segment.size=0.2) 
                      }else{
                        p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$main_plot_target_genes_2_input, split = "\n")),],  color = input$main_plot_target_genes_2_colour, aes(label = id), size = input$high.label.size, max.overlaps=50, segment.size=0.2) 
                      }
                    }
                  }
                }
              }
              tryCatch(
                expr = {
                  res <- brushedPoints(df(), input$plot_brush, xvar = input$scat.x, yvar = input$scat.y)
                  if(length(res$id)<500){
                    if(input$main_plot_white_back_label){
                      p <- p + geom_label_repel(data = res,  color = 'black', aes(label = id), size = input$high.label.size, max.overlaps=60, segment.size=0.2)
                    }else{
                      p <- p + geom_text_repel(data = res,  color = 'black', aes(label = id), size = input$high.label.size, max.overlaps=60, segment.size=0.2)
                    }
                  }
                },
                error = function(e){NULL}
              )
              p <- p + theme(axis.text.y = element_text(size = input$label.font.size), axis.text.x = element_text(size = input$label.font.size))
              p <- p + theme(axis.title.y = element_text(size = input$title.font.size), axis.title.x = element_text(size = input$title.font.size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              if(input$while_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              p
            }, width=reactive(input$fig.width), height=reactive(input$fig.height), res=300)

          # the selected genes' information
            Overview_selected_table <- reactive({
              # req(input$plot_brush)
              if(Dataset()[Dataset()$Dataset == input$Dataset_select, 'Data.Class'] == 'B'){ 
                res <- brushedPoints(df(), input$plot_brush, xvar = input$scat.x, yvar = input$scat.y) 
                if(dim(res)[1] == 0){
                  output$outFile2_status <- renderText({"The selected area in the plot will be shown here."})
                }else{
                  output$outFile2_status <- renderText({NULL})
                }
                return(res)
              }else{
                return(NULL)
              }
            })

          # display the selected genes info as a table
            output$outFile2 <- renderDataTable({
              datatable( Overview_selected_table(), options = list(scrollX = TRUE, pageLength = 10))
            })         

          # download the selected genes' info
            output$selected_download <- downloadHandler(
              filename = function(){"selected_gene_table.tsv"},   
              content = function(fname){ write.table(Overview_selected_table(), fname, sep='\t', quote=F, row.names=F) }
            )

          # show the list of the gene names
            output$selected_gene_list <- renderText({
              if(is.null(Overview_selected_table())){return(NULL)}
              else{
                paste(na.omit(Overview_selected_table()$id), collapse = "\n")
              }
            })

          ## show a bar plot for the filtered genes
            output$Gene_ex_barplot <- renderPlot({
              if( is.null(input$scat.x) || is.null(input$scat.y) ){ 
                output$Gene_ex_barplot_status <- renderText({'Please select a dataset, X and Y.'})
                return(ggplot())
              }else if( input$scat.x == 'None' ||input$scat.y == 'None'){ 
                output$Gene_ex_barplot_status <- renderText({'Please select a dataset, X and Y.'})
                return(ggplot())
              }

              if(input$show_filterin_input_option=='A'){
                output$Gene_ex_barplot_status <- renderText({'Please turn on "Show in a bar plot" in the "Highlight filterd genes or gene sets in the plot" section. \nA bar plot will be generated here.'})  
                return(ggplot())
              }else if(input$show_filterin_input_option=='B'){
                if(input$show_outliers_bar_plot){
                  output$Gene_ex_barplot_status <- renderText({NULL})
                  outliers <- df_outliers()
                }else{
                  output$Gene_ex_barplot_status <- renderText({'Please turn on "Show in a bar plot". \nA bar plot will be generated here.'})  
                  return(ggplot())
                }
              }else if(input$show_filterin_input_option=='C'){
                if(input$show_pathway_bar_plot){
                  output$Gene_ex_barplot_status <- renderText({NULL})
                  outliers <- df_outliers_pathway()
                }else{
                  output$Gene_ex_barplot_status <- renderText({'Please turn on "Show in a bar plot". \nA bar plot will be generated here.'})  
                  return(ggplot())
                }
              }else if(input$show_filterin_input_option=='D'){
                if(input$show_geneset_bar_plot){
                  output$Gene_ex_barplot_status <- renderText({NULL}) 
                  outliers <- df_genes_custom_geneset()
                }else{
                  output$Gene_ex_barplot_status <- renderText({'Please turn on "Show in a bar plot". \nA bar plot will be generated here.'})  
                  return(ggplot())
                }
              }

              if(dim(outliers)[1] == 0){
                output$Gene_ex_barplot_status <- renderText({'Nothing was detected. \nPlease change the input.'})
                return(ggplot())
              }
              output$Gene_ex_barplot_status <- renderText(NULL)
              outliers <- outliers[order(outliers[, input$scat.x], decreasing=T), ]
              outliers[,'id'] <- factor(outliers[,'id'], levels = c(outliers[,'id']))
              fill_option <- input$scat.x

              if(!is.null(input$target_gene) && input$target_gene!= "" ){
                highligh_category <- unlist(strsplit(input$target_gene, split = "\n"))
                outliers <- outliers %>% mutate(fill_colour = ifelse(id %in% highligh_category, input$interesting_gene_colour_id, 'gray'))
                p <- ggplot(outliers, aes(x=id, y=.data[[input$scat.x]], fill=fill_colour)) + scale_fill_identity()
              }else{
                p <- ggplot(outliers, aes(x= id, y=.data[[input$scat.x]], fill=.data[[input$scat.x]]))
                values_for_colours <- outliers[,fill_option][!is.na(outliers[,fill_option])]
                if( min(values_for_colours)<0 ){
                  if( max(values_for_colours)>=0 ){
                    tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                    p <- p + scale_color_gradientn( colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=fill_option)
                    p <- p + scale_fill_gradientn( colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=fill_option)
                  }else{
                    p <- p + scale_color_gradientn( colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=fill_option)
                    p <- p + scale_fill_gradientn( colors = c(input$Gene_ex_barplot_col_min, input$Gene_ex_barplot_col_0), values = scales::rescale(c(min(values_for_colours), 0)  , limits = c(c(min(values_for_colours), 0)) ), name=fill_option)
                  }
                }else{
                  p <- p + scale_color_gradientn( colors = c(input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=fill_option)
                  p <- p + scale_fill_gradientn( colors = c(input$Gene_ex_barplot_col_0, input$Gene_ex_barplot_col_max), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=fill_option)
                }
              }
              if(input$show_outliers_rotate_x){
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
              }
              p <- p + geom_bar(stat='identity') + labs(x = NULL)
              p <- p + theme(legend.text = element_text(size = 4), legend.title = element_text(size = 4) ) + guides(color = guide_colourbar(barwidth = 0.5, barheight = 2)) 
              p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
              p <- p + theme(axis.text.y = element_text(size = input$Gene_ex_barplot_ylab.font.size), axis.text.x = element_text(size = input$Gene_ex_barplot_xlab.font.size))
              p <- p + theme(axis.title.y = element_text(size = input$Gene_ex_barplot_graph.title.font.size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              if(input$Gene_ex_barplot_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p <- p + theme(legend.key.size = unit(0.5, "mm"))
              p
            }, width=reactive(input$Gene_ex_barplot_fig.width), height=reactive(input$Gene_ex_barplot_fig.height), res=300)
          # 

                                          # fluidRow(
                                          #   column(6, sliderInput(inputId = 'Gene_ex_barplot_fig.width', label='fig width', min=300, max=3000, value=500, step=10)),
                                          #   column(6, sliderInput(inputId = 'Gene_ex_barplot_fig.height', label='fig height', min=300, max=3000, value=500, step=10)),
                                          #   column(6, sliderInput(inputId = 'Gene_ex_barplot_xlab.font.size', label='X label size', min=1, max=10, value=4, step=0.1)),
                                          #   column(6, sliderInput(inputId = 'Gene_ex_barplot_ylab.font.size', label='Y label size', min=1, max=10, value=4, step=0.1)),
                                          #   column(6, sliderInput(inputId = 'Gene_ex_barplot_graph.title.font.size', label='Y title size', min=1, max=10, value=4, step=0.1))
                                          # ),
                                          # fluidRow( # colour for max, 0 and min values
                                          #   column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_max', label='Colour for the max value:', value='red')),
                                          #   column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_min', label='Colour for the min value:', value='blue')),
                                          #   column(6, colourpicker::colourInput(inputId = 'Gene_ex_barplot_col_0', label='Colour for the 0 value:', value='white'))
                                          # ),
                                          # fluidRow(
                                          #   # Rotate x axis lable in the bar plot
                                          #   column(6, materialSwitch('show_outliers_rotate_x', 'Rotate x axis lable', value=FALSE, status = "success")),
                                          #   column(6, materialSwitch('Gene_ex_barplot_white_background', 'Use white background', value=FALSE, status = "success"))
                                          # ),

        ###### GO analysis ######
          # Choose the genes used in GO analysis
            GO_analysis_genes <- reactive({
              if(input$GO_input_type == 'A'){
                if(nchar(input$GO_input_geneList) > 0){
                  unlist(strsplit(input$GO_input_geneList, split = "\n"))
                }else{
                  return(NULL)
                }
              }
              else if(input$show_filterin_input_option=='B' & input$GO_input_type == 'B'){df_outliers()$id}
              else if(!is.null(input$plot_brush) & input$GO_input_type == 'C'){brushedPoints(df(), input$plot_brush, xvar = input$scat.x, yvar = input$scat.y)$id}
              else {return(NULL)}
            })

          # Do GO analysis
            output$GO_go_status <- renderText({'Please enter inputs and select other settings, and click "Start GO/KEGG Analysis"'})
            goResult <- reactiveVal({NULL})
            isCalculating <- reactiveVal(FALSE) 
            triggered <- reactiveVal(FALSE)
            observeEvent(input$GO_start, {  
              isCalculating(TRUE)   # 計算中フラグを立てる
              triggered(TRUE) 
              goResult(NULL) 
              if(is.null(GO_analysis_genes()) || length(GO_analysis_genes()) == 0){
                if(input$GO_input_type == 'Use filtered genes'){
                  if(!input$show_filterin_input_option=='B'){
                    show_alert(title='Error.',text='Please filter the genes in the plot first.', type='error')
                    output$GO_go_status <- renderText({'Please filter the genes in the plot first. (Go to "Highlight filterd genes or gene sets in the plot" > "Filtered genes".)'})
                    goResult(NULL)  
                    isCalculating(FALSE)
                    return(NULL) 
                  }
                }else if(input$GO_input_type == 'Text input'){
                  show_alert(title='Error.',text='Please enter genes names.', type='error')
                  output$GO_go_status <- renderText({'Please enter genes names. (Make sure that names are gene symbols and do not contain unnecessary spaces.)'})
                  goResult(NULL)
                  isCalculating(FALSE)
                  return(NULL) 
                }
                show_alert(title='Error.',text='Please input the genes correctly.', type='error')
                output$GO_go_status <- renderText({'Please input the genes correctly.'})
                goResult(NULL)
                isCalculating(FALSE)
                return(NULL) 
              }
              genes <- GO_analysis_genes()
              genes <- genes[genes!='']
              if(length(genes) == 0){
                show_alert(title='Error.',text='Please input the genes correctly.', type='error')
                output$GO_go_status <- renderText({'Please input the genes correctly. \nPlease make sure the gene names are correct and do not contain unnecessary spaces.'})
                goResult(NULL)
                isCalculating(FALSE)
                return(NULL) 
              }
              geneList_ENTREZID <- tryCatch(
                  bitr(genes, fromType="SYMBOL", toType="ENTREZID", OrgDb=ifelse(input$GO_species == "Human", "org.Hs.eg.db", "org.Mm.eg.db"))$ENTREZID,
                  # bitr(c('FCRL1'), fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")$ENTREZID,
                  error=function(e){
                    output$GO_go_status <- renderText({'Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.'})
                    show_alert(title='Error.',text='None of the keys entered are valid keys.\nPlease change the input.', type='error')
                    goResult(NULL)
                    isCalculating(FALSE)
                    return(NULL) 
                  }
                )
              if(is.null(geneList_ENTREZID)==TRUE){
                show_alert(title='Error.',text='None of the keys entered are valid keys.\nPlease change the input.', type='error')
                output$GO_go_status <- renderText({'Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.'})
                goResult(NULL)
                isCalculating(FALSE)
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
                  show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                  output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                  goResult(NULL)
                  isCalculating(FALSE)
                  return(NULL) 
                }else{
                  goResult(out)
                  isCalculating(FALSE)
                  return(NULL) 
                }
              }else if(input$GO_database == 'KEGG'){
                if(input$GO_species == 'Human'){
                  kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'hsa', pvalueCutoff = 1, qvalueCutoff = 1)
                  if(is.null(kk_ORA)){
                    show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                    output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                    isCalculating(FALSE)
                    return(NULL)
                  }else{
                    output$GO_go_status <- renderText({NULL})
                    kk_ORA <- setReadable(kk_ORA, 'org.Hs.eg.db', 'ENTREZID')
                    goResult(kk_ORA)
                  }
                }else if(input$GO_species == 'Mouse'){
                  kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'mmu', pvalueCutoff = 1, qvalueCutoff = 1)
                  if(is.null(kk_ORA)){
                    show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                    output$GO_go_status <- renderText({'No significant GO/KEGG term was detected. Please change (or increase) the input.'})
                    return(NULL)
                    return(NULL) 
                  }else{
                    output$GO_go_status <- renderText({NULL})
                    kk_ORA <- setReadable(kk_ORA, 'org.Mm.eg.db', 'ENTREZID')
                    goResult(kk_ORA)
                    isCalculating(FALSE)
                    return(NULL)
                  }
                }
              }else{
                show_alert(title='Error.',text='Please select the database correctly..', type='error')
                output$GO_go_status <- renderText({'Please select the database (and the ontology) correctly.'})
                goResult(NULL)
                isCalculating(FALSE)
                return(NULL) 
              }
              isCalculating(FALSE)
            })  



          # output$GO_go_status <- renderText({NULL})
            outputOptions(output, "GO_go_status", suspendWhenHidden=FALSE)

          ## Plots and display the table ##
            output$GO_goTable_status <- renderText({"The results table of GO/KEGG analysis will be shown here."})
            output$GO_goPlot_status <- renderText({"A Bar plot of the GO/KEGG analysis results will be shown here."})
            output$GO_goBubblePlot_status <- renderText({"A Bubble plot of the GO/KEGG analysis results will be shown here."})
            output$GO_netPlot_status_status <- renderText({"A network plot of the top 5 terms from the GO/KEGG analysis results will be shown here."})
            outputOptions(output, "GO_goTable_status", suspendWhenHidden=FALSE)
            outputOptions(output, "GO_goPlot_status", suspendWhenHidden=FALSE) 
            outputOptions(output, "GO_goBubblePlot_status", suspendWhenHidden=FALSE) 
            outputOptions(output, "GO_netPlot_status_status", suspendWhenHidden=FALSE) 

          # Goplot 
            output$GO_goPlot <- renderPlot({
              if (!triggered()) {
                return(ggplot())
              }else if (isCalculating()) {
                return(ggplot())
              }else{
                if(is.null(goResult())){
                  output$GO_goPlot_status <- renderText({"A Bar plot of the GO/KEGG analysis results will be shown here."})
                  return(ggplot())
                }
                else{
                  output$GO_goPlot_status <- renderText({NULL})
                  # use ggplot, not enrichplot:barplot
                  df_goResults <- as.data.frame(goResult())
                  showCategory <- input$GO_fig.category_show_number 
                  df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                  df_goResults$Description <- str_wrap(df_goResults$Description, width=50)

                  # Create barplot with custom colors
                  p <- ggplot(df_goResults, aes(x = Count, y = reorder(Description, Count), fill = p.adjust)) + geom_bar(stat = "identity") + labs(x = "Count", y = NULL, fill = "P.adjust")
                  p <- p + theme(axis.text.y = element_text(size = input$GO_ylab.font.size), axis.text.x = element_text(size = input$GO_xlab.font.size), axis.title.x = element_text(size=input$GO_xtitle.font.size))
                  p <- p + theme(legend.text = element_text(size = input$GO_legend.size), legend.title = element_text(size = input$GO_legend.size) )
                  p <- p + theme(legend.key.size = unit(1.5, "mm"))
                  p <- p + scale_fill_gradient(low = input$GO_bar_colour_min, high = input$GO_bar_colour_max)
                  p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                  p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
                  # white background
                  if(input$GO_bar_white_background){
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                  }
                  p
                }
              }
            }, width=reactive(input$GO_fig.width), height=reactive(input$GO_fig.height), res=300)
          
          # GoBubblePlot;
            output$GO_goBubblePlot <- renderPlot({
              if (!triggered()) {
                return(ggplot())
              }else if (isCalculating()) {
                return(ggplot())
              }else{
                if(is.null(goResult())){
                  output$GO_goBubblePlot_status <- renderText({"A Bubble plot of the GO/KEGG analysis results will be shown here."})
                  return(ggplot())
                }
                else{ 
                  output$GO_goBubblePlot_status <- renderText({NULL})
                  df_goResults <- as.data.frame(goResult())
                  showCategory <- input$GO_Bubble_fig.category_show_number 
                  df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                  df_goResults$GeneRatio <- sapply(df_goResults$GeneRatio, function(x) {
                    parts <- strsplit(x, "/")[[1]]
                    as.numeric(parts[1]) / as.numeric(parts[2])
                  })
                  df_goResults$Description <- str_wrap(df_goResults$Description, width=50)
                                                  
                  p <- ggplot(df_goResults, aes(x = GeneRatio, y = reorder(Description, Count), size =Count , color = p.adjust)) + geom_point() +  labs(x = "GeneRatio", y = NULL, color = "P.adjust", size = "Count")
                  p <- p + theme(axis.text.y = element_text(size = input$GO_Bubble_ylab.font.size), axis.text.x = element_text(size = input$GO_Bubble_xlab.font.size), axis.title.x = element_text(size=input$GO_Bubble_xtitle.font.size))
                  p <- p + theme(legend.text = element_text(size = input$GO_Bubble_legend.size), legend.title = element_text(size = input$GO_Bubble_legend.size) )
                  p <- p + theme(legend.key.size = unit(1.5, "mm"))
                  p <- p + scale_color_gradient(low = input$GO_Bubble_colour_min, high = input$GO_Bubble_colour_max) 
                  p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                  p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(1, "pt"))
                  # white background
                  if(input$GO_Bubble_white_background){
                    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                    p <- p + theme(panel.background = element_rect(fill="white", size=0))
                    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                  }
                  p
                }
              }
            }, width=reactive(input$GO_Bubble_fig.width), height=reactive(input$GO_Bubble_fig.height), res=300)
            
          # Show the table
            output$GO_goTable <- DT::renderDataTable({
              if (!triggered()) {
                tmp <- data.frame(Category = character(0), Generatio = character(0), pvalue = numeric(0), pvalue.adjust = numeric(0), Count = numeric(0))
                return(datatable(tmp) )
              }else if (isCalculating()) {
                tmp <- data.frame(Category = character(0), Generatio = character(0), pvalue = numeric(0), pvalue.adjust = numeric(0), Count = numeric(0))
                return(datatable(tmp) )
              }else{
                if(is.null(goResult())){ 
                  output$GO_goTable_status <- renderText({"The results table of GO/KEGG analysis will be shown here."})
                  tmp <- data.frame(Category = character(0), Generatio = character(0), pvalue = numeric(0), pvalue.adjust = numeric(0), Count = numeric(0))
                  return(datatable(tmp))
                }
                else{ 
                  output$GO_goTable_status <- renderText({NULL})
                  return(datatable(as.data.frame(goResult()), option=list(scrollX=TRUE, pageLength = 10, scrollY=TRUE )) )
                }
              }
            })
            outputOptions(output, "GO_goTable", suspendWhenHidden=FALSE) 
          
          # table download button
            output$GO_goTable_download <- downloadHandler(
              filename = function(){"GO_table_results.csv"}, 
              content = function(fname){ write.csv(as.data.frame(goResult()), fname) }
            )
          
          # network plot
            output$GO_netPlot <- renderPlot({
              if (!triggered()) {
                return(ggplot())
              }else if (isCalculating()) {
                return(ggplot())
              }else{
                if(is.null(goResult())){ 
                  output$GO_netPlot_status_status <- renderText({"A network plot of the top 5 terms from the GO/KEGG analysis results will be shown here."})
                  return(ggplot())
                }
                else{ 
                  output$GO_netPlot_status_status <- renderText({NULL})
                  df_goResults <- as.data.frame(goResult())
                  showCategory <- input$GO_netPlot_category_show_number 
                  df_goResults <- df_goResults[order(df_goResults$p.adjust), ][1:showCategory, ]  # Select top categories based on p.adjust
                  gene_list <- strsplit(df_goResults$geneID, "/")  # Split gene lists
                  edge_df <- data.frame(
                    GO_Term = rep(df_goResults$Description, sapply(gene_list, length)),  # Repeat GO terms correctly
                    Gene = unlist(gene_list)  # Flatten list into a single column
                  )
                  df_goResults$Description <- str_wrap(df_goResults$Description, width=50)

                  # Generate igraph object
                  graph <- graph_from_data_frame(edge_df, directed = FALSE)
                  node_type <- ifelse(V(graph)$name %in% df_goResults$Description, "GO Term", "Gene")
                  E(graph)$GO_Term <- edge_df$GO_Term  # Assign GO term category to edges
                  node_size <- ifelse(V(graph)$name %in% df_goResults$Description, input$GO_netPlot_node_size_term, input$GO_netPlot_node_size_gene)  # GO terms larger than genes

                  if(input$GO_netPlot_circle_plot){
                    p <- ggraph(graph, layout = "circle")
                  }else{
                    p <- ggraph(graph, layout = "fr")  # Fruchterman-Reingold layout
                  }
                  if(input$GO_netPlot_change_edge_colour){
                    p <- p + geom_edge_link(aes(color = GO_Term), alpha = 0.6, linewidth = input$GO_netPlot_edge_size_term)  
                  }else{
                    p <- p + geom_edge_link(alpha = 0.6, linewidth = input$GO_netPlot_edge_size_term)
                  }
                  p <- p + scale_edge_color_manual(values = setNames(rainbow(length(unique(edge_df$GO_Term))), unique(edge_df$GO_Term)))
                  p <- p + geom_node_point(aes(size = node_size, color = node_type)) 
                  p <- p + scale_color_manual(values = c("GO Term" = input$GO_netPlot_node_colour_term, "Gene" = input$GO_netPlot_node_colour_gene))
                  p <- p + scale_size_continuous(range = c(input$GO_netPlot_node_size_gene, input$GO_netPlot_node_size_term)) 
                  if(input$GO_netPlot_label_size_term_term > 0){
                    p <- p + geom_node_text(
                      data = function(x) dplyr::filter(x, node_type == "GO Term"),
                      aes(label = name), color = input$GO_netPlot_node_colour_term, size = input$GO_netPlot_label_size_term_term,
                      repel = TRUE, max.overlaps = Inf, segment.size = 0.2
                    )
                  }
                  if(input$GO_netPlot_label_size_term_gene > 0){
                    p <- p + geom_node_text(
                      data = function(x) dplyr::filter(x, node_type == "Gene"),
                      aes(label = name), color = input$GO_netPlot_node_colour_gene, size = input$GO_netPlot_label_size_term_gene,
                      repel = TRUE, segment.size = 0.2, max.overlaps = 5
                    )
                  }
                  p <- p + guides(color = "none")
                  p <- p + theme(legend.key.size = unit(0.5, "mm"))
                  p <- p + theme(legend.text = element_text(size = input$GO_netPlot_legend.size), legend.title = element_text(size = input$GO_netPlot_legend.size) )
                  p <- p + theme(panel.background = element_rect(fill="white", size=0))
                  p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                  p
                }
              }
            }, width=reactive(input$GO_netPlot_fig.width), height=reactive(input$GO_netPlot_fig.height), res=300)

            outputOptions(output, "GO_goPlot", suspendWhenHidden=FALSE)
            outputOptions(output, "GO_goBubblePlot", suspendWhenHidden=FALSE) 
            outputOptions(output, "GO_goTable", suspendWhenHidden=FALSE) 
            outputOptions(output, "GO_netPlot", suspendWhenHidden=FALSE) 

          # 

        ###### GSEA analysis ######
          # select gene set
            output$GSEA_goTable_status <- renderText({'Please select the input and click "Start GSEA Analysis".'})
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
            outputOptions(output, "GSEA_pathway_dataset_select_one_geneset_select_from_custom_set", suspendWhenHidden=FALSE)

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

          # defalut status message
            output$GSEA_status <- renderText({NULL})
            output$GSEA_plot_status <- renderText({NULL})
            output$GSEA_analysis_status <- renderText({NULL})
            outputOptions(output, "GSEA_status", suspendWhenHidden=FALSE)
            outputOptions(output, "GSEA_plot_status", suspendWhenHidden=FALSE) 
            outputOptions(output, "GSEA_analysis_status", suspendWhenHidden=FALSE) 

          # main part of GSEA calculation
            GSEA_results <- reactiveVal(NULL)
            GSEA_Gene_set_after_start <- reactiveVal(NULL)
            observeEvent(input$GSEA_start, {
              GSEA_Gene_set_after_start(GSEA_Gene_set())
              # when the ranking score is not selected
              if(input$GSEA_select_score=='None'){
                show_alert(title='Error.',text='Please choose the score for the analysis.', type='error')
                output$GSEA_analysis_status <- renderText({'Please choose the score for the analysis'})
                output$GSEA_goTable_status <- renderText({'Error. Please check the input'})
                GSEA_results(NULL)
                return(NULL)
              }
              # when the ranking score is not numeric
              ranked_genes <- df()[,input$GSEA_select_score]
              if(!is.numeric(ranked_genes)){
                show_alert(title='Error.',text=' Please check the input.', type='error')
                output$GSEA_analysis_status <- renderText({'The selected score is not numeric, and cannot be used for the GSEA analysis. Please choose another.'})
                output$GSEA_goTable_status <- renderText({'Error. Please check the input'})
                GSEA_results(NULL)
                return(NULL)
              }
              output$GSEA_analysis_status <- renderText({NULL})
              output$GSEA_goTable_status <- renderText({NULL})
              names(ranked_genes) <- df()$id
              # output$GSEA_status <- renderText({ 'AAA' })
              if(is.null(GSEA_Gene_set())){
                GSEA_results(NULL)
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
                show_alert(title='Error.',text='Please check the input.', type='error')
                output$GSEA_goTable_status <- renderText({'Error. Please check the input'})
                GSEA_results(NULL)
                return(NULL)
              }
              fgseaRes2 <- data.frame(fgseaRes2[order(pval), ])
              # output$GSEA_plot_status_tmp <- renderText({dim(fgseaRes2)})
              fgseaRes2 <- fgseaRes2[c('pathway', 'pval', 'padj', 'log2err', 'ES', 'NES', 'size')]
              fgseaRes2$GSEA_select_score <- input$GSEA_select_score
              GSEA_results(fgseaRes2)
              fgseaRes2
            })


          # dispaly the table
            output$GSEA_goTable <- DT::renderDataTable({
              if(is.null(GSEA_results())){ 
                tmp <- as.data.frame(list('pathway'=character(0), 'pval'=character(0), 'ES'=character(0), 'NES'=character(0), 'size'=character(0), 'log2err'=character(0), 'padj'=character(0)))
                datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
              }else{ 
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
                return(ggplot())
              }else{
                if(length(input$GSEA_goTable_rows_selected) == 0){
                  output$GSEA_plot_status <- renderText({'Please select the pathway (row) from the GSEA results table'})
                  output$GSEA_status <- renderText({NULL})
                  return(ggplot())
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
                p$layers[[1]]$aes_params$colour <- input$GSEA_graph_line_colour
                p$layers[[3]]$aes_params$colour <- input$GSEA_graph_maxmin_line_colour
                p$layers[[4]]$aes_params$colour <- input$GSEA_graph_maxmin_line_colour
                p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p
              }
            }, width=reactive(input$GSEA_fig.width), height=reactive(input$GSEA_fig.height),res=300)
            outputOptions(output, "GSEA_plot", suspendWhenHidden=FALSE)
          #


        ###### TF activity inference (DecoupleR) ######
          output$DecoupeR_plot_status <- renderText({NULL})
          output$DecoupeR_plot_status2 <- renderText({'Please click "Start DecoupleR Analysis". \nA bar plot showing the activity level of transcription factors will be shown here.'})
          output$DecoupeR_Table_status <- renderText({'The result of the DecoupleR analysis (the activity level of transcription factors) will be shown here.'})
          outputOptions(output, "DecoupeR_plot_status", suspendWhenHidden=FALSE)
          outputOptions(output, "DecoupeR_plot_status2", suspendWhenHidden=FALSE)
          outputOptions(output, "DecoupeR_Table_status", suspendWhenHidden=FALSE)

          # Run decoupeR
            DecoupeR_TF_table_all <- reactiveVal(NULL)
            isCalculating_DecoupeR <- reactiveVal(FALSE)
            Triggered_DecoupeR <- reactiveVal(FALSE)
            observeEvent(input$DecoupeR_start, {
              isCalculating_DecoupeR(TRUE)   # 計算中フラグを立てる
              Triggered_DecoupeR(TRUE)
              df_LFC <- df()
              rownames(df_LFC) <- df_LFC$id
              if(!'stat' %in% colnames(df_LFC)){
                output$DecoupeR_plot_status <- renderText({'The input data is not the RANseq DEG data processed by DESeq2, and cannot applicable to this function.'})
                output$DecoupeR_plot_status2 <- renderText({NULL})
                DecoupeR_TF_table_all(NULL)
                isCalculating_DecoupeR(FALSE)
                return()
              }
              output$DecoupeR_plot_status2 <- renderText({NULL})
              contrast_acts <- run_ulm(mat=df_LFC[, 'stat', drop=FALSE], net=net, .source='source', .target='target', .mor='mor', minsize = 5)
              
              DecoupeR_TF_table_all(contrast_acts)
              isCalculating_DecoupeR(FALSE)
              return()
            })

          # output table
            DecoupeR_TF_table <- reactive({
                if(is.null(DecoupeR_TF_table_all())){
                  return(NULL)
                }else{
                  f_contrast_acts <- DecoupeR_TF_table_all() %>% mutate(rnk = NA)
                  msk <- f_contrast_acts$score > 0
                  f_contrast_acts[msk, 'rnk'] <- rank(-f_contrast_acts[msk, 'score'])
                  f_contrast_acts[!msk, 'rnk'] <- rank(-abs(f_contrast_acts[!msk, 'score']))
                  tfs <- f_contrast_acts %>% arrange(rnk) %>% head(input$DecoupeR_TF_number) %>% pull(source)
                  f_contrast_acts <- f_contrast_acts %>% filter(source %in% tfs)
                  return(f_contrast_acts)
                }
              })

          # table display
            output$DecoupeR_Table <- DT::renderDataTable({
              if (!Triggered_DecoupeR()) {
                output$DecoupeR_Table_status <- renderText({'The result of the DecoupleR analysis (the activity level of transcription factors) will be shown here.'})
                tmp <- as.data.frame(list('statistic'=character(0), 'source'=character(0), 'condition'=character(0), 'score'=character(0), 'p.value'=character(0)))
                datatable(tmp,  options = list(scrollX = TRUE, pageLength = 10))
              }else if(isCalculating_DecoupeR()) {
                output$DecoupeR_Table_status <- renderText({'The result of the DecoupleR analysis (the activity level of transcription factors) will be shown here.'})
                tmp <- as.data.frame(list('statistic'=character(0), 'source'=character(0), 'condition'=character(0), 'score'=character(0), 'p.value'=character(0)))
                datatable(tmp,  options = list(scrollX = TRUE, pageLength = 10))
              }else if(is.null(DecoupeR_TF_table_all())){ 
                output$DecoupeR_Table_status <- renderText({'The result of the DecoupleR analysis (the activity level of transcription factors) will be shown here.'})
                tmp <- as.data.frame(list('statistic'=character(0), 'source'=character(0), 'condition'=character(0), 'score'=character(0), 'p.value'=character(0)))
                datatable(tmp,  options = list(scrollX = TRUE, pageLength = 10))
              }else{ 
                output$DecoupeR_Table_status <- renderText({NULL})
                datatable(DecoupeR_TF_table_all(), options = list(scrollX = TRUE)) 
              }
            })
            outputOptions(output, "DecoupeR_Table", suspendWhenHidden=FALSE)

          # download the table
            output$DecoupeR_Table_download <- downloadHandler(
            filename = function(){"decoupleR.tsv"}, 
            content = function(fname){ write.table(DecoupeR_TF_table_all(), fname, sep='\t', row.names=F, quote=F) }
            )

          # plot DecoupeR results
            output$DecoupeR_plot <- renderPlot({
              if (!Triggered_DecoupeR()) {
                return(ggplot())
              }else if(isCalculating_DecoupeR()) {
                return(ggplot())
              }else if(is.null(DecoupeR_TF_table())){
                return(ggplot())
              }else{
                p <- ggplot(DecoupeR_TF_table(), aes(x = reorder(source, score), y = score)) + geom_bar(aes(fill = score), stat = "identity")
                p <- p + scale_fill_gradient2(low = input$DecoupeR_colour_low, high = input$DecoupeR_colour_high, mid = input$DecoupeR_colour_mid, midpoint = 0)
                p <- p + theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust = 1)) + xlab("TFs")
                p <- p + theme(axis.text=element_text(size=input$DecoupeR_lab.font.size), axis.title=element_text(size=input$DecoupeR_title.font.size))
                p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p <- p + theme(legend.text = element_text(size = input$DecoupeR_legend.size), legend.title = element_text(size = input$DecoupeR_legend.size) )
                p <- p + theme(legend.key.size = unit(1, "mm"))
                p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                if(input$DecoupeR_white_background){
                  p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                  p <- p + theme(panel.background = element_rect(fill="white", size=0))
                  p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                }
                p
              }
            }, width=reactive(input$DecoupeR_fig.width), height=reactive(input$DecoupeR_fig.height),res=300)
            outputOptions(output, "DecoupeR_plot", suspendWhenHidden=FALSE)
          #

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
            outputOptions(output, "Data_Overview_heatmap_target_select_geneset", suspendWhenHidden=FALSE)

            genes_for_heatmap <- reactive({
              if(length(input$Data_Overview_heatmap_target_gene_type)==0){
                output$Data_Overview_heatmap_target_gene_type_status <- renderText({"Please select one from 'Gene from'"})
                return(NULL)
              }
              output$Data_Overview_heatmap_target_gene_type_status <- renderText({NULL})
              if(input$Data_Overview_heatmap_target_gene_type == 'A'){
                if(nchar(input$Data_Overview_heatmap_target_genes) == 0){
                  return(NULL)
                }else{
                  unlist(strsplit(input$Data_Overview_heatmap_target_genes, split = "\n"))
                }
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
              datatable( Data_Overview_heatmap_sample_table_tmp(), selection='none', extensions=c('Select', 'Buttons', 'Scroller'), rownames=F,
                options = list(
                  select=list(style="multi", items='row'),
                  scroller=TRUE, deferRender=TRUE, scrollY=200,
                  dom='Blfrtip', buttons=c('selectAll', 'selectNone'), pageLength = 5)) 
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

          # default status
            output$Data_Overview_heatmap_status <- renderText('Please enter/choose inputs and select the samples, and click "Generate a heatmap"\nA heatmap showing the standardised expression of the selected genes across the selected samples will be generated here.')
            output$Data_Overview_heatmap_expression_status <- renderText('Please generate a heatmap first. A table of the scores using the heatmap will be shown here.')

          # heatmap table
            ex_datafreme_for_heatmap <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE) 
            triggered <- reactiveVal(FALSE)
            observeEvent(input$Gene_Overview_heatmap_start, {
              isCalculating(TRUE)   
              triggered(TRUE) 
              if(is.null(genes_for_heatmap())){
                show_alert(title='Error.',text='Please enter/choose input genes.', type='error')
                output$Data_Overview_heatmap_status <- renderText('Please enter/choose input genes.')
                output$Data_Overview_heatmap_expression_status <- renderText('Please generate a heatmap first. A table of the scores using the heatmap will be shown here.')
                ex_datafreme_for_heatmap(NULL)
                isCalculating(FALSE)   
                return()
              }else{
                output$Data_Overview_heatmap_status <- NULL
                output$Data_Overview_heatmap_expression_status <- NULL
                df_ex <- df()
                # extract the target genes
                if(length(df_ex$id[df_ex$id %in% genes_for_heatmap()]) == 0){
                  show_alert(title='Error.',text='None of the inputted genes are in the data.', type='error')
                  output$Data_Overview_heatmap_status <- renderText('None of the inputted genes are in the data.')
                  output$Data_Overview_heatmap_expression_status <- renderText('Error. Please check the input')
                  ex_datafreme_for_heatmap(NULL)
                  isCalculating(FALSE)   
                  return()
                }else{
                  df_ex <- df_ex[df_ex$id %in% genes_for_heatmap(),] 
                  rownames(df_ex) <- df_ex$id
                  df_ex <- df_ex[,2:dim(df_ex)[2]] ## select which samples are included
                  selected_samples <- Data_Overview_heatmap_sample_table_tmp()[input$Data_Overview_heatmap_sample_table_rows_selected,]
                  if(length(selected_samples)<=1){
                    show_alert(title='Error.',text='Please select at least two samples.', type='error')
                    output$Data_Overview_heatmap_status <- renderText("Please select at least two samples.")
                    output$Data_Overview_heatmap_expression_status <- renderText('Error. Please check the input')
                    ex_datafreme_for_heatmap(NULL)
                  }else{
                    df_ex <- df_ex[,selected_samples]
                    df_ex <- data.frame(t(df_ex))
                    # standardise
                    df_ex <- sd_table(df_ex)
                    df_ex <- df_ex %>% select_if(~ !any(is.na(.)))
                    ex_datafreme_for_heatmap(df_ex)
                    isCalculating(FALSE)   
                    return()
                  }
                }
              }
            })

          # heatmap plot
            clustered_heatmap_ex <- reactiveVal(NULL)
            output$Data_Overview_heatmap_plot <- renderPlot({
              if(!is.null(ex_datafreme_for_heatmap())){
                df_ex <- ex_datafreme_for_heatmap()

                # clustering
                set.seed(123)
                if(input$Cluster_num > length(genes_for_heatmap())){
                  output$Data_Overview_heatmap_status <- renderText('The cluster number exceeds the number of genes. Please chosse a lower cluster number.')
                  output$Data_Overview_heatmap_expression_status <- renderText('Error. Please check the input')
                  return(ggplot())
                }
                km <- kmeans(t(df_ex), centers = input$Cluster_num, nstart = 25)
                clusters <- as.data.frame(km$cluster)
                colnames(clusters) <- "Cluster"
                # combine the cluster number and the expression table
                gene_expression_matrix <- as.data.frame(t(df_ex))
                gene_expression_matrix$Cluster <- clusters$Cluster
                new_colnames <- c('Cluster', colnames(gene_expression_matrix)[1:dim(gene_expression_matrix)[2]-1])
                gene_expression_matrix <- gene_expression_matrix[,new_colnames]
                clustered_heatmap_ex(gene_expression_matrix)
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
                p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p <- p + theme(legend.text = element_text(size = input$Data_Overview_heatmap_legend.size), legend.title = element_text(size = input$Data_Overview_heatmap_legend.size) )
                p <- p + theme(legend.key.size = unit(1.5, "mm"))
                p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
                p
              }else{
                p <- ggplot()
                p
              }
            }, width=reactive(input$Data_Overview_heatmap_fig.width), height=reactive(input$Data_Overview_heatmap_fig.height), res=300)

          # display the standardised table
            output$Data_Overview_heatmap_expression <- DT::renderDataTable({
              if(is.null(clustered_heatmap_ex())){ 
                data.frame() 
              }else{ 
                output$Data_Overview_heatmap_expression_status <- renderText(NULL)
                datatable(clustered_heatmap_ex(), options = list(scrollX = TRUE)) 
              }
            })

          # Download the standardised table
            output$Data_Overview_heatmap_expression_download <- downloadHandler(
              filename = function(){"Heatmap_expression_tablle.tsv"}, 
              content = function(fname){ write.table(clustered_heatmap_ex(), fname, sep='\t', quote=F) }
            )

          # select the cluster to show the gene names
            output$Data_Overview_heatmap_expression_cluster_select <- renderUI({
              if(is.null(clustered_heatmap_ex())){
                return(NULL)
              }
              clusters <- sort(unique(clustered_heatmap_ex()$Cluster))
              selectInput('Data_Overview_heatmap_expression_cluster_select', 'Select the cluster number',  c('None'='None', clusters))  
            })
            outputOptions(output, "Data_Overview_heatmap_expression_cluster_select", suspendWhenHidden=FALSE)

          # show the list of gene names
            output$Data_Overview_heatmap_expression_cluster_genename <- renderText({
              if(is.null(clustered_heatmap_ex())){
                return(NULL)
              }
              if(input$Data_Overview_heatmap_expression_cluster_select == 'None'){
                return(NULL)
              }
              ex_datafreme_for_heatmap_cluster <- clustered_heatmap_ex()[clustered_heatmap_ex()$Cluster == input$Data_Overview_heatmap_expression_cluster_select, ]
              paste(rownames(ex_datafreme_for_heatmap_cluster), collapse = "\n")
            })
          #

        ###### PCA plot ######
          # calculate PCA
            output$Data_Overview_PCA_status <- renderText({"Please go to the Settings on the right and click 'Generate a PCA plot'."})
            PCA_table <- reactiveVal(NULL)
            observeEvent(input$Data_Overview_PCA_Start, {
              output$Data_Overview_PCA_status <- renderText({NULL})
              df_ex <- df()
              # df_ex <- read.table('/home/h023o/ShinyApps/in_house_screening/00_Expression_data_all/Helena/Human_T_cell_activation_Vora/all_cnt_FeatureCounts_cpm_gene.tsv', sep='\t', header=T)
              rownames(df_ex) <- df_ex$id
              df_ex <- df_ex[,2:dim(df_ex)[2]] # df_ex[1:3, 1:3]
              df_ex[is.na(df_ex)] <- 0
              if(input$Data_Overview_PCA_Setting=='B'){
                if(nchar(input$Data_Overview_PCA_Setting_group_define)==0){
                  show_alert(title='Error.',text='Please enter the group description.', type='error')
                  output$Data_Overview_PCA_status <- renderText({"Please fill in the 'Enter the group descriptions' box."})
                  PCA_table(NULL)
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
                  show_alert(title='Error.',text='There are duplicated sample names.', type='error')
                  output$Data_Overview_PCA_status <- renderText({"There are duplicated sample names."})
                  PCA_table(NULL)
                  return(NULL)
                }
                output$Data_Overview_PCA_plot_tmp <- renderDataTable({
                  datatable(df_sample_group)
                })
                samples <- df_sample_group$Sample
                samples_intersect <- intersect(samples, colnames(df_ex)) # colnames(df_ex)[1:3, 1:3]
                if(length(samples_intersect)==0){
                  show_alert(title='Error.',text='Please set the group description correctly.', type='error')
                  output$Data_Overview_PCA_status <- renderText({"Non of the inputted sample names are in the dataset. \nPlease check the sample names are correct and do not contain unnecessary spaces."})
                  PCA_table(NULL)
                  return()
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
              PCA_table(pca_df)
            })

          # show the PCA plot
            output$Data_Overview_PCA_plot <- renderPlot({
              pca_df <- PCA_table()
              if(is.null(pca_df)){
                return(ggplot())
              }
              if(input$Data_Overview_PCA_change_colour_by_group){
                p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample, color=Group)) + geom_point(size=input$Data_Overview_PCA_point_size) 
                p <- p + theme(legend.text = element_text(size=input$Data_Overview_PCA_legend_size), legend.title=element_blank())
              }else{
                p <- ggplot(pca_df, aes(x=PC1, y=PC2, label=sample)) + geom_point(size=input$Data_Overview_PCA_point_size) 
              }
              if(!input$Data_Overview_PCA_label_hide){
                p <- p + geom_text_repel(data = pca_df,  color = 'black', aes(label = sample), size = input$Data_Overview_PCA_label_size, max.overlaps = Inf, segment.size=0.2)
              }
              p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
              p <- p + theme(axis.text = element_text(size = input$Data_Overview_PCA_xy.font.size), axis.title = element_text(size = input$Data_Overview_PCA_xy.title.size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              p <- p + theme(legend.key.size = unit(2, "mm"))
              if(input$Data_Overview_PCA_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }, width=reactive(input$Data_Overview_PCA_fig.width), height = reactive(input$Data_Overview_PCA_fig.height), res=300)
        
          # Sample name list
            output$Data_Overview_PCA_Sample_list <- renderText({
              df_ex <- df()
              samples <- colnames(df_ex)[2:dim(df_ex)[2]]
              samples <- samples[order(samples)]
              paste(unlist(samples), collapse='\n')
            })
          # 

        ###### two genes correlation #######    
          # when exploring correlation
            df_Two_gene_corr_inputB <- reactiveVal({NULL})
            df_Two_gene_corr_inputB_gene1 <- reactiveVal({NULL})
            observeEvent(input$Two_gene_corr_start,{ #df_Two_gene_corr_inputB <- 
              if(input$Two_gene_corr_corr_Input == 'B'){
                ## set up the gene1
                gene1 <- input$Two_gene_corr_gene1
                if(gene1 == ''){
                  output$Two_gene_corr_corr_score <- renderText({NULL})
                  show_alert(title='Error.',text='Please enter Gene1 first.', type='error')
                  output$Two_gene_corr_statusB <- renderText({"Please enter Gene1 first."}) 
                  df_Two_gene_corr_inputB(NULL)
                  return(NULL)
                }else if(!gene1 %in% df()$id){
                  output$Two_gene_corr_corr_score <- renderText({NULL})
                  show_alert(title='Error.',text='Gene1 not found in the dataset.', type='error')
                  output$Two_gene_corr_statusB <- renderText({paste0("Gene1: '", gene1, "' not found in the dataset.")}) 
                  df_Two_gene_corr_inputB(NULL)
                  return(NULL)
                }
                gene1_score <- as.numeric(df()[df()$id == gene1,-which(colnames(df()) == 'id')])
                ## set up the gene2
                if(input$Two_gene_corr_gene2_list_Input == 'A'){
                  if(nchar(input$Two_gene_corr_gene2_list) == 0){
                    output$Two_gene_corr_corr_score <- renderText({NULL})
                    show_alert(title='Error.',text='Please enter Gene2s.', type='error')
                    output$Two_gene_corr_statusB <- renderText({"Please enter Gene2s (line by line)."}) 
                    df_Two_gene_corr_inputB(NULL)
                    return(NULL)
                  }
                  gene2s <- unlist(strsplit(input$Two_gene_corr_gene2_list, split = "\n"))
                }else if(input$Two_gene_corr_gene2_list_Input == 'B'){
                  if(input$Two_gene_corr_gene2_Input_from_custom_geneset_select == 'None'){
                    show_alert(title='Error.',text='Please select a custom gene set.', type='error')
                    output$Two_gene_corr_statusB <- renderText({"Please select a custom gene set."}) 
                    return(NULL)
                  }
                  gene2s <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Two_gene_corr_gene2_Input_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                }
                gene2_not_in_data <- c() # gene2_not_in_data <- c('hoge', 'fuga')
                df_out <- data.frame(Gene=c(), Correlation=c(), Pvalue=c(), log=c())
                for (gene2 in gene2s){
                  if(!gene2 %in% df()$id){
                    gene2_not_in_data <- c(gene2_not_in_data, gene2)
                  }else{
                    gene2_score <- as.numeric(df()[df()$id == gene2,-which(colnames(df()) == 'id')])
                    if(input$Two_gene_corr_log){
                      cor_res <- cor.test(log2(gene1_score + 1), log2(gene2_score+1), method=input$Two_gene_corr_corr_method)  
                    }else{
                      cor_res <- cor.test(gene1_score, gene2_score, method=input$Two_gene_corr_corr_method)
                    }
                    r <- cor_res$estimate; pval <- cor_res$p.value
                    df_tmp <- data.frame(Gene=c(gene2), Correlation=c(r), Pvalue=c(pval))
                    if(input$Two_gene_corr_log){
                      df_tmp$log <- 1
                    }else{
                      df_tmp$log <- 0
                    }
                    df_Two_gene_corr_inputB_gene1(gene1)
                    df_out <- rbind(df_out, df_tmp)
                  }
                }
                if(length(gene2_not_in_data) > 0){
                  output$Two_gene_corr_statusB <- renderText({paste0("Gene2: The following genes are not in the dataset \n", paste(gene2_not_in_data, collapse=','))}) 
                }
                df_out <- df_out[order(df_out$Pvalue),]
                rownames(df_out) <- NULL
                df_Two_gene_corr_inputB(df_out)
                return(NULL)
              }else{
                df_Two_gene_corr_inputB(NULL)
                return(NULL)
              }
            })


          # specify gene1 and gene2 (typeA)
            df_Two_gene_corr <- reactive({
              if(input$Two_gene_corr_corr_Input == 'A'){
                output$Two_gene_corr_statusB <- renderText({NULL}) 
                gene1 <- input$Two_gene_corr_gene1
                gene2 <- input$Two_gene_corr_gene2
                # when no input
                if(nchar(input$Two_gene_corr_gene1) == 0 | nchar(input$Two_gene_corr_gene2) == 0 ){
                  output$Two_gene_corr_statusA <- renderText({"Please enter gene1 and gene2"}) 
                  return(NULL)
                }
                # when input genes are not in the dataset
                tmp1=''; tmp2=''
                if(!gene1 %in% df()$id){
                  tmp1 <- paste0("Error in Gene1: '", gene1, "' is not included in the dataset.")
                }
                if(!gene2 %in% df()$id){
                  tmp2 <- paste0("Error in Gene2: '", gene2, "' is not included in the dataset.")
                }
                if(tmp1!='' | tmp2!=''){
                  if(tmp1 == ''){ 
                    output$Two_gene_corr_statusA <- renderText({tmp2}) 
                  }else if(tmp2 == ''){
                    output$Two_gene_corr_statusA <- renderText({tmp1}) 
                  }else{
                    output$Two_gene_corr_statusA <- renderText({paste(tmp1, tmp2, sep='\n')}) 
                  }
                  return(NULL)
                }
              }else if(input$Two_gene_corr_corr_Input == 'B'){
                output$Two_gene_corr_statusA <- renderText({NULL}) 
                gene1 <- df_Two_gene_corr_inputB_gene1()
                if(is.null(df_Two_gene_corr_inputB())){
                  return(NULL)
                }
                if(length(input$Two_gene_corr_table_rows_selected)==0){
                  return(NULL)
                }
                gene2 <- df_Two_gene_corr_inputB()[input$Two_gene_corr_table_rows_selected,]$Gene
              }
              # prepare the table
              output$Two_gene_corr_statusA <- renderText({NULL}) 
              output$Two_gene_corr_statusB <- renderText({NULL}) 
              df_tmp <- df()[df()$id %in% c(gene1, gene2),] # df_tmp <- df[df$id %in% c(gene2, gene1),]
              rownames(df_tmp) <- df_tmp$id
              df_tmp <- df_tmp[,-which(colnames(df_tmp) == 'id')]
              df_tmp <- t(df_tmp)
              if(input$Two_gene_corr_choose_sample){ # when focusing on some samples
                if(nchar(input$Two_gene_corr_choose_sample_input) == 0){
                  output$Two_gene_corr_status_selectsample <- renderText({'You are selecting "Select samples" below. Please enter the sample names there.'})
                  return(NULL)
                }
                samples <- intersect(unlist(strsplit(input$Two_gene_corr_choose_sample_input, split = "\n")), rownames(df_tmp)) 
                samples_not_found <- setdiff(unlist(strsplit(input$Two_gene_corr_choose_sample_input, split = "\n")), rownames(df_tmp))
                if(length(samples_not_found) > 0){
                  samples_not_found_tmp <- paste(samples_not_found, collappse=', ')
                  output$Two_gene_corr_status_selectsample <- renderText({paste0('The following sample names are not found. Please enter the correct names: \n', samples_not_found_tmp)})
                }else{
                  output$Two_gene_corr_status_selectsample <- renderText({NULL})
                }
                if(length(samples)==0){
                  return(NULL)
                }
                df_tmp <- df_tmp[samples,]
              }else{
                output$Two_gene_corr_status_selectsample <- renderText({NULL})
              }
              # when taking log2
              if(input$Two_gene_corr_corr_Input == 'A'){
                if(input$Two_gene_corr_log){
                  df_tmp <- log2(df_tmp+1)
                }
              }else if(input$Two_gene_corr_corr_Input == 'B'){
                if(df_Two_gene_corr_inputB()$log[1] == 1){
                  df_tmp <- log2(df_tmp+1)
                }
              }

              # when using groups for colouring
              if(input$Two_gene_corr_colour_grorp){
                Group <- c()
                for (i in strsplit(rownames(df_tmp), '_')){
                  tmp <- ''
                  for(j in 1:(length(i)-1)){
                    tmp <- paste0(tmp, i[j],'_')
                  }
                  tmp <- substr(tmp, 1, nchar(tmp)-1)
                  Group <- c(Group, tmp)
                }
                df_tmp <- data.frame(df_tmp)
                df_tmp$Group <- Group
              }
              return(df_tmp)
            })
          
          # when selecting the smaples to use
            output$Two_gene_corr_choose_sample_input_list <- renderText({
              tmp <- colnames(df())[which(colnames(df()) != 'id')]
              tmp <- tmp[order(tmp)]
              paste(tmp, collapse='\n')
            })

          # gene2 from custome genesets
            output$Two_gene_corr_gene2_Input_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c()
              gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
              selectInput('Two_gene_corr_gene2_Input_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
            outputOptions(output, "Two_gene_corr_gene2_Input_from_custom_geneset_select",  suspendWhenHidden=FALSE)
          
          # table status
            output$Two_gene_corr_table_status <- renderText({
              if(is.null(df_Two_gene_corr_inputB())){
                "Please calculate the correlations first"
              }else{
                return(NULL)
              }
            })

          # display a table
            output$Two_gene_corr_table <- renderDataTable({
              if(is.null(df_Two_gene_corr_inputB())){
                tmp <- data.frame(list('Gene'=character(0), 'Correlation'=character(0),'Pvalue'=character(0)), stringsAsFactors = FALSE)
                datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
              }else{
                datatable( data.frame(df_Two_gene_corr_inputB()[, c('Gene', 'Correlation', 'Pvalue')]), selection = list(mode='single'),  options = list(scrollX = TRUE, scrollY = TRUE)) 
              }
            })

          # plot
            output$Two_gene_corr_plot <- renderPlot({
              if(is.null(df_Two_gene_corr())){
                if(input$Two_gene_corr_corr_Input == 'B'){
                  if(is.null(df_Two_gene_corr_inputB())){
                    output$Two_gene_corr_corr_score <- renderText({"Please set the inputs and click 'Calculate the correlations'"})
                  }else{
                    if(length(input$Two_gene_corr_table_rows_selected) == 0){
                      output$Two_gene_corr_corr_score <- renderText({"Please select a row from the table."})
                    }else{
                      output$Two_gene_corr_corr_score <- renderText({NULL})
                    }
                  }
                }else{
                  output$Two_gene_corr_corr_score <- renderText({NULL})
                }
                return(ggplot())
              }else{
                if(input$Two_gene_corr_corr_Input == 'A'){
                  gene1 <- input$Two_gene_corr_gene1
                  gene2 <- input$Two_gene_corr_gene2
                  df_tmp <- df_Two_gene_corr()
                }else{
                  gene1 <- df_Two_gene_corr_inputB_gene1()
                  gene2 <- df_Two_gene_corr_inputB()[input$Two_gene_corr_table_rows_selected,]$Gene
                  df_tmp <- df_Two_gene_corr()
                }
                if(!is.null(df_tmp)){
                  if(input$Two_gene_corr_colour_grorp){
                    p <- ggplot(df_tmp, aes_string(x=gene2, y=gene1, color='Group')) + geom_point(size=input$Two_gene_corr_pt.size)
                  }else{
                    p <- ggplot(df_tmp, aes_string(x=gene2, y=gene1)) + geom_point(size=input$Two_gene_corr_pt.size)
                  }
                  if(input$Two_gene_corr_plot_line){
                    p <- p + geom_smooth(method='lm', se=TRUE, size=0.2, color='black')
                  }
                  if(input$Two_gene_corr_corr_Input == 'A' & input$Two_gene_corr_log){
                    p <- p + xlab(paste(gene2, 'log2(Expression+1)', sep='\n')) + ylab(paste(gene1, 'log2(Expression+1)', sep='\n'))
                  }
                  if(input$Two_gene_corr_corr_Input == 'B'){
                    if(df_Two_gene_corr_inputB()$log[1] == 1){
                      p <- p + xlab(paste(gene2, 'log2(Expression+1)', sep='\n')) + ylab(paste(gene1, 'log2(Expression+1)', sep='\n'))
                    }
                  }
                  # calculate R and p
                  res <- cor.test(df_tmp[, gene1], df_tmp[, gene2], method=input$Two_gene_corr_corr_method)
                  r <- res$estimate
                  pval <- res$p.value
                  output$Two_gene_corr_corr_score <- renderText({
                    paste0('Correlation: ', r, '\n', 'P-value: ', pval)
                  })
                  p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                }else{
                  return(ggplot())
                }
              }
              p <- p + theme(axis.title = element_text(size=input$Two_gene_corr_title.font.size), axis.text = element_text(size=input$Two_gene_corr_label.font.size))
              p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              p <- p + theme(legend.key.size = unit(2, "mm"))
              p <- p + theme(legend.title = element_blank(), legend.text = element_text(size=input$Two_gene_corr_legend.font.size))
              if(input$Two_gene_corr_while_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }, width=reactive(input$Two_gene_corr_fig.width), height=reactive(input$Two_gene_corr_fig.height), res=300)
          #
        ######
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
      outputOptions(output, "choose_data_type", suspendWhenHidden=FALSE)

      output$Compare_dataset_selection_status <- renderText({"Please choose the data type first, and select the datasets that you want to compare from the 'Dataset select' table. "})


      # selectinon filtering
      # data from who
      output$Compare_dataset_filtering_Data_from <- renderUI({
        data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        tmp <- data_tmp$Data.from
        selectInput('Compare_dataset_filtering_Data_from', 'Data from', c('None'= 'None', tmp))
      })
      outputOptions(output, "Compare_dataset_filtering_Data_from", suspendWhenHidden=FALSE)

      # data from which experiment
      output$Compare_dataset_filtering_Experiment <- renderUI({
        data_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
        if(length(input$Compare_dataset_filtering_Data_from)!= 0){
          if(input$Compare_dataset_filtering_Data_from != 'None'){ data_tmp <- data_tmp[data_tmp$Data.from == input$Compare_dataset_filtering_Data_from,] }
        }
        tmp <- data_tmp$Experiment
        selectInput('Compare_dataset_filtering_Experiment', 'Experiment', c('None'= 'None', tmp))
      })
      outputOptions(output, "Compare_dataset_filtering_Experiment", suspendWhenHidden=FALSE)

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
          selection='none', extensions=c('Select', 'Buttons'), rownames=F,
          options = list( select=list(style="multi", items='row'), 
            scrollX = TRUE, pageLength = 10, 
            dom='Blfrtip', rowId=0, buttons=c('selectAll', 'selectNone') ))
      },server = FALSE)


    #### Dataset comparison
      # when using the custom geneset
        output$target_gene_for_comparing_Input_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
          selectInput('target_gene_for_comparing_Input_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "target_gene_for_comparing_Input_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # chosse the score for comparison
        output$Choose_datasets_y <- renderUI({ 
          if(length(input$choose_data_type)!=0){
            if(input$choose_data_type != 'None'){
              data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T,check.names = FALSE)
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
        outputOptions(output, "Choose_datasets_y", suspendWhenHidden=FALSE)
        output$Choose_datasets_colour <- renderUI({ 
          if(length(input$choose_data_type)!=0){
            if(input$choose_data_type != 'None'){
              data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T,check.names = FALSE)
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
        outputOptions(output, "Choose_datasets_colour", suspendWhenHidden=FALSE)


      # Start comparing the score
        df_compare_prepare <- reactiveVal(NULL)
        isCalculating_compare <- reactiveVal(FALSE)
        isTriger_compare <- reactiveVal(FALSE)
        observeEvent(input$comparison_start,{
          isCalculating_compare(TRUE)
          isTriger_compare(TRUE)
          data_table_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
          if(!is.null(input$Compare_dataset_filtering_Data_from) && input$Compare_dataset_filtering_Data_from != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] }
          if(!is.null(input$Compare_dataset_filtering_Experiment) && input$Compare_dataset_filtering_Experiment != 'None'){ data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] }
          # when datasets are not selected
          if(length(input$all_dataset_rows_selected) == 0){
            show_alert(title='Error.',text='Please select the datasets first.', type='error')
            output$Gene_comparing_status <- renderText({"Please select the datasets first."})
            df_compare_prepare(NULL)
            isCalculating_compare(FALSE)
            return(NULL)
          }
          datasets_for_compare <- data_table_tmp[input$all_dataset_rows_selected,]$Dataset
          # gene inputs
          # from custome genes
          if(input$target_gene_for_comparing_Input_from_custom_geneset){
            if(input$target_gene_for_comparing_Input_from_custom_geneset_select == 'None'){
              show_alert(title='Error.',text='Please select the custom geneset.', type='error')
              output$Gene_comparing_status <- renderText({"Please select the custom geneset."})
              df_compare_prepare(NULL)
              isCalculating_compare(FALSE)
              return(NULL)
            }else{
              Genes_to_be_shown_list <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$target_gene_for_comparing_Input_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
            } 
          }else{
            if(nchar(input$target_gene_for_comparing) == 0){ # when no genes are specified
              show_alert(title='Error.',text='Please enter the gene names.', type='error')
              output$Gene_comparing_status <- renderText({"Please enter the gene names."})
              df_compare_prepare(NULL)
              isCalculating_compare(FALSE)
              return(NULL)
            }else{
              Genes_to_be_shown_list <- unlist(strsplit(input$target_gene_for_comparing, split = "\n"))
            }
          }
          # when Y is not selected
          if(input$Choose_datasets_y == 'None'){
            show_alert(title='Error.',text='Please select the Y-axis.', type='error')
            output$Gene_comparing_status <- renderText({"Please select the Y-axis."})
            df_compare_prepare(NULL)
            isCalculating_compare(FALSE)
            return(NULL)
          }
          output$Gene_comparing_status <- renderText({NULL})
          Y_axis <- input$Choose_datasets_y
          undetected_genes <- c()
          # start extract the scores for each gene
          if(input$Choose_datasets_colour == 'None'){
            df_Y_tmp <- data.frame(id = Genes_to_be_shown_list) 
            for (dataset in datasets_for_compare){
              df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T,check.names = FALSE)
              if(colnames(df_tmp_tmp)[1] == 'X'){colnames(df_tmp_tmp)[1]='id'}
              df_tmp_tmp_Y <- df_tmp_tmp[df_tmp_tmp$id %in% Genes_to_be_shown_list, c('id', Y_axis)]
              colnames(df_tmp_tmp_Y)[2] <- dataset 
              df_Y_tmp <- merge(df_Y_tmp, df_tmp_tmp_Y, by='id', all.x=TRUE)
              rm(df_tmp_tmp)
            }
            df_Y_tmp$type <- 'Y'
            df_Y_tmp$Y_axis_name <- Y_axis
            df_compare_prepare(df_Y_tmp)
            isCalculating_compare(FALSE)
            return(NULL)
          }else{
            df_Y_tmp <- data.frame(id = Genes_to_be_shown_list) 
            df_col_tmp <- data.frame(id = Genes_to_be_shown_list)
            col <- input$Choose_datasets_colour
            for (dataset in datasets_for_compare){
              df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T,check.names = FALSE)
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
            df_Y_col_tmp$Y_axis_name <- Y_axis
            df_Y_col_tmp$col_name <- col
            df_compare_prepare(df_Y_col_tmp)
            isCalculating_compare(FALSE)
            return(NULL)
          }        
        })

      # select a gene from a table
        output$Gene_comparing_gene_list_table <- DT::renderDataTable({
          if(is.null(df_compare_prepare())){
            tmp <- data.frame('Input'=character(0))
            rownames(tmp) <- NULL
            datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE))
          }else{
            tmp <- data.frame('Input'=unique(df_compare_prepare()$id))
            rownames(tmp) <- NULL
            datatable(tmp, selection = list(mode='single'), options = list(scrollY=TRUE, scroller=TRUE, pageLength = 5))
          }
        })

      # table for the plot
        # output$Gene_comparing_plot_status <- renderText({'Please set the inputs and start analysis first.'})
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
          Y_axis <- df_compare_tmp$Y_axis_name[1]
          colnames(df_compare_tmp_Y) <- c(Y_axis)  # colnames(df_compare_tmp_Y) <- c(Y_axis)
          df_compare_tmp_Y$dataset <- rownames(df_compare_tmp_Y)
          if('col' %in% df_compare_tmp$type){
            df_compare_tmp_col <- data.frame(t(df_compare_tmp[df_compare_tmp$type == 'col',]))
            colnames(df_compare_tmp_col) <- c('Colour')
            df_compare_tmp_col$dataset <- rownames(df_compare_tmp_col)
            df_compare <- merge(df_compare_tmp_Y, df_compare_tmp_col, by='dataset')
            df_compare[,'Colour'] <- as.numeric(df_compare[,'Colour'])
            df_compare$col_name <- df_compare_tmp$col_name[1]
          }else{
            df_compare <- df_compare_tmp_Y
            df_compare <- df_compare[,c('dataset', Y_axis)]
            rownames(df_compare) <- NULL
          }
          df_compare$Y_axis_name <- Y_axis
          df_compare <- df_compare[df_compare$dataset != 'Y_axis_name',]
          df_compare <- df_compare[df_compare$dataset != 'col_name',]
          df_compare <- df_compare[df_compare$dataset != 'type',]
          df_compare[,Y_axis] <- as.numeric(df_compare[,Y_axis])
          df_compare <- df_compare[order(df_compare[,Y_axis], decreasing = T), ]
          # df_compare$dataset <- factor(df_compare$dataset, levels=df_compare$dataset)
          return(df_compare)
        })

      # show as a table
        dataframe_comparing_dataset_display_table <- reactive({
          if(is.null(df_compare())){
            tmp <- data.frame('Dataset'=character(0), 'Y axis value'=character(0))
            return(tmp)
          }
          if(dim(df_compare())[1] == 0){
            tmp <- data.frame('Dataset'=character(0), 'Y axis value'=character(0))
            return(tmp)
          }
          if(length(colnames(df_compare())) > 3){
            return(df_compare()[, c(1,2,3)])
          }
          if(length(colnames(df_compare())) == 3){
            return(df_compare()[, c(1,2)])
          }
        })

      # status for the plot
        output$Gene_comparing_status <- renderText({
          "Please select the datasets and set the filtering setting above, and click 'Start Analysis'."
        })



      # display the result table
        output$dataframe_comparing_dataset <- renderDataTable({
          datatable( dataframe_comparing_dataset_display_table(), options = list(scrollX = TRUE, pageLength = 5 ))
        })

      # download the table
        output$comparing_dataset_download <- downloadHandler(
          filename = function(){"comparing_score_across_dataset.tsv"}, 
          content = function(fname){ write.table(dataframe_comparing_dataset_display_table(), fname, sep='\t', quote=F) }
        )

      # main plot for comparison
        output$Gene_comparing_plot <- renderPlot({
          if(is.null(df_compare())){
            return(ggplot())
          }
          df_compare <- df_compare()
          df_compare <- na.omit(df_compare)
          if(dim(df_compare)[1]==0){
            output$Gene_comparing_status <- renderText(NULL)
            output$Gene_comparing_plot_status <- renderText({"Non of the dataests included the inputted gene. Pleas make sure the gene name is correct and does not contain unnecessary spaces."})
            return(ggplot())
          }
          output$Gene_comparing_plot_status <- renderText({NULL})
          Y_axis <- df_compare$Y_axis_name[1]
          if(dim(df_compare)[2] == 5){
            col_name <- df_compare$col_name[1]
          }
          df_compare <- df_compare[order(df_compare[,Y_axis], decreasing = T),]
          df_compare$dataset <- factor(df_compare$dataset, levels=df_compare$dataset)
          if(is.null(df_compare()) || dim(df_compare)[1] == 0) { 
            return(ggplot()) 
          }
          # # if the colour option is set, change the colour of the plot
          # if(is.null(input$Choose_datasets_y) || input$Choose_datasets_y == 'None') { return(ggplot()) }
          else if(dim(df_compare)[2] == 5){ 
            p <- ggplot(df_compare, aes_string(x = 'dataset', y = Y_axis, fill='Colour', color = 'Colour')) 
          }else if(dim(df_compare)[2] == 3){ 
            p <- ggplot(df_compare, aes_string(x = 'dataset', y = Y_axis)) 
          }
          # either a scatter plot or a bar plot
          if(input$bar_or_scatter == "Scatter plot"){ 
            p <- p + geom_point(size = input$Compare_pt.size) 
          }else if (input$bar_or_scatter == "Bar plot") { 
            p <- p + geom_bar(stat = "identity") 
          }
          # change the color scale ( only when colour option is selected )
          if(dim(df_compare)[2] == 5){
            values_for_colours <- df_compare$Colour[!is.na(df_compare$Colour)]
            if( min(values_for_colours)<0 ){
              if( max(values_for_colours)>=0 ){
                tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=col_name)
                p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=col_name)
                p <- p + geom_hline(yintercept=0, linetype='dotted', linewidth=0.1)
              }else{
                p <- p + scale_color_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(values_for_colours), 0))  , limits = c(c(min(df_compare$Colour), 0)), name=col_name)
                p <- p + scale_fill_gradientn( colors = c(input$Compare_lowest_colour, input$Compare_zero_colour), values = scales::rescale(c(min(values_for_colours), 0))  , limits = c(c(min(df_compare$Colour), 0)) , name=col_name)
              }
            }else{
              p <- p + scale_color_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(df_compare$Colour)))  , limits = c(0,max(df_compare$Colour)) , name=col_name)
              p <- p + scale_fill_gradientn( colors = c(input$Compare_zero_colour, input$Compare_highest_colour), values = scales::rescale(c(0,max(df_compare$Colour)))  , limits = c(0,max(df_compare$Colour)) , name=col_name)
            }
          }
          p <- p + ggtitle(colnames(df_compare)[1])
          p <- p + labs(x= 'Datasets',  y = Y_axis)
          p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_graph.title.font.size))
          p <- p + theme(axis.text.y = element_text(size = input$Compare_label.font.size), axis.text.x = element_text(size = input$Compare_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_title.font.size), axis.title.x = element_text(size = input$Compare_title.font.size))
          tmp <- data.frame('Input'=unique(df_compare_prepare()$id))
          gene <- tmp[input$Gene_comparing_gene_list_table_rows_selected,]
          p <- p + ggtitle(gene)
          p <- p + theme(legend.text = element_text(size=input$Compare_label_legend_size), legend.title= element_text(size=input$Compare_label_legend_size))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          if(input$Compare_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p <- p + theme(legend.key.size = unit(1, "mm"))
          p
        }, width=reactive(input$Compare_fig.width), height=reactive(input$Compare_fig.height), res=300)

      #

    #### investigate the overlap
      # chosse the score for comparison
        output$Compare_dataset_get_overview_select_score <- renderUI({ 
          if(!is.null(input$choose_data_type)){
            if(input$choose_data_type != 'None'){
              data_ex_tmp <- read.table(Dataset()[Dataset()$Data.type == input$choose_data_type,]$Path[1], sep='\t', header=T,check.names = FALSE)
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
        outputOptions(output, "Compare_dataset_get_overview_select_score", suspendWhenHidden=FALSE)

      # default status  
        output$Compare_dataset_get_overview_status <- renderText({
          "Please select the datasets and set the filter setting above, and start 'Investigate the overlap'."
        })

      # Start calculation to check the overlap. 
        overlap_barplot_legend_tilte <- reactiveVal({NULL})
        df_compare_overlapped_hit <- reactiveVal({NULL})
        isCalculating_ovelap_hit <- reactiveVal({FALSE})
        isTriggered_ovelap_hit <- reactiveVal({FALSE})
        observeEvent(input$Compare_dataset_get_overview_start, {
          isCalculating_ovelap_hit(TRUE)
          isTriggered_ovelap_hit(TRUE)
          # datasets slection
          data_table_tmp <- Dataset()[Dataset()$Data.type == input$choose_data_type, ] 
          if(!is.null(input$Compare_dataset_filtering_Data_from) && input$Compare_dataset_filtering_Data_from != 'None'){ 
            data_table_tmp <- data_table_tmp[data_table_tmp$Data.from == input$Compare_dataset_filtering_Data_from, ] 
          }
          if(!is.null(input$Compare_dataset_filtering_Experiment) && input$Compare_dataset_filtering_Experiment != 'None'){ 
            data_table_tmp <- data_table_tmp[data_table_tmp$Experiment == input$Compare_dataset_filtering_Experiment, ] 
          }
          datasets_for_compare <- data_table_tmp[input$all_dataset_rows_selected,]$Dataset
          if(length(datasets_for_compare)==0){
            show_alert(title='Error.',text='Please select more than two datasets to compare.', type='error')
            output$Compare_dataset_get_overview_status <- renderText({"Please select more than two datasets to compare."})
            df_compare_overlapped_hit(NULL)
            isCalculating_ovelap_hit(FALSE)
            return(NULL)
          }
          # if a score for ranking is not set
          else if(input$Compare_dataset_get_overview_select_score == 'None' || is.null(input$Compare_dataset_get_overview_select_score)){
            show_alert(title='Error.',text='Please select a score for ranking.', type='error')
            output$Compare_dataset_get_overview_status <- renderText({"Please select the score for ranking"})
            df_compare_overlapped_hit(NULL)
            isCalculating_ovelap_hit(FALSE)
            return(NULL)
          }else{
            output$Compare_dataset_get_overview_status <- renderText({NULL})
            sorted_score <- input$Compare_dataset_get_overview_select_score
            df_tmp <- data.frame()    
            i=0
            for (dataset in datasets_for_compare){
              df_tmp_tmp <- read.table(Dataset()[Dataset()$Dataset == dataset,]$Path, sep='\t', header=T,check.names = FALSE)
              if(colnames(df_tmp_tmp)[1] == 'X'){colnames(df_tmp_tmp)[1]='id'}
              df_tmp_tmp_sorted <- df_tmp_tmp[,c('id', sorted_score)][order(df_tmp_tmp[,sorted_score], decreasing = T),] # head(df_tmp_tmp_sorted)
              # get the threshold score
              # and if the score does not meet the threshold, the score will be replaced by NA
              if(input$Compare_dataset_get_overview_direction == 'Top X%'){
                if(length(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]>0])==0){
                  df_tmp_tmp_sorted[,sorted_score] <- NA  
                }else{
                  thr <- quantile(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]>0], 1-(input$Compare_dataset_get_overview_threshold/100), na.rm = T)
                  df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score] < thr] <- NA
                }
              }else{
                if(length(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]<0])==0){
                  df_tmp_tmp_sorted[,sorted_score] <- NA  
                }else{
                  thr <- quantile(df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score]<0], input$Compare_dataset_get_overview_threshold/100 , na.rm = T)
                  df_tmp_tmp_sorted[,sorted_score][df_tmp_tmp_sorted[,sorted_score] > thr] <- NA
                }
              }
              # merge into one dataframe
              colnames(df_tmp_tmp_sorted) <- c('id', dataset)
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
            overlap_barplot_legend_tilte(sorted_score)
            df_tmp # head(df_tmp)
            df_compare_overlapped_hit(df_tmp)
            isCalculating_ovelap_hit(FALSE)
            return(NULL)
          }

        })

      # display the overlapped genes as a table
        output$Compare_dataset_get_overview_overlap <- DT::renderDataTable({
          if(!isTriggered_ovelap_hit()){
            output$Compare_dataset_get_overview_status <- renderText({"Please click 'Investigate the overlap' to start."})
            tmp <- data.frame()
          }else if(isCalculating_ovelap_hit()){
            output$Compare_dataset_get_overview_status <- renderText({"Calculating the overlap. Please wait."})
            tmp <- data.frame()
          }else if(!is.null(df_compare_overlapped_hit())){
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
          if(is.null(df_compare_overlapped_hit())){
            return(NULL)
          }
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
              if( min(values_for_colours)<0 ){
                if( max(values_for_colours)>=0 ){
                  tmp <- max(abs(max(values_for_colours)), abs(min(values_for_colours)))
                  p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=overlap_barplot_legend_tilte())
                  p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(-tmp, 0, tmp)) , limits = c(-tmp, tmp), name=overlap_barplot_legend_tilte())
                }else{
                  p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour), values = scales::rescale(c(min(values_for_colours), 0) ) , limits = c(c(min(values_for_colours), 0)) , name=overlap_barplot_legend_tilte())
                  p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_lowest_colour, input$Compare_dataset_get_overview_zero_colour), values = scales::rescale(c(min(values_for_colours), 0) ) , limits = c(c(min(values_for_colours), 0)) , name=overlap_barplot_legend_tilte())
                }
              }else{
                p <- p + scale_color_gradientn( colors = c(input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Compare_dataset_get_overview_select_score)
                p <- p + scale_fill_gradientn( colors = c(input$Compare_dataset_get_overview_zero_colour, input$Compare_dataset_get_overview_highest_colour), values = scales::rescale(c(0,max(values_for_colours)))  , limits = c(0,max(values_for_colours)) , name=input$Compare_dataset_get_overview_select_score)
              }
              p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + theme(plot.title = element_text(size = input$Compare_dataset_get_overview_graph.title.font.size))
              p <- p + theme(axis.text.y = element_text(size = input$Compare_dataset_get_overview_label.font.size), axis.text.x = element_text(size = input$Compare_dataset_get_overview_label.font.size)) + theme(axis.title.y = element_text(size = input$Compare_dataset_get_overview_title.font.size), axis.title.x = element_text(size = input$Compare_dataset_get_overview_title.font.size))
              p <- p + ggtitle(gene)
              p <- p + theme(legend.text = element_text(size=input$Compare_dataset_get_overview_legend_size), legend.title= element_text(size=input$Compare_dataset_get_overview_legend_size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              p <- p + theme(legend.key.size = unit(2, "mm"))
              if(input$Compare_dataset_get_overview_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }else{
              output$Compare_dataset_get_overview_barplot_status <- renderText({'Please select a row from the table'})
              return(ggplot())
            }
          }else{
            output$Compare_dataset_get_overview_barplot_status <- renderText({"Please set the input and start analysis first."})
            return(ggplot())
          }
        }, width=reactive(input$Compare_dataset_get_overview_fig.width), height=reactive(input$Compare_dataset_get_overview_fig.height), res=300)
      #
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
      outputOptions(output, "Integrate_data1_Seuqenced_by", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data1_Experiments", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data1_Data_type", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data1_select", suspendWhenHidden=FALSE)

      # dataset2
      output$Integrate_data2_Seuqenced_by <- renderUI({ Seuqenced_by_select_button_creation(Dataset(), 'Integrate_data2_Seuqenced_by') })
      output$Integrate_data2_Experiments <- renderUI({ Experiments_select_button_creation(Dataset(), 'Integrate_data2_Experiments', input$Integrate_data2_Seuqenced_by) })
      output$Integrate_data2_Data_type <- renderUI({ Data_type_select_button_creation(Dataset(), 'Integrate_data2_Data_type', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments) })
      output$Integrate_data2_select <- renderUI({ dataset_select_button_creation(Dataset(), 'Integrate_data2_select', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments, input$Integrate_data2_Data_type) })
      outputOptions(output, "Integrate_data2_Seuqenced_by", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data2_Experiments", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data2_Data_type", suspendWhenHidden=FALSE)
      outputOptions(output, "Integrate_data2_select", suspendWhenHidden=FALSE)


    #### dataset load
      data_load <- function(selected_data){
        if(!is.null(selected_data) && selected_data!= 'None'){
          path <- Dataset()[Dataset()$Dataset == selected_data, ]$Path
          df_tmp <- read.table(path, sep='\t', header=T,check.names = FALSE)
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
        outputOptions(output, "Integrate_data1_Scat.X", suspendWhenHidden=FALSE)
        outputOptions(output, "Integrate_data2_Scat.X", suspendWhenHidden=FALSE)
        outputOptions(output, "Integrate_data1_Scat.Y", suspendWhenHidden=FALSE)
        outputOptions(output, "Integrate_data2_Scat.Y", suspendWhenHidden=FALSE)

      ##### get outliers (filtered genes)
        get_outliers <- function(df_main_plot, X_thr_method, Y_thr_method, selected_x, selected_y, x_threshold_1, x_threshold_2, y_threshold_1, y_threshold_2, method, brush_point){
          if(is.null(df_main_plot)){
            return(NULL)
          }
          if(selected_x=='None' | selected_y=='None'){
            return(NULL)
          }
          if(method=='A'){            
            if(X_thr_method == 'A' & Y_thr_method == 'A'){
              return(NULL)  
            }else{
              df_main_plot_thre <- switch(X_thr_method, 
                  "A" = df_main_plot,
                  "B" = df_main_plot[df_main_plot[selected_x] > x_threshold_1, ],
                  "C" = df_main_plot[df_main_plot[selected_x] < x_threshold_2, ],
                  "D" = df_main_plot[(df_main_plot[selected_x] > x_threshold_2) & (df_main_plot[selected_x] < x_threshold_1), ],
                  "E" = df_main_plot[(df_main_plot[selected_x] < x_threshold_2) | (df_main_plot[selected_x] > x_threshold_1), ],
              )
              df_main_plot_thre <- switch(Y_thr_method, 
                  "A" = df_main_plot_thre,
                  "B" = df_main_plot_thre[df_main_plot_thre[selected_y] > y_threshold_1, ],
                  "C" = df_main_plot_thre[df_main_plot_thre[selected_y] < y_threshold_2, ],
                  "D" = df_main_plot_thre[(df_main_plot_thre[selected_y] > y_threshold_2) & (df_main_plot_thre[selected_y] < y_threshold_1), ],
                  "E" = df_main_plot_thre[(df_main_plot_thre[selected_y] < y_threshold_2) | (df_main_plot_thre[selected_y] > y_threshold_1), ],
              )
              return(df_main_plot_thre)
            }
          }else{
            brushedPoints(df_main_plot, brush_point, xvar = selected_x, yvar = selected_y)
          }
        }
        data1_outliers <- reactive({ get_outliers(df_data1(), input$Integrate_data1_thr_X_method, input$Integrate_data1_thr_Y_method, input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, input$Integrate_data1_thr_X1, input$Integrate_data1_thr_X2, input$Integrate_data1_thr_Y1, input$Integrate_data1_thr_Y2, input$Integrate_data1_Gene_selection, input$Integrate_data1_plot_brush) })
        data2_outliers <- reactive({ get_outliers(df_data2(), input$Integrate_data2_thr_X_method, input$Integrate_data2_thr_Y_method, input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, input$Integrate_data2_thr_X1, input$Integrate_data2_thr_X2, input$Integrate_data2_thr_Y1, input$Integrate_data2_thr_Y2, input$Integrate_data2_Gene_selection, input$Integrate_data2_plot_brush) })

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
          plot_scatter_plot <- function(df_main_plot, Selected_x, Selected_y, outliers, mapped_thr_X, mapped_thr_Y, highligh_colour, show_label, plot_size, highlight_plot_size, highlight_label_size  ){
            if((Selected_x == 'None') ||(Selected_y == 'None')){ return(ggplot()) }
            else{ 
              p <- ggplot(df_main_plot, aes(x = .data[[Selected_x]], y = .data[[Selected_y]])) + geom_point(size = plot_size)
              if(!is.null(outliers)){
                if(!'id' %in% rownames(outliers)){
                  p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% outliers$id,], color=highligh_colour , size = highlight_plot_size)
                  if(show_label==1){
                    p <- p + geom_text_repel(data =  df_main_plot[df_main_plot$id %in% outliers$id,],  color = highligh_colour, aes(label = id), size = highlight_label_size, segment.size=0.2, max.overlaps=50)
                  }
                }
              }
            }
            p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
            p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p
          }    


        # plot1
          output$Integrate_data1_plot <- renderPlot({
            if(length(input$Integrate_data1_Scat.X) ==0 | length(input$Integrate_data1_Scat.Y)==0 ){
              return(ggplot())
            }
            if(input$Integrate_data1_Scat.X == 'None' | input$Integrate_data1_Scat.Y == 'None'){
              output$Integrate_data1_plot_status <- renderText({"Please select a dataset, X and Y."})
              return(ggplot())
            }else{
              output$Integrate_data1_plot_status <- renderText({NULL})
              if(input$Integrate_data_map_direction == 'A'){ 
                if(input$Integrate_data1_hide_labels){
                  p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size) 
                }else{
                  p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size) 
                }
                if(input$Integrate_data1_Gene_selection == 'A' & !input$Integrate_data1_hide_threshold){
                  if(length(input$Integrate_data1_thr_X_method)==0 | length(input$Integrate_data1_thr_Y_method)==0){
                    output$Integrate_data1_plot_status <- renderText({"Please check the filtering method is correctly set. Choose one from 'X,Y filter'."})
                    return(ggplot())
                  }
                  switch(input$Integrate_data1_thr_X_method,
                    'A' = p <- p,
                    'B' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', size=0.2),
                    'C' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', size=0.2),
                    'D' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', size=0.2),
                    'E' = p <- p + geom_vline(xintercept=input$Integrate_data1_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data1_thr_X2, linetype='dotted', size=0.2),
                  ) 
                  switch(input$Integrate_data1_thr_Y_method,
                    'A' = p <- p,
                    'B' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', size=0.2),
                    'C' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', size=0.2),
                    'D' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', size=0.2),
                    'E' = p <- p + geom_hline(yintercept=input$Integrate_data1_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data1_thr_Y2, linetype='dotted', size=0.2),
                  ) 
                }
              }else { 
                if(input$Integrate_data2_Scat.X == 'None' | input$Integrate_data2_Scat.Y == 'None'){
                  if(input$Integrate_data1_hide_labels){
                    p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size) 
                  }else{
                    p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size) 
                  }
                  
                }else{
                  if(input$Integrate_data1_hide_labels){
                    p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data1_colour_id, 0, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)  
                  }else{
                    p <- plot_scatter_plot(df_data1(), input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold, input$Integrate_data1_colour_id, 1, input$Integrate_data1_pt.size, input$Integrate_data1_high.pt.size, input$Integrate_data1_high.label.size)  
                  }
                  if(!input$Integrate_data_mapped_hide_threshold){
                    switch(input$Integrate_data_mapped_thr_X_method,
                      'A' = p <- p,
                      'B' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2),
                      'C' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                      'D' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                      'E' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                    ) 
                    switch(input$Integrate_data_mapped_thr_Y_method,
                      'A' = p <- p,
                      'B' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2),
                      'C' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                      'D' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                      'E' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                    ) 
                  }
                }
              }
              p <- p + theme(axis.text = element_text(size = input$Integrate_data1_label.font.size), axis.title = element_text(size = input$Integrate_data1_title.font.size))
              if(input$Integrate_data1_while_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }
          }, width=reactive(input$Integrate_data1_fig.width), height=reactive(input$Integrate_data1_fig.height), res=300)

        # plot2
          output$Integrate_data2_plot <- renderPlot({
            if(length(input$Integrate_data2_Scat.X) == 0 |  length(input$Integrate_data2_Scat.Y)== 0){
              return(ggplot())
            }
            if(input$Integrate_data2_Scat.X == 'None' |  input$Integrate_data2_Scat.Y== 'None'){
              output$Integrate_data2_plot_status <- renderText({"Please select a dataset, X and Y."})
              return(ggplot())
            }else{
              output$Integrate_data2_plot_status <- renderText({NULL})
              if(input$Integrate_data_map_direction == 'A'){ 
                if(input$Integrate_data1_Scat.X == 'None' | input$Integrate_data1_Scat.Y == 'None'){
                  if(input$Integrate_data2_hide_labels){
                    p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                  }else{
                    p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, NULL, input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                  }
                  
                }else{
                  if(input$Integrate_data2_hide_labels){
                    p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                  }else{
                    p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data1_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                  }
                  if(!input$Integrate_data_mapped_hide_threshold){
                    switch(input$Integrate_data_mapped_thr_X_method,
                      'A' = p <- p,
                      'B' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2),
                      'C' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                      'D' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                      'E' = p <- p + geom_vline(xintercept=input$Integrate_data_mapped_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data_mapped_thr_X2, linetype='dotted', size=0.2),
                    ) 
                    switch(input$Integrate_data_mapped_thr_Y_method,
                      'A' = p <- p,
                      'B' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2),
                      'C' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                      'D' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                      'E' = p <- p + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data_mapped_thr_Y2, linetype='dotted', size=0.2),
                    ) 
                  }
                }
              }   
              else { 
                if(input$Integrate_data2_hide_labels){
                  p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 0, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                }else{
                  p <- plot_scatter_plot(df_data2(), input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, data2_outliers(), input$Integrate_data_mapped_x_threshold, input$Integrate_data_mapped_y_threshold,  input$Integrate_data2_colour_id, 1, input$Integrate_data2_pt.size, input$Integrate_data2_high.pt.size, input$Integrate_data2_high.label.size) 
                }
                if(input$Integrate_data2_Gene_selection == 'A' & !input$Integrate_data2_hide_threshold){
                  if(length(input$Integrate_data2_thr_X_method)==0 | length(input$Integrate_data2_thr_Y_method)==0 ){
                    output$Integrate_data1_plot_status <- renderText({"Please select one from 'X/Y filter'."})
                    return(NULL)
                  }
                  switch(input$Integrate_data2_thr_X_method,
                    'A' = p <- p,
                    'B' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', size=0.2),
                    'C' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', size=0.2),
                    'D' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', size=0.2),
                    'E' = p <- p + geom_vline(xintercept=input$Integrate_data2_thr_X1, linetype='dotted', size=0.2) + geom_vline(xintercept=input$Integrate_data2_thr_X2, linetype='dotted', size=0.2),
                  ) 
                  switch(input$Integrate_data2_thr_Y_method,
                    'A' = p <- p,
                    'B' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', size=0.2),
                    'C' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', size=0.2),
                    'D' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', size=0.2),
                    'E' = p <- p + geom_hline(yintercept=input$Integrate_data2_thr_Y1, linetype='dotted', size=0.2) + geom_hline(yintercept=input$Integrate_data2_thr_Y2, linetype='dotted', size=0.2),
                  ) 
                }
              }
              p <- p + theme(axis.text = element_text(size = input$Integrate_data2_label.font.size), axis.title = element_text(size = input$Integrate_data2_title.font.size))
              if(input$Integrate_data2_while_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }
          }, width=reactive(input$Integrate_data2_fig.width), height=reactive(input$Integrate_data2_fig.height), res=300)

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

          output$Integrate_Overlapped_gene_table_status1 <- renderText({
            'A list of genes that meet the filter settings in both datasets is displayed here.\nPlease set the threshoolds for the data to which the selected genes are mapped.'
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
                df_tmp <- switch(input$Integrate_data_mapped_thr_X_method, 
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1, ],
                    "C" = df_tmp[df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2, ],
                    "D" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X2) & (df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X1), ],
                    "E" = df_tmp[(df_tmp[input$Integrate_data2_Scat.X] < input$Integrate_data_mapped_thr_X2) | (df_tmp[input$Integrate_data2_Scat.X] > input$Integrate_data_mapped_thr_X1), ],
                )       
                df_tmp <- switch(input$Integrate_data_mapped_thr_Y_method, 
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ],
                    "C" = df_tmp[df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2, ],
                    "D" = df_tmp[(df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y2) & (df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y1), ],
                    "E" = df_tmp[(df_tmp[input$Integrate_data2_Scat.Y] < input$Integrate_data_mapped_thr_Y2) | (df_tmp[input$Integrate_data2_Scat.Y] > input$Integrate_data_mapped_thr_Y1), ],
                )            
                overlapped_gene <- df_tmp$id
              }else{
                df_tmp <- df_data1()[df_data1()$id %in% gene_from_mapping_side,]
                df_tmp <- switch(input$Integrate_data_mapped_thr_X_method, 
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X1, ],
                    "C" = df_tmp[df_tmp[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X2, ],
                    "D" = df_tmp[(df_tmp[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X2) & (df_main_plot[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X1), ],
                    "E" = df_tmp[(df_tmp[input$Integrate_data1_Scat.X] < input$Integrate_data_mapped_thr_X2) | (df_main_plot[input$Integrate_data1_Scat.X] > input$Integrate_data_mapped_thr_X1), ],
                )       
                df_tmp <- switch(input$Integrate_data_mapped_thr_Y_method, 
                    "A" = df_tmp,
                    "B" = df_tmp[df_tmp[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y1, ],
                    "C" = df_tmp[df_tmp[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y2, ],
                    "D" = df_tmp[(df_tmp[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y2) & (df_main_plot[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y1), ],
                    "E" = df_tmp[(df_tmp[input$Integrate_data1_Scat.Y] < input$Integrate_data_mapped_thr_Y2) | (df_main_plot[input$Integrate_data1_Scat.Y] > input$Integrate_data_mapped_thr_Y1), ],
                ) 
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
              if(dim(Integrate_Overlapped_gene_table_tmp())[1]==0){
                output$Integrate_Overlapped_gene_table_status <- renderText({'No overlap genes. Please change the thrshold.'})
              }else{
                output$Integrate_Overlapped_gene_table_status <- renderText({NULL})
              }
              datatable( data.frame(Integrate_Overlapped_gene_table_tmp()),  options = list(scrollX = TRUE, pageLength = 10))  
            }else{
              output$Integrate_Overlapped_gene_table_status <- renderText({'Please set up the threshold of Data1 and Data2 above first.'})
              return(NULL)
            }
            
          })

        # Download the integrated table
          output$Integrate_Overlapped_gene_table_download <- downloadHandler(
            filename = function(){"Overlap_filtered_gene_data1_and_data2.tsv"}, 
            content = function(fname){ write.table(Integrate_Overlapped_gene_table_tmp(), fname, sep='\t', quote=F) }
          )

        # list up the gene names
          output$Integrate_Overlapped_gene_list <- renderText({
            paste(na.omit(Integrate_Overlapped_gene_table_tmp()$id), collapse = "\n")
          })
        #

      ##### plot the integrated figure
        # X axis
          output$Integrate_data1_plus_2_Scat.X <- renderUI({
            if(!is.null(data1_plus_data2())){ X_axis_name <- colnames(data1_plus_data2()) }
            else{ X_axis_name <- c() }
            selectInput('Integrate_data1_plus_2_Scat.X', 'X', c('None'='None', X_axis_name), selected = "")
          })
          outputOptions(output, "Integrate_data1_plus_2_Scat.X", suspendWhenHidden=FALSE)

        # Y axis
          output$Integrate_data1_plus_2_Scat.Y <- renderUI({
            if(!is.null(data1_plus_data2())){ Y_axis_name <- colnames(data1_plus_data2()) }
            else{ Y_axis_name <- c() }
            selectInput('Integrate_data1_plus_2_Scat.Y', 'Y', c('None'='None', Y_axis_name))
          })
          outputOptions(output, "Integrate_data1_plus_2_Scat.Y", suspendWhenHidden=FALSE)


        # colour
          output$Integrate_data1_plus_2_Scat.colour <- renderUI({
            if(!is.null(data1_plus_data2())){ col_name <- colnames(data1_plus_data2()) }
            else{ col_name <- c() }
            selectInput('Integrate_data1_plus_2_Scat.colour', 'Colour', c('None'='None', col_name))
          })
          outputOptions(output, "Integrate_data1_plus_2_Scat.colour", suspendWhenHidden=FALSE)

        # get the filtered genes
          # for pathway genes, select pathway
            Integrate_data1_plus_2_plot_Gene_set <- reactive({
              if(input$Integrate_data1_plus_2_plot_use_geneset){
                if(input$Integrate_data1_plus_2_plot_pathway_dataset_select == 'HALLMARK (human)'){ gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt') }
                else if(input$Integrate_data1_plus_2_plot_pathway_dataset_select == 'HALLMARK (mouse)'){ gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt') } 
                else if(input$Integrate_data1_plus_2_plot_pathway_dataset_select == 'Custom'){ 
                  tmp <- input$Integrate_data1_plus_2_plot_upload_custom_pathway_file
                  if (is.null(tmp)){ gsc <- NULL }
                  else { gsc <- getGmt(tmp$datapath)}
                }
                gsc
              }else{
                return(NULL)
              }
            })

            output$Integrate_data1_plus_2_plot_select_pathway <- renderUI({
              gene_sets_names <- c()
              if(!is.null(Integrate_data1_plus_2_plot_Gene_set())){
                for ( i in 1:length(Integrate_data1_plus_2_plot_Gene_set())){ gene_sets_names <- c(gene_sets_names, Integrate_data1_plus_2_plot_Gene_set()@.Data[[i]]@setName)}
              }
              selectInput('Integrate_data1_plus_2_plot_select_pathway', 'Select a geneset',  c('None'='None', gene_sets_names))  
            })
            outputOptions(output, "Integrate_data1_plus_2_plot_select_pathway", suspendWhenHidden=FALSE)

          # take filtered genes
          Integrate_data1_plus_2_plot_filtered <- reactive({
            df_main_plot <- data1_plus_data2()
            if(is.null(df_main_plot)){ 
              return(NULL)
            }
            if((input$Integrate_data1_plus_2_Scat.X == 'None') || (input$Integrate_data1_plus_2_Scat.Y == 'None')){ 
              return(NULL)  
            }
            if(!input$Integrate_data1_plus_2_plot_use_geneset & input$Integrate_data1_plus_2_plot_xselect =='E' & input$Integrate_data1_plus_2_plot_yselect =='E'){
              return(NULL)  
            }
            x_select <- input$Integrate_data1_plus_2_plot_xselect
            y_select <- input$Integrate_data1_plus_2_plot_yselect
            if(!is.numeric(input$Integrate_data1_plus_2_plot_xthr1) & (x_select == 'A' | x_select == 'C' | x_select == 'D')){
              return(NULL)
            }
            if(!is.numeric(input$Integrate_data1_plus_2_plot_xthr2) & (x_select == 'B' | x_select == 'C' | x_select == 'D')){
              return(NULL)
            }
            if(!is.numeric(input$Integrate_data1_plus_2_plot_ythr1) & (y_select == 'A' | y_select == 'C' | y_select == 'D')){
              return(NULL)
            }
            if(!is.numeric(input$Integrate_data1_plus_2_plot_ythr2) & (y_select == 'B' | y_select == 'C' | y_select == 'D')){
              return(NULL)
            }
            if(input$Integrate_data1_plus_2_plot_use_geneset){
              if(input$Integrate_data1_plus_2_plot_select_pathway != 'None'){ 
                genes_in_the_pathway <- Integrate_data1_plus_2_plot_Gene_set()[[input$Integrate_data1_plus_2_plot_select_pathway]]@geneIds
                df_main_plot <- df_main_plot[df_main_plot$id %in% genes_in_the_pathway, ]
              }else{
                return(NULL)
              }

            }
            if(dim(df_main_plot)[1] != 0){
              switch(x_select,
                "A" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.X] >=  input$Integrate_data1_plus_2_plot_xthr1, ] },
                "B" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.X] <=  input$Integrate_data1_plus_2_plot_xthr2, ] },
                "C" = { df_main_plot <- df_main_plot[ (df_main_plot[input$Integrate_data1_plus_2_Scat.X] <=  input$Integrate_data1_plus_2_plot_xthr1 & df_main_plot[input$Integrate_data1_plus_2_Scat.X] >=  input$Integrate_data1_plus_2_plot_xthr2), ] },
                "D" = { df_main_plot <- df_main_plot[ (df_main_plot[input$Integrate_data1_plus_2_Scat.X] >=  input$Integrate_data1_plus_2_plot_xthr1 |  df_main_plot[input$Integrate_data1_plus_2_Scat.X] <=  input$Integrate_data1_plus_2_plot_xthr2), ] }
              )
              switch(y_select,
                "A" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >=  input$Integrate_data1_plus_2_plot_ythr1, ] },
                "B" = { df_main_plot <- df_main_plot[df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <=  input$Integrate_data1_plus_2_plot_ythr2, ] },
                "C" = { df_main_plot <- df_main_plot[ (df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <=  input$Integrate_data1_plus_2_plot_ythr1 & df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >=  input$Integrate_data1_plus_2_plot_ythr2), ] },
                "D" = { df_main_plot <- df_main_plot[ (df_main_plot[input$Integrate_data1_plus_2_Scat.Y] >=  input$Integrate_data1_plus_2_plot_ythr1 |  df_main_plot[input$Integrate_data1_plus_2_Scat.Y] <=  input$Integrate_data1_plus_2_plot_ythr2), ] }
              )
            }
            return(df_main_plot)
          })

        # plot
          # for highlight genes from the custome genes 
            output$Integrate_data1_plus_2_target_gene_from_custom_geneset_select <- renderUI({
                  gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
                  selectInput('Integrate_data1_plus_2_target_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
                })
            outputOptions(output, "Integrate_data1_plus_2_target_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)


          # plot
            output$Integrate_data1_plus_2_plot <- renderPlot({
              df_main_plot <- data1_plus_data2()
              if(is.null(df_main_plot)){ 
                output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the Data1 and the Data2."})
                return(ggplot()) 
              }
              if((input$Integrate_data1_plus_2_Scat.X == 'None') || (input$Integrate_data1_plus_2_Scat.Y == 'None')){ 
                output$Integrate_data1_plus_2_plot_status <- renderText({"Please set the X and the Y."})
                return(ggplot())  
              }
              else{ 
                output$Integrate_data1_plus_2_plot_status <- renderText({NULL})
                if(is.null(input$Integrate_data1_plus_2_Scat.colour) || input$Integrate_data1_plus_2_Scat.colour == 'None'){
                  p <- ggplot(df_main_plot, 
                    aes(x = .data[[input$Integrate_data1_plus_2_Scat.X]], y = .data[[input$Integrate_data1_plus_2_Scat.Y]]))
                }else{
                  p <- ggplot(df_main_plot, 
                    aes(x = .data[[input$Integrate_data1_plus_2_Scat.X]], y = .data[[input$Integrate_data1_plus_2_Scat.Y]], color = .data[[input$Integrate_data1_plus_2_Scat.colour]]))

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
                  res <- brushedPoints(df_main_plot, input$Integrate_data1_plus_2_plot_brush,
                    xvar = input$Integrate_data1_plus_2_Scat.X, yvar = input$Integrate_data1_plus_2_Scat.Y)
                  p <- p + geom_text_repel(data = res,  color = 'black', aes(label = id), size=input$Integrate_data1_plus_2_id_size, segment.size=0.2)
                },
                error = function(e){NULL}
              )
              if(!is.null(Integrate_data1_plus_2_plot_filtered())){
                Integrate_outliers <- Integrate_data1_plus_2_plot_filtered()
                if(input$Integrate_data1_plus_2_plot_xselect == 'A'){
                  p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr1, linetype='dotted', size=0.2) 
                }else if(input$Integrate_data1_plus_2_plot_xselect == 'B'){
                  p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr2, linetype='dotted', size=0.2)  
                }else if(input$Integrate_data1_plus_2_plot_xselect == 'C' | input$Integrate_data1_plus_2_plot_xselect == 'D'){
                  p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr1, linetype='dotted', size=0.2)  
                  p <- p + geom_vline(xintercept=input$Integrate_data1_plus_2_plot_xthr2, linetype='dotted', size=0.2)  
                }

                if(input$Integrate_data1_plus_2_plot_yselect == 'A'){
                  p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr1, linetype='dotted', size=0.2)
                }else if(input$Integrate_data1_plus_2_plot_yselect == 'B'){
                  p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr2, linetype='dotted', size=0.2)
                }else if(input$Integrate_data1_plus_2_plot_yselect == 'C' | input$Integrate_data1_plus_2_plot_yselect == 'D'){
                  p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr1, linetype='dotted', size=0.2)
                  p <- p + geom_hline(yintercept=input$Integrate_data1_plus_2_plot_ythr2, linetype='dotted', size=0.2)
                }
                
                p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% Integrate_outliers$id,], color='blue' , size = input$Integrate_data1_plus_2_highlight_dot_size)
                if(!input$Integrate_data1_plus_2_plot_filter_label){
                  p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% Integrate_outliers$id,],  color = "blue", aes(label = id), size = input$Integrate_data1_plus_2_id_size, max.overlaps=50, segment.size=0.2)   
                }
              } 
              if(input$Integrate_data1_plus_2_target_gene_from_custom_geneset){
                if(input$Integrate_data1_plus_2_target_gene_from_custom_geneset_select != 'None'){
                  genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Integrate_data1_plus_2_target_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                  p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% genes,], color=input$Integrate_data1_plus_2_target_gene_colour , size = input$Integrate_data1_plus_2_highlight_dot_size)
                  if(input$Integrate_data1_plus_2_show_gene_name){
                    p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% genes,],  color = input$Integrate_data1_plus_2_target_gene_colour, aes(label = id), size = input$Integrate_data1_plus_2_id_size, max.overlaps=20, segment.size=0.2) 
                  }
                }
              }else{
                if(nchar(input$Integrate_data1_plus_2_target_gene) != 0){
                  p <- p + geom_point(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$Integrate_data1_plus_2_target_gene, split = "\n")),], color=input$Integrate_data1_plus_2_target_gene_colour , size = input$Integrate_data1_plus_2_highlight_dot_size)
                  if(input$Integrate_data1_plus_2_show_gene_name){
                    p <- p + geom_text_repel(data = df_main_plot[df_main_plot$id %in% unlist(strsplit(input$Integrate_data1_plus_2_target_gene, split = "\n")),],  color = input$Integrate_data1_plus_2_target_gene_colour, aes(label = id), size = input$Integrate_data1_plus_2_id_size, max.overlaps=20, segment.size=0.2) 
                  }
                }
              }
              p <- p + theme(legend.text = element_text(size = 4), legend.title = element_text(size = 4) ) + guides(color = guide_colourbar(barwidth = 0.5, barheight = 2)) 
              p <- p + theme(axis.text.y = element_text(size = input$Integrate_data1_plus_2_XY_label_size), axis.text.x = element_text(size = input$Integrate_data1_plus_2_XY_label_size))
              p <- p + theme(axis.title.y = element_text(size = input$Integrate_data1_plus_2_XY_title_size), axis.title.x = element_text(size = input$Integrate_data1_plus_2_XY_title_size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(legend.key.size = unit(0.2, "mm"))
              if(input$Integrate_data1_plus_2_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              p
            }, width=reactive(input$Integrate_data1_plus_2_fig.width), height=reactive(input$Integrate_data1_plus_2_fig.height), res=300)

        # display the filtered genes
          output$Integrate_data1_plus_2_filtered_status <- renderText({
            "Please set the Data1 and Data2, and set X and Y on the left."
          })
          output$Integrate_data1_plus_2_filtered <- renderDataTable({
            if(length(Integrate_data1_plus_2_plot_filtered())==0){
              output$Integrate_data1_plus_2_filtered_status <- renderText({ "The genes passed the filtering will be shown here."})
            }else if(is.null(Integrate_data1_plus_2_plot_filtered()) | dim(Integrate_data1_plus_2_plot_filtered())[1] == 0){
              output$Integrate_data1_plus_2_filtered_status <- renderText({ "The genes passed the filtering will be shown here."})
            }else{
              output$Integrate_data1_plus_2_filtered_status <- renderText({NULL})
            }
            datatable( data.frame(Integrate_data1_plus_2_plot_filtered()), options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10))
          })

        # download the table
          output$Integrate_data1_plus_2_filtered_download <- downloadHandler(
            filename = function(){"Integrate_data1_data2_filtered.tsv"}, 
            content = function(fname){ write.table(Integrate_data1_plus_2_plot_filtered(), fname, sep='\t', row.names=F, quote=F) }
          )

        # list up the gene names
          output$Integrate_data1_plus_2_filtered_gene_list <- renderText({
            if(is.null(Integrate_data1_plus_2_plot_filtered())){
              return(NULL)
            }
            paste(na.omit(Integrate_data1_plus_2_plot_filtered()$id), collapse = "\n")
          })

        # display the selected area
          output$Integrate_data1_plus_2_selected <- renderDataTable({
            res <- brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush, 
              xvar = input$Integrate_data1_plus_2_Scat.X, yvar = input$Integrate_data1_plus_2_Scat.Y) 
            datatable( data.frame(res), options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10))
          })

        # download the table
          output$Integrate_data1_plus_2_selected_download <- downloadHandler(
            filename = function(){"Integrate_data1_data2.tsv"}, 
            content = function(fname){ write.table(brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush, 
              xvar = input$Integrate_data1_plus_2_Scat.X, yvar = input$Integrate_data1_plus_2_Scat.Y), fname, sep='\t', row.names=F, quote=F) }
          )

        # list up the gene names
          output$Integrate_data1_plus_2_selected_gene_list <- renderText({
            if(is.null(data1_plus_data2())){
              return(NULL)
            }
            res <- brushedPoints(data1_plus_data2(), input$Integrate_data1_plus_2_plot_brush ,
              xvar = input$Integrate_data1_plus_2_Scat.X, yvar = input$Integrate_data1_plus_2_Scat.Y) 
            paste(na.omit(res$id), collapse = "\n")
          })
        
        #
      #####
    ####
  ###

  ### scRNA ########################################################################################
    #### data selection
      output$scRNA_data_select <- renderUI({ selectInput('scRNA_data_select', 'Select a scRNA data', c('None'='None', Dataset()[Dataset()$Data.Class == 'C',]$Dataset)) })
      outputOptions(output, "scRNA_data_select", suspendWhenHidden=FALSE)
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
          output$scRNA_UMAP1_status <- renderText({"A Umap plot of the selected dataset will be shown here."})
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
        outputOptions(output, "scRNA_UMAP1_groupBy", suspendWhenHidden=FALSE)

      # when highlighting a specific group
        output$scRNA_UMAP1_highlight_group_select <- renderUI({
          if(!is.null(Seurat_obj())){
            if(!is.null(input$scRNA_UMAP1_highlight_group)){
              if(input$scRNA_UMAP1_groupBy != 'None'){
                if( length(unique(Seurat_obj()@meta.data[,input$scRNA_UMAP1_groupBy])) > 60 ){
                  selectInput('scRNA_UMAP1_highlight_group_select', 'Select the highlighted group:', c('None'='None') )
                }else{
                  meta <- Seurat_obj()@meta.data
                  groups <- as.character(meta[,input$scRNA_UMAP1_groupBy])
                  suppressWarnings({
                    groups_vals <- as.numeric(groups)
                  })
                  if(all(!is.na(groups_vals))){
                    groups <- sort(unique(groups_vals))
                  }else{
                    groups <- sort(unique(groups))
                  }
                  
                  selectInput('scRNA_UMAP1_highlight_group_select', 'Select the highlighted group:', c('None'='None', groups) )
                }
              }else{
                selectInput('scRNA_UMAP1_highlight_group_select', 'Select the highlighted group:', c('None'='None') )
              }
            }else{
              return(NULL)
            }
          }else{
            return(NULL)
          }
        })
        outputOptions(output, "scRNA_UMAP1_highlight_group_select", suspendWhenHidden=FALSE)


      # draw a umap
      output$scRNA_UMAP1 <- renderPlot({
        if(is.null(input$scRNA_UMAP1_groupBy) || input$scRNA_UMAP1_groupBy == 'None'){
          output$scRNA_UMAP1_status <- renderText({"Please choose one from the 'Colour by' options."})
          return(ggplot())
        }else{
          # if there are too many categories in the selected group
          if( length(unique(Seurat_obj()@meta.data[,input$scRNA_UMAP1_groupBy])) > 60 ){
            output$scRNA_UMAP1_status <- renderText({"Too many categories in the selected group. Please select another group."})
            output$scRNA_UMAP1_groupBy_status <- renderText({"Too many categories in the selected group. Please select another group."})
            return(ggplot())
          }
          #
          output$scRNA_UMAP1_groupBy_status <- renderText({NULL}) 
          output$scRNA_UMAP1_status <- renderText({NULL})
          p_tmp <- DimPlot(Seurat_obj(),reduction = "umap",group.by = c(input$scRNA_UMAP1_groupBy))
          if(input$scRNA_UMAP1_highlight_group){
            p_tmp_data <- p_tmp$data
            p_tmp_data$col <- ifelse(p_tmp_data[,colnames(p_tmp_data)[3]] == input$scRNA_UMAP1_highlight_group_select, input$scRNA_UMAP1_highlight_group_highlight, input$scRNA_UMAP1_highlight_group_background)
            p1 <- ggplot(p_tmp_data, aes_string(x=colnames(p_tmp_data)[1], y=colnames(p_tmp_data)[2]))
            p1 <- p1 + geom_point(size=input$scRNA_umap1_graph_dot_size, aes(color=col), data=p_tmp_data[p_tmp_data$col == input$scRNA_UMAP1_highlight_group_background,])
            p1 <- p1 + geom_point(size=input$scRNA_umap1_graph_dot_size, aes(color=col), data=p_tmp_data[p_tmp_data$col == input$scRNA_UMAP1_highlight_group_highlight,]) + scale_color_identity()
            p1 <- p1 + ggtitle(paste0(input$scRNA_UMAP1_groupBy, ' – ', input$scRNA_UMAP1_highlight_group_select))
          }else{
            p1 <- ggplot(p_tmp$data, aes_string(x=colnames(p_tmp$data)[1], y=colnames(p_tmp$data)[2], color=colnames(p_tmp$data)[3])) + geom_point(size=input$scRNA_umap1_graph_dot_size)
          }
          p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap1_XY_label), axis.title = element_text(size=input$scRNA_umap1_XY_title))
          p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap1_legend_size), legend.title = element_text(size=input$scRNA_umap1_legend_size))
          p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap1_graph_title)) 
          p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          p1 <- p1 + theme(legend.key.size=unit(0.01, 'mm'))
          if(input$scRNA_umap1_white_background){
            p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
            p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p1
        }
      }, width=reactive(input$scRNA_umap1_fig.width), height=reactive(input$scRNA_umap1_fig.height), res=300)



    #### Feature plot
      # function for showing one gene's expression
        gene_expression_map <- function(ex, umap, gene){
          if(gene %in% rownames(ex)){
            ex_gene <- ex[gene,]
            gene_ex_data <- data.frame(umap, ex_gene)
            colnames(gene_ex_data) <- c("UMAP_1","UMAP_2","Gene" )
            p1 <- ggplot(gene_ex_data,aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=gene_ex_data[gene_ex_data$Gene == 0,] , size = input$scRNA_umap2_dot_size_bg, color= input$scRNA_umap2_zero_colour)
            p1 <- p1 + geom_point(data=gene_ex_data[gene_ex_data$Gene > 0,] , size = input$scRNA_umap2_dot_size, aes(color= Gene))
            p1 <- p1 + scale_color_gradient(low  = input$scRNA_umap2_lowest_colour, high = input$scRNA_umap2_highest_colour)
            p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap2_XY_label.font.size), axis.title = element_text(size=input$scRNA_umap2_XY_title.font.size))
            p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap2_legend_size), legend.title = element_text(size=input$scRNA_umap2_legend_size))
            p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap2_graph.title.font.size)) 
            p1 <- p1 + ggtitle(gene)
            p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
            p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p1 <- p1 + theme(legend.key.size = unit(2, "mm"))
            if(input$scRNA_umap2_while_background){
              p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
              p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
              p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            }
          }else{
            p1 <- gene_expression_map_noGene(ex, umap)
          }
          p1
        }

      # when selecting from custom genesets
        output$scRNA_UMAP2_gene_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c()
              gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
              selectInput('scRNA_UMAP2_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
        outputOptions(output, "scRNA_UMAP2_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # input gene talbe
        target_gene_for_scRNA_featurePlot <- reactive({
          if(!is.null(Seurat_obj())){
            if(input$scRNA_UMAP2_gene_from_custom_geneset){
              if(input$scRNA_UMAP2_gene_from_custom_geneset_select == 'None'){
                output$scRNA_UMAP2_gene_input_status <- renderText({"Please select a custom gene set."})
                return(NULL)
              }else{
                output$scRNA_UMAP2_gene_input_status <- renderText({NULL})
                genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$scRNA_UMAP2_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
              }
            }else{
              if(nchar(input$scRNA_UMAP2_gene) >0){
                output$scRNA_UMAP2_gene_input_status <- renderText({NULL})
                genes <- unique(unlist(strsplit(input$scRNA_UMAP2_gene, split = "\n")))
              }else{
                output$scRNA_UMAP2_gene_input_status <- renderText({'Please enter the gene names.'})
                return(NULL)
              }
            }
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
            data.frame(Genes=genes2)
          }else{
            return(NULL)
          }

        })

      # show as a table
        output$scRNA_UMAP2_gene_table <- renderDataTable({
          if(is.null(target_gene_for_scRNA_featurePlot())){
            tmp <- data.frame('Genes'=character(0), stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
          }else{
            datatable( target_gene_for_scRNA_featurePlot(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
          }
        })

      # draw UMAP2 (gene expression feature map)
        output$scRNA_UMAP2 <- renderPlot({
          if(!is.null(Seurat_obj())){
            if(is.null(target_gene_for_scRNA_featurePlot()) ){
              output$Feature_Plot_status_catch <- renderText({'A feature plot will be displayed here'})
              return(ggplot())
            }else{
              if(length(input$scRNA_UMAP2_gene_table_rows_selected)>0){
                output$Feature_Plot_status_catch <- renderText({NULL})
                gene <- target_gene_for_scRNA_featurePlot()[input$scRNA_UMAP2_gene_table_rows_selected,]
                p <- gene_expression_map(Seurat_expression(), Seurat_umap(), gene )    
                p
              }else{
                output$Feature_Plot_status_catch <- renderText({'Please select a gene'})
                return(ggplot())
              }
            }
          }else{
            output$scRNA_UMAP2_gene_input_status <- renderText({'Please select a database and set the input'})
            output$Feature_Plot_status_catch <- renderText({'A feature plot will be displayed here'})
            return(ggplot())
          }
        }, width=reactive(input$scRNA_umap2_fig.width), height=reactive(input$scRNA_umap2_fig.height), res=300)

      #

    #### Feature Plot (gene set)
      # status
        output$scRNA_UMAP2_gene_signature_status <- renderText({'Please set the input and click "Calculate the signature score".\nThe AUC scores of the inputted genes will be calculated, \nand a feature plot will be shown here.'})
        output$scRNA_violin_gene_signature_status <- renderText({'Please set the input and click "Calculate the signature score".\nThe AUC scores of the inputted genes will be calculated, \nand a violin plot will be shown here.'})

      # select a gene set
        output$scRNA_UMAP2_gene_signature_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c()
          gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
          selectInput('scRNA_UMAP2_gene_signature_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "scRNA_UMAP2_gene_signature_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # group by for violin
        output$scRNA_violin_gene_signature_groupby <- renderUI({
          if(!is.null(Seurat_obj())){
            meta <- Seurat_obj()@meta.data
            selectInput('scRNA_violin_gene_signature_groupby', 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
          }else{
            selectInput('scRNA_violin_gene_signature_groupby', 'Group by:', c('None'='None') )
          }
        })
        outputOptions(output, "scRNA_violin_gene_signature_groupby",  suspendWhenHidden=FALSE)

      # calculate the AUC score
        umap_AUC <- reactiveVal({NULL})
        violin_AUC <- reactiveVal({NULL})
        isCalculating <- reactiveVal(FALSE) 
        triggered <- reactiveVal(FALSE)
        observeEvent(input$scRNA_UMAP2_gene_signature_start, {
          isCalculating(TRUE)   # 計算中フラグを立てる
          triggered(TRUE) # トリガーを立てる      
          if(!is.null(Seurat_obj())) {
            # gene from custom geneset
            if(input$scRNA_UMAP2_gene_signature_from_custom_geneset){
              if(input$scRNA_UMAP2_gene_signature_from_custom_geneset_select == 'None'){
                show_alert(title='Error.',text='Please select a custom gene set.', type='error')
                output$scRNA_UMAP2_gene_signature_status <- renderText({"Please select a custom gene set."})
                output$scRNA_violin_gene_signature_status <- renderText({'Please select a custom gene set.'})
                umap_AUC(NULL)
                violin_AUC(NULL)
                isCalculating(FALSE)
                return()
              }else{
                genesets <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$scRNA_UMAP2_gene_signature_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
              }
            }else{
              # gene from input
              if(nchar(input$scRNA_UMAP2_gene_signature) == 0){
                show_alert(title='Error.',text='Please enter genes.', type='error')
                output$scRNA_UMAP2_gene_signature_status <- renderText({'Please enter genes (line by line)'})
                output$scRNA_violin_gene_signature_status <- renderText({'Please enter genes (line by line)'})
                umap_AUC(NULL)
                violin_AUC(NULL)
                isCalculating(FALSE)
                return()
              }else{
                genesets <- unlist(strsplit(input$scRNA_UMAP2_gene_signature, split = "\n"))
              }
            }
            # check if the genes are included in the dataset
            if(length( intersect(rownames(Seurat_obj()), genesets)) == 0 ){
              show_alert(title='Error.',text='None of the inputted genes are included in the dataset.', type='error')
              output$scRNA_UMAP2_gene_signature_status <- renderText({'None of the inputted genes are included in the dataset.'})
              output$scRNA_violin_gene_signature_status <- renderText({'None of the inputted genes are included in the dataset.'})
              umap_AUC(NULL)
              violin_AUC(NULL)
              isCalculating(FALSE)
              return()
            }
            # calculate the AUC
            output$scRNA_UMAP2_gene_signature_status <- renderText({'Calculating the AUC scores of the inputted genes. \nThis may take a while.'})
            output$scRNA_violin_gene_signature_status <- renderText({'Calculating the AUC scores of the inputted genes. \nThis may take a while.'})
            Seurat_obj <- Seurat_obj()
            GS <- list('Custom'=genesets)
            expr_matrix <- as(Seurat_expression(), "dgCMatrix")  
            cells_AUC <- AUCell_run(expr_matrix, GS)
            cells_AUC_df <- data.frame(t(getAUC(cells_AUC))) 
            cells_AUC_df$barcode <- as.character(rownames(cells_AUC_df))
            Seurat_umap <- Seurat_umap()
            Seurat_umap$barcode <- rownames(Seurat_umap)
            umap_AUC <- merge(Seurat_umap, cells_AUC_df, by='barcode')
            colnames(umap_AUC) <- c("barcode","UMAP_1", "UMAP_2","AUC.score" )
            umap_AUC(umap_AUC)
            meta <- Seurat_obj@meta.data
            meta$barcode <- as.character(rownames(meta)) # head(meta)
            barocde_order <- rownames(meta)  # head(barocde_order)
            meta <- merge(meta, cells_AUC_df, by='barcode')# head(meta)
            violin_AUC(meta)
            isCalculating(FALSE)
            output$scRNA_UMAP2_gene_signature_status <- renderText({NULL})
            output$scRNA_violin_gene_signature_status <- renderText({NULL})
            return()
          }else{
            show_alert(title='Error.',text='Please set the dataset.', type='error')
            output$scRNA_UMAP2_gene_signature_status <- renderText({'Please set the input and click "Calculate the signature score".\nThe AUC scores of the inputted genes will be calculated, \nand a feature plot will be shown here.'})
            output$scRNA_violin_gene_signature_status <- renderText({'Please set the input and click "Calculate the signature score".\nThe AUC scores of the inputted genes will be calculated, \nand a violin plot will be shown here.'})
            umap_AUC(NULL)
            violin_AUC(NULL)
            isCalculating(FALSE)
            return()
          }
        })


      # Feature plot
        output$scRNA_UMAP2_gene_signature_plot <- renderPlot({
          if (!triggered()) {
            return(ggplot())
          }else{
            if (isCalculating()) {
              while(TRUE){
                # display a spinner while calculating
                ggplot()
              }
            }else{
              if(is.null(umap_AUC())){
                ggplot()
              }else{
                output$scRNA_UMAP2_gene_signature_status <- renderText({NULL})
                output$scRNA_violin_gene_signature_status <- renderText({NULL})
                p1 <- ggplot(umap_AUC(),aes(x=UMAP_1,y=UMAP_2)) + geom_point(data=umap_AUC()[umap_AUC()$AUC.score == 0,] , size = input$scRNA_umap2_gene_signature_dot_size_bg, color= input$scRNA_umap2_gene_signature_zero_colour)
                p1 <- p1 + geom_point(data=umap_AUC()[umap_AUC()$AUC.score > 0,] , size = input$scRNA_umap2_gene_signature_dot_size, aes(color= AUC.score))
                p1 <- p1 + scale_color_gradient(low  = input$scRNA_umap2_gene_signature_lowest_colour, high = input$scRNA_umap2_gene_signature_highest_colour)
                p1 <- p1 + theme(axis.text = element_text(size=input$scRNA_umap2_gene_signature_XY_label.font.size), axis.title = element_text(size=input$scRNA_umap2_gene_signature_XY_title.font.size))
                p1 <- p1 + theme(legend.text = element_text(size=input$scRNA_umap2_gene_signature_legend_size), legend.title = element_text(size=input$scRNA_umap2_gene_signature_legend_size))
                p1 <- p1 + theme(plot.title = element_text(size=input$scRNA_umap2_gene_signature_graph.title.font.size)) 
                p1 <- p1 + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                p1 <- p1 + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                p1 <- p1 + theme(legend.key.size = unit(2, "mm"))
                # p1 <- p1 + ggtitle(gene)
                if(input$scRNA_umap2_gene_signature_while_background){
                  p1 <- p1 + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                  p1 <- p1 + theme(panel.background = element_rect(fill="white", size=0))
                  p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                }
                p1
              }
            }
          }
        },width=reactive(input$scRNA_umap2_gene_signature_fig.width), height=reactive(input$scRNA_umap2_gene_signature_fig.height), res=300)
        
      # violin plot
        # group select
        output$scRNA_violin_gene_signature_select_group_table <- renderDataTable({
          if(input$scRNA_violin_gene_signature_groupby == 'None'){
            tmp <- data.frame('Group name'=character(0), stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE))   
          }else{
            tmp0 <- unique(Seurat_obj()@meta.data[,input$scRNA_violin_gene_signature_groupby])
            tmp0 <- tmp0[order(tmp0)]
            tmp <- data.frame('Group name'=tmp0, stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE))   
          }
        })
        
        # plot
        output$scRNA_violin_gene_signature_plot <- renderPlot({
          if (!triggered()) {
            return(ggplot())
          }else{
            if (isCalculating()) {
              while(TRUE){
                # display a spinner while calculating
                ggplot()
              }
            }else{
              if(is.null(violin_AUC())){
                ggplot()
              }else{
                if(input$scRNA_violin_gene_signature_groupby == 'None'){
                  output$scRNA_violin_gene_signature_status <- renderText({'Please select one from the "Group by" option.'})
                  ggplot()
                }else{
                  # when there are too many categories in the selected group
                  if(length(unique(violin_AUC()[,input$scRNA_violin_gene_signature_groupby])) > 60){
                    output$scRNA_violin_gene_signature_status <- renderText({'Too many categories in the selected group. \nPlease re-select a group.'})
                    ggplot()
                  }else{
                    meta <- violin_AUC()
                    if(input$scRNA_violin_gene_signature_select_group){
                      if(length(input$scRNA_violin_gene_signature_select_group_table_rows_selected) == 0){
                        meta <- violin_AUC()  
                      }else{
                        tmp0 <- unique(Seurat_obj()@meta.data[,input$scRNA_violin_gene_signature_groupby])
                        tmp0 <- tmp0[order(tmp0)]
                        tmp <- data.frame('Group name'=tmp0, stringsAsFactors = FALSE)
                        meta <- violin_AUC()[violin_AUC()[,input$scRNA_violin_gene_signature_groupby] %in% tmp[input$scRNA_violin_gene_signature_select_group_table_rows_selected,],]
                      }
                    }
                    p <- ggplot(meta, aes_string(x=input$scRNA_violin_gene_signature_groupby, y='Custom', fill=input$scRNA_violin_gene_signature_groupby)) + geom_violin(trim = FALSE, size=0.2)
                    if(!(input$scRNA_violin_gene_signature_hide_jitter)){
                      p <- p +  geom_jitter(width=0.2, height=0, size=0.05)
                    }
                    p <- p + theme(axis.text = element_text(size=input$scRNA_violin_gene_signature_XY_label.font.size), axis.title = element_text(size=input$scRNA_violin_gene_signature_XY_title.font.size))
                    p <- p + theme(legend.text = element_text(size=input$scRNA_violin_gene_signature_legend_size), legend.title = element_text(size=input$scRNA_violin_gene_signature_legend_size))
                    p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
                    p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
                    p <- p + theme(legend.key.size=unit(0.8, 'mm'))
                    if(input$scRNA_violin_gene_signature_while_background){
                      p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                      p <- p + theme(panel.background = element_rect(fill="white", size=0))
                      p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
                    }
                    if(input$scRNA_violin_gene_signature_rotate_x){
                      p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
                    }
                    p
                  }
                }
              }
            }
          } 
        },width=reactive(input$scRNA_violin_gene_signature_fig.width), height=reactive(input$scRNA_violin_gene_signature_fig.height), res=300)

    #### Vlnplot
      # select group.by
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

      # status message
        output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({"Choose a scRNA data and set the input genes."})
        output$scRNA_VlnPlot_vln_inputsetting2 <- renderText({
          if (input$scRNA_VlnPlot_groupBy == 'None') {
            "Choose a group to compare the gene expressions."
          } else {
            NULL
          }
        })
        output$scRNA_VlnPlot_vln_status <- renderText({"A violin plot will be shown here. Select a scRNA data, set the input and choose a gene on the left."})


      # when selecting genes from custom gene sets
        output$scRNA_VlnPlot_gene_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
          selectInput('scRNA_VlnPlot_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "scRNA_VlnPlot_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # input genes and the group
        scRNA_VlnPlot_input_gene <- reactive({
          if(is.null(Seurat_obj())){
            return(NULL)
          }else{
            if(input$scRNA_VlnPlot_gene_from_custom_geneset){
              if(input$scRNA_VlnPlot_gene_from_custom_geneset_select == 'None'){
                output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({"Please select a custom geneset."})
                return(NULL)
              }else{
                output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({NULL})
                gene_features <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$scRNA_VlnPlot_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
              }
            }else{
              if(nchar(input$scRNA_VlnPlot_gene)==0){
                output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({"Please enter genes (line by line)."})
                return(NULL)
              }else{
                gene_features <- unique(unlist(strsplit(input$scRNA_VlnPlot_gene, split = "\n")))
              }
            }
            diff_gene <- setdiff(gene_features,rownames(Seurat_obj()))
            gene_features2 <- intersect(gene_features, rownames(Seurat_obj()))
            if(length(diff_gene) > 0){
              output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({
                tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                genes_tmp <- ''
                for (a in diff_gene){
                  genes_tmp <- paste0(genes_tmp, a, ',')
                }
                genes_tmp <- substr(genes_tmp, 1, nchar(genes_tmp)-1)
                paste0(tmp, genes_tmp)
              })
            }else{
              output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({NULL})
            }

            if(length(gene_features) == 0){
              output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({'None of the inputted genes are included in the dataset.'})
              return(NULL)
            }else{
              # output$scRNA_VlnPlot_vln_inputsetting1 <- renderText({NULL})
              return(data.frame(Genes=gene_features))
            }
          }
        })

      # input gene table
        output$scRNA_vln_vln_gene_table <- renderDataTable({
          if(is.null(scRNA_VlnPlot_input_gene())){
            tmp <- data.frame('Genes'=character(0), stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))   
          }else{
            datatable( scRNA_VlnPlot_input_gene(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
          }
        })

      # select the groups
        output$scRNA_VlnPlot_vln_select_group_table <- renderDataTable({
          if(input$scRNA_VlnPlot_groupBy == 'None'){
            tmp <- data.frame('Group name'=character(0), stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE))   
          }else{
            tmp0 <- unique(Seurat_obj()@meta.data[,input$scRNA_VlnPlot_groupBy])
            tmp0 <- tmp0[order(tmp0)]
            tmp <- data.frame('Group name'=tmp0, stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, scrollY=TRUE))   
          }
        })

      # plot vlnplot
        output$scRNA_VlnPlot_vln <- renderPlot({
          if(is.null(Seurat_obj())){
            output$scRNA_VlnPlot_vln_status <- renderText({"A violin plot will be shown here. Select a scRNA data, set the input and choose a gene on the left."})
            return(ggplot())
          }else if(is.null(scRNA_VlnPlot_input_gene)){
            output$scRNA_VlnPlot_vln_status <- renderText({"A violin plot will be shown here. Select a scRNA data, set the input and choose a gene on the left."})
            return(ggplot())
          }else if(input$scRNA_VlnPlot_groupBy == 'None'){
            output$scRNA_VlnPlot_vln_status <- renderText({"A violin plot will be shown here. Select a scRNA data, set the input and choose a gene on the left."})
            return(ggplot())
          }
          # if the groups are too many, stop
          if(length(unique(Seurat_obj()@meta.data[,input$scRNA_VlnPlot_groupBy] )) > 60 ){
            output$scRNA_VlnPlot_vln_status <- renderText({"There are too many categories in the group. Please re-select a group from the table on the left."})
            return(ggplot())
          }

          seurat_obj_tmp <- Seurat_obj()
          if(length(input$scRNA_vln_vln_gene_table_rows_selected) == 0){
            output$scRNA_VlnPlot_vln_status <- renderText({"Please select a gene from the table on the left."})
            return(ggplot())
          }
          # gene select
          Gene <- scRNA_VlnPlot_input_gene()[input$scRNA_vln_vln_gene_table_rows_selected,]
          One_Gene_ex <- data.frame((Seurat_expression()[Gene,]))
          colnames(One_Gene_ex) <- Gene # head(One_Gene_ex)
          One_Gene_ex$barcode <- rownames(One_Gene_ex)
          meta <- seurat_obj_tmp@meta.data # head(meta)
          meta$barcode <- rownames(meta)
          meta <- merge(meta, One_Gene_ex, by='barcode')
          if(input$scRNA_VlnPlot_vln_select_group){
            if(length(input$scRNA_VlnPlot_vln_select_group_table_rows_selected) == 0){
              meta <- meta  
            }else{
              tmp0 <- unique(Seurat_obj()@meta.data[,input$scRNA_VlnPlot_groupBy])
              tmp0 <- tmp0[order(tmp0)]
              tmp <- data.frame('Group name'=tmp0, stringsAsFactors = FALSE)
              meta <- meta[meta[,input$scRNA_VlnPlot_groupBy] %in% tmp[input$scRNA_VlnPlot_vln_select_group_table_rows_selected,],]
            }
          }
          # plot
          p <- ggplot(meta, aes_string(x=input$scRNA_VlnPlot_groupBy, y=Gene, fill=input$scRNA_VlnPlot_groupBy))+ geom_violin(trim = FALSE, size=0.2)
          if(!(input$scRNA_vln_vln_hide_jitter)){
            p <- p +  geom_jitter(width=0.2, height=0, size=0.05)
          }
          p <- p + theme(legend.text=element_text(size=input$scRNA_vln_vln_legend_size), legend.title=element_text(size=input$scRNA_vln_vln_legend_size))
          p <- p + theme(axis.text.x = element_text(size=input$scRNA_vln_vln_X_label_size), axis.text.y = element_text(size=input$scRNA_vln_vln_Y_label_size))
          p <- p + theme(axis.title = element_text(size=input$scRNA_vln_vln_Y_title_size))
          p <- p + xlab(input$scRNA_VlnPlot_groupBy) + scale_y_continuous(limits = c(0, NA))
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          p <- p + theme(legend.key.size = unit(1.5, "mm"))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          if(input$scRNA_vln_vln_white_back){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          if(input$scRNA_vln_vln_rotate_x){
            p <- p + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
          }
          output$scRNA_VlnPlot_vln_status <- renderText({NULL})
          ylim1 <- ifelse(is.numeric(input$scRNA_vln_vln_ylim_min), input$scRNA_vln_vln_ylim_min, NA)
          ylim2 <- ifelse(is.numeric(input$scRNA_vln_vln_ylim_max), input$scRNA_vln_vln_ylim_max, NA)
          p <- p + coord_cartesian( ylim=c(ylim1, ylim2))
          p
        }, width=reactive(input$scRNA_vln_vln_fig.width), height=reactive(input$scRNA_vln_vln_fig.height), res=300)
      

      #
    #### Dot plot
      # select grou.by
        output$scRNA_DotPlot_groupBy <- renderUI({
          if(length(input$scRNA_data_select) != 0){
            if(input$scRNA_data_select != 'None'){
              if(!is.null(Seurat_obj())){
                meta <- Seurat_obj()@meta.data
                selectInput('scRNA_DotPlot_groupBy', 'Group by:', c('None'='None', colnames(meta)[!(colnames(meta) %in% c('percent.mt', 'nCount_RNA', 'nFeature_RNA', 'orig.ident'))]), selected = 'seurat_clusters' )
              }else{
                selectInput('scRNA_DotPlot_groupBy', 'Group by:', c('None'='None') )  
              }
            }else{
              selectInput('scRNA_DotPlot_groupBy', 'Group by:', c('None'='None') )
            }
          }
        })
        outputOptions(output, "scRNA_DotPlot_groupBy", suspendWhenHidden=FALSE)

      # when selecting genes from custom gene sets
        output$scRNA_DotPlot_gene_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
              selectInput('scRNA_DotPlot_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
        outputOptions(output, "scRNA_DotPlot_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # Set the input
        output$scRNA_DotPlot_dot_status <- renderText({"A dot plot will be shown here. Set the input genes and click the start button."})
        scRNA_DotPlot_input_gene <- reactiveVal({NULL})
        scRNA_DotPlot_groupBy <- reactiveVal({NULL})
        selected_dataset <- reactiveVal({NULL})
        observeEvent(input$scRNA_DotPlot_start, {
          if(is.null(Seurat_obj())){
            show_alert(title='Error.',text='Please select a dataset.', type='error')
            output$scRNA_DotPlot_dot_status <- renderText({"Please select a dataset, set the input and choose the group to compare the gene expressions."})
            return()
          }
          selected_dataset(input$scRNA_data_select)
          # input genes
          if(input$scRNA_DotPlot_gene_from_custom_geneset){
            if(input$scRNA_DotPlot_gene_from_custom_geneset_select == 'None'){
              show_alert(title='Error.',text='Please select a custom geneset.', type='error')
              output$scRNA_DotPlot_dot_status <- renderText({"Please select a custom gene set."})
              return()
            }else{
              gene_features <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$scRNA_DotPlot_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
            }
          }else{
            if(nchar(input$scRNA_DotPlot_gene)==0){
              show_alert(title='Error.',text='Please enter genes.', type='error')
              output$scRNA_DotPlot_dot_status <- renderText({"Please enter genes (line by line)."})
              return(NULL)
            }else{
              gene_features <- unique(unlist(strsplit(input$scRNA_DotPlot_gene, split = "\n")))
            }
          }
          gene_features <- intersect(gene_features, rownames(Seurat_obj()))
          if(length(gene_features) == 0){
            show_alert(title='Error.',text='None of the inputted genes are included in the dataset.', type='error')
            output$scRNA_DotPlot_dot_status <- renderText({'None of the inputted genes are included in the dataset.'})
            return(NULL)
          }else{
            output$scRNA_DotPlot_dot_status <- renderText({NULL})
            scRNA_DotPlot_input_gene(gene_features)
          }
          # set the group
          if(input$scRNA_DotPlot_groupBy == 'None'){
            show_alert(title='Error.',text='Please select a group.', type='error')
            output$scRNA_DotPlot_dot_status <- renderText({'Please select a group.'})
            return(NULL)
          }else{
            output$scRNA_DotPlot_dot_status <- renderText({NULL})
            scRNA_DotPlot_groupBy(input$scRNA_DotPlot_groupBy)
          }
        })

      # plot
        output$scRNA_DotPlot_dot <- renderPlot({
          if(length(input$scRNA_data_select)==0){
            return(ggplot())
          }else if(is.null(Seurat_obj())){
            return(ggplot())
          }else if(is.null(selected_dataset())){
            return(ggplot())
          }else if(selected_dataset() != input$scRNA_data_select){
            return(ggplot())
          }else if(is.null(scRNA_DotPlot_groupBy())){
            return(ggplot())
          }else if(is.null(scRNA_DotPlot_input_gene()) ){
            return(ggplot())
          }else if(scRNA_DotPlot_groupBy() == 'None' ){
            return(ggplot())
          }else if(length(unique(Seurat_obj()@meta.data[,scRNA_DotPlot_groupBy()] )) > 60 ){
            output$scRNA_DotPlot_dot_status <- renderText({"There are too many categories in the group. Please re-select a group from the table on the left."})
            return(ggplot())
          }else{
            output$scRNA_DotPlot_dot_status <- renderText({NULL})
            seurat_obj_tmp <- Seurat_obj()
            seurat_obj_tmp <- SetIdent(seurat_obj_tmp, value = scRNA_DotPlot_groupBy())
            # plot
            p <- DotPlot(seurat_obj_tmp, features = factor(scRNA_DotPlot_input_gene(), levels=scRNA_DotPlot_input_gene()) , dot.scale=input$scRNA_dot_dotScale, cols = c(input$scRNA_dot_low_col, input$scRNA_dot_high_col)) + RotatedAxis()
            p <- p + theme(legend.text=element_text(size=input$scRNA_dot_legend_size), legend.title=element_text(size=input$scRNA_dot_legend_size))
            p <- p + theme(axis.text.x = element_text(size=input$scRNA_dot_X_label_size), axis.text.y = element_text(size=input$scRNA_dot_Y_label_size))
            p <- p + theme(axis.title = element_text(size=input$scRNA_dot_Y_title_size))
            p <- p + ylab(scRNA_DotPlot_groupBy())
            p <- p + xlab(NULL)
            p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p <- p + theme(legend.key.size = unit(1.5, "mm"))
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            p
          }
        }, width=reactive(input$scRNA_dot_fig.width), height=reactive(input$scRNA_dot_fig.height), res=300)
        outputOptions(output, "scRNA_DotPlot_dot", suspendWhenHidden=FALSE)

      #




    #### Fraction of the cells expressing a certain gene
      # choose from custom genesets
        output$scRNA_fraction_Input_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c()
          gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
          selectInput('scRNA_fraction_Input_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "scRNA_fraction_Input_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # input genes
        target_gene_for_scRNA_fraction <- reactive({
          if(!is.null(Seurat_obj())){
            if(input$scRNA_fraction_Input_from_custom_geneset){
              if(input$scRNA_fraction_Input_from_custom_geneset_select == 'None'){
                output$scRNA_fraction_gene_input_status1 <- renderText({"Please select a custom gene set."})
                return(NULL)
              }else{
                output$scRNA_fraction_gene_input_status1 <- renderText({NULL})
                genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$scRNA_fraction_Input_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
              }
            }else{
              if(nchar(input$scRNA_fraction_gene) >0){
                output$scRNA_fraction_gene_input_status1 <- renderText({NULL})
                genes <- unique(unlist(strsplit(input$scRNA_fraction_gene, split = "\n")))
              }else{
                output$scRNA_fraction_gene_input_status1 <- renderText({"Please enter gene names."})
                return(NULL)
              }
            }
            genes2 <- intersect(genes,rownames(Seurat_obj()) ) 
            diff_gene <- setdiff(genes,rownames(Seurat_obj()))
            if(length(diff_gene) > 0){
              output$scRNA_fraction_gene_input_status1 <- renderText({
                tmp <- 'The followings are not detected in this dataset. \nPlease check if the names are correct and do not include unnecessary spaces. \n'
                genes_tmp <- ''
                for (a in diff_gene){
                  genes_tmp <- paste0(genes_tmp, a, ',')
                }
                genes_tmp <- substr(genes_tmp, 1, nchar(genes_tmp)-1)
                paste0(tmp, genes_tmp)
              })
            }else{
              output$scRNA_fraction_gene_input_status1 <- renderText({NULL})
            }
            data.frame(Genes=genes2)
          }else{
            return(NULL)
          }

        })

      # show as a table
        output$scRNA_fraction_gene_table <- renderDataTable({
          if(is.null(target_gene_for_scRNA_fraction())){
            tmp <- data.frame('Genes'=character(0), stringsAsFactors = FALSE)
            datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE))
          }else{
            datatable( target_gene_for_scRNA_fraction(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
          }
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

      # group status
        output$scRNA_fraction_gene_input_status2 <- renderText({
          if(input$scRNA_fraction_groupBy == 'None'){
            "Please select a category for grouping ('Group by')."
          }else{
            NULL
          }
        })    
        output$scRNA_fraction_status <- renderText({NULL})

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
          }else{
            if(length(unique(meta[,input$scRNA_fraction_groupBy])) > 60){
              output$scRNA_fraction_status <- renderText({'There are too many categories in the group. Please re-select a group from the table on the left.'})
              return(NULL)
            }
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
            return(ggplot())
          }
          df_fraction <- fraction_gene_group()
          if(is.null(df_fraction)){
            return(ggplot())
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
      # 
    ####

  ###

  ### igv ##########################################################################################
    # suppressMessages(library(GenomicAlignments))
    # suppressMessages(library(EnrichedHeatmap))
    # suppressMessages(library(rtracklayer))
    # suppressMessages(library(circlize))
    # # suppressMessages(library(Gviz))
    # suppressMessages(library(PWMEnrich.Hsapiens.background))
    # suppressMessages(library(seqLogo))
    # suppressMessages(library(PWMEnrich))
    # suppressMessages(library(BSgenome.Hsapiens.UCSC.hg38))
    # suppressMessages(library(BSgenome.Hsapiens.UCSC.hg19))
    # suppressMessages(library(ggseqlogo))
    # data(PWMLogn.hg19.MotifDb.Hsap)

    #### data selection for IGV
      # data from who
        output$igv_data_DataFrom <- renderUI({  selectInput('igv_data_DataFrom', 'Data from', c('None'='None', Dataset()[Dataset()$Data.Class == input$igv_data_type,]$Data.from)) })
        outputOptions(output, "igv_data_DataFrom", suspendWhenHidden=FALSE)

      # data from which experiment
        output$igv_data_Experiment <- renderUI({  
          tmp <- Dataset()[Dataset()$Data.Class == input$igv_data_type,]
          if(!is.null(input$igv_data_DataFrom) && input$igv_data_DataFrom != 'None'){ tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] }
          selectInput('igv_data_Experiment', 'Experiment', c('None'='None', tmp$Experiment)) 
        })
        outputOptions(output, "igv_data_Experiment", suspendWhenHidden=FALSE)

      # data selection
        # column(12, radioButtons("igv_data_type", "Data type", choices = c('BED' = 'D', 'BAM' = 'E'), selected='D')),
        output$igv_data_select <- renderUI({ 
          tmp <- Dataset()[Dataset()$Data.Class == 'D',]
          if(!is.null(input$igv_data_DataFrom) && input$igv_data_DataFrom != 'None'){ tmp <-tmp[tmp$Data.from == input$igv_data_DataFrom,] }
          if(!is.null(input$igv_data_Experiment) && input$igv_data_Experiment != 'None'){ tmp <-tmp[tmp$Experiment == input$igv_data_Experiment,] }
          selectInput('igv_data_select', 'Select dataset to see in IGV', c('None'='None', tmp$Dataset)) 
        })
        outputOptions(output, "igv_data_select", suspendWhenHidden=FALSE)

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
        tmp <- read.table(path, sep='\t',check.names = FALSE) # head(bed_data)
        colnames(tmp)[1] <- 'chrom'
        colnames(tmp)[2] <- 'start'
        colnames(tmp)[3] <- 'end'
        colnames(tmp)[5] <- 'score'
        return(tmp)
      })
      
    #### start igv
      
      # igv initiation
        output$igv <- renderIgvShiny({
          options <- parseAndValidateGenomeSpec(genomeName=input$igv_gneome_selection)
          igvShiny(options)  # Initialize IGV
        })

      # add bed file to view
        observeEvent(input$igv_data_add, {
          # Track information for the BAM file
          loadBedTrack(session, id="igv", trackName=input$igv_data_select, tbl=bed_data())
          
          # Add the BAM track to the IGV viewer
          # session$sendCustomMessage(type = "addTrack", track)
        })
    #### Profile plots
      # dataset selection
        output$Profile_Plot_sample_selection <- renderUI({ 
          df_tmp <- Dataset()
          df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
          # if(!is.null(input$Data_type)) { if(input$Data_type!='None'){ df_tmp <- df_tmp[df_tmp$Data.type == input$Data_type,]}}
          # if(!is.null(input$Seuqenced_by)) { if(input$Seuqenced_by!='None'){ df_tmp <- df_tmp[df_tmp$Data.from == input$Seuqenced_by,]}}
          # if(!is.null(input$Experiments)) { if(input$Experiments!='None'){ df_tmp <- df_tmp[df_tmp$Experiment == input$Experiments,]}}
          selectInput('Profile_Plot_sample_selection', 'Dataset select', c('None'='None', unique(df_tmp$Dataset)) )
        })

      # Imported samples
        imported_sample <- reactiveVal(NULL) # list of the imported sample names
        imported_bw_data <- reactiveVal(list())

        isCalculating_import <- reactiveVal(FALSE) 
        triggered_import <- reactiveVal(FALSE)

        observeEvent(input$Profile_Plot_sample_import, {
          isCalculating_import(TRUE)
          triggered_import(TRUE) 
          if(input$Profile_Plot_sample_selection == 'None'){
            show_alert(title='Error.',text='Please select a dataset.', type='error')
            output$Profile_Plot_sample_selection_status <- renderText({"Please select a dataset."})
            isCalculating_import(FALSE)
            return()
          }
          if(input$Profile_Plot_sample_selection %in% imported_sample()){
            show_alert(title='Error.',text='The selected dataset is already imported.', type='error')
            output$Profile_Plot_sample_selection_status <- renderText({"The selected dataset is already imported."})
            isCalculating_import(FALSE)
            return()
          }
          path <- Dataset()[Dataset()$Dataset == input$Profile_Plot_sample_selection, ]$Path
          if(!file.exists(path)){
            show_alert(title='Error.',text='The file does not exist.', type='error')
            output$Profile_Plot_sample_selection_status <- renderText({"The file does not exist. Please upload the dataset again."})
            isCalculating_import(FALSE)
            return()
          }
          bw_list <- imported_bw_data()
          bw_list <- append(bw_list, list(import(path))) #  ex. tmp <- import('/home/h023o/ShinyApps/Software/OmicsBridge/00_Expression_data_all/2025/06.24/THP1_LPS.IFNg.0.5h_Rep1.bw')
          # check if the chr names are chrX or X.
          # unique(tmp@seqnames)
          tmp <- imported_sample()
          tmp <- c(tmp , input$Profile_Plot_sample_selection)
          imported_sample(tmp)
          imported_bw_data(bw_list)
          isCalculating_import(FALSE)
          # output$Profile_Plot_sample_selection_status <- renderText({print(length(imported_bw_data()))})
          return()
        })

      # remove selected sample, Profile_Plot_sample_remove
        observeEvent(input$Profile_Plot_sample_remove, {
          if(length(input$Profile_Plot_imported_sample_table_rows_selected) == 0){
            show_alert(title='Error.',text='Please select a sample to remove.', type='error')
            output$Profile_Plot_sample_selection_status <- renderText({"Please select a sample to remove."})
            return()
          }
          isCalculating_import(TRUE)
          triggered_import(TRUE) 
          selected_sample <- imported_sample()[input$Profile_Plot_imported_sample_table_rows_selected]
          bw_list <- imported_bw_data()
          # position index
          delete_index <- which(imported_sample() == selected_sample)
          bw_list <- bw_list[-delete_index]
          tmp <- imported_sample()
          tmp <- tmp[-delete_index]
          imported_bw_data(bw_list)
          imported_sample(tmp)
          isCalculating_import(FALSE)
          return()
        })

      # Table of imported sample
        output$Profile_Plot_imported_sample_table  <- renderDataTable({
          if (!triggered_import()) {
            tmp <- data.frame(list('Sample.Name'=character(0)), stringsAsFactors = FALSE)
            return(datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) )
          }else if (isCalculating_import()) {
            tmp <- data.frame(list('Sample.Name'=character(0)), stringsAsFactors = FALSE)
            return(datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) )
          }else{
            if(is.null(imported_bw_data())){
              tmp <- data.frame(list('SampleName'=character(0)), stringsAsFactors = FALSE)
              datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
            }else{
              tmp <- data.frame(list('SampleName'=imported_sample()), stringsAsFactors = FALSE)
              datatable( tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
            }
          }
        })

      # main calculation
        heatmap_data_list <- reactiveVal(NULL)
        isCalculating <- reactiveVal(FALSE) 
        triggered <- reactiveVal(FALSE)
        observeEvent(input$Profile_Plot_start, {
          isCalculating(TRUE)
          triggered(TRUE) 
          bw_list <- imported_bw_data()

          if(length(bw_list) == 0){
            show_alert(title='Error.',text='Please import datasets first.', type='error')
            output$Profile_Plot_status <- renderText({"Please import datasets first."})
            isCalculating(FALSE)
            return()
          }

          names(bw_list) <- imported_sample()
          # output$Profile_Plot_status <- renderText({print(names(bw_list))})
          if(is.null(bw_list)){
            col_fun(NULL)
            heatmap_data_list(NULL)
            isCalculating(FALSE)
          }
          # positions to explore
          if(nchar(input$Profile_Plot_input_coord) == 0){
            show_alert(title='Error.',text='Please input coordinates.', type='error')
            output$Profile_Plot_status <- renderText({"Please input coordinates."})
            isCalculating(FALSE)
            return()
          }
          # the format should be 'chr:start-end'. and they should be line by line without any spaces.
          # if the text input does not follow the format, it will be ignored.
          
          genome_position <- unlist(strsplit(input$Profile_Plot_input_coord, split = "\n")) 
          # Filter only lines matching 'chr:start-end' format (no spaces)
          genome_position <- genome_position[grepl("^[^\\s:]+:[0-9]+-[0-9]+$", genome_position)] # ex, genome_position=c('chr1:1000-2000', 'chr2:4000-4000')
          if(length(genome_position)==0){
            show_alert(title='Error.',text='Please input coordinates in the format "chr:start-end" (line by line).', type='error')
            output$Profile_Plot_status <- renderText({"Please input coordinates in the format 'chr:start-end' (line by line)."})
            isCalculating(FALSE)
            return()
          }
          # Parse coordinates and exclude if end < start
          parsed_coords <- lapply(genome_position, function(x) {
            parts <- strsplit(x, ":")[[1]]
            chr <- parts[1]
            range <- strsplit(parts[2], "-")[[1]]
            start <- as.numeric(range[1])
            end <- as.numeric(range[2])
            if (!is.na(start) && !is.na(end) && end >= start) {
              list(chr = chr, start = start, end = end)
            } else {
              NULL
            }
          })
          # Remove NULLs (invalid ranges)
          parsed_coords <- Filter(Negate(is.null), parsed_coords)
          if(length(parsed_coords) == 0){
            show_alert(title='Error.',text='Invalid input. Please check the input.', type='error')
            output$Profile_Plot_status <- renderText({"Please check the input. The input should be in the format 'chr:start-end' and the end should be greater than or equal to the start."})
            isCalculating(FALSE)
            return()
          }
          chr_list <- sapply(parsed_coords, function(x) x$chr)
          Start_list <- as.numeric(sapply(parsed_coords, function(x) x$start))
          End_list <- as.numeric(sapply(parsed_coords, function(x) x$end))
          target_coordinates <- GRanges(seqnames=Rle(chr_list), ranges=IRanges(start=Start_list, end=End_list), Group='test')

          # heatmap_data_list <- normalizeToMatrix( bw_list(), target_coordinates, extend = 2000, value_column = "score", mean_mode = "w0", w = 10 )
          heatmap_data_list_tmp <- lapply(bw_list, function(bw_tmp) {
            normalizeToMatrix( bw_tmp, target_coordinates, extend = input$Profile_Plot_extend_length, value_column = "score", mean_mode = "w0", w = 10 )
          })
          if(max(unlist(lapply(heatmap_data_list_tmp, function(x) quantile(x,0.98)))) == 0){
            show_alert(title='Error.',text='The coverage is zero for all the positions. Please check the input coordinates.', type='error')
            output$Profile_Plot_status <- renderText({"The coverage is zero for all the positions. Extending the input coordinates may solve this."})
            heatmap_data_list(NULL)
            isCalculating(FALSE)
            return()
          }
          heatmap_data_list(heatmap_data_list_tmp)
          # output$Profile_Plot_status <- renderText({'test'})
          isCalculating(FALSE)
        })

      # plot
        output$Profile_Plot_Plot <- renderPlot({
          if (!triggered()) {
            return(ggplot())
          }else if (isCalculating()) {
            return(ggplot())
          }else{
            # output$Profile_Plot_status <- renderText({'test5'})
            if(is.null(heatmap_data_list())){
              return(ggplot())
            }else{
              heatmap_data_list <- heatmap_data_list()

              col_fun <- colorRamp2(breaks = c(0, max(unlist(lapply(heatmap_data_list, function(x) quantile(x,0.98))))), colors=c(input$Profile_Plot_min_col, input$Profile_Plot_max_col))

              # grid の新規ページを作成（これがないと描画されない可能性あり）
              grid.newpage()

              # Main heatmap legend (The one on the right)
              coverage_legend <- Legend(
                col_fun = col_fun, title = "Norm.Coverage",
                title_gp = grid::gpar(fontsize=input$Profile_Plot_legend_font_size ),
                labels_gp = grid::gpar(fontsize=input$Profile_Plot_legend_font_size ) ,
                legend_height = grid::unit( (5 + 0.1 * input$Profile_Plot_legend_font_size) , "mm"),
                legend_width = grid::unit(input$Profile_Plot_legend_font_size, 'mm')
              )

              # ヒートマップ作成
              ymax <- max(sapply(heatmap_data_list, function(x) {
                max(colMeans(x, na.rm = TRUE))  # or another summary stat depending on your data
              }))
              top_anno <- HeatmapAnnotation( 
                enriched = anno_enriched(
                  gp = gpar(col = input$Profile_Plot_line_col),
                  pos_line_gp = gpar(lwd=0.5,lty = 2),
                  axis_param = list(
                    gp = grid::gpar(fontsize = input$Profile_Plot_label_size_up)
                  ),
                  ylim = c(0, ymax)
                ),
                show_annotation_name = FALSE,
                height=unit(input$Profile_Plot_top_annot_height , 'cm')
              )
              heatmaps <- lapply(seq_along(heatmap_data_list), function(i) {
                EnrichedHeatmap(
                  heatmap_data_list[[i]], 
                  column_title = names(heatmap_data_list)[i],
                  pos_line_gp = gpar(lwd = 0.5,lty = 2),
                  col = col_fun, use_raster = TRUE,
                  show_heatmap_legend = FALSE, 
                  column_title_gp = grid::gpar(fontsize = input$Profile_Plot_column_font_size),
                  axis_name_gp = grid::gpar(fontsize = input$Profile_Plot_label_size_main),
                  top_annotation = top_anno
                  # border_gp = gpar(lwd=20)
                )
              })
              # output$Profile_Plot_status <- renderText({'test3'})

              # heatmapsが空でないことを確認
              if(length(heatmaps) == 0){
                output$Profile_Plot_status <- renderText({'error'})
                return(ggplot())
              }else{
                # output$Profile_Plot_status <- renderText({NULL})

                # 複数のヒートマップを組み合わせる
                p <- Reduce("+", heatmaps)

                # grid.draw() を使って描画
                draw(
                  p,  annotation_legend_side = "top",  
                  heatmap_legend_list = list(coverage_legend), heatmap_legend_side = "right"
                )
              }
            }
          }
        }, width = reactive(input$Profile_Plot_fig.width), height = reactive(input$Profile_Plot_fig.height), res=300)

      #
    #### Gviz plot
      # library(GenomicRanges)
      # dataset select
        output$Gviz_data_select <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[df_tmp$Data.Class == 'E',]
          selectInput('Gviz_data_select', 'Select a dataset to see in Gviz', c('None'='None', unique(df_tmp$Dataset)) )
        })
        outputOptions(output, "Gviz_data_select", suspendWhenHidden=FALSE)

        # positions
        # Gvis_chr <- reactiveVal({'chr1'})
        # Gvis_start  <- reactiveVal({100000})
        # Gvis_end  <- reactiveVal({200000})
        # observe({
        #   req(input$Gviz_chromosome_pos)
        #   # The foramt is "chrN:start-end". Let's break this to chrN, start, and end.
        #   Gvis_chr(strsplit(input$Gviz_chromosome_pos, ':')[[1]][1])
        #   Gvis_start(as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][1]))
        #   Gvis_end(as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][2]))
        # })


      # Plot
        # change the cyto based on the Gviz_genome_selection. hg38 or hg19
        cyto <- reactive({
          if(input$Gviz_genome_selection == 'hg38'){
            read.table("data/cytoBand_hg38.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
          }else if(input$Gviz_genome_selection == 'hg19'){
            read.table("data/cytoBand_hg19.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
          }else{
            return(NULL)
          }
        })
        
        # output$Gviz_plot <- renderPlot({
        #   gen=input$Gviz_genome_selection

        #   # extact the position from the input (Gviz_chromosome_pos) Gviz_plot_status
        #   if(length(input$Gviz_chromosome_pos)==0 || input$Gviz_chromosome_pos == ''){
        #     output$Gviz_plot_status <- renderText({'Please input the chromosome position in the format "chrN:start-end".'})
        #     return(NULL)
        #   }
        #   output$Gviz_plot_status <- renderText({NULL})
        #   # The foramt is "chrN:start-end". Let's break this to chrN, start, and end.
        #   Gviz_chr <- strsplit(input$Gviz_chromosome_pos, ':')[[1]][1]
        #   Gviz_start <- as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][1])
        #   Gviz_end <- as.numeric(strsplit(strsplit(input$Gviz_chromosome_pos, ':')[[1]][2], '-')[[1]][2])
        #   if(is.na(Gviz_start) || is.na(Gviz_end)){
        #     output$Gviz_plot_status <- renderText({'Please input the chromosome position in the format "chrN:start-end".'})
        #     return(NULL)
        #   }
        #   if(Gviz_start >= Gviz_end){
        #     output$Gviz_plot_status <- renderText({'The start position should be less than the end position.'})
        #     return(NULL)
        #   }
        #   if(!Gviz_chr %in% cyto()$chrom){
        #     output$Gviz_plot_status <- renderText({'The chromosome name is not valid. Please check the chromosome name.'})
        #     return(NULL)
        #   }
        #   output$Gviz_plot_status <- renderText({NULL})
          
        #   names(gen) <- Gviz_chr
        #   chr=Gviz_chr
        #   itrack <- Gviz::IdeogramTrack(genome = gen, chromosome = chr, bands = cyto())
        #   gtrack <- Gviz::GenomeAxisTrack()

        #   # load the selected dataset
        #   # (test)
        #   Datatrak1 <- Gviz::AlignmentsTrack('00_Expression_data_all/2025/07.04/MCF7_E2_Rep1_sort_by_coordinate_dup.bam',showIndels=TRUE, name='MCF7_E2_Rep1', genome=input$Gviz_genome_selection)
        #   # bmt <- Gviz::BiomartGeneRegionTrack(genome = input$Gviz_genome_selection, chromosome = chr,
        #   #                               start = Gviz_start, end = Gviz_end,
        #   #                               filter = list(with_ox_refseq_mrna = TRUE),
        #   #                               stacking = "dense")


        #   # Gviz::plotTracks(list(itrack, gtrack, Datatrak1, bmt ), from = Gviz_start, to = Gviz_end, chromosome=chr)
        #   Gviz::plotTracks(list(itrack, gtrack, Datatrak1 ), from = Gviz_start, to = Gviz_end, chromosome=chr)
        # }, width = reactive(input$Gviz_fig.width), height = reactive(input$Gviz_fig.height), res=300)
      #
    #### Enhancer finder
      # select RNAseq data
        output$Enhancer_Find_data_select_RNAseq <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[df_tmp$Data.Class == 'A',]
          selectInput('Enhancer_Find_data_select_RNAseq', 'Select a RNAseq count dataset', c('None'='None', unique(df_tmp$Dataset)) )
        })
        outputOptions(output, "Enhancer_Find_data_select_RNAseq", suspendWhenHidden=FALSE)

      # select ATACseq data
        output$Enhancer_Find_data_select_ATACseq <- renderUI({
          df_tmp <- Dataset()
          df_tmp <- df_tmp[df_tmp$Data.Class == 'A',]
          selectInput('Enhancer_Find_data_select_ATACseq', 'Select a ATACseq count dataset', c('None'='None', unique(df_tmp$Dataset)) )
        })
        outputOptions(output, "Enhancer_Find_data_select_ATACseq", suspendWhenHidden=FALSE)

      # load RNAseq data
        output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"Please select a dataset."})
        Enhancer_Find_RNAseq_data <- reactiveVal(NULL)
        observeEvent(input$Enhancer_Find_data_select_RNAseq, {
          if(length(input$Enhancer_Find_data_select_RNAseq)==0){
            Enhancer_Find_RNAseq_data(NULL)
            return(NULL)
          }
          if(input$Enhancer_Find_data_select_RNAseq == 'None'){
            output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"Please select a dataset."})
            Enhancer_Find_RNAseq_data(NULL)
            return(NULL)
          }
          path <- Dataset()[Dataset()$Dataset == input$Enhancer_Find_data_select_RNAseq, ]$Path
          if(!file.exists(path)){
            output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"The file does not exist. Please upload the dataset again."})
            Enhancer_Find_RNAseq_data(NULL)
            return(NULL)
          }
          tmp <- read.table(path, header=T, check.names = FALSE)
          output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({
            col_names <- colnames(tmp)
            n <- 3  # break after every 4 elements
            groups <- split(col_names, ceiling(seq_along(col_names) / n))
            paste(sapply(groups, function(x) paste(x, collapse = ", ")), collapse = "\n")
          })
          Enhancer_Find_RNAseq_data(tmp)
          return(NULL)
        })

      # load ATACseq data
        output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"Please select a dataset."})
        Enhancer_Find_ATACseq_data <- reactiveVal(NULL)
        observeEvent(input$Enhancer_Find_data_select_ATACseq, {
          if(length(input$Enhancer_Find_data_select_ATACseq)==0){
            Enhancer_Find_ATACseq_data(NULL)
            return(NULL)
          }
          if(input$Enhancer_Find_data_select_ATACseq == 'None'){
            output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"Please select a dataset."})
            Enhancer_Find_ATACseq_data(NULL)
            return(NULL)
          }
          path <- Dataset()[Dataset()$Dataset == input$Enhancer_Find_data_select_ATACseq, ]$Path
          if(!file.exists(path)){
            output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"The file does not exist. Please upload the dataset again."})
            Enhancer_Find_ATACseq_data(NULL)
            return(NULL)
          }
          tmp <- read.table(path, header=T, check.names = FALSE  )
          # if the selected data is not an ATACseq data: (the value in the tmp$id is not the format of chr:start-end)
          if(!all(grepl("^[^\\s:]+:[0-9]+-[0-9]+$", tmp$id))){
            output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"The selected dataset is not an ATACseq data. \nPlease select a valid ATACseq dataset. \nThe id should be the format of 'chr:start-end'."})
            Enhancer_Find_ATACseq_data(NULL)
            return(NULL)
          }
          # show the colnames
          output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({
            col_names <- colnames(tmp)
            n <- 3  # break after every 4 elements
            groups <- split(col_names, ceiling(seq_along(col_names) / n))
            paste(sapply(groups, function(x) paste(x, collapse = ", ")), collapse = "\n")
          })
          Enhancer_Find_ATACseq_data(tmp)
          return(NULL)
        })
      # when using custom geneset
        output$Enhancer_Find_custom_geneset_select <- renderUI({
          gene_sets_names <- c(Original_geneset_lsit()$Geneset.name)
          selectInput('Enhancer_Find_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "Enhancer_Find_custom_geneset_select",  suspendWhenHidden=FALSE)
      # Calculate the correlated peaks (MAIN part)
        output$Enhancer_Find_table_status <- renderText({"The calculated correlations will be displayed here."})
        output$Enhancer_Find_RNAseq_data_status <- renderText({"The RNAseq data used for the correlation calculation will be shown here."})
        output$Enhancer_Find_ATACseq_data_status <- renderText({"The ATACseq data used for the correlation calculation will be shown here."})
        RNAseq_data_table <- reactiveVal(NULL)
        ATACseq_data_table <- reactiveVal(NULL)
        Enhancer_Find_table_result <- reactiveVal(NULL)
        isCalculating_Enhancer_Find <- reactiveVal(FALSE)
        isTriggered_Enhancer_Find <- reactiveVal(FALSE)
        observeEvent(input$Enhancer_Find_start, {
          isTriggered_Enhancer_Find(TRUE)
          isCalculating_Enhancer_Find(TRUE)
          if(is.null(Enhancer_Find_RNAseq_data()) || is.null(Enhancer_Find_ATACseq_data())){ # when the data is not loaded
            show_alert(title='Error.',text='Please select RNAseq and ATACseq datasets.', type='error')
            output$Enhancer_Find_table_status <- renderText({"Please select RNAseq and ATACseq datasets."})
            output$Enhancer_Find_RNAseq_data_status <- renderText({"Please select RNAseq dataset."})
            output$Enhancer_Find_ATACseq_data_status <- renderText({"Please select ATACseq dataset."})
            RNAseq_data_table(NULL)
            ATACseq_data_table(NULL)  
            Enhancer_Find_table_result(NULL)
            isCalculating_Enhancer_Find(FALSE)
            return(NULL)
          }
          if(input$Enhancer_Find_data_select_RNAseq == 'None' || input$Enhancer_Find_data_select_ATACseq == 'None'){ # when the data is not loaded
            show_alert(title='Error.',text='Please select RNAseq and ATACseq datasets.', type='error')
            output$Enhancer_Find_table_status <- renderText({"Please select RNAseq and ATACseq datasets."})
            output$Enhancer_Find_RNAseq_data_status <- renderText({"Please select RNAseq dataset."})
            output$Enhancer_Find_ATACseq_data_status <- renderText({"Please select ATACseq dataset."})
            RNAseq_data_table(NULL)
            ATACseq_data_table(NULL)  
            Enhancer_Find_table_result(NULL)
            isCalculating_Enhancer_Find(FALSE)
            return(NULL)
          }
          # when no genes are inputted
          if(input$Enhancer_Find_use_custom_geneset){
            if(input$Enhancer_Find_custom_geneset_select == 'None'){
              show_alert(title='Error.',text='Please select a custom geneset.', type='error')
              output$Enhancer_Find_table_status <- renderText({"Please select a custom geneset."})
              output$Enhancer_Find_RNAseq_data_status <- renderText({"Please set the input."})
              output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input."})
              RNAseq_data_table(NULL)
              ATACseq_data_table(NULL)
              Enhancer_Find_table_result(NULL)
              isCalculating_Enhancer_Find(FALSE)
              return(NULL)
            }
            target_genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Enhancer_Find_custom_geneset_select, ]$Genes, split=', ')[[1]]
          }else{
            if(nchar(input$Enhancer_Find_input_gene) == 0){
              show_alert(title='Error.',text='Please input genes.', type='error')
              output$Enhancer_Find_table_status <- renderText({"Please input genes."})
              output$Enhancer_Find_RNAseq_data_status <- renderText({"Please input genes."})
              output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input"})
              RNAseq_data_table(NULL)
              ATACseq_data_table(NULL)
              Enhancer_Find_table_result(NULL)
              isCalculating_Enhancer_Find(FALSE)
              return(NULL)
            }
            target_genes <- unlist(strsplit(input$Enhancer_Find_input_gene, split = "\n")) # ex. target_genes=c('gene1', 'gene2', 'gene3')
          }
          if(length(intersect(target_genes, Enhancer_Find_RNAseq_data()$id)) == 0){ # check the overlap of the inputted gene and the id in the RANseq data
            show_alert(title='Error.',text='The inputted genes are not found in the RNAseq data.', type='error')
            output$Enhancer_Find_table_status <- renderText({"The inputted genes are not found in the RNAseq data."})
            output$Enhancer_Find_RNAseq_data_status <- renderText({"The inputted genes are not found in the RNAseq data."})
            output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input"})
            RNAseq_data_table(NULL)
            ATACseq_data_table(NULL)
            Enhancer_Find_table_result(NULL)
            isCalculating_Enhancer_Find(FALSE)  
            return(NULL)
          }
          # take the samples
          Sample_name_df <- read.csv(text = input$Enhancer_Find_sample_select, header = FALSE)
          RNAseq_sample <- Sample_name_df[,1]
          ATACseq_sample <- Sample_name_df[,2]
          RNAseq_sample_intersect <- intersect(RNAseq_sample, colnames(Enhancer_Find_RNAseq_data()))
          ATACseq_sample_intersect <- intersect(ATACseq_sample, colnames(Enhancer_Find_ATACseq_data()))
          if(length(RNAseq_sample_intersect) <= 2 || length(ATACseq_sample_intersect) <= 2){
            show_alert(title='Error.',text='Please input more than three samples.', type='error')
            output$Enhancer_Find_table_status <- renderText({"Please input more than three samples"})
            output$Enhancer_Find_RNAseq_data_status <- renderText({"Please input more than three samples"})
            output$Enhancer_Find_ATACseq_data_status <- renderText({"Please input more than three samples"})
            RNAseq_data_table(NULL)
            ATACseq_data_table(NULL)
            Enhancer_Find_table_result(NULL)
            isCalculating_Enhancer_Find(FALSE)
            return(NULL)
          }
          RNAseq_sample_diff <- setdiff(RNAseq_sample, RNAseq_sample_intersect)
          ATACseq_sample_diff <- setdiff(ATACseq_sample, ATACseq_sample_intersect)
          if(length(RNAseq_sample_diff) > 0 || length(ATACseq_sample_diff) > 0){
            output$Enhancer_Find_table_status <- renderText({
              msg <- "The following samples are not found in the RNAseq or ATACseq data:\n"
              if(length(RNAseq_sample_diff) > 0){
                msg <- paste0(msg, "RNAseq samples: ", paste(RNAseq_sample_diff, collapse = ", "), "\n")
              }
              if(length(ATACseq_sample_diff) > 0){
                msg <- paste0(msg, "ATACseq samples: ", paste(ATACseq_sample_diff, collapse = ", "))
              }
              return(msg)
            })
          }
          RNAseq_df <- Enhancer_Find_RNAseq_data()[Enhancer_Find_RNAseq_data()$id %in% target_genes, c('id', RNAseq_sample_intersect)]
          ATACseq_df <- Enhancer_Find_ATACseq_data()[, c('id', ATACseq_sample_intersect)]
          RNAseq_data_table(RNAseq_df)
          ATACseq_data_table(ATACseq_df)
          # output$Enhancer_Find_table_status <- renderText({dim(ATACseq_df)})
          # add meta infor to the ATACseq_df. The ATACseq_df$id is set 'chr:start-end'. Split this column into chr, start and end.
          ATACseq_df$id <- as.character(ATACseq_df$id)
          ATACseq_df$chr <- sapply(strsplit(ATACseq_df$id, ":"), function(x) x[1])
          ATACseq_df$start <- as.numeric(sapply(strsplit(ATACseq_df$id, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][1])))
          ATACseq_df$end <- as.numeric(sapply(strsplit(ATACseq_df$id, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][2])))
          ATACseq_df <- ATACseq_df[, c('id', 'chr', 'start', 'end', ATACseq_sample_intersect)]
          # calculate the correlation
          df_cor_tmp <- data.frame(list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
          ATACseq_Peak_all <- c()
          for (each_gene in intersect(target_genes, Enhancer_Find_RNAseq_data()$id)){
            if(each_gene %in% RNAseq_df$id == FALSE){
              next # if the gene is not in the RNAseq data, skip to the next gene
            }
            RNAseq_df_gene <- RNAseq_df[RNAseq_df$id == each_gene, ]
            RNAseq_df_gene <- as.numeric(RNAseq_df_gene[1, RNAseq_sample_intersect]) # remove the id column
            # find the genome position
            if(each_gene %in% Gene_coords_GRch38$gene_name == FALSE){
              next # if the gene is not in the Gene_coords_GRch38, skip to the next gene
            }
            gene_chr_all <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'chr']
            gene_start_all <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'start']
            gene_end_all <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'end']
            if(length(gene_chr_all) == 0 | length(gene_start_all) == 0 | length(gene_end_all) == 0){
              next # if the gene is not in the Gene_coords_GRch38, skip to the next gene
            }
            if(any(is.na(gene_chr_all) | is.na(gene_start_all) | is.na(gene_end_all))){
              next # if the gene is not in the Gene_coords_GRch38, skip to the next gene
            }
            for(i in seq_along(gene_chr_all)){
              # if the gene has multiple positions, take the first one
              gene_chr <- gene_chr_all[i]
              gene_start <- gene_start_all[i]
              gene_end <- gene_end_all[i]
              # if the gene_start is greater than gene_end, swap them
              if(gene_start > gene_end){
                tmp <- gene_start
                gene_start <- gene_end
                gene_end <- tmp
              }
              
              # extract the ATACseq data
              Extend = input$Enhancer_Find_extend_length
              if(input$Enhancer_Find_chr_focus){
                ATACseq_df_tmp <- ATACseq_df[ATACseq_df$chr == gene_chr & ATACseq_df$end >= gene_start-Extend & ATACseq_df$start <= gene_end+Extend, ]
              }
              # Calculate the correlation with RNAseq_df_gene
              if(dim(ATACseq_df_tmp)[1] == 0){
                next # if no ATACseq data is found, skip to the next gene
              }
              ATACseq_Peak_all <- c(ATACseq_Peak_all, ATACseq_df_tmp$id)
              
              for (each_peak in ATACseq_df_tmp$id){
                ATACseq_df_peak <- ATACseq_df_tmp[ATACseq_df_tmp$id == each_peak, ]
                ATACseq_df_peak <- as.numeric(ATACseq_df_peak[1, -c(1,2,3,4 )]) # remove the id, chr, start
                if(length(RNAseq_df_gene) != length(ATACseq_df_peak)){
                  next # if the length of the RNAseq and ATACseq data is not the same
                }
                # tmp <- c(RNAseq_df_gene, ATACseq_df_peak)
                # output$Enhancer_Find_table_status <- renderText({RNAseq_df_gene })
                if(var(RNAseq_df_gene) == 0 || var(ATACseq_df_peak) == 0){
                  next # if the variance is zero, skip to the next peak
                }
                # calculate the correlation. If error, show the error message in Enhancer_Find_table_status
                cor_test <- tryCatch(
                  cor.test(RNAseq_df_gene, ATACseq_df_peak, method = input$Enhancer_Find_calculation_type),
                  error = function(e) {
                    output$Enhancer_Find_table_status <- renderText({paste0("Error in correlation calculation for gene: ", each_gene, " and peak: ", each_peak, ". ", e$message)})
                    next
                  }
                )
                if (!is.null(cor_test)){
                  df_cor_tmp <- rbind(df_cor_tmp, data.frame(Gene=each_gene, Peak=each_peak,  Correlation=cor_test$estimate, P.value=cor_test$p.value,stringsAsFactors = FALSE))
                }
              }

            }

            
          }
          ATACseq_data_table(ATACseq_df[ATACseq_df$id %in% ATACseq_Peak_all, ])
          output$Enhancer_Find_table_status <- renderText({NULL})
          output$Enhancer_Find_RNAseq_data_status <- renderText({NULL})
          output$Enhancer_Find_ATACseq_data_status <- renderText({NULL})
          Enhancer_Find_table_result(df_cor_tmp)
          isCalculating_Enhancer_Find(FALSE)
          return(NULL)          
        })

      # show the RNA/ATACseq table
        # RNAseq_data_table
        output$Enhancer_Find_RNAseq_data_table <- renderDataTable({
          if(is.null(RNAseq_data_table())){
            tmp <- data.frame(list('Gene'=character(0), 'Sample'=character(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE,pageLength=5)))
          }else{
            tmp <- RNAseq_data_table()
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE,pageLength=5)))
          }
        })


        # ATACseq data table
        output$Enhancer_Find_ATACseq_data_table <- renderDataTable({
          if(is.null(ATACseq_data_table())){
            tmp <- data.frame(list('id'=character(0), 'Sample'=character(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE,pageLength=5)))
          }else{
            tmp <- ATACseq_data_table()
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE,pageLength=5)))
          }
        })

      # show the correlation table
        output$Enhancer_Find_table <- renderDataTable({
          if(!isTriggered_Enhancer_Find()) {
            tmp <- data.frame(list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }else if(isCalculating_Enhancer_Find()) {
            tmp <- data.frame(list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }
          if(is.null(Enhancer_Find_table_result())){
            tmp <- data.frame(list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }else{
            tmp <- Enhancer_Find_table_result()
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5)))
          }
        })
        outputOptions(output, "Enhancer_Find_table", suspendWhenHidden=FALSE)
      # Show the list of the correlated peak list
        # gene select
          output$Enhancer_Find_gene_selection <- renderUI({
            if(is.null(Enhancer_Find_table_result())){
              selectInput('Enhancer_Find_gene_selection', 'Select a gene', c('All'))
            }else{
              Enhancer_Find_gene_selection_genes <- c('All', Enhancer_Find_table_result()$Gene)
              selectInput('Enhancer_Find_gene_selection', 'Select a gene', Enhancer_Find_gene_selection_genes)
            }
          })
        # peak show
          output$Enhancer_Find_gene_correlated_peak_list <- renderText({
            if(is.null(Enhancer_Find_table_result())){
              return("Please calculate the correlation first.")
            }
            if(input$Enhancer_Find_gene_selection == 'All'){
              p_thr <- input$Enhancer_Find_show_list_threshold
              tmp <- Enhancer_Find_table_result()[Enhancer_Find_table_result()$P.value < p_thr, ]
              if(dim(tmp)[1] == 0){
                return("No peaks found with the selected threshold.")
              }
              tmp <- tmp[order(tmp$Correlation, decreasing = TRUE), ]
              return(paste(tmp$Peak, collapse = "\n"))
            }else{
              selected_gene <- input$Enhancer_Find_gene_selection
              if(selected_gene %in% Enhancer_Find_table_result()$Gene){
                selected_peaks <- Enhancer_Find_table_result()[Enhancer_Find_table_result()$Gene == selected_gene, ]$Peak
                p_thr <- input$Enhancer_Find_show_list_threshold
                selected_peaks <- selected_peaks[Enhancer_Find_table_result()[Enhancer_Find_table_result()$Gene == selected_gene, ]$P.value < p_thr]
                if(length(selected_peaks) == 0){
                  return("No peaks found with the selected threshold.")
                }
                return(paste(selected_peaks, collapse = "\n"))
              }else{
                return("Please select a gene.")
              }
            }
          })


    #### Motif search
      # defalt message
        output$Motif_analysis_status <- renderText({'Motif scan result will be shown here.'})
        output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})

      # Motif scan
        Motif_scan_result <- reactiveVal(NULL)
        isCalculating_Motif_analysis <- reactiveVal(FALSE)
        isTriggered_Motif_analysis <- reactiveVal(FALSE)

        observeEvent(input$Motif_analysis_start,{
          if(input$Motif_analysis_input_genome_type == 'hg38'){
            genome <- BSgenome.Hsapiens.UCSC.hg38
          }else if(input$Motif_analysis_input_genome_type == 'hg19'){
            genome <- BSgenome.Hsapiens.UCSC.hg19
          }
          isCalculating_Motif_analysis(TRUE)
          isTriggered_Motif_analysis(TRUE)

          # creat the input
          if(input$Motif_analysis_input_type == 'A'){
            if(nchar(input$Motif_analysis_input_peaks) == 0){
              show_alert(title='Error.',text='Please input the peaks in the format of chr:start-end.', type='error')
              output$Motif_analysis_status <- renderText({'Please input the peaks in the format of chr:start-end.'})
              output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})
              isCalculating_Motif_analysis(FALSE)
              return(NULL)
            }
            peaks <- unlist(strsplit(input$Motif_analysis_input_peaks, split = "\n"))
            peaks <- unique(peaks)
            # if the selected data is not an ATACseq data: (the value in the tmp$id is not the format of chr:start-end)
            if(!all(grepl("^[^\\s:]+:[0-9]+-[0-9]+$", peaks))){
              show_alert(title='Error.',text='The input peaks are not in the format of "chr:start-end". Please input the peaks in the correct format.', type='error')
              output$Motif_analysis_status <- renderText({ "The input peaks are not in the format of 'chr:start-end'. Please input the peaks in the correct format." })
              output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})
              isCalculating_Motif_analysis(FALSE)
              return(NULL)
            } 
            chromosome <- sapply(strsplit(peaks, ":"), function(x) x[1])
            start <- as.numeric(sapply(strsplit(peaks, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][1])))
            end <- as.numeric(sapply(strsplit(peaks, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][2])))
            seq_region <- getSeq(genome, names=chromosome, start=start, end=end)
            seq_region_clean <- seq_region[grepl("^[ACGT]+$", as.character(seq_region))]
            seq_region_with_non_acgt <- seq_region[!grepl("^[ACGT]+$", as.character(seq_region))] # the selected region dose not contain A,T,G,C (or not defined)
            if(length(seq_region_with_non_acgt) > 0 ){
              if(length(seq_region_clean) == 0){ 
                show_alert(title='Error.',text='The selected region does not contain A,T,G,C. Please select another region.', type='error')
                output$Motif_analysis_status <- renderText({ "The selected region does not contain A,T,G,C. Please select another region." })
                output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})
                isCalculating_Motif_analysis(FALSE)
                return(NULL)
              }else{
                error_peak <- peaks[!grepl("^[ACGT]+$", as.character(seq_region))]
                output$Motif_analysis_status <- renderText({ paste("The following peaks do not contain A,T,G,C and will be ignored:\n", paste(error_peak, collapse = "\n")) })
              }
            }else{
              output$Motif_analysis_status <- renderText({NULL})
            }
          }else if(input$Motif_analysis_input_type == 'B'){
            if(nchar(input$Motif_analysis_input_sequences) == 0){
              show_alert(title='Error.',text='Please input the sequences in the format of ACGT.', type='error')
              output$Motif_analysis_status <- renderText({'Please input the sequences in the format of ACGT.'})
              output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})
              isCalculating_Motif_analysis(FALSE)
              return(NULL)
            }
            seq_region <- unlist(strsplit(input$Motif_analysis_input_sequences, split = "\n"))
            seq_region <- unique(seq_region)
            seq_region_clean <- seq_region[grepl("^[ACGT]+$", as.character(seq_region))]
            seq_region_with_non_acgt <- seq_region[!grepl("^[ACGT]+$", as.character(seq_region))] # the selected region dose not contain A,T,G,C (or not defined)
            if(length(seq_region_with_non_acgt) > 0 ){
              if(length(seq_region_clean) == 0){ 
                show_alert(title='Error.',text='The input sequences contain characters other than A, T, G, and C. Please enter the sequences again.', type='error')
                output$Motif_analysis_status <- renderText({ "The input sequences contain characters other than A, T, G, and C. Please enter the sequences again." })
                output$Motif_analysis_plot_status <- renderText({'Please do the motif scan first.'})
                isCalculating_Motif_analysis(FALSE)
                return(NULL)
              }else{
                output$Motif_analysis_status <- renderText({ paste("The following sequences contain characters other than A, T, G, and C, and will be ignored:\n", paste(seq_region_with_non_acgt, collapse = "\n")) })
              }
            }else{
              output$Motif_analysis_status <- renderText({NULL})
            }
            seq_region_clean <- DNAStringSet(seq_region_clean) # convert to DNAStringSet
          }

          # scan
          res = motifEnrichment(seq_region_clean, PWMLogn.hg19.MotifDb.Hsap)
          report = groupReport(res)
          output$Motif_analysis_plot_status <- renderText({'Please select a row in the motif scan table.'})
          Motif_scan_result(df_report <- as.data.frame(report))
          isCalculating_Motif_analysis(FALSE)
          return(NULL)
        })
        
      # Show the table
        output$Motif_analysis_table <- renderDataTable({
          if(!isTriggered_Motif_analysis()) {
            tmp <- data.frame(list('rank'=character(0), 'target'=character(0), 'id'=character(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }else if(isCalculating_Motif_analysis()) {
            tmp <- data.frame(list('rank'=character(0), 'target'=character(0), 'id'=character(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }else if(is.null(Motif_scan_result())){
            tmp <- data.frame(list('rank'=character(0), 'target'=character(0), 'id'=character(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }else{
            return(datatable(Motif_scan_result(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
          }
        })

      # download table
        output$Motif_analysis_table_download <- downloadHandler(
          filename = function() {
            "Motif_analysis_table.tsv"
          },
          content = function(fname) {
            # Guard clause inside content function
            if (!isTriggered_Motif_analysis() || isCalculating_Motif_analysis() || is.null(Motif_scan_result())) {
              return(NULL)
            }
            write.table(Motif_scan_result(), fname, sep = '\t', row.names = FALSE, quote = FALSE)
          }
        )


      # show a logo
        output$Motif_analysis_plot <- renderPlot({
          if(!isTriggered_Motif_analysis() || isCalculating_Motif_analysis() || is.null(Motif_scan_result())){
            return(ggplot())
          }
          selected_row <- input$Motif_analysis_table_rows_selected
          if(length(selected_row) == 0){
            output$Motif_analysis_plot_status <- renderText({'Please select a row in the motif scan table.'})
            return(ggplot())
          }
          data(PWMLogn.hg19.MotifDb.Hsap)
          select_id <- Motif_scan_result()[selected_row, 'id']
          pfm <- PWMLogn.hg19.MotifDb.Hsap@pwms[[select_id]]$pfm
          pfm_norm <- apply(pfm, 2, function(col) col / sum(col))
          output$Motif_analysis_plot_status <- renderText({NULL})
          p <- ggseqlogo(pfm_norm, method=input$Motif_analysis_plot_Y_axis)
          p <- p + theme(axis.title = element_text(size = input$Motif_analysis_plot_XY_title_size), axis.text = element_text(size = input$Motif_analysis_plot_XY_label_size))
          p

        }, width = reactive(input$Motif_analysis_fig.width), height = reactive(input$Motif_analysis_fig.height), res=300)

    ####
  ###

  ### Clinical_data ################################################################################

    #### Clinical data loading ####
      Cliniacal_dataset <- reactiveVal({data.frame(read.table('data/Clinical_data_database.tsv', sep='\t', header=T, check.names = FALSE))})
      output$Clinical_data_select <- renderUI({ selectInput('Clinical_data_select', 'Select a clinical data', c('None'='None', Cliniacal_dataset()$Database.Name)) })
      outputOptions(output, "Clinical_data_select", suspendWhenHidden=FALSE)

      # show the details when it is selected
        output$Clinical_Dataset_detail <- renderText({
          df_tmp <- Cliniacal_dataset()
          if(input$Clinical_data_select != 'None'){
            paste0('Description: ' , as.character(df_tmp[df_tmp$Database.Name == input$Clinical_data_select, ]$Description), '\n' )
          }else{
            'Please select a dataset.'
          }
        })

      # load all the data
        Clinical_gene_expression <- reactiveVal(NULL)
        Clinical_surival <- reactiveVal(NULL)
        Clinical_meta <- reactiveVal(NULL)
        Clinical_mutation <- reactiveVal(NULL)

        # when selecting a cohort
          observe({
            # req(input$Clinical_data_select)
            if(length(input$Clinical_data_select)==0){
              output$Clinical_View_Geneexpression_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_Survival_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_MetaData_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_mutation_status <- renderText({'Please select a dataset.'})
              Clinical_gene_expression(NULL)
              Clinical_surival(NULL)
              Clinical_meta(NULL)
              Clinical_mutation(NULL)
              return(NULL)
            }
            if(input$Clinical_data_select != 'None'){
              # Gene expression
                path <- Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Expression_path
                if(!file.exists(path)){
                  output$Clinical_View_Geneexpression_status <- renderText({'The file does not exsit. \nDid you download and deploy the folloeing files? \nhttps://d250-shiny2.inet.dkfz-heidelberg.de/users/h023o/in_house_screening/00_Clinical_dataset.tar.gz \n \n or, please upload the data again. '})  
                  Clinical_gene_expression(NULL)
                }else{
                  tmp_ex <- read.table(path, sep='\t', header=T, row.names=1, check.names = FALSE)
                  output$Clinical_View_Geneexpression_status <- renderText({
                    paste0('Number of genes: ', dim(tmp_ex)[1], '\n', 'Number of samples: ' , dim(tmp_ex)[2])
                  })
                  Clinical_gene_expression(tmp_ex)
                }

              # survival
                output$Clinical_View_Survival_status <- renderText({NULL})
                path=Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Survival_path
                if(!file.exists(path)){
                  output$Clinical_View_Survival_status <- renderText({'The file does not exsit. \nDid you successfully upload the data? '})  
                  Clinical_surival(NULL)
                }else{
                  tmp_suv <- read.table(path, header=T, check.names = FALSE, sep='\t')
                  Clinical_surival(tmp_suv)
                }

              # meta
                output$Clinical_View_MetaData_status <- renderText({NULL})
                path=Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Meta_path
                if(!file.exists(path)){
                  output$Clinical_View_MetaData_status <- renderText({'The file does not exsit. \nDid you upload the data?'})  
                  Clinical_meta(NULL)
                }else{
                  tmp_meta <- read.delim(path, header=T,check.names = FALSE)
                  Clinical_meta(tmp_meta)
                }

              # mutation
                output$Clinical_View_mutation_status <- renderText({NULL})
                if(is.na(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Mutation_path)){
                  output$Clinical_View_mutation_status <- renderText({"No mutation data in this cohort"})
                  Clinical_mutation(NULL)
                }else{
                  if(file.exists(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Mutation_path)){
                    tmp_mut <- read.delim(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == input$Clinical_data_select, ]$Mutation_path, header=T,check.names = FALSE)
                    Clinical_mutation(tmp_mut)
                  }else{
                    output$Clinical_View_mutation_status <- renderText({"No mutation data in this cohort"})
                    Clinical_mutation(NULL)
                  }
                }
              #
            }else{
              output$Clinical_View_Geneexpression_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_Survival_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_MetaData_status <- renderText({'Please select a dataset.'})
              output$Clinical_View_mutation_status <- renderText({'Please select a dataset.'})
              Clinical_gene_expression(NULL)
              Clinical_surival(NULL)
              Clinical_meta(NULL)
              Clinical_mutation(NULL)
            }
          })
      #

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
      outputOptions(output, "Clinical_View_Geneexpression", suspendWhenHidden=FALSE)
      output$Clinical_View_Survival <- DT::renderDataTable({
        datatable(Clinical_surival(), options = list(scrollX = TRUE, pageLength = 10))
      })
      outputOptions(output, "Clinical_View_Survival", suspendWhenHidden=FALSE)
      output$Clinical_View_MetaData <- DT::renderDataTable({
        datatable(Clinical_meta(), options = list(scrollX = TRUE, pageLength = 10))
      })
      outputOptions(output, "Clinical_View_MetaData", suspendWhenHidden=FALSE)
      output$Clinical_View_Mutation <- DT::renderDataTable({
        datatable(Clinical_mutation(), options = list(scrollX = TRUE, pageLength = 10))
      })
      outputOptions(output, "Clinical_View_Mutation", suspendWhenHidden=FALSE)


    #### Survival analysis ####

      ##### Calculate the p and HR #####
        # when using a custom gene set
          output$Clinical_Survival_genes_from_custom_geneset_select <- renderUI({
            gene_sets_names <- c()
            gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
            selectInput('Clinical_Survival_genes_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
          })
          outputOptions(output, "Clinical_Survival_genes_from_custom_geneset_select", suspendWhenHidden=FALSE)

        # initial status of the error message
          output$Clinical_Survial_all_status <- renderText({"Please enter the input and choose the setting, and click 'Start the survival analysis'."})
          output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for \nthe inputted genes will be shown here."})
          output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
          output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })

        # calculate p and HR
          # choose which event to evaluate (OS, PFS, etc)
          output$Clinical_Survival_choose_score_type <- renderUI({
            if(!is.null(Clinical_surival())){
              suv_colnames <- colnames(Clinical_surival())
              col_tmp <- suv_colnames[grepl("\\.time", suv_colnames, ignore.case = TRUE)]
              col_first_parts <- sapply(strsplit(col_tmp, "\\."), `[`, 1)
            }else{
              col_first_parts <- NULL
            }
            selectInput('Clinical_Survival_choose_score_type', 'Select the event type',  c('None'='None', col_first_parts))
          })
          outputOptions(output, "Clinical_Survival_choose_score_type",  suspendWhenHidden=FALSE)

          # record the selected cohort name, so that when you change the cohort, the generated plot will be initialised.
          selected_cohort_suv <- reactiveVal(NULL)
          selected_score_type <- reactiveVal(NULL)

          # caluculate the p and HR value and save as a table.
          df_Suv_p_and_HR <- reactiveVal(NULL)
          topX_perc <- reactiveVal(NULL) # for df_Suv_p_and_HR()$method[1] == 'C'
          topY_perc <- reactiveVal(NULL) # for df_Suv_p_and_HR()$method[1] == 'C'
          observeEvent(input$Clinical_Survival_start, {
            # After clicking the button, the table for p and HR (df_Suv_p_and_HR) will be updated.
            # update the selected cohort name and event type
              selected_cohort_suv(input$Clinical_data_select)
              selected_score_type(input$Clinical_Survival_choose_score_type)

            # when a cohort is not selected
              if(input$Clinical_data_select=='None'){
                show_alert(title='Error.',text='Please select a clinical dataset', type='error')
                output$Clinical_Survial_all_status <- renderText({"Please select the clinical dataset"})
                output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                df_Suv_p_and_HR(NULL)
                return()
              }

            # load data
              df_geneEx <- Clinical_gene_expression()
              df_OS <- Clinical_surival()

            # gene selection for input
              if(input$Clinical_Survival_Split_way != 'C'){
                if(input$Clinical_Survival_genes_from_custom_geneset){ # gene selection (from custom geneset)
                  if(input$Clinical_Survival_genes_from_custom_geneset_select == 'None'){
                    show_alert(title='Error.',text='Please select a custom gene set.', type='error')
                    output$Clinical_Survial_all_status <- renderText({"Please select a custom gene set."})
                    output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                    output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                    output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                    df_Suv_p_and_HR(NULL)
                    return()
                  }
                  genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Clinical_Survival_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                }else{  # gene selection (from text input)
                  if(nchar(input$Clinical_Survival_genes)== 0 ){
                    show_alert(title='Error.',text='Please enter genes (line by line)', type='error')
                    output$Clinical_Survial_all_status <- renderText({"Please enter genes (line by line)"})
                    output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                    output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                    output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                    df_Suv_p_and_HR(NULL)
                    return()
                  }
                  genes <- unlist(strsplit(input$Clinical_Survival_genes, '\n'))
                }
                genes <- intersect(genes, rownames(df_geneEx))
              }else{
                genes <- c('(Custom grouping)')
              }
              if(length(genes) == 0){
                show_alert(title='Error.',text='None of the inputted genes are not in the dataset.', type='error')
                output$Clinical_Survial_all_status <- renderText({"None of the inputted genes are not in the dataset. \nPlease make sure the gene names are correct and does not include unnecessary spaces."})
                output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                df_Suv_p_and_HR(NULL)
                return()
              }
              if(input$Clinical_Survival_choose_score_type == 'None'){
                show_alert(title='Error.',text='Please select an event type.', type='error')
                output$Clinical_Survial_all_status <- renderText({"Please select an event type."})
                output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                df_Suv_p_and_HR(NULL)
                return()
              }

            # calculate p and HR for each gene
              df_out <- data.frame('Gene'=c(), 'P.value'=c(), 'Hazard.Ratio'=c())
              error_genes <- c()
              output$Clinical_Survial_table_status <- renderText({NULL})
              for (gene in genes){ # gene <- genes[1]
                if(gene!=''){ 
                  if(input$Clinical_Survival_Split_way != 'C' & !(gene %in% rownames(df_geneEx))){
                    df_tmp <- data.frame('Gene'=gene, 'P.value'=NA, 'Hazard.Ratio'=NA)
                    df_out <- rbind(df_out, df_tmp)
                  }else{
                    if(input$Clinical_Survival_Split_way == 'A'){
                      med <- median(unlist(df_geneEx[gene,]))
                      df_high_sample <- colnames(df_geneEx[,df_geneEx[gene,] >= med])
                      df_low_sample <- colnames(df_geneEx[,df_geneEx[gene,] < med])
                    }else if(input$Clinical_Survival_Split_way == 'B'){
                      top25 <- quantile(unlist(df_geneEx[gene,]), 0.75, na.rm = T)
                      bottom25 <- quantile(unlist(df_geneEx[gene,]), 0.25, na.rm = T)
                      df_high_sample <- colnames(df_geneEx[,df_geneEx[gene,] >= top25])
                      df_low_sample <- colnames(df_geneEx[,df_geneEx[gene,] <= bottom25])
                    }else if(input$Clinical_Survival_Split_way == 'C'){
                      group1_sample <- unlist(strsplit(input$Clinical_Survival_Split_Group1, "\n"))
                      group2_sample <- unlist(strsplit(input$Clinical_Survival_Split_Group2, "\n"))
                      if(length(group1_sample) == 0 | length(group2_sample) == 0){
                        show_alert(title='Error.',text='Please enter the sample names for the groups.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'Please enter the sample names for the groups.'})
                        return()
                      }
                      if(length(intersect(group1_sample,group2_sample )) > 0){
                        show_alert(title='Error.',text='The sample names for the groups are not unique. \nPlease check the input.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'The sample names for the groups are not unique. \nPlease check the input.'})
                        return()
                      }
                      df_high_sample <-  intersect(group1_sample, colnames(df_geneEx))
                      df_low_sample <- intersect(group2_sample, colnames(df_geneEx))
                      if(length(df_high_sample) == 0 | length(df_low_sample) == 0){
                        show_alert(title='Error.',text='The sample names for the groups are not in the dataset. \nPlease check the input.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'The sample names for the groups are not in the dataset. \nPlease check the input.'})
                        return()
                      }
                    }else if(input$Clinical_Survival_Split_way == 'D'){
                      # use the top X% and bottom Y% of the expression values
                      if(is.numeric(input$Clinical_Survival_Split_Group1_perc) == FALSE | is.numeric(input$Clinical_Survival_Split_Group2_perc) == FALSE){
                        show_alert(title='Error.',text='Please enter the percentage of the top and bottom groups.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'Please enter the percentage of the top and bottom groups.'})
                        return()
                      }
                      if(input$Clinical_Survival_Split_Group1_perc < 0 | input$Clinical_Survival_Split_Group1_perc > 100){
                        show_alert(title='Error.',text='Please enter the percentage of the top group between 0 and 100.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'Please enter the percentage of the top group between 0 and 100.'})
                        return()
                      }
                      if(input$Clinical_Survival_Split_Group2_perc < 0 | input$Clinical_Survival_Split_Group2_perc > 100){
                        show_alert(title='Error.',text='Please enter the percentage of the bottom group between 0 and 100.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'Please enter the percentage of the bottom group between 0 and 100.'})
                        return()
                      }
                      if(input$Clinical_Survival_Split_Group1_perc+input$Clinical_Survival_Split_Group2_perc > 100){
                        show_alert(title='Error.',text='The sum of the percentage of the top and bottom groups should be less than or equal to 100.', type='error')
                        output$Clinical_Survial_plot_error_catch <- renderText({'The sum of the percentage of the top and bottom groups should be less than or equal to 100.'})
                        return()
                      }
                      topX <- quantile(unlist(df_geneEx[gene,]), (100-input$Clinical_Survival_Split_Group1_perc)/100 , na.rm = T)
                      bottomY <- quantile(unlist(df_geneEx[gene,]), input$Clinical_Survival_Split_Group2_perc/100 , na.rm = T)
                      df_high_sample <- colnames(df_geneEx[,df_geneEx[gene,] >= topX])
                      df_low_sample <- colnames(df_geneEx[,df_geneEx[gene,] <= bottomY])
                    }
                    topX_perc(input$Clinical_Survival_Split_Group1_perc)
                    topY_perc(input$Clinical_Survival_Split_Group2_perc)
                    if(length(df_high_sample)==0|length(df_low_sample)==0){
                      error_genes <- c(error_genes, gene)
                    }else{
                      # add group
                      df_OS$group = NA
                      df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
                      df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
                      df_OS$group <- factor(df_OS$group, levels=c('Low', 'High'))
                      # survival object
                      surv_obj <- Surv(time = df_OS[, paste0(input$Clinical_Survival_choose_score_type, '.time')], event = df_OS[,input$Clinical_Survival_choose_score_type]) ###### 
                      # calculate the kaplan-meier for each group
                      km_fit <- survfit(surv_obj ~ group, data = df_OS)
                      cox_model <- coxph(surv_obj ~ group, data = df_OS)
                      # Hazard ratio and p
                      HR <- exp(cox_model$coefficients)
                      p_value <- summary(cox_model)$coefficients[, 5]
                      if(input$Clinical_Survival_Split_way == 'C'){
                        gene <- '(Custom grouping)'
                      }
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

            # concatenate
              if(dim(df_out)[1]==0){
                show_alert(title='Error.',text='Cannot divide the samples into high/low for all the genes with the selected method', type='error')
                output$Clinical_Survial_all_status <- renderText({'Cannot divide the samples into high/low for all the genes with the selected method.'})
                output$Clinical_Survial_table_status <- renderText({"A table of hazard ratios and p-values for the inputted genes will be shown here."})
                output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
                output$Clinical_Survial_plot_distribution_status  <- renderText({ "Please calculate the hazard ratios first." })
                df_Suv_p_and_HR(NULL)
                return()
              }else{
                df_out <- df_out[order(df_out$Hazard.Ratio, decreasing = T),]
                df_out$method <- input$Clinical_Survival_Split_way
                output$Clinical_Survial_all_status <- renderText({NULL})
                df_Suv_p_and_HR(df_out)
                return()
              }
          })

          # show as a table
          output$Clinical_Survial_table <- DT::renderDataTable({
            if(is.null(df_Suv_p_and_HR())){
              tmp <- data.frame('Gene'=character(0), 'P.value'=numeric(0), 'Hazard.Ratio'=numeric(0), stringsAsFactors = FALSE)
            }else{
              tmp <- df_Suv_p_and_HR()[, c('Gene', 'P.value', 'Hazard.Ratio')]
            }
            rownames(tmp) <- NULL
            datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
          })
        
        # download the table
          output$Clinical_Survial_table_download <- downloadHandler(
            filename = function(){"Survival_analysis.tsv"}, 
            content = function(fname){ write.table(df_Suv_p_and_HR(), fname, sep='\t', row.names=F, quote=F) }
          )
        #
      ##### plot a Kaplan meier #####
        output$Clinical_Survial_plot <- renderPlot({
          if(is.null(df_Suv_p_and_HR())){
            output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
            return(ggplot())
          }
          if(!is.null(selected_score_type()) && selected_score_type() != input$Clinical_Survival_choose_score_type){
            output$Clinical_Survial_plot_error_catch <- renderText({"You changed the event type. \nPlease calculate the p value and the hazard ratios first." })
            return(ggplot())
          }
          if(!is.null(selected_cohort_suv()) && selected_cohort_suv() != input$Clinical_data_select){
            output$Clinical_Survial_plot_error_catch <- renderText({"You changed the cohort. \nPlease calculate the p value and the hazard ratios first." })
            return(ggplot())
          }
          if(input$Clinical_Survival_choose_score_type == 'None'){
            output$Clinical_Survial_plot_error_catch <- renderText({"Please calculate the p value and the hazard ratios first." })
            output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please select an event type."})
            return(ggplot())
          }
          df_geneEx <- Clinical_gene_expression()
          df_OS <- Clinical_surival()
          # df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          if(is.null(df_Suv_p_and_HR())){
            return(ggplot())
          }
          # gene_kaplan <- input$Clinical_Survial_plot_Geneselect
          if(length(input$Clinical_Survial_table_rows_selected)==0){
            output$Clinical_Survial_plot_error_catch <- renderText({'Please select a gene from the table.'})
            return(ggplot())
          }
          output$Clinical_Survial_plot_error_catch <- renderText({NULL})
          gene_kaplan <- df_Suv_p_and_HR()[input$Clinical_Survial_table_rows_selected,]$Gene
          if(df_Suv_p_and_HR()$method[1] == 'A'){
            med <- median(unlist(df_geneEx[gene_kaplan,]))
            df_high_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] >= med])
            df_low_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] < med])
          }else if(df_Suv_p_and_HR()$method[1] == 'B'){
            top25 <- quantile(unlist(df_geneEx[gene_kaplan,]), 0.75, na.rm = T)
            bottom25 <- quantile(unlist(df_geneEx[gene_kaplan,]), 0.25, na.rm = T)
            df_high_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] >= top25])
            df_low_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] <= bottom25])
          }else if(df_Suv_p_and_HR()$method[1] == 'C'){
            group1_sample <- unlist(strsplit(input$Clinical_Survival_Split_Group1, "\n"))
            group2_sample <- unlist(strsplit(input$Clinical_Survival_Split_Group2, "\n"))
            df_high_sample <-  intersect(group1_sample, colnames(df_geneEx))
            df_low_sample <- intersect(group2_sample, colnames(df_geneEx))
          }else if(df_Suv_p_and_HR()$method[1] == 'D'){
            topX <- quantile(unlist(df_geneEx[gene_kaplan,]), (100-topX_perc())/100 , na.rm = T)
            bottomY <- quantile(unlist(df_geneEx[gene_kaplan,]), topY_perc()/100 , na.rm = T)
            df_high_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] >= topX])
            df_low_sample <- colnames(df_geneEx[,df_geneEx[gene_kaplan,] <= bottomY])
          }
          df_OS$group = NA
          df_OS[df_OS$sample %in% df_high_sample,]$group <- 'High'
          df_OS[df_OS$sample %in% df_low_sample,]$group <- 'Low'
          df_OS$group <- factor(df_OS$group, levels=c('High', 'Low'))

          # survival object
          surv_obj <- Surv(time = df_OS[, paste0(input$Clinical_Survival_choose_score_type, '.time')], event = df_OS[,input$Clinical_Survival_choose_score_type])
          km_fit <- survfit(surv_obj ~ group, data = df_OS)
          km_data <- broom::tidy(km_fit)
          # graph
          km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 0.25) + 
            geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
            labs( title = gene_kaplan, x = "Time", y = "Survival Probability", color = "")
          p <- km_plot
          if(df_Suv_p_and_HR()$method[1] == 'A' | df_Suv_p_and_HR()$method[1] == 'B' | df_Suv_p_and_HR()$method[1] == 'D'){
            p <- p +
              scale_color_manual(
                  values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
                  labels=c(paste0(gene_kaplan, '-High (n=', as.character(length(df_high_sample)), ')'), paste0(gene_kaplan, '-Low (n=', as.character(length(df_low_sample)), ')'))
                ) +
              scale_fill_manual(
                  values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
                  labels=c(paste0(gene_kaplan, '-High (n=', as.character(length(df_high_sample)), ')'), paste0(gene_kaplan, '-Low (n=', as.character(length(df_low_sample)), ')'))
                )
          }else if(df_Suv_p_and_HR()$method[1] == 'C'){
            p <- p +
              scale_color_manual(
                  values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
                  labels=c(paste0('Group1', ' (n=', as.character(length(df_high_sample)), ')'), paste0('Group2', ' (n=', as.character(length(df_low_sample)), ')'))
                ) +
              scale_fill_manual(
                  values=c('group=High'=input$Clinical_Survial_High_colour, 'group=Low'=input$Clinical_Survial_Low_colour),
                  labels=c(paste0('Group1', ' (n=', as.character(length(df_high_sample)), ')'), paste0('Group2', ' (n=', as.character(length(df_low_sample)), ')'))
                )
          }
          p <- p + guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Clinical_Survial_legend_size)) 
          p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
          p <- p + theme(axis.text.y = element_text(size = input$Clinical_Survial_label_size), axis.text.x = element_text(size = input$Clinical_Survial_label_size))
          p <- p + theme(axis.title.y = element_text(size = input$Clinical_Survial_title_size), axis.title.x = element_text(size = input$Clinical_Survial_title_size))
          # p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          p <- p + theme(legend.key.size = unit(2, "mm"))
          p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
          p <- p + theme(panel.background = element_rect(fill="white", size=0))
          p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          p <- p + labs(title=NULL)
          p
        }, width=reactive(input$Clinical_Survial_fig.width), height=reactive(input$Clinical_Survial_fig.height), res=300)

      ##### distribution #####
        output$Clinical_Survial_distribution_plot <- renderPlot({
          if(is.null(df_Suv_p_and_HR())){
            output$Clinical_Survial_plot_distribution_status <- renderText({'Please calculate the p value and the hazard ratios first.'})
            return(ggplot())
          }
          if(length(input$Clinical_data_select)==0){
            output$Clinical_Survial_plot_distribution_status <- renderText({'Please calculate the p value and the hazard ratios first.'})
            return(ggplot())
          }
          if(selected_cohort_suv() != input$Clinical_data_select){
            output$Clinical_Survial_plot_distribution_status <- renderText({'You changed the cohort. \nPlease calculate the p value and the hazard ratios first.'})
            return(ggplot())
          }
          if(length(input$Clinical_Survial_table_rows_selected)==0){
            output$Clinical_Survial_plot_distribution_status <- renderText({'Please select a gene from the table.'})
            return(ggplot())
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
          p <- p + theme(legend.margin = margin(-5, 0, 0, 0))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          if(input$Clinical_Survial_distribution_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p
        }, width=reactive(input$Clinical_Survial_distribution_fig.width), height=reactive(input$Clinical_Survial_distribution_fig.height),res=300)
      #### 

    #### Gene corralation ####
      ##### Calculate the correlation #####
        # when using a custom gene set
          output$Gene_correlation_genes_y_from_custom_geneset_select <- renderUI({
            gene_sets_names <- c()
            gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
            selectInput('Gene_correlation_genes_y_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
          })
          outputOptions(output, "Gene_correlation_genes_y_from_custom_geneset_select", suspendWhenHidden=FALSE)

        # initial status of the error message
          output$Gene_correlation_all_status <- renderText({"Please select a cohort, set the input genes and click 'Calculate the correlation'."})
          output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
          output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
        
        # calculate the correlation after clicking the button
          df_gene_correlation <- reactiveVal(NULL)
          selected_cohort_cor <- reactiveVal(NULL)

          observeEvent(input$Gene_correlation_start, {
            selected_cohort_cor(input$Clinical_data_select)

            if(input$Clinical_data_select == 'None'){
              show_alert(title='Error.',text='Please select a cohort', type='error')
              output$Gene_correlation_all_status <- renderText({'Please select a cohort'})
              output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
              output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
              df_gene_correlation(NULL)
              return()
            }
            if(nchar(input$Gene_correlation_genes)==0){
              show_alert(title='Error.',text='Please enter a gene name for the Y axis.', type='error')
              output$Gene_correlation_all_status <- renderText({'Please enter a gene name for the Y axis.'})
              output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
              output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
              df_gene_correlation(NULL)
              return()
            }
            gene <-  unlist(strsplit(input$Gene_correlation_genes, split = "\n"))[1]
            df_geneEx <- Clinical_gene_expression()
            if(!gene %in% rownames(df_geneEx)){
              show_alert(title='Error.',text='The inputted gene for the Y-axis is not in the selected dataset.', type='error')
              output$Gene_correlation_all_status <- renderText({'The inputted gene for the Y-axis is not in the selected dataset.\nPlease make sure the gene name is correct and does not include unnecessary spaces.'})
              output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
              output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
              df_gene_correlation(NULL)
              return()
            }
            if(length(input$Gene_correlation_Corralation_method) == 0){
              show_alert(title='Error.',text='Please choose the Method for correlation.', type='error')
              output$Gene_correlation_all_status <- renderText({'Please choose the Method for correlation'})
              output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
              output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
              df_gene_correlation(NULL)
              return()
            }
            if(length(input$Gene_correlation_genes_comparison_type)==0){
              show_alert(title='Error.',text='Please choose the "Explore type".', type='error')
              output$Gene_correlation_all_status <- renderText({'Please choose the "Explore type"'})
              output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
              output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
              df_gene_correlation(NULL)
              return()
            }
            if(input$Gene_correlation_genes_comparison_type == 'A'){
              genes_to_compare <- rownames(df_geneEx)
            }else if(input$Gene_correlation_genes_comparison_type == 'B'){
              if(input$Gene_correlation_genes_y_from_custom_geneset){
                if(input$Gene_correlation_genes_y_from_custom_geneset_select == 'None'){
                  show_alert(title='Error.',text='Please select a custom gene set.', type='error')
                  output$Gene_correlation_all_status <- renderText({"Please select a custom gene set."})
                  output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
                  output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
                  df_gene_correlation(NULL)
                  return()
                }
                genes_to_compare <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Gene_correlation_genes_y_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
              }else{
                if(nchar(input$Gene_correlation_genes_y)== 0 ){
                  show_alert(title='Error.',text='Please enter genes for the X axis (line by line).', type='error')
                  output$Gene_correlation_all_status <- renderText({"Please enter genes for the X axis (line by line)"})
                  output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
                  output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
                  df_gene_correlation(NULL)
                  return()
                }
                genes_to_compare <- unlist(strsplit(input$Gene_correlation_genes_y, '\n'))
              }
              genes_to_compare <- intersect(genes_to_compare, rownames(df_geneEx))
              if(length(genes_to_compare) == 0){
                show_alert(title='Error.',text='The inputted genes (for X-axis) are not in the selected dataset.', type='error')
                output$Gene_correlation_all_status <- renderText({'The inputted genes (for X-axis) are not in the dataset.\nPlease make sure the gene names are correct and do not include unnecessary spaces.'})
                output$Gene_correlation_table_status <- renderText({"A correlation table will be shown here."})
                output$Gene_correlation_error_catch <- renderText({ "Please calculate the correlation first" })
                df_gene_correlation(NULL)
                return()
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
            output$Gene_correlation_table_status <- renderText({NULL})
            df_gene_correlation(df_cor_out)
            return()
          })
        #
      ##### Plot the correlation by a scatter plot #####
        output$Gene_correlation_table <- DT::renderDataTable({
          if(!is.null(df_gene_correlation())){
            datatable(df_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
          }else{
            tmp <- data.frame('Gene'=character(0), 'r'=numeric(0), 'p'=numeric(0), stringsAsFactors = FALSE)
            datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
          }
        })

        output$Gene_correlation_scatter_plot <- renderPlot({
          if(length(input$Clinical_data_select)==0 || is.null(selected_cohort_cor())){
            output$Gene_correlation_all_status <- renderText({'Please select a dataset and start the analysis.'})
            return(ggplot())
          }
          if(!is.null(selected_cohort_cor()) && selected_cohort_cor() != input$Clinical_data_select){
            output$Gene_correlation_all_status <- renderText({'You changed the dataset. Please re-start the analysis.'})
            return(ggplot())
          }
          if(is.null(df_gene_correlation())){
            return(ggplot())
          }else{
            if(length(input$Gene_correlation_table_rows_selected)>0){
              output$Gene_correlation_error_catch <- renderText({NULL})
              Gene2 <- df_gene_correlation()$target[1]
              Gene1 <- df_gene_correlation()[input$Gene_correlation_table_rows_selected,]$Gene
              df_geneEx <- Clinical_gene_expression()
              scatter_data <- data.frame(Gene1=unlist(df_geneEx[Gene1, ]), Gene2=unlist(df_geneEx[Gene2, ]), Sample=colnames(df_geneEx)) # head(scatter_data)
              p <- ggplot(scatter_data, aes(x=Gene1, y=Gene2))
              p <- p + geom_point(size=0.3, color=input$Gene_correlation_colour, alpha=0.7)
              if(input$Gene_correlation_show_correlation_line){
                p <- p + geom_smooth(method='lm', se=TRUE, color=input$Gene_correlation_colour, size=0.4)
              }
              p <- p + labs(x=Gene1, y=Gene2)
              p <- p + theme(axis.text.y = element_text(size = input$Gene_correlation_label_size), axis.text.x = element_text(size = input$Gene_correlation_label_size))
              p <- p + theme(axis.title.y = element_text(size = input$Gene_correlation_title_size), axis.title.x = element_text(size = input$Gene_correlation_title_size))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
              if(input$Gene_correlation_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p
            }else{
              output$Gene_correlation_error_catch <- renderText('Please select a gene from the correlation table.')
              return(ggplot())
            }
          }
          p
        }, width=reactive(input$Gene_correlation_fig.width), height=reactive(input$Gene_correlation_fig.height), res=300)

        # download the table
        output$Gene_correlation_table_download <- downloadHandler(
          filename = function(){"Gene_correlation_in_cohort.tsv"}, 
          content = function(fname){ write.table(df_gene_correlation(), fname, sep='\t', row.names=F, quote=F) }
        )
      ####
      
    #### Expression across subtypes ####
      # select "Groupby"
        output$Expression_subtype_groupBy <- renderUI({ selectInput('Expression_subtype_groupBy', 'Group by', c('None'='None', colnames(Clinical_meta()))) })
        outputOptions(output, "Expression_subtype_groupBy", suspendWhenHidden=FALSE)

      # check how many subtypes there are
        output$Expression_subtype_subtype_number <- renderText({
          if(length(input$Expression_subtype_groupBy) == 0 || input$Expression_subtype_groupBy =='None'){
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

      # when selecting from custom genesets
        output$Expression_subtype_genes_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c()
              gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
              selectInput('Expression_subtype_genes_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
        outputOptions(output, "Expression_subtype_genes_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      # pivot table for test
        output$Expression_subtype_status <- renderText({ 'You can compare the genes expression across the selected subtypes.\nPlease enter the inputs, select the groups and click "Start comparing".' })
        output$Expression_subtype_table_status <- renderText({ 'A table of the test results (statistic score and p-value) will be shown here.' })
        output$Expression_subtype_error_catch <- renderText({ 'Please set the input and settings, and start "Start comparing".' })
        selected_cohort_ex_sub <- reactiveVal(NULL)
        Expression_subtype_for_test <- reactiveVal(NULL)
        isCalculating_Expression_subtype <- reactiveVal(FALSE)
        isTriggered_Expression_subtype <- reactiveVal(FALSE)
        observeEvent(input$Expression_subtype_start,{
          isTriggered_Expression_subtype(TRUE)
          isCalculating_Expression_subtype(TRUE)
          selected_cohort_ex_sub(input$Clinical_data_select)
          if(input$Clinical_data_select == 'None'){ # when not selecting the cohort
            show_alert(title='Error.',text='Please select a dataset', type='error')
            output$Expression_subtype_status <- renderText({'Please select a dataset first.'})
            output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
            output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
            Expression_subtype_for_test(NULL)
            isCalculating_Expression_subtype(FALSE)
            return(NULL)
          }
          # expression
          df_geneEx <- Clinical_gene_expression() 
          if(input$Expression_subtype_genes_from_custom_geneset){
            if(input$Expression_subtype_genes_from_custom_geneset_select == 'None'){
              show_alert(title='Error.',text='Please select a custom gene set.', type='error')
              output$Expression_subtype_status <- renderText({"Please select a custom gene set."})
              output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
              output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
              Expression_subtype_for_test(NULL)
              isCalculating_Expression_subtype(FALSE)
              return(NULL)
            }
            genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Expression_subtype_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]] 
          }else{
            if(nchar(input$Expression_subtype_genes)==0){ # when no entey in the gene input
              show_alert(title='Error.',text='Please enter genes (line by line).', type='error')
              output$Expression_subtype_status <- renderText({"Please enter genes (line by line)."})
              output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
              output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
              Expression_subtype_for_test(NULL)
              isCalculating_Expression_subtype(FALSE)
              return(NULL)
            }  
            genes <- unlist(strsplit(input$Expression_subtype_genes, split = "\n")) # genes <- c('RERE', 'PHF7')
          }
          genes <- intersect(genes, rownames(df_geneEx))
          if(length(genes)==0){ # when the entry genes are not in the cohort
            show_alert(title='Error.',text='None of the inputted genes are included in the dataset.', type='error')
            output$Expression_subtype_status <- renderText({"None of the inputted genes are included in the dataset. \nPlease make sure the gene names are correct and do not include unnecessary spaces."})
            output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
            output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
            Expression_subtype_for_test(NULL)
            isCalculating_Expression_subtype(FALSE)
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
            show_alert(title='Error.',text='Please select a group to compare.', type='error')
            output$Expression_subtype_status <- renderText({"Please select a group to compare."})
            output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
            output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
            Expression_subtype_for_test(NULL)
            isCalculating_Expression_subtype(FALSE)
            return(NULL)
          }
          df_meta_subtype <- df_meta[, c('sample', group_by)] # head(df_meta_subtype)
          df_meta_subtype <- df_meta_subtype[!is.na(df_meta_subtype[,group_by]),]
          df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] != '',]
          df_meta_subtype[,group_by] <- as.character(df_meta_subtype[,group_by])
          # merge
          df_tmp <- merge(df_gene_EX_gene, df_meta_subtype, by='sample') # head(df_tmp)
          df_out <- df_tmp %>% pivot_longer(cols=all_of(genes), names_to='Genes', values_to='Expression') # head(df_out)
          Expression_subtype_for_test(df_out)
          isCalculating_Expression_subtype(FALSE)
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
              output$Expression_subtype_status <- renderText({"There is no sub groups for the selected category. Please try with other categories."})
              output$Expression_subtype_table_status <- renderText({'Error. Please check the input and settings.'})
              output$Expression_subtype_error_catch <- renderText({'Error. Please check the input and settings.'})
              return(NULL)
            }
            rownames(df_test) <- NULL
            df_test <- df_test[order(df_test$P.value),]
            df_test$group_by <- group_by
            return(df_test)
          }
        })

      # show as a table
        output$Expression_subtype_table <- DT::renderDataTable({
          if(!isTriggered_Expression_subtype()){
            output$Expression_subtype_status <- renderText({'Please set the input and settings, and start "Start comparing".'})
            df_test <- data.frame('Gene'=character(0), 'Statistic'=numeric(0), 'P.value'=numeric(0), stringsAsFactors = FALSE) 
          }
          if(isCalculating_Expression_subtype()){
            output$Expression_subtype_status <- renderText({'Calculating...'})
            df_test <- data.frame('Gene'=character(0), 'Statistic'=numeric(0), 'P.value'=numeric(0), stringsAsFactors = FALSE) 
          }
          if(is.null(Expression_subtype_test())){
            df_test <- data.frame('Gene'=character(0), 'Statistic'=numeric(0), 'P.value'=numeric(0), stringsAsFactors = FALSE) 
          }else{
            output$Expression_subtype_status <- renderText({NULL})
            output$Expression_subtype_table_status <- renderText({NULL})
            df_test <- Expression_subtype_test()[,1:3]
          }
          datatable(df_test, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        })

      # download the table
        output$Expression_subtype_table_download <- downloadHandler(
          filename = function(){"Expression_across_subtype.tsv"}, 
          content = function(fname){ write.table(Expression_subtype_test()[,1:3], fname, sep='\t', row.names=F, quote=F) }
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
          if(!isTriggered_Expression_subtype()){
            output$Expression_subtype_status <- renderText({'Please set the input and settings, and start "Start comparing".'})
            return(ggplot())
          }
          if(isCalculating_Expression_subtype()){
            output$Expression_subtype_status <- renderText({'Calculating...'})
            return(ggplot())
          }
          if(length(selected_cohort_ex_sub()) > 0){
            if(selected_cohort_ex_sub() != input$Clinical_data_select){
              output$Expression_subtype_error_catch <- renderText({'You changed a dataset. Please re-start the analysis.'})
              return(ggplot())
            }
          }
          if(is.null(Expression_subtype_test())){
            return(ggplot())
          }
          if(length(input$Expression_subtype_table_rows_selected)==0){
            output$Expression_subtype_error_catch <- renderText({'Please select a gene (row) from the test result table.'})
            return(ggplot())
          }
          # output$Expression_subtype_error_catch <- renderText({NULL})
          gene <- Expression_subtype_test()[input$Expression_subtype_table_rows_selected,]$Gene
          df_meta <- Clinical_meta()
          df_out <- Expression_subtype_for_test()
          number_each_group <- 'The number of data in each subtypes. \n'
          for (nm in names(table(df_out[,colnames(df_out)[2]]))){
            number_each_group <- paste0(number_each_group, nm , ': ', table(df_meta[,colnames(df_out)[2]])[nm], '\n') # df_out[,])
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
              p <- p + geom_boxplot(fill=input$Expression_subtype_choose_single_colour, size=0.2, outlier.size=0.5)
            }else{
              p <- p + geom_boxplot(color='black', size=0.2, outlier.size=0.5)
              if(input$Expression_subtype_select_colour_pallete != 'None'){
                p <- p + scale_fill_viridis_d(option=input$Expression_subtype_select_colour_pallete)
              }
            }
          }else if(input$Expression_subtype_figtype == 'B'){ # violin plot
            if(input$Expression_subtype_use_single_colour){
              p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour, size=0.2)
            }else{
              p <- p + geom_violin(color='black',trim = FALSE, size=0.2)
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
              p <- p + geom_violin(trim = FALSE, fill=input$Expression_subtype_choose_single_colour, size=0.2)
            }else{
              p <- p + geom_violin(trim = FALSE, size=0.2)
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
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          if(input$Expression_subtype_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          output$Expression_subtype_error_catch <- renderText({NULL})
          p
        }, width=reactive(input$Expression_subtype_fig.width), height=reactive(input$Expression_subtype_fig.height), res=300)

      #
    #### Upload ####
      # file upload and reset function 
        output$new_cohort_upload_GE <- renderUI({ fileInput("new_cohort_upload_GE", "Upload a Gene expression file*") })
        output$new_cohort_upload_sur <- renderUI({ fileInput("new_cohort_upload_sur", "Upload a survival data file*") })
        output$new_cohort_upload_meta <- renderUI({ fileInput("new_cohort_upload_meta", "Upload a metadata file*") })
        output$new_cohort_upload_mut <- renderUI({ fileInput("new_cohort_upload_mut", "Upload a mutation data file (optional)") })
        outputOptions(output, "new_cohort_upload_GE", suspendWhenHidden=FALSE)
        outputOptions(output, "new_cohort_upload_sur", suspendWhenHidden=FALSE)
        outputOptions(output, "new_cohort_upload_meta", suspendWhenHidden=FALSE)
        outputOptions(output, "new_cohort_upload_mut", suspendWhenHidden=FALSE)

      # reset
        observeEvent(input$new_cohort_upload_reset, {
          output$new_cohort_upload_GE <- renderUI({ fileInput("new_cohort_upload_GE", "Upload a Gene expression file*") })
          output$new_cohort_upload_sur <- renderUI({ fileInput("new_cohort_upload_sur", "Upload a survival data file*") })
          output$new_cohort_upload_meta <- renderUI({ fileInput("new_cohort_upload_meta", "Upload a metadata file*") })
          output$new_cohort_upload_mut <- renderUI({ fileInput("new_cohort_upload_mut", "Upload a mutation data file (optional)") })
          output$new_cohort_upload_GE_preview <- renderDataTable({NULL})
          output$new_cohort_upload_sur_preview <- renderDataTable({NULL})
          output$new_cohort_upload_meta_preview <- renderDataTable({NULL})
          output$new_cohort_upload_mut_preview <- renderDataTable({NULL})
          output$new_cohort_status <- renderText({ NULL })
          output$new_cohort_upload_GE_preview_status <- renderText({"Please upload a gene expression file. The preview will be shown here."})
          output$new_cohort_upload_sur_preview_status <- renderText({"Please upload a survival data file. The preview will be shown here."})
          output$new_cohort_upload_meta_preview_status <- renderText({"Please upload a metadata file. The preview will be shown here."})
          output$new_cohort_upload_mut_preview_status <- renderText({"Please upload a mutation data file. The preview will be shown here."})
        })

      ## load data if they are uploaded
      # initial value
        gx_table <- reactiveVal(NULL)
        suv_table <- reactiveVal(NULL)
        meta_table <- reactiveVal(NULL)
        mut_table <- reactiveVal(NULL)

        observe({
          if(is.null(input$new_cohort_upload_GE)){
            gx_table(NULL)
          }else{
            gx_table <- read.table(input$new_cohort_upload_GE$datapath, sep='\t', header=T,check.names = FALSE)
            gx_table(gx_table)
          }
          if(is.null(input$new_cohort_upload_sur)){
            suv_table(NULL)
          }else{
            suv_table <- read.table(input$new_cohort_upload_sur$datapath, sep='\t', header=T,check.names = FALSE)
            suv_table(suv_table)
          }
          if(is.null(input$new_cohort_upload_meta)){
            meta_table(NULL)
          }else{
            meta_table <- read.table(input$new_cohort_upload_meta$datapath, sep='\t', header=T,check.names = FALSE)
            meta_table(meta_table)
          }
          if(is.null(input$new_cohort_upload_mut)){
            mut_table(NULL)
          }else{
            mut_table <- read.table(input$new_cohort_upload_mut$datapath, sep='\t', header=T,check.names = FALSE)
            mut_table(mut_table)
          }
        })


      # in case that the gx file has duplicated id names
        output$new_cohort_status <- renderText({NULL})
        new_cohort_upload_GE_table <- reactive({
          output$new_cohort_status <- renderText({NULL})
          if(is.null(gx_table())){
            return(NULL)
          }
          gx_table <- gx_table()
          if(!'id' %in% colnames(gx_table)){
            output$new_cohort_status <- renderText({'Error: The gene expression table does not have "id" in its header.'})
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

      # preview
        output$new_cohort_upload_GE_preview_status <- renderText({"Please upload a gene expression file. The preview will be shown here."})
        output$new_cohort_upload_sur_preview_status <- renderText({"Please upload a survival data file. The preview will be shown here."})
        output$new_cohort_upload_meta_preview_status <- renderText({"Please upload a metadata file. The preview will be shown here."})
        output$new_cohort_upload_mut_preview_status <- renderText({"Please upload a mutation data file. The preview will be shown here."})

        output$new_cohort_upload_GE_preview <- renderDataTable({
          if(is.null(gx_table())){
            return(NULL)
          }else{
            output$new_cohort_upload_GE_preview_status <- renderText({"The below are the first 10 lines."})
            datatable( head(new_cohort_upload_GE_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
          }
        })

        output$new_cohort_upload_sur_preview <- renderDataTable({
          if(is.null(suv_table())){
            return(NULL)
          }else{
            output$new_cohort_upload_sur_preview_status <- renderText({"The below are the first 10 lines."})
            datatable( head(suv_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
          }
        })

        output$new_cohort_upload_meta_preview <- renderDataTable({
          if(is.null(meta_table())){
            return(NULL)
          }else{
            output$new_cohort_upload_meta_preview_status <- renderText("The below are the first 10 lines.")
            datatable( head(meta_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
          }
        })

        output$new_cohort_upload_mut_preview <- renderDataTable({
          if(is.null(mut_table())){
            return(NULL)
          }else{
            output$new_cohort_upload_mut_preview_status <- renderText("The below are the first 10 lines.")
            datatable( head(mut_table(), 10), options = list(scrollX = TRUE, scrollY = TRUE )) 
          }
        })


      # uploading
        observeEvent(input$new_cohort_upload_data,{
          if(is.null(gx_table()) | is.null(suv_table()) | is.null(meta_table()) ){
            show_alert(title='Error.',text='Please upload all the mandatory files.', type='error' )
            output$new_cohort_status <- renderText({'Error: Please upload the files.'})
            return()
          }else{
            if(nchar(input$new_cohort_upload_dataset_name)==0 ){
              show_alert(title='Error.',text='Please enter a cohort name.', type='error' )
              output$new_cohort_status <- renderText('Error: * is a mandatory filed.')
              return()
            }else{
              cohort_name <- input$new_cohort_upload_dataset_name
              if(cohort_name %in% Cliniacal_dataset()$Database.Name){
                show_alert(title='Error.',text='The cohort name is duplicated. Please enter a different name.', type='error' )
                output$new_cohort_status <- renderText('Error: The Cohort name is duplicated.')
                return()
              }else if (str_detect(cohort_name, "[;/,()\\[\\]!@#$%]")) {
                show_alert(title='Error.',text='Please avoid special characters for the cohort name.', type='error' )
                output$new_cohort_status <- renderText('Error: Please avoid special characters for the cohort name. The Cohort name cannot contain "/ , ( ) [ ] ! # @ $ %"!')
                return()
              }else{
                # in case there are duplicated genes
                error=0
                gx_table <- gx_table()
                if(!'id' %in% colnames(gx_table)){
                  show_alert(title='Error.',text='The gene expression table does not have "id" in its header.', type='error' )
                  output$new_cohort_status <- renderText('Error: The gene expression table does not have "id" in its header.')
                  error= 1
                  return()
                }
                suv_table <- suv_table()
                if(!'sample' %in% colnames(suv_table)){
                  show_alert(title='Error.',text='The survival table does not have "sample" in its header.', type='error' )
                  output$new_cohort_status <- renderText('Error: The survival table does not have "sample" in its header.')
                  error= 1
                  return()
                }
                meta_table <- meta_table()
                if(!'sample' %in% colnames(meta_table)){
                  show_alert(title='Error.',text='The meta data does not have "sample" in its header.', type='error' )
                  output$new_cohort_status <- renderText('Error: The meta data does not have "sample" in its header.')
                  error= 1
                  return()
                }
                mut_table <- mut_table()
                if(!'sample' %in% colnames(mut_table)){
                  show_alert(title='Error.',text='The mutation data tabke does not have "sample" in its header.', type='error' )
                  output$new_cohort_status <- renderText('Error: The mutation data tabke does not have "sample" in its header.')
                  error= 1
                  return()
                }
                mut_table <- mut_table()
                if(!'id' %in% colnames(mut_table)){
                  show_alert(title='Error.',text='The mutation data tabke does not have "id" in its header.', type='error' )
                  output$new_cohort_status <- renderText('Error: The mutation data tabke does not have "id" in its header.')
                  error= 1
                  return()
                }
                if(error == 0){
                  time_stamp <- as.character(Sys.time()) 
                  Year <- format(Sys.time(), "%Y")
                  date <- format(Sys.time(), "%m.%d")
                  dir.create(file.path('00_Clinical_dataset', Year, date), recursive=T, showWarnings = F)

                  save_path_ge <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_GE$name))
                  save_path_cli <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_sur$name))
                  save_path_meta <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_meta$name))
                  if(is.null(mut_table())){
                    save_path_mut <- NULL
                  }else{
                    save_path_mut <- file.path('00_Clinical_dataset', Year, date, paste0(format(Sys.time(), "%H.%M.%S"), '-', input$new_cohort_upload_mut$name))
                  }
                  Description <- unlist(strsplit(input$new_cohort_upload_description, split = "\n"))[1]

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
                  if(!is.null(mut_table())){
                    file.copy(input$new_cohort_upload_mut$datapath, save_path_mut)
                  }               

                  tmp <- Cliniacal_dataset()
                  tmp <- add_row(tmp, Database.Name=cohort_name , 
                    Description=	Description,
                    Expression_path= save_path_ge,
                    Survival_path= save_path_cli,
                    Meta_path= save_path_meta,
                    added.when= time_stamp,
                    Mutation_path= save_path_mut)
                  tmp <- tmp[order(tmp$added.when, decreasing =T),]
                  Cliniacal_dataset(tmp)
                  replaceData(dataTableProxy('Cliniacal_dataset'), Cliniacal_dataset(), resetPaging=F)
                  write.table(Cliniacal_dataset(), 'data/Clinical_data_database.tsv', row.names=F, sep='\t', quote=F)
                  show_alert(title='Success!', text='The cohort was successfully uploaded.', type='success')
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
        output$Signature_input_selection_status <- renderText({"Please set the input, choose the method and click 'Calculate the signature score'.\nSignature scores using the selected input genes will be calculated for each sample in the cohort."})
        output$Signature_analysis_status <- renderText({"The signature scores for the samples will be shown here."})

      # signature score calculation
        singature_table <- reactiveVal({ NULL })
        selected_cohort_sig <- reactiveVal('None')
        isCalculating_singature_table <- reactiveVal(FALSE)
        isTriggered_singature_table <- reactiveVal(FALSE)
        observeEvent(input$Signature_start, {
          selected_cohort_sig(input$Clinical_data_select)
          isTriggered_singature_table(TRUE)
          isCalculating_singature_table(TRUE)
          if(input$Clinical_data_select == 'None'){
            show_alert(title='Error.', text='Please select a dataset first.', type='error')
            output$Signature_input_selection_status <- renderText({'Please select a dataset first.'})
            singature_table(NULL)
            isCalculating_singature_table(FALSE)
            return(NULL)
          }
          # when no proper input
          df_geneEx <- Clinical_gene_expression() 
          if(input$Signature_input_selection=='A'){
            if(input$Signature_input_selection_custom_geneset_select == 'None'){
              show_alert(title='Error.', text='Please select a gene set.', type='error')
              output$Signature_input_selection_status <- renderText({'Please select a gene set'})
              singature_table(NULL)
              isCalculating_singature_table(FALSE)
              return(NULL)
            }else{
              genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Signature_input_selection_custom_geneset_select, ]$Genes, split=', ')[[1]]
              genes <- intersect(genes, rownames(df_geneEx))
              if(length(genes)==0){
                show_alert(title='Error.', text='None of the genes in the selected gene set are in the dataset.', type='error')
                output$Signature_input_selection_status <- renderText({'None of the genes in the selected gene sets are in the dataset. \nPlease change the gene set.'})    
                singature_table(NULL)
                isCalculating_singature_table(FALSE)
                return(NULL)
              }
            }
          }else{
            if(nchar(input$Signature_input_selection_text_input)==0){
              show_alert(title='Error.', text='Please input genes (line by line).', type='error')
              output$Signature_input_selection_status <- renderText({'Please enter genes (line by line)'})
              singature_table(NULL)
              isCalculating_singature_table(FALSE)
              return(NULL)
            }else{
              genes <- unlist(strsplit(input$Signature_input_selection_text_input, split = "\n"))
              genes <- intersect(genes, rownames(df_geneEx))
              if(length(genes)==0){
                show_alert(title='Error.', text='None of the inputted genes are in the dataset.', type='error')
                output$Signature_input_selection_status <- renderText({'None of the inputted genes are in the dataset. \nPlease check if the gene names are correct and do not have unneccesary spaces.'})    
                singature_table(NULL)
                isCalculating_singature_table(FALSE)
                return(NULL)
              }
            }
          }
          # method is not selected
          if(length(input$Signature_input_score_type)==0){
            show_alert(title='Error.', text='Please select the calculation method.', type='error')
            output$Signature_input_selection_status <- renderText({'Please select the Calculation method.'})
            singature_table(NULL)
            isCalculating_singature_table(FALSE)
            return(NULL)
          }
          output$Signature_input_selection_status <- renderText({NULL})
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
          singature_table(signature_gsva_table)
          isCalculating_singature_table(FALSE)
          return()
        })

      # show table
        output$Signature_result_table <- DT::renderDataTable({
          if(!isTriggered_singature_table()){
            output$Signature_input_selection_status <- renderText({'Please set the input, choose the method and click "Calculate the signature score".'})
            df_test <- data.frame('Sample'=character(0), 'Signature.score'=numeric(0), stringsAsFactors = FALSE)
          }
          if(isCalculating_singature_table()){
            output$Signature_input_selection_status <- renderText({'Calculating...'})
            df_test <- data.frame('Sample'=character(0), 'Signature.score'=numeric(0), stringsAsFactors = FALSE)
          }
          if(is.null(singature_table())){
            df_test <- data.frame('Sample'=character(0), 'Signature.score'=numeric(0), stringsAsFactors = FALSE)
          }else{
            output$Signature_analysis_status <- renderText(NULL)
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
        output$Signature_Survival_detail <- renderText({"Please calulate the signature score first."})
        output$Signature_Survival_plot <- renderPlot({
          if(!isTriggered_singature_table()){
            output$Signature_Survival_detail <- renderText({'Please set the input, choose the method and click "Calculate the signature score".'})
            return(ggplot())
          }
          if(isCalculating_singature_table()){
            output$Signature_Survival_detail <- renderText({'Calculating...'})
            return(ggplot())
          }
          if(length(input$Clinical_data_select)==0){
            output$Signature_Survival_detail <- renderText({'Please calulate the signature score first.'})
            return(ggplot())
          }
          if(selected_cohort_sig() != input$Clinical_data_select){
            output$Signature_Survival_detail <- renderText({'You changed a dataset. Please re-start the analysis.'})
            return(ggplot())
          }
          if(is.null(singature_table())){
            return(ggplot())
          }else{
            singature_table <- singature_table()
          }
          df_OS <- Clinical_surival()
          df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          if(is.null(singature_table)){
            output$Signature_Survival_detail <- renderText({"Please start calulating the score first."})
            return(ggplot())
          }
          output$Signature_Survival_detail <- renderText({NULL})
          Sig_scores <- singature_table[,'Signature.score']
          if(input$Signature_Survival_cutoff_method == 'A'){
            med <- median(Sig_scores)
            df_high_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] >= med, ]$Sample)
            df_low_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] < med, ]$Sample)
          }else{
            top25 <- quantile(Sig_scores, 0.75, na.rm = T)
            bottom25 <- quantile(Sig_scores, 0.25, na.rm = T)
            df_high_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] >= top25,]$Sample)
            df_low_sample <- gsub('\\.', '-', singature_table[singature_table[,'Signature.score'] <= bottom25,]$Sample)
          }
          if(length(df_high_sample)==0 | length(df_low_sample)==0){
            output$Signature_Survival_detail <- renderText({"The samples cannot divide into two using the selected split method."})
            return(ggplot())
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
          km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 0.25) + 
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
          p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          p <- p + theme(legend.key.size = unit(1, "mm"))
          p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
          p <- p + theme(panel.background = element_rect(fill="white", size=0))
          p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          p <- p + labs(title=NULL)
          p
        }, width=reactive(input$Signature_Survival_plot_fig.width), height=reactive(input$Signature_Survival_plot_fig.height), res=300)
        
      ## compare subtypes
      # select group
        output$Signature_subtype_groupBy <- renderUI({ selectInput('Signature_subtype_groupBy', 'Group by', c('None'='None', colnames(Clinical_meta()))) })
        outputOptions(output, "Signature_subtype_groupBy", suspendWhenHidden=FALSE)
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
        Signature_subtype_test <- reactiveVal(NULL)
        isCalculating_subtype_test <- reactiveVal(FALSE)
        isTriggered_subtype_test <- reactiveVal(FALSE)
        observeEvent(input$Signature_subtype_start, {
          isTriggered_subtype_test(TRUE)
          isCalculating_subtype_test(TRUE)
          if(input$Clinical_data_select == 'None'){
            show_alert(title='Error.', text='Please select a dataset first.', type='error')
            output$Signature_subtype_note <- renderText({'Please select a dataset first.'})
            Signature_subtype_test(NULL)
            isCalculating_subtype_test(FALSE)
            return(NULL)
          }
          if(is.null(singature_table())){
            show_alert(title='Error.', text='Please calculate the signature score first.', type='error')
            output$Signature_subtype_note <- renderText({"Please start calulating the score first."})
            Signature_subtype_test(NULL)
            isCalculating_subtype_test(FALSE)  
            return(NULL)
          }
          singature_table <- singature_table() # head(singature_table)
          # meta, subtype
          df_meta <- Clinical_meta()
          df_meta$sample <- gsub('\\.', '-', df_meta$sample)
          group_by <- input$Signature_subtype_groupBy # group_by <- 'gender'
          if(group_by == 'None'){
            show_alert(title='Error.', text='Please select a group to compare.', type='error')
            output$Signature_subtype_note <- renderText({"Please select a group to compare."})
            Signature_subtype_test(NULL)
            isCalculating_subtype_test(FALSE)
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
            show_alert(title='Error.', text='There is no sub groups for the selected category. Please try with other categories.', type='error')
            output$Signature_subtype_note <- renderText({"There is no sub groups for the selected category. Please try with other categories."})
            Signature_subtype_test(NULL)
            isCalculating_subtype_test(FALSE)
            return(NULL)
          }
          Signature_subtype_test(df_out)
          isCalculating_subtype_test(FALSE)
          return(NULL)

        })
          
      # colour option. Should be mutually exclusive
        observeEvent(input$Signature_subtype_change_colour_pallete, { 
          if(input$Signature_subtype_change_colour_pallete){ updateCheckboxInput(session, "Signature_subtype_use_single_colour", value=FALSE)}
        })
        observeEvent(input$Signature_subtype_use_single_colour, { 
          if(input$Signature_subtype_use_single_colour){ updateCheckboxInput(session, "Signature_subtype_change_colour_pallete", value=FALSE)}
        })
 
      # plot (box, violin, swarm)
        output$Signature_subtype_plot <- renderPlot({
          if(!isTriggered_subtype_test()){
            output$Signature_subtype_note <- renderText({'Please start calulating the score first.'})
            return(ggplot())
          }
          if(isCalculating_subtype_test()){
            output$Signature_subtype_note <- renderText({'Calculating...'})
            return(ggplot())
          }
          if(length(input$Clinical_data_select)==0){
            output$Signature_subtype_note <- renderText({'Please select a dataset and start the analysis.'})
            return(ggplot())
          }
          if(selected_cohort_sig() != input$Clinical_data_select){
            output$Signature_subtype_note <- renderText({'You changed a dataset. Please re-start the analysis.'})
            return(ggplot())
          }
          if(is.null(Signature_subtype_test())){
            return(ggplot())
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
              p <- p + geom_boxplot(fill=input$Signature_subtype_choose_single_colour, size=0.2, outlier.size=0.5)
            }else{
              p <- p + geom_boxplot(color='black', size=0.2, outlier.size=0.5)
              if(input$Signature_subtype_select_colour_pallete != 'None'){
                p <- p + scale_fill_viridis_d(option=input$Signature_subtype_select_colour_pallete)
              }
            }
          }else if(input$Signature_subtype_figtype == 'B'){ # violin plot
            if(input$Signature_subtype_use_single_colour){
              p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_choose_single_colour, size=0.2)
            }else{
              p <- p + geom_violin(color='black',trim = FALSE, size=0.2)
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
              p <- p + geom_violin(trim = FALSE, fill=input$Signature_subtype_choose_single_colour, size=0.2)
            }else{
              p <- p + geom_violin(trim = FALSE, size=0.2)
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
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          if(input$Signature_subtype_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p
        }, width=reactive(input$Signature_subtype_fig.width), height=reactive(input$Signature_subtype_fig.height), res=300)


      # histogram
        output$Signature_score_distribution_plot <- renderPlot({
          if(!isTriggered_singature_table()){
            output$Signature_score_distribution_status <- renderText({'Please set the input, choose the method and click "Calculate the signature score".'})
            return(ggplot())
          }
          if(isCalculating_singature_table()){
            output$Signature_score_distribution_status <- renderText({'Calculating...'})
            return(ggplot())
          }
          if(length(input$Clinical_data_select)==0){
            output$Signature_score_distribution_status <- renderText({'Please select a dataset and start the analysis.'})
            return(ggplot())
          }
          
          if(selected_cohort_sig() != input$Clinical_data_select){
            output$Signature_score_distribution_status <- renderText({'You changed a dataset. Please re-start the analysis.'})
            return(ggplot())
          }
          if(is.null(singature_table())){
            return(ggplot())
          }else{
            singature_table <- singature_table()
          }
          df_OS <- Clinical_surival()
          df_OS$sample <- gsub('\\.', '-', df_OS$sample)
          if(is.null(singature_table)){
            output$Signature_score_distribution_status <- renderText({"Please Calulate the signature score first."})
            return(ggplot())
          }
          output$Signature_score_distribution_status <- renderText({NULL})
          p <- ggplot(singature_table, aes_string(x=colnames(singature_table)[2]))
          p <- p + geom_histogram(fill=input$Signature_score_distribution_colour, alpha=0.6, bins=input$Signature_score_distribution_bin_num)
          p <- p + theme(axis.text = element_text(size = input$Signature_score_distribution_label_size))
          p <- p + theme(axis.title = element_text(size = input$Signature_score_distribution_title_size))
          p <- p + theme(plot.title = element_text(size = input$Signature_score_distribution_graphtitle_size))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          if(input$Signature_score_distribution_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p
        }, width=reactive(input$Signature_score_distributionfig.width), height=reactive(input$Signature_score_distribution_fig.height), res=300)
        
      ###

    #### Deconvolution
      # initial setting message
        output$Deconvodution_status <- renderText({"Please select the dataset and the deconvolution method, and click 'Start deconvolution'."})
        
      # Run deconvolution
        deconv_table <- reactiveVal(NULL)
        isCalculating_deconv_table <- reactiveVal(FALSE)
        isTriggered_deconv_table <- reactiveVal(FALSE)
        observeEvent(input$Deconvodution_start,{
          isTriggered_deconv_table(TRUE)
          isCalculating_deconv_table(TRUE)
          if(input$Clinical_data_select == 'None'){
            show_alert(title='Error.', text='Please select a dataset first.', type='error')
            output$Deconvodution_status <- renderText({'Please select a dataset first.'})
            deconv_table(NULL)
            isCalculating_deconv_table(FALSE)
            return(NULL)
          }
          if(length(input$Deconvodution_tool_select)==0){
            show_alert(title='Error.', text='Please select the deconvolution method.', type='error')
            output$Deconvodution_status <- renderText({'Please select the method.'})
            deconv_table(NULL)
            isCalculating_deconv_table(FALSE)
            return(NULL)
          }
          output$Deconvodution_status <- renderText({NULL})
          df_geneEx <-  Clinical_gene_expression() 
          if(input$Deconvodution_tool_select == 'MCPcounter'){
            deconv_table_tmp <-  MCPcounter.estimate(df_geneEx,featuresType="HUGO_symbols")
          }else if(input$Deconvodution_tool_select == 'xCell'){
            deconv_table_tmp <- xCellAnalysis(df_geneEx) # deconv_table[1:3, 1:3]
          }
          colnames(deconv_table_tmp) <- gsub('\\.', '-', colnames(deconv_table_tmp))
          # output$Deconvodution_results <- renderDataTable({
          #   datatable(deconv_table, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
          # })
          deconv_table(deconv_table_tmp)
          isCalculating_deconv_table(FALSE)
          return(NULL)
        })

      # table
        output$Deconvodution_results <- renderDataTable({
          if(!isTriggered_deconv_table()){
            tmp <- data.frame('Cell type'=character(0), 'Sample'=character(0), 'Abundance'=numeric(0), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
          }
          if(isCalculating_deconv_table()){
            output$Deconvodution_status <- renderText({'Calculating...'})
            tmp <- data.frame('Cell type'=character(0), 'Sample'=character(0), 'Abundance'=numeric(0), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
          }
          if(is.null(deconv_table())){
            tmp <- data.frame('Cell type'=character(0), 'Sample'=character(0), 'Abundance'=numeric(0), stringsAsFactors = FALSE)
            return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
          }else{
            return(datatable(deconv_table(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
          }
        })


      # when changing the cohort, data table is reset
        observeEvent(input$Clinical_data_select, {
          output$Deconvodution_status <- renderText({"Please select the dataset and the deconvolution method, and click 'Start deconvolution'."})
          # output$Deconvodution_results <-  renderDataTable({NULL})
        }, ignoreInit=TRUE)
      

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
      output$Deconvodution_Gene_correlation_status0 <- renderText({
        "Please do the deconvolution first, and then, enter the input and choose the setting.\nCorrelations between the inputted genes' expressions and the estimated immune cell abandance level will be calculated."
      })
      output$Deconvodution_Gene_correlation_status <- renderText({"Please do the deconvolution first."})
      Deconvodution_gene_correlation <- reactiveVal(NULL)
      isCalculating_Deconvodution_gene_correlation <- reactiveVal(FALSE)
      isTriggered_Deconvodution_gene_correlation <- reactiveVal(FALSE)
      observeEvent(input$Deconvodution_Gene_correlation_start, {
        isTriggered_Deconvodution_gene_correlation(TRUE)
        isCalculating_Deconvodution_gene_correlation(TRUE)
        if(input$Deconvodution_Gene_correlation_select_celltype == 'None'){
          show_alert(title='Error.', text='Please select a cell type to compare.', type='error')
          output$Deconvodution_Gene_correlation_status0 <- renderText({"Please choose the cell type"})
          Deconvodution_gene_correlation(NULL)
          isCalculating_Deconvodution_gene_correlation(FALSE)
          return(NULL)
        }
        if(input$Deconvodution_Gene_correlation_from_custom_geneset){
          if(input$Deconvodution_Gene_correlation_from_custom_geneset_select == 'None'){
            show_alert(title='Error.', text='Please select a custom gene set.', type='error')
            output$Deconvodution_Gene_correlation_status0 <- renderText({"Please select a custom gene set."})
            Deconvodution_gene_correlation(NULL)
            isCalculating_Deconvodution_gene_correlation(FALSE)
            return(NULL)
          }
          genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Deconvodution_Gene_correlation_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
        }else{
          if(nchar(input$Deconvodution_Gene_correlation_genes)== 0 ){
            show_alert(title='Error.', text='Please input the genes to calculate the correlation.', type='error')
            output$Deconvodution_Gene_correlation_status0 <- renderText({"Please enter genes (line by line)"})
            Deconvodution_gene_correlation(NULL)
            isCalculating_Deconvodution_gene_correlation(FALSE)
            return(NULL)
          }
          genes <- unlist(strsplit(input$Deconvodution_Gene_correlation_genes, '\n'))
        }
        # Cell abundunce
        if(is.null(deconv_table())){
          show_alert(title='Error.', text='Please do the deconvolution first.', type='error')
          output$Deconvodution_Gene_correlation_status0 <- renderText({"Please do deconvolution first."})
          Deconvodution_gene_correlation(NULL)
          isCalculating_Deconvodution_gene_correlation(FALSE)
          return(NULL)
        }
        deconv_table <- deconv_table() # deconv_table[1:3, 1:3]
        cell_type <- input$Deconvodution_Gene_correlation_select_celltype # cell_type <- 'aDC'
        deconv_table_cell <- deconv_table[cell_type,]
        df_geneEx <- Clinical_gene_expression() # genes <- c('CXCL10', 'CXCL9')
        sample_deconv <- gsub('\\.', '-', colnames(deconv_table))
        sample_geneEx <- gsub('\\.', '-', colnames(df_geneEx))
        if(length(intersect(sample_deconv, sample_geneEx))==0){
          show_alert(title='Error.', text='The sample names in the gene expression data and the deconvolution data do not match. Please check the data.', type='error')
          output$Deconvodution_Gene_correlation_status0 <- renderText({'Error. Please chech the expression data has a "sample" in its columns'})
          Deconvodution_gene_correlation(NULL)
          isCalculating_Deconvodution_gene_correlation(FALSE)
          return(NULL)
        }
        genes <- intersect(genes, rownames(df_geneEx))
        if(length(genes) == 0){
          show_alert(title='Error.', text='The inputted gene is not in the dataset. Please make sure the gene name is correct and does not include unnecessary spaces.', type='error')
          output$Deconvodution_Gene_correlation_status0 <- renderText({'The inputted gene is not in the dataset.\nPlease make sure the gene name is correct and does not include unnecessary spaces.'})
          Deconvodution_gene_correlation(NULL)
          isCalculating_Deconvodution_gene_correlation(FALSE)
          return(NULL)
        }
        df_cor_out <- data.frame(Gene=c(), r=c(), p=c())
        if(length(input$Deconvodution_Gene_correlation_method)==0){
          show_alert(title='Error.', text='Please select the method for correlation.', type='error')
          output$Deconvodution_Gene_correlation_status0 <- renderText({'Please select the Method for correlation.'})
          Deconvodution_gene_correlation(NULL)
          isCalculating_Deconvodution_gene_correlation(FALSE)
          return(NULL)
        }
        for ( gene2 in genes){ # gene2 = genes[1]
          gene_ex <- unlist(df_geneEx[gene2,])
          c <- cor.test(deconv_table_cell, gene_ex, method=input$Deconvodution_Gene_correlation_method)
          r <- c$estimate
          p <- c$p.value
          df_cor_tmp <- data.frame(Gene=gene2, r=r, p=p)
          df_cor_out <- rbind(df_cor_out, df_cor_tmp)
        }
        df_cor_out <- df_cor_out[order(df_cor_out$p, decreasing=F),]
        df_cor_out$cell_type <- cell_type
        rownames(df_cor_out) <- NULL
        output$Deconvodution_Gene_correlation_status0 <- renderText({NULL})
        Deconvodution_gene_correlation(df_cor_out)
        isCalculating_Deconvodution_gene_correlation(FALSE)
        return(NULL)
      })

      # show in table
      output$Deconvodution_Gene_correlation_status1 <- renderText({"The correlation table will be shown here."})
      output$Deconvodution_Gene_correlation_table <- DT::renderDataTable({
        if(is.null(Deconvodution_gene_correlation())){
          output$Deconvodution_Gene_correlation_status1 <- renderText({"The correlation table will be shown here."})
          datatable(Deconvodution_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        }else if(length(Deconvodution_gene_correlation()) == 0){
          output$Deconvodution_Gene_correlation_status1 <- renderText({"The correlation table will be shown here."})
          datatable(Deconvodution_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        }else{
          output$Deconvodution_Gene_correlation_status1 <- renderText(NULL)
          datatable(Deconvodution_gene_correlation()[,c('Gene', 'r', 'p')], selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
        }
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
          return(ggplot())
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
            p <- p + geom_point(size=0.5, color=input$Deconvodution_Gene_correlation_colour, alpha=0.7)
            if(input$Deconvodution_Gene_correlation_show_correlation_line){
              p <- p + geom_smooth(method='lm', se=TRUE, color=input$Deconvodution_Gene_correlation_colour, size=0.4)
            }
            p <- p + labs(x=Gene2, y=cell_type)
            p <- p + theme(axis.text = element_text(size = input$Deconvodution_Gene_correlation_label_size))
            p <- p + theme(axis.title = element_text(size = input$Deconvodution_Gene_correlation_title_size))
            p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
            p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            if(input$Deconvodution_Gene_correlation_white_background){
              p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
              p <- p + theme(panel.background = element_rect(fill="white", size=0))
              p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            }
            p
          }else{
            output$Deconvodution_Gene_correlation_status <- renderText('Please select a gene from the table.')
            return(ggplot())
          }
        }
        p
      }, width=reactive(input$Deconvodution_Gene_correlation_fig.width), height=reactive(input$Deconvodution_Gene_correlation_fig.height),res=300)

    #### Mutation
      ## frequency
        # filtering the cohort by metadata (optional)
          output$Clinical_Mutation_frequency_filter_selection <- renderUI({
            if(is.null(Clinical_meta())){
              selectInput("Clinical_Mutation_frequency_filter_selection", "Filtering by:", c('None'='None'))
            }else{
              selectInput("Clinical_Mutation_frequency_filter_selection", "Filtering by:", c('None'='None', colnames(Clinical_meta())))
            }
          })
          output$Clinical_Mutation_frequency_filter_selection_category <- renderUI({
            if(length(input$Clinical_Mutation_frequency_filter_selection)==0 || input$Clinical_Mutation_frequency_filter_selection == 'None'){
              selectInput("Clinical_Mutation_frequency_filter_selection_category", "Category:", c('None'='None'))
            }else{
              selectInput("Clinical_Mutation_frequency_filter_selection_category", "Category:", c('None'='None', unique(Clinical_meta()[,input$Clinical_Mutation_frequency_filter_selection])))
            }
          })
        
        # when selecting genes from custom genesets
          output$Clinical_Mutation_gene_from_custom <- renderUI({
            gene_sets_names <- c()
            gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
            selectInput('Clinical_Mutation_gene_from_custom', 'Select a custom geneset',  c('None'='None', gene_sets_names))  
          })
          outputOptions(output, "Clinical_Mutation_gene_from_custom", suspendWhenHidden=FALSE)
        
        # message before starting
          output$Clinical_Mutation_frequency_plot_status <- renderText({
            if(is.null(input$Clinical_data_select) || input$Clinical_data_select == 'None'){
              "Please select the dataset first"
            }else{
              "Please set 'Gene Input from' and 'Sample filtering' (if needed), and click 'Show plot'"
            }
          })
          output$Clinical_Mutation_frequency_plot_status_table <- renderText({ "A table for Mutation counts (frequenceies) will be shown here." })
          output$Clinical_Mutation_frequency_plot_status_plot <- renderText({ " A plot for Mutation counts (frequenceies) will be shown here." })

        # Show the number of patients after filtering the sample if a category was set
          output$Clinical_Mutation_frequency_filter_selection_number <- renderText({
            df_Mut <- Clinical_mutation()
            df_meta <- Clinical_meta()
            if(is.null(df_Mut)){
              "This dataset does not have a mutation data"
            }else{
              N_sample <- length(df_meta$sample)
              if(input$Clinical_Mutation_frequency_filter == 'B'){
                if(length(input$Clinical_Mutation_frequency_filter_selection_category)!= 0){
                  if(input$Clinical_Mutation_frequency_filter_selection_category != 'None'){
                    filtered_sample <- df_meta[df_meta[,input$Clinical_Mutation_frequency_filter_selection] == input$Clinical_Mutation_frequency_filter_selection_category, ]$sample
                    df_Mut <- df_Mut[df_Mut$sample %in% filtered_sample, ]
                    if(dim(df_Mut)[1] == 0){
                      "None of the selected samples are in the mutation dataset. \nPlease check if the sample names in the meta data and in the mutation data are unique."
                    }else{
                      paste0("Number of samples(patients): ", length(filtered_sample))
                    }
                  }else{
                    paste0("Number of samples(patients): (Please select the category)")
                  }
                }
              }else if(input$Clinical_Mutation_frequency_filter == 'A'){
                N_sample <- length(df_meta$sample)
                paste0("Number of samples(patients): ", N_sample)
              }
            }
          })
          outputOptions(output, "Clinical_Mutation_frequency_filter_selection_number", suspendWhenHidden=FALSE)


        # Create the table when clicking the start button
          df_mut_num <- reactiveVal(NULL)
          sub_sample_list <- reactiveVal(NULL) # in case some subtype of the cohort is selected
          isCalculating_mutation <- reactiveVal(FALSE)
          isTriggered_mutation <- reactiveVal(FALSE)
          observeEvent(input$Clinical_Mutation_plot_start, {
            isTriggered_mutation(TRUE)
            isCalculating_mutation(TRUE)
            output$Clinical_Mutation_frequency_plot_status <- renderText({NULL})
            if(is.null(input$Clinical_data_select) || input$Clinical_data_select == 'None'){
              show_alert(title='Error.', text='Please select a dataset first.', type='error')
              output$Clinical_Mutation_frequency_plot_status <- renderText({"Please select the dataset first"})
              output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
              output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
              df_mut_num(NULL)
              isCalculating_mutation(FALSE)
              return()
            }
            if(is.null(Clinical_mutation())){
              show_alert(title='Error.', text='This dataset does not have a mutation data.', type='error')
              output$Clinical_Mutation_frequency_plot_status <- renderText({"No mutation data in this cohort."})
              output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
              output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
              df_mut_num(NULL)
              isCalculating_mutation(FALSE)
              return()
            }

            df_Mut <- Clinical_mutation()
            df_meta <- Clinical_meta()
            N_sample <- length(df_meta$sample)
            output$Clinical_Mutation_frequency_plot_status <- renderText({"Please set 'Gene Input from' and 'Sample filtering' (if needed), and click 'Show plot'"})

            # filtering the sample if a category was set
            if(input$Clinical_Mutation_frequency_filter == 'B'){
              if(length(input$Clinical_Mutation_frequency_filter_selection_category)!= 0){
                if(input$Clinical_Mutation_frequency_filter_selection_category != 'None'){
                  filtered_sample <- df_meta[df_meta[,input$Clinical_Mutation_frequency_filter_selection] == input$Clinical_Mutation_frequency_filter_selection_category, ]$sample
                  sub_sample_list(filtered_sample)
                  df_Mut <- df_Mut[df_Mut$sample %in% filtered_sample, ]
                  if(dim(df_Mut)[1] == 0){
                    output$Clinical_Mutation_frequency_plot <- renderPlot({NULL}, width=100, height=100)
                    df_mut_num(NULL)
                    isCalculating_mutation(FALSE)
                    return()
                  }
                }else{
                  sub_sample_list(df_meta$sample)
                }
              }            
            }
            
            # gene input
            if(length(input$Clinical_Mutation_gene_input) == 0){
              show_alert(title='Error.', text='Please select the gene input method.', type='error')
              output$Clinical_Mutation_frequency_plot_status <- renderText({"Please select one from 'Genes Input from'"})
              output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
              output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
              df_mut_num(NULL)
              isCalculating_mutation(FALSE)
              return()
            }
            if(input$Clinical_Mutation_gene_input=='A'){ # text input
              if(nchar(input$Clinical_Mutation_gene) == 0){ # No input
                show_alert(title='Error.', text='Please enter gene names.', type='error')
                output$Clinical_Mutation_frequency_plot_status <- renderText({"Please enter gene names."})
                output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
                output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
                df_mut_num(NULL)
                isCalculating_mutation(FALSE)
                return()
              }else{
                input_genes <- unlist(strsplit(input$Clinical_Mutation_gene, split = "\n"))
                input_genes <- intersect(rownames(Clinical_gene_expression()), input_genes)
                if(length(input_genes) == 0){
                  show_alert(title='Error.', text='None of the inputted genes are included in the cohort.', type='error')
                  output$Clinical_Mutation_frequency_plot_status <- renderText({"None of the inputted genes are included in the cohort. \nPlease make sure the gene names are correct and they do not have unnecessary spaces."})
                  output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
                  output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
                  df_mut_num(NULL)
                  isCalculating_mutation(FALSE)
                  return()
                }
              }
            }else if(input$Clinical_Mutation_gene_input=='B'){  # use all genes
              input_genes <- rownames(Clinical_gene_expression())
            }else if(input$Clinical_Mutation_gene_input=='C'){
              if(input$Clinical_Mutation_gene_from_custom == 'None'){
                show_alert(title='Error.', text='Please select a custom gene set.', type='error')
                output$Clinical_Mutation_frequency_plot_status <- renderText({"Please select a custom gene set."})
                output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
                output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
                df_mut_num(NULL)
                isCalculating_mutation(FALSE)
                return()
              }
              input_genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Clinical_Mutation_gene_from_custom, ]$Genes, split=', ')[[1]]
              input_genes <- intersect(rownames(Clinical_gene_expression()), input_genes)
              if(length(input_genes) == 0){
                show_alert(title='Error.', text='None of the inputted genes are included in the cohort.', type='error')
                output$Clinical_Mutation_frequency_plot_status <- renderText({"None of the inputted genes are included in the cohort. \nPlease make sure the gene names are correct and they do not have unnecessary spaces."})
                output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Error. Please check the input."})
                output$Clinical_Mutation_frequency_plot_status_plot <- renderText({"Error. Please check the input."})
                df_mut_num(NULL)
                isCalculating_mutation(FALSE)
                return()
              }
            }

            # table for the barplot
            output$Clinical_Mutation_frequency_plot_status <- renderText({NULL})
            output$Clinical_Mutation_frequency_plot_status_table <- renderText({NULL})
            output$Clinical_Mutation_frequency_plot_status_plot <- renderText({NULL})
            df_mut_num <- data.frame(genes=input_genes, 'Number_of_patients'=0)
            for ( gene in input_genes){
                df_mut_num[df_mut_num$genes == gene, ]$Number_of_patients <- length(unique(df_Mut[df_Mut$id == gene, ]$sample))
            }
            df_mut_num$Frequence <- round(df_mut_num$Number_of_patients/N_sample * 100, 2)
            df_mut_num <- df_mut_num[order(df_mut_num$Number_of_patients, decreasing = T),]
            df_mut_num$genes <- factor(df_mut_num$genes, levels=df_mut_num$genes)
            df_mut_num(df_mut_num)
            isCalculating_mutation(FALSE)
            return()

          })

        # A table for barplot
          output$Clinical_Mutation_frequency_table <- DT::renderDataTable({
            if(!isTriggered_mutation()){
              output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Please click 'Calculate the mutation frequency' to show the table."})
              tmp <- data.frame('genes'=character(0), 'Number_of_patients'=numeric(0), 'Frequence'=numeric(0))
              datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }else if(isCalculating_mutation()){
              output$Clinical_Mutation_frequency_plot_status_table <- renderText({"Calculating the mutation frequency. Please wait."})
              tmp <- data.frame('genes'=character(0), 'Number_of_patients'=numeric(0), 'Frequence'=numeric(0))
              datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }else if(is.null(df_mut_num())){
              tmp <- data.frame('genes'=character(0), 'Number_of_patients'=numeric(0), 'Frequence'=numeric(0))
              datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }else{
              datatable(df_mut_num(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10))
            }
          })
          


        # Plot
          output$Clinical_Mutation_frequency_plot <- renderPlot({
            if(!isTriggered_mutation()){
              output$Clinical_Mutation_frequency_plot_status <- renderText({"Please click 'Calculate the mutation frequency' to show the plot."})
              return(ggplot())
            }
            if(isCalculating_mutation()){
              output$Clinical_Mutation_frequency_plot_status <- renderText({"Calculating the mutation frequency. Please wait."})
              return(ggplot())
            }
            df_mut_num <- df_mut_num()
            if(is.null(df_mut_num)){
              return(ggplot())
            }
            if(length(df_mut_num)==0){
              return(ggplot())
            }else{
              # barplot
              if(length(input$Clinical_Mutation_frequency_plot_type) == 0){
                output$Clinical_Mutation_frequency_plot_status <- renderText({"Please select a sample filering method."})
                output$Clinical_Mutation_frequency_table <- DT::renderDataTable({ datatable(df_mut_num, options = list(scrollX = TRUE, pageLength = 10)) })
                return(ggplot())
              }
              more_than_15 <- 0
              if(dim(df_mut_num)[1]> input$Clinical_Mutation_frequency_plot_top_X){
                df_mut_num <- head(df_mut_num, input$Clinical_Mutation_frequency_plot_top_X)
                more_than_15 <- 1
              }

              if(input$Clinical_Mutation_frequency_plot_type == 'A'){ # show the patient number
                
                p <- ggplot(df_mut_num, aes(x=genes, y=Number_of_patients, fill=Number_of_patients))
                p <- p + geom_bar(stat = 'identity')
                if(!input$Clinical_Mutation_frequency_hide_score){
                  p <- p + geom_text(aes(label=Number_of_patients), vjust=-0.5, color='black', size=input$Clinical_Mutation_frequency_score_size)
                }
                if(max(df_mut_num$Number_of_patients) > 0){
                  p <- p + scale_fill_gradientn( colors = c(input$Clinical_Mutation_frequency_colour_zero,input$Clinical_Mutation_frequency_colour_high ), values = scales::rescale(c(0, max(df_mut_num$Number_of_patients))) , limits = c(0, max(df_mut_num$Number_of_patients)), name=NULL)
                }else{
                  p <- p + scale_fill_gradientn(name=NULL)
                }
                p <- p + labs(y='Number of the Patients with mutations', x=NULL)
              }else if(input$Clinical_Mutation_frequency_plot_type == 'B'){ # show the percentage
                p <- ggplot(df_mut_num, aes(x=genes, y=Frequence, fill=Frequence))
                p <- p + geom_bar(stat = 'identity')
                if(!input$Clinical_Mutation_frequency_hide_score){
                  p <- p + geom_text(aes(label=Frequence), vjust=-0.5, color='black',size=input$Clinical_Mutation_frequency_score_size)
                }
                if(max(df_mut_num$Frequence) > 0){
                  p <- p + scale_fill_gradientn( colors = c(input$Clinical_Mutation_frequency_colour_zero,input$Clinical_Mutation_frequency_colour_high ), values = scales::rescale(c(0, max(df_mut_num$Frequence))) , limits = c(0, max(df_mut_num$Frequence)), name=NULL)
                }else{
                  p <- p + scale_fill_gradientn(name=NULL)
                }
                p <- p + labs(y='Percentage of the Patients with mutations', x=NULL)
              }
              if(more_than_15 >0){
                p <- p + labs(x= paste0("Top ", input$Clinical_Mutation_frequency_plot_top_X ," frequently mutated genes"))
              }
              p <- p + theme(axis.text.y = element_text(size = input$Clinical_Mutation_frequency_title_size), axis.text.x = element_text(size = input$Clinical_Mutation_frequency_label_size))
              p <- p + theme(axis.title.y = element_text(size = input$Clinical_Mutation_frequency_title_size), axis.title.x = element_text(size = input$Clinical_Mutation_frequency_title_size))
              p <- p + theme(legend.key.size = unit(2, "mm"))
              p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
              p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))          
              p <- p + theme(legend.text = element_text(size=input$Clinical_Mutation_frequency_legend_size))
              if(input$Clinical_Mutation_frequency_white_background){
                p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
                p <- p + theme(panel.background = element_rect(fill="white", size=0))
                p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
              }
              p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
              p
            }
          }, width=reactive(input$Clinical_Mutation_frequency_fig.width), height=reactive(input$Clinical_Mutation_frequency_fig.height), res=300)
          # outputOptions(output, "Clinical_Mutation_frequency_plot", suspendWhenHidden=FALSE)

      ## Kaplan-meier
        # choose the event type
          output$Clinical_Mutation_Kaplan_choose_score_type <- renderUI({
            if(!is.null(Clinical_surival())){
              suv_colnames <- colnames(Clinical_surival())
              col_tmp <- suv_colnames[grepl("\\.time", suv_colnames, ignore.case = TRUE)]
              col_first_parts <- sapply(strsplit(col_tmp, "\\."), `[`, 1)
            }else{
              col_first_parts <- NULL
            }
            selectInput('Clinical_Mutation_Kaplan_choose_score_type', 'Select the event type',  c('None'='None', col_first_parts))
          })
          outputOptions(output, "Clinical_Mutation_Kaplan_choose_score_type",  suspendWhenHidden=FALSE)

        # plot
          output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please calculate the frequency first."})
          output$Clinical_Mutation_Kaplan_plot <- renderPlot({
            if(is.null(df_mut_num())){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please calculate the frequency first."})
              return(ggplot())
            }
            if(length(df_mut_num()) == 0){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please calculate the frequency first."})
              return(ggplot())
            }
            if(dim(df_mut_num())[1] == 0){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please calculate the frequency first."})
              return(ggplot())
            }
            df_geneEx <- Clinical_gene_expression()
            df_OS <- Clinical_surival()
            # if samples were filtered by meta data
            if(input$Clinical_Mutation_frequency_filter == 'B'){
              df_OS <- df_OS[df_OS$sample %in% sub_sample_list(),]
            }
            df_mut <- Clinical_mutation()
            df_OS$sample <- gsub('\\.', '-', df_OS$sample)
            if(length(input$Clinical_Mutation_frequency_table_rows_selected)==0){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({'Please select a gene from the table.'})
              return(ggplot())
            }
            gene_kaplan <- df_mut_num()[input$Clinical_Mutation_frequency_table_rows_selected,]$gene
            df_OS$sample <- gsub('\\.', '-', df_OS$sample)
            df_mut$sample <- gsub('\\.', '-', df_mut$sample)
            df_mut_sample <- intersect(df_OS$sample, unique(df_mut[df_mut$id == gene_kaplan,]$sample))
            df_wt_sample <- setdiff(df_OS$sample, df_mut[df_mut$id == gene_kaplan,]$sample) 
            if(length(df_mut_sample) == 0){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({paste0('There is no mutated patient for this gene: ', gene_kaplan , df_mut[df_mut$id == gene_kaplan,]$sample)})
              return(ggplot())
            }
            if(length(df_wt_sample) == 0){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({'There is no wild type patient for this gene.'})
              return(ggplot())
            }

            df_OS$group = NA
            df_OS[df_OS$sample %in% df_mut_sample,]$group <- 'Mutation'
            df_OS[df_OS$sample %in% df_wt_sample,]$group <- 'Wild.Type'
            df_OS$group <- factor(df_OS$group, levels=c('Mutation', 'Wild.Type'))

            # survival object
            if(length(input$Clinical_Mutation_Kaplan_choose_score_type) == 0 || input$Clinical_Mutation_Kaplan_choose_score_type == 'None'){
              output$Clinical_Mutation_Kaplan_plot_status <- renderText({"Please select the event type."})
              return(ggplot())
            }
            surv_obj <- Surv(time = df_OS[, paste0(input$Clinical_Mutation_Kaplan_choose_score_type, '.time')], event = df_OS[,input$Clinical_Mutation_Kaplan_choose_score_type])
            km_fit <- survfit(surv_obj ~ group, data = df_OS)
            km_data <- broom::tidy(km_fit)
            cox_model <- coxph(surv_obj ~ group, data = df_OS)
            # Hazard ratio and p
            HR <- exp(cox_model$coefficients)
            p_value <- summary(cox_model)$coefficients[, 5]
            output$Clinical_Mutation_Kaplan_plot_status <- renderText({
              paste0('P-value: ', p_value, '\n', 'HR: ', HR )
            })
            # graph
            km_plot <- ggplot(km_data, aes(x = time, y = estimate, color = strata, group = strata)) + geom_step(size = 0.25) + 
              geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill=strata), alpha = 0.2, color=NA) +
              labs( title = gene_kaplan, x = "Time", y = "Survival Probability", color = "") +
              scale_color_manual(
                values=c('group=Mutation'=input$Clinical_Mutation_Kaplan_High_colour, 'group=Wild.Type'=input$Clinical_Mutation_Kaplan_Low_colour),
                labels=c(paste0(gene_kaplan, '-Mutation (n=', as.character(length(df_mut_sample)), ')'), paste0(gene_kaplan, '-Wild.Type (n=', as.character(length(df_wt_sample)), ')'))
              ) + 
              scale_fill_manual(
                values=c('group=Mutation'=input$Clinical_Mutation_Kaplan_High_colour, 'group=Wild.Type'=input$Clinical_Mutation_Kaplan_Low_colour),
                labels=c(paste0(gene_kaplan, '-Mutation (n=', as.character(length(df_mut_sample)), ')'), paste0(gene_kaplan, '-Wild.Type (n=', as.character(length(df_wt_sample)), ')'))
              ) +
              guides(fill='none') + theme_minimal() + theme(legend.position = "top", legend.direction='horizontal', legend.text=element_text(size=input$Clinical_Mutation_Kaplan_legend_size)) 
            p <- km_plot
            p <- p + theme(legend.margin = margin(-3, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
            p <- p + theme(axis.text = element_text(size = input$Clinical_Mutation_Kaplan_label_size))
            p <- p + theme(axis.title = element_text(size = input$Clinical_Mutation_Kaplan_title_size))
            # p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
            p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            p <- p + theme(legend.key.size = unit(2, "mm"))
            p <- p + labs(title=NULL)
            p
          }, width=reactive(input$Clinical_Mutation_Kaplan_fig.width), height=reactive(input$Clinical_Mutation_Kaplan_fig.height), res=300)
        #

      ## Expression comparison
        ## input genes
          # when selecting from custom genesets
            output$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select <- renderUI({
              gene_sets_names <- c()
              gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
              selectInput('Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
            })
            outputOptions(output, "Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select",  suspendWhenHidden=FALSE)

          # data table for selecting a gene
            Clinical_Mutation_Gene_expression_geneInput_selecttable_tmp <- reactive({
              if(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset){
                if(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select == 'None'){
                  # output$Clinical_Survial_table_status <- renderText({"Please select a custom gene set."})
                  data.frame(Input=unique(unlist(strsplit(input$Clinical_Mutation_Gene_expression_geneInput, split = "\n"))))
                }else{
                  genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                  data.frame(Input=unique(unlist(strsplit(genes, split = "\n"))))
                }
              }else{
                data.frame(Input=unique(unlist(strsplit(input$Clinical_Mutation_Gene_expression_geneInput, split = "\n"))))
              }
            })

          # show a table
            output$Clinical_Mutation_Gene_expression_geneInput_selecttable <- renderDataTable({
              datatable( Clinical_Mutation_Gene_expression_geneInput_selecttable_tmp(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)) 
            })
        ## Comparison plot
          # select genes -> make a pivot table -> t-test -> plot
          output$Clinical_Mutation_Gene_expression_geneInput_plot <- renderPlot({
            if(is.null(df_mut_num())){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please calculate the frequency first."})
              return(ggplot())
            }
            # gene select
            if(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset){
              if(input$Clinical_Mutation_Gene_expression_geneInput_from_custom_geneset_select == 'None'){
                output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please select a geneset."})
                return(ggplot())
              }
            }else{
              if(nchar(input$Clinical_Mutation_Gene_expression_geneInput) == 0){
                output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please enter genes."})
                return(ggplot())
              }
            }
            if(length(input$Clinical_Mutation_frequency_table_rows_selected) == 0){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please select a gene from the frequency table."})
              return(ggplot())
            }
            if(length(input$Clinical_Mutation_Gene_expression_geneInput_selecttable_rows_selected) == 0){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please select a gene to check the expression from left."})
              return(ggplot())
            }
            gene_compare <- df_mut_num()[input$Clinical_Mutation_frequency_table_rows_selected,]$gene
            gene_ex <- Clinical_Mutation_Gene_expression_geneInput_selecttable_tmp()[input$Clinical_Mutation_Gene_expression_geneInput_selecttable_rows_selected,]
            # sample selection
            df_geneEx <- Clinical_gene_expression() 
            if(!gene_ex %in% rownames(df_geneEx)){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"The selected gene is not included in the cohort.\nPlease check the gene name is correct and does not have unnecessary spaces."})
              return(ggplot())
            }
            df_mut <- Clinical_mutation()
            # if samples were filtered by meta data
            if(input$Clinical_Mutation_frequency_filter == 'B'){
              df_mut <- df_mut[df_mut$sample %in% sub_sample_list(),]
            }
            colnames(df_geneEx) <- gsub('\\.', '-', colnames(df_geneEx))
            # if samples were filtered by meta data
            if(input$Clinical_Mutation_frequency_filter == 'B'){
              df_geneEx <- df_geneEx[, intersect(colnames(df_geneEx), sub_sample_list())]
            }
            df_mut$sample <- gsub('\\.', '-', df_mut$sample)
            df_mut_sample <- intersect(colnames(df_geneEx), unique(df_mut[df_mut$id == gene_compare,]$sample))
            df_wt_sample <- setdiff(colnames(df_geneEx), unique(df_mut[df_mut$id == gene_compare,]$sample)) 
            if(length(df_mut_sample) == 0){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"There is no mutated patient for the selected gene."})
              return(ggplot())
            }
            if(length(df_wt_sample) == 0){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"There is no wild type patient for the selected gene."})
              return(ggplot())
            }
            # take expressions
            mut_ex <- df_geneEx[gene_ex,df_mut_sample]
            wt_ex <- df_geneEx[gene_ex,df_wt_sample]
            test_res <- wilcox.test(as.numeric(mut_ex), as.numeric(wt_ex))
            output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({
              paste0('Statistic (Wilcox test): ', test_res$statistic, '\n', 'P-value: ', test_res$p.value)
            })
            # plot
            df_mut_ex <- data.frame('Expression'=as.numeric(mut_ex), 'Group'='Mutation')
            df_wt_ex <- data.frame('Expression'=as.numeric(wt_ex), 'Group'='Wild.type')
            df_out <- rbind(df_mut_ex, df_wt_ex)
            df_out$Group <- factor(df_out$Group, levels=c('Mutation','Wild.type'))
            if(length(input$Clinical_Mutation_Gene_expression_plot_type) == 0){
              output$Clinical_Mutation_Gene_expression_geneInput_plot_status <- renderText({"Please select a plot type."})
              return(ggplot())
            }
            p <- ggplot(df_out, aes(x=Group, y=Expression, fill=Group))
            if(input$Clinical_Mutation_Gene_expression_plot_type == 'A'){ # boxplot
              p <- p + geom_boxplot(size=0.2, outlier.size=0.5)
            }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'B'){
              p <- p + geom_violin(trim = FALSE, size=0.2)
            }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'C'){
              p <- ggplot(df_out, aes(x=Group, y=Expression, color=Group))
              p <- p + geom_beeswarm(size=input$Clinical_Mutation_Gene_expression_dot.size)
            }else if(input$Clinical_Mutation_Gene_expression_plot_type == 'D'){
              p <- p + geom_violin(trim = FALSE, size=0.2)
              p <- p + geom_jitter(width=0.1, height=0, size=input$Clinical_Mutation_Gene_expression_dot.size)
            }            
            p <- p + scale_fill_manual(name= NULL, 
              labels = c(paste0(gene_compare, '-Mutation (', length(df_mut_sample), ')'), paste0(gene_compare, '-Wild.type (', length(df_wt_sample), ')')),
              values = c('Mutation' = input$Clinical_Mutation_Gene_expression_col_mut, 'Wild.type' = input$Clinical_Mutation_Gene_expression_col_wt )
            )
            if(input$Clinical_Mutation_Gene_expression_plot_type == 'C'){
              p <- p + scale_color_manual(name= NULL, 
                labels = c(paste0(gene_compare, '-Mutation (', length(df_mut_sample), ')'), paste0(gene_compare, '-Wild.type (', length(df_wt_sample), ')')),
                values = c('Mutation' = input$Clinical_Mutation_Gene_expression_col_mut, 'Wild.type' = input$Clinical_Mutation_Gene_expression_col_wt )
              ) 
            }
            p <- p + theme(axis.text = element_text(size = input$Clinical_Mutation_Gene_expression_XY_label.font.size))
            p <- p + theme(axis.title = element_text(size = input$Clinical_Mutation_Gene_expression_XY_title.font.size))
            p <- p + ggtitle(gene_ex) + theme(plot.title = element_text(size = input$Clinical_Mutation_Gene_expression_title.font.size))
            p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
            p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
            p <- p + theme(legend.key.size = unit(1.5, "mm"))
            p <- p + theme(legend.text = element_text(size=input$Clinical_Mutation_Gene_expression_legend.font.size), legend.title = element_text(size=input$Clinical_Mutation_Gene_expression_legend.font.size))
            if(input$Clinical_Mutation_Gene_expression_white_background){
              p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
              p <- p + theme(panel.background = element_rect(fill="white", size=0))
              p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
            }
            p
          }, width=reactive(input$Clinical_Mutation_Gene_expression_fig.width), height=reactive(input$Clinical_Mutation_Gene_expression_fig.height), res=300)
        ##


      ##

    #### Cacner Gene Census (COSMIC)
      CGC_Database <- read.table('data/Cancer_Gene_Census_30_Mar_2025.tsv', sep='\t', header=T,check.names = FALSE)
      output$CGC_input_gene_from_custom_geneset_select <- renderUI({
        gene_sets_names <- c()
        gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
        selectInput('CGC_input_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
      })
      outputOptions(output, "CGC_input_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)

      CGC_input_genes <- reactive({
        if(input$CGC_input_gene_from_custom_geneset){
          if(input$CGC_input_gene_from_custom_geneset_select == 'None'){
            output$CGC_table_status <- renderText({"Please select a custom gene set. \nAll genes in the database are now shown."})
            return(NULL)
          }
          genes <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$CGC_input_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
        }else{
          if(nchar(input$CGC_input_gene) == 0){ # No input
            output$CGC_table_status <- renderText({"Please enter gene names. \nAll genes in the database are now shown."})
            return(NULL)
          }else{
            input_genes <- unlist(strsplit(input$CGC_input_gene, split = "\n"))
            input_genes <- intersect(CGC_Database[,'Gene Symbol'], input_genes)
            if(length(input_genes) == 0){
              output$CGC_table_status <- renderText({"Non of the inputted genes are includied in the database. \nAll genes in the database are now shown."})
              return(NULL)
            }else{
              return(input_genes)
            }
          }
        }
      })
      CGC_table_data <- reactive({
        if(is.null(CGC_input_genes())){
          CGC_Database_tmp <- CGC_Database
        }else{
          output$CGC_table_status <- renderText({NULL})
          CGC_Database_tmp <- CGC_Database[CGC_Database[,'Gene Symbol'] %in% CGC_input_genes(), ]
        }
        rownames(CGC_Database_tmp) <- CGC_Database_tmp[,'Gene Symbol']
        return(CGC_Database_tmp)
      })
      output$CGC_table <- renderDataTable({ 
        datatable(CGC_table_data(), options = list(scrollX = TRUE, pageLength = 10, fixedColumns = list(leftColumns=1)), rownames=TRUE) 
      })
      # download the table
      output$CGC_table_download <- downloadHandler(
        filename = function(){"Cancer_predisposition_genes.tsv"}, 
        content = function(fname){ write.table(CGC_table_data(), fname, sep='\t', row.names=F, quote=F) }
      )

    #### Compare cohorts
      ## input
        # cohort selection table
        output$Compare_across_cohorts_cohort_table <- renderDataTable({ 
          cohorts_list <- Cliniacal_dataset()$Database.Name
          data_table_tmp <- data.frame(Cohort=cohorts_list)
          datatable(data_table_tmp, selection = list(mode='multiple'), options = list(scrollX = TRUE, pageLength = 10, buttons=c('selectAll', 'selectNone'),dom='Blfrtip', rowId=0)) 
        })

        # gene selection table
        # select from custom gene sets
        output$Compare_across_cohorts_gene_from_custom_geneset_select <- renderUI({
          gene_sets_names <- c()
          gene_sets_names <- c(gene_sets_names, Original_geneset_lsit()$Geneset.name)
          selectInput('Compare_across_cohorts_gene_from_custom_geneset_select', 'Select a custom geneset',  c('None'='None', gene_sets_names))
        })
        outputOptions(output, "Compare_across_cohorts_gene_from_custom_geneset_select",  suspendWhenHidden=FALSE)

        output$Compare_across_cohorts_input_status <- renderText({'Please select a gene and cohorts to compare (more than one) below'})
        gene_list <- reactive({
          if(input$Compare_across_cohorts_gene_from_custom_geneset){
            if(input$Compare_across_cohorts_gene_from_custom_geneset_select == 'None'){
              output$Compare_across_cohorts_gene_table_status <- renderText({"Please select a custom gene set."})
              return(NULL)
            }
            gene_list <- strsplit(Original_geneset_lsit()[Original_geneset_lsit()$Geneset.name %in% input$Compare_across_cohorts_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
            return(data.frame(Gene=gene_list))
          }else{
            if(nchar(input$Compare_across_cohorts_gene) == 0){
              output$Compare_across_cohorts_gene_table_status <- renderText({"Please enter genes line by line."})
              return(NULL)
            }else{
              gene_list <- unlist(strsplit(input$Compare_across_cohorts_gene, split = "\n"))
              return(data.frame(Gene=gene_list))
            }
          }
        })
        output$Compare_across_cohorts_gene_table <- renderDataTable({ 
          if(is.null(gene_list())){
            datatable(data.frame(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)) 
          }else{
            output$Compare_across_cohorts_gene_table_status <- renderText({NULL})
            datatable(gene_list(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)) 
          }
          
        })
      ## mutation freq
        output$Compare_across_cohorts_mut_freq_plot_status <- renderText({'A plot for mutation counts or frequencies will be shown here'})
        output$Compare_across_cohorts_mut_freq_table_status <- renderText({'A table for Mutation counts or frequenceies will be shown here.'})
        outputOptions(output, "Compare_across_cohorts_mut_freq_plot_status", suspendWhenHidden=FALSE)
        outputOptions(output, "Compare_across_cohorts_mut_freq_table_status", suspendWhenHidden=FALSE)

        isCalculating <- reactiveVal(FALSE) 
        triggered <- reactiveVal(FALSE)
        Compare_cohort_mut_table <- reactiveVal()
        observeEvent(input$Compare_across_cohorts_mut_freq_start,{
          isCalculating(TRUE)   # 計算中フラグを立てる
          triggered(TRUE) 
          if(length(input$Compare_across_cohorts_gene_table_rows_selected) == 0){
            output$Compare_across_cohorts_input_status <- renderText({'Please select a gene'})
            Compare_cohort_mut_table(NULL)
            isCalculating(FALSE)
            return()
          }else if(length(input$Compare_across_cohorts_cohort_table_rows_selected) == 0){
            output$Compare_across_cohorts_input_status <- renderText({'Please select cohorts (more than one)'})
            Compare_cohort_mut_table(NULL)
            isCalculating(FALSE)
            return()
          }else{
            cohorts <- Cliniacal_dataset()[input$Compare_across_cohorts_cohort_table_rows_selected,]$Database.Name
            gene <- gene_list()[input$Compare_across_cohorts_gene_table_rows_selected,]
            df_out <- data.frame(Cohort=c(),Mutation.Patients=c(), Frequency=c())
            for (cohort in cohorts){
              if(file.exists(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == cohort, ]$Mutation_path)){
                mut <- data.frame(read.delim(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == cohort, ]$Mutation_path, header=T,check.names = FALSE))
                if(gene %in% mut$id){
                  mut_gene <- mut[mut$id == gene,] # df_mut_num$Frequence <- round(df_mut_num$Number_of_patients/N_sample * 100, 2)
                  df_tmp <- data.frame(Cohort=c(cohort),Mutation.Patients=c(length(unique(mut_gene$sample))), Frequency=c( round(length(unique(mut_gene$sample))/length(unique(mut$sample))*100, 2) ) )
                  df_out <- rbind(df_out, df_tmp)
                }
                rm(mut,mut_gene)
              }
            }
            if(length(df_out)==0){
              output$Compare_across_cohorts_input_status <- renderText({"None of the cohort has a mutation of the selected gene. Please check if the gene name are correct and do not have unnecessary spaces."})
              Compare_cohort_mut_table(NULL)
            }else{
              output$Compare_across_cohorts_input_status <- renderText({NULL})
              Compare_cohort_mut_table(df_out)
              isCalculating(FALSE)
              return()
            }
          }
        })

        output$Compare_across_cohorts_mut_freq_table <- renderDataTable({ 
          if(is.null(Compare_cohort_mut_table())){
            output$Compare_across_cohorts_mut_freq_table_status <- renderText({'A table for Mutation counts or frequenceies will be shown here.'})  
            datatable(data.frame(), options = list(scrollX = TRUE, pageLength = 10, fixedColumns = list(leftColumns=1)), rownames=TRUE)   
          }else{
            output$Compare_across_cohorts_mut_freq_table_status <- renderText({NULL})
            datatable(Compare_cohort_mut_table(), options = list(scrollX = TRUE, pageLength = 5, fixedColumns = list(leftColumns=1)), rownames=TRUE) 
          }
        })

        output$Compare_across_cohorts_mut_freq_plot <- renderPlot({
          if (!triggered()) {
            return(ggplot())
          }else if (isCalculating()) {
            return(ggplot()) # 計算中なら空データフレームを返してスピナーを出す
          }
          if(is.null(Compare_cohort_mut_table())){
            output$Compare_across_cohorts_mut_freq_plot_status <- renderText({'A plot for mutation counts or frequencies will be shown here'})
            return(ggplot())
          }
          df_tmp <- Compare_cohort_mut_table()
          if(input$Compare_across_cohorts_mut_freq_plot_type == 'A'){
            df_tmp <- df_tmp[order(df_tmp$Mutation.Patients, decreasing = T),]
            df_tmp$Cohort <- factor(df_tmp$Cohort, level=df_tmp$Cohort)
            p <- ggplot(df_tmp, aes(x=Cohort, y=Mutation.Patients, fill=Mutation.Patients))
          }else{
            df_tmp <- df_tmp[order(df_tmp$Frequency, decreasing = T),]
            df_tmp$Cohort <- factor(df_tmp$Cohort, level=df_tmp$Cohort)
            p <- ggplot(df_tmp, aes(x=Cohort, y=Frequency, fill=Frequency))
          }
          p <- p + geom_bar(stat = "identity")
          if(!input$Compare_across_cohorts_mut_hide_score){
            if(input$Compare_across_cohorts_mut_freq_plot_type == 'A'){
              p <- p + geom_text(aes(label=Mutation.Patients), vjust=-0.5, color='black',size=input$Compare_across_cohorts_mut_score_size)
            }else{
              p <- p + geom_text(aes(label=Frequency), vjust=-0.5, color='black',size=input$Compare_across_cohorts_mut_score_size)
            }
          }
          if(max(df_tmp$Frequency) > 0){
            if(input$Compare_across_cohorts_mut_freq_plot_type == 'A'){
              p <- p + scale_fill_gradientn( colors = c(input$Compare_across_cohorts_mut_colour_zero,input$Compare_across_cohorts_mut_colour_high ), values = scales::rescale(c(0, max(df_tmp$Mutation.Patients))) , limits = c(0, max(df_tmp$Mutation.Patients)), name=NULL)
            }else{
              p <- p + scale_fill_gradientn( colors = c(input$Compare_across_cohorts_mut_colour_zero,input$Compare_across_cohorts_mut_colour_high ), values = scales::rescale(c(0, max(df_tmp$Frequency))) , limits = c(0, max(df_tmp$Frequency)), name=NULL)
            }
          }else{
            p <- p + scale_fill_gradientn(name=NULL)
          }
          p <- p + theme(axis.text = element_text(size = input$Compare_across_cohorts_mut_label_size))
          p <- p + theme(axis.title = element_text(size = input$Compare_across_cohorts_mut_title_size))
          p <- p + theme(legend.key.size = unit(2, "mm"))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))          
          p <- p + theme(legend.text = element_text(size=input$Compare_across_cohorts_mut_legend_size))
          if(input$Compare_across_cohorts_mut_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
          output$Compare_across_cohorts_mut_freq_plot_status <- renderText({NULL})
          p
        }, width=reactive(input$Compare_across_cohorts_mut_fig.width), height=reactive(input$Compare_across_cohorts_mut_fig.height), res=300)

      ## Gene expression compare
        Compare_cohort_gx_table <- reactiveVal()
        isCalculating <- reactiveVal(FALSE) 
        triggered <- reactiveVal(FALSE)
        observeEvent(input$Compare_across_cohorts_gx_start,{
          isCalculating(TRUE)   # calculating flag
          triggered(TRUE) 
          if(length(input$Compare_across_cohorts_gene_table_rows_selected) == 0){
            output$Compare_across_cohorts_input_status <- renderText({'Please select a gene'})
            Compare_cohort_gx_table(NULL)
            isCalculating(FALSE)
            return()
          }else if(length(input$Compare_across_cohorts_cohort_table_rows_selected) == 0){
            output$Compare_across_cohorts_input_status <- renderText({'Please select cohorts (more than one)'})
            Compare_cohort_gx_table(NULL)
            isCalculating(FALSE)
            return()
          }else{
            cohorts <- Cliniacal_dataset()[input$Compare_across_cohorts_cohort_table_rows_selected,]$Database.Name
            gene <- gene_list()[input$Compare_across_cohorts_gene_table_rows_selected,]
            df_out <- data.frame(Cohort=c(), Expression=c())
            for (cohort in cohorts){
              if(file.exists(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == cohort, ]$Expression_path)){
                gx <- data.frame(read.delim(Cliniacal_dataset()[Cliniacal_dataset()$Database.Name == cohort, ]$Expression_path, header=T,check.names = FALSE))
                if(gene %in% gx$id){
                  gx_gene <- gx[gx$id == gene,] 
                  gx_gene <- gx_gene[!names(gx_gene) %in% 'id']
                  gx_gene <- na.omit(gx_gene)
                  df_tmp <- data.frame(Expression= as.numeric(gx_gene))
                  df_tmp$Cohort <- cohort
                  df_out <- rbind(df_out, df_tmp)
                }
                rm(gx,gx_gene)
              }
            }
            if(length(df_out)==0){
              output$Compare_across_cohorts_input_status <- renderText({"None of the cohort has the selected gene. Please check if the gene name are correct and do not have unnecessary spaces."})
              Compare_cohort_mut_table(NULL)
              isCalculating(FALSE)
              return()
            }else{
              output$Compare_across_cohorts_input_status <- renderText({NULL})
              Compare_cohort_gx_table(df_out)
              isCalculating(FALSE)
              return()
            }
          }
        })

        output$Compare_across_cohorts_gx_plot <- renderPlot({
          if (!triggered()) {
            return(ggplot())
          }else if (isCalculating()) {
            return(ggplot()) # 計算中なら空を返してスピナーを出す
          }
          if(is.null(Compare_cohort_gx_table())){
            output$Compare_across_cohorts_gx_plot_status <- renderText({'A plot for gene expression across cohorts will be shown here'})
            return(ggplot())
          }
          df_tmp <- Compare_cohort_gx_table()
          df_tmp_med <- tapply(df_tmp$Expression, df_tmp$Cohort, median)
          cohort_order <- names(df_tmp_med[order(df_tmp_med, decreasing=T)]) 
          df_tmp$Cohort <- factor(df_tmp$Cohort, levels=cohort_order)
          p <- ggplot(df_tmp, aes(x=Cohort, y=Expression, fill=Cohort))
          p <- p + geom_boxplot(size=0.2, outlier.size=0.5)
          p <- p + theme(axis.text = element_text(size = input$Compare_across_cohorts_gx_label_size))
          p <- p + theme(axis.title = element_text(size = input$Compare_across_cohorts_gx_title_size))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))          
          p <- p + theme(legend.position='none')
          if(input$Compare_across_cohorts_gx_white_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
          output$Compare_across_cohorts_gx_plot_status <- renderText({NULL})
          p
        }, width=reactive(input$Compare_across_cohorts_gx_fig.width), height=reactive(input$Compare_across_cohorts_gx_fig.height), res=300)

      ##

    ####

  ####

  ### Tools 
    #### human to mouse, mouse to human
      # status messages
        output$human_mouse_convert_status <- renderText({'Please enter gene names and set the input/output types, and click "Convert genes".'})
        output$human_mouse_convert_table_status <- renderText({ 'A conversion table will be shown here.' })
        output$human_mouse_convert_result <- renderText({'The converted genes will be listed up here'})
        outputOptions(output, "human_mouse_convert_status", suspendWhenHidden=FALSE)
        outputOptions(output, "human_mouse_convert_table_status", suspendWhenHidden=FALSE)
        outputOptions(output, "human_mouse_convert_result", suspendWhenHidden=FALSE)
      
      # conversion table
        human_mouse_convert_data <- reactiveVal(NULL)
        observeEvent(input$human_mouse_convert_start,{
          if(nchar(input$human_mouse_convert_input_gene) == 0){
            show_alert(title='Error.',text='Please enter genes.', type='error')
            output$human_mouse_convert_status <- renderText({'Please enter genes (line by line).'})
            output$human_mouse_convert_table_status <- renderText({ 'A conversion table will be shown here.' })
            output$human_mouse_convert_result <- renderText({'The converted genes will be listed up here'})
            human_mouse_convert_data(NULL)
            return(NULL)
          }
          input_genes <- unlist(strsplit(input$human_mouse_convert_input_gene, '\n')) # input_genes <- c('CXCL10', 'CXCL9', 'hoge')
          converted_df <- data.frame(input=input_genes)
          if(is.null(input$human_mouse_convert_direction)){
            show_alert(title='Error.',text='Please select the conversion direction.', type='error')
            output$human_mouse_convert_status <- renderText({'Please select the conversion direction.'})
            output$human_mouse_convert_table_status <- renderText({ 'A conversion table will be shown here.' })
            output$human_mouse_convert_result <- renderText({'The converted genes will be listed up here'})
            human_mouse_convert_data
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
            converted <- distinct(converted) 
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
            converted <- distinct(converted) 
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
          output$human_mouse_convert_status <- renderText({NULL})
          output$human_mouse_convert_table_status <- renderText({NULL})
          human_mouse_convert_data(converted)
          return(converted)
        })
      
      # show the conversion table
        output$human_mouse_convert_table <- renderDataTable({
          if(is.null(human_mouse_convert_data())){
            tmp <- data.frame(list('Human.Gene'=character(0), 'Mouse.Gene'=character(0)), stringsAsFactors = FALSE )
            datatable( tmp, options = list(scrollX = TRUE, pageLength = 10 )) 
          }else{
            datatable( human_mouse_convert_data(), options = list(scrollX = TRUE, pageLength = 10 )) 
          }
        })
      # 


    ### convert Ensembl to Gene symbol
      # status messages
        output$Gene_Ensembl_convert_status <- renderText({'Please enter gene names and set the input/output types, and click "Convert genes".'})
        output$Gene_Ensembl_convert_table_status <- renderText({ 'A conversion table will be shown here.' })
        output$Gene_Ensembl_convert_result <- renderText({'The converted genes will be listed up here'})
        outputOptions(output, "Gene_Ensembl_convert_status", suspendWhenHidden=FALSE)
        outputOptions(output, "Gene_Ensembl_convert_table_status", suspendWhenHidden=FALSE)
        outputOptions(output, "Gene_Ensembl_convert_result", suspendWhenHidden=FALSE)
      
      # conversion table
        Gene_Ensemble_convert_data <- reactiveVal(NULL)
        observeEvent(input$Gene_Ensembl_convert_start,{
          if(nchar(input$Gene_Ensembl_input_gene) == 0){
            show_alert(title='Error.',text='Please enter genes.', type='error')
            output$Gene_Ensembl_convert_status <- renderText({'Please enter genes (line by line).'})
            output$Gene_Ensembl_convert_table_status <- renderText({ 'A conversion table will be shown here.' })
            output$Gene_Ensembl_convert_result <- renderText({'The converted genes will be listed up here'})
            Gene_Ensemble_convert_data(NULL)
            return(NULL)
          }
          input_genes <- unlist(strsplit(input$Gene_Ensembl_input_gene, '\n')) # input_genes <- c('CXCL10', 'CXCL9', 'hoge', 'MYC')
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
            converted <- distinct(converted) # library(dplyr)
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
            converted <- distinct(converted) # library(dplyr)
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
          output$Gene_Ensembl_convert_table_status <- renderText({NULL})
          output$Gene_Ensembl_convert_status <- renderText({NULL})
          Gene_Ensemble_convert_data(converted)
          return(converted)
        })
        
      
      # show the conversion table
        output$Gene_Ensembl_convert_table <- renderDataTable({
          if(is.null(Gene_Ensemble_convert_data())){
            tmp <- data.frame(list('Gene.Symbol'=character(0), 'Ensembl.ID'=character(0)), stringsAsFactors = FALSE )
            datatable( tmp, options = list(scrollX = TRUE, pageLength = 10 )) 
          }else{
            datatable( Gene_Ensemble_convert_data(), options = list(scrollX = TRUE, pageLength = 10 )) 
          }
        })
      # 
    
    ### Find the genomic loci
      # status messages
        Gene_coords_GRch38 <- read.table('data/Gene_coords_GRch38.tsv', sep='\t', header=T,check.names = FALSE) # head(Gene_coords_GRch38)
        output$Find_genome_loci_status <- renderText({'Please enter the inputs, set the method and click "Search". '})
        output$Find_genome_loci_table_status <- renderText({'A table containing gene names and their genomic locus (chromosome number, start and end) will be displayed here.'})
        output$Find_genome_loci_table_gene_names <- renderText({'The gene names/genomic coordinates will be listed up here.'})
        outputOptions(output, "Find_genome_loci_status", suspendWhenHidden=FALSE)
        outputOptions(output, "Find_genome_loci_table_status", suspendWhenHidden=FALSE)
        outputOptions(output, "Find_genome_loci_table_gene_names", suspendWhenHidden=FALSE)

      # the main calculation
        output$Find_genome_loci_table <- renderDataTable({
          tmp <- data.frame(list('chr'=character(0), 'start'=character(0), 'end'=character(0), 'strand'=character(0), 'gene_id'=character(0), 'gene_name'=character(0)), stringsAsFactors = FALSE )
          datatable(tmp, options = list(scrollX = TRUE, pageLength = 10 ))
        })
        observeEvent(input$Find_genome_loci_start,{
          if(length(input$Find_genome_loci_direction) == 0){
            show_alert(title='Error.',text='Please select the method.', type='error')
            output$Find_genome_loci_status <- renderText({'Please choose the method.'})
            output$Find_genome_loci_table_status <- renderText({'A table containing gene names and their genomic locus (chromosome number, start and end) will be displayed here.'})
            output$Find_genome_loci_table_gene_names <- renderText({'The gene names/genomic coordinates will be listed up here.'})
            output$Find_genome_loci_table <- renderDataTable({
              tmp <- data.frame(list('chr'=character(0), 'start'=character(0), 'end'=character(0), 'strand'=character(0), 'gene_id'=character(0), 'gene_name'=character(0)), stringsAsFactors = FALSE )
              datatable(tmp, options = list(scrollX = TRUE, pageLength = 10 ))
            })
            return(NULL)
          }
          if(input$Find_genome_loci_direction == 'A'){
            if(nchar(input$Find_genome_loci_input) == 0){
              show_alert(title='Error.',text='Please enter gene names.', type='error')
              output$Find_genome_loci_status <- renderText({'Please enter gene names'})
              output$Find_genome_loci_table_status <- renderText({'A table containing gene names and their genomic locus (chromosome number, start and end) will be displayed here.'})
              output$Find_genome_loci_table_gene_names <- renderText({'The gene names/genomic coordinates will be listed up here.'})
              output$Find_genome_loci_table <- renderDataTable({
                tmp <- data.frame(list('chr'=character(0), 'start'=character(0), 'end'=character(0), 'strand'=character(0), 'gene_id'=character(0), 'gene_name'=character(0)), stringsAsFactors = FALSE )
                datatable(tmp, options = list(scrollX = TRUE, pageLength = 10 ))
              })
              return(NULL)
            }
            genes <- unlist(strsplit(input$Find_genome_loci_input, '\n')) # genes <- c('CXCL10', 'CXCL9')
            genes <- intersect(genes, Gene_coords_GRch38$gene_name)
            if(length(genes)==0){
              show_alert(title='Error.',text='None of the inputted genes are found.', type='error')
              output$Find_genome_loci_status <- renderText({'None of the inputted genes are found. \nPlease make sure that the gene names are correct and do not have unnecessary spaces.'})
              output$Find_genome_loci_table_gene_names <- renderText({'The gene names/genomic coordinates will be listed up here.'})
              output$Find_genome_loci_table_status <- renderText({'None of the inputted genes are found. \nPlease make sure that the gene names are correct and do not have unnecessary spaces.'})
              output$Find_genome_loci_table <- renderDataTable({
                tmp <- data.frame(list('chr'=character(0), 'start'=character(0), 'end'=character(0), 'strand'=character(0), 'gene_id'=character(0), 'gene_name'=character(0)), stringsAsFactors = FALSE )
                datatable(tmp, options = list(scrollX = TRUE, pageLength = 10 ))
              })
              return(NULL) 
            }
            Gene_coords_GRch38_focus <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name %in% genes,]
            coord <- paste0(Gene_coords_GRch38_focus$chr, ':', Gene_coords_GRch38_focus$start, '-',  Gene_coords_GRch38_focus$end)
            output$Find_genome_loci_table_gene_names <- renderText({ paste(coord, collapse='\n') })
            output$Find_genome_loci_table <- renderDataTable({
              datatable( Gene_coords_GRch38_focus, options = list(scrollX = TRUE, pageLength = 10 )) 
            })
            output$Find_genome_loci_status <- renderText({NULL})
            output$Find_genome_loci_table_status <- renderText({NULL})
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
              show_alert(title='Error.',text='No genes were found in the specified location.', type='error')
              output$Find_genome_loci_status <- renderText({'No genes were found in the specified location. \nPlease make sure the formats are correct and do not include unnecessary spaces. \n(Ex. chr1:76021118-76023497)'})
              output$Find_genome_loci_table_gene_names <- renderText({'None of the inputted genes are found. \nPlease make sure that the gene names are correct and do not have unnecessary spaces.'})
              return(NULL) 
            }
            genes <- Gene_coords_GRch38_focus$gene_name
            output$Find_genome_loci_table_gene_names <- renderText({ paste(genes, collapse='\n') })
            output$Find_genome_loci_table <- renderDataTable({
              datatable( Gene_coords_GRch38_focus, options = list(scrollX = TRUE, pageLength = 10 )) 
            })
            output$Find_genome_loci_status <- renderText({NULL})
            output$Find_genome_loci_table_status <- renderText({NULL})
          }
        })
      #
    
    ### Cross_tabulation analysis
      # input the parameter for the contingency table
        cross_table <- reactive({
          tmp <- data.frame(A=c(input$Cross_tabulation_val1,input$Cross_tabulation_val3), B=c(input$Cross_tabulation_val2,input$Cross_tabulation_val4))
          if(input$Cross_tabulation_Row1 == '' | input$Cross_tabulation_Row2 == ''){
            rownames(tmp) <- c('Row Group 1', 'Row Group 2')  
          }else{
            if(input$Cross_tabulation_Row1 == input$Cross_tabulation_Row2){
              output$cross_table_status <- renderText({"Row names are duplicated."})
              rownames(tmp) <- c('Row Group 1', 'Row Group 2')  
            }else{
              output$cross_table_status <- renderText({NULL})
              rownames(tmp) <- c(input$Cross_tabulation_Row1, input$Cross_tabulation_Row2)
            }
          }
          if(input$Cross_tabulation_col1 == '' | input$Cross_tabulation_col2 == ''){
            colnames(tmp) <- c('Column Group 1', 'Column Group 2')  
          }else{
            if(input$Cross_tabulation_col1 == input$Cross_tabulation_col2){
              output$cross_table_status <- renderText({"Column names are duplicated."})
              colnames(tmp) <- c('Column Group 1', 'Column Group 2')  
            }else{
              output$cross_table_status <- renderText({NULL})
              colnames(tmp) <- c(input$Cross_tabulation_col1, input$Cross_tabulation_col2)
            }
          }
          output$cross_table_status <- renderText({NULL})
          tmp        
        })
        
      # show table
        output$Cross_tabulation_table <- renderDataTable({
          datatable( cross_table()) 
        })

      # plot
        output$Cross_tabulation_plot <- renderPlot({
          df_cross <- cross_table()
          if(length(df_cross[is.na(df_cross)])>0){
            output$Cross_tabulation_plot_status <- renderText({'Please fill in the table first.'}) 
            return(ggplot())
          }else if(length(df_cross[df_cross==0])==4){
            output$Cross_tabulation_plot_status <- renderText({'Please fill in the table first.'}) 
            return(ggplot())         
          }
          col_group <- colnames(df_cross)
          df_cross$Row_group <- rownames(df_cross)
          df_cross_melt <- pivot_longer(df_cross, cols=-Row_group, names_to = 'Column_group')
          if(length(input$Cross_tabulation_plot_method) == 0){
            output$Cross_tabulation_plot_status <- renderText({'Please choose the plot method'}) 
            return(ggplot())
          }
          output$Cross_tabulation_plot_status <- renderText({NULL}) 
          p <- ggplot(df_cross_melt, aes(x=Row_group, y=value, fill=Column_group))
          if(input$Cross_tabulation_plot_method == 'A'){
            p <- p + geom_bar(stat='identity', position='fill')
            p <- p + ylab('Percentage')
          }else if(input$Cross_tabulation_plot_method == 'C'){
            p <- p + geom_bar(stat='identity')
            p <- p + ylab('Count')
          }else if(input$Cross_tabulation_plot_method == 'D'){
            p <- p + geom_bar(stat='identity', position='dodge')
            p <- p + ylab('Count')
          }
          p <- p + theme(axis.text = element_text(size = input$Cross_tabulation_plot_XY_label.font.size))
          p <- p + theme(axis.title = element_text(size = input$Cross_tabulation_plot_XY_title.font.size))
          p <- p + theme(axis.title.x= element_blank())
          p <- p + theme(legend.text = element_text(size = input$Cross_tabulation_plot_legend_size))
          p <- p + theme(legend.title = element_blank())
          colours <- setNames(c(input$Cross_tabulation_plot_col1_colour,input$Cross_tabulation_plot_col2_colour), col_group)
          p <- p + scale_fill_manual(values = colours)
          if(input$Cross_tabulation_plot_col2_colour_while_background){
            p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', size=0.1))
            p <- p + theme(panel.background = element_rect(fill="white", size=0))
            p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
          }
          if(input$Cross_tabulation_plot_rotate_x){
            if(!is.na(input$Cross_tabulation_plot_rotate_x_angle)){
              if(input$Cross_tabulation_plot_rotate_x_angle != ''){
                if(is.integer(input$Cross_tabulation_plot_rotate_x_angle)){
                  if( ( as.integer(input$Cross_tabulation_plot_rotate_x_angle) %% 90) == 0 ){
                    p <- p + theme(axis.text.x = element_text(angle = input$Cross_tabulation_plot_rotate_x_angle, vjust = 1, hjust= 0.5))
                  }else{
                    p <- p + theme(axis.text.x = element_text(angle = input$Cross_tabulation_plot_rotate_x_angle, vjust = 1, hjust= 1))
                  }
                }
              }

            }
          }
          p <- p + theme(legend.key.size = unit(2, "mm"))
          p <- p + theme(legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"))
          p <- p + theme(panel.grid.major = element_line(size = 0.1), panel.grid.minor = element_line(size = 0.05))  
          p <- p + theme(axis.ticks = element_line(size=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
          p

        }, width=reactive(input$Cross_tabulation_plot.width), height=reactive(input$Cross_tabulation_plot.height), res=300)

      # test
        output$cross_table_Statistic <- renderText({
          df_cross <- cross_table()
          if(length(df_cross[is.na(df_cross)])>0){
            'Please fill in the table first.'
          }else if(length(df_cross[df_cross==0])==4){
            'Please fill in the table first.'
          }else{
            if(input$cross_table_Statistic_method == 'A'){
              chi2_res <- chisq.test(cross_table())
              paste0('P-value: ', chi2_res$p.value)
            }else{
              fisher_res <- fisher.test(cross_table())
              paste0('P-value: ',fisher_res$p.value)
            }
          }
        })
      #

    ### Venn Diagram
      venn_data <- reactive({
        if(length(input$Venn_Diagram_method) == 0){
          output$Venn_Diagram_status <- renderText({'Please choose the method.'})
          return(NULL)
        }
        if(input$Venn_Diagram_Group1_name == '' | input$Venn_Diagram_Group2_name == ''){
          output$Venn_Diagram_status <- renderText({'Please fill in the Group 1 & 2 name.'})
          return(NULL)
        }
        if(nchar(input$Venn_Diagram_Group1_element)==0 | nchar(input$Venn_Diagram_Group2_element)==0){
          output$Venn_Diagram_status <- renderText({'Please fill in the element Group 1 & 2 name.'})
          return(NULL)
        }
        output$Venn_Diagram_status <- renderText({NULL})
        # 2D
        if(input$Venn_Diagram_method == 'A'){
          group1_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group1_element, split = "\n")))
          group2_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group2_element, split = "\n")))
          tmp <- list(group1_name = group1_elements, group2_name=group2_elements)
          return(tmp)
        }else if(input$Venn_Diagram_method == 'B'){ # 3D
          if(input$Venn_Diagram_Group1_name == '' | input$Venn_Diagram_Group2_name == '' | input$Venn_Diagram_Group3_name == ''){
            output$Venn_Diagram_status <- renderText({'Please fill in the Group 1 & 2 & 3 name.'})
            return(NULL)
          }
          if(nchar(input$Venn_Diagram_Group1_element)==0 | nchar(input$Venn_Diagram_Group2_element)==0 | nchar(input$Venn_Diagram_Group3_element)==0){
            output$Venn_Diagram_status <- renderText({'Please fill in the element Group 1 & 2 & 3 name.'})
            return(NULL)
          }
          output$Venn_Diagram_status <- renderText({NULL})
          group1_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group1_element, split = "\n")))
          group2_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group2_element, split = "\n")))
          group3_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group3_element, split = "\n")))
          tmp <- list(group1_name = group1_elements, group2_name=group2_elements, group3_name=group3_elements)
          return(tmp)
        }else{
          return(NULL)
        }

      })

      output$Venn_Diagram_plot <- renderPlot({
        if(is.null(venn_data())){
          return(ggplot())
        }
        euler_data <- euler(venn_data())
        if(input$Venn_Diagram_method == 'A'){
          plot(euler_data,
            fills = list(fill=c(input$Venn_Diagram_plot_col1_colour, input$Venn_Diagram_plot_col2_colour), alpha=0.7),
            quantities = list(cex = input$Venn_Diagram_plot_label.font.size),
            legend = list(labels = c(input$Venn_Diagram_Group1_name, input$Venn_Diagram_Group2_name), cex = input$Venn_Diagram_plot_legend_size)
          )
        }else if(input$Venn_Diagram_method == 'B'){
          plot(euler_data,
            fills = list(fill=c(input$Venn_Diagram_plot_col1_colour, input$Venn_Diagram_plot_col2_colour, input$Venn_Diagram_plot_col3_colour), alpha=0.7),
            quantities = list(cex = input$Venn_Diagram_plot_label.font.size),
            legend = list(labels = c(input$Venn_Diagram_Group1_name, input$Venn_Diagram_Group2_name, input$Venn_Diagram_Group3_name), cex = input$Venn_Diagram_plot_legend_size)
          )
        }
      }, width=reactive(input$Venn_Diagram_plot.width), height=reactive(input$Venn_Diagram_plot.height), res=300)

      output$Venn_Diagram_show_overlap_2D_list <- renderText({
        venn_data <- venn_data()
        if(input$Venn_Diagram_show_overlap_2D == 'None'){ NULL }
        else if(input$Venn_Diagram_show_overlap_2D == 'in Group1 & Group2'){ paste(intersect(venn_data$group1_name,venn_data$group2_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_2D == 'only in Group1'){ paste(setdiff(venn_data$group1_name,venn_data$group2_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_2D == 'only in Group2'){ paste(setdiff(venn_data$group2_name,venn_data$group1_name), collapse='\n') }
      })

      output$Venn_Diagram_show_overlap_3D_list <- renderText({
        venn_data <- venn_data()
        if(input$Venn_Diagram_show_overlap_3D == 'None'){ NULL }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2 & Group3'){ paste( intersect(intersect(venn_data$group1_name,venn_data$group2_name),venn_data$group3_name ), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2'){ paste( intersect(venn_data$group1_name,venn_data$group2_name) , collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group2 & Group3'){ paste( intersect(venn_data$group2_name,venn_data$group3_name) , collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group3 and Group1'){ paste( intersect(venn_data$group3_name,venn_data$group1_name) , collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2 but not in Group3'){ paste( setdiff( intersect(venn_data$group1_name,venn_data$group2_name) ,venn_data$group3_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group2 & Group3 but not in Group1'){ paste( setdiff( intersect(venn_data$group2_name,venn_data$group3_name) ,venn_data$group1_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'in Group3 & Group1 but not in Group2'){ paste( setdiff( intersect(venn_data$group3_name,venn_data$group1_name) ,venn_data$group2_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group1'){ paste( setdiff( setdiff(venn_data$group1_name,venn_data$group2_name), venn_data$group3_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group2'){ paste( setdiff( setdiff(venn_data$group2_name,venn_data$group3_name), venn_data$group1_name), collapse='\n') }
        else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group3'){ paste( setdiff( setdiff(venn_data$group3_name,venn_data$group1_name), venn_data$group2_name), collapse='\n') }
      })

    ### Netwrok plot
      # load data
        Network_input_data <- reactiveVal(NULL)
        observe({
          if(input$Network_input_example){
            edges <- data.frame(
              from = c("STAT1", "STAT1", "STAT1", "STAT1", "STAT2", "STAT2", "STAT2", "STAT3", "STAT3", "STAT3", "STAT3", "STAT5", "STAT5", "STAT5", "STAT3", "STAT5", "STAT1", "STAT2", "STAT2", "STAT3", "STAT1", "STAT2", "STAT3", "STAT5"),
              to = c("IRF1", "GBP1", "ISG15", "MX1", "ISG15",  "IRF9", "OAS1", "SAA1", "CRP", "VEGF", "MYC", "CSN2", "WAP", "BCL2L1",  "BCL2L1", "CISH", "IL6", "MX1", "IL6", "IL6", "SOCS1", "SOCS1", "SOCS1", "SOCS1"),
              weight = c(10.0, 5.8, 2.9, 1.7, 10.9,  0.5, 12.0, 5.8, 1.9, 3.7, 1.0, 2.8, 7.9, 1.7, 5.0, 8.8, 6.0, 1.9, 2.9,10.9, 10.0, 5.0, 6.0, 8.0)
            )
            Network_input_data(edges)
            return()
          }else{
            if(length(input$Network_input_file) == 0){
              output$Network_input_table_visNet_status <- renderText({'Please input the data'})
              Network_input_data(NULL)
              return(NULL)
            }else{
              req(input$Network_input_file)  # ファイルがアップロードされたら処理を続行
              edges <- read.delim(input$Network_input_file$datapath, header = TRUE, stringsAsFactors = FALSE, sep='\t',check.names = FALSE)
              Network_input_data(edges)
              return()
            }
          }
        })

      # show the data as a table
        output$Network_input_table <- DT::renderDataTable({ 
          if(!is.null(Network_input_data())){
            datatable(Network_input_data(), options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10)) 
          }else{
            tmp <- data.frame(list(from=character(0), to=character(0), weight=numeric(0)), stringsAsFactors = FALSE )
            datatable(tmp, options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10)) 
          }
        })

      # show plot
        library(igraph)
        output$Network_input_table_visNet_status <- renderText({'Please input the data'})
        output$Network_input_table_visNet <- renderVisNetwork({
          if(is.null(Network_input_data())){
            output$Network_input_table_visNet_status <- renderText({'Please input the data'})
            return(ggplot())
          }
          if(length(Network_input_data())== 0 ){
            output$Network_input_table_visNet_status <- renderText({'Please input the data'})
            return(ggplot())
          }
          output$Network_input_table_visNet_status <- renderText({NULL})
          graph <- graph_from_data_frame(Network_input_data(), directed = TRUE)
          V(graph)$size <- igraph::degree(graph)
          V(graph)$size <- 5 + (V(graph)$size - min(V(graph)$size)) / (max(V(graph)$size) - min(V(graph)$size)) * 25
          nodes <- data.frame(id = V(graph)$name, 
                              label = V(graph)$name, 
                              size = V(graph)$size)
          nodes$shape <- ifelse(nodes$label %in% unique(Network_input_data()$from), input$Network_input_shape_from, input$Network_input_shape_to)
          nodes$color <- ifelse(nodes$label %in% unique(Network_input_data()$from), input$Network_input_color_from, input$Network_input_color_to)
          edges <- data.frame(from = Network_input_data()$from, 
                              to = Network_input_data()$to,
                              width = Network_input_data()$weight)
          if(input$Network_input_arrow){
            edges$arrows <- 'to'
          }
                
          network <- visNetwork(nodes, edges, height = "1000px", width = "100%")
          network <- visOptions(network, highlightNearest = TRUE, nodesIdSelection=TRUE)
          network

        })
      #

    ###


  ###

  ### Wiki-document ##########################
    output$session_info <- renderText({
      input$session_info_refresh  # trigger dependency
      isolate({
        paste(capture.output(sessionInfo()), collapse = "\n")
      })
    })
  ### 
}



# Run the app
shinyApp(ui, server)




