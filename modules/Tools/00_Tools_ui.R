source("modules/Tools/01_Tools_HumanMouse_ui.R")
source("modules/Tools/02_Tools_SymbolEns_ui.R")
source("modules/Tools/03_Tools_FindLoci_ui.R")
source("modules/Tools/04_Tools_CrossTabular_ui.R")
source("modules/Tools/05_Tools_VennDiagram_ui.R")
source("modules/Tools/06_Tools_NetworkPlot_ui.R")

tools_UI <- function(ns) {
  tabItem(tabName = "Tools",
    h2('Tools'),
    tabsetPanel(
        tabPanel(strong('Human <=> Mouse'),
          tools_humanmouse_UI(ns)
        ),
        tabPanel(strong('Gene Symbol <=> Ensembl'),
          tools_symbolens_UI(ns)
        ),
        tabPanel(strong('Find Gene Positions/Annotations'),
          tools_findloci_UI(ns)
        ),
        tabPanel(strong('Cross-Tabulation Analysis'),
          tools_crosstabular_UI(ns)
        ),
        tabPanel(strong('Venn Diagram'),
          tools_venndiagram_UI(ns)
        ),
        tabPanel(strong('Network Plot'),
          tools_networkplot_UI(ns)
        )
    )

  )
}
