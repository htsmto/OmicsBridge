
# FAQ 

??? note  "What are the system requirements to run OmicsBridge?"
    OmicsBridge runs on virtually any standard computer, but performance scales with available RAM. Loading single-cell RNA-seq or epigenome datasets is particularly memory-intensive, so we recommend at least 24 GB of RAM for these analyses. If you only work with bulk RNA-seq or similar lighter data types, a lower-RAM machine will run smoothly.

??? note "How can I save the figure?"
    Right-click on the plot and select "Save Image As…" — this works the same way in Chrome or Firefox on Windows, Mac, or Linux. There is currently no built-in "Download plot" button in the interface (unlike tables, which mostly have a "Download this table" button).

??? note "Does OmicsBridge handle raw data preprocessing?"
    Not currently. OmicsBridge does not perform raw data processing (e.g. alignment, quantification, peak calling) at this stage, though this may be added in the future. Preprocessing is expected to be handled by a bioinformatician beforehand. OmicsBridge's role is to provide a code-free interface for exploring already-processed data, rather than generating it from raw sequencing files.

??? note "What input format does OmicsBridge expect?"
    Data should be uploaded as already-processed files in .csv, .tsv, .txt, or .rds format, matching the expected structure for the relevant Data Class (e.g. expression matrix, clinical metadata). For epigenome data uploaded as BAM files, the corresponding .bai index file must be uploaded alongside it. Note that large files (e.g. BAM) may take longer to upload or fail depending on your computer's specifications and the platform's file size limit.

??? note "Do I need an internet connection to use OmicsBridge?"
    No. OmicsBridge is designed mainly for local usage. Once installed, it works fully offline. This means you don't need to worry about data privacy, since your data never leaves your machine.

??? note "What operating systems are supported?"
    OmicsBridge's local version runs via Docker, so it works on Windows, macOS, and Linux — anywhere Docker Desktop (or Docker Engine) can be installed. No OS-specific setup is required beyond having Docker running.

??? note "How much disk space do I need?"
    Disk space requirements depend mainly on the size of the datasets you plan to load. Bulk RNA-seq datasets are relatively small, while scRNA-seq and epigenome datasets (e.g. BAM/BigWig files for the IGV browser) can require significantly more space. Plan for enough free storage to comfortably hold every dataset you intend to upload, plus some headroom — large single-cell RDS files and BAM files are typically the biggest contributors.

??? note "Does OmicsBridge require a powerful CPU?"
    No. CPU speed is not a major bottleneck for most analyses. RAM is the more important factor, particularly for scRNA-seq and epigenome data loading.

??? note "My session disconnected, or the app seems to have crashed — what happened?"
    This is most often caused by hitting the server's RAM limit. The sidebar shows two live usage bars, "RAM usage" and "CPU usage (N cores)", reflecting the whole server host rather than just your own session — if the host is shared with other users, their activity affects these bars too. Keep an eye on them while working with memory-heavy data (scRNA-seq, epigenome bigWig/BAM tracks, large clinical cohorts).

    For a few of the heaviest loading steps — loading a scRNA dataset, generating a Genome visualisation plot, importing bigWig samples for a Profile Plot, and loading a clinical cohort's data — OmicsBridge checks resource usage before proceeding: if CPU usage is at or above 90%, RAM usage is at or above 85%, or the file(s) being loaded are unlikely to fit in the RAM currently free, it shows a "Server resources are low" warning and lets you cancel or continue anyway. Other actions don't have this check, so if the usage bars are already high, it's best to wait until they drop (or check with anyone else sharing the server) before starting another heavy analysis.

??? note "Do I need to install R separately?"
    If you're using the Dockerised version, no. R and all dependencies are bundled in the container. R is only needed separately if you choose to run OmicsBridge from source rather than via Docker.

??? note "What browser should I use?"
    Since OmicsBridge is an R/Shiny application, a modern browser such as Chrome or Firefox is recommended for the best experience with the interactive plots and dashboards.

??? note "Does OmicsBridge need a GPU?"
    No. OmicsBridge runs entirely on CPU — none of its analyses (differential expression, enrichment, clustering, single-cell scoring, etc.) require or make use of a GPU.

??? note "Does OmicsBridge support species other than human and mouse?"
    Data upload itself is species-agnostic — you can upload an expression matrix, comparison table, or clinical dataset for any organism, since these are just numeric tables. However, several built-in tools rely on human (or human + mouse) reference annotations and won't work for other species: FPKM normalisation in Count & Comparison Data Overview (human gene lengths only), Find gene loci / Peak annotation in Tools (human GENCODE annotation), the Cancer Gene Census lookup in Clinical Data Analysis, and the Human & Mouse Gene Converter. The IGV genome browser is the exception — it directly supports human (hg19/hg38) and mouse (mm10/mm39) genomes.

??? note "Is there a login system? Is my data private if I share an instance with others?"
    OmicsBridge has no built-in login or user-account system. If you run it locally on your own machine, your data stays on that machine and isn't shared with anyone. If you (or your lab) run one shared instance on a server that multiple people connect to, everyone connecting to that instance sees the same uploaded datasets — there's no per-user separation of data.

??? note "Can I undo a save or deletion?"
    No. Actions like saving edits to the database, deleting a dataset, or deleting a custom gene set or cohort all show a confirmation dialog first ("This action cannot be undone."), but once you confirm, the change is permanent — there is no undo or version history.

??? note "I just uploaded or edited a dataset, but it's not showing up in a dropdown — why?"
    Dataset dropdowns are loaded once when a section is first opened and don't refresh automatically. Nearly every section that lists datasets has a "Reload your datasets list" (or similarly named) button next to the dropdown — click it to refresh the list with anything uploaded or edited since the page was loaded.

??? warning "I downloaded the TCGA clinical dataset before 2026-09-02, and mutation analysis isn't finding any mutations when I filter by a category — why?"
    Datasets downloaded from an earlier version of the TCGA data package (before it was corrected) have a sample ID format mismatch: `mutations.tsv` used a different TCGA barcode format (with an extra trailing character) than `meta.tsv`, `survival.tsv`, and the gene expression file for the same cohort.

    In practice, this only causes a problem in the **Mutation analysis** section of Clinical Data Analysis, and only when using the **"Use the selected samples by a specific category"** sample-filtering option — that filter matches mutation samples against the cohort's metadata table, and with the old format the two never match, silently returning zero patients/mutations rather than an error. Mutation analysis using "Use all samples" (the default) is not affected, since it doesn't need to match sample IDs across files.

    **Fix**: download the current version of the TCGA dataset package from Zenodo and replace your cohort folder(s). See the Clinical Data Analysis page, **10.1. Pre-installed cohort** section, for full details on this fix and how the data was prepared.
