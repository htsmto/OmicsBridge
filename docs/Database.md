
# **Database and Data Upload** 

This section allows users to browse all datasets registered within the interface (i.e., custom database). Additionally, users can upload new datasets and modify information regarding existing datasets.


## <u> **1. Available data types** </u>

The interface accommodates four distinct types of data and specifies the required formatting for each.

### **A. Count Data / Expression Matrix Data**: 
The read count tables derived from RNA sequencing, proteomics, and various other sources, whether normalised or non-normalised, are considered. It is essential to note that while non-normalised data is permissible, the interface does not offer functionality for data normalisation. Ensure that the data adheres to the following criteria:

- The table must be in <span style="color: red;"> tab-delimited </span> format (either tsv or .txt file), featuring gene names in the index and sample names in the columns.
- The header name (column name) containing gene names <span style="color: red;">should be designated as "id" </span>.
- The sample names must conclude with <span style="color: red;">*_Rep# or *_rep#</span>.

??? tip "Example"
    ![Example](img/1_expression_table.png)

### **B. Comparison Data**: 
Any dataset containing log fold changes and statistical scores, including differentially expressed gene results from RNA sequencing and outcomes of CRISPR screening, among others, suitable for generating a volcano plot, may be input into OmicsBridge. It is imperative that the data complies with the following criteria:

- The table must be formatted as <span style="color: red;">tab-delimited</span> (either tsv or .txt file) and must include headers, featuring gene names in the index.
- The header name (column name) that encompasses gene names <span style="color: red;">should be designated as "id"</span>.

??? tip "Example"
    ![Example](img/1_log_table.png)

### **C. scRNAseq data**: 
Users can browse their single-cell RNAseq data, but it must be properly processed and saved as an RDS file. See the "scRNA" section for more details. 

### **D. Epigenetic data (bam, bed, bigwig file, etc)**:
Bam, bed, and bigwig files generated from ATACseq, ChIPseq, etc. can be browsed in the "Genome browser" section. 


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

