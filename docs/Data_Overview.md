# **Data Overview and Downstream Analysis**

This section provides an overview of the selected dataset (except for scRNA data and bam/bed files, which are viewable in the "scRNA" and "Genome Browser" sections). Users can create various plots, identify and highlight significant genes and hits, examine overlaps with gene sets of interest, and conduct downstream analyses including GO/KEGG and GSEA analyses.

## <u> **1. Data Selection** </u>

To begin, a dataset will be chosen in the “Dataset Selection” section. Upon selection, the details of the dataset will be displayed on the right side. Users can filter datasets by “Data from," "Experiment," or “Data type" inside the toggle button. Depending on whether the data is in the form of a Count Table (A) or Comparison Data (B), the content will be presented in the “Overview and Analysis” section. Please refer to the following for more information.

## <u> **2. Analysis of "Comparison data"** </u>

Upon selecting a **“Comparison Data”** type of data, two tabs will appear within the **“Overview and Analysis”** section. The “Data Table” presents the data in tabular format, while the "Plot” tab enables users to generate graphical representations and conduct subsequent analyses.

### <u> **2.1. Getting an overview (Scatter Plot)** </u>

To create and interact with scatter plots:

1. <span style="color:rgb(255, 94, 8);">Select the X and Y axes</span> from the "Display Options" panel on the right. For most analyses, use "Log Fold Change" for the X-axis and "-log10(p.value)" for the Y-axis.

2. <span style="color:rgb(255, 94, 8);">Select a region within the plot with your mouse</span> to label dots with their gene names (IDs). Note that:
    - Not all dots will be labelled due to automatic positioning adjustments
    - Very large selections disable labelling to prevent computational issues
    - Information about selected dots appears in the "Selected Area Information" table below
3. <span style="color:rgb(255, 94, 8);">Highlight specific genes of interest</span> by entering gene names line by line in the "Enter genes" box. Note that:
    - These genes will be marked in red on the plot, along with their labels/annotations
    - If any entered genes aren't found in the dataset, a message will indicate which ones are missing. Ensure gene names have no extra spaces
    - The "Show information as a table" switch generates a downloadable table with details of highlighted genes in the "Information of Genes of Interest" section
    - The "show gene names" switch toggles annotation visibility when the display becomes crowded

??? success  "Adjustable graph parameters"
    - The size of the figure. (width and height)
    - The size of all the dots and the highlighted dots.
    - The size of the annotation label.
    - The size of the XY axis label and the title font size.
    - Axis range control: Specify minimum and maximum values for x and y axes to zoom in on specific data regions.
    - White background option: The default is a grey background. Use this to switch to a white background.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_1_annot_light.mp4" type="video/mp4"> 
    </video>

### <u> **2.2. Highlighting the filtered genes** </u>

#### <u>**2.2.1. filtering genes**</u>
To highlight significant data points: 

1. Select "Filtered genes"
2. Choose your filtering method: <br>
    - Show top/bottom N%: 
    Highlights data by percentile (default: 10%) sorted by the X-axis score and filtered by the Y-axis value (default: 1.13, corresponding to -log10(p.value), where p = 0.05). For example, the top 10% represents the highest-scoring points where X ≥ 0 and Y ≥ 1.13.
    - Custom threshold setting: 
    Set specific X and Y cutoff values. You can directly specify your desired threshold values and choose to show only positive hits, only negative hits, or both.
3. Show as a barplot:
By clicking the 'Show in a bar plot' switch, a bar plot of the filtered genes will appear in the "Bar plot" tab. The y-axis and colour in the bar plot correspond to the x-axis value in the scatter plot. The x-axis displays gene names (ids), sorted by score.

??? tip  "Other available options"
    | **Option** | **Description** |
    |------|------|
    | **Hide labels** | Hide gene name labels when they become crowded.|
    | **Show the threshold lines**       | Display vertical and horizontal threshold lines to indicate your chosen significance cutoffs. |
    | **Change the colour**              | Customise highlighting colours for both positive and negative sides.|
    | **Show the filtered genes information** | View filtered points in a downloadable table in the "Outliers Information" section below. Users can also access a simple list of filtered gene names for copying. |

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_2_annot.mp4" type="video/mp4"> 
    </video>

#### <u>**2.2.2. Showing the pathway genes**</u>
Users can visualise genes associated with specific pathways in the plot.

1. Select "Pathway genes"<br>
2. Choose the gene sets group:<br>
HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as preset options for both human and mouse. If you have your own gene sets file, select "custom" and upload the gmt file to the interface. Note that only gmt files are supported.
3. Select a gene set:<br>
After selecting the gene sets group, available gene sets will appear in the drop-down menu. Choose one, and genes from that set will be highlighted in the plot.
4. Show as a barplot:<br>
Similar to "filtering genes", clicking the 'Show in a bar plot' switch will display a bar plot of the Pathway genes in the 'Bar plot' tab. The y-axis and color in the bar plot correspond to the x-axis value in the scatter plot. The x-axis displays gene names (ids), sorted by score.

??? tip  "Adjustable graph parameters"
    | **Option**                  | **Description**       |
    |----------------------------|---------------------------------------------------------------------------------------------------------|
    | **Hide labels**            | Hide gene ID labels when the display becomes crowded.                                                   |
    | **Show the genes’ information** | Display detailed information about filtered points in a table below. |
    | **Change the colour**      | Customise the highlighting colour for better visualisation.                                             |
    | **Apply further filtering**| Refine results by specifying thresholds for both x and y axes.                                          |


??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_3_annot_light.mp4" type="video/mp4"> 
    </video>


#### **2.2.3. Showing the custom gene set genes**
Users can visualise genes from their custom gene sets that are registered in the interface. When a gene set is selected, all genes within that set will be highlighted in the plot. For instructions on creating gene sets, refer to the "Gene set" section. Similar to the other options, clicking the 'Show in a bar plot' switch will display a bar plot of the Pathway genes in the 'Bar plot' tab. 

??? tip  "Adjustable graph parameters"
    | **Option**                  | **Description**       |
    |----------------------------|---------------------------------------------------------------------------------------------------------|
    | **Hide labels**            | Hide gene ID labels when the display becomes crowded.                                                   |
    | **Show the genes’ information** | Display detailed information about filtered points in a table below. |
    | **Change the colour**      | Customise the highlighting colour for better visualisation.                                             |
    | **Apply further filtering**| Refine results by specifying thresholds for both x and y axes.                                          |


??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_4_annot_light.mp4" type="video/mp4"> 
    </video>

### <u> **2.3. Downstream analysis** </u>

#### **2.3.1. GO/KEGG analysis**

Users can perform GO or KEGG analysis using gene symbols (Note: ENSEMBL IDs are not supported so far). 

1. Input the genes.
    - Text input: The user enters a list of genes in the text box, one per line.
    - Use filtered genes: Import genes that pass the threshold from the "Show outliers" plot option directly into the analysis. (You have to filter genes first)
    - Use selected genes: Use genes in a selected area in the plot by your mouse.

2. Select the species and database. <br>
Currently, GO-BP, GO-MF, GO-CC, and KEGG analyses are available for both humans and mice.

3. Click "Start GO Analysis" to begin. <br>
    The analysis takes a few minutes, depending on the input size and chosen ontology. KEGG is faster than GO.

4. It will return four outputs in the “Results & Plots” section.
    - Table: Complete GO/KEGG analysis results
    - Bar plot: Enriched GO/KEGG terms showing gene count and p-value.
    - Bubble plot: Alternative visualisation showing the proportion of detected genes within each term.
    - Network plot: Visual network of the top 5 enriched GO/KEGG terms and their connections to detected genes

??? success  "Adjustable graph parameters"
    - Number of categories/terms to display in bar and bubble plots
    - Figure width and height
    - X and Y axis label size
    - X-axis title size

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_5_annot_light.mp4" type="video/mp4"> 
    </video>


#### **2.3.2. GSEA analysis**

To perform GSEA analysis:

1. Select the gene sets group:
    - Use pre-installed HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb)
    - Or select "Upload a gmt file (other gene sets)" to upload custom gene sets (gmt format only)
    - Or users can calculate the enrichment of one gene set. In this case, you can select a custom geneset from a drop-dwon menu, or manually input the list of genes in a text box line by line.
2. Choose a score for GSEA ranking:
    - This score determines gene sorting and ranking. Typically, log fold change is used
    - Note: selecting a non-numeric category will cause an error
3. Click "Start GSEA Analysis"
4. View results:
    - A table displays statistical scores (p-values, adjusted p-values) and enrichment scores (ES, NES)
    - Clicking any pathway name displays its GSEA plot on the right


??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the X and Y axis font size
    - The size of the graph title
    - The colour of the lines in the GSEA plot.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_6_annot_light.mp4" type="video/mp4"> 
    </video>


#### **2.3.3. Transcription Factor activity inference analysis**

To perform Transcription Factor (TF) activity inference analysis. This analysis utilises the [decoupleR](https://saezlab.github.io/decoupleR/) package to estimate TF activity based on changes in expression of target genes.

1. Ensure you have RNA-seq data processed by DESeq2 with 'stat' values available
2. Click "Start DecoupleR Analysis" to begin the process and wait approximately 1 minute for the analysis to complete
3. The results:
    - Bar plot shows TF activity (positive scores indicate activation in treatment vs control)
    - Results table provides detailed statistics

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure.
    - The size of the X and Y axis font size.
    - The colour of the bar plot
    - The number of transcription factos to show

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_7_annot_light.mp4" type="video/mp4"> 
    </video>

## **3. Analysis of "Count table"**

### <u> **3.1. Swarm plot** </u>
The swarm plot visualises expression differences of genes of interest across samples. Samples with the same experimental conditions (replicated samples) are grouped together, making it easy to compare differences between conditions.

1. Make sure your sample names follow the format SampleName_Rep# so the interface can identify replicates.
2. Enter gene names line by line in the "Enter genes" box.
3. Clicking any gene(s) in the table displays its swarm plot on the right. The detailed table of individual sample scores will be shown below the input section.
4. To customise the graph:
    1. “Use a log scale (log2)”:
        - This transforms the y-axis value to log2 values
    2. "Re-order the X axis":
        - Enter the group names line by line. The x-axis of the swarm plot will be re-ordered accordingly.
        - The available group names will be listed below
    3. "Want to exclude specific samples?":
        - If you want to exclude a specific sample, enter the sample names line by line in the text box.
        - The available sample names will be listed  below


??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure.
    - The size of the X and Y axis/label font size.
    - The point size.
    - The colour palette
    - The option for changing the background colour from gray to white

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_8_annot_light.mp4" type="video/mp4"> 
    </video>


### <u> **3.2. Two gene correlation Plot** </u>

This feature displays a scatter plot comparing expression levels of two genes and calculates their correlation across samples in the selected dataset.

When choosing "Enter both X and Y-axis genes":

1. Enter a gene name for Y-axis and a gene name for X-axis. A scatter plot will be generated immediately.
2. Choose the calculation method: either Pearson or Spearman.
3. You can display data on a logarithmic scale by toggling "Use log scale"

When choosing "Enter Y-axis gene and explore the correlations":

1. Enter a gene name for Y-axis
2. Set the genes for X-axis. Enter gene names line by line, or choose a gene set.
3. Choose the calculation method: either Pearson or Spearman.
4. Toggle "Use log scale" on or off, if needed.
5. Click the start button to generate a results table below.
6. Clicking any row in the table displays its scatter plot on the right.

??? success  "Adjustable graph parameters"
    - Figure dimensions (width and height)
    - Font size for X and Y axis labels and titles
    - Size of sample labels and legend
    - Option to show the correlation line.
    - Option to use only the selected samples (’Select samples’)
    - Option to change colours by group

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_9_annot_light.mp4" type="video/mp4"> 
    </video>


### <u> **3.3. Heatmap** </u>
The heatmap feature allows you to visualise gene expression patterns across samples. Here's how to use it:

1. Input the genes to be used in the heatmap by either:
    - Text input: Enter genes directly through
    - Custom Gene Sets: Select a gene set from registered gene sets. (A drop-down menu appears)
    - HALLMARK (Human)/(Mouse): Select a gene set from HALLMARK (A drop-down menu appears)
    - Input a gmt file: Upload a GMT file of another gene set group and select a gene set. (An upload menu and a drop-down menu appear)
2. Select the samples of interest from the sample table.
3. Click "Generate a heatmap".
    - A heatmap visualises the standardised expression scores across selected genes and samples.
    - The "Expression scores" table shows standardised values
4. Adjust "Cluster number"
    - You can cluster the genes based on their expression patterns by changing the slider bar below the plot.

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure.
    - The size of the X and Y axis/label font size.
    - The colour of the highest, lowest and zero values in the heatmap

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Data_overview_10_annot_light.mp4" type="video/mp4"> 
    </video>


### <u> **3.4. PCA plot** </u>
1. If you don't have any specific preferences, simply click "Generate a PCA plot".
    - By default, all samples will be included and colored according to the detected groups (those with replicates, as shown in the swarm plot).
2. To customise sample selection, click "Define the groups":
    - Enter the sample names and their descriptions, separated by commas. The available sample names are listed below.
    - Click "Generate a PCA plot"


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