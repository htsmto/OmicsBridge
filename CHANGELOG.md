# Changelog

## v1.3.1 (October 2026)
- Added: Clinical Data Analysis > Deconvolution > "Association with mutations" — compare cell-type abundance between mutant and wild-type samples for each gene (Wilcoxon test), with box/violin/swarm plots and a view split by amino acid change.
- Added: a warning when uploading gene expression data for a clinical cohort, recommending normalised, log2-transformed values (e.g. log2(TPM+1)), with details in the Wiki.
- Fixed: swarm plots in Clinical Data Analysis no longer fail when Data Overview has not been opened; plot options in Clinical Data Analysis now show and hide correctly; gene expression files whose `id` column is not the first column are now uploaded correctly.
