sidebar <- dashboardSidebar(width = 300, collapsed = TRUE, 
    sidebarMenu(id='sidebar',
        menuItem("Home", tabName='home', icon=icon('home')),
        menuItem("Database and Data Upload", tabName='Database', icon=icon('table')),
        menuItem("Transcriptome analysis", tabName='Data_Overview', icon=icon('chart-bar')),
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
        style = "position: absolute; bottom: 10px; width: 100%; text-align: center;",
        tags$img(src = 'DKFZ_blue.png', width= "80%")
    )
)