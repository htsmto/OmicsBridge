# scRNA dataset
Here, users can visualise the registered scRNAseq dataset and investigate their genes of interest in it.

---

## <u> **0. Pre-processing** </u>
The interface accepts an RDS file as input for the scRNA section. The scRNA data must be processed using Seurat and ready for UMAP plotting (not tSNE). Before uploading to the interface, it is highly recommended to annotate each cluster with its corresponding cell type. For more information, please refer to the Seurat tutorial.

??? note "Seurat object preprocess"
    The Seurat object must be loaded from an RDS file. Ensure that `Reductions(Seurat_object)` returns "umap". While the metadata (Seurat_object@meta.data) is flexible, your data should ideally include "seurat_clusters" and "Annotation" fields for optimal functionality.
    ![Example](img/1_Seurat.png)

??? warning "Seurat object too large to upload? Reduce its size"
    If your RDS file is too large to upload, you can shrink it by removing data that is not required for data exploration in the **current version** of OmicsBridge (note: this may change in future versions, e.g. if new features come to rely on this data).

    ```r
    # Make the object smaller by removing unnecessary data

    # Scaled data (needed for PCA/DEG, but not required for data exploration in OmicsBridge)
    Seurat_obj@assays$RNA@layers$scale.data <- NULL

    # Count data (raw counts; not needed if already processed)
    Seurat_obj@assays$RNA@layers$counts <- NULL

    # Graph structures (used for clustering, but not needed for plotting)
    Seurat_obj@graphs <- list()

    # Command history (kept for reproducibility, safe to drop to save space)
    Seurat_obj@commands <- list()

    # Unnecessary reductions (keep only UMAP; e.g. remove PCA)
    Seurat_obj@reductions$pca <- NULL  # if only using UMAP
    ```

---

## <u> **1. Data overview** </u>

This section provides a simple UMAP overview of your data.

1. Select the dataset from the drop-down menu. The dataset's details (Data from, Experiment, When, Description) appear on the right.

    Click "Reload your datasets list" (next to the dropdown) to refresh with any datasets uploaded or edited since the page was loaded.

2. By default, the plot is coloured according to the clusters defined by Seurat.
    - You can change the colouring option by selecting from a drop-down menu.
    - The available categories depend on the metadata in the dataset (stored in Seurat_object@meta.data).
3. To highlight a specific group, toggle on "Highlight a specific group".
    - A drop-down menu will appear for selecting a group.

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure.
    - The size of the XY axis/label, graph title and the legend font size.
    - The dot size

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/scRNA_1_annot_light.mp4" type="video/mp4"> 
    </video>

---

## <u> **2. Feature plots** </u>

This section lets you investigate genes of interest across the cells in your UMAP plot, in several plot formats.

Enter your genes of interest (one per line) in the "Inputs and Settings" box, or toggle "Use the genes from the custom gene sets" to pull genes from one of your registered custom gene sets instead. The genes will appear as a selectable table below the input box, shared across all the tabs described below.

=== "**Feature Plot (UMAP)**"
    Click on a gene in the table to generate a feature plot. Cells not expressing the selected gene appear in a background colour, while cells expressing the gene (UMI > 0) are highlighted with a gradient colour scheme (default: white to red).

    ??? success  "Adjustable graph parameters"
        - Figure size (width and height)
        - X/Y label font size, X/Y title font size, graph title font size, and legend font size
        - Dot size (expressing cells) and dot size (background/non-expressing cells)
        - Colour for the highest expression, colour for the lowest expression, and colour for zero expression (background)
        - Option to use a white background

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/scRNA_2_annot_light.mp4" type="video/mp4"> 
        </video>

=== "**Violin Plot**"
    1. Choose a "Group by" categorical variable from the drop-down menu.
    2. Click a gene from the gene list table to generate a violin plot of its expression across the chosen groups.
    3. To view specific groups only, toggle "Select the groups to show" below the plot.
        - A list of all group names will appear.
        - Only the selected groups will be displayed in the plot.

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure
        - X label size, Y label size, X/Y title size, and legend font size
        - Min/max Y-axis display range
        - Option to use a white background
        - Option to rotate X-axis labels
        - "Hide jitter plots" switch (jitter points, showing individual cells, are hidden by default)

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/scRNA_5_annot_light.mp4" type="video/mp4"> 
        </video>

=== "**Dot Plot**"
    1. Choose a "Group by" categorical variable from the drop-down menu.
    2. By default, click a gene from the gene list table to plot just that gene. Alternatively, toggle "Show all the input genes?" to plot every entered gene together in one dot plot, in the order they were entered (this may take longer with many genes).
    3. To view specific groups only, toggle "Select the groups to show" below the plot.
        - A list of all group names will appear.
        - Only the selected groups will be displayed in the plot.

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure
        - X label size, Y label size, Y title size, and legend font size
        - Dot scale
        - Colour for high expression and colour for low expression

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/scRNA_4_annot_light.mp4" type="video/mp4"> 
        </video>

=== "**Pie chart**"
    Users can visualise the fraction of cells expressing specific genes across different clusters or cell types in the scRNA data. A cell is considered to be expressing a gene if it has a UMI count of 1 or greater.

    1. Choose a "Group by" categorical variable from the drop-down menu.
    2. Click a gene from the gene list table. The pie chart will show the proportions of expressing and non-expressing cells across groups in the selected category, with labels indicating the cell count and percentage in each group.
    3. To view specific groups only, toggle "Select the groups to show" below the plot.
        - A list of all group names will appear.
        - Only the selected groups will be displayed as pie charts.

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure
        - The size of the label, group names, and legend
        - The colour for the expressing and non-expressing segments in the pie chart
        - Option to hide the labels/legend

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/scRNA_6_annot_light.mp4" type="video/mp4"> 
        </video>

=== "**Gene Set Signature (AUC score) Feature Plot**"
    The interface can also calculate gene set signature scores (AUC scores) for the genes entered above and generate a feature plot for visualisation.

    AUC (Area Under the Curve) scores in scRNA-seq data measure the activity or enrichment of gene sets within single cells. They are calculated using the AUCell method, which ranks gene expression values in each cell and assesses how well a given gene set is enriched among highly expressed genes. AUC scores help infer pathway activity or transcription factor activity across cells, revealing functional differences between cell populations.

    1. With your genes of interest entered above, click "Calculate the signature score" to run AUCell for each single cell. This takes 1-3 minutes depending on the number of genes and the size of the dataset.
    2. Once complete, a feature plot appears automatically, showing every cell's signature score on the UMAP.
    3. **Violin plot**: select the desired "Group by" variable from the drop-down menu to compare signature scores across groups. To view specific groups only, toggle "Select the groups to show" below this plot in the same way as the other violin plot.

    ??? success  "Adjustable graph parameters"
        - Figure size (width and height)
        - X/Y label font size, X/Y title font size, and legend font size
        - Dot size (foreground) and dot size (background), for the feature plot
        - Colour for the highest expression, colour for the lowest expression, and colour for zero expression (background), for the feature plot
        - Option to use a white background

        For the violin plot:

        - Min/max Y-axis display range
        - Option to rotate X-axis labels
        - "Hide jitter plots" switch (jitter points are hidden by default)

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/scRNA_3_annot_light.mp4" type="video/mp4"> 
        </video>
