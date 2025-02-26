
<span style="font-family: Helvetica, Arial, serif">

# <span style="font-family: Helvetica, Arial, serif; font-size: 36px;">Compare across datasets</span>

> <span style="font-size: 22px;"> 
>
> This section allows users to compare numerical scores (such as log fold changes of genes of interest) across multiple datasets. After selecting datasets of the same type, users can perform two types of analyses:
> 
> 1. Compare the top/bottom N% of hits across datasets to identify genes that consistently appear as significant hits, tracking their frequency of occurrence.
> 2. Compare specific scores (such as the LFC value of a particular gene) across datasets to identify experiment-specific effects and determine which conditions show stronger effect sizes.

<span style="font-size: 22px;"> 

- [ Datasets selection ](#datasets-selection)
- [ Identify genes that consistently appear as hits across multiple datasets ](#identify-genes-that-consistently-appear-as-hits-across-multiple-datasets)
- [ Compare the scores for specific genes ](#compare-the-scores-for-specific-genes)

</span>

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;">Datasets selection</span>

> <span style="font-size: 22px;"> 
> 
> 1. First, select a "Data type." This will display a table of datasets with matching data frame structures (identical header names).
> 2. Select datasets for investigation by clicking rows. Use "Select all" to include all datasets in the database (within the same data type) or “Deselect all” to clear the selection. You can filter the database table by "Data from" and "Experiment."

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;">Identify genes that consistently appear as hits across multiple datasets </span>

> <span style="font-size: 22px;"> 
> 
> This section analyses the top or bottom rankings genes across selected datasets and identifies which genes consistently emerge as significant hits. By default, it will take the top 5% of the genes. The user has to specify the score for ranking the genes, which is typically log fold changes. Once the user starts by clicking “Investigate the overlap”, a table will return. This table shows how many times each gene appeared in the top 5% (this number and direction can be changed) of each selected dataset (”Overlap_times”) and each score (the score used for ranking) in each dataset if it is significant. If they are not the hit gene, the score will be just blank for that dataset.
> 
> The user can decide the minimum overlap times to display by specifying “Show genes whose Overlap_time is more than:”. Any click of the gene name in the table will show a bar plot below.
> 
> <u>Adjustable plot parameters</u>:
> 
> - the size (width and height) of the figure.
> - the size of the X and Y axis label/title font size.
> - the size of the graph title.
> - the colour of the highest/lowest/zero value

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;">Compare the scores for specific genes</span>

> <span style="font-size: 22px;"> 
>
> This feature compares the scores of genes of interest across selected datasets, displaying the results as either a bar plot or scatter plot (bar plot is default). First, enter gene names in the text box and select the "Y-axis" and "Colour" parameters. The Y-axis represents the score you want to compare—typically a log fold change or equivalent value. The colour parameter determines how the bars (or dots in a scatter plot) are colored. This can be set to match the Y-axis value (like LFC) or another statistical measure (like p-values). After clicking "Start Analysis," a list of gene names appears. Clicking any gene name displays its plot on the right. If none of the datasets includes the selected gene, no plot will be shown.
>
> <u>Adjustable plot parameters</u>
>
> - the size (width and height) of the figure.
> - the size of the X and Y axis/label font size.
> - the size of the graph title.
> - the colour of the highest/lowest/zero value.



</span>