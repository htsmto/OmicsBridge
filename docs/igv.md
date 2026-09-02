# **Epigenome Visualisation**

## <u>**1. Profile Plot**</u>

This section allows users to generate a profile plot using selected bigWig files. 
A profile plot is a visualisation that displays signal intensities across a specified genomic region using selected bigWig files. It allows users to examine patterns of data, such as epigenetic signals, over a defined chromosomal interval.

1. **Select datasets:**<br>
Select the bigWig files you want to include in the profile plot and click 'Import the selected sample'. The loaded samples will appear in a list table. All datasets in this table will be used for plotting. To remove datasets from this list, select them in the table and click 'Remove the selected sample'. Note that importing data takes a few seconds.

    Use the "Data from" and "Experiment name" dropdowns (behind the filter icon next to the dataset selector) to narrow the list to matching datasets. Click "Reload your datasets list" to refresh with any datasets uploaded or edited since the page was loaded.

2. **Set chromosome positions:**<br>
Enter chromosome locations line by line using the format `chr:start-end` (e.g., `chr1:1000000-2000000`) to define regions for plotting. You can also specify how much additional sequence to include by adjusting the 'Extend length' value. The default extension is 2000 base pairs, meaning the plot will display from (start - 2000) to (end + 2000).
3. **Generate the profile plot:**<br>
Click on "Generate a plot" to create the visualisation. The profile plot will display signal intensities across the specified genomic region for each selected bigWig file. The profile plot consists of two parts: the upper section displays signal intensity levels across the genomic region, while the lower section presents the same data as a heatmap visualisation for easier pattern recognition.

??? success  "Adjustable graph parameters"
    - Figure width (shared by both the upper plot and the heatmap) and figure height (set separately for the upper plot and the heatmap)
    - Font size for sample names and legend
    - X and Y axis label sizes
    - Heatmap colour scale (maximum and minimum colours)
    - Line colour for the signal intensity graph (upper part)

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Epi_1_annot.mp4" type="video/mp4"> 
    </video>

---

## <u>**2. Genome visualisation**</u>

This section visualises genomic read coverage from bigwig or bam files using the [Gviz library](https://bioconductor.org/packages/devel/bioc/html/Gviz.html). It displays coverage data across specified genomic regions.

1. **Select the datasets**<br>
Choose datasets from the drop-down menu and click 'Use this dataset'. The selected datasets are listed in the table below and will be included in the plot. To remove a dataset, select it in the table and click 'Remove the dataset from the list'.

    Click "Reload your datasets list" to refresh the dropdown with any datasets uploaded or edited since the page was loaded.

2. **Set the chromatin positions and generate the plot**<br>
Select either hg38 or hg19 genome, then specify the position to visualise using the format `chr:start-end`. Note that specifying too wide a range will result in an error.

!!! warning "Things to note"
    - When using BAM files, a wide range (e.g., >100k-200k bp) can cause a memory error and stop the interface. This issue does not occur when using only BigWig files.
    - If a sample's label is missing from the plot, try increasing the figure height and re-plotting.
    - Track colours, track heights, and the Y-axis limit options below only take effect after you click "Show a plot" again — changing them does not update an existing plot automatically.

??? success  "Adjustable graph parameters"
    - Figure size (width and height)
    - Track height for bigwig data, bam data, or reference genome display
    - Colour settings for bigwig data, bam data, or reference genome tracks
    - Option to set a manual Y-axis maximum, separately for bigwig and bam data
  
??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Epi_2_annot.mp4" type="video/mp4"> 
    </video>

---

## <u>**3. IGV**</u>

The IGV (Integrated Genome Viewer) section embeds a genome browser within the interface, allowing users to view data from bed files directly in the browser. [IGV](https://igv.org/) is a widely used tool for visualising genomic data. It supports a variety of file formats, including BAM, BED, and BigWig, and provides an interactive platform for exploring genomic alignments, annotations, and datasets. <br>
In this section, due to memory limitations, only bed files can be viewed. For visualisation of bigwig or bam files, please refer to the 'Genome visualisation' section.

1. **Choose a genome**<br>
Currently, human (hg19 and hg38) and mouse genome (mm10 and mm39) are available.
2. **Select a dataset**<br>
Choose a dataset to view in IGV from the drop-down menu. Use the "Data from" and "Experiment" dropdowns (behind the filter icon) to narrow the list, and click "Reload your datasets list" to refresh it with any datasets uploaded or edited since the page was loaded. Once selected, dataset details will appear below.
3. **Click the 'View in IGV' button**<br>
The selected dataset will be displayed in the IGV section on the right. Like the original IGV, you can specify chromosome positions, change color settings, and more. For detailed instructions, please refer to the original IGV documentation.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Epi_3_annot_light.mp4" type="video/mp4"> 
    </video>

---

## <u> **4. Find Enhancer/Promoter**</u>

This section identifies potential enhancers or promoters for each gene by analysing the correlation between gene expression from RNAseq and peak intensity from ATACseq. Using a normalised read count table with matched RNAseq and ATACseq data, it calculates the correlation for peaks located around each gene's genomic region (default range: ±100K, adjustable). Peaks with a high correlation coefficient or significant results are highlighted as potential enhancers or promoters for the corresponding gene.

1. **Select the RNAseq and ATACseq data**<br>
First, select the matched RNAseq and ATACseq datasets. The RNAseq data is a normalised read count table where the indexes are gene names and columns are sample names. The ATACseq is also a normalised read count table where the indexes are chromosome positions (chr:start-end) and columns are sample names.

    Use the "Data from", "Experiment", and "Data type" dropdowns (behind the filter icon) to narrow either dataset list, and click "Reload your datasets list" to refresh with any datasets uploaded or edited since the page was loaded. Once a dataset is selected, its column (sample) names are shown below the dropdown, for reference when entering the matched sample pairs in step 2.

2. **Specify the matched samples**<br>
Next, tell the interface which RNAseq samples and ATACseq samples are matched. In the text box, enter each pair of matched samples on a new line, with the RNAseq sample name and ATACseq sample name separated by a comma (,). At least 3 matched pairs are required.
3. **Enter the genes to investigate**<br>
Enter the gene names you want to check, one per line. You can also use genes from custom gene sets.
4. **Calculation type**<br>
Choose either Pearson or Spearman (default) for the correlation calculation.
5. **Specify the genomic region range**<br>
The default range is ±100kb. By adjusting this value, the interface calculates correlations between the gene and peaks within a specified distance from the gene's position, on the same chromosome as the gene ("Check only the same chromosomes of the target genes" is on by default). Unchecking this option instead checks peaks across all chromosomes, which significantly increases calculation time.
6. **Start calculation**<br>
Click the "Find enhancers/promoters" button to begin the calculation. The results appear on the right in a "Results" box with three tabs:

    === "**Correlation result**"
        A table of every gene-peak pair tested, with its correlation coefficient and p-value, downloadable via "Download this table". Selecting a row draws a scatter plot of that gene's expression against that peak's accessibility across the matched samples, with an optional fitted correlation line.

        ??? success "Adjustable graph parameters"
            - Figure size (width and height)
            - X/Y title font size and X/Y label font size
            - Graph title font size
            - Sample label size
            - Option to hide the sample labels
            - Option to show the correlation line
            - Point colour

    === "**RNAseq data table**"
        The RNAseq expression table for the input genes and matched samples. Selecting a gene row draws a bar plot of that gene's correlation with every nearby peak it was tested against, coloured by correlation strength; bars are marked with an asterisk (*) where the p-value is below the threshold set in the "Show the potential enhancer/promoter list" box below (step 7).

        ??? success "Adjustable graph parameters"
            - Figure size (width and height)
            - X/Y title font size and X/Y label font size
            - Graph title font size
            - Legend size
            - Colour for the highest, lowest, and midpoint (zero) correlation

    === "**ATACseq data table**"
        The ATACseq peak intensity table for the peaks tested and matched samples. Selecting a peak row draws the equivalent bar plot the other way round: that peak's correlation with every gene it was tested against.

        ??? success "Adjustable graph parameters"
            - Same parameters as the RNAseq data table above

    Note that only the Correlation result table has its own "Download this table" button; the RNAseq and ATACseq data tables are for reference and plotting only.

7. **Show the potential enhancer/promoter list**<br>
Below the Results box, select a gene (or "All") from the drop-down menu and set a P-value threshold. The box below lists the peak IDs correlated with the selected gene(s) below that threshold, ranked by correlation strength — these are the potential enhancers/promoters.

!!! note "Gene coordinates"
    Gene positions used to find nearby peaks are looked up from a fixed GRCh38 (hg38) gene annotation, regardless of the genome build your own RNAseq/ATACseq data was aligned to.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Epi_4_annot_light.mp4" type="video/mp4"> 
    </video>

---

## <u> **5. Motif scan** </u>

This tool scans for transcription factor motifs in the input chromatin positions or sequences using the [MotifDb](https://bioconductor.org/packages/release/bioc/html/MotifDb.html) database (PWMLogn.hg19.MotifDb.Hsap), identifying potential binding sites within specified genomic regions.

1. **Set the input**<br>
First, choose the input type: either "Input genomic positions" or "Input sequences". For "Input genomic positions", enter the genomic positions line by line using the format chr:start-end, and select either hg38 or hg19 genome type. For "Input sequences", enter the genomic sequence directly line by line. Note that the calculation will stop if you use any characters other than A, T, G, and C.
2. **Start motif scan**<br>
Click the start button to begin the motif scan. Each input takes a few seconds to process, so the total time depends on how many positions you've entered. Once scanning is complete, a results table will appear on the right, ranked by statistical significance, and is downloadable via "Download motif table". Click any row to display the corresponding motif logo at the bottom.
The results table includes:
    - raw.score: Raw enrichment score for the motif across input regions
    - top.motif.prop: Proportion of top-scoring regions where the motif was found

    Expand the collapsed "Significant motifs" box to set a significance threshold (default: 0.05) and see a plain list of motif names passing it.

??? success  "Adjustable graph parameters"
    - Figure size (width and height) for the motif logo plot
    - X/Y label size and X/Y title size
    - Y axis type: bits or probability

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Epi_5_annot_light.mp4" type="video/mp4"> 
    </video>
