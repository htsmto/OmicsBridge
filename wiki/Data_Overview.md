<font size="4">

<span style="font-family: Helvetica, Arial, serif">

# <span style="font-family: Helvetica, Arial, serif; font-size: 36px;"> Data Overview </spna>

> <span style="font-size: 22px;"> 
>
> This section provides an overview of the selected dataset (except for scRNA data and bam/bed files, which are viewable in the "scRNA" and "Genome Browser" sections). Users can create various plots, identify and highlight significant genes and hits, examine overlaps with gene sets of interest, and conduct downstream analyses including GO/KEGG and GSEA analysis.

<span style="font-size: 22px;">

  - [ Data Selection ](#data-selection)
  - [ When the data type is "Comparison data" ](#when-the-data-type-is-comparison-data)
    - [ Plot ](#plot)
      - [ Getting a general overview (scatter plot) ](#getting-a-general-overview-scatter-plot)
      - ["Show outliers": Highlighting the filtered genes ](#show-outliers-highlighting-the-filtered-genes)
      - [ "Show pathway genes": Showing the pathway genes ](#show-pathway-genes-showing-the-pathway-genes)
      - [ "Show custom genesets": Showing the custom gene set genes ](#show-custom-genesets-showing-the-custom-gene-set-genes)
    - [ Downstream analysis ](#downstream-analysis)
      - [ GO/KEGG analysis ](#gokegg-analysis)
      - [ GSEA analysis ](#gsea-analysis)
      - [ Transcription Factor activity inference analysis ](#transcription-factor-activity-inference-analysis)
  - [ When the data type is "Count table" ](#when-the-data-type-is-count-table)
    - [ Swarm plot ](#swarm-plot)
    - [ Heatmap ](#heatmap)
    - [ PCA plot ](#pca-plot)
</span>

<br>

## <span style="font-family: Helvetica, Arial, serif;font-size: 30px;"><u> Data Selection </u></span>

> <span style="font-size: 22px;"> 
>
> Users can filter and select datasets using three categories defined during upload: "Data from," "Experiment," and "Data type." <br>The interface then shows detailed information about the selected dataset.
> 
> Once a dataset is selected, users can view it as a spreadsheet in the "Data Table" tab. <br>Depending on the data type, users can also create visualisations and conduct downstream analyses in additional tabs.

<br>

## <span style="font-family: Helvetica, Arial, serif;font-size: 30px;"><u> When the data type is "Comparison data" </u></span>

> <span style="font-size: 22px;"> 
>
> In the "Plot" tab, users can visualise the data and perform several downstream analyses, including GO and GSEA analysis.
>
> ### <span style="font-family: Helvetica, Arial, serif;font-size: 28px;"><u> Plot </u></span>
>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **Getting a general overview (scatter plot)** </u></span>
>>> <span style="font-size: 22px;"> 
>>>
>>> First, users can generate a scatter plot for a general overview of the selected dataset by choosing the X and Y axes. Typically, the X-axis represents "Log Fold Change" while the Y-axis shows a statistical value such as "-log10(p.value)". If the plot fails to generate, please verify that the header name (column name) containing gene/protein/transcription names is set to "id". The plot uses a grey background by default, though white is also available via the "Use white background" checkbox.
>>> 
>>> When users select an area in the plot with their mouse, the dots within that area will be labelled with their names (ids). Additional details about these dots, including relevant scores, appear in a table at the bottom of the page under "Selected Area Information".
>>>
>>> To highlight genes of interest in the plot, enter their names line by line in the "Enter gene(s)" box. The genes will be highlighted in red by default. If no highlights appear, verify that your genes exist in the dataset—a message will indicate which genes are not found. Remove any extra spaces before or after gene names in the text box. Select "show information as a table" to view and download details about highlighted genes in the "Information of genes of interest" section. Use the "show gene names" checkbox to toggle gene labels on or off when the display becomes crowded.
>>>
>>> <u>Adjustable plot parameters</u>:
>>> 
>>> - the size (width and height) of the figure.
>>> - the size of all the dots and the highlighted dots.
>>> - the size of the highlighted label size.
>>> - the size of the XY axis label and title font size.
>>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **"Show outliers": Highlighting the filtered genes** </u></span>
>>> <span style="font-size: 22px;">
>>>
>>> Users can highlight significant data points by selecting "Show outliers." By default (”Show top/bottom N%”), this highlights the top and bottom 10% of hits. The data points are sorted by X-axis score and filtered by Y-axis value (default: 1.13, which corresponds to -log10(p.value) where p=0.05). The top 10% represents the highest-scoring points where X ≥ 0 and Y ≥ 1.13, while the bottom 10% represents the lowest-scoring points where X ≤ 0 and Y ≥ 1.13. Users can customise these thresholds for both X-axis (positive and negative sides) and Y-axis values. With "Custom threshold setting" selected, users can directly specify their desired X and Y threshold values. They can also decide to filter to show only positive hits, only negative hits, or both.
>>>
>>> <u>Available options include</u>:
>>> 
>>> - Hide gene name labels when they become crowded ("Hide labels")
>>> - Customize highlighting colours for both positive and negative sides ("change the colour")
>>> - Display threshold lines vertically or horizontally ("Show the threshold lines")
>>> - View filtered points in a downloadable table in the "Outliers Information" section below. Users can also access a simple list of filtered gene names for easy copying to other analyses ("Show the filtered genes information")
>>> - View the filtered data as a bar plot, sorted by X-axis value (e.g., LFC). The bars can be colored based on X-axis values, Y-axis values, or shown in plain grey. Any genes listed in the "Enter genes" box will be highlighted in red. ("Show in a bar plot")
>>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **"Show pathway genes": Showing the pathway genes** </u></span>
>>> <span style="font-size: 22px;">
>>>
>>> Users can visualise genes associated with specific pathways in the plot. HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as preset options. Users with custom gene sets can upload them in GMT format by selecting "custom." Note that only gmt files are supported. After selecting a pathway, all genes within that pathway will be highlighted in the plot.
>>> 
>>> <u>Available options include</u>:
>>> 
>>> - hide id labels when they become crowded ("Hide labels")
>>> - display information about filtered points in a table below ("Show the genes information")
>>> - change the highlighting colour ("Change the colour")
>>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **"Show custom genesets": Showing the custom gene set genes** </u></span>
>>> <span style="font-size: 22px;">
>>>
>>> Users can visualise genes from their custom gene sets that are registered in the interface. When a gene set is selected, all genes within that set will be highlighted in the plot. For instructions on creating gene sets, refer to the "Gene set" section.
>>> 
>>> <u>Available options include</u>:
>>> 
>>> - Hide gene labels when the display becomes crowded ("Hide labels")
>>> - Display detailed information about the highlighted genes in the table below ("Show the genes information")
>>> - Customize the highlighting colour ("Change the colour")
>>
> ### <span style="font-family: Helvetica, Arial, serif;font-size: 28px;"><u> Downstream analysis </u></span>
>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **GO/KEGG analysis** </u></span>
>>> <span style="font-size: 22px;">
>>> 
>>> Users can perform GO or KEGG analysis using gene symbols (ENSEMBL IDs are not supported so far). There are three ways to input genes:
>>> 
>>> 1. Text input: Enter a list of genes in the text box, one per line.
>>> 2. Use filtered genes: Import genes that pass the threshold from the "Show outliers" plot option directly into the analysis.
>>> 3. Use selected genes: Choose genes by selecting an area in the plot with your mouse.
>>> 
>>> After entering genes, select the species and database. Currently, GO-BP, GO-MF, GO-CC, and KEGG analyses are available for both humans and mice.
>>> 
>>> Click "Start GO Analysis" to begin. The analysis takes 1-3 minutes depending on input size and chosen ontology, and produces four results:
>>> 
>>> 1. Table: Complete GO/KEGG analysis results
>>> 2. Bar plot: Enriched GO/KEGG terms showing gene count and p-value
>>> 3. Bubble plot: Alternative visualization showing the proportion of detected genes within each term
>>> 4. Network plot: Visual network of the top 5 enriched GO/KEGG terms and their connections to detected genes
>>> 
>>> <u>Adjustable plot parameters</u>:
>>> 
>>> - Number of categories/terms to display in bar and bubble plots
>>> - Figure width and height
>>> - X and Y axis label size
>>> - X axis title size
>>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **GSEA analysis** </u></span>
>>> <span style="font-size: 22px;">
>>>
>>> Users can perform GSEA analysis using their chosen gene sets. HALLMARK gene sets for humans and mice from [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb) are available as presets. Users with other gene sets can select "Upload a gmt file (other gene sets)" and upload a gmt file (note that only gmt format is supported). Next, users must select which score to use for GSEA ranking—typically the log fold change. This score determines how genes are sorted and ranked during analysis. Selecting a non-numeric category will result in an error.
>>> 
>>> After clicking "Start GSEA Analysis," the interface displays a table with statistical scores (p-values and adjusted p-values) and enrichment scores (ES and normalized enrichment score NES). Clicking any pathway name in the table reveals its GSEA plot on the right.
>>> 
>>> <u>Adjustable plot parameters</u>:
>>> 
>>> - the size (width and height) of the figure
>>> - the size of the X and Y axis font size
>>> - the size of the graph title
>>
>> #### <span style="font-family: Helvetica, Arial, serif;font-size: 24px;"><u> **Transcription Factor activity inference analysis** </u></span>
>>> <span style="font-size: 22px;">
>>>
>>> This analysis is specifically for RNA-seq data processed by DESeq2 and requires 'stat' values from DESeq2. It uses the [decoupleR](https://saezlab.github.io/decoupleR/) package to estimate transcription factor (TF) activity based on expression changes in their target genes. Simply click "Start DecoupleR Analysis" to generate a bar plot and results table (approximately 1 minute). In the bar plot, positive scores indicate TF activation in the treatment group compared to the control group. You can customize how many TFs are displayed.
>>> 
>>> <u>Adjustable plot parameters</u>:
>>> 
>>> - the size (width and height) of the figure.
>>> - the size of the X and Y axis font size.

## <span style="font-family: Helvetica, Arial, serif;font-size: 30px;"><u> When the data type is "Count table" </u></span>

> ### <span style="font-family: Helvetica, Arial, serif;font-size: 28px;"><u> **Swarm plot** </u></span>
>> <span style="font-size: 22px;">
>>
>> The swarm plot visualises expression differences of genes of interest across samples. Samples with the same experimental conditions (replicated samples) are grouped together, making it easy to compare differences between conditions. Please make sure that the sample names are all set to SamepleName_Rep# so that the interface can tell which samples are replicates of each other.
>> 
>> To create a plot, enter gene names line by line in the "Enter genes" box. The genes will appear in the table below. Clicking any gene in the table displays its swarm plot on the right. A detailed table showing individual sample scores appears beside the plot. To customise the display, check "Re-order the X axis" - this allows you to reorder or filter which experimental groups appear in the plot by entering group names line by line. The plot will show only the groups you specify in your chosen order.
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure.
>> - the size of the X and Y axis/label font size.
>> - the size of the graph title.
>> - The point size.
>>
> ### <span style="font-family: Helvetica, Arial, serif;font-size: 28px;"><u> **Heatmap** </u></span>
>> <span style="font-size: 22px;">
>>
>> Users can generate a heatmap to visualize gene expression patterns across selected samples. Expression values are standardized across samples to enable clear comparisons.
>> 
>> To create a heatmap, enter genes directly through "Text input" or select from gene sets. You can use your own registered gene sets from the "Gene sets" section under "Custom Gene Sets." Pre-installed options include HALLMARK gene sets from MSigDB for both human and mouse data. Additional gene sets can be uploaded via gmt files (using "input a gmt file"). After entering genes or selecting a gene set, choose your samples of interest from the sample table. Click "Generate a heatmap" to create a visualization of standardized expression values across your selected samples.
>> 
>> The heatmap includes clustering analysis based on expression patterns, helping you identify groups of co-expressing genes. Adjust the "Cluster number" (default is 1 for no clustering) and regenerate the plot to group genes into your desired number of clusters.
>> 
>> The "Expression scores" table below the plot shows standardized scores and cluster assignments for each gene.
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure.
>> - the size of the X and Y axis/label font size.
>> - the colour of the highest, lowest and zero values in the heatmap
>>
>  ### <span style="font-family: Helvetica, Arial, serif;font-size: 28px;"><u> **PCA plot** </u></span>
>> <span style="font-size: 22px;">
>> 
>> Users can generate a PCA plot from the count matrix to visualise sample patterns and relationships. By default, it uses all samples and colours them by detected groups (those with replicates, as in the swarm plot). Users can also specify which samples to include and assign group names themselves by clicking "Define the groups" and entering group descriptions following the example. Clicking "Generate a PCA plot" displays the visualisation coloured by either interface-detected or user-defined groups. Alternatively, you can use a single colour for all samples by unchecking "Colour by groups". 
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure
>> - the size of the X and Y axis label/title font size
>> - the size of all the dots
>> - the size of the sample labels and the legend
>> - hide the labels if they are messy ("Hide labels")
>> - use a white background instead of the default grey background ("Use white background")


</span>
