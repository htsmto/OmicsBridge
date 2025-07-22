# **Clinical data**

## <u>**1. Cohort selection and view the data**</u>

A cohort can be selected in the top. Once selected, its details will be shown on the right. The data can be viewed as an excel format in the “View the data” section. For a gene expression, since this table is usually a large data, by default it shows the first 1000 lines to avoid over memory usega. The uses can choose to show all the data if they want.

## <u>**2. Survival analysis**</u>

This section examines the association between gene expression and survival outcomes within a selected patient cohort.

1. Enter individual gene names line by line or select a custom gene set.
2. Choose how to divide patients into high- and low-expression groups:
    - Using the median (default)
    - Using top 25% vs. bottom 25%
    - Using custom-defined thresholds (e.g., top X% vs. bottom Y%)
    - Manually specifying the two groups by entering sample names directly
3. Select the event type
4. Click the start button.
    - It generates a results table showing p-values and hazard ratios for each gene, sorted by the hazard ratio.
5. Click on any row in the results table to display the corresponding Kaplan–Meier curve.
6. Use the histogram feature to visualise gene expression distributions, which can help determine appropriate sample splitting criteria.

The survival events available for analysis (such as overall survival or progression-free survival) depend on the metadata included in your cohort dataset. For more details, please refer to **10-2. How to upload your own cohort** section.


??? success  "Adjustable graph parameters"

    - The size (width and height) of the figure.
    - The size of the X and Y axis/label font size.
    - The size of the legend title
    - The colour for the high- and low-expression group.
  
??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Clinical_1_720.mp4" type="video/mp4"> 
    </video>

## <u>**3. Gene correlation**</u>

This section allows you to analyse gene expression correlations within a selected cohort. Users can investigate how the expression level of a specific gene correlates with the expression levels of other genes.

1. Enter one name of the target gene (will be shown on the Y-axis of scatter plots).
2. Select an analysis mode under Explore type:
    - **Explore one gene's correlation with specific genes** (default):
        - In this case, enter the gene names or select a geneset from a Custom Geneset to investigate the correlation (will be shown on the X-axis)
    - **Explore one gene's correlation with all the genes**:
        - It calculates correlations with all genes in the cohort. This takes several minutes.
3. Choose correlation method: Pearson (linear relationships) or Spearman (rank-based).
4. Click Start to run analysis. It returns a table showing correlation coefficient and p-value for each gene.
5. Clicking any gene in the table displays its scatter plot showing correlation with the target gene.

??? success  "Adjustable graph parameters"

    - The size (width and height) of the figure.
    - The size of the X and Y axis/label font size.
    - Change the background from gray to white
    - The colour of the dot
    - Show the correlation line

??? example  "Example Usage video"
    <video width="1000" controls>
    <source src="../videos/Clinical_2_720.mp4" type="video/mp4"> 
    </video>

## <u>**4. Mutation analysis**</u>

This section helps you analyse gene mutations in the selected cohort.

1. Input the genes to investigate by:
    - Entering gene names one per line in the text box ('Text input')
    - Choosing to analyse all genes in the dataset ('Use all genes')
    - Selecting a geneset from the Custom Geneset ('Select from custom genesets')
2. Filter the samples if necessary
    - By default, all cohort samples are included ('Use all samples')
    - When choosing 'Use the selected samples by a specific category', you can filter samples using metadata (treatment group, cancer subtype, demographics) for targeted analysis
3. Click the start button. A Results table will appear in the bottom left section. The following plots will be generated in the tabs:
    - **Frequency Plot** tab: 
    A bar plot showing the frequency or the counts of mutated genes. The Y-axis displays either mutation count or frequency (%). You can adjust the number of genes to display.
    - **Survival analysis** tab: 
    Select an event for survival analysis. Clicking a gene name displays a Kaplan-Meier curve comparing the wild-type patients and the mutant patients.
    - **Gene expression plot** tab: 
    This comparison examines the expression levels between the wild-type and mutant groups.
        1. Click a gene in the mutation analysis results table
        2. Enter genes in the input field to generate a table listing these genes
        3. Click a gene from the Input genes table to generate a plot comparing its expression between the wild-type and mutant patients

??? success  "Adjustable graph parameters"
    1. Frequency Plot
        - Plot size (width and height)
        - X and Y label size
        - Legend size
        - Colours for highest and lowest mutant count/frequency
        - Number of genes to display
        - White background option
        - Option to hide scores on each bar
    2. Survival analysis
        - Figure size (width and height)
        - X and Y axis/label font size
        - Legend title size
        - Colours for high and low expression groups
    3. Gene expression plot
        - Plot size (width and height)
        - X and Y label size
        - Graph title and legend font size
        - Colours for wild-type and mutant groups


## <u>**5. Gene expression across subtypes**</u>

When metadata for the cohort is provided and patients can be divided into subtypes, users can compare gene expression across patient subgroups.

1. Enter the genes or select a custom geneset
2. Select a category for subtype from the "Group by" drop-down menu
3. Click "Start comparing" to compare gene expression across subtypes. Note that visualisation may be slow and cluttered when there are many subtypes in the selected group.
4. A result table with statistical scores and p-values will be generated. Statistical scores include W values for two subtypes and H values for three or more subtypes.
5. Clicking any row in the table displays a visualisation on the right. Available plot types include Box plot, Violin plot, Swarm plot, or Violin + Swarm plot
   

??? success  "Adjustable graph parameters"
    - Figure size (width and height)
    - X and Y axis/label font size
    - Graph title size
    - Colour palette for each subtype

## <u>**6. Signature analysis**</u>

This section performs signature analysis on gene expression data from the selected cohort to evaluate the activity or presence of specific biological processes.

1. Choose the input type by either:
    - Selecting from custom gene sets
    - Entering gene names line by line
2. Select the calculation method:
    - GSVA (Gene Set Variation Analysis) or ssGSEA (single-sample Gene Set Enrichment Analysis) is available.
    - What is GSVA and ssGSEA?
        
        
        GSVA (Gene Set Variation Analysis) calculates an enrichment score for each gene set by transforming gene expression data into a pathway activity score across samples. It uses kernel-based density estimation to assess the relative enrichment of a gene set, comparing it to the overall expression distribution in the dataset.
        
        ssGSEA (single-sample Gene Set Enrichment Analysis), on the other hand, ranks genes within each sample and calculates an enrichment score based on the ranked positions of genes in a gene set. It evaluates how consistently genes of a set are positioned at the top or bottom of the ranked gene list for each individual sample.
        
        In summary, GSVA works across samples to estimate pathway activity, while ssGSEA focuses on ranking genes within each sample to calculate enrichment scores.
        
3. Click the start button. This generates a result table with scores for each sample.
4. Three plots are generated:
    - **Survival analysis plot** tab:
        - Generates a Kaplan-Meier plot.
        - Allows selection of methods to split samples into high and low-score patients: either by median or comparing Top 25% vs Bottom 25%.
    - **Score comparison** tab:
        - Select the group to compare signature scores and click the start button.
        - Four plot types are available (Box plot, Violin plot, Swarm plot, and Violin + Swarm plot).
    - **Distribution** tab:
        - Generates a histogram of signature scores to help determine appropriate sample splitting criteria.
  
??? success  "Adjustable graph parameters"
    - **Survival analysis plot**
        - Figure size (width and height)
        - X and Y axis/label font size
        - Legend title size
        - Colors for high and low expression groups
    - **Score comparison plot**
        - Figure size (width and height)
        - X and Y axis/label font size
        - Legend title size
        - Color palette
    - **Histogram**
        - Figure size (width and height)
        - X and Y axis/label font size
        - Legend title size
        - Histogram bin color
        - Number of histogram bins

## <u>**7. Deconvolution analysis**</u>

## <u>**8. Compare cohorts**</u>

## <u>**9. Cancer Gene Census (COSMOS)**</u>


## <u>**10. Manage the cohort database**</u>
Select a cohort dataset to view its details on the right. Three tables will be displayed in the "View the data" section: Gene expression, Patient survival information, and Metadata. You can also upload your own cohort from the "upload own cohort" sub-section.
 
### <u>**10-1. Pre-installed cohort**</u>
[TCGA](https://www.nature.com/articles/ng.2764) data (34 cancer types, see the table below) is available as pre-installed cohorts. This includes mRNA sequencing results, clinical information, metadata and mutation data downloaded from [UCSC](https://xenabrowser.net/datapages/?hub=https://tcga.xenahubs.net:443) Xena, with gene expression values transformed as log2(RSEM normalised count+1).

??? info  "TCGA abbreviation"
    | Abbreviation | Cancer type |
    | --- | --- |
    | TCGA_ACC | Adrenocortical carcinoma |
    | TCGA_BLCA | Bladder Urothelial Carcinoma |
    | TCGA_BRCA | Breast invasive carcinoma |
    | TCGA_CESC | Cervical squamous cell carcinoma and endocervical adenocarcinoma |
    | TCGA_CHOL | Cholangiocarcinoma |
    | TCGA_COAD | Colon adenocarcinoma |
    | TCGA_DLBC | Lymphoid Neoplasm Diffuse Large B-cell Lymphoma |
    | TCGA_ESCA | Esophageal carcinoma |
    | TCGA_GBM | Glioblastoma multiforme |
    | TCGA_HNSC | Head and Neck squamous cell carcinoma |
    | TCGA_KICH | Kidney Chromophobe |
    | TCGA_KIRC | Kidney renal clear cell carcinoma |
    | TCGA_KIRP | Kidney renal papillary cell carcinoma |
    | TCGA_LAML | Acute Myeloid Leukemia |
    | TCGA_LGG | Brain Lower Grade Glioma |
    | TCGA_LIHC | Liver hepatocellular carcinoma |
    | TCGA_LUAD | Lung adenocarcinoma |
    | TCGA_LUSC | Lung squamous cell carcinoma |
    | TCGA_MESO | Mesothelioma |
    | TCGA_PAAD | Pancreatic adenocarcinoma |
    | TCGA_PCPG | Pheochromocytoma and Paraganglioma |
    | TCGA_PRAD | Prostate adenocarcinoma |
    | TCGA_READ | Rectum adenocarcinoma |
    | TCGA_SARC | Sarcoma |
    | TCGA_SKCM | Skin Cutaneous Melanoma |
    | TCGA_TGCT | Testicular Germ Cell Tumors |
    | TCGA_THCA | Thyroid carcinoma |
    | TCGA_THYM | Thymoma |
    | TCGA_UCEC | Uterine Corpus Endometrial Carcinoma |
    | TCGA_UCS | Uterine Carcinosarcoma |
    | TCGA_UVM | Uveal Melanoma |
    | TCGA_COADREAD | Colon and Rectal Cancer |
    | TCGA_GBMLGG | lower grade glioma and glioblastoma |
    | TCGA_LUNG | Lung Cancer |   


### <u>**10-2.How to upload an own cohort**</u>

The users can upload their own cohort and analyse it here. Three files (Gene expression, Clinical data a d Metadata) should be uploaded. Optionally, mutation data can be added. Each data has to follow the following data format.

#### 1. **Gene expression**

A tab-delimited table of the gene expression of each sample (genes × samples(patients)) from bulk RNAseq (or microarray). 

- Ensure the data is already normalised before uploading, as the interface does not perform normalisation automatically.
- Rows (index): gene names.
- Columns (headers): sample names that match those used in your clinical data.

??? tip "Example"
    ![Example](img/3_ex_example.png)

#### 2. **Patient survival information**

A tab-delimited table containing the information of overall survival, progression-free survival, etc (those needed for generating a Kaplan-Meier curve or survival analysis). Please follow these rules.

- The first column must contain sample IDs and should have the header named `sample` (in all lowercase). All sample IDs should exactly match those used in your gene expression and clinical data.
- All other columns must represent pairs of event data:
   One column for the event status (censoring), with binary values: 1 (event occurred) or 0 (censored).
   One corresponding column for the event time (in days), labelled with the same event name followed by .time.
- For example: For Overall Survival (OS), use one column named OS for event status and use another column named OS.time for the number of days until the event or censoring. Similary, for other types of events (e.g., DSS, DFI, PFI), follow the same format. DSS and DSS.time, DFI and DFI.time, PFI and PFI.time, etc.
- You may include other columns in the dataset that do not follow the event/time pair format. These columns will be safely ignored and will not affect the analysis.

??? tip "Example"
    ![Example](img/3_clinical_example.png)

#### 3. **Metadata**

Please upload a tab-delimited (.tsv) table containing metadata for the samples (patients) in your cohort. This may include information such as treatment condition, gender, grade, or cancer subtype.

- The first column must contain the sample IDs, and the header for this column must be `sample` (all lowercase). All sample IDs should exactly match those used in your gene expression and clinical data.

If you do not have any metadata to include, please upload a .tsv file that contains only the sample IDs in the first column with the header `sample`. This ensures consistency and allows the interface to process the data correctly.

??? tip "Example"
    ![Example](img/3_meta_example.png)

#### 4. Mutation data

### <u>**10-3. Edit or delete the cohort**</u>
