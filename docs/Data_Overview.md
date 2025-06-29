# **Data Overview and Downstream Analysis**

This section provides an overview of the selected dataset (except for scRNA data and bam/bed files, which are viewable in the "scRNA" and "Genome Browser" sections). Users can create various plots, identify and highlight significant genes and hits, examine overlaps with gene sets of interest, and conduct downstream analyses including GO/KEGG and GSEA analyses.

## <u> **1. Data Selection** </u>

To begin, a dataset will be chosen in the “Dataset Selection” section. Upon selection, the details of the dataset will be displayed on the right side. Users can filter datasets by “Data from," "Experiment," or “Data type" inside the toggle button. Depending on whether the data is in the form of a Count Table (A) or Comparison Data (B), the content will be presented in the “Overview and Analysis” section. Please refer to the following for more information.

## <u> **2. Analysis of "Comparison data"** </u>

Upon selecting a **“Comparison Data”** type of data, two tabs will appear within the **“Overview and Analysis”** section. The “Data Table” presents the data in tabular format, while the "Plot” tab enables users to generate graphical representations and conduct subsequent analyses.

### <u> **Getting an overview (Scatter Plot)** </u>

The scatter plot offers a visual summary of the selected dataset, enabling users to intuitively explore gene-level information. By selecting the X and Y axes from the “Display Options” panel on the right-hand side, users can tailor the plot to suit their analytical objectives. Commonly, the X-axis represents "Log Fold Change", while the Y-axis displays a statistical measure such as "-log10(p.value)".

Users can interactively select a region of the plot using their mouse. Genes (represented as dots) within the selected area will be annotated with their names (IDs), although not all may be labelled due to automatic label positioning by ggplot. To maintain clarity and system performance, annotations are disabled when the selected area is excessively large.

Further details about the selected genes are shown in the "Selected Area Information" table located at the bottom of the page.

To highlight specific genes of interest, users may input gene names—one per line—into the "Enter genes" text box. These genes will be marked in red on the plot, along with their labels. If any of the entered genes are not found within the dataset, a message will indicate which ones are missing. Please ensure that there are no leading or trailing spaces in the input.

The “Show information as a table” switch allows users to generate a downloadable table containing details of the highlighted genes, displayed in the "Information of Genes of Interest" section. If the plot becomes visually cluttered, the “Show gene names” switch can be used to toggle the gene labels on or off for improved readability.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/21_Overview_comparison_plot.mp4" type="video/mp4"> 
    </video>

??? success  "Adjustable graph parameters"
    - The size of the figure. (width and height)
    - The size of all the dots and the highlighted dots.
    - The size of the annotation label.
    - The size of the XY axis label and the title font size.
    - Axis range control: Specify minimum and maximum values for x and y axes to zoom in on specific data regions.
    - White background option: The default is a grey background. Use this to switch to a white background.


### <u> **Highlighting the filtered genes** </u>

#### 1. filtering genes
Users can highlight significant data points by selecting "Show outliers." By default (”Show top/bottom N%”), this highlights the top and bottom 10% of hits. The data points are sorted by X-axis score and filtered by Y-axis value (default: 1.13, which corresponds to -log10(p.value) where p=0.05). The top 10% represents the highest-scoring points where X ≥ 0 and Y ≥ 1.13, while the bottom 10% represents the lowest-scoring points where X ≤ 0 and Y ≥ 1.13. Users can customise these thresholds for both X-axis (positive and negative sides) and Y-axis values. With "Custom threshold setting" selected, users can directly specify their desired X and Y threshold values. They can also decide to filter to show only positive hits, only negative hits, or both.

??? success  "Adjustable graph parameters"
    - Hide gene name labels when they become crowded ("Hide labels")
    - Customize highlighting colours for both positive and negative sides ("change the colour")
    - Display threshold lines vertically or horizontally ("Show the threshold lines")
    - View filtered points in a downloadable table in the "Outliers Information" section below. Users can also access a simple list of filtered gene names for easy copying to other analyses ("Show the filtered genes information")
    - View the filtered data as a bar plot, sorted by X-axis value (e.g., LFC). The bars can be colored based on X-axis values, Y-axis values, or shown in plain grey. Any genes listed in the "Enter genes" box will be highlighted in red. ("Show in a bar plot")

#### **2. Showing the pathway genes**
Users can visualise genes associated with specific pathways in the plot. HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as preset options. Users with custom gene sets can upload them in GMT format by selecting "custom." Note that only gmt files are supported. After selecting a pathway, all genes within that pathway will be highlighted in the plot.

??? success  "Adjustable graph parameters"
    - hide id labels when they become crowded ("Hide labels")
    - display information about filtered points in a table below ("Show the genes information")
    - change the highlighting colour ("Change the colour")

#### **3. Showing the custom gene set genes**
Users can visualise genes from their custom gene sets that are registered in the interface. When a gene set is selected, all genes within that set will be highlighted in the plot. For instructions on creating gene sets, refer to the "Gene set" section.

??? success  "Adjustable graph parameters"
    - Hide gene labels when the display becomes crowded ("Hide labels")
    - Display detailed information about the highlighted genes in the table below ("Show the genes information")
    - Customize the highlighting colour ("Change the colour")

### <u> **Downstream analysis** </u>

#### **1. GO/KEGG analysis**

Users can perform GO or KEGG analysis using gene symbols (Note: ENSEMBL IDs are not supported so far). 

1. Input the genes.
    <br>There are three ways to input genes:

    - <span style="color:rgb(31, 191, 205);">Text input</span>: The user enters a list of genes in the text box, one per line.
    - <span style="color:rgb(31, 191, 205);">Use filtered genes</span>: Import genes that pass the threshold from the "Show outliers" plot option directly into the analysis. (You have to filter genes first)
    - <span style="color:rgb(31, 191, 205);">Use selected genes</span>: Use genes in a selected area in the plot by your mouse.

2. Select the species and database. 
    <br>Currently, GO-BP, GO-MF, GO-CC, and KEGG analyses are available for both humans and mice.

3. Click "Start GO Analysis" to begin. 
    <br>The analysis takes 1-3 minutes, depending on the input size and chosen ontology. KEGG is faster than GO.

4. It will return four outputs in the “Results & Plots” section.
    
    - <span style="color:rgb(31, 191, 205);">Table</span>: Complete GO/KEGG analysis results
    - <span style="color:rgb(31, 191, 205);">Bar plot</span>: Enriched GO/KEGG terms showing gene count and p-value.
    - <span style="color:rgb(31, 191, 205);">Bubble plot</span>: Alternative visualisation showing the proportion of detected genes within each term.
    - <span style="color:rgb(31, 191, 205);">Network plot</span>: Visual network of the top 5 enriched GO/KEGG terms and their connections to detected genes

??? success  "Adjustable graph parameters"
    - Number of categories/terms to display in bar and bubble plots
    - Figure width and height
    - X and Y axis label size
    - X-axis title size



#### **2. GSEA analysis**

Users can perform GSEA analysis using their chosen gene sets. HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as presets. Users with other gene sets can select "Upload a gmt file (other gene sets)" and upload a gmt file (note that only gmt format is supported). Next, users must select which score to use for GSEA ranking—typically the log fold change. This score determines how genes are sorted and ranked during analysis. Selecting a non-numeric category will result in an error.

After clicking "Start GSEA Analysis," the interface displays a table with statistical scores (p-values and adjusted p-values) and enrichment scores (ES and normalized enrichment score NES). Clicking any pathway name in the table reveals its GSEA plot on the right.


??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the X and Y axis font size
    - The size of the graph title


#### **3. Transcription Factor activity inference analysis**

This analysis is specifically for RNA-seq data processed by DESeq2 and requires 'stat' values from DESeq2. It uses the [decoupleR](https://saezlab.github.io/decoupleR/) package to estimate transcription factor (TF) activity based on expression changes in their target genes. Simply click "Start DecoupleR Analysis" to generate a bar plot and results table (approximately 1 minute). In the bar plot, positive scores indicate TF activation in the treatment group compared to the control group. You can customize how many TFs are displayed.

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the X and Y axis font size


## **3. Analysis of "Count table"**

### <u> **Swarm plot** </u>
The swarm plot visualises expression differences of genes of interest across samples. Samples with the same experimental conditions (replicated samples) are grouped together, making it easy to compare differences between conditions. Please make sure that the sample names are all set to `(SamepleName)_Rep#` so that the interface can tell which samples are replicates of each other.

To create a plot, enter gene names line by line in the "Enter genes" box. The genes will appear in the table below. Clicking any gene in the table displays its swarm plot on the right. A detailed table showing individual sample scores appears beside the plot. To customise the display, check "Re-order the X axis" - this allows you to reorder or filter which experimental groups appear in the plot by entering group names line by line. The plot will show only the groups you specify in your chosen order.

??? success  "Adjustable graph parameters"
    - the size (width and height) of the figure. 
    - the size of the X and Y axis/label font size. 
    - the size of the graph title.
    - The point size.  
    - The colour pallete
    - The colour of the dots.

### <u> **Two gene correlation Plot** </u>

hogehogehogeo

??? success  "Adjustable graph parameters"
    - the size (width and height) of the figure


### <u> **Heatmap** </u>
Users can generate a heatmap to visualize gene expression patterns across selected samples. Expression values are standardized across samples to enable clear comparisons.

To create a heatmap, enter genes directly through "Text input" or select from gene sets. You can use your own registered gene sets from the "Gene sets" section under "Custom Gene Sets." Pre-installed options include HALLMARK gene sets from MSigDB for both human and mouse data. Additional gene sets can be uploaded via gmt files (using "input a gmt file"). After entering genes or selecting a gene set, choose your samples of interest from the sample table. Click "Generate a heatmap" to create a visualization of standardized expression values across your selected samples.

The heatmap includes clustering analysis based on expression patterns, helping you identify groups of co-expressing genes. Adjust the "Cluster number" (default is 1 for no clustering) and regenerate the plot to group genes into your desired number of clusters.

The "Expression scores" table below the plot shows standardized scores and cluster assignments for each gene.

??? success  "Adjustable graph parameters"
    - the size (width and height) of the figure.
    - the size of the X and Y axis/label font size.
    - the colour of the highest, lowest and zero values in the heatmap

### <u> **PCA plot** </u>
Users can generate a PCA plot from the count matrix to visualise sample patterns and relationships. By default, it uses all samples and colours them by detected groups (those with replicates, as in the swarm plot). Users can also specify which samples to include and assign group names themselves by clicking "Define the groups" and entering group descriptions following the example. Clicking "Generate a PCA plot" displays the visualisation coloured by either interface-detected or user-defined groups. Alternatively, you can use a single colour for all samples by unchecking "Colour by groups".

??? success  "Adjustable graph parameters"
    - the size (width and height) of the figure
    - the size of the X and Y axis label/title font size
    - the size of all the dots
    - the size of the sample labels and the legend
    - hide the labels if they are messy ("Hide labels")
    - use a white background instead of the default grey background ("Use white background")
