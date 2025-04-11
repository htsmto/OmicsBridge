# OmicsBridge

## Overview

OmicsBrige is an intuitive platform that integrates and visualises diverse omics datasets. Our tool assists researchers in identifying key genes with functional and clinical relevance, supporting hypothesis generation. It also functions as a centralised database for efficient data storage and access, minimising scattered datasets and enhancing overall data accessibility.


You can use OmicsBridge in a stand alone web interface at https://omicsbridge.dkfz.de.
There, the uploaded data will be deleted after you close the tab.
If you want to deploy OmicsBridge in your local environment, please follow the instructions below.

![Interface overview](www/interface_overview.png)

## Installation

Plase make a clone of this repository first. In the terminal,

```bash
git clone https://github.com/Immune-Regulation-in-Cancer/OmicsBridge.git
cd OmicsBridge
```

Or, download the zip file from [here](https://omicsbridge.dkfz.de/OmicsBridge.zip), and umcompress it.


Please download the necessary data, uncompress and deploy the folder in the `OmicsBridge` folter.
```bash
curl -O https://omicsbridge.dkfz.de/00_Clinical_dataset.tar.gz
curl -O https://omicsbridge.dkfz.de/00_Expression_data_all.tar.gz
tar -xzvf 00_Clinical_dataset.tar.gz
tar -xzvf 00_Expression_data_all.tar.gz 
```

Or, copy the links above and paste in a browser to download the files, umcompress and diploy them inside the OmicsBridge folder.

Please make sure that all the dependencies are ready (Read below). 
<p>

Once you are ready, open R in a terminal (or in a console in R studio), and

```R
shiny::runApp('app.R')
```

The interface will open in your brower.
If not, check the console and find `Listening on http://127.0.0.1:XXXX`. Please go to your browser and enter `http://127.0.0.1:XXXX` in the URL bar.

<p>

If you have a shiny server, please deploy the folder in the shiny home. You can access the interface via `https://(Your-shiny-server-address)/OmicsBridge`

## Dependency

To use OmicsBridge, R is requrired and version should be >=4.4.0. We confirmed that R 4.2 or R 4.3 can be also okay for most of the functions, but some functions (ex. GSVA packages) will cause some errors, so we recommend to install the latest version of R.

The necessary R libraries can be installed as the follwings:

### Manually install the necessary libraries

Installing via the renv library can be OS specifc. If it does not work, please install the following packages manually to your R environment.

```R
## CRAN dependent packages
install.packages(c('shiny','shinydashboard','eulerr','ggplot2', 'ggbeeswarm','patchwork','igraph','tidyr','dplyr','DT','ggrepel','tibble','forcats', 'colourpicker', 'devtools','stringr', 'Cairo', 'Seurat', 'reshape2', 'cowplot', 'survival', 'survminer',"BiocManager", 'visNetwork'))

## BiocManager dependent packages
BiocManager::install(version = "3.20")
BiocManager::install(c("GSEABase",'GSVA','fgsea',"clusterProfiler","org.Hs.eg.db","org.Mm.eg.db","decoupleR","igvShiny","GenomicAlignments", "AUCell"))

## Other packages
devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")
devtools::install_github('dviraran/xCell')

```

If you cannot install BiocManager >= 3.20 due to the version of R, you may install the libraries from your available BiocManager version. But we highly recommend to use >=3.20.

Depends on the system, it usually takes 30-45 minutes to install all the dependencies.


### Using renv

The renv package is a tool for managing project-specific package dependencies in R. We provide a lockfile for Ubuntsu and MacOS in case you restore the R environemnt via renv.

```R
install.packages('rnev') # skippable if you already have rnev

## For Linux (Ubuntsu)
renv::restore(lockfile='renv.lock')
## For Mac
renv::restore(lockfile='renv_Mac.lock')

# Please type '1' (1: Activate the project and use the project library) when you are asked "How would you like to proceed?"
# Please just type 'y' when you are asked "Do you want to proceed? [Y/n]:"

```

<br>
Depends on the OS, it usually takes 15-30 minutes.

## How to use?

Please refer to the Wiki in the interface. We provide concise instructions and short demo videos for each visualisation and analysis there.