# OmicsBridge

## Overview

OmicsBrige is....

![Interface overview](www/interface_overview.png)

## Installation

### Dependency

To use OmicsBridge, R >= 4.4.0 is requrired. R=4.2 or R=4.3 can be also okay, but some functions (ex. GSVA packages) will make an error, so we recommend to install the latest version of R.

The necessary R library can be installed as following:

#### (recommend) Using renv

The renv package is a tool for managing project-specific package dependencies in R.

```R
install.packages('renv')
renv::restore(lockfile='renv.lock')
```
Please type "Y" to proceed.
```
Do you want to proceed? [Y/n]: y
```
Depends on the OS, it usually takes 15-30 minutes.

#### Manually install the necessary libraries

Please install the following packages to your environment.

```R
## CRAN dependent packages
install.packages(c('shiny','shinydashboard','ggplot2', 'ggbeeswarm','patchwork','igraph',
  'tidyr','dplyr','DT','ggrepel','tibble','forcats', 'colourpicker', 'devtools',
  'stringr', 'Cairo', 'Seurat', 'reshape2', 'cowplot', 'survival', 'survminer',))

## BiocManager dependent packages
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(version = "3.20")
BiocManager::install(c("GSEABase", 'GSVA','fgsea',"clusterProfiler","org.Hs.eg.db","org.Mm.eg.db",
      "decoupleR","igvShiny","GenomicAlignments"))

## Other packages
devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")
devtools::install_github('dviraran/xCell')

```
