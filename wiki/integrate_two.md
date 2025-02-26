<span style="font-family: Helvetica, Arial, serif">

# <span style="font-family: Helvetica, Arial, serif; font-size: 36px;"> Dataset Integration </span>

> <span style="font-size: 22px;">
>
> This section allows users to visualise two datasets side by side, making it easy to see how genes affected in one dataset relate to the other. Users can also merge the datasets to create integrated visualisations.

<span style="font-size: 22px;">

- [ Data exchanging ](#data-exchanging)
- [ Integration Plot ](#integration-plot)

</span>

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"> Data exchanging </span>
> <span style="font-size: 22px;">
>
> Users can plot two datasets side by side and transfer information between the left and right panels (or in the opposite direction. Select the direction in the "Direction" section). To begin, select two datasets (Data1 and Data2) and choose the X and Y axes for each. As in the "Data Overview" section, you can filter datasets by "Data from," "Experiment," and/or "Data type." By default, you select genes in Data1 to see their locations in Data2. 
>
> There are two gene selection methods: 1) use thresholds for both X and Y axes (default), or 2) manually select an area in the plot with your mouse. For threshold selection, you can specify the direction (considering either positive or negative genes). The number of selected genes appears below. After selection, these genes are highlighted in Data2's plot (or Data1's plot if you changed the Direction). 
>
> Make sure the column containing gene names is labelled "id" for proper dataset merging. Note that if selected genes aren't present in the other dataset, no highlighting will appear. You can set a threshold for Data2 (information-mapped side) to identify genes that meet the criteria in both datasets (overlapped genes). A table of these overlapping genes appears below.

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"> Integration Plot </span>
> <span style="font-size: 22px;">
>
> Users can merge two datasets and plot them together. A common use case is plotting the log fold change (LFC) from Data1 on the X-axis and the LFC from Data2 on the Y-axis to assess consistency between datasets.
> 
> To create a plot, select the X and Y axes. Column names from Data1 are prefixed with "Data1_XXX" and from Data2 with "Data2_XXX". You can also select another score to colour the dots. To highlight specific genes, enter their names in the "Enter gene(s)" text box. Detailed information appears on the right when you select an area in the plot with your mouse.

</span>