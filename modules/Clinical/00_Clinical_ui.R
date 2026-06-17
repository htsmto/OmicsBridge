source("modules/Clinical/01_clinical_DataSelection_ui.R")
source("modules/Clinical/02_clinical_ViewData_ui.R")
source("modules/Clinical/03_clinical_Survival_ui.R")
source("modules/Clinical/04_clinical_GeneCorrelation_ui.R")
source("modules/Clinical/05_clinical_Mutation_ui.R")
source("modules/Clinical/06_clinical_ExpressionCompare_ui.R")
source("modules/Clinical/07_clinical_Signature_ui.R")
source("modules/Clinical/08_clinical_Deconvolution_ui.R")
source("modules/Clinical/09_clinical_CompareCohorts_ui.R")
source("modules/Clinical/10_clinical_COSMIC_ui.R")
source("modules/Clinical/11_clinical_upload_ui.R")


Clinical_UI <- function(ns) {
  tabItem(tabName = "Clinical_dataset",
    h2(' Clinical data'),
    clinical_DataSelection_ui(ns),
    box(width=12, status='primary', solidHeader = TRUE, title='Overview and Analysis', collapsible=TRUE,
      tabsetPanel(
        tabPanel(strong("Data View"), clinical_ViewData_ui(ns)),
        tabPanel(strong("Survival analysis"), clinical_Survival_ui(ns)),
        tabPanel(strong("Gene correlation"), clinical_GeneCorrelation_ui(ns)),
        tabPanel(strong("Mutation analysis"), clinical_Mutation_ui(ns)),
        tabPanel(strong("Expression comparison"), clinical_ExpressionCompare_ui(ns)),
        tabPanel(strong("Signature analysis"), clinical_Signature_ui(ns)),
        tabPanel(strong("Deconvolution"), clinical_Deconvolution_ui(ns)),
        tabPanel(strong("Compare cohorts"), clinical_CompareCohorts_ui(ns)),
        tabPanel(strong("COSMIC"), clinical_COSMIC_ui(ns)),
        tabPanel(strong("Upload data"), clinical_upload_ui(ns))
      )
    )
  )
}
