<span style="font-family: Helvetica, Arial, serif">

# <span style="font-family: Helvetica, Arial, serif; font-size: 36px;"> scRNA dataset </span>

> <span style="font-size: 22px;">
>
> Here, users can visualise the registered scRNAseq dataset and investigate their genes of interest in it. For each gene, users can see: <br>
> (1) a feature plot (the expression across all the single cells in UMAP), <br>
> (2) a dot plot, a Violin plot, a Ridge plot and <br>
> (3) the fractions of the cells expressing the gene in each group.

<span style="font-size: 22px;">

- [ Pre-processing ](#pre-processing)
- [ Data overview and Feature plot ](#data-overview-and-feature-plot)
    - [ Dataset overview ](#dataset-overview)
    - [ Gene feature plot ](#gene-feature-plot)
- [ Other plots ](#other-plots)
    - [ Violin·Dot·Ridge plot ](#violindotridge-plot)
    - [ Fraction of the cells ](#fraction-of-the-cells)

</span>

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"> Pre-processing </span>
> <span style="font-size: 22px;"> The interface accepts an RDS file as input for the scRNA section. The scRNA data must be processed using Seurat and ready for UMAP plotting (not tSNE). Before uploading to the interface, it is highly recommended to annotate each cluster with its corresponding cell type. For more information, please refer to the Seurat tutorial.

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"> Data overview and Feature plot </span>

> ### <span style="font-family: Helvetica, Arial, serif; font-size: 28px;"><u> Dataset overview </u></span>
>> <span style="font-size: 22px;">
>>
>> This gives you a simple overview (UMAP) of the data. You can colour the cluster by the metadata stored in the data (the table stored in Seurat_object@meta.data). The header of the metadata can be selected in the “Colour by” section. 
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure.
>> - the size of the XY axis/label, graph title and the legend font size.
>
> ### <span style="font-family: Helvetica, Arial, serif; font-size: 28px;"><u> Gene feature plot </u></span>
>> <span style="font-size: 22px;">
>>
>> Here, you can visualise how your genes of interest are expressed across different cell types in the scRNAseq dataset.
>> 
>> Enter your genes of interest (one per line) to display them in a selectable table. When you select a gene, its expression pattern appears on the UMAP plot. Cells not expressing the selected gene appear in black as a background, while cells expressing the gene (UMI > 0) are highlighted using a gradient colour scheme (default: white to red).
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure
>> - the size of the XY axis/label, graph title and legend font size
>> - The colour of the highest/lowest expression and the background

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"> Other plots </span>
> ### <span style="font-family: Helvetica, Arial, serif; font-size: 28px;"><u> Violin/Dot/Ridge plot </u></span>
>> <span style="font-size: 22px;">
>> 
>> Users can visualise how gene expression is distributed across different clusters or cell types in the scRNA data.
>> 
>> Enter gene names one per line. By default, the tool generates a dot plot, showing both the average expression and percentage of expressing cells in each cluster. You can choose which category to compare (”Group by” select button). While dot plots are the default visualisation, violin plots and ridge plots are also available.
>> 
>> <u>Adjustable plot parameters</u>:
>> 
>> - the size (width and height) of the figure
>> - the size of the X/Y axis labels, graph title, and legend font
>> 
> ### <span style="font-family: Helvetica, Arial, serif; font-size: 28px;"><u> Fraction of the cells </u></span>
>> <span style="font-size: 22px;">
>> 
>> Users can visualise the fraction of cells expressing their genes of interest across different clusters or cell types in the scRNA data. A cell is considered to be expressing a gene if it has a UMI count ≥1.
>> 
>> Enter gene names line by line and select your desired category. A selectable table of gene names will appear on the left. Clicking any gene name displays pie charts showing the proportions of expressing and non-expressing cells across groups in the selected category, with labels indicating the cell count in each group.
>> 
>> <u>Adjustable plot parameters</u>
>> 
>> - the size (width and height) of the figure
>> - the size of the label, group names, and legend
>> - the colour of the Expressing/Non-expressing
>> - hide the legend ("Hide legends")
>> - hide the label ("Hide labels")



</span>