# **Case Study Report**

This section demonstrates the use of OmicsBridge with multiple omics datasets.

## <u>**Case Study 1**</u>: <br>Exploring Screening Data and Narrowing Down Candidate Genes from a Clinical Perspective

CXCL10 is a chemokine that facilitates T-cell migration to the tumour microenvironment. We conducted a FACS-assisted loss-of-function CRISPR screening to identify CXCL10 regulators in a myeloid cell line, U937. We introduced a CRISPR gRNA library (Brunello library, Addgene) into cells via lentiviral transduction and cultured them with IFNγ and TNFα to induce CXCL10 expression. After trapping the chemokine within cells using brefeldin A treatment, we measured CXCL10 production levels using flow cytometry. We then sorted CXCL10-high and -low cell populations using FACS and analysed the enriched barcoded gRNAs in each population.

The screening data were analysed using MaGeCK, and results were uploaded to OmicsBridge to identify potential CXCL10 regulators.

### <u>1.1. Analysis of CRISPR Screening Data</u>

OmicsBridge can facilitate visualisation of the screening results through volcano plots with customisable x/y axes. Validation of screening quality was confirmed by observing reduced read counts of CXCL10 and cytokine receptor genes, such as IFNGR1 and STAT1, in the CXCL10-low population, as anticipated. Conversely, genes such as TADA1 and EP300 appeared on the right side of the plot (easily confirmed by mouse selection), indicating that their knockout enhanced CXCL10 production in stimulated cells.

Using OmicsBridge's threshold-based filtering functionality, we identified potential positive regulators of CXCL10 by applying stringent criteria (LFC < -2 and p-value < 0.01). This analysis yielded 429 candidate genes whose knockout significantly attenuated cytokine-induced CXCL10 expression.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_1a.mp4" type="video/mp4"> 
    </video>

### <u>1.2. Integration of Clinical Datasets</u>

To refine our list of 429 potential CXCL10 positive regulators, we leveraged clinical datasets integrated within OmicsBridge to assess their pathophysiological relevance.

Initially, we examined whether any candidate genes were annotated as cancer predisposition genes. Given that our screening utilised U937, a myeloid leukaemia cell line, we specifically focused on germline mutations. Through OmicsBridge's integration with the Cancer Gene Census database from COSMIC, we identified five CPGs among our candidates: ERCC2, ERCC3, SBDS, SMARCB1, and STK11. Among them, STK11 is a tumour suppressor gene frequently mutated in various types of cancer, and its alteration has been shown to influence the response to immune checkpoint inhibitors. Given its significant role in prognostic prediction and therapeutic decision-making, we focused on STK11 in this study.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_1b.mp4" type="video/mp4"> 
    </video>


### <u>1.3. Clinical Characteristics of STK11</u>

OmicsBridge is configured with TCGA data as a preset clinical dataset. To elucidate STK11's impact on the tumour microenvironment, we examined its influence on patient outcomes using OmicsBridge. Consistent with previous reports, cross-cancer analysis revealed that STK11 mutations occurred most frequently in lung adenocarcinoma (LUAD). Analysis of the TCGA LUAD cohort demonstrated that STK11 mutations did not significantly affect overall patient survival or show a strong correlation with CXCL10 expression. However, we observed elevated CXCL10 levels in STK11 wild-type patients compared to those with STK11 mutations. Additionally, STK11 expression positively correlated with T cell abundance as determined by deconvolution analysis.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_1c.mp4" type="video/mp4"> 
    </video>


### <u>1.4. Visualising STK11 Expression in scRNA data</u>

We further investigated STK11 expression patterns at single-cell resolution using OmicsBridge. Two distinct scRNA-seq datasets were analysed: Non-Small Cell Lung Cancer (NSCLC) patient samples (GSE148071) and Acute Myeloid Leukaemia (AML) patient samples (GSE116256). Using OmicsBridge's interactive feature plotting functionality, we observed that STK11 exhibited ubiquitous expression across diverse cell populations. This expression pattern contrasted markedly with CXCL10, which demonstrated cell type-specific expression predominantly restricted to myeloid cell populations.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_1d.mp4" type="video/mp4"> 
    </video>

## <u>**Case Study 2**</u>: <br>Transcriptomic Analysis of STK11 Knockout in Myeloid Cell Lines

To elucidate the molecular mechanism underlying STK11-mediated regulation of CXCL10 expression, we performed RNA-seq analysis on U937 and THP1 myeloid cell lines with CRISPR/Cas9-mediated STK11 knockout, both in the presence and absence of cytokine stimulation. OmicsBridge facilitates comprehensive visualisation and analysis of the transcriptomic data, enabling intuitive interpretation of complex datasets. The platform's integrated analytical framework allowed for robust differential expression analysis, pathway enrichment, and cross-dataset comparisons. We leveraged these capabilities to systematically examine the transcriptional consequences of STK11 deficiency on cytokine signalling networks across both cellular models.

### <u>2.1. Transcriptome Data Analysis</u>

OmicsBridge facilitates comprehensive visualisation of transcriptomic data through multiple modalities, including PCA plots, swarm plots, and heatmaps. Initial quality control via PCA revealed one replicate (THP1_gNT_UT_Rep3) with significant deviation from the expected distribution pattern, which was excluded from subsequent analyses. Swarm plots confirmed the downregulation of both CXCL10 and STK11 transcripts in the STK11 knockout condition. Hierarchical clustering analysis demonstrated that HALLMARK interferon-gamma response genes exhibited robust upregulation following cytokine treatment. Notably, a distinct gene subset displayed attenuated induction in STK11-deficient cells compared to non-target controls, with this pattern consistently observed across both THP1 and U937 cell lines.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_2a.mp4" type="video/mp4"> 
    </video>


### <u>2.2 Downstream Analysis Reveals Cell-Type Specific Chemokine Regulation</u>

The downstream effects of STK11 knockout were comprehensively analysed using OmicsBridge's integrated analytical suite. KEGG pathway analysis of downregulated genes in STK11-deficient U937 cells under cytokine stimulation revealed coordinated suppression of multiple chemokines beyond CXCL10. In contrast, no significant KEGG pathway enrichment was detected in STK11-knockout THP1 cells, suggesting cell type-specific regulatory mechanisms rather than a universal effect on CXCL10 expression. Comparative analysis utilising OmicsBridge's visualisation tools, including Venn diagram functionality, enabled quantitative assessment of differential gene regulation patterns between the two myeloid cell lines, highlighting the context-dependent nature of STK11-mediated transcriptional control.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_2b.mp4" type="video/mp4"> 
    </video>


### <u>2.3. Integrative Multi-Dataset Analysis</u>

OmicsBridge can perform comparative analysis between datasets through both side-by-side visualisation and integrated plotting functionality. This enables researchers to examine how genes affected in one experimental condition correspond to their expression patterns in another condition. We investigated the differential effects of STK11 knockout on cytokine-regulated gene expression in both cell lines. In U937 cells, cytokine-induced upregulation of numerous genes, particularly chemokines, was significantly attenuated following STK11 knockout. Conversely, THP1 cells exhibited a distinctly different response pattern, wherein cytokine-induced gene expression was largely maintained or even enhanced following STK11 deletion, demonstrating a cell line-specific regulatory mechanism.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_2c.mp4" type="video/mp4"> 
    </video>


### <u>2.4. Cross-Dataset Comparative Analysis</u>

To systematically evaluate the transcriptional impact of STK11 deletion, we performed a comparative analysis of log fold changes across both cell lines following cytokine stimulation. This analysis identified 24 genes showing significant downregulation (ranked within the 5%) in STK11-knockout conditions across both U937 and THP1 cell lines. Further examination of chemokine expression patterns revealed concordant downregulation of several interferon-inducible chemokines, including CXCL9, CXCL10, and CXCL11, in both cellular models. In contrast, other interferon-γ-responsive genes, notably CCL7 and CCL8, demonstrated divergent regulation patterns between the two cell lines, suggesting context-dependent regulatory mechanisms.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_2d.mp4" type="video/mp4"> 
    </video>


## <u>**Case Study 3**</u>: <br>Epigenomic Analysis of Chromatin Accessibility Dynamics in Response to Cytokine Stimulation

To elucidate the underlying molecular mechanisms, we analysed publicly available epigenomic data (ATAC-seq) from THP1 cells treated with IFN-γ at various time points. This approach enabled us to investigate differential chromatin accessibility patterns across genes differentially regulated by STK11 under cytokine stimulation conditions.

### <u>3.1. Correlation Analysis Between Chromatin Accessibility and Cytokine-Induced Gene Expression</u>

We analysed the relationship between chromatin accessibility dynamics and gene expression using matched RNA-seq and ATAC-seq datasets from THP1 cells stimulated with IFN-γ (and LPS) across multiple time points (GSE201376). To identify putative cis-regulatory elements associated with cytokine-responsive genes, we performed correlation analysis between gene expression profiles and accessibility of chromatin regions within proximity to the corresponding gene loci.  The analysis identified 239 accessibility peaks significantly correlated with 68 cytokine-induced genes that were suppressed in STK11 knockout cells (including CXCL10). We also found 1080 accessibility peaks associated with 231 cytokine-induced genes that showed enhanced expression under the same conditions.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_3a.mp4" type="video/mp4"> 
    </video>


### <u>3.2. Visualisation of Chromatin Accessibility Dynamics</u>

Subsequently, we visualised the chromatin accessibility of the identified peaks across multiple time points following IFNγ treatment using OmicsBridge. Profile plot analysis revealed distinct temporal patterns, wherein enhancer regions associated with genes downregulated by STK11KO exhibited significantly more rapid chromatin opening in response to IFNγ stimulation compared to enhancers of genes upregulated in the STK11KO condition.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_3b.mp4" type="video/mp4"> 
    </video>


### <u>3.3. Transcription Factor Binding Motif Analysis</u>

To identify potential transcriptional regulators, we performed motif enrichment analysis on the enhancer regions associated with differentially regulated genes using OmicsBridge. Comparative analysis of transcription factor binding motifs revealed a distinct subset of transcription factors that specifically target enhancers of genes downregulated by STK11 knockout under cytokine stimulation. Visualisation of these results using Venn diagrams facilitated the identification of transcription factor binding signatures unique to STK11-dependent enhancer regions.

??? abstract  "Usage video"
    <video width="1000" controls>
    <source src="../videos/Supplemental_video_3c.mp4" type="video/mp4"> 
    </video>
