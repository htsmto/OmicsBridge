homeTabUI <- function() {
    tabItem(
        tabName = "home",
        tags$div(
            class = "home-container",
            tags$h2(class = "home-title",
                tags$u(
                    tags$b("The Multi-Omics Platform Built for the Whole Experiment")
                )
            ),
            tags$p(class = "home-text",
                "Modern research generates transcriptome, epigenome, and single-cell data in parallel —", tags$br(),
                "yet most analysis tools address only one modality at a time.", tags$br(),
                "OmicsBridge integrates several omics modalities and 50+ analytical modules into a single,", tags$br(),
                "code-free platform, covering everything from raw data upload to clinical outcome analysis.", tags$br(),
                "Seamlessly connect your multi-omics findings with cancer patient survival,", tags$br(),
                "mutation landscapes, and immune profiles — all without leaving the interface.", tags$br(),
                "", tags$br()
            ),
            tags$h2(class = "home-title",
                tags$u(
                    tags$b("Key Features")
                )
            ),
            tags$p(class = "home-text",
                "🔹 ", tags$b("Comprehensive Transcriptome Analysis"), tags$br(),
                tags$span(style="margin-left:2em", "– Differential expression, gene correlation, GO/GSEA enrichment, heatmaps,"), tags$br(),
                tags$span(style="margin-left:2em", "PCA, swarm plots, and transcription factor inference — all the standard RNA-seq analyses covered in one place."), tags$br(),
                "", tags$br(),
                "🔹 ", tags$b("Clinical Translatability Built In — Bench to Bedside in One Platform"), tags$br(),
                tags$span(style="margin-left:2em", "– Evaluate your omics findings directly in patient cohorts: survival analysis,"), tags$br(),
                tags$span(style="margin-left:2em", "mutation landscape (OncoPrint/waterfall), immune cell deconvolution, and COSMIC cancer gene annotation —"), tags$br(),
                tags$span(style="margin-left:2em", "all within the same interface. A capability not demonstrated in any of the compared tools."), tags$br(),
                "", tags$br(),
                "🔹 ", tags$b("Epigenomics & Functional Genomics Included"), tags$br(),
                tags$span(style="margin-left:2em", "– ChIP-seq, ATAC-seq, CUT&RUN, and CRISPR screen data are supported natively."), tags$br(),
                tags$span(style="margin-left:2em", "These modalities are absent in all comparable multi-omics platforms."), tags$br(),
                "", tags$br(),
                "🔹 ", tags$b("Persistent Local Database — No More Repetitive Uploads"), tags$br(),
                tags$span(style="margin-left:2em", "– Datasets are stored once and instantly accessible across all modules at any time."), tags$br(),
                tags$span(style="margin-left:2em", "A workflow bottleneck that no other compared tool addresses."), tags$br(),
                "", tags$br(),
                "🔹 ", tags$b("Cross-Dataset Comparison at Scale"), tags$br(),
                tags$span(style="margin-left:2em", "– Rank genes by any numerical score (e.g. log fold change) across multiple experiments simultaneously,"), tags$br(),
                tags$span(style="margin-left:2em", "and identify reproducible hits in seconds."), tags$br(),
                "", tags$br(),
                "", tags$br()
            ),
            tags$h2(class = "home-title",
                tags$u(
                    tags$b("Installing OmicsBridge to your local PC")
                )
            ),
            tags$p(class = "home-text",
                "The source code and installation guide is available at",
                tags$a(
                    href = "https://github.com/htsmto/OmicsBridge",
                    target = "_blank",
                    rel = "noopener noreferrer",
                    tags$b("this GitHub page")
                ), tags$br(),
                "Please install and set up OmicsBridge to your local PC to use the full power of our interface.", tags$br(),
                "", tags$br()
            ),
            tags$div(class = "home-image-container",
                tags$img(class = "home-image",
                    src = "interface_overview.png"
                )
            ),
            tags$p(class = "home-footer-text",
                "Make your data work for you. Start uncovering meaningful biological connections today."
            )
        )
    )
}