# =============================================================================
# DataOverview - Heatmap: Data
# File: modules/DataOverview/03_03_DataOverview_heatmap_data.R
# Purpose: Handles gene input (manual text, GMT pathway, or custom geneset),
#          sample selection, and expression matrix preparation for the heatmap.
# Edit this file when: changing gene input modes, sample selection logic,
#                       or expression matrix standardisation for the heatmap.
# =============================================================================

heatmap_data_server <- function(input, output, session, df_ex, Custom_geneset) {
    ## Input and Settings ----
        # Gene Input
            # status
                Data_Overview_heatmap_target_gene_type_status <- reactiveVal(NULL)
                output$Data_Overview_heatmap_target_gene_type_status <- renderText({ Data_Overview_heatmap_target_gene_type_status() })
            #

            # select UI
                gsc <- reactiveVal(NULL)
                output$Data_Overview_heatmap_target_select_geneset <- renderUI({
                    if(length(input$Data_Overview_heatmap_target_gene_type) == 0){
                        return(NULL)
                    }

                    # update the gene set selection UI based on the selected gene input type
                    if(input$Data_Overview_heatmap_target_gene_type == 'A'){
                        textAreaInput(session$ns("Data_Overview_heatmap_target_genes"), "Enter genes (line by line)",  placeholder = "GeneA\nGeneB\nGeneC", width = '100%')
                    }else if (input$Data_Overview_heatmap_target_gene_type == 'B') {
                        gene_sets_names <- c(Custom_geneset()$Geneset.name)
                        selectInput(session$ns('Data_Overview_heatmap_target_select_geneset'), 'Select a geneset',  c('None'='None', gene_sets_names))
                    }else if (input$Data_Overview_heatmap_target_gene_type == 'C') {
                        gsc <- getGmt('data/h.all.v2023.2.Hs.symbols.gmt')
                        gsc(gsc)
                        gene_sets_names <- c()
                        for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
                        selectInput(session$ns('Data_Overview_heatmap_target_select_geneset'), 'Select a geneset',  c('None'='None', gene_sets_names))
                    }else if (input$Data_Overview_heatmap_target_gene_type == 'D') {
                        gsc <- getGmt('data/mh.all.v2023.2.Mm.symbols.gmt')
                        gsc(gsc)
                        gene_sets_names <- c()
                        for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
                        selectInput(session$ns('Data_Overview_heatmap_target_select_geneset'), 'Select a geneset',  c('None'='None', gene_sets_names))
                    }else if (input$Data_Overview_heatmap_target_gene_type == 'E'){
                        fluidRow(
                            column(12, fileInput(session$ns("Data_Overview_heatmap_target_upload_custom_pathway"), "Upload a gmt file")),
                            column(12, htmlOutput(session$ns('Data_Overview_heatmap_target_upload_custom_pathway_selection')))
                        )
                    }
                })
            #

            # when a custom gmt file is uploaded, update the selectInput for geneset selection
                output$Data_Overview_heatmap_target_upload_custom_pathway_selection <- renderUI({
                    if(input$Data_Overview_heatmap_target_gene_type == 'E'){
                        tmp <- input$Data_Overview_heatmap_target_upload_custom_pathway
                        if (is.null(tmp)){
                            selectInput(session$ns('Data_Overview_heatmap_target_select_geneset'), 'Select a geneset',  c('--Upload a gmt file first--'='None'))
                        }else{
                            gsc <- getGmt(tmp$datapath)
                            gsc(gsc)
                            gene_sets_names <- c()
                            for ( i in 1:length(gsc)){ gene_sets_names <- c(gene_sets_names, gsc@.Data[[i]]@setName)}
                            selectInput(session$ns('Data_Overview_heatmap_target_select_geneset'), 'Select a geneset',  c('None'='None', gene_sets_names))
                        }
                    }
                })
            #

            # Set up the input genes. Show the number of genes
                Input_genes <- reactiveVal(NULL)
                observe({
                    if(length(input$Data_Overview_heatmap_target_gene_type)==0){
                        Data_Overview_heatmap_target_gene_type_status("Please select one from 'Genes from'.")
                        return(NULL)
                    }

                    # Text input
                    if(input$Data_Overview_heatmap_target_gene_type == 'A'){
                        if(all(grepl("^\\s*$", input$Data_Overview_heatmap_target_genes))){
                            Data_Overview_heatmap_target_gene_type_status('Please enter gene names in the box above, one gene per line.')
                            Input_genes(NULL)
                            return(NULL)
                        }

                        # when there are gene names inputted
                        genes_tmp <- unique(unlist(strsplit(input$Data_Overview_heatmap_target_genes, split="\n")))
                        genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names

                        # check if genes are included in the data
                        genes_tmp_found <- genes_tmp[genes_tmp %in% df_ex()$id]
                        genes_tmp_notfound <- genes_tmp[!(genes_tmp %in% df_ex()$id)]
                        if(length(genes_tmp_found) == 0){
                            Data_Overview_heatmap_target_gene_type_status('None of the inputted genes are in the data. Please check your gene names and try again.')
                            Input_genes(NULL)
                            return(NULL)
                        }
                        if(length(genes_tmp_notfound) != 0){
                            message <- paste0("\n\nThe following inputted gene(s) are not found in the data and will be ignored: \n", paste(genes_tmp_notfound, collapse = ", "))
                        }else{
                            message <- NULL
                        }

                        Input_genes(genes_tmp_found)
                        Data_Overview_heatmap_target_gene_type_status(paste0("You have input ", length(Input_genes()), " gene(s).", message))
                        return(NULL)
                    }

                    # Custom Gene Set
                    if(input$Data_Overview_heatmap_target_gene_type == 'B'){
                        if(length(input$Data_Overview_heatmap_target_select_geneset) == 0 || input$Data_Overview_heatmap_target_select_geneset == 'None'){
                            Data_Overview_heatmap_target_gene_type_status("Please select a custom geneset above first.")
                            Input_genes(NULL)
                            return(NULL)
                        }else{
                            # check if the geneset is included
                            if(input$Data_Overview_heatmap_target_select_geneset %in% Custom_geneset()$Geneset.name){
                                genes_tmp <- strsplit(Custom_geneset()[Custom_geneset()$Geneset.name %in% input$Data_Overview_heatmap_target_select_geneset, ]$Genes, split=', ')[[1]]
                                genes_tmp_found <- genes_tmp[genes_tmp %in% df_ex()$id]
                                genes_tmp_notfound <- genes_tmp[!(genes_tmp %in% df_ex()$id)]
                                if(length(genes_tmp_found) == 0){
                                    Data_Overview_heatmap_target_gene_type_status('None of the inputted genes are in the data. Please check your gene names and try again.')
                                    Input_genes(NULL)
                                    return(NULL)
                                }
                                if(length(genes_tmp_notfound) != 0){
                                    message <- paste0("\n\nThe following inputted gene(s) are not found in the data and will be ignored: \n", paste(genes_tmp_notfound, collapse = ", "))
                                }else{
                                    message <- NULL
                                }
                                Input_genes(genes_tmp_found)
                                Data_Overview_heatmap_target_gene_type_status(paste0("You have input ", length(Input_genes()), " genes from your selected custom geneset.", message))
                                return(NULL)
                            }else{
                                Input_genes(NULL)
                                return(NULL)
                            }
                        }
                    }

                    # HALLMARK/GMT gene set
                    if(input$Data_Overview_heatmap_target_gene_type == 'C' || input$Data_Overview_heatmap_target_gene_type == 'D' || input$Data_Overview_heatmap_target_gene_type == 'E'){
                        if(length(input$Data_Overview_heatmap_target_select_geneset) == 0 || input$Data_Overview_heatmap_target_select_geneset == 'None'){
                            Data_Overview_heatmap_target_gene_type_status("Please select a geneset above first.")
                            Input_genes(NULL)
                            return(NULL)
                        }else{
                            # check if the geneset is included
                            if(input$Data_Overview_heatmap_target_select_geneset %in% names(gsc())){
                                genes_tmp <- gsc()[[input$Data_Overview_heatmap_target_select_geneset]]@geneIds
                                genes_tmp_found <- genes_tmp[genes_tmp %in% df_ex()$id]
                                genes_tmp_notfound <- genes_tmp[!(genes_tmp %in% df_ex()$id)]
                                if(length(genes_tmp_found) == 0){
                                    Data_Overview_heatmap_target_gene_type_status('None of the inputted genes are in the data. Please check your gene names and try again.')
                                    Input_genes(NULL)
                                    return(NULL)
                                }
                                if(length(genes_tmp_notfound) != 0){
                                    message <- paste0("\n\nThe following inputted gene(s) are not found in the data and will be ignored: \n", paste(genes_tmp_notfound, collapse = ", "))
                                }else{
                                    message <- NULL
                                }
                                Input_genes(genes_tmp_found)
                                Data_Overview_heatmap_target_gene_type_status(paste0("You have input ", length(Input_genes()), " genes from your selected geneset.", message))
                                return(NULL)
                            }else{
                                Input_genes(NULL)
                                return(NULL)
                            }
                        }
                    }

                })
            #
        #

        # Sample Input UI
            # status
                Data_Overview_heatmap_sample_table_status <- reactiveVal(NULL)
                output$Data_Overview_heatmap_sample_table_status <- renderText({ Data_Overview_heatmap_sample_table_status() })
            #

            # sample table
                Data_Overview_heatmap_sample_table_tmp <- reactiveVal(NULL)
                observe({
                    if(is.null(df_ex())){
                        Data_Overview_heatmap_sample_table_tmp(NULL)
                        return(NULL)
                    }else{
                        samples <- colnames(df_ex())[!(colnames(df_ex())=='id')]
                        Data_Overview_heatmap_sample_table_tmp(data.frame(Sample_name=samples[order(samples)]))
                    }
                })
            #

            # show the sample table for selection
                output$Data_Overview_heatmap_sample_table <- renderDataTable({
                    datatable( Data_Overview_heatmap_sample_table_tmp(), selection='none', extensions=c('Select', 'Buttons', 'Scroller', 'RowReorder'),
                        options = list(
                            select=list(style="multi", items='row'), rowReorder = TRUE, order = list(c(0 , 'asc')),
                            scroller=TRUE, deferRender=TRUE, scrollY=200,
                            dom='Blfrtip', buttons=c('selectAll', 'selectNone'), pageLength = 10)
                        )
                },server = FALSE)
            #

            # Sample selection
                Selected_samples <- reactiveVal(NULL)
                observe({
                    # when no sample table
                    if(is.null(Data_Overview_heatmap_sample_table_tmp())){
                        Selected_samples(NULL)
                        Data_Overview_heatmap_sample_table_status("No sample is available for selection. Please check your input data.")
                        return(NULL)
                    }

                    # when sample table is available but no sample is selected
                    if(length(input$Data_Overview_heatmap_sample_table_rows_selected) == 0){
                        Selected_samples(NULL)
                        Data_Overview_heatmap_sample_table_status("Please select samples from the table below.")
                        return(NULL)
                    }

                    # when sample(s) is selected, show the number of selected samples
                    selected_samples <- Data_Overview_heatmap_sample_table_tmp()[input$Data_Overview_heatmap_sample_table_rows_selected, ,drop=FALSE ]$Sample_name
                    Selected_samples(selected_samples)
                    Data_Overview_heatmap_sample_table_status(paste0(length(Selected_samples()), " sample(s) selected."))
                    return(NULL)

                })
            #
        #
    ##

    ## Heatmap calculation
        # status
            Data_Overview_heatmap_status <- reactiveVal('Please enter/choose inputs and select the samples, and click "Generate a heatmap"\nA heatmap showing the standardised expression of the selected genes across the selected samples will be generated here.')
            output$Data_Overview_heatmap_status <- renderText({ Data_Overview_heatmap_status() })
        #

        # function for standardise the table
            sd_table <- function(df_ex){
              for (key in colnames(df_ex)){
                  tmp <- df_ex[,key] - mean(df_ex[,key])
                  tmp <- tmp/sd(tmp)
                  df_ex[,key] <- tmp
              }
              return(df_ex)
            }
        #

        # heatmap table
            ex_datafreme_for_heatmap <- reactiveVal(NULL)
            isCalculating <- reactiveVal(FALSE)
            Input_genes_used <- reactiveVal(NULL)
            observeEvent(input$Gene_Overview_heatmap_start, {
                isCalculating(TRUE)
                df_ex <- df_ex()
                # gene -> Input_genes(), sample -> Selected_samples()

                # when no gene is inputted
                    if(length(Input_genes()) == 0){
                        show_alert(title='Error.',text='Please enter/choose input genes.', type='error')
                        Data_Overview_heatmap_status('Please enter/choose input genes.')
                        ex_datafreme_for_heatmap(NULL)
                        isCalculating(FALSE)
                        Input_genes_used(NULL)
                        return()
                    }
                #

                # extract the target genes
                    Input_genes <- Input_genes()

                # if the input genes are not in the data, show error
                    if(length(df_ex$id[df_ex$id %in% Input_genes]) == 0){
                        show_alert(title='Error.',text='None of the inputted genes are in the data.', type='error')
                        Data_Overview_heatmap_status('None of the inputted genes are in the data.')
                        ex_datafreme_for_heatmap(NULL)
                        isCalculating(FALSE)
                        Input_genes_used(NULL)
                        return()
                    }
                #


                # when no sample is selected
                    if(length(Selected_samples()) == 0){
                        show_alert(title='Error.',text='Please select one or more samples.', type='error')
                        Data_Overview_heatmap_status('Please select one or more samples.')
                        ex_datafreme_for_heatmap(NULL)
                        isCalculating(FALSE)
                        Input_genes_used(NULL)
                        return()
                    }
                #

                # when only one sample is selected
                    if(length(Selected_samples()) == 1){
                        show_alert(title='Error.',text='Please select at least two samples.', type='error')
                        Data_Overview_heatmap_status('Please select at least two samples.')
                        ex_datafreme_for_heatmap(NULL)
                        isCalculating(FALSE)
                        Input_genes_used(NULL)
                        return()
                    }
                #

                selected_samples <- Selected_samples()

                # extract the genes and selected samples for heatmap
                    df_ex <- df_ex[df_ex$id %in% Input_genes,]
                    desired_order <- Input_genes
                    desired_order <- desired_order[desired_order %in% df_ex$id]
                    df_ex <- df_ex[df_ex$id %in% desired_order, ]
                    df_ex <- df_ex[match(desired_order, df_ex$id), ]
                #

                # when there are duplicated id, add sufix of .1, .2...
                    if(any(duplicated(df_ex$id))){
                        dup_ids <- df_ex$id[duplicated(df_ex$id)]
                        for(dup_id in dup_ids){
                            rows <- which(df_ex$id == dup_id)
                            for(i in 1:length(rows)){
                                if(i == 1){
                                next
                                }else{
                                df_ex$id[rows[i]] <- paste0(df_ex$id[rows[i]], '.', i-1)
                                }
                            }
                        }
                    }
                    rownames(df_ex) <- df_ex$id
                #

                # standerdise
                    df_ex <- df_ex[, -which(colnames(df_ex) == "id")]
                    df_ex <- df_ex[,selected_samples]
                    df_ex <- data.frame(t(df_ex))
                    # standardise
                    df_ex <- sd_table(df_ex)
                    df_ex <- df_ex %>% select_if(~ !any(is.na(.)))
                    ex_datafreme_for_heatmap(df_ex)
                    Input_genes_used(Input_genes)
                    isCalculating(FALSE)
                    Data_Overview_heatmap_status(NULL)
                    return()
                #


            })

        #

    ##

    return(list(
        ex_datafreme_for_heatmap = ex_datafreme_for_heatmap,
        Input_genes_used = Input_genes_used,
        isCalculating = isCalculating,
        Data_Overview_heatmap_status = Data_Overview_heatmap_status
    ))
}
