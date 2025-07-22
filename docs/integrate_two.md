# **Dataset Integration**
This section allows users to visualise two datasets side by side, making it easy to see how genes affected in one dataset relate to the other. Users can also merge the datasets to create integrated visualisations.

## <u> **1. Data exchanging** </u>
This feature compares two datasets side by side and transfers information between them to visualise how genes affected in one dataset correspond to their behaviour in another dataset.

1. Select the direction:
    - View selected genes from Data1 (left, the data mapping side) on Data2 (right, the data mapped side)
    - View selected genes from Data2 (right, the data mapping side) on Data1 (left, the data mapped side)
2. Choose two datasets (Data1 and Data2) and select the X and Y axes for each.
    - Filter your datasets using "Data from," "Experiment," and/or "Data type" if needed.
3. Select genes of interest in the data mapping side using either:
    - Setting thresholds for both X and Y axes (default method)
    - Manual selection by drawing an area on the plot
4. Once selection is complete, the selected genes will be highlighted in the other dataset's plot. The selected gene information will appear in the Overlap genes section below.
5. In the Overlap genes section, you can apply additional filters on the mapped side. The filtered genes will be displayed as a table.

Important notes: Ensure the column containing gene names is labelled "id" for proper dataset merging. If selected genes aren't present in the other dataset, no highlighting will appear.

## <u> **2. Integration Plot** </u>
Users can merge two datasets and plot them together. A common use case is plotting the log fold change (LFC) from Data1 on the X-axis and the LFC from Data2 on the Y-axis to assess consistency between datasets.

To create a plot, select the X and Y axes. Column names from Data1 are prefixed with "Data1_XXX" and from Data2 with "Data2_XXX". You can also select another score to colour the dots. To highlight specific genes, enter their names in the "Enter gene(s)" text box. Detailed information appears on the right when you select an area in the plot with your mouse.
