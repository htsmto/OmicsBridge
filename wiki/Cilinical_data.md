<span style="font-family: 'Times', serif">

# <span style="font-family: 'Times', serif; font-size: 36px;">Clinical data</span>

> <span style="font-size: 22px;">
> 
> In this section, users can analyze how their genes of interest impact patient cohorts. Users can:
> 
> 1. Evaluate genes' clinical influence through patient survival analysis
> 2. Examine gene expression variation across patient subtypes
> 3. Identify correlations between genes within the cohort

<span style="font-size: 22px;">

- [ Survival analysis ](#survival-analysis)
- [ Gene correlation ](#gene-correlation)
- [ Gene expression across subtypes ](#gene-expression-across-subtypes)
- [ Cohort Data selection and add an own cohort ](#cohort-data-selection-and-add-an-own-cohort)
    - [ Pre-installed cohort ](#pre-installed-cohort)
    - [ How to upload an own cohort ](#how-to-upload-an-own-cohort)


</span>

## <span style="font-family: 'Times', serif; font-size: 30px;">Survival analysis</span>
> <span style="font-size: 22px;">
> 
> Users can analyze how genes influence patient survival by performing survival analysis on their genes of interest. Enter any number of genes in the "Enter genes" box. For each gene, patients are split into high- and low-expression groups based on their gene expression levels. By default, the split uses the median expression value, but users can also compare the top 25% highest expressing patients with the bottom 25% lowest expressing patients.
> 
> After clicking "Start the survival analysis," a table appears showing p-values and hazard ratios for each gene, sorted by hazard ratio. The hazard ratios are calculated using the Cox proportional hazard regression model, while p-values are determined using the log-rank test. Clicking any row displays a Kaplan-Meier curve on the right.
> 
> <u>Adjustable plot parameters</u>:
> 
> - the size (width and height) of the figure.
> - the size of the X and Y axis/label font size.
> - the size of the graph title.
> - the colour for the high- and low-expression group.

## <span style="font-family: 'Times', serif; font-size: 30px;">Gene correlation</span>
> <span style="font-size: 22px;">
> 
> Users can identify genes that positively or negatively correlate with their one gene of interest. Enter ONE gene in the "Enter ONE gene" box. Choose either Pearson or Spearman correlation method, depending on your gene expression data normalization.
> 
> After clicking "Calculate the correlation," the tool compares the input gene’s expression against all genes in the expression table (usually ~20,000) and generates a table of correlation scores and p-values, sorted by p-value. The input gene should appear at the top of the table. This calculation typically takes 2-4 minutes to complete. Clicking any row displays a scatter plot on the right, where each dot represents a patient. The X-axis shows the expression of your input gene, while the Y-axis shows the expression of the selected gene.
> 
> <u>Adjustable plot parameters</u>:
> 
> - the size (width and height) of the figure.
> - the size of the X and Y axis/label font size.
> - the size of the graph title.
> - the colour for the high- and low-expression group.

## <span style="font-family: 'Times', serif; font-size: 30px;">Gene expression across subtypes</span>
> <span style="font-size: 22px;">
> 
> When metadata for the cohort is provided and patients can be divided into subtypes, users can compare gene expression across these groups.
> 
> Enter your genes of interest and select a category for subtyping from the "Group by" menu. Click "Start comparing" to analyse gene expression across subtypes using statistical tests. For two subtypes, the tool uses the Wilcox test; for three or more subtypes, it uses the Kruskal-Wallis test. The results table shows statistical scores (W values for two subtypes, H values for three or more) and p-values, sorted by p-value. Therefore, genes at the top of the table show the largest expression differences between subtypes. Click any row to display a visualization on the right. You can choose between Box plot, Violin plot, Swarm plot, or Violin + Swarm plot formats.
> 
> <u>Adjustable plot parameters</u>
> 
> - the size (width and height) of the figure.
> - the size of the X and Y axis/label font size.
> - the size of the graph title.
> - the colour for the high- and low-expression group.

## <span style="font-family: 'Times', serif; font-size: 30px;">Cohort Data selection and add an own cohort</span>

> <span style="font-size: 22px;">
> 
> Select a cohort dataset to view its details on the right. Three tables will be displayed in the "View the data" section: Gene expression, Patient survival information, and Metadata. You can also upload your own cohort from the "upload own cohort" sub-section.
> 
> ### <span style="font-family: 'Times', serif; font-size: 28px;"><u>Pre-installed cohort</u></span>
>
>> <span style="font-size: 22px;">
>> 
>> [TCGA](https://www.nature.com/articles/ng.2764) (34 cancer types, see the table below) and [METABRIC](https://www.nature.com/articles/nature10983) (breast cancer) are available as pre-installed cohorts.<br>
>> The TCGA data includes mRNA sequencing results and clinical information downloaded from [UCSC Xena](https://xenabrowser.net/datapages/?hub=https://tcga.xenahubs.net:443), with gene expression values transformed as log2(RSEM normalized count+1). <br>
>> The METABRIC data comes from [cBioPortal](https://www.cbioportal.org/study/summary?id=brca_metabric).
>>
>> <details>
>>
>> <summary><span style="font-size: 18px;"> The list of the cancer types included the downloaded TCGA data　</span></summary>
>> <span style="font-size: 18px;">
>>
>> | Abbreviation | Cancer type |
>> | --- | --- |
>> | TCGA_ACC | Adrenocortical carcinoma |
>> | TCGA_BLCA | Bladder Urothelial Carcinoma |
>> | TCGA_BRCA | Breast invasive carcinoma |
>> | TCGA_CESC | Cervical squamous cell carcinoma and endocervical adenocarcinoma |
>> | TCGA_CHOL | Cholangiocarcinoma |
>> | TCGA_COAD | Colon adenocarcinoma |
>> | TCGA_DLBC | Lymphoid Neoplasm Diffuse Large B-cell Lymphoma |
>> | TCGA_ESCA | Esophageal carcinoma |
>> | TCGA_GBM | Glioblastoma multiforme |
>> | TCGA_HNSC | Head and Neck squamous cell carcinoma |
>> | TCGA_KICH | Kidney Chromophobe |
>> | TCGA_KIRC | Kidney renal clear cell carcinoma |
>> | TCGA_KIRP | Kidney renal papillary cell carcinoma |
>> | TCGA_LAML | Acute Myeloid Leukemia |
>> | TCGA_LGG | Brain Lower Grade Glioma |
>> | TCGA_LIHC | Liver hepatocellular carcinoma |
>> | TCGA_LUAD | Lung adenocarcinoma |
>> | TCGA_LUSC | Lung squamous cell carcinoma |
>> | TCGA_MESO | Mesothelioma |
>> | TCGA_PAAD | Pancreatic adenocarcinoma |
>> | TCGA_PCPG | Pheochromocytoma and Paraganglioma |
>> | TCGA_PRAD | Prostate adenocarcinoma |
>> | TCGA_READ | Rectum adenocarcinoma |
>> | TCGA_SARC | Sarcoma |
>> | TCGA_SKCM | Skin Cutaneous Melanoma |
>> | TCGA_TGCT | Testicular Germ Cell Tumors |
>> | TCGA_THCA | Thyroid carcinoma |
>> | TCGA_THYM | Thymoma |
>> | TCGA_UCEC | Uterine Corpus Endometrial Carcinoma |
>> | TCGA_UCS | Uterine Carcinosarcoma |
>> | TCGA_UVM | Uveal Melanoma |
>> | TCGA_COADREAD | Colon and Rectal Cancer |
>> | TCGA_GBMLGG | lower grade glioma and glioblastoma |
>> | TCGA_LUNG | Lung Cancer |    
>> 
>> </details>
>
> ### <span style="font-family: 'Times', serif; font-size: 28px;"><u>How to upload an own cohort</u></span>
>
>> <span style="font-size: 22px;">
>> 
>> You need to upload three types of data::
>>
>> 1. Gene expression
>> - A table of genes × samples/patients from bulk RNAseq (or microarray). Data must be normalized before uploading.
>> - Note: Analysis may be slow for large datasets (>200MB).
>> 2. Patient survival information
>> - Column headers must be set according to the table below
>>        
>>> | The column containing | the header has to be set to |
>>> | --- | --- |
>>> | Patient IDs | samples |
>>> | Event for Overall Survival (censor status. either 0 or 1. 0: living, 1: deceased) | OS |
>>> | Observed time (month) for  Overall Survival  | OS.time |
>>> | Event for Progression Free Survival (censor status. either 0 or 1.) | PFS |
>>> | Observed time (month) for  Progression Free Survival | PFS.time |
>>> | Event for Relapse-Free Survival (censor status. either 0 or 1.) | RFS |
>>> | Observed time (month) for Relapse-Free Survival  | RFS.time |
>>
>> 3. Metadata
>> - The Metadata contains additional patient information such as cancer subtypes, treatment responses, and age.
>> - The column header for patient IDs must be set as "sample".
>>
>> **Please ensure that patient IDs match exactly across all samples.**


</font>