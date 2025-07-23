# **Dataset Integration**
This section allows users to visualise two datasets side by side, making it easy to see how genes affected in one dataset relate to the other. Users can also merge the datasets to create integrated visualisations.

## <u> **1. Data exchanging (Side by Side comparison)** </u>
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
This feature enables you to merge two datasets for integrated visualisation.

0. (Select the two datasets in the "Side by Side comparison" section.)
1. Select your data source for both X and Y axes to generate a scatter plot.
    - Data1 columns are prefixed with "Data1_XXX" and Data2 columns with "Data2_XXX"
    - X-axis typically represents scores from Data1
    - Y-axis typically represents scores from Data2
    - For example, plotting LFC from Data1 on the X-axis against LFC from Data2 on the Y-axis helps assess consistency between datasets
2. Enter gene names line by line to highlight them in the plot.
3. Select a region within the plot using your mouse to label dots with their gene names (IDs)
    - Detailed information about the selected area appears in a table below
4. Filtering options
    - Set thresholds for x and y to highlight dots that exceed these values
    - Select a gene set from HALLMARK or custom uploaded gene set lists ('Custom')
    - Genes in the filtered area appear in a table below

??? success  "Adjustable graph parameters"
    - Figure size (width and height)
    - Font size of x/y axis and title
    - Dot size for all points and highlighted points
    - Option to use a white background    