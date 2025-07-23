
# **Compare across datasets**

This section enables users to compare numerical scores (such as log fold changes of genes of interest) across multiple datasets. After selecting datasets of the same type, users can perform two types of analyses:
 
1. **"Get overlaps"**: Compare the top/bottom N% of hits across datasets to identify genes that consistently appear as significant hits, tracking their frequency of occurrence.
2. **"Compare one gene"**: Compare specific scores (such as the LFC value of a particular gene) across datasets to identify experiment-specific effects and determine which conditions show stronger effect sizes.


## <u> **0. Datasets selection**</u>

1. First, select a "Data type" from the dropdown menu to view compatible datasets with matching structures.
2. Next, select datasets for analysis by clicking rows in the table. Use "Select all" or "Deselect all" buttons as needed. For targeted analysis, use the "Data from" and "Experiment" filters to narrow options by source or conditions.

## <u>**1. Get overlaps** </u> <br>
This section analyses and identifies genes that consistently appear as significant hits across multiple datasets to .

1. (Select the datasets to compare)
2. Select a score for ranking
    - Typically log fold changes.
    - The interface gets the top or bottom N% of genes ranked by this score.
3. Select the direction
    - Either investigating top X% or bottom X%
    - For top X%, the interface will identify how many times each gene appears in the top X% across the selected datasets.
4. Set the threshold (Default: 5%)
5. Set "Overlap_times"
    - This defines how many times a gene must appear in the top/bottom N%
    - Example: If you select 10 datasets and set Overlap_times to 5 for top 15%, it will return genes that appear in the top 15% in at least 5 of the 10 datasets.
6. Click the start button
    - The results table will appear below.
    - The result table displays the frequency of each gene's appearance and its corresponding score for each dataset. When a gene is not in the top/bottom X% in a dataset, its score will be blank for that dataset.
7. Clicking any gene name in the table generates a bar plot on the right


??? success  "Adjustable graph parameters"
    - The size (width and height) of the figure
    - The size of the X and Y axis label/title font size
    - The size of the graph title
    - The color of the highest/lowest/zero value

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Compare_acorss_datasets_1_720.mp4" type="video/mp4"> 
    </video>


## <u>**2. Compare one gene**</u>

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
