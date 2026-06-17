# =============================================================================
# DataOverview - GO / Pathway Enrichment: Calculation
# File: modules/DataOverview/04_02_DataOverview_GO_calc.R
# Purpose: Handles gene input (text, filtered, or selected genes) and runs
#          ORA enrichment via clusterProfiler (GO or KEGG database).
# Edit this file when: changing the enrichment method (GO vs KEGG vs Reactome),
#                       background gene set, p-value cutoff, or input modes.
# =============================================================================

go_calc_server <- function(input, output, session, filtered_ex, selected_ex) {
    ## Input and Settings ----
        # Input
            # status
                GO_input_geneList_status <- reactiveVal(NULL)
                output$GO_input_geneList_status <- renderText({ GO_input_geneList_status() })
            #

            # Input genes -> GO_input_genes()
                    # column(12, radioButtons(ns("GO_input_type"), "Input genes for the analysis", choices = c("Text input"='A', "Use filtered genes (Results from 'Show outliers' above)"='B', "Use selected genes (Selected area in the Main plot)"='C'), selected="A")),
                    # conditionalPanel(condition = paste0("input['", ns("GO_input_type"), "'] == 'A'"),
                    #     column(12, textAreaInput(ns("GO_input_geneList"), "Enter gene list (one gene per line, Gene symbol)"))
                    # ),
                    # column(10, verbatimTextOutput(ns('GO_input_geneList_status')) ),
                    # column(12, h4(''))
                GO_input_genes <- reactiveVal(NULL)
                observe({
                    # Text input -> unlist the input and remove empty lines.
                    # B -> get the ids from the filtered_ex reactive value.
                    # C -> get the ids from the selected_ex reactive value.
                    if(length(input$GO_input_type) == 0 || is.null(input$GO_input_type)){
                        GO_input_genes(NULL)
                        GO_input_geneList_status(NULL)
                        return()
                    }

                    # Text input
                    if(input$GO_input_type == 'A'){
                        if(length(input$GO_input_geneList) == 0 || is.null(input$GO_input_geneList)){
                            GO_input_genes(NULL)
                            GO_input_geneList_status(NULL)
                            return()
                        }

                        # if all the input are spaces.
                        if(all(grepl("^\\s*$", input$GO_input_geneList))){
                            GO_input_genes(NULL)
                            GO_input_geneList_status('Please enter genes line by line. ')
                            return()
                        }

                        # unlist the input and remove empty lines.
                        genes <- unlist(strsplit(input$GO_input_geneList, "\n"))
                        genes <- genes[!grepl("^\\s*$", genes)]

                        if(length(genes) == 0){
                            GO_input_genes(NULL)
                            GO_input_geneList_status("Please enter valid genes names. ")
                            return()
                        }

                        GO_input_genes(genes)
                        GO_input_geneList_status(paste0(length(genes), " genes inputted."))

                    }

                    # Filtered genes
                    else if(input$GO_input_type == 'B'){
                        if(is.null(filtered_ex()) || nrow(filtered_ex()) == 0){
                            GO_input_genes(NULL)
                            GO_input_geneList_status("No filtered genes available. Please use the 'Show outliers' function to filter genes first. ")
                            return()
                        }

                        GO_input_genes(filtered_ex()$id)
                        GO_input_geneList_status(paste0(length(filtered_ex()$id), " filtered genes available and will be used for the analysis. "))

                    }

                    # Selected genes
                    else if(input$GO_input_type == 'C'){
                        if(is.null(selected_ex()) || nrow(selected_ex()) == 0){
                            GO_input_genes(NULL)
                            GO_input_geneList_status("No selected genes available. Please select genes from the Main plot first. ")
                            return()
                        }

                        GO_input_genes(selected_ex()$id)
                        GO_input_geneList_status(paste0(length(selected_ex()$id), " selected genes available and will be used for the analysis. "))
                    }
                })
            #

        #

        # Do GO/KEGG analysis
            # status
                GO_go_status <- reactiveVal('Please enter inputs and select other settings, and click "Start GO/KEGG Analysis"')
                output$GO_go_status <- renderText({ GO_go_status() })
            #

            # start calculation
                Species <- reactiveVal(NULL)
                GO_Database <- reactiveVal(NULL)
                Ontology <- reactiveVal(NULL)
                goResult <- reactiveVal(NULL)
                isCalculating <- reactiveVal(FALSE)
                observeEvent(input$GO_start, {
                    isCalculating(TRUE)

                    # if no input
                        if(length(GO_input_genes()) == 0 || is.null(GO_input_genes())){
                            show_alert(title='Error.',text='Please input the genes for the GO/KEGG analysis.', type='error')
                            GO_go_status('Please input the genes for the GO/KEGG analysis.')
                            Species(NULL)
                            GO_Database(NULL)
                            Ontology(NULL)
                            goResult(NULL)
                            isCalculating(FALSE)
                            return()
                        }
                    #

                    genes <- GO_input_genes()

                    # convert gene symbols to entrezID
                        geneList_ENTREZID <- tryCatch(
                            bitr(genes, fromType="SYMBOL", toType="ENTREZID", OrgDb=ifelse(input$GO_species == "Human", "org.Hs.eg.db", "org.Mm.eg.db"))$ENTREZID,
                            error=function(e){
                                GO_go_status('Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.')
                                show_alert(title='Error.',text='None of the keys entered are valid keys.\nPlease change the input.', type='error')
                                Species(NULL)
                                GO_Database(NULL)
                                Ontology(NULL)
                                goResult(NULL)
                                isCalculating(FALSE)
                                return(NULL)
                            }
                        )

                        if(is.null(geneList_ENTREZID)==TRUE){
                            show_alert(title='Error.',text='None of the keys entered are valid keys.\nPlease change the input.', type='error')
                            GO_go_status('Cannot do the GO/KEGG analysis using the inputted genes.\n None of the keys entered are valid keys.\nPlease change the input.')
                            Species(NULL)
                            GO_Database(NULL)
                            Ontology(NULL)
                            goResult(NULL)
                            isCalculating(FALSE)
                            return(NULL)
                        }
                    #

                    # main part
                        if(input$GO_database == 'GO'){
                            if(input$GO_species == 'Human'){
                                suppressMessages(library(org.Hs.eg.db))
                                df_GO_base = as.data.frame(org.Hs.egGO)
                            }else if(input$GO_species == 'Mouse'){
                                suppressMessages(library(org.Mm.eg.db))
                                df_GO_base = as.data.frame(org.Mm.egGO)
                            }
                            go_gene_universe_list = unique(sort(df_GO_base$gene_id))
                            GO_go_status(NULL)
                            out <- enrichGO(gene = geneList_ENTREZID, universe = go_gene_universe_list, OrgDb = ifelse(input$GO_species == "Human", "org.Hs.eg.db", "org.Mm.eg.db"), ont = input$GO_ontology, pAdjustMethod = "BH", pvalueCutoff = 1, qvalueCutoff = 1, readable = TRUE)

                            if(is.null(out)){
                                show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                                GO_go_status('No significant GO/KEGG term was detected. Please change (or increase) the input.')
                                Species(NULL)
                                GO_Database(NULL)
                                Ontology(NULL)
                                goResult(NULL)
                                isCalculating(FALSE)
                                return(NULL)
                            }else{
                                goResult(out)
                                isCalculating(FALSE)
                                Species(input$GO_species)
                                GO_Database(input$GO_database)
                                Ontology(input$GO_ontology)

                                # tell the users about the setting in a message. Species, database, ontology, number of genes used (after conversion to entrezID).
                                message <- paste0("Species: ", input$GO_species, "\nDatabase: ", input$GO_database, "\nOntology: ", input$GO_ontology, "\nNumber of genes used for the analysis: ", length(geneList_ENTREZID))
                                GO_go_status(message)
                                return(NULL)
                            }
                        }else if(input$GO_database == 'KEGG'){
                            if(input$GO_species == 'Human'){
                                kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'hsa', pvalueCutoff = 1, qvalueCutoff = 1)
                                if(is.null(kk_ORA)){
                                    show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                                    GO_go_status('No significant GO/KEGG term was detected. Please change (or increase) the input.')
                                    Species(NULL)
                                    GO_Database(NULL)
                                    Ontology(NULL)
                                    goResult(NULL)
                                    isCalculating(FALSE)
                                    return(NULL)
                                }else{
                                    GO_go_status(NULL)
                                    kk_ORA <- setReadable(kk_ORA, 'org.Hs.eg.db', 'ENTREZID')
                                    goResult(kk_ORA)
                                    isCalculating(FALSE)
                                    Species(input$GO_species)
                                    GO_Database(input$GO_database)
                                    Ontology(NULL)
                                    message <- paste0("Species: ", input$GO_species, "\nDatabase: ", input$GO_database, "\nNumber of genes used for the analysis: ", length(geneList_ENTREZID))
                                    GO_go_status(message)
                                    return(NULL)
                                }
                            }else if(input$GO_species == 'Mouse'){
                                kk_ORA <- enrichKEGG(gene = geneList_ENTREZID, organism = 'mmu', pvalueCutoff = 1, qvalueCutoff = 1)
                                if(is.null(kk_ORA)){
                                    show_alert(title='Error.',text='Please change (or increase) the input.', type='error')
                                    GO_go_status('No significant GO/KEGG term was detected. Please change (or increase) the input.')
                                    Species(NULL)
                                    GO_Database(NULL)
                                    Ontology(NULL)
                                    goResult(NULL)
                                    isCalculating(FALSE)
                                    return(NULL)
                                }else{
                                    GO_go_status(NULL)
                                    kk_ORA <- setReadable(kk_ORA, 'org.Mm.eg.db', 'ENTREZID')
                                    goResult(kk_ORA)
                                    isCalculating(FALSE)
                                    Species(input$GO_species)
                                    GO_Database(input$GO_database)
                                    Ontology(NULL)
                                    message <- paste0("Species: ", input$GO_species, "\nDatabase: ", input$GO_database, "\nNumber of genes used for the analysis: ", length(geneList_ENTREZID))
                                    GO_go_status(message)
                                    return(NULL)
                                }
                            }
                        }else{
                            show_alert(title='Error.',text='Please select the database correctly..', type='error')
                            GO_go_status('Please select the database (and the ontology) correctly.')
                            goResult(NULL)
                            isCalculating(FALSE)
                            Species(NULL)
                            GO_Database(NULL)
                            Ontology(NULL)
                            return(NULL)
                        }
                    #
                    isCalculating(FALSE)
                })
            #

            # reset
                observeEvent(input$GO_start_reset,{
                    GO_go_status('Please enter inputs and select other settings, and click "Start GO/KEGG Analysis"')
                    Species(NULL)
                    GO_Database(NULL)
                    Ontology(NULL)
                    goResult(NULL)
                })
            #
        #

    ##

    return(list(
        goResult     = goResult,
        isCalculating = isCalculating
    ))
}
