source("ui/home.R")
source("modules/Database_module.R")
source("modules/DataOverview_module.R")
source("modules/Tools_module.R")
source("modules/Original_geneset_module.R")
source("modules/wiki_document_module.R")
source("modules/scRNA_module.R")
source("modules/DatasetsCompare_module.R")
source("modules/Clinical_module.R")
source("modules/IntegrateTwoDataset_module.R")
source("modules/Epigenome_module.R")


body <- dashboardBody(
  useShinyjs(),
  tabItems(
    tabItem("home",   
      homeTabUI()
    ),
    tabItem("Database", 
      databaseModuleUI("db")
    ),
    tabItem("Data_Overview", 
      dataoverviewModuleUI("data_overview")
    ),
    tabItem("Compare_across_datasets", 
      DatasetsCompareModuleUI("datasets_compare")
    ),
    tabItem("Integrate_two_dataset", 
      IntegrateTwoDatasetModuleUI("integrate_two_dataset")
    ),
    tabItem("Clinical_dataset", 
      clinicalModuleUI("clinical")
    ),
    tabItem("scRNA", 
      scRNAModuleUI("scRNA")
    ),
    tabItem("igv", 
      EpigenomeModuleUI("igv")
    ),
    tabItem("Original_geneset",
      originalgenesetModuleUI("original_geneset")
    ),
    tabItem("Tools", 
      toolsModuleUI("tools")
    ),
    tabItem("wiki_document", 
      wiki_documentModuleUI("wiki_document")
    )

  ),
  ## Footer
  tags$div(class = "app-footer",
    "OmicsBridge | Version 1.3.0 | Last updated: 31st August 2026", tags$br(),
    "© 2026, Immune Regulation in Cancer, German Cancer Research Center (DKFZ).", tags$br(),
    tags$a(
      href = "https://github.com/htsmto/OmicsBridge",
      target = "_blank",
      "GitHub"
    )
  )
)
