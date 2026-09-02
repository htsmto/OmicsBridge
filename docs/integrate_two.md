# **Dataset Integration**

This section allows users to visualise two datasets side by side, making it easy to see how genes affected in one dataset relate to the other.

Users can also merge the datasets to create integrated visualisations.

---

## <u> **1. Data exchanging (Side by Side comparison)** </u>

This feature compares two datasets side by side and transfers information between them to visualise how genes affected in one dataset correspond to their behaviour in another dataset.

1. Select the direction:
    - View selected genes from Data1 (left, the data mapping side) on Data2 (right, the data mapped side)
    - View selected genes from Data2 (right, the data mapping side) on Data1 (left, the data mapped side)

    Click "Reload your datasets list" (next to the direction choice) to refresh with any datasets uploaded or edited since the page was loaded.

2. Choose two datasets (Data1 and Data2) and select the X and Y axes for each.
    - Filter your datasets using "Data from," "Experiment," and/or "Data type" if needed.

3. Select genes of interest in the data mapping side using either:
    - Setting thresholds for both X and Y axes (default method)
    - Manual selection by drawing an area on the plot

    For the threshold method, X and Y are each filtered independently using the same five modes available elsewhere in OmicsBridge: "none" (no filter), "> X1"/"> Y1" (above the first threshold — the default for both axes), "< X2"/"< Y2" (below the second threshold), "X2 < X < X1"/"Y2 < Y < Y1" (between the two thresholds), or "X < X2 or X > X1"/"Y < Y2 or Y > Y1" (beyond either threshold). A "Hide threshold line" switch is also available to hide the threshold lines drawn on the plot.

4. Once selection is complete, the selected genes will be highlighted in the other dataset's plot. The selected gene information will appear in the "Overlap genes" section below.

5. In the "Overlap genes" section, you can apply additional filters on the mapped side, using the same five-mode X/Y threshold system and its own "Hide threshold line" switch.

    The filtered genes will be displayed as a table ("Overlap genes table"), which is downloadable via "Download this table". You can also expand the collapsed "List of the genes" box below it to see the gene names as a simple list.

Important notes: Ensure the column containing gene names is labelled "id" for proper dataset merging. If selected genes aren't present in the other dataset, no highlighting will appear.

??? success  "Adjustable graph parameters"
    - Figure width and height (set independently for the Data1 and Data2 plots)
    - Point size
    - Highlighted points size
    - Highlighted labels size
    - X/Y label font size
    - X/Y title font size
    - Option to switch from white to grey background (defaults to white here, unlike most other modules)
    - "Hide labels" switch (defaults to on)
    - Colour picker for the highlighted dots

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Integrated_two_1_annot_light.mp4" type="video/mp4">
    </video>

---

## <u> **2. Integration Plot** </u>

This feature enables you to merge two datasets for integrated visualisation.

0. (Select the two datasets in the "Side by Side comparison" section.)

1. Select your data source for both X and Y axes, and (optionally) a third variable for the point colour, to generate a scatter plot.
    - Data1 columns are prefixed with "Data1_XXX" and Data2 columns with "Data2_XXX"
    - X-axis typically represents scores from Data1
    - Y-axis typically represents scores from Data2
    - For example, plotting LFC from Data1 on the X-axis against LFC from Data2 on the Y-axis helps assess consistency between datasets

    Two reference lines can be toggled on the plot: "Draw y=x line" and "Draw y=-x line" — useful when visually assessing how consistent (or anti-correlated) the two datasets are.

2. Enter gene names line by line to highlight them in the plot.
    - "Show gene names" toggles whether their labels are drawn on the plot (on by default)
    - "Change colour of the selected genes" lets you pick a custom highlight colour instead of the default red

3. Select a region within the plot using your mouse to label dots with their gene names (IDs)
    - Detailed information about the selected area appears in the "Selected area" table below, which is downloadable via "Download this table" (with a collapsed "List of the genes" box alongside it)

4. Filtering options
    - Set thresholds for X and Y to highlight dots that meet them, using the same five-mode system described in Section 1 above (none / above / below / between / beyond either threshold)
    - Select a gene set to highlight instead, by toggling "Use pathway genes or custom gene sets" — choices are HALLMARK (human), HALLMARK (mouse), Custom (upload your own GMT file), or Custom gene sets (from your registered custom gene sets)
    - "Hide labels" and "Change colour" switches are available for the filtered gene set, separate from the highlighted-gene colour above
    - Genes in the filtered area appear in the "Filtered area" table below (collapsed by default), downloadable via "Download this table" (with its own collapsed "List of the genes" box)

??? success  "Adjustable graph parameters"
    - Figure size (width and height)
    - Font size of x/y axis and title
    - Dot size for all points and highlighted points
    - Label size (font size of the gene ID annotations on the plot)
    - Option to use a white background

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Integrated_two_2_annot_light.mp4" type="video/mp4">
    </video>
