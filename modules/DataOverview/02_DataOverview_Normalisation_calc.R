# =============================================================================
# DataOverview - Normalisation calculations
# File: modules/DataOverview/02_DataOverview_Normalisation_calc.R
# Purpose: Pure helper functions for normalising a raw gene x sample count
#          table (Data.Class == 'A') to CPM / TPM / FPKM. Used by
#          02_DataOverview_DataOverview_server.R. No Shiny reactivity here -
#          plain data.frame in, list out - so these are easy to test/reuse.
# Edit this file when: adding a new normalisation method, or changing how
#                       gene lengths are looked up / joined.
# =============================================================================

# --- gene length reference ---------------------------------------------------
# Reads the gene length lookup table used by TPM/FPKM. Two columns: 'id'
# (human gene symbol, matching the 'id' column of every expression table in
# this app) and 'length' (gene length in bp). Returns NULL if the file is
# missing/unreadable so callers can degrade gracefully (CPM never needs this).
load_gene_lengths <- function(path = "data/gencode.v41.primary_assembly.gene_length.tsv") {
    tryCatch({
        gl <- data.frame(read.delim(path, sep = "\t", header = TRUE, check.names = FALSE))
        if(!all(c("id", "length") %in% names(gl))){
            return(NULL)
        }
        gl
    }, error = function(e) NULL)
}


# --- normalisation dispatcher --------------------------------------------------
# df            : data.frame with an 'id' column (gene symbol) plus one numeric
#                 column per sample (raw counts).
# method        : one of 'none', 'cpm', 'tpm', 'fpkm'.
# gene_lengths  : data.frame from load_gene_lengths(), or NULL.
#
# Returns list(data, total, dropped, error):
#   data    - normalised data.frame (same shape as df, 'id' column restored),
#             or NULL if error is non-NULL.
#   total   - number of genes in the input (only for tpm/fpkm; NA otherwise).
#   dropped - number of genes skipped because they had no entry in
#             gene_lengths (only for tpm/fpkm; NA otherwise).
#   error   - NULL on success, otherwise a user-facing error message.
normalise_counts <- function(df, method, gene_lengths) {
    if(is.null(df) || nrow(df) == 0){
        return(list(data = df, total = NA, dropped = NA, error = "No data loaded to normalise."))
    }

    id_col <- df$id
    numeric_cols <- names(df)[!(names(df) %in% "id")]
    counts <- as.matrix(df[numeric_cols])

    if(method == "none"){
        return(list(data = df, total = NA, dropped = NA, error = NULL))
    }

    if(method == "cpm"){
        lib_sizes <- colSums(counts, na.rm = TRUE)
        normed <- sweep(counts, 2, lib_sizes, "/") * 1e6
        out <- data.frame(id = id_col, normed, check.names = FALSE)
        names(out) <- c("id", numeric_cols)
        return(list(data = out, total = NA, dropped = NA, error = NULL))
    }

    if(method %in% c("tpm", "fpkm")){
        if(is.null(gene_lengths)){
            return(list(data = NULL, total = NA, dropped = NA,
                        error = "Gene length reference file (data/gencode.v41.primary_assembly.gene_length.tsv) could not be read. TPM/FPKM require it - CPM does not."))
        }

        total <- length(id_col)
        matched_length <- gene_lengths$length[match(id_col, gene_lengths$id)]
        keep <- !is.na(matched_length) & matched_length > 0
        dropped <- total - sum(keep)

        if(sum(keep) == 0){
            return(list(data = NULL, total = total, dropped = dropped,
                        error = "None of the genes in this table matched the gene length file (expects human gene symbols in the 'id' column)."))
        }

        counts_k <- counts[keep, , drop = FALSE]
        length_bp <- matched_length[keep]
        id_k <- id_col[keep]

        if(method == "tpm"){
            length_kb <- length_bp / 1000
            rate <- counts_k / length_kb
            normed <- sweep(rate, 2, colSums(rate, na.rm = TRUE), "/") * 1e6
        } else { # fpkm
            lib_sizes <- colSums(counts_k, na.rm = TRUE)
            normed <- (counts_k * 1e9) / (length_bp * matrix(lib_sizes, nrow = nrow(counts_k), ncol = length(lib_sizes), byrow = TRUE))
        }

        out <- data.frame(id = id_k, normed, check.names = FALSE)
        names(out) <- c("id", numeric_cols)
        return(list(data = out, total = total, dropped = dropped, error = NULL))
    }

    list(data = NULL, total = NA, dropped = NA, error = paste("Unknown normalisation method:", method))
}
