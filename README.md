# OmicsBridge

## Overview

OmicsBrige is....
You can use OmicsBridge in a stand alone web interface at XXX.
There, the uploaded data will be deleted after you close the tab.
If you want to deploy OmicsBridge in your local environment, please follow the instructions below.

![Interface overview](www/interface_overview.png)

## Installation and usage

### Run on your local PC

Plase make a clone of this repository first. In the terminal,

```bash
git clone https://github.com/htsmto/OmicsBridge.git
cd OmicsBridge
```

<details>
<summary> do not have git installed in your PC?</summary>

> Please go to 'Code' > 'Download ZIP' on teh top right of this page, and you will get 'OmicsBridge-main.zip'. Please place this file in your desired folder and uncompress.

</details>
<br>

Please download the necessary data, uncompress and deploy the folder to the correct position. In the terminal,
```bash
curl -O https://d250-shiny2.inet.dkfz-heidelberg.de/users/h023o/in_house_screening/00_Clinical_dataset.tar.gz
tar -xzvf 00_Clinical_dataset.tar.gz 
```

Please make sure that all the dependencies are ready (Read below). 
<p>

Once you are ready, open R in a terminal (or in a console in R studio), and

```R
shiny::runApp('app.R')
```

The interface will open in your brower.
If not, check the console and find `Listening on http://127.0.0.1:XXXX`. Please go to your browser and enter `http://127.0.0.1:XXXX` in the URL bar.

### Run on a Shiny server


## Dependency

To use OmicsBridge, R is requrired and version should be >=4.4.0. We confirmed that R 4.2 or R 4.3 can be also okay for most of the functions, but some functions (ex. GSVA packages) will cause some errors, so we recommend to install the latest version of R.

The necessary R libraries can be installed in the either way in the follwings:

### Manually install the necessary libraries

Installing via the renv library can be OS specifc. If it does not work, please install the following packages manually to your R environment.

```R
## CRAN dependent packages
install.packages(c('shiny','shinydashboard','eulerr','ggplot2', 'ggbeeswarm','patchwork','igraph','tidyr','dplyr','DT','ggrepel','tibble','forcats', 'colourpicker', 'devtools','stringr', 'Cairo', 'Seurat', 'reshape2', 'cowplot', 'survival', 'survminer',"BiocManager", 'visNetwork'))

## BiocManager dependent packages
BiocManager::install(version = "3.20")
BiocManager::install(c("GSEABase",'GSVA','fgsea',"clusterProfiler","org.Hs.eg.db","org.Mm.eg.db","decoupleR","igvShiny","GenomicAlignments"))

## Other packages
devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")
devtools::install_github('dviraran/xCell')

```

<details>
<summary> cannot install some libraries?</summary>

> Please install the library one by one, not all in once. If you are a Mac user, installing [XQuartz](https://www.xquartz.org/) can solve the problem.

</details>



If you cannot install BiocManager >= 3.20 due to the version of R, you may install the libraries from your available BiocManager version. But we highly recommend to use >=3.20.


### Using renv

The renv package is a tool for managing project-specific package dependencies in R.

```R
install.packages('rnev') # skippable if you already have rnev

## For Linux (Ubuntsu)
renv::restore(lockfile='renv.lock')
## For Mac
renv::restore(lockfile='renv_Mac.lock')

# Please type '1' (1: Activate the project and use the project library) when you are asked "How would you like to proceed?"
# Please just type 'y' when you are asked "Do you want to proceed? [Y/n]:"


```

<details>
<summary> cannot install renv?</summary>

> If you are a Mac user, downloading Xcode (or upgrating it) via app store and XQuartz from [here](https://www.xquartz.org/) may solve this problem.

</details>

<br>
Depends on the OS, it usually takes 15-30 minutes.

