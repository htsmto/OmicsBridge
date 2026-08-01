
# FAQ 

??? note  "What are the system requirements to run OmicsBridge?"
    OmicsBridge runs on virtually any standard computer, but performance scales with available RAM. Loading single-cell RNA-seq or epigenome datasets is particularly memory-intensive, so we recommend at least 24 GB of RAM for these analyses. If you only work with bulk RNA-seq or similar lighter data types, a lower-RAM machine will run smoothly.

??? note "How can I save the figure?"
    Right-click on your mouse and select “Save Image As…” (in Mac)

??? note "Does OmicsBridge handle raw data preprocessing?"
    Not currently. OmicsBridge does not perform raw data processing (e.g. alignment, quantification, peak calling) at this stage, though this may be added in the future. Preprocessing is expected to be handled by a bioinformatician beforehand. OmicsBridge's role is to provide a code-free interface for exploring already-processed data, rather than generating it from raw sequencing files.

??? note "What input format does OmicsBridge expect?"
    Data should be uploaded as already-processed files in .csv, .tsv, .txt, or .rds format, matching the expected structure for the relevant Data Class (e.g. expression matrix, clinical metadata). For epigenome data uploaded as BAM files, the corresponding .bai index file must be uploaded alongside it. Note that large files (e.g. BAM) may take longer to upload or fail depending on your computer's specifications and the platform's file size limit.

??? note "Do I need an internet connection to use OmicsBridge?"
    No. OmicsBridge is designed mainly for local usage. Once installed, it works fully offline. This means you don't need to worry about data privacy, since your data never leaves your machine.

??? note "What operating systems are supported?"
    OmicsBridge's local version runs via Docker, so it works on Windows, macOS, and Linux — anywhere Docker Desktop (or Docker Engine) can be installed. No OS-specific setup is required beyond having Docker running.

??? note "How much disk space do I need?"
    Disk space requirements depend mainly on the size of the datasets you plan to load. Bulk RNA-seq datasets are relatively small, while scRNA-seq and epigenome datasets (e.g. BAM/BigWig files for the IGV browser) can require significantly more space. We recommend at least [X GB] of free storage, more if you're working with large cohorts.

??? note "Does OmicsBridge require a powerful CPU?"
    No. CPU speed is not a major bottleneck for most analyses. RAM is the more important factor, particularly for scRNA-seq and epigenome data loading.

??? note "Do I need to install R separately?"
    If you're using the Dockerised version, no. R and all dependencies are bundled in the container. R is only needed separately if you choose to run OmicsBridge from source rather than via Docker.

??? note "What browser should I use?"
    Since OmicsBridge is an R/Shiny application, a modern browser such as Chrome or Firefox is recommended for the best experience with the interactive plots and dashboards.
