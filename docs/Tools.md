# **Tools**
This section contains useful tools and functions that support analyses in other sections.

## <u> **1. Human & Mouse Gene Converter** </u>
This tool converts gene symbols between human and mouse.

1. Select the conversion direction (human to mouse or mouse to human).
2. Specify the input and output formats. The tool handles gene symbols and Ensembl gene IDs (with or without version numbers).
3. Enter gene names one per line and click "Convert genes."

A Conversion Table showing corresponding gene names between species will be generated. If no ortholog exists for a gene, that entry remains blank. The "List of Converted Genes" on the right displays only genes with identified orthologs, ready to be copied and used in other sections. This tool utilises the Ensembl genome browser 113 (BioMart, GRCh38.p14 and GRCm39). Note that a single gene may have multiple orthologous matches.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_1_annot_light.mp4" type="video/mp4"> 
    </video>


## <u>**2. Ensembl ID & Gene Symbol Converter** </u>
This tool converts between gene symbols and Ensembl IDs for both human and mouse genes.

1. Select the species
2. Specify input and output formats
3. Enter gene names line by line and click "Convert genes"

A Conversion Table will be displayed in the middle. Entries without matches remain blank. The List of Converted Genes on the right provides a clean list of successfully converted names. This tool utilises data from the Ensembl genome browser 113 (GRCh38.p14 and GRCm39).

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_2_annot_light.mp4" type="video/mp4"> 
    </video>

## <u>**3. Find gene loci**</u>

This tool displays chromosomal coordinates for genes of interest in humans. It can also identify genes at specific genomic locations.

1. Select the method: either find coordinates of genes or find genes at coordinates.
2. Enter either gene names or genomic loci line by line. For genomic coordinates, use the format: chromosome number, start and end positions connected by ":" and "-" (e.g., chr1:76021118-7602349).
3. Click "Search".

The tool generates a table showing gene names (both Ensembl ID and gene symbol), chromosome, start position, end position, and strand information. A copyable list of genes or coordinates appears on the right, ready for use in other sections—particularly useful when exploring ChIPseq, ATACseq, or using the Genome browser session. The conversion uses annotation files from [GENCODE](https://www.gencodegenes.org/human/release_42.html) (GRCh38.p13)

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_3_annot_light.mp4" type="video/mp4"> 
    </video>

## <u>**4. Cross-tabulation analysis**</u>

This section offers a cross-tabulation analysis tool for examining relationships between two categorical variables. Follow these steps:

1. Enter category names and values for each entry
    - This automatically generates a 2×2 table and a plot
2. Choose display options:
    - View percentiles (default) or original count values
    - Select stacked bar plot (default) or dodge bar plot
3. Check the calculated p-value from either:
    - Chi-square test (default)
    - Fisher's exact test

??? success  "Adjustable graph parameters"
    - Figure size (width, height)
    - Font size (labels, title, including the legend)
    - Colours for each category
    - Use a white background
    - Rotate the X labels for 90°

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_4_annot_light.mp4" type="video/mp4"> 
    </video>

## <u>**5. Venn Diagram**</u>

This section helps users quickly check the overlaps between two or three groups and create a Venn diagram.

1. Choose a method: either a 2-group or a 3-group Venn diagram.
2. Enter the group names and their elements (one per line). A Venn diagram automatically appears on the right.
3. To determine which elements overlap or are specific to a particular group, select a category below. A list of elements in the selected category will be displayed.

The following figure parameters can be customised:

??? success  "Adjustable graph parameters"
    - Figure size (width, height)
    - Font size (labels, title)
    - Colours for each group

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_5_annot_light.mp4" type="video/mp4"> 
    </video>

## <u>**6. Network Plot**</u>
This section generates a network plot by providing a TSV file containing nodes, edges, and weights.

1. Upload the input TSV file. The header should contain 'from', 'to' and 'weight' columns. Click the "Use an example data" switch to see sample data. The data table will be displayed below.
2. After uploading, the network graph will be automatically generated.

??? success  "Adjustable graph parameters"
    - The shape of the From nodes and the To nodes.
    - The colour of the From nodes and the To nodes.
    - Option to show the direction of the node connections.

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Tool_6_annot_light.mp4" type="video/mp4"> 
    </video>