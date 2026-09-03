# OmicsBridge

## <u>**Overview**</u>

OmicsBridge is a code-free, multi-omics analysis platform that integrates transcriptome, epigenome, and single-cell data within a single interface. With 50+ analytical modules spanning several omics modalities, it covers everything from standard RNA-seq analysis to epigenome visualisation, cross-dataset comparison, and clinical outcome evaluation — all without writing a single line of code.
A persistent local database eliminates repetitive uploads, and custom gene sets defined in one module are instantly reusable across all others.

You can try the demo version of OmicsBridge at [https://omicsbridge.dkfz.de](https://omicsbridge.dkfz.de/).
Please note that uploaded data there will be deleted after you close the session.
If you want to deploy OmicsBridge in your local environment, please follow the instructions below.

![Interface overview](img/interface_overview.png)

## <u>**Installation**</u>

Please clone this repository first. In the terminal:

```bash
git clone https://github.com/htsmto/OmicsBridge.git
cd OmicsBridge
```

Next, download the necessary data (`00_Clinical_dataset.tar.gz` and `00_Expression_data_all.tar.gz`) from [Zenodo](https://doi.org/10.5281/zenodo.22257376), uncompress and place the folders in the `OmicsBridge` directory:

```bash
tar -xzvf 00_Clinical_dataset.tar.gz
tar -xzvf 00_Expression_data_all.tar.gz
```
> Note: You cound skip downloading `00_Expression_data_all.tar.gz`, as it only contains demo data.

the final file structure should be:
```
.
├── 00_Clinical_dataset
├── 00_Expression_data_all      # auto-created as empty if not downloaded
├── app.R
├── data
├── docs
├── install_packages.R          # automated package installation script
├── launch_with_local_R.command # macOS: install packages (first run) + launch, using local R
├── launch_with_local_R.bat     # Windows: install packages (first run) + launch, using local R
├── launch_with_docker.command  # macOS: launch using Docker (no local R needed)
├── launch_with_docker.bat      # Windows: launch using Docker (no local R needed)
├── libraries                   # per-module library loaders (loaded lazily on first tab access)
├── mkdocs.yml
├── modules                     # modularised server and UI code
│   ├── Clinical/
│   ├── DataOverview/
│   ├── Database/
│   ├── DatasetsCompare/
│   ├── Epigenome/
│   ├── IntegrateTwoDataset/
│   ├── OriginalDataset/
│   ├── Tools/
│   ├── scRNA/
│   ├── wiki_document/
│   └── *_module.R              # per-module orchestrators
├── README.md
├── ui                          # app-level UI components (header, sidebar, body, home)
├── wiki
└── www
```

## <u>**Quick Start (Easiest — for local computer usage)**</u>

!!! tip "New to the command line?"
    A screenshot-illustrated, step-by-step guide for non-bioinformaticians is available on the [Installation Guide for Non-Bioinformaticians](installation.md) page.

This is the easiest way to get OmicsBridge running, and the recommended path for most users.

> This Quick Start is for running OmicsBridge **on your own computer**, where you'll also open the browser. It is not meant for launching OmicsBridge on a remote server (e.g. over SSH with no desktop to double-click from) — if that's your setup, see [Launching the App Manually](#launching-the-app-manually) below, which includes SSH port-forwarding instructions.

First, decide whether you'll use your own **R** installation or **Docker**, and install that (R from [cran.r-project.org](https://cran.r-project.org/), version 4.4.0 or higher; Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/)). Then double-click the one file below that matches your system and that choice:

- **macOS + local R** → `launch_with_local_R.command`
- **macOS + Docker** → `launch_with_docker.command`
- **Windows + local R** → `launch_with_local_R.bat`
- **Windows + Docker** → `launch_with_docker.bat`

That single file does everything: the first time you run it, it installs the necessary libraries — for local R this means running `install_packages.R`, and for Docker this means pulling the pre-built image — which takes around 10 minutes either way, depending on your internet connection. It then launches the app. On every later run, it skips straight to launching the app, which takes about 10-20 seconds.

Once it's running, a terminal window will tell you when the app is ready and which URL to open in your browser (`http://localhost:4191`).

> Note (macOS): the first time you double-click a `.command` file, Gatekeeper may block it as "from an unidentified developer." Right-click (or Control-click) the file → **Open** → confirm **Open**. You only need to do this once per file.
>
> Note (Windows): the first time you double-click a `.bat` file, Windows Defender SmartScreen may show a "Windows protected your PC" warning. Click **More info**, then **Run anyway**. You only need to do this once per file.

If you'd rather run things manually from the terminal instead of double-clicking, see the sections below.

## <u>**Dependencies**</u>

### Docker Image

We provide a Docker image available from Docker Hub:
```bash
docker pull htsmto/omicsbridge:latest
```
This image already bundles every required package, so no R installation or `install_packages.R` step is needed on your machine — `launch_with_docker.command` / `launch_with_docker.bat` handle the `docker pull`/`docker run` for you.


### Manual Installation of Required Libraries (for a local R environment)

OmicsBridge requires R version *4.4.0 or higher*. While it may work with earlier versions, some packages (such as GSVA) might cause unexpected errors. Please ensure you install BiocManager version *3.20 or higher*.

#### Automated Installation (Recommended)

An installation script is provided. Run the following in your terminal from the project root:

```bash
Rscript install_packages.R
```

This installs all required CRAN, Bioconductor, and GitHub packages automatically and prints a summary of installed versions at the end. (`launch_with_local_R.command` / `launch_with_local_R.bat` run this for you automatically on first launch.)

#### Alternative: Manual Installation

```R
## Bootstrap packages (needed to install everything else)
install.packages(c('BiocManager', 'remotes'))
BiocManager::install() # Make sure to install >3.20

## CRAN dependent packages
install.packages(c('shiny', 'shinyjs', 'shinydashboard', 'shinyWidgets', 'shinycssloaders', 'DT', 'dplyr', 'tidyr', 'reshape2', 'stringr', 'ggplot2', 'ggbeeswarm', 'patchwork', 'ggrepel', 'ggraph', 'eulerr', 'visNetwork', 'igraph', 'circlize', 'cowplot', 'colourpicker', 'ggseqlogo', 'survival', 'survminer', 'Rtsne', 'umap'))

## BiocManager dependent packages
BiocManager::install(c('GSEABase', 'clusterProfiler', 'org.Hs.eg.db', 'org.Mm.eg.db', 'fgsea', 'GSVA', 'decoupleR', 'GenomicRanges', 'GenomicFeatures', 'ChIPseeker', 'AnnotationDbi', 'rtracklayer', 'EnrichedHeatmap', 'Gviz', 'igvShiny', 'BSgenome.Hsapiens.UCSC.hg38', 'BSgenome.Hsapiens.UCSC.hg19', 'PWMEnrich', 'PWMEnrich.Hsapiens.background', 'AUCell', 'Seurat'))

## GitHub-only packages
remotes::install_github('ebecht/MCPcounter', ref = 'master', subdir = 'Source')
remotes::install_github('dviraran/xCell')
```

## <u>**Launching the App Manually**</u>

> Prefer the double-click launchers described in [Quick Start](#quick-start-easiest--for-local-computer-usage) above — this section is for running things by hand instead.

If you are using a Docker image, open your terminal and

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
> 
> After logging in, run the Docker command as above on the remote server. Then, open `http://localhost:4191` in your local browser to access the app. <br>


If you're using your local R environment instead of Docker, open your terminal and:

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

Current version: v1.3.0 <br>
Release date: August 2026

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
