# =============================================================================
# Clinical - Deconvolution: Association with Mutations (Calculation)
# File: modules/Clinical/08_clinical_Deconvolution_mutation_calc.R
# Purpose: Handles gene input and cell-type selection, splits samples into
#          Mutant / WT groups for each input gene, and compares the estimated
#          abundance of the selected cell type between the two groups
#          (Wilcoxon rank-sum test).
#          Samples used = all samples in the deconvolution result. A sample
#          without any reported mutation in a gene is treated as WT (same as
#          the Mutation Analysis module).
# Edit this file when: changing the Mutant/WT definition, the statistical test,
#                      or the gene / cell-type input logic for this tab.
# =============================================================================

deconvolution_mutation_calc_server <- function(input, output, session, deconv_table, Mutation_data, Custom_genesets) {

    ## Input genes ----
        Mutation_input_gene <- reactiveVal(NULL)

        # status
            Deconvolution_Mutation_genes_status <- reactiveVal(NULL)
            output$Deconvolution_Mutation_genes_status <- renderText({ Deconvolution_Mutation_genes_status() })
        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$Deconvolution_Mutation_genes <- renderUI({ textAreaInput(session$ns("Deconvolution_Mutation_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$Deconvolution_Mutation_from_custom_geneset) > 0 && input$Deconvolution_Mutation_from_custom_geneset == TRUE){
                    shinyjs::disable("Deconvolution_Mutation_genes")
                } else {
                    shinyjs::enable("Deconvolution_Mutation_genes")
                }
            })
        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$Deconvolution_Mutation_from_custom_geneset_select <- renderUI({
                if(length(input$Deconvolution_Mutation_from_custom_geneset) > 0 && input$Deconvolution_Mutation_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets()$Geneset.name)
                    selectInput(session$ns('Deconvolution_Mutation_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })
        #

        # Set the input genes
            observe({
                if(length(input$Deconvolution_Mutation_genes) == 0 || length(input$Deconvolution_Mutation_from_custom_geneset) == 0){
                    Mutation_input_gene(NULL)
                    Deconvolution_Mutation_genes_status(NULL)
                    return(NULL)
                }else if(input$Deconvolution_Mutation_from_custom_geneset == FALSE){
                    # custom select: off -> manual

                    if(all(grepl("^\\s*$", input$Deconvolution_Mutation_genes))){
                        Deconvolution_Mutation_genes_status('Please enter gene names in the box above, one gene per line.')
                        Mutation_input_gene(NULL)
                        return(NULL)
                    }

                    # when there are gene names inputted
                    genes_tmp <- unique(unlist(strsplit(input$Deconvolution_Mutation_genes, split="\n")))
                    genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                    Mutation_input_gene(genes_tmp)
                    Deconvolution_Mutation_genes_status(paste0("You have manually input ", length(Mutation_input_gene()), " gene(s)."))

                }else if(input$Deconvolution_Mutation_from_custom_geneset == TRUE){
                    # custom select: on -> custom geneset
                    if(length(input$Deconvolution_Mutation_from_custom_geneset_select) == 0 || input$Deconvolution_Mutation_from_custom_geneset_select == 'None'){
                        Deconvolution_Mutation_genes_status("Please select a custom geneset above first.")
                        Mutation_input_gene(NULL)
                        return(NULL)
                    }

                    genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% input$Deconvolution_Mutation_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                    Mutation_input_gene(genes)
                    Deconvolution_Mutation_genes_status(paste0("You have input ", length(Mutation_input_gene()), " gene(s) from your selected custom geneset."))

                }
            })
        #
    ##

    ## Select a cell type ----
        output$Deconvolution_Mutation_select_celltype <- renderUI({
            if(is.null(deconv_table())){
                selectInput(session$ns('Deconvolution_Mutation_select_celltype'), 'Select a Cell type',  c('--Run deconvolution first--'='None'))
            }else{
                celltype_names <- rownames(deconv_table())
                selectInput(session$ns('Deconvolution_Mutation_select_celltype'), 'Select a Cell type',  c('None'='None', celltype_names))
            }
        })
    ##

    ## Compare the abundance between Mutant and WT ----
        # status
            Deconvolution_Mutation_status0 <- reactiveVal('Please set the input genes and the cell type, and click \'Start comparing\'.')
            output$Deconvolution_Mutation_status0 <- renderText({ Deconvolution_Mutation_status0() })

            # shown above the result table (genes without mutated / WT samples)
            Deconvolution_Mutation_table_note <- reactiveVal(NULL)
            output$Deconvolution_Mutation_table_note <- renderText({ Deconvolution_Mutation_table_note() })
        #

        # start
            isCalculating_Deconvolution_mutation <- reactiveVal(FALSE)
            Deconvolution_mutation_result <- reactiveVal(NULL)
            Deconvolution_mutation_plot_info <- reactiveVal(NULL)
            observeEvent(input$Deconvolution_Mutation_start, {
                isCalculating_Deconvolution_mutation(TRUE)
                Deconvolution_mutation_result(NULL)
                Deconvolution_mutation_plot_info(NULL)
                Deconvolution_Mutation_table_note(NULL)
                updateMaterialSwitch(session, 'Deconvolution_Mutation_split_by_type', value = FALSE)

                # when no deconv table
                    if(is.null(deconv_table())){
                        show_alert(title='Error.', text='Please do the deconvolution first.', type='error')
                        Deconvolution_Mutation_status0("Please do the deconvolution first.")
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                    deconv_table <- deconv_table()
                #

                # when no mutation data
                    if(is.null(Mutation_data())){
                        show_alert(title='Error.', text='No mutation data is available for this dataset.', type='error')
                        Deconvolution_Mutation_status0("No mutation data is available for this dataset.")
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                    df_mut <- Mutation_data()
                #

                # when no cell type is selected
                    if(length(input$Deconvolution_Mutation_select_celltype) == 0 || input$Deconvolution_Mutation_select_celltype == 'None'){
                        show_alert(title='Error.', text='Please select a cell type.', type='error')
                        Deconvolution_Mutation_status0("Please select a cell type.")
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                    cell_type <- input$Deconvolution_Mutation_select_celltype
                #

                # when no gene is inputted
                    if(is.null(Mutation_input_gene()) || length(Mutation_input_gene()) == 0){
                        show_alert(title='Error.', text='Please input genes or select a custom gene set.', type='error')
                        Deconvolution_Mutation_status0("Please input genes or select a custom gene set.")
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                    genes <- Mutation_input_gene()
                #

                # all the samples in the deconvolution result. Samples without a reported mutation in a gene are WT.
                    samples_used <- colnames(deconv_table)

                    # when no sample name in the mutation data matches the deconvolution result, the sample names are probably in a different format
                    if(length(intersect(samples_used, unique(df_mut$sample))) == 0){
                        show_alert(title='Error.', text='No sample is shared between the deconvolution result and the mutation data. Please check the sample names.', type='error')
                        Deconvolution_Mutation_status0("No sample is shared between the deconvolution result and the mutation data. \nPlease check if the sample names in the mutation data match those in the gene expression data.")
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                    abundance <- as.numeric(unlist(deconv_table[cell_type, samples_used, drop=TRUE]))
                    names(abundance) <- samples_used
                #

                # Do test (Wilcoxon rank-sum test, Mutant vs WT)
                    no_mut_genes <- c()
                    no_wt_genes <- c()
                    df_test <- tryCatch({
                        df_test <- data.frame('Gene'=c(), 'N_Mutant'=c(), 'N_WT'=c(), 'Statistic (Wilcoxon)'=c(), 'P.value'=c(), check.names=FALSE)
                        for (gene in genes){ # gene = 'KIT'
                            mut_samples <- intersect(unique(df_mut[df_mut$id == gene, ]$sample), samples_used)
                            wt_samples <- setdiff(samples_used, mut_samples)
                            if(length(mut_samples) == 0){
                                no_mut_genes <- c(no_mut_genes, gene)
                                next
                            }
                            if(length(wt_samples) == 0){
                                no_wt_genes <- c(no_wt_genes, gene)
                                next
                            }
                            df_test_tmp <- wilcox.test(abundance[mut_samples], abundance[wt_samples])
                            tmp <- data.frame('Gene'=gene, 'N_Mutant'=length(mut_samples), 'N_WT'=length(wt_samples), 'Statistic (Wilcoxon)'=unname(df_test_tmp$statistic), 'P.value'=df_test_tmp$p.value, check.names=FALSE)
                            df_test <- rbind(df_test, tmp)
                        }
                        df_test
                    }, error = function(e){
                        show_alert(title='Error.', text=paste0('An error occurred while running the statistical test: ', conditionMessage(e)), type='error')
                        Deconvolution_Mutation_status0(paste0('An error occurred while running the statistical test: ', conditionMessage(e)))
                        NULL
                    })
                    if(is.null(df_test)){
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                #

                # when none of the genes have mutated (or WT) samples, show the message and do not return the table
                    if(nrow(df_test) == 0){
                        message <- paste0("None of the input genes could be compared, because there is no mutated sample for these genes among the ", length(samples_used), " sample(s) in the deconvolution result. \nThis could be because the gene names you inputted are wrong or no mutation was reported in the samples for these genes.")
                        if(length(no_wt_genes) > 0){
                            message <- paste0(message, "\n\nThere is no wild type sample for the following gene(s): ", paste(no_wt_genes, collapse=', '), ".")
                        }
                        show_alert(title='Error.', text='None of the input genes have both mutated and wild type samples. Please check your input genes or data.', type='error')
                        Deconvolution_Mutation_status0(message)
                        isCalculating_Deconvolution_mutation(FALSE)
                        return(NULL)
                    }
                #

                # sort by p value
                    df_test <- df_test[order(df_test$`P.value`),]
                    rownames(df_test) <- NULL
                #

                # the genes that could not be tested (shown above the table)
                    note <- NULL
                    if(length(no_mut_genes) > 0){
                        note <- paste0("No mutated samples were found for the following ", length(no_mut_genes), " gene(s): \n", paste(no_mut_genes, collapse=', '), ".")
                    }
                    if(length(no_wt_genes) > 0){
                        note <- paste0(c(note, paste0("No wild type samples were found for the following ", length(no_wt_genes), " gene(s): \n", paste(no_wt_genes, collapse=', '), ".")), collapse='\n')
                    }
                    Deconvolution_Mutation_table_note(note)
                #

                # status
                    message <- paste0(
                        "The abundance of ", cell_type, " was compared between mutant and wild type (WT) samples for ", nrow(df_test), " gene(s). \n",
                        "All the ", length(samples_used), " sample(s) in the deconvolution result were used. Samples without a reported mutation in a gene are treated as WT. \n",
                        "The test used is the Wilcoxon rank-sum test."
                    )
                    if(length(no_mut_genes) + length(no_wt_genes) > 0){
                        message <- paste0(message, "\n\n", length(no_mut_genes) + length(no_wt_genes), " gene(s) could not be compared. See the note above the result table.")
                    }
                    Deconvolution_Mutation_status0(message)
                    Deconvolution_mutation_result(df_test)
                    Deconvolution_mutation_plot_info(list(cell_type=cell_type, abundance=abundance, samples_used=samples_used))
                    isCalculating_Deconvolution_mutation(FALSE)
                    return(NULL)
                #
            })
        #
    ##

    # Return reactive values needed by plot server
    list(
        Deconvolution_mutation_result        = Deconvolution_mutation_result,
        isCalculating_Deconvolution_mutation = isCalculating_Deconvolution_mutation,
        Deconvolution_mutation_plot_info     = Deconvolution_mutation_plot_info
    )
}
