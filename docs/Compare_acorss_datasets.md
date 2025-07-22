
# **Compare across datasets**

This section enables users to compare numerical scores (such as log fold changes of genes of interest) across multiple datasets. After selecting datasets of the same type, users can perform two types of analyses:
 
1. **"Get overlap"**: Compare the top/bottom N% of hits across datasets to identify genes that consistently appear as significant hits, tracking their frequency of occurrence.
2. **"Compare one gene"**: Compare specific scores (such as the LFC value of a particular gene) across datasets to identify experiment-specific effects and determine which conditions show stronger effect sizes.


## <u> **Datasets selection**</u>

1. First, select a "Data type" from the dropdown menu to view compatible datasets with matching structures.
2. Next, select datasets for analysis by clicking rows in the table. Use "Select all" or "Deselect all" buttons as needed. For targeted analysis, use the "Data from" and "Experiment" filters to narrow options by source or conditions.

## <u>**Get overlap: Identify genes that consistently appear as hits across multiple datasets** </u>
This section analyses genes that consistently rank at the top or bottom across selected datasets, identifying significant hits. By default, it selects the top 5% of genes ranked by the user-specified score, typically log fold changes. After clicking "Investigate the overlap," a results table appears, showing how many times each gene appears in the top/bottom N% (i.e., "Overlap_times") across the selected datasets. The table also displays each gene's score in datasets where it's significant. For non-hit genes, the score remains blank for that dataset. <br>

Users can filter the results by setting a minimum threshold for gene overlap across datasets using "Show genes whose Overlap_time is more than:". This lets you focus on genes that consistently appear as significant hits in multiple datasets. <br>

Clicking any gene name in the table generates a bar plot on the right.

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the X and Y axis label/title font size
    - The size of the graph title
    - The color of the highest/lowest/zero value

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Compare_acorss_datasets_1_720.mp4" type="video/mp4"> 
    </video>


## <u>**Compare one gene: Compare the scores for specific genes**</u>

This feature compares scores of specific genes across selected datasets, displaying results as either a bar plot or scatter plot (bar plot is default). To use it:

1. Enter gene names in the text box
2. Select the "Y-axis" parameter (typically log fold change or similar value)
3. Choose a "Colour" parameter to determine how bars/dots are colored (can match the Y-axis value or another measure like p-values)

After clicking "Start Analysis," a list of gene names appears. Click any gene to display its plot on the right. 

Note that if none of the datasets contains the selected gene, no plot will appear.

??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the dots (only for the scatter plot)
    - The size of the X and Y axis label/title font size
    - The size of the graph title and the legend
    - The colour of the highest/lowest/zero value
    - The white background option

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Compare_acorss_datasets_2_720.mp4" type="video/mp4"> 
    </video>
