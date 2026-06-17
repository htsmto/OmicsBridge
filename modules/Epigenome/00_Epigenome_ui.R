source("modules/Epigenome/01_Epigenome_profile_UI.R")
source("modules/Epigenome/02_Epigenome_genomevisualisation_UI.R")
source("modules/Epigenome/03_Epigenome_igv_UI.R")
source("modules/Epigenome/04_Epigenome_findEnhancerPromoter_UI.R")
source("modules/Epigenome/05_Epigenome_motifScan_UI.R")


Epigenome_UI <- function(ns) {
    tagList(
    h2('Epigenetic Data Analysis'),
    tabsetPanel(
        tabPanel( 'Profile plot', Epigenome_profile_UI(ns)),
        tabPanel('Genome visualisation', Epigenome_genomevisualisation_UI(ns)),
        tabPanel( 'IGV', Epigenome_igv_UI(ns)),
        tabPanel('Find Enhancer/Promoter', Epigenome_findEnhancerPromoter_UI(ns)),
        tabPanel('Motif Scan', Epigenome_motifScan_UI(ns))
    )
    )
}