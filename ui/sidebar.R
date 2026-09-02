sidebar <- dashboardSidebar(width = 300, collapsed = TRUE, 
    sidebarMenu(id='sidebar',
        menuItem("Home", tabName='home', icon=icon('home')),
        menuItem("Database and Data Upload", tabName='Database', icon=icon('table')),
        menuItem("Count & Comparison Data Overview", tabName='Data_Overview', icon=icon('chart-bar')),
        menuItem("Compare across datasets", tabName='Compare_across_datasets', icon=icon('chart-bar')),
        menuItem("Integrate two data", tabName='Integrate_two_dataset', icon=icon('chart-bar')),
        menuItem("Clinical data analysis", tabName='Clinical_dataset', icon=icon('chart-bar')),
        menuItem("scRNAseq analysis", tabName='scRNA', icon=icon('chart-bar')),
        menuItem("Epigenome Visualisation", tabName='igv', icon=icon('chart-bar')),
        menuItem("Custom Gene sets", tabName='Original_geneset', icon=icon('gear')),
        menuItem("Tools", tabName='Tools', icon=icon('wrench')),
        menuItem("Wiki(Document)", tabName='wiki_document', icon=icon('book'))
    ),
    tags$div(
        class = "sysmon-panel",
        style = "padding: 12px 12px; margin-top: 5px; border-top: 1px solid #eee;",
        # AdminLTE's default sidebar text color is light gray, meant for a
        # dark sidebar background — but custom.css sets .main-sidebar to
        # white, so progressBar()'s title/number text is nearly invisible
        # without this override. Also: size="xs" bars are only 7px tall (see
        # AdminLTE.css .progress-xs), too short to fit the in-bar "NN%" text
        # at all, which is why the score wasn't visible — bump the height so
        # it fits comfortably.
        tags$style(HTML("
            .sysmon-panel .progress-text,
            .sysmon-panel .progress-number {
                color: #000000 !important;
                font-weight: 600;
                font-size: 13px;
            }
            .sysmon-panel .progress {
                height: 22px;
                margin-bottom: 12px;
            }
            .sysmon-panel .progress-bar {
                font-size: 12px;
                line-height: 22px;
            }
            .sysmon-panel .cpu-percore-line {
                color: #000000 !important;
                font-size: 12px;
                padding-left: 2px;
                margin-bottom: 2px;
            }
        ")),
        shinyWidgets::progressBar(id = "mem_usage_bar", value = 0, total = 100, display_pct = TRUE,
                                   title = "RAM usage", status = "info"),
        shinyWidgets::progressBar(id = "cpu_usage_bar", value = 0, total = 100, display_pct = TRUE,
                                   title = paste0("CPU usage (", ps::ps_cpu_count(), " cores)"), status = "info"),
        uiOutput("cpu_percore_usage")
    ),
    tags$div(
        style = "position: absolute; bottom: 10px; width: 100%; text-align: center;",
        tags$img(src = 'DKFZ_blue.png', width= "80%")
    )
)