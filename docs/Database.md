
# **Database and Data Upload** 

This section allows users to browse all datasets registered within the interface (i.e., custom database). Additionally, users can upload new datasets and modify information regarding existing datasets.


## <u> **1. Available data types** </u>

The interface accommodates four distinct types of data and specifies the required formatting for each.

### **A. Count Data / Expression Matrix Data**: 
The read count tables derived from RNA sequencing, proteomics, and various other sources, whether normalised or non-normalised, are considered. It is essential to note that while non-normalised data is permissible, the interface does not offer functionality for data normalisation. Ensure that the data adheres to the following criteria:

- The table must be in <span style="color: red;"> tab-delimited </span> format (either tsv or .txt file), featuring gene names in the index and sample names in the columns.
- The header name (column name) containing gene names <span style="color: red;">should be designated as "id" </span>.
- The samples must be named using the format <span style="color: red;">$(Group.Name)_RepX</span> or <span style="color: red;">${Group.Name}_repX</span>, such as THP1_STK11KO_Rep1, THP1_STK11KO_Rep2, THP1_WT_Rep1, etc.

??? tip "Example"
    ![Example](img/1_expression_table.png)

### **B. Comparison Data**: 
Any dataset containing log fold changes and statistical scores, including differentially expressed gene results from RNA sequencing and outcomes of CRISPR screening, among others, suitable for generating a volcano plot, may be input into OmicsBridge. It is imperative that the data complies with the following criteria:

- The table must be formatted as <span style="color: red;">tab-delimited</span> (either tsv or .txt file) and must include headers, featuring gene names in the index.
- The header name (column name) that encompasses gene names <span style="color: red;">should be designated as "id"</span>.

??? tip "Example"
    ![Example](img/1_log_table.png)

### **C. scRNAseq data**: 
scRNA data properly processed by Seurat and saved as an RDS file can be input to the interface. The scRNA data must be processed using Seurat and ready for UMAP plotting (not tSNE). Before uploading to the interface, it is highly recommended to annotate each cluster with its corresponding cell type.

??? note "Seurat object preprocess"
    The Seurat object must be loaded from an RDS file. Ensure that `Reductions(Seurat_object)` returns "umap". While the metadata (Seurat_object@meta.data) is flexible, your data should ideally include "seurat_clusters" and "Annotation" fields for optimal functionality.
    ![Example](img/1_Seurat.png)

### **D. Epigenome data (bed, bigwig and bam file)**:
Bed, bigwig and bam files from ATACseq, ChIPseq, and similar analyses can be viewed in the "Epigenome Visualisation" section. <br>

- Bed files must not contain headers and must be tab-delimited. They should include at least five columns: chromosome name, start and end positions, feature name/identifier, and score (ranging from 0 to 1000). Any columns beyond the sixth will be ignored. Please refer to the example bed file below.
- For bam files, you must also provide the corresponding index file (bai file). When you select bam as a Data Class, an upload option will appear. If the bai file doesn't match the bam file, you'll receive an error message.<br>

??? tip "Example(bed file)"
    ![Example](img/1_bed.png)

## <u> **2. How to upload a new dataset** </u>

Users can upload new datasets in the 'Data upload' section by following these steps.

### **2.1. Upload a file**. 
A file can be selected or dragged and dropped into the file upload section. Make sure the file format and data format meet the requirements described above. The maximum data size to upload is 1 GB.

### **2.2. Complete the dataset information**.
<span style="color: red;">Do not use line breaks</span> in any text boxes, as the database will only keep the first line. Fields marked with an asterisk (*) are required. Also, avoid using special characters (such as /,!,?, etc.).

| **Field**  | **Description**|
|-----|-----|
| **Dataset Name***      | Denotes the name assigned to the dataset to be uploaded. Duplicate dataset names are prohibited.  |
| **Experiment Name***   | Refers to the name of the experiment to which the dataset is associated. This information aids in filtering the dataset for selection in the Database or Data Overview section. |
| **Data Source***       | Indicates the origin or creator of the dataset.  |
| **Data Type***         | Represents the category of data, such as “DEG from RNAseq” or “CRISPR screening.” All datasets under the same Data Type must have identical data structures (same header/column names) for comparison. |
| **Data Class***        | Select the appropriate classification for the dataset.|
| **Cell Line** (Optional)     | Specifies the cell line utilised in the experiment (e.g., MCF7, THP1, Mouse Monocyte Derived Macrophages, etc.).|
| **Collection Date** (Optional) | Denotes the time period during which the dataset was collected.|
| **Description** (Optional)    | Provides additional details regarding the dataset.|


### **2.3. Click on ‘Add to the dataset’**.
If the upload is successful, a message stating “Uploaded!” will appear adjacent to the upload button. Additionally, the newly added dataset will be displayed as the first entry in the table.


## <u> **3. How to edit the database** </u>

### **3.1 Editing the database**
Each cell can be edited by double-clicking. Upon the user making an edit, the change will be manifested below the table. The editing process is deemed successful once the user clicks “Save changes” and subsequently confirms the message “saved!”. 

### **3.2 Deleting some data**
Each row of the database can be selected by simply clicking on it. It is possible to make multiple selections, and the number of selected rows is displayed at the bottom of the table. By clicking “Delete selected data”, all selected rows will be removed from the database.

