
<span style="font-family: Helvetica, Arial, serif">


# <span style="font-family: Helvetica, Arial, serif; font-size: 36px;"> Database </span>

> <span style="font-size: 22px;"> This section allows users to browse all datasets registered in the interface. Here, users can also upload new datasets and edit information for existing ones. </span>

<span style="font-size: 22px;">

- [Available data type](#available-data-types)
- [How to upload a new dataset](#how-to-upload-a-new-dataset)
- [How to edit the database](#how-to-edit-the-database)

</span>

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"><u> Available data types </u></span>

> <span style="font-size: 22px;"> 
> 
> The interface supports four types of data:
>  
> 1. **Count data / Expression Matrix data**: 
> 
>    Normalized (or non-normalized) read count tables from RNAseq, proteomics, etc. While non-normalized data is accepted, please note that the interface does not include data normalization functionality.
> 
> 2. **Comparison data**: 
> 
>     Any data containing (log) fold changes, including differentially expressed gene results from RNAseq, CRISPR screening, ChIPseq, proteomics, etc.
> 
> 3. **scRNAseq data**: 
>
>     Users can browse their single-cell RNAseq data, but it must be properly processed and saved as an RDS file. See the "scRNA" section for more details. 
>
> 4. **Epigenetic data (bam, bed, bigwig file, etc)**: 
>
>     Bam, bed, and bigwig files generated from ATACseq, ChIPseq, etc. can be browsed in the "Genome browser" section. 


## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"><u> How to upload a new dataset </u></span>

> <span style="font-size: 22px;">
> 
> A new dataset can be uploaded in the ‘Data upload’ section. Please follow the guide below:
> 
>> <span style="font-size: 22px;">
>>
>> 1. Upload the file. 
>>
>>       The file has to be **tab-delimited** **text** (tsv, txt) or **rds file** (for single cell RNAseq data, see the “scRNA” section) or **bam/bed/bigwig files** (for epigenetic data like ATACseq, ChIPseq. <br>See the “Genome browser” section), and the file size has to be less than 300MB. 
>> 
>>    - Please make sure that <span style="color: red;"> the header name (column name) containing gene/protein/transcription names is set to “id”. </span>
>>    - When uploading a count table, use sample names as column headers (along with 'id'), with gene names as row indexes. <br>For replicated samples, we recommend <span style="color: red;">adding "_Rep#" to the end of each sample name </span>(e.g., "Sample_Rep1", "Sample_Rep2"). <br>This naming convention allows you to integrate replicates when viewing swarm plots later. Please see the example below:
>>
> 
>> <span style="font-size: 22px;">
>> 
>> 2. Fill in the dataset information. 
>> 
>>      **Do not use line breaks in any text boxes,** as only the first line will be saved to the database.
>>
>>    - Dataset name: A unique identifier for your dataset. Ensure no other datasets share this name.
>>    - Experiment name: The name of the experiment this dataset belongs to. Avoid using special symbols ( / ! ? etc).
>>    - Data from: The source or creator of the dataset.
>>    - Data type: The category of data, such as DEG from RNAseq or CRISPR screening. <span style="color: red;">All datasets of the same Data type must share an identical data structure (same header/column names)</span>. This enables comparison across datasets (see "Compare across datasets" section).
>>    - Data Class: Select the appropriate classification for your dataset.
>>    - Cell line: (optional) The cell line used in the experiment.
>>    - When: (optional) The date the data was collected.
>>    - Description: (optional) Additional details about the dataset.
>
>> <span style="font-size: 22px;">
>> 
>> 3. Click ‘Add to the dataset’, and the user can see the newly added dataset at the top of the table.

## <span style="font-family: Helvetica, Arial, serif; font-size: 30px;"><u> How to edit the database </u></span>

> <span style="font-size: 22px;">
>
> Each cell is editable by double-clicking. When the user makes an edit, the change will be displayed below the table. <br>The editing is successful once the user clicks “Save changes” and confirms the message “saved!”. <br>The user can select each row by just clicking them. They see how many rows are selected at the bottom of the table (multiple selections possible). <br>By clicking “Delete selected data”, all the selected rows will be removed from the database.

</span>