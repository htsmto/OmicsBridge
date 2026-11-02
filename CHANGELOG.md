# Changelog

## Unreleased
- Added: KEGG analysis (Count & Comparison Data Overview > ORA) can run offline using KEGG data downloaded by the user into `data/` (see the new Wiki page "KEGG Data for Offline Use"). Without it, the analysis still runs online, and a message tells the user that it is not available offline.
- Added: IGV (Epigenome Visualisation) shows hg38 and hg19 offline, using the cytobands and gene models in `data/` (no DNA sequence in this mode). Gene names are searched locally. mm10 and mm39 are still loaded from igv.org.
- Fixed: the KEGG analysis no longer stops the session when the KEGG server cannot be reached; an error message is shown instead.
- Fixed: Epigenome Visualisation > Find Enhancer/Promoter now lists each potential enhancer/promoter (and each gene in the gene selector) only once, and the list for a selected gene is ranked by correlation like the "All" list.

## v1.3.1 (October 2026)
- Added: Clinical Data Analysis > Deconvolution > "Association with mutations" — compare cell-type abundance between mutant and wild-type samples for each gene (Wilcoxon test), with box/violin/swarm plots and a view split by amino acid change.
- Added: a warning when uploading gene expression data for a clinical cohort, recommending normalised, log2-transformed values (e.g. log2(TPM+1)), with details in the Wiki.
- Fixed: swarm plots in Clinical Data Analysis no longer fail when Data Overview has not been opened; plot options in Clinical Data Analysis now show and hide correctly; gene expression files whose `id` column is not the first column are now uploaded correctly.
