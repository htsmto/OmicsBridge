# =============================================================================
# Epigenome - Find Enhancer/Promoter: Server
# File: modules/Epigenome/04_Epigenome_findEnhancerPromoter_server.R
# Purpose: Server logic for the "Find Enhancer/Promoter" sub-panel.
#          Handles dataset selection, sample matching, correlation calculation
#          between RNA-seq expression and ATAC-seq peak intensity, and
#          result display (tables, plots, peak lists).
#
# Edit this file when:
#   - Changing the correlation calculation logic or supported methods
#   - Adding new output types (tables, plots, downloads)
#   - Modifying how datasets are filtered or loaded
# =============================================================================

epigenome_findEnhancerPromoter_server <- function(input, output, session, Dataset) {

  Custom_genesets    <- data.frame(read.delim('data/Genesets_list.tsv', sep='\t', header=TRUE, check.names=FALSE))
  Gene_coords_GRch38 <- read.table('data/Gene_coords_GRch38.tsv', sep='\t', header=TRUE, check.names=FALSE)

  # --- [1] RNAseq dataset selection dropdowns ---------------------------------

  output$Enhancer_Find_data_select_RNAseq <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_RNAseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_RNAseq_Seuqenced_by, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_RNAseq_Experiments) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Experiments != 'None') {
        df_tmp <- df_tmp[df_tmp$Experiment == input$Enhancer_Find_data_select_RNAseq_Experiments, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_RNAseq_Data_type) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Data_type != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.type == input$Enhancer_Find_data_select_RNAseq_Data_type, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_RNAseq'), 'Select a RNAseq count dataset', c('None'='None', unique(df_tmp$Dataset)))
  })
  outputOptions(output, "Enhancer_Find_data_select_RNAseq", suspendWhenHidden=FALSE)

  output$Enhancer_Find_data_select_RNAseq_Seuqenced_by <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    selectInput(session$ns('Enhancer_Find_data_select_RNAseq_Seuqenced_by'), 'Data from', c('None'='None', unique(df_tmp$Data.from)))
  })

  output$Enhancer_Find_data_select_RNAseq_Experiments <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_RNAseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_RNAseq_Seuqenced_by, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_RNAseq_Experiments'), 'Experiment', c('None'='None', unique(df_tmp$Experiment)))
  })

  output$Enhancer_Find_data_select_RNAseq_Data_type <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_RNAseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_RNAseq_Seuqenced_by, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_RNAseq_Experiments) > 0) {
      if (input$Enhancer_Find_data_select_RNAseq_Experiments != 'None') {
        df_tmp <- df_tmp[df_tmp$Experiment == input$Enhancer_Find_data_select_RNAseq_Experiments, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_RNAseq_Data_type'), 'Data type', c('None'='None', unique(df_tmp$Data.type)))
  })


  # --- [2] ATACseq dataset selection dropdowns --------------------------------

  output$Enhancer_Find_data_select_ATACseq <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_ATACseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_ATACseq_Seuqenced_by, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_ATACseq_Experiments) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Experiments != 'None') {
        df_tmp <- df_tmp[df_tmp$Experiment == input$Enhancer_Find_data_select_ATACseq_Experiments, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_ATACseq_Data_type) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Data_type != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.type == input$Enhancer_Find_data_select_ATACseq_Data_type, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_ATACseq'), 'Select a ATACseq count dataset', c('None'='None', unique(df_tmp$Dataset)))
  })
  outputOptions(output, "Enhancer_Find_data_select_ATACseq", suspendWhenHidden=FALSE)

  output$Enhancer_Find_data_select_ATACseq_Seuqenced_by <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    selectInput(session$ns('Enhancer_Find_data_select_ATACseq_Seuqenced_by'), 'Data from', c('None'='None', unique(df_tmp$Data.from)))
  })

  output$Enhancer_Find_data_select_ATACseq_Experiments <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_ATACseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_ATACseq_Seuqenced_by, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_ATACseq_Experiments'), 'Experiment', c('None'='None', unique(df_tmp$Experiment)))
  })

  output$Enhancer_Find_data_select_ATACseq_Data_type <- renderUI({
    df_tmp <- Dataset()
    df_tmp <- df_tmp[df_tmp$Data.Class == 'A', ]
    if (length(input$Enhancer_Find_data_select_ATACseq_Seuqenced_by) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Seuqenced_by != 'None') {
        df_tmp <- df_tmp[df_tmp$Data.from == input$Enhancer_Find_data_select_ATACseq_Seuqenced_by, ]
      }
    }
    if (length(input$Enhancer_Find_data_select_ATACseq_Experiments) > 0) {
      if (input$Enhancer_Find_data_select_ATACseq_Experiments != 'None') {
        df_tmp <- df_tmp[df_tmp$Experiment == input$Enhancer_Find_data_select_ATACseq_Experiments, ]
      }
    }
    selectInput(session$ns('Enhancer_Find_data_select_ATACseq_Data_type'), 'Data type', c('None'='None', unique(df_tmp$Data.type)))
  })


  # --- [3] Load RNAseq data on dataset selection ------------------------------

  output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"Please select a dataset."})
  Enhancer_Find_RNAseq_data <- reactiveVal(NULL)

  observeEvent(input$Enhancer_Find_data_select_RNAseq, {
    if (length(input$Enhancer_Find_data_select_RNAseq) == 0) {
      Enhancer_Find_RNAseq_data(NULL)
      return(NULL)
    }
    if (input$Enhancer_Find_data_select_RNAseq == 'None') {
      output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"Please select a dataset."})
      Enhancer_Find_RNAseq_data(NULL)
      return(NULL)
    }
    path <- Dataset()[Dataset()$Dataset == input$Enhancer_Find_data_select_RNAseq, ]$Path
    if (!file.exists(path)) {
      output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({"The file does not exist. Please upload the dataset again."})
      Enhancer_Find_RNAseq_data(NULL)
      return(NULL)
    }
    tmp <- read.table(path, header=TRUE, check.names = FALSE)
    output$Enhancer_Find_data_select_RNAseq_SampleNames <- renderText({
      col_names <- colnames(tmp)
      n <- 3  # break after every 3 elements
      groups <- split(col_names, ceiling(seq_along(col_names) / n))
      paste(sapply(groups, function(x) paste(x, collapse = ", ")), collapse = "\n")
    })
    Enhancer_Find_RNAseq_data(tmp)
    return(NULL)
  })


  # --- [4] Load ATACseq data on dataset selection -----------------------------

  output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"Please select a dataset."})
  Enhancer_Find_ATACseq_data <- reactiveVal(NULL)

  observeEvent(input$Enhancer_Find_data_select_ATACseq, {
    if (length(input$Enhancer_Find_data_select_ATACseq) == 0) {
      Enhancer_Find_ATACseq_data(NULL)
      return(NULL)
    }
    if (input$Enhancer_Find_data_select_ATACseq == 'None') {
      output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"Please select a dataset."})
      Enhancer_Find_ATACseq_data(NULL)
      return(NULL)
    }
    path <- Dataset()[Dataset()$Dataset == input$Enhancer_Find_data_select_ATACseq, ]$Path
    if (!file.exists(path)) {
      output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({"The file does not exist. Please upload the dataset again."})
      Enhancer_Find_ATACseq_data(NULL)
      return(NULL)
    }
    tmp <- read.table(path, header=TRUE, check.names = FALSE)
    # Validate that the dataset contains ATACseq-style ids (chr:start-end)
    if (!all(grepl("^[^\\s:]+:[0-9]+-[0-9]+$", tmp$id))) {
      output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({
        "The selected dataset is not an ATACseq data. \nPlease select a valid ATACseq dataset. \nThe id of the ATACseq data should be the format of 'chr:start-end'."
      })
      Enhancer_Find_ATACseq_data(NULL)
      return(NULL)
    }
    output$Enhancer_Find_data_select_ATACseq_SampleNames <- renderText({
      col_names <- colnames(tmp)
      n <- 3  # break after every 3 elements
      groups <- split(col_names, ceiling(seq_along(col_names) / n))
      paste(sapply(groups, function(x) paste(x, collapse = ", ")), collapse = "\n")
    })
    Enhancer_Find_ATACseq_data(tmp)
    return(NULL)
  })


  # --- [5] Custom geneset selector --------------------------------------------

  output$Enhancer_Find_custom_geneset_select <- renderUI({
    if (input$Enhancer_Find_use_custom_geneset) {
      gene_sets_names <- c(Custom_genesets$Geneset.name)
      selectInput(session$ns('Enhancer_Find_custom_geneset_select'), 'Select a custom geneset', c('None'='None', gene_sets_names))
    }
  })
  outputOptions(output, "Enhancer_Find_custom_geneset_select", suspendWhenHidden=FALSE)


  # --- [5a] Disable gene textarea when custom geneset is selected -------------

  observe({
    if (isTRUE(input$Enhancer_Find_use_custom_geneset)) {
      shinyjs::disable("Enhancer_Find_input_gene")
    } else {
      shinyjs::enable("Enhancer_Find_input_gene")
    }
  })


  # --- [5b] Real-time sample name status -------------------------------------

  output$Enhancer_Find_sample_status <- renderText({
    txt <- input$Enhancer_Find_sample_select
    if (is.null(txt) || nchar(trimws(txt)) == 0) {
      return("Please enter sample name pairs (RNA_sample,ATAC_sample), one pair per line.")
    }
    lines <- strsplit(txt, "\n")[[1]]
    lines <- trimws(gsub("\r", "", lines))
    lines <- lines[lines != ""]
    pairs <- strsplit(lines, ",")
    rna_names  <- trimws(sapply(pairs, function(x) x[1]))
    atac_names <- trimws(sapply(pairs, function(x) if (length(x) >= 2) x[2] else NA_character_))
    valid <- !is.na(rna_names) & !is.na(atac_names) & rna_names != "" & atac_names != ""

    msgs <- c()
    msgs <- c(msgs, paste0(sum(valid), " pair(s) entered."))

    rna_data  <- Enhancer_Find_RNAseq_data()
    atac_data <- Enhancer_Find_ATACseq_data()

    if (!is.null(rna_data) && !is.null(atac_data)) {
      rna_ok  <- rna_names[valid]  %in% colnames(rna_data)
      atac_ok <- atac_names[valid] %in% colnames(atac_data)
      matched <- sum(rna_ok & atac_ok)
      msgs <- c(msgs, paste0(matched, " pair(s) found in both datasets."))

      rna_missing  <- rna_names[valid][!rna_ok]
      atac_missing <- atac_names[valid][!atac_ok]
      if (length(rna_missing) > 0)
        msgs <- c(msgs, paste0("Not found in RNAseq: ", paste(rna_missing, collapse=", ")))
      if (length(atac_missing) > 0)
        msgs <- c(msgs, paste0("Not found in ATACseq: ", paste(atac_missing, collapse=", ")))
    } else {
      msgs <- c(msgs, "(Select RNAseq and ATACseq datasets to check matches.)")
    }
    paste(msgs, collapse="\n")
  })


  # --- [5c] Real-time gene input status --------------------------------------

  output$Enhancer_Find_gene_status <- renderText({
    use_custom <- isTRUE(input$Enhancer_Find_use_custom_geneset)

    if (use_custom) {
      sel <- input$Enhancer_Find_custom_geneset_select
      if (is.null(sel) || sel == "None") {
        return("Please select a custom gene set.")
      }
      genes <- strsplit(
        Custom_genesets[Custom_genesets$Geneset.name %in% sel, ]$Genes, " "
      )[[1]]
      genes <- genes[genes != ""]
      return(paste0(length(genes), " gene(s) in selected gene set: ", sel))
    } else {
      txt <- input$Enhancer_Find_input_gene
      if (is.null(txt) || nchar(trimws(txt)) == 0) {
        return("Please enter gene names, one per line.")
      }
      genes <- strsplit(txt, "\n")[[1]]
      genes <- trimws(gsub("\r", "", genes))
      genes <- unique(genes[genes != ""])
      return(paste0(length(genes), " gene(s) entered."))
    }
  })


  # --- [6] Main correlation calculation ---------------------------------------

  output$Enhancer_Find_table_status       <- renderText({"The calculated correlations will be displayed here."})
  output$Enhancer_Find_RNAseq_data_status <- renderText({"The RNAseq data used for the correlation calculation will be shown here."})
  output$Enhancer_Find_ATACseq_data_status <- renderText({"The ATACseq data used for the correlation calculation will be shown here."})

  RNAseq_data_table           <- reactiveVal(NULL)
  ATACseq_data_table          <- reactiveVal(NULL)
  Enhancer_Find_table_result  <- reactiveVal(NULL)
  isCalculating_Enhancer_Find <- reactiveVal(FALSE)
  isTriggered_Enhancer_Find   <- reactiveVal(FALSE)
  Enhancer_Find_cor_all_data  <- reactiveVal(FALSE)

  observeEvent(input$Enhancer_Find_start, {
    isTriggered_Enhancer_Find(TRUE)
    isCalculating_Enhancer_Find(TRUE)

    # Guard: datasets must be loaded
    if (is.null(Enhancer_Find_RNAseq_data()) || is.null(Enhancer_Find_ATACseq_data())) {
      show_alert(title='Error.', text='Please select RNAseq and ATACseq datasets.', type='error')
      output$Enhancer_Find_table_status       <- renderText({"Please select RNAseq and ATACseq datasets."})
      output$Enhancer_Find_RNAseq_data_status <- renderText({"Please select RNAseq dataset."})
      output$Enhancer_Find_ATACseq_data_status <- renderText({"Please select ATACseq dataset."})
      RNAseq_data_table(NULL)
      ATACseq_data_table(NULL)
      Enhancer_Find_table_result(NULL)
      isCalculating_Enhancer_Find(FALSE)
      Enhancer_Find_cor_all_data(FALSE)
      return(NULL)
    }
    if (input$Enhancer_Find_data_select_RNAseq == 'None' || input$Enhancer_Find_data_select_ATACseq == 'None') {
      show_alert(title='Error.', text='Please select RNAseq and ATACseq datasets.', type='error')
      output$Enhancer_Find_table_status       <- renderText({"Please select RNAseq and ATACseq datasets."})
      output$Enhancer_Find_RNAseq_data_status <- renderText({"Please select RNAseq dataset."})
      output$Enhancer_Find_ATACseq_data_status <- renderText({"Please select ATACseq dataset."})
      RNAseq_data_table(NULL)
      ATACseq_data_table(NULL)
      Enhancer_Find_table_result(NULL)
      isCalculating_Enhancer_Find(FALSE)
      Enhancer_Find_cor_all_data(FALSE)
      return(NULL)
    }

    # Resolve target genes from text input or custom geneset
    if (input$Enhancer_Find_use_custom_geneset) {
      if (input$Enhancer_Find_custom_geneset_select == 'None') {
        show_alert(title='Error.', text='Please select a custom geneset.', type='error')
        output$Enhancer_Find_table_status       <- renderText({"Please select a custom geneset."})
        output$Enhancer_Find_RNAseq_data_status <- renderText({"Please set the input."})
        output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input."})
        RNAseq_data_table(NULL)
        ATACseq_data_table(NULL)
        Enhancer_Find_table_result(NULL)
        isCalculating_Enhancer_Find(FALSE)
        Enhancer_Find_cor_all_data(FALSE)
        return(NULL)
      }
      target_genes <- strsplit(
        Custom_genesets[Custom_genesets$Geneset.name %in% input$Enhancer_Find_custom_geneset_select, ]$Genes,
        split=', '
      )[[1]]
    } else {
      if (nchar(input$Enhancer_Find_input_gene) == 0) {
        show_alert(title='Error.', text='Please input genes.', type='error')
        output$Enhancer_Find_table_status       <- renderText({"Please input genes."})
        output$Enhancer_Find_RNAseq_data_status <- renderText({"Please input genes."})
        output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input"})
        RNAseq_data_table(NULL)
        ATACseq_data_table(NULL)
        Enhancer_Find_table_result(NULL)
        isCalculating_Enhancer_Find(FALSE)
        Enhancer_Find_cor_all_data(FALSE)
        return(NULL)
      }
      target_genes <- unlist(strsplit(input$Enhancer_Find_input_gene, split = "\n"))
    }

    # Guard: at least one target gene must exist in the RNAseq data
    if (length(intersect(target_genes, Enhancer_Find_RNAseq_data()$id)) == 0) {
      show_alert(title='Error.', text='The inputted genes are not found in the RNAseq data.', type='error')
      output$Enhancer_Find_table_status       <- renderText({"The inputted genes are not found in the RNAseq data."})
      output$Enhancer_Find_RNAseq_data_status <- renderText({"The inputted genes are not found in the RNAseq data."})
      output$Enhancer_Find_ATACseq_data_status <- renderText({"Please set the input"})
      RNAseq_data_table(NULL)
      ATACseq_data_table(NULL)
      Enhancer_Find_table_result(NULL)
      isCalculating_Enhancer_Find(FALSE)
      Enhancer_Find_cor_all_data(FALSE)
      return(NULL)
    }

    # Parse paired sample names (RNA,ATAC per line) with robust whitespace handling
    lines <- strsplit(input$Enhancer_Find_sample_select, "\n")[[1]]
    lines <- trimws(gsub("\r", "", lines))
    lines <- lines[lines != ""]
    pairs <- strsplit(lines, ",")
    RNAseq_sample  <- trimws(sapply(pairs, function(x) x[1]))
    ATACseq_sample <- trimws(sapply(pairs, function(x) if (length(x) >= 2) x[2] else NA_character_))
    valid <- !is.na(RNAseq_sample) & !is.na(ATACseq_sample)
    df_tmp <- data.frame(rna=RNAseq_sample[valid], atac=ATACseq_sample[valid])
    df_tmp_intersect <- df_tmp[
      df_tmp$rna  %in% colnames(Enhancer_Find_RNAseq_data()) &
      df_tmp$atac %in% colnames(Enhancer_Find_ATACseq_data()), ]
    RNAseq_sample_intersect  <- df_tmp_intersect$rna
    ATACseq_sample_intersect <- df_tmp_intersect$atac

    # Guard: need at least 3 matching pairs
    if (length(RNAseq_sample_intersect) <= 2 || length(ATACseq_sample_intersect) <= 2) {
      show_alert(title='Error.', text='Please input more than three samples.', type='error')
      output$Enhancer_Find_table_status       <- renderText({"Please input more than three samples"})
      output$Enhancer_Find_RNAseq_data_status <- renderText({"Please input more than three samples"})
      output$Enhancer_Find_ATACseq_data_status <- renderText({"Please input more than three samples"})
      RNAseq_data_table(NULL)
      ATACseq_data_table(NULL)
      Enhancer_Find_table_result(NULL)
      isCalculating_Enhancer_Find(FALSE)
      Enhancer_Find_cor_all_data(FALSE)
      return(NULL)
    }

    # Warn about samples not found in either dataset
    RNAseq_sample_diff  <- setdiff(RNAseq_sample,  RNAseq_sample_intersect)
    ATACseq_sample_diff <- setdiff(ATACseq_sample, ATACseq_sample_intersect)
    if (length(RNAseq_sample_diff) > 0 || length(ATACseq_sample_diff) > 0) {
      output$Enhancer_Find_table_status <- renderText({
        msg <- "The following samples are not found in the RNAseq or ATACseq data:\n"
        if (length(RNAseq_sample_diff) > 0) {
          msg <- paste0(msg, "RNAseq samples: ", paste(RNAseq_sample_diff, collapse = ", "), "\n")
        }
        if (length(ATACseq_sample_diff) > 0) {
          msg <- paste0(msg, "ATACseq samples: ", paste(ATACseq_sample_diff, collapse = ", "))
        }
        return(msg)
      })
    }

    # Subset data to target genes and matched samples
    RNAseq_df  <- Enhancer_Find_RNAseq_data()[Enhancer_Find_RNAseq_data()$id %in% target_genes, c('id', RNAseq_sample_intersect)]
    ATACseq_df <- Enhancer_Find_ATACseq_data()[, c('id', ATACseq_sample_intersect)]
    RNAseq_data_table(RNAseq_df)
    ATACseq_data_table(ATACseq_df)

    # Parse ATACseq peak coordinates from id column (chr:start-end)
    ATACseq_df$id    <- as.character(ATACseq_df$id)
    ATACseq_df$chr   <- sapply(strsplit(ATACseq_df$id, ":"), function(x) x[1])
    ATACseq_df$start <- as.numeric(sapply(strsplit(ATACseq_df$id, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][1])))
    ATACseq_df$end   <- as.numeric(sapply(strsplit(ATACseq_df$id, ":"), function(x) as.numeric(strsplit(x[2], "-")[[1]][2])))
    ATACseq_df <- ATACseq_df[, c('id', 'chr', 'start', 'end', ATACseq_sample_intersect)]

    # Correlation loop across genes and nearby peaks
    df_cor_tmp <- data.frame(
      list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)),
      stringsAsFactors = FALSE
    )
    ATACseq_Peak_all <- c()
    df_cor_all_data <- data.frame(
      list('Gene_id'=character(0), 'Peak_id'=character(0), 'Gene'=numeric(0), 'Peak'=numeric(0), 'Sample'=numeric(0)),
      stringsAsFactors = FALSE
    )

    for (each_gene in intersect(target_genes, Enhancer_Find_RNAseq_data()$id)) {
      if (each_gene %in% RNAseq_df$id == FALSE) {
        next
      }
      RNAseq_df_gene <- RNAseq_df[RNAseq_df$id == each_gene, ]
      RNAseq_df_gene <- as.numeric(RNAseq_df_gene[1, RNAseq_sample_intersect])

      # Look up gene coordinates in GRCh38 annotation
      if (each_gene %in% Gene_coords_GRch38$gene_name == FALSE) {
        next
      }
      gene_chr_all   <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'chr']
      gene_start_all <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'start']
      gene_end_all   <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name == each_gene, 'end']
      if (length(gene_chr_all) == 0 | length(gene_start_all) == 0 | length(gene_end_all) == 0) {
        next
      }
      if (any(is.na(gene_chr_all) | is.na(gene_start_all) | is.na(gene_end_all))) {
        next
      }

      for (i in seq_along(gene_chr_all)) {
        gene_chr   <- gene_chr_all[i]
        gene_start <- gene_start_all[i]
        gene_end   <- gene_end_all[i]
        # Ensure start <= end
        if (gene_start > gene_end) {
          tmp        <- gene_start
          gene_start <- gene_end
          gene_end   <- tmp
        }

        Extend <- input$Enhancer_Find_extend_length
        if (input$Enhancer_Find_chr_focus) {
          ATACseq_df_tmp <- ATACseq_df[
            ATACseq_df$chr == gene_chr &
            ATACseq_df$end   >= gene_start - Extend &
            ATACseq_df$start <= gene_end   + Extend, ]
        }
        if (dim(ATACseq_df_tmp)[1] == 0) {
          next
        }
        ATACseq_Peak_all <- c(ATACseq_Peak_all, ATACseq_df_tmp$id)

        for (each_peak in ATACseq_df_tmp$id) {
          ATACseq_df_peak    <- ATACseq_df_tmp[ATACseq_df_tmp$id == each_peak, ]
          sample_annotation  <- colnames(ATACseq_df_tmp[ATACseq_df_tmp$id == each_peak, -c(1,2,3,4), drop=FALSE])
          ATACseq_df_peak    <- as.numeric(ATACseq_df_peak[1, -c(1,2,3,4)])
          if (length(RNAseq_df_gene) != length(ATACseq_df_peak)) {
            next
          }
          if (var(RNAseq_df_gene) == 0 || var(ATACseq_df_peak) == 0) {
            next
          }
          cor_test <- tryCatch(
            cor.test(RNAseq_df_gene, ATACseq_df_peak, method = input$Enhancer_Find_calculation_type),
            error = function(e) {
              output$Enhancer_Find_table_status <- renderText({
                paste0("Error in correlation calculation for gene: ", each_gene, " and peak: ", each_peak, ". ", e$message)
              })
              next
            }
          )
          df_cor_all_data <- rbind(df_cor_all_data,
            data.frame(Gene_id=each_gene, Peak_id=each_peak,
                       Gene=RNAseq_df_gene, Peak=ATACseq_df_peak, Sample=sample_annotation,
                       stringsAsFactors = FALSE))
          if (!is.null(cor_test)) {
            df_cor_tmp <- rbind(df_cor_tmp,
              data.frame(Gene=each_gene, Peak=each_peak,
                         Correlation=cor_test$estimate, P.value=cor_test$p.value,
                         stringsAsFactors = FALSE))
          }
        }
      }
    }

    ATACseq_data_table(ATACseq_df[ATACseq_df$id %in% ATACseq_Peak_all, ])
    Enhancer_Find_cor_all_data(df_cor_all_data)
    output$Enhancer_Find_table_status       <- renderText({NULL})
    output$Enhancer_Find_RNAseq_data_status <- renderText({NULL})
    output$Enhancer_Find_ATACseq_data_status <- renderText({NULL})
    Enhancer_Find_table_result(df_cor_tmp)
    isCalculating_Enhancer_Find(FALSE)
    return(NULL)
  })


  # --- [7] Result tables ------------------------------------------------------

  # Correlation result table
  output$Enhancer_Find_table <- renderDataTable({
    empty <- data.frame(list('Gene'=character(0), 'Peak'=character(0), 'Correlation'=numeric(0), 'P.value'=numeric(0)), stringsAsFactors = FALSE)
    if (!isTriggered_Enhancer_Find() || isCalculating_Enhancer_Find()) {
      return(datatable(empty, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
    }
    if (is.null(Enhancer_Find_table_result())) {
      return(datatable(empty, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE)))
    }
    datatable(Enhancer_Find_table_result(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5))
  })
  outputOptions(output, "Enhancer_Find_table", suspendWhenHidden=FALSE)

  # RNAseq data table
  output$Enhancer_Find_RNAseq_data_table <- renderDataTable({
    if (!isTriggered_Enhancer_Find() || isCalculating_Enhancer_Find() || is.null(RNAseq_data_table())) {
      tmp <- data.frame(list('Gene'=character(0), 'Sample'=character(0)), stringsAsFactors = FALSE)
      return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5)))
    }
    datatable(RNAseq_data_table(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5))
  })

  # ATACseq data table
  output$Enhancer_Find_ATACseq_data_table <- renderDataTable({
    if (is.null(ATACseq_data_table())) {
      tmp <- data.frame(list('id'=character(0), 'Sample'=character(0)), stringsAsFactors = FALSE)
      return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5)))
    }
    datatable(ATACseq_data_table(), selection = list(mode='single'), options = list(scrollX = TRUE, scrollY=TRUE, pageLength=5))
  })


  # --- [8] Scatter plot: selected gene-peak pair ------------------------------

  output$Enhancer_Find_table_plot <- renderPlot({
    if (!isTriggered_Enhancer_Find() || isCalculating_Enhancer_Find() || is.null(Enhancer_Find_table_result())) {
      output$Enhancer_Find_table_plot_status <- renderText({NULL})
      return(NULL)
    }
    if (length(input$Enhancer_Find_table_rows_selected) == 0) {
      output$Enhancer_Find_table_plot_status <- renderText({"Please select a row. A correlation scatter plot will be shown here."})
      return(NULL)
    }
    output$Enhancer_Find_table_plot_status <- renderText({NULL})
    Gene <- Enhancer_Find_table_result()[input$Enhancer_Find_table_rows_selected, ]$Gene
    Peak <- Enhancer_Find_table_result()[input$Enhancer_Find_table_rows_selected, ]$Peak
    if (length(Gene) == 0 | length(Peak) == 0) {
      return(NULL)
    }
    if (is.null(Enhancer_Find_cor_all_data())) {
      return(NULL)
    }
    df_cor_all_data <- Enhancer_Find_cor_all_data()
    if (dim(df_cor_all_data)[1] == 0) {
      return(NULL)
    }
    df_cor_all_data_extract <- df_cor_all_data[
      df_cor_all_data$Gene_id == Gene & df_cor_all_data$Peak_id == Peak,
      c('Gene', 'Peak', 'Sample')]
    if (dim(df_cor_all_data_extract)[1] == 0) {
      return(NULL)
    }
    p <- ggplot(df_cor_all_data_extract, aes(x=Gene, y=Peak))
    p <- p + geom_point(color=input$Enhancer_Find_table_plot_point_col, size=1)
    if (input$Enhancer_Find_table_plot_correlation) {
      p <- p + geom_smooth(method='lm', color='red', se=FALSE, linewidth=0.5)
    }
    if (!input$Enhancer_Find_table_plot_label) {
      p <- p + geom_text_repel(
        data = df_cor_all_data_extract, color = 'black', aes(label = Sample),
        max.overlaps=Inf, box.padding = 0.3, point.padding = 0.5,
        segment.color = 'grey50', segment.size = 0.1,
        size=input$Enhancer_Find_table_plot_legend_font_size)
    }
    p <- p + labs(
      title=paste0('Correlation between\n', Gene, ' and ', Peak),
      x=paste0(Gene, '\nexpression'),
      y=paste0(Peak, '\naccessibility'))
    p <- p + theme(
      axis.title=element_text(size=input$Enhancer_Find_table_plot_label_font_size),
      axis.text=element_text(size=input$Enhancer_Find_table_plot_font_size),
      plot.title=element_text(size=input$Enhancer_Find_table_plot_title_size, hjust = 0.5))
    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
    p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
    p
  }, width=reactive(input$Enhancer_Find_table_plot_fig.width), height=reactive(input$Enhancer_Find_table_plot_fig.height), res=300)


  # --- [9] Bar plots: correlation by gene or by peak --------------------------

  # Bar plot when a gene row is selected in the RNAseq table
  output$Enhancer_Find_RNAseq_data_plot <- renderPlot({
    if (!isTriggered_Enhancer_Find() || isCalculating_Enhancer_Find() || is.null(Enhancer_Find_table_result())) {
      output$Enhancer_Find_RNAseq_data_plot_status <- renderText({NULL})
      return(NULL)
    }
    if (length(input$Enhancer_Find_RNAseq_data_table_rows_selected) == 0) {
      output$Enhancer_Find_RNAseq_data_plot_status <- renderText({"Please select a row. A bar plot will be shown here."})
      return(NULL)
    }
    output$Enhancer_Find_RNAseq_data_plot_status <- renderText({NULL})
    Gene <- RNAseq_data_table()[input$Enhancer_Find_RNAseq_data_table_rows_selected, ]$id
    if (length(Gene) == 0) {
      return(NULL)
    }
    Enhancer_corr_results      <- Enhancer_Find_table_result()
    Enhancer_corr_results_gene <- Enhancer_corr_results[Enhancer_corr_results$Gene == Gene, c('Peak', 'Correlation', 'P.value')]
    Enhancer_corr_results_gene$Correlation <- as.numeric(Enhancer_corr_results_gene$Correlation)
    Enhancer_corr_results_gene$ypos <- ifelse(
      Enhancer_corr_results_gene$Correlation >= 0,
      Enhancer_corr_results_gene$Correlation + 0.02,
      Enhancer_corr_results_gene$Correlation - 0.02
    )
    Enhancer_corr_results_gene$label <- ifelse(Enhancer_corr_results_gene$P.value < input$Enhancer_Find_show_list_threshold, "*", "")
    p <- ggplot(Enhancer_corr_results_gene, aes(x=reorder(Peak, Correlation), y=Correlation, fill=Correlation))
    p <- p + geom_text(aes(label=label, y=ypos), vjust=ifelse(Enhancer_corr_results_gene$Correlation >= 0, 0, 1), size=1.5)
    p <- p + geom_bar(stat='identity')
    p <- p + scale_fill_gradient2(
      low=input$Enhancer_Find_RNAseq_data_plot_min_col,
      mid=input$Enhancer_Find_RNAseq_data_plot_mid_col,
      high=input$Enhancer_Find_RNAseq_data_plot_max_col,
      midpoint=0,
      limits=c(-max(abs(Enhancer_corr_results_gene$Correlation)), max(abs(Enhancer_corr_results_gene$Correlation))))
    p <- p + xlab('Peak') + ylab('Correlation') + ggtitle(paste0('Correlation of peaks with gene: ', Gene))
    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
    p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
    p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
    p <- p + theme(plot.title = element_text(hjust = 0.5))
    p <- p + theme(
      axis.title=element_text(size=input$Enhancer_Find_RNAseq_data_plot_font_size),
      axis.text=element_text(size=input$Enhancer_Find_RNAseq_data_plot_label_font_size),
      plot.title=element_text(size=input$Enhancer_Find_RNAseq_data_plot_title_size))
    p <- p + guides(fill = guide_colourbar(barwidth = unit(0.1, "cm"), barheight = unit(1.2, "cm")))
    p <- p + theme(
      legend.text=element_text(size=input$Enhancer_Find_RNAseq_data_legend_size),
      legend.title=element_text(size=input$Enhancer_Find_RNAseq_data_legend_size))
    p
  }, width = reactive(input$Enhancer_Find_RNAseq_data_plot_fig.width), height = reactive(input$Enhancer_Find_RNAseq_data_plot_fig.height), res=300)

  # Bar plot when a peak row is selected in the ATACseq table
  output$Enhancer_Find_ATACseq_data_plot <- renderPlot({
    if (!isTriggered_Enhancer_Find() || isCalculating_Enhancer_Find() || is.null(Enhancer_Find_table_result())) {
      output$Enhancer_Find_ATACseq_data_plot_status <- renderText({NULL})
      return(NULL)
    }
    output$Enhancer_Find_RNAseq_data_plot_status <- renderText({NULL})
    Peak <- ATACseq_data_table()[input$Enhancer_Find_ATACseq_data_table_rows_selected, ]$id
    if (length(Peak) == 0) {
      return(NULL)
    }
    Enhancer_corr_results      <- Enhancer_Find_table_result()
    Enhancer_corr_results_gene <- Enhancer_corr_results[Enhancer_corr_results$Peak == Peak, c('Gene', 'Correlation', 'P.value')]
    Enhancer_corr_results_gene$Correlation <- as.numeric(Enhancer_corr_results_gene$Correlation)
    Enhancer_corr_results_gene$ypos <- ifelse(
      Enhancer_corr_results_gene$Correlation >= 0,
      Enhancer_corr_results_gene$Correlation + 0.02,
      Enhancer_corr_results_gene$Correlation - 0.02
    )
    Enhancer_corr_results_gene$label <- ifelse(Enhancer_corr_results_gene$P.value < input$Enhancer_Find_show_list_threshold, "*", "")
    p <- ggplot(Enhancer_corr_results_gene, aes(x=reorder(Gene, Correlation), y=Correlation, fill=Correlation))
    p <- p + geom_text(aes(label=label, y=ypos), vjust=ifelse(Enhancer_corr_results_gene$Correlation >= 0, 0, 1), size=8)
    p <- p + geom_bar(stat='identity')
    p <- p + scale_fill_gradient2(
      low=input$Enhancer_Find_RNAseq_data_plot_min_col,
      mid=input$Enhancer_Find_RNAseq_data_plot_mid_col,
      high=input$Enhancer_Find_RNAseq_data_plot_max_col,
      midpoint=0,
      limits=c(-max(abs(Enhancer_corr_results_gene$Correlation)), max(abs(Enhancer_corr_results_gene$Correlation))))
    p <- p + xlab('Gene') + ylab('Correlation') + ggtitle(paste0('Correlation of genes with peak: ', Peak))
    p <- p + theme(panel.grid = element_blank(), panel.border=element_blank(), axis.line = element_line(color='black', linewidth=0.1))
    p <- p + theme(panel.background = element_rect(fill="white", linewidth=0))
    p <- p + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    p <- p + theme(axis.ticks = element_line(linewidth=0.1)) + theme(axis.ticks.length = unit(0.5, "pt"))
    p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
    p <- p + theme(plot.title = element_text(hjust = 0.5))
    p <- p + theme(
      axis.title=element_text(size=input$Enhancer_Find_RNAseq_data_plot_font_size),
      axis.text=element_text(size=input$Enhancer_Find_RNAseq_data_plot_label_font_size),
      plot.title=element_text(size=input$Enhancer_Find_RNAseq_data_plot_title_size))
    p <- p + guides(fill = guide_colourbar(barwidth = unit(0.1, "cm"), barheight = unit(1.2, "cm")))
    p <- p + theme(
      legend.text=element_text(size=input$Enhancer_Find_RNAseq_data_legend_size),
      legend.title=element_text(size=input$Enhancer_Find_RNAseq_data_legend_size))
    p
  }, width = reactive(input$Enhancer_Find_ATACseq_data_plot_fig.width), height = reactive(input$Enhancer_Find_ATACseq_data_plot_fig.height), res=300)


  # --- [10] Download handler --------------------------------------------------

  output$Enhancer_Find_table_status_download <- downloadHandler(
    filename = function() { "RNAseq_ATACseq_Correlation.tsv" },
    content  = function(fname) { write.table(Enhancer_Find_table_result(), fname, sep='\t', quote=FALSE, row.names=FALSE) }
  )


  # --- [11] Correlated peak list panel ----------------------------------------

  # Gene selector populated after calculation
  output$Enhancer_Find_gene_selection <- renderUI({
    if (is.null(Enhancer_Find_table_result())) {
      selectInput(session$ns('Enhancer_Find_gene_selection'), 'Select a gene', c('All'))
    } else {
      genes <- c('All', Enhancer_Find_table_result()$Gene)
      selectInput(session$ns('Enhancer_Find_gene_selection'), 'Select a gene', genes)
    }
  })

  # Peak list filtered by selected gene and p-value threshold
  output$Enhancer_Find_gene_correlated_peak_list <- renderText({
    if (is.null(Enhancer_Find_table_result())) {
      return("Please calculate the correlation first.")
    }
    p_thr <- input$Enhancer_Find_show_list_threshold
    if (input$Enhancer_Find_gene_selection == 'All') {
      tmp <- Enhancer_Find_table_result()[Enhancer_Find_table_result()$P.value < p_thr, ]
      if (dim(tmp)[1] == 0) {
        return("No peaks found with the selected threshold.")
      }
      tmp <- tmp[order(tmp$Correlation, decreasing = TRUE), ]
      return(paste(tmp$Peak, collapse = "\n"))
    } else {
      selected_gene <- input$Enhancer_Find_gene_selection
      if (selected_gene %in% Enhancer_Find_table_result()$Gene) {
        selected_peaks <- Enhancer_Find_table_result()[Enhancer_Find_table_result()$Gene == selected_gene, ]$Peak
        selected_peaks <- selected_peaks[Enhancer_Find_table_result()[Enhancer_Find_table_result()$Gene == selected_gene, ]$P.value < p_thr]
        if (length(selected_peaks) == 0) {
          return("No peaks found with the selected threshold.")
        }
        return(paste(selected_peaks, collapse = "\n"))
      } else {
        return("Please select a gene.")
      }
    }
  })

}
