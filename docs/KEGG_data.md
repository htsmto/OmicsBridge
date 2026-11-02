# **KEGG Data for Offline Use**

The KEGG analysis in **Count & Comparison Data Overview > Downstream analysis > Over-representation analysis (ORA)** needs the KEGG pathway–gene table.
Because of KEGG's licence, this table is **not bundled** with OmicsBridge.

- **If the KEGG data is in the `data` folder**, OmicsBridge uses it and the KEGG analysis works offline.
- **If it is not**, OmicsBridge downloads the table from the KEGG server every time you click "Start GO/KEGG Analysis". This needs an internet connection, so the KEGG analysis cannot be used offline. A message is shown when you click "Start GO/KEGG Analysis" in this case.

GO analysis is not affected: it always works offline.

!!! warning "KEGG licence"
    The KEGG API is provided "only for academic use by academic users". Non-academic use of KEGG requires a commercial licence.
    Please download the KEGG data yourself, use it only in your own OmicsBridge installation, and **do not redistribute it** (e.g. do not commit it to a public repository or include it in a shared Docker image).
    See the [KEGG API](https://www.kegg.jp/kegg/rest/) and [KEGG legal](https://www.kegg.jp/kegg/legal.html) pages for details.


## <u> **1. Download the KEGG data** </u>

Do this once, on a computer with an internet connection.

1. Open R (or RStudio) and set the working directory to the `OmicsBridge` folder (the folder that contains `app.R`).
2. Run the following code. It downloads the human (`hsa`) and mouse (`mmu`) data and saves them in the `data` folder.

```r
library(clusterProfiler)
for (sp in c("hsa", "mmu")) {
  kegg <- download_KEGG(sp)
  # Pathway categories, used for the "category" and "subcategory" columns of the result table
  kegg$category <- clusterProfiler:::kegg_category_data()
  kegg$downloaded <- Sys.Date()
  saveRDS(kegg, file.path("data", paste0("KEGG_", sp, ".rds")))
}
```

!!! note "Using Docker?"
    The code needs R with `clusterProfiler`. If you do not have R installed locally, you can run it inside the OmicsBridge Docker image from the `OmicsBridge` folder:

    ```bash
    docker run -it --rm -v "$(pwd)":/app -w /app htsmto/omicsbridge Rscript -e 'library(clusterProfiler); for (sp in c("hsa", "mmu")) { kegg <- download_KEGG(sp); kegg$category <- clusterProfiler:::kegg_category_data(); kegg$downloaded <- Sys.Date(); saveRDS(kegg, file.path("data", paste0("KEGG_", sp, ".rds"))) }'
    ```


## <u> **2. Check the files** </u>

The `data` folder should now contain:

```
data
├── KEGG_hsa.rds   # human
├── KEGG_mmu.rds   # mouse
└── ...
```

Restart OmicsBridge. After a KEGG analysis, the status box under "Start GO/KEGG Analysis" shows which KEGG data was used, e.g. `KEGG data: local (downloaded 2026-11-02)`.


## <u> **3. Update the KEGG data** </u>

KEGG is updated regularly. To use the latest version, run the code in step 1 again; the files are overwritten.
