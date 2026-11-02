# =============================================================================
# Epigenome - IGV Browser: Offline Genomes
# File: modules/Epigenome/03_Epigenome_igv_offline_genome.R
# Purpose: Builds the files igv.js needs to show a genome without the internet
#          (chromosome sizes, cytobands and gene models; no DNA sequence) from
#          the reference files in data/, and the igvShiny options that use them.
#          Genomes without local reference files are loaded from igv.org.
# Edit this file when: adding a genome to the offline list, or changing the
#                       source files of the cytobands / gene models.
# Used by: 03_Epigenome_igv_server.R; www/custom.js builds the igv.js genome
#          from these options (dataMode = 'offline').
# =============================================================================

# Source files in data/ for each offline genome (genes = NA: no gene track)
igv_offline_sources <- list(
    hg38 = list(cytoband = 'data/cytoBand_hg38.txt', genes = 'data/customgeneModels.rds'),
    hg19 = list(cytoband = 'data/cytoBand_hg19.txt', genes = NA)
)
igv_offline_dir <- 'data/igv'           # generated files (git-ignored)
igv_offline_url <- 'igv_offline'        # URL prefix of igv_offline_dir
igv_offline_chromosomes <- paste0('chr', c(1:22, 'X', 'Y', 'M'))

# Gene models (one row per exon, Gviz format) -> BED12 (one row per transcript)
igv_gene_models_to_bed12 <- function(gene_models){
    x <- gene_models[gene_models$chromosome %in% igv_offline_chromosomes, ]
    x <- x[order(x$transcript, x$start), ]
    # integers, so that coordinates are not written as e.g. 1e+05
    x$start <- as.integer(x$start)
    x$end <- as.integer(x$end)
    tx <- x$transcript
    first <- !duplicated(tx)
    tx_start <- tapply(x$start, tx, min) - 1L   # 1-based -> 0-based
    tx_end <- tapply(x$end, tx, max)
    ids <- tx[first]
    data.frame(
        chrom = x$chromosome[first],
        start = tx_start[ids],
        end = tx_end[ids],
        name = x$symbol[first],
        score = 0,
        strand = x$strand[first],
        thickStart = tx_start[ids],
        thickEnd = tx_end[ids],
        itemRgb = 0,
        blockCount = as.vector(table(tx)[ids]),
        blockSizes = tapply(x$end - x$start + 1L, tx, paste, collapse = ',')[ids],
        blockStarts = tapply(x$start - 1L - tx_start[tx], tx, paste, collapse = ',')[ids]
    )
}

# Creates data/igv/<genome>/ if needed. Returns TRUE if the genome can be shown offline.
igv_prepare_offline_genome <- function(genome){
    src <- igv_offline_sources[[genome]]
    if(is.null(src) || !file.exists(src$cytoband)){
        return(FALSE)
    }
    out_dir <- file.path(igv_offline_dir, genome)
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

    sizes_file <- file.path(out_dir, 'chrom.sizes')
    cytoband_file <- file.path(out_dir, 'cytoBand.txt')
    if(!file.exists(sizes_file) || !file.exists(cytoband_file)){
        cyto <- read.table(src$cytoband, header = TRUE, sep = '\t', stringsAsFactors = FALSE)
        cyto <- cyto[cyto$chrom %in% igv_offline_chromosomes, ]
        sizes <- tapply(as.integer(cyto$chromEnd), cyto$chrom, max)
        sizes <- sizes[intersect(igv_offline_chromosomes, names(sizes))]
        # no trailing newline: igv.js 2.13.1 reads an empty last line as a chromosome, which breaks the whole-genome view
        cat(paste(names(sizes), sizes, sep = '\t', collapse = '\n'), file = sizes_file)
        write.table(cyto, cytoband_file, sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)
    }

    genes_file <- file.path(out_dir, 'genes.bed')
    if(!is.na(src$genes) && file.exists(src$genes) && !file.exists(genes_file)){
        bed <- igv_gene_models_to_bed12(readRDS(src$genes))
        write.table(bed, genes_file, sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)
    }

    shiny::addResourcePath(igv_offline_url, normalizePath(igv_offline_dir))
    return(TRUE)
}

# igvShiny options: offline genome if available, otherwise the stock genome from igv.org
igv_genome_options <- function(genome){
    if(!igv_prepare_offline_genome(genome)){
        # some genome names (e.g. mm39) are checked against igv.org, which fails offline
        options <- tryCatch(parseAndValidateGenomeSpec(genomeName = genome), error = function(e) NULL)
        shiny::validate(shiny::need(!is.null(options), paste0(genome, ' is loaded from igv.org and needs an internet connection.')))
        return(options)
    }
    genes_file <- file.path(igv_offline_dir, genome, 'genes.bed')
    # cytobands as a data URL: igv.js 2.13.1 fails to load a cytoband URL for a genome without sequence
    cytoband_file <- file.path(igv_offline_dir, genome, 'cytoBand.txt')
    cytoband_data_url <- paste0('data:text/plain;base64,', jsonlite::base64_enc(readBin(cytoband_file, 'raw', file.size(cytoband_file))))
    list(
        stockGenome = FALSE,
        dataMode = 'offline',
        validated = TRUE,
        genomeName = genome,
        initialLocus = 'all',
        fasta = paste(igv_offline_url, genome, 'chrom.sizes', sep = '/'),          # chromosome sizes
        fastaIndex = cytoband_data_url,                                           # cytobands
        annotation = if(file.exists(genes_file)) paste(igv_offline_url, genome, 'genes.bed', sep = '/') else NA
    )
}
