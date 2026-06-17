# =============================================================================
# DataOverview - GSEA: Calculation
# File: modules/DataOverview/04_03_DataOverview_GESA_calc.R
# Purpose: Handles gene set selection UI and runs fgsea calculation on the
#          ranked expression data. Returns GSEA results as reactive values.
# Edit this file when: changing the ranking metric, gene set database,
#                       p-value cutoff, or fgsea parameters.
# Libraries required: fgsea (loaded via libraries_DataOverview.R)
# =============================================================================

gsea_calc_server <- function(input, output, session, df_ex, Original_geneset_list) {
    ## Input and Settings
        # Select UI
            output$GSEA_select_score <- renderUI({
                if(length(df_ex()) == 0 || is.null(df_ex())) {
                    return(NULL)
                } else {
                    selectInput(session$ns('GSEA_select_score'), 'Choose which score to use: (genes will be sorted by this score)', c('None'='None', colnames(df_ex())))
                }
            })
        #

        # pathway chooose (Custom Gene sets)
            output$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set <- renderUI({
                if(input$GSEA_pathway_dataset_select == 'E' && input$GSEA_pathway_dataset_select_one_geneset_select == 'A') {
                    gene_sets_names <- c(Original_geneset_list$Geneset.name)
                    selectInput(session$ns('GSEA_pathway_dataset_select_one_geneset_select_from_custom_set'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })
        #

        # status
            GSEA_pathway_dataset_select_status <- reactiveVal(NULL)
            output$GSEA_pathway_dataset_select_status <- renderText({ GSEA_pathway_dataset_select_status() })
        #

        # gene set selection -> GSEA_Gene_set()
            GSEA_Gene_set <- reactiveVal(NULL)
            observe({
                if(length(input$GSEA_pathway_dataset_select) == 0 || is.null(input$GSEA_pathway_dataset_select)){
                    GSEA_Gene_set(NULL)
                    return(NULL)
                }

                # from hallmark (human)
                if(input$GSEA_pathway_dataset_select == 'B'){
                    gsc <- gmtPathways('data/h.all.v2023.2.Hs.symbols.gmt')
                    GSEA_Gene_set(gsc)
                    GSEA_pathway_dataset_select_status(paste0(length(gsc), ' gene sets were selected from the HALLMARK (human) dataset.'))
                    return()
                }

                # from hallmark (mouse)
                else if(input$GSEA_pathway_dataset_select == 'C'){
                    gsc <- gmtPathways('data/mh.all.v2023.2.Mm.symbols.gmt')
                    GSEA_Gene_set(gsc)
                    GSEA_pathway_dataset_select_status(paste0(length(gsc), ' gene sets were selected from the HALLMARK (mouse) dataset.'))
                }

                # from uploaded gmt file
                else if(input$GSEA_pathway_dataset_select == 'D'){
                    tmp <- input$GSEA_upload_custom_pathway_file
                    if (is.null(tmp)){
                        GSEA_pathway_dataset_select_status('Please upload a gmt file.')
                        gsc <- NULL
                        GSEA_Gene_set(gsc)
                        return(NULL)
                    }else {
                        gsc <- gmtPathways(tmp$datapath)
                        GSEA_Gene_set(gsc)
                        GSEA_pathway_dataset_select_status(paste0(length(gsc), ' gene sets were selected from the uploaded gmt file.'))
                    }
                }

                # from one gene set
                else if(input$GSEA_pathway_dataset_select == 'E'){

                    if(length(input$GSEA_pathway_dataset_select_one_geneset_select) == 0){
                        GSEA_Gene_set(NULL)
                        return(NULL)
                    }

                    # from one custom gene set
                    else if(input$GSEA_pathway_dataset_select_one_geneset_select == 'A'){

                        if(length(input$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set) == 0 || input$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set == 'None'){
                            GSEA_Gene_set(NULL)
                            GSEA_pathway_dataset_select_status('Please select a custom gene set.')
                            return(NULL)
                        }else{
                            genes <- strsplit(Original_geneset_list[Original_geneset_list$Geneset.name %in% input$GSEA_pathway_dataset_select_one_geneset_select_from_custom_set, ]$Genes, split=', ')[[1]]
                            gsc <- list('Selected custom gene set' = genes)
                            GSEA_pathway_dataset_select_status('One gene set was set from the selected custom gene set.')
                            GSEA_Gene_set(gsc)
                            return(NULL)
                        }

                    }

                    # from one gene set by text input
                    else if(input$GSEA_pathway_dataset_select_one_geneset_select == 'B'){
                        if(length(input$GSEA_pathway_dataset_select_one_geneset_select_from_text) == 0 || input$GSEA_pathway_dataset_select_one_geneset_select_from_text == ''){
                            GSEA_Gene_set(NULL)
                            GSEA_pathway_dataset_select_status('Please input genes for the gene set.')
                            return(NULL)
                        }

                        # if all the input is spaces
                        if(grepl("^\\s*$", input$GSEA_pathway_dataset_select_one_geneset_select_from_text)){
                            GSEA_Gene_set(NULL)
                            GSEA_pathway_dataset_select_status('Please input genes for the gene set.')
                            return(NULL)
                        }

                        genes <- unlist(strsplit(input$GSEA_pathway_dataset_select_one_geneset_select_from_text, split = "\n"))

                        # remove empty and space-only genes
                        genes <- genes[!grepl("^\\s*$", genes)]
                        gsc <- list('Inputted gene set' = genes) # genes <- c('CXCL10', 'CXCL9')
                        GSEA_Gene_set(gsc)
                        GSEA_pathway_dataset_select_status('One gene set was set from the text input.')
                        GSEA_Gene_set(gsc)
                        return(NULL)
                    }
                }
            })
        #

    ##

    ## calculation GSEA
        # status
            GSEA_analysis_status <- reactiveVal('Set the gene sets, select the score for ranking, and then click the button to start the analysis.')
            output$GSEA_analysis_status <- renderText({ GSEA_analysis_status()})
        #

        # start
            GSEA_results <- reactiveVal(NULL)
            GSEA_Gene_set_after_start <- reactiveVal(NULL)
            ranked_score <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            observeEvent(input$GSEA_start, {
                isCalculating(TRUE)
                df_ex <- df_ex()
                # check the data
                    if(length(df_ex) == 0 || is.null(df_ex)){
                        show_alert(title='Error.',text='No data available for the analysis. Please check the input.', type='error')
                        GSEA_analysis_status('No data available for the analysis. Please check the input.')
                        GSEA_results(NULL)
                        isCalculating(FALSE)
                        ranked_score(NULL)
                        return(NULL)
                    }
                #

                # check the score is selected
                    if(length(input$GSEA_select_score) == 0 || input$GSEA_select_score=='None'){
                        show_alert(title='Error.',text='Please choose the score for the analysis.', type='error')
                        GSEA_analysis_status('Please choose the score for the analysis')
                        GSEA_results(NULL)
                        isCalculating(FALSE)
                        ranked_score(NULL)
                        GSEA_Gene_set_after_start(NULL)
                        return(NULL)
                    }
                #

                # check if the genesets are set
                    if(length(GSEA_Gene_set()) == 0 || is.null(GSEA_Gene_set())){
                        show_alert(title='Error.',text='No gene set is selected for the analysis. Please check the input.', type='error')
                        GSEA_analysis_status('No gene set is selected for the analysis. Please check the input.')
                        GSEA_results(NULL)
                        isCalculating(FALSE)
                        ranked_score(NULL)
                        GSEA_Gene_set_after_start(NULL)
                        return(NULL)
                    }
                #
                ranked_genes <- df_ex[,input$GSEA_select_score]

                # when the ranking score is not numeric
                    if(!is.numeric(ranked_genes)){
                        show_alert(title='Error.',text='The selected score is not numeric.', type='error')
                        GSEA_analysis_status('The selected score is not numeric, and cannot be used for the GSEA analysis. Please choose another.')
                        GSEA_results(NULL)
                        isCalculating(FALSE)
                        ranked_score(NULL)
                        GSEA_Gene_set_after_start(NULL)
                        return(NULL)
                    }
                #

                names(ranked_genes) <- df_ex$id
                ranked_genes <- ranked_genes[!is.na(names(ranked_genes)) & names(ranked_genes) != ""]
                set.seed(1234)
                gsc <- GSEA_Gene_set()
                fgseaRes2 <- fgsea(pathways = gsc, stats = ranked_genes, minSize = 1, maxSize = 5000)
                if(dim(fgseaRes2)[1] == 0){
                    show_alert(title='Error.',text='No pathway was able to calculate the GSEA score to this dataset.', type='error')
                    tmp <- "No pathway was able to calculate the GSEA score to this dataset.\n"
                    tmp <- paste0(tmp, "Potential cause:\n")
                    tmp <- paste0(tmp, "- Using differnet species\n")
                    tmp <- paste0(tmp, "- The gene names in the dataset are not gene symbol\n")
                    tmp <- paste0(tmp, "- No overlap between the genes in the dataset and the genes in the pathwas\n")
                    tmp <- paste0(tmp, "- The size of the gene set is too small\n")
                    GSEA_analysis_status(tmp)
                    GSEA_results(NULL)
                    ranked_score(NULL)
                    isCalculating(FALSE)
                    GSEA_Gene_set_after_start(NULL)
                    return(NULL)
                }
                # message: Gene sets, the score used for ranking, how many genes were used for the analysis
                message <- paste0(length(gsc), ' gene sets were used for the analysis. \nThe score used for ranking is: ', input$GSEA_select_score, '.\nNumber of genes used for the analysis: ', length(ranked_genes), '.')
                GSEA_analysis_status(message)
                fgseaRes2 <- data.frame(fgseaRes2[order(pval), ], check.names = FALSE)
                fgseaRes2 <- fgseaRes2[c('pathway', 'pval', 'padj', 'log2err', 'ES', 'NES', 'size')]
                GSEA_results(fgseaRes2)
                ranked_score(input$GSEA_select_score)
                GSEA_Gene_set_after_start(GSEA_Gene_set())
                isCalculating(FALSE)
                return(NULL)
            })
        #
    ##

    ## return reactive values needed by plot sub-module
        return(list(
            GSEA_results            = GSEA_results,
            GSEA_Gene_set_after_start = GSEA_Gene_set_after_start,
            ranked_score            = ranked_score,
            isCalculating           = isCalculating
        ))
    ##
}
