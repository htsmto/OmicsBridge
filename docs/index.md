# OmicsBridge

## <u>**Overview**</u>

OmicsBridge is an intuitive platform that integrates and visualizes diverse omics datasets. Our tool helps researchers identify key genes with functional and clinical relevance, supporting hypothesis generation. It also serves as a centralized database for efficient data storage and access, reducing scattered datasets and improving overall data accessibility.

You can use OmicsBridge through a standalone web interface at [https://omicsbridge.dkfz.de](https://omicsbridge.dkfz.de/).
This web interface is a demo version. Please note that uploaded data in this demo will be deleted after you close the tab.
If you want to deploy OmicsBridge in your local environment, please follow the instructions below.

![Interface overview](img/interface_overview.png)

## <u>**Installation**</u>

Please clone this [Github repository](https://github.com/htsmto/OmicsBridge) by running the following commands in your terminal:

```bash
git clone https://github.com/Immune-Regulation-in-Cancer/OmicsBridge.git
cd OmicsBridge
```

> Note: You may be prompted to install `git-lfs` when cloning the repository. For installation instructions, please refer to [the official Git LFS website](https://git-lfs.com/).

Next, download the necessary data (`00_Clinical_dataset.tar.gz` and `00_Expression_data_all.tar.gz`) from [Zendo](https://doi.org/10.5281/zenodo.16410489), uncompress and place the folders in the `OmicsBridge` directory:

```bash
tar -xzvf 00_Clinical_dataset.tar.gz
tar -xzvf 00_Expression_data_all.tar.gz
```
the final file structure should be:
```
.
├── 00_Clinical_dataset
├── 00_Expression_data_all
├── app.R
├── data
├── docs
├── mkdocs.yml
├── README.md
├── wiki
└── www
```


Alternatively, copy the links above and paste them in a browser to download the files, then uncompress and place them inside the OmicsBridge folder.

## <u>**Dependencies**</u>

### Docker Image
We provide a Docker image available from Docker Hub:
```bash
docker pull htsmto/omicsbridge:latest
```

### Manual Installation of Required Libraries
OmicsBridge requires R version *4.4.0 or higher*. While it may work with earlier versions, some packages (such as GSVA) might cause unexpected errors. Please install the following libraries and ensure you install BiocManager version *3.20 or higher*.

```R
## CRAN dependent packages
install.packages(c('shiny','shinydashboard','eulerr','ggplot2', 'ggbeeswarm','patchwork','igraph','tidyr','dplyr','DT','ggrepel','tibble','forcats', 'colourpicker', 'devtools','stringr', 'Cairo', 'Seurat', 'reshape2', 'cowplot', 'survival', 'survminer',"BiocManager", 'visNetwork', 'ggraph', "shinyWidgets", "shinycssloaders", 'ggseqlogo', 'circlize'. 'ggupset'))

## BiocManager dependent packages
BiocManager::install() # Make sure to install >3.20
BiocManager::install(c("GSEABase",'GSVA','fgsea',"clusterProfiler","org.Hs.eg.db","org.Mm.eg.db","decoupleR","igvShiny","GenomicAlignments", "AUCell", 'Gviz', 'PWMEnrich', 'seqLogo', 'PWMEnrich.Hsapiens.background', 'BSgenome.Hsapiens.UCSC.hg38', 'BSgenome.Hsapiens.UCSC.hg19', 'EnrichedHeatmap', 'rtracklayer', 'ChIPseeker'))

## Other packages
devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")
devtools::install_github('dviraran/xCell')
```

## <u>**Launching the App**</u>
If you are using a Docker image, open your termiank and

```bash
docker run -it --rm \
  -v ${Your_path_to_OmicsBridge_directory}:/app \
  -w /app \
  -p 4191:4191 \
  htsmto/omicsbridge \
  Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=4191)"
```

You can customise the port number (4191 in this example) as needed. Once running, open `http://localhost:4191` in your browser.<br> 

> Note: If you are running this on a remote server, make sure to forward the port when connecting via SSH. For example:
> 
> ```bash
> ssh -L 4191:localhost:4191 your_username@remote_server_address
> ```

After logging in, run the Docker command as above on the remote server. Then, open `http://localhost:4191` in your local browser to access the app. <br>


If you're using your local R environment instead of Docker, open your teminal and:

```bash
cd ${Your_path_to_OmicsBridge_directory}
Rscript -e "shiny::runApp('app.R')"
```
> Note: If you get an error of utils::browseURL (ex. 'browser' must be a non-empty character string), please try:
> ```R
> Rscript -e "shiny::runApp('app.R', launch.browser = FALSE)"
> ```

A new browser tab should open automatically. If it doesn't, check your terminal for a message like Listening on `http://X.X.X.X:YYYY` and navigate to that URL in your browser.

## <u>**Usage Guide**</u>
We provide a comprehensive Wiki for the interface at https://htsmto.github.io/OmicsBridge/.
The Wiki contains concise instructions and short demo videos for each visualization and analysis feature.

## <u>**Version**</u>

Current version: v1.0 <br>
Release date: August 2025

## <u>**Citation**</u>

A permanent DOI and citation will be provided upon publication.

## <u>**Contact**</u>

For questions, feature requests, or bug reports, please contact:

  ```
  Hitoshi Matsuo
  German Cancer Research Center (DKFZ) Heidelberg
  Division Immune Regulation in Cancer
  Im Neuenheimer Feld 280, 69120 Heidelberg, Germany
  Email: hitoshi.matsuo[at]dkfz-heidelberg.de
  ```