# **Count & Comparison Data Overview**

This section provides an overview of the selected dataset.

(scRNA data and bam/bed files are viewable in the "scRNA" and "Genome Browser" sections instead.)

Users can create various plots, identify and highlight significant genes and hits, examine overlaps with gene sets of interest, and conduct downstream analyses including GO/KEGG and GSEA analyses.

---

## <u> **1. Data Selection** </u>

To begin, a dataset will be chosen in the "Dataset Selection" section.

Upon selection, the details of the dataset will be displayed on the right side.

Users can filter datasets by "Sequenced by," "Experiments," or "Data type" inside the toggle button.

Click "Reload your datasets list" to refresh the dropdown with any datasets uploaded or edited since the page was loaded.

Depending on whether the data is in the form of a Count Table (A) or Comparison Data (B), the content will be presented in the "Overview and Analysis" section.

Please refer to the following for more information.

### <u> **1.1. Viewing and normalising the data table** </u>

Once a dataset is selected, its contents are shown as a table in the "Overview and Analysis" section below, under the "Data Table" tab.

If the selected data is a Count Table (Data Class A), you can normalise the raw counts before further use by choosing a normalisation method — "None", "CPM", "TPM", or "FPKM" — from the dropdown and clicking "Apply".

??? warning "TPM/FPKM currently only support the human genome"
    TPM and FPKM require the length of each gene, which is looked up by human gene symbol from a GENCODE (v41) gene annotation file.

    Any gene in your table whose "id" is not a recognised human gene symbol, or has no known length in this reference, will be skipped during normalisation — the status message shown after clicking "Apply" reports how many genes were skipped.

    CPM does not require gene length, so it works for any species.

---

## <u> **2. Analysis of "Comparison data"** </u>

Upon selecting a **"Comparison Data"** type of data, two tabs will appear within the **"Overview and Analysis"** section.

The "Data Table" presents the data in tabular format, while the "Plot & Downstream Analysis" tab enables users to generate graphical representations and conduct subsequent analyses.

### <u> **2.1. Getting an overview (Volcano / Scatter Plot)** </u>

This plot is primarily designed to generate a **volcano plot** — Log Fold Change on the X-axis and -log10(p-value) on the Y-axis.

The X and Y axes can be set to any numeric column in your data though, so it can also be used as a general-purpose scatter plot for other comparisons.

To create and interact with the plot:

1. <span style="color:rgb(255, 94, 8);">Select the X and Y axes</span> from the "Display Options" panel on the right. For a volcano plot, use "Log Fold Change" for the X-axis and "-log10(p.value)" for the Y-axis.

2. <span style="color:rgb(255, 94, 8);">Select a region within the plot with your mouse</span> to label dots with their gene names (IDs). Note that:
    - Not all dots will be labelled due to automatic positioning adjustments
    - Very large selections disable labelling to prevent computational issues
    - Information about selected dots appears in the "Selected Area Information" table below

3. <span style="color:rgb(255, 94, 8);">Highlight specific genes of interest</span> by entering gene names line by line in the "Enter genes" box. Note that:
    - These genes will be marked in red on the plot, along with their labels/annotations
    - If any entered genes aren't found in the dataset, a message will indicate which ones are missing. Ensure gene names have no extra spaces
    - The "Show information as a table" switch generates a downloadable table with details of highlighted genes in the "Information of Genes of Interest" section
    - The "show gene names" switch toggles annotation visibility when the display becomes crowded

4. (optional) <span style="color:rgb(255, 94, 8);">Highlight a second, independent set of genes in a different colour</span> by toggling "Highlight other genes with a different colour" below the first "Enter genes" box.

    This opens a second "Enter genes" box (with its own colour picker, default blue) so you can highlight two separate gene lists on the same plot at once — for example, one gene list in red and another in blue.

??? success  "Adjustable graph parameters"
    - The size of the figure. (width and height)
    - The size of all the dots and the highlighted dots.
    - The size of the annotation label.
    - The size of the XY axis label and the title font size.
    - Label overlap level: Controls how aggressively overlapping gene-name labels are thinned out/repositioned — raise this if too many labels are being hidden due to crowding (see note in step 2 above).
    - Axis range control: Specify minimum and maximum values for x and y axes to zoom in on specific data regions.
    - White background option: The default is a grey background. Use this to switch to a white background (there is a separate "white background for labels" switch to control the label background independently).

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_1_annot_light.mp4" type="video/mp4"> 
    </video>

### <u> **2.2. Highlighting the filtered genes** </u>

Beyond manually typing gene names, OmicsBridge can automatically highlight genes for you, from three different sources. Select one of the tabs below.

===  "**Filtered genes**"
    Rather than manually typing in gene names one by one (as in step 2.1 above), this option automatically finds and highlights genes that pass a significance and/or fold-change cutoff you set.

    For example, every statistically significant hit on a volcano plot at once. This is useful when you want to see or export the full list of "hit" genes without already knowing their names.

    1. Select "Filtered genes"
    2. Choose your filtering method — see the two tabs below for how each one works.
    3. (optional) Show as a barplot:
    The scatter plot is useful for seeing the overall pattern, but it can be hard to read off exact values for individual genes, especially when many points are highlighted.

    Clicking the 'Show in a bar plot' switch generates a companion bar plot of the filtered genes in the "Bar plot" tab, making it easier to compare and rank the highlighted genes' scores at a glance.

    The y-axis and colour in the bar plot correspond to the x-axis value in the scatter plot, and the x-axis displays gene names (ids), sorted by score.

    **Show top/bottom N%**

    Highlights data by percentile, ranked by the X-axis score.

    You can set the top-hit percentile and bottom-hit percentile independently (each defaults to 10%).

    By default this mode does not apply any Y-axis significance filter (its Y-axis threshold starts at 0); raise it if you also want to require a minimum Y-axis value.

    **Custom threshold setting**

    Set specific cutoff values for the X-axis (X1, X2) and Y-axis (Y1, Y2; Y1 defaults to 1.3, corresponding to -log10(p.value) where p = 0.05).

    For each axis independently, choose how its thresholds are applied:

    - "none" (no filter on that axis)
    - "> X1" / "> Y1" (keep points above the first threshold — the default for both axes)
    - "< X2" / "< Y2" (keep points below the second threshold)
    - "X2 < X < X1" / "Y2 < Y < Y1" (keep points between the two thresholds)
    - "X < X2 or X > X1" / "Y < Y2 or Y > Y1" (keep points beyond either threshold — useful for capturing both up- and down-regulated genes on a volcano plot)

    The final highlighted set must satisfy the X-axis and Y-axis conditions together.

    Note that the default combination (“> X1” on both axes) only highlights points above both thresholds (e.g. only up-regulated, significant genes) — switch the X-axis mode to “X < X2 or X > X1” if you want both up- and down-regulated hits highlighted at once.

    ??? tip  "Other available options"
        | **Option** | **Description** |
        |------|------|
        | **Hide labels** | Hide gene name labels when they become crowded.|
        | **Show the threshold lines**       | Display vertical and horizontal threshold lines to indicate your chosen significance cutoffs. |
        | **Change the colour**              | Customise highlighting colours for both positive and negative sides.|
        | **Show the filtered genes information** | View filtered points in a downloadable table in the "Filtered genes information" section below. Users can also access a simple list of filtered gene names for copying. |

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_2_annot.mp4" type="video/mp4"> 
        </video>

===  "**Pathway genes**"
    Users can visualise genes associated with specific pathways in the plot.

    1. Select "Pathway genes"<br>
    2. Choose the gene sets group:<br>
    HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as preset options for both human and mouse.

    If you have your own gene sets file, select "custom" and upload the gmt file to the interface. Note that only gmt files are supported.
    3. Select a gene set:<br>
    After selecting the gene sets group, available gene sets will appear in the drop-down menu. Choose one, and genes from that set will be highlighted in the plot.
    4. (optional) Show as a barplot:<br>
    Similar to "filtering genes", clicking the 'Show in a bar plot' switch will display a bar plot of the Pathway genes in the 'Bar plot' tab.

    The y-axis and color in the bar plot correspond to the x-axis value in the scatter plot. The x-axis displays gene names (ids), sorted by score.

    ??? tip  "Adjustable graph parameters"
        | **Option**                  | **Description**       |
        |----------------------------|---------------------------------------------------------------------------------------------------------|
        | **Hide labels**            | Hide gene ID labels when the display becomes crowded.                                                   |
        | **Show the genes’ information** | Display detailed information about filtered points in a table below. |
        | **Change the colour**      | Customise the highlighting colour for better visualisation.                                             |
        | **Apply further filtering**| Works the same way as the "Custom threshold setting" described in the Filtered genes tab above — refine which pathway genes are highlighted by setting X-axis and Y-axis thresholds independently. |
        | **Show the threshold lines** | Display vertical and horizontal lines on the plot marking your chosen thresholds (only available once "Apply further filtering" is on). |

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_3_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**Custom gene sets**"
    Users can visualise genes from their own custom gene sets, registered in the interface.

    1. Select "Custom genesets"<br>
    2. Select a gene set:<br>
    Choose one of your registered custom gene sets from the drop-down menu. (For instructions on creating gene sets, refer to the "Gene set" section.) All genes within that set will be highlighted in the plot.
    3. (optional) Show as a barplot:<br>
    Similar to "Filtered genes" and "Pathway genes" above, clicking the 'Show in a bar plot' switch will display a bar plot of the custom-gene-set genes in the "Bar plot" tab.

    ??? tip  "Adjustable graph parameters"
        | **Option**                  | **Description**       |
        |----------------------------|---------------------------------------------------------------------------------------------------------|
        | **Hide labels**            | Hide gene ID labels when the display becomes crowded.                                                   |
        | **Show the genes’ information** | Display detailed information about filtered points in a table below. |
        | **Change the colour**      | Customise the highlighting colour for better visualisation.                                             |
        | **Apply further filtering**| Works the same way as the "Custom threshold setting" described in the Filtered genes tab above — refine which custom-gene-set genes are highlighted by setting X-axis and Y-axis thresholds independently. |
        | **Show the threshold lines** | Display vertical and horizontal lines on the plot marking your chosen thresholds (only available once "Apply further filtering" is on). |

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_4_annot_light.mp4" type="video/mp4"> 
        </video>

### <u> **2.3. Downstream analysis** </u>

Three downstream analysis methods are available, each in its own tab below.

===  "**Over-representation analysis (ORA)**"
    Over-representation analysis (ORA) is implemented via [clusterProfiler](https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html) and is applied to two gene set collections — **GO** (Gene Ontology) and **KEGG** pathways — using a user-defined gene list.

    ORA tests whether your input gene list contains significantly more genes from a given gene set than would be expected by chance, based on that gene list alone.

    (This is different from GSEA in the next tab, which uses the full ranked gene list rather than a fixed list of "hits".)

    !!! note "Gene symbols only"
        Genes must be provided as gene symbols — ENSEMBL IDs are not supported so far.

    1. Input the genes.
        - Text input: The user enters a list of genes in the text box, one per line.
        - Use filtered genes: Import genes that pass the threshold from the "Show outliers" plot option directly into the analysis. (You have to filter genes first)
        - Use selected genes: Use genes in a selected area in the plot by your mouse.

    2. Select the species and database. <br>
    Currently, GO-BP, GO-MF, GO-CC, and KEGG analyses are available for both humans and mice.

    3. Click "Start GO/KEGG Analysis" to begin. <br>
        This takes about 1-3 minutes, depending on the size of the input and the chosen ontology.

        Click "Reset" to clear the inputs and results and start over.

    4. It will return four outputs in the "Results & Plots" section, each in its own tab:
        - **Table**: Complete ORA results. Includes a "Download this table" button.
        - **Bar plot**: Enriched GO/KEGG terms showing gene count and p-value.
        - **Bubble plot**: Alternative visualisation showing the proportion of detected genes within each term.
        - **Network plot**: Visual network of the top enriched GO/KEGG terms and their connections to detected genes.

    ??? success  "Adjustable graph parameters (Bar plot)"
        - Figure width and height
        - Number of categories/terms to display
        - Legend size
        - X title font size, Y label size, X label font size
        - Colour for the maximum and minimum values
        - Option to switch from grey to white background

    ??? success  "Adjustable graph parameters (Bubble plot)"
        - Figure width and height
        - Number of categories/terms to display
        - X title font size, Y label size, X label font size
        - Legend size
        - Colour for the maximum and minimum values
        - Option to switch from grey to white background

    ??? success  "Adjustable graph parameters (Network plot)"
        - Figure width and height
        - Number of categories/terms to display
        - Legend size
        - Edge line width
        - Node label size (separately for term names and genes)
        - Node size (separately for term names and genes)
        - Node colour (separately for term names and genes)
        - Option to colour edges by term
        - Option to switch to a circular layout ("Circle plot")

    !!! tip "Network plot not rendering?"
        If the network plot fails to render due to insufficient width, click "Reset" and increase the figure width.

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_5_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**GSEA**"
    Gene set enrichment analysis (GSEA) is implemented via [fgsea](https://bioconductor.org/packages/release/bioc/html/fgsea.html), using a ranked gene list.

    It is applied to either the HALLMARK gene set collection from MSigDB, or a user-uploaded custom gene set.

    (This is different from ORA in the previous tab, which uses a fixed list of "hit" genes rather than the full ranking.)

    To perform GSEA analysis:

    1. Select the gene sets group:
        - Use pre-installed HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb)
        - Or select "Upload a gmt file (other gene sets)" to upload custom gene sets (gmt format only)
        - Or users can calculate the enrichment of one gene set.

            In this case, you can select a custom gene set from a drop-down menu, or manually input the list of genes in a text box line by line.
    2. Choose a score for GSEA ranking:
        - This score determines gene sorting and ranking. Typically, log fold change is used
        - Note: selecting a non-numeric category will cause an error
    3. Click "Start GSEA Analysis"
    4. View results:
        - A table displays statistical scores (p-values, adjusted p-values) and enrichment scores (ES, NES)
        - Clicking any pathway name displays its GSEA plot on the right

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure
        - X/Y axis labels size
        - X/Y axis title font size
        - Graph title font size
        - GSEA line colour (the running enrichment score line)
        - Max/Min line colour (the peak/trough marker line)

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_6_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**TF activity inference**"
    Transcription Factor (TF) activity inference analysis uses the [decoupleR](https://saezlab.github.io/decoupleR/) package to estimate TF activity based on changes in expression of target genes.

    1. Ensure you have RNA-seq data processed by DESeq2 with 'stat' values available
    2. Set the "Number of TF to display" slider (default: 50, range: 10-200).

        Then click "Start DecoupleR Analysis" to begin the process, and wait approximately 1 minute for the analysis to complete.
    3. The results appear in two tabs:
        - "DecoupeR Plot": Bar plot shows TF activity (positive scores indicate activation in treatment vs control)
        - "Results Table": Detailed statistics for each TF, downloadable

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure
        - X/Y axis labels size and X/Y axis title font size
        - Legend size
        - High activity colour, Low activity colour, and Zero activity colour (a three-point colour gradient for the bar plot)
        - Option to switch from grey to white background

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_7_annot_light.mp4" type="video/mp4"> 
        </video>

---

## **3. Analysis of "Count table"**

Four analyses are available for Count Table data, each in its own tab below.

===  "**Swarm plot**"
    The swarm plot visualises expression differences of genes of interest across samples.

    Samples with the same experimental conditions (replicated samples) are grouped together, making it easy to compare differences between conditions.

    1. Make sure your sample names follow the format SampleName_Rep# so the interface can identify replicates.
    2. Enter the genes you want to plot, either by typing gene names line by line in the "Enter genes" box, or by toggling "Use genes from a custom gene set" to pull genes from one of your registered custom gene sets instead.
    3. Clicking any gene(s) in the table displays its swarm plot on the right. The detailed table of individual sample scores will be shown below the input section, in the "Expression scores" box (downloadable) — values there are log2-transformed too if you turn on "Use a log scale (log2)" below.
    4. To customise the graph:
        1. "Use a log scale (log2)":
            - This transforms the y-axis value to log2 values
        2. "Re-order the X axis":
            - Enter the group names line by line. The x-axis of the swarm plot will be re-ordered accordingly.
            - The available group names will be listed below
        3. "Want to exclude specific samples?":
            - If you want to exclude a specific sample, enter the sample names line by line in the text box.
            - The available sample names will be listed below

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure.
        - X label size, Y label size, and Y title size.
        - The point size.
        - Change the colour palette: pick from a set of preset palettes (viridis, magma, plasma, inferno, cividis).
        - Use a single colour: override the palette with one flat colour of your choice for all groups.
        - The option for changing the background colour from gray to white

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_8_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**Gene correlation**"
    This feature computes and visualises pairwise correlations between the expression levels of multiple genes, across the samples in the selected dataset.

    Enter two or more genes to get a correlation heatmap across all of them, then drill down into any specific pair to see its own scatter plot.

    1. Enter the genes to correlate:<br>
    Type two or more gene names, line by line, in the "Enter genes names" box — or toggle "Use the genes from the custom gene sets" to pull genes from one of your registered custom gene sets instead.
    2. Correlation settings:<br>
        - Choose the calculation method: Pearson or Spearman.
        - Toggle "Use log scale" if you want the correlation calculated on log-transformed values.
    3. Select the samples:<br>
    Choose which samples to include in the calculation, from the sample table.
    4. Click "Calculate the correlations" to compute the full pairwise correlation matrix across all your input genes.
    5. View the results:<br>
        - **Correlation table**: Select one of your input genes from the "Select a gene to show its correlation result table" drop-down to see a table of that gene's correlation (r-value and p-value) against every other gene you entered. The table is downloadable.
        - **Pairwise heatmap**: By default, the "Plot" panel shows a clustered heatmap of the full pairwise correlation matrix across all your input genes — genes are automatically reordered by hierarchical clustering so similarly-correlated genes sit together.
        - **Scatter plot for one pair**: Once you've selected a gene from the drop-down above, click its row in the correlation table to pick a second gene — the "Plot" panel then switches to a scatter plot of just that gene pair, with points coloured by sample group (or a single colour, if you prefer) and an optional regression line.

    ??? success  "Adjustable graph parameters (Pairwise heatmap)"
        - Figure width and height
        - X/Y axis label font size (set to 0 to hide the gene name labels entirely)
        - Legend font size
        - Colour for the highest correlation (+1), lowest correlation (-1), and zero correlation

    ??? success  "Adjustable graph parameters (Two-gene scatter plot)"
        - Figure width and height
        - Legend font size
        - X/Y axis label font size and title font size
        - Point size
        - Option to switch from grey to white background
        - Option to show a linear regression line
        - Option to use a single colour for all points, instead of colouring by sample group (with its own colour picker)

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_9_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**Heatmap**"
    The heatmap feature allows you to visualise gene expression patterns across samples. Here's how to use it:

    1. Input the genes to be used in the heatmap by either:
        - Text input: Enter genes directly through
        - Custom Gene Sets: Select a gene set from registered gene sets. (A drop-down menu appears)
        - HALLMARK (Human)/(Mouse): Select a gene set from HALLMARK (A drop-down menu appears)
        - Input a gmt file: Upload a GMT file of another gene set group and select a gene set. (An upload menu and a drop-down menu appear)
    2. Select the samples of interest from the sample table. You can also drag rows in this table to reorder them — this order is carried through to the sample (Y-axis) order in the resulting heatmap, so you can arrange samples however you'd like them displayed before generating the plot.
    3. Click "Generate a heatmap".
        - A heatmap visualises the standardised (z-score) expression scores across selected genes and samples.
        - The "Expression scores" table below shows the standardised values, and can be downloaded via "Download this table".
    4. Adjust "Cluster number"
        - You can cluster the genes based on their expression patterns by changing the slider bar below the plot.
        - Once genes are clustered, expand the collapsed "List of the genes in each cluster" box (next to the download button) and select a cluster number to see exactly which genes were assigned to it.

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure.
        - X label size and Y label size
        - Legend size
        - The colour of the highest, lowest and zero values in the heatmap
        - Option to switch from grey to white background

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_10_annot_light.mp4" type="video/mp4"> 
        </video>

===  "**PCA plot**"
    1. If you don't have any specific preferences, simply click "Generate a PCA plot".
        - By default, all samples will be included and colored according to the detected groups (those with replicates, as shown in the swarm plot).
    2. To customise sample selection, click "Define the groups":
        - Enter the sample names and their descriptions, separated by commas. The available sample names are listed below.
        - Click "Generate a PCA plot"
    3. (optional) Select a region on the plot with your mouse to see the sample names of the points you selected, listed below the plot.

    !!! note "t-SNE and UMAP are also available"
        Under "Plot type" in the Settings panel, you can switch from "PCA" to "tSNE" or "Umap" to use those dimensionality-reduction methods instead, using the same gene/sample inputs.

        Selecting "tSNE" reveals an additional "tSNE perplexity" slider (default: 30) that controls the t-SNE algorithm's neighbourhood size.

    ??? success  "Adjustable graph parameters"
        - The size (width and height) of the figure.
        - Font size for X and Y axis labels and titles
        - Dot size
        - Size of sample labels and legend
        - Option to hide labels when crowded ("Hide labels")
        - Option to switch from grey to white background ("Use white background")

    ??? example  "Example Usage video"
        <video width="1000" controls>
        <source src="../videos/Data_overview_11_annot_light.mp4" type="video/mp4"> 
        </video>
