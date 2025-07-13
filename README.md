# OmicsBridge

## Overview

OmicsBridge is an intuitive platform that integrates and visualizes diverse omics datasets. Our tool helps researchers identify key genes with functional and clinical relevance, supporting hypothesis generation. It also serves as a centralized database for efficient data storage and access, reducing scattered datasets and improving overall data accessibility.

You can use OmicsBridge through a standalone web interface at [https://omicsbridge.dkfz.de](https://omicsbridge.dkfz.de/).
Please note that uploaded data will be deleted after you close the tab.
If you want to deploy OmicsBridge in your local environment, please follow the instructions below.

![Interface overview](docs/img/interface_overview.png)

## Installation

Please clone this repository first. In the terminal:

```bash
git clone https://github.com/Immune-Regulation-in-Cancer/OmicsBridge.git
cd OmicsBridge
```

Or, download the zip file from [here](https://omicsbridge.dkfz.de/OmicsBridge.zip) and uncompress it.

Next, download the necessary data, uncompress and place the folders in the `OmicsBridge` directory:

```bash
curl -O <https://omicsbridge.dkfz.de/00_Clinical_dataset.tar.gz>
curl -O <https://omicsbridge.dkfz.de/00_Expression_data_all.tar.gz>
tar -xzvf 00_Clinical_dataset.tar.gz
tar -xzvf 00_Expression_data_all.tar.gz

# the final file structure:
# .
# ├── 00_Clinical_dataset
# ├── 00_Expression_data_all
# ├── app.R
# ├── data
# ├── docs
# ├── mkdocs.yml
# ├── README.md
# ├── wiki
# └── www
```

Alternatively, copy the links above and paste them in a browser to download the files, then uncompress and place them inside the OmicsBridge folder.

## Dependencies

### Docker Image

We provide a Docker image available from Docker Hub:
```bash
docker pull htsmto/omicsbridge:latest
```

### Manual Installation of Required Libraries

OmicsBridge requires R version 4.2.0 or higher. While it may work with earlier versions, some packages (such as GSVA) might cause unexpected errors. Please install the following libraries and ensure you install BiocManager version 3.20 or higher.

```R
## CRAN dependent packages
install.packages(c('shiny','shinydashboard','eulerr','ggplot2', 'ggbeeswarm','patchwork','igraph','tidyr','dplyr','DT','ggrepel','tibble','forcats', 'colourpicker', 'devtools','stringr', 'Cairo', 'Seurat', 'reshape2', 'cowplot', 'survival', 'survminer',"BiocManager", 'visNetwork'))

## BiocManager dependent packages
BiocManager::install() # Make sure to install >3.20
BiocManager::install(c("GSEABase",'GSVA','fgsea',"clusterProfiler","org.Hs.eg.db","org.Mm.eg.db","decoupleR","igvShiny","GenomicAlignments", "AUCell"))

## Other packages
devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")
devtools::install_github('dviraran/xCell')
```

## Launching the App
Open your terminal. If you are using a Docker image:

```R
docker run -it --rm \
  -v ${Your_path_to_OmicsBridge_directory}:/app \
  -w /app \
  -p 4191:4191 \
  htsmto/omicsbridge \
  Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=4191)"
```

You can customise the port number (4191 in this example) as needed. Once running, open `http://localhost:4191` in your browser.
If you're using your local R environment instead of Docker:

```R
cd ${Your_path_to_OmicsBridge_directory}
Rscript -e "shiny::runApp('app.R')"
```

A new browser tab should open automatically. If it doesn't, check your terminal for a message like Listening on http://X.X.X.X:YYYY and navigate to that URL in your browser.

## Usage Guide
We provide a comprehensive Wiki for the interface at https://htsmto.github.io/OmicsBridge/.
The Wiki contains concise instructions and short demo videos for each visualization and analysis feature.
