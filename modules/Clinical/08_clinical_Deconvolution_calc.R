# =============================================================================
# Clinical - Deconvolution: Calculation
# File: modules/Clinical/08_clinical_Deconvolution_calc.R
# Purpose: Runs the selected deconvolution method (MCPcounter / xCell) on the
#          gene expression matrix and computes gene-to-cell-type correlations.
#          Manages sample/cell-type selection and sample filtering logic.
# Edit this file when: adding a new deconvolution method, changing the
#                      correlation computation, or modifying sample filtering.
# =============================================================================

deconvolution_calc_server <- function(input, output, session, Gene_expression, Survival, Meta_data, Custom_genesets) {

    ## Deconvolution ----
        # initial setting message
            Deconvolution_status <- reactiveVal('Please select the dataset and the deconvolution method, and click \'Start deconvolution\'.')
            output$Deconvolution_status <- renderText({Deconvolution_status()})
        #

        # Run deconvolution
            deconv_table <- reactiveVal(NULL)
            isCalculating_deconv_table <- reactiveVal(FALSE)
            observeEvent(input$Deconvolution_start,{
                isCalculating_deconv_table(TRUE)
                if(input$Clinical_data_select == 'None'){
                    show_alert(title='Error.', text='Please select a dataset first.', type='error')
                    Deconvolution_status('Please select a dataset first.')
                    deconv_table(NULL)
                    isCalculating_deconv_table(FALSE)
                    return(NULL)
                }
                if(length(input$Deconvolution_tool_select)==0){
                    show_alert(title='Error.', text='Please select the deconvolution method.', type='error')
                    Deconvolution_status('Please select the method.')
                    deconv_table(NULL)
                    isCalculating_deconv_table(FALSE)
                    return(NULL)
                }
                Deconvolution_status(NULL)
                df_geneEx <-  Gene_expression()
                if(input$Deconvolution_tool_select == 'MCPcounter'){
                    deconv_table_tmp <-  MCPcounter.estimate(df_geneEx,featuresType="HUGO_symbols")
                }else if(input$Deconvolution_tool_select == 'xCell'){
                    deconv_table_tmp <- xCellAnalysis(df_geneEx) # deconv_table[1:3, 1:3]
                }
                deconv_table(deconv_table_tmp)
                isCalculating_deconv_table(FALSE)
                return(NULL)
            })
        #

        # table
            output$Deconvolution_results <- renderDataTable({
                if(isCalculating_deconv_table()){
                    Deconvolution_status('Calculating...')
                    tmp <- data.frame('Cell type'=character(0), 'Sample'=character(0), 'Abundance'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
                }
                if(is.null(deconv_table())){
                    tmp <- data.frame('Cell type'=character(0), 'Sample'=character(0), 'Abundance'=numeric(0), stringsAsFactors = FALSE)
                    return(datatable(tmp, selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
                }else{
                    return(datatable(deconv_table(), selection = list(mode='single'), options = list(scrollX = TRUE, pageLength = 10)))
                }
            })
        #

        # table download
            output$Deconvolution_result_download <- downloadHandler(
            filename = function(){"deconvolution.tsv"},
            content = function(fname){ write.table(deconv_table(), fname, sep='\t', row.names=F, quote=F) }
            )
        #

    ##

    ## Heatmap/barplot inputs - sample and cell-type selection
        # ui
            # sample selection, group by drop-down menu
                output$Deconvolution_Heatmap_sample_selection_meta_data <- renderUI({
                    if(input$Deconvolution_Heatmap_sample_selection == 'B'){
                        selectInput(session$ns('Deconvolution_Heatmap_sample_selection_meta_data'), 'Filtering by:', c('None'='None', colnames(Meta_data())))
                    }else{
                        NULL
                    }
                })
            #

            # category selection drop-down menu
                output$Deconvolution_Heatmap_sample_selection_meta_data_group <- renderUI({
                    if(input$Deconvolution_Heatmap_sample_selection == 'B'){
                        if(length(input$Deconvolution_Heatmap_sample_selection_meta_data) == 0 || input$Deconvolution_Heatmap_sample_selection_meta_data == 'None'){
                            category_tmp <- c('None')
                        }else{
                            meta_tmp <- Meta_data()[,input$Deconvolution_Heatmap_sample_selection_meta_data]
                            category_tmp <- c('None', unique(meta_tmp))
                        }
                        selectInput(session$ns('Deconvolution_Heatmap_sample_selection_meta_data_group'), 'Select a category', c(category_tmp), selected='None')
                    }else{
                        NULL
                    }
                })
            #

            # when text input
                output$Deconvolution_Heatmap_sample_selection_text_input <- renderUI({
                    if(input$Deconvolution_Heatmap_sample_selection == 'C'){
                        textAreaInput(session$ns('Deconvolution_Heatmap_sample_selection_text_input'), 'Enter sample IDs (line by line)', width='100%', height='100px', placeholder = "SampleA\nSampleB\nSampleC",)
                    }else{
                        NULL
                    }
                })
            #

            # cell type selection
                output$Deconvolution_Heatmap_celltype_selection_table <- renderDataTable({
                    if(input$Deconvolution_Heatmap_celltype_selection == 'B'){
                        if(is.null(deconv_table())){
                            # show a message to ask users to run deconvolution first
                            celltype_df_tmp <- data.frame(Message='Please run deconvolution first to see the cell type list.', stringsAsFactors = FALSE)
                            datatable( celltype_df_tmp, selection='none')
                        }else{
                            celltype_df_tmp <- data.frame(CellType=rownames(deconv_table()), stringsAsFactors = FALSE)
                            datatable( celltype_df_tmp, selection='none', extensions=c('Select', 'Buttons', 'Scroller'), rownames=F,
                                options = list(
                                select=list(style="multi", items='row'),
                                scroller=TRUE, deferRender=TRUE, scrollY=200,
                                dom='Blfrtip', buttons=c('selectAll', 'selectNone'), pageLength = 5))
                        }

                    }else{
                        NULL
                    }
                },server = FALSE)
            #

        #

        # Input samples
            # status
                Deconvolution_Heatmap_sample_selection_meta_data_status <- reactiveVal(NULL)
                output$Deconvolution_Heatmap_sample_selection_meta_data_status <- renderText({Deconvolution_Heatmap_sample_selection_meta_data_status()})
            #

            # show the number and set the input samples
                Input_samples <- reactiveVal(NULL)
                observe({
                    # deconvolution is not yet run
                        if(is.null(deconv_table())){
                            Deconvolution_Heatmap_sample_selection_meta_data_status('Run deconvolution first.')
                            return(NULL)
                        }
                    #

                    # All samples
                        if(input$Deconvolution_Heatmap_sample_selection == 'A'){
                            Deconvolution_Heatmap_sample_selection_meta_data_status(paste0('All samples are selected. (', ncol(deconv_table()), ' samples)'))
                            Input_samples(colnames(deconv_table()))
                            return(NULL)
                        }
                    #

                    # Text input
                        if(input$Deconvolution_Heatmap_sample_selection == 'C'){
                            if(is.null(input$Deconvolution_Heatmap_sample_selection_text_input) || input$Deconvolution_Heatmap_sample_selection_text_input == ''){
                                Deconvolution_Heatmap_sample_selection_meta_data_status('Please enter sample IDs.')
                                return(NULL)
                            }else{
                                sample_input <- unlist(strsplit(input$Deconvolution_Heatmap_sample_selection_text_input, split='\n'))
                                sample_input <- gsub(' ', '', sample_input) # remove spaces
                                sample_input <- sample_input[sample_input != ''] # remove empty strings
                                n_sample_selected <- sum(sample_input %in% colnames(deconv_table()))
                                if(n_sample_selected == 0){
                                    Deconvolution_Heatmap_sample_selection_meta_data_status('No matching sample ID found. Please check your input.')
                                    return(NULL)
                                }
                                Deconvolution_Heatmap_sample_selection_meta_data_status(paste0(n_sample_selected, ' samples are selected.'))
                                Input_samples(sample_input[sample_input %in% colnames(deconv_table())])
                                return(NULL)
                            }
                        }
                    #

                    # from metadata
                        meta_data <- Meta_data()
                        if(input$Deconvolution_Heatmap_sample_selection == 'B'){
                            if(length(input$Deconvolution_Heatmap_sample_selection_meta_data) == 0 || input$Deconvolution_Heatmap_sample_selection_meta_data == 'None'){
                                Deconvolution_Heatmap_sample_selection_meta_data_status('Please select a metadata column for filtering.')
                                return(NULL)
                            }else if(length(input$Deconvolution_Heatmap_sample_selection_meta_data_group ) == 0 || input$Deconvolution_Heatmap_sample_selection_meta_data_group == 'None' ){
                                Deconvolution_Heatmap_sample_selection_meta_data_status('Please select a category for filtering.')
                                return(NULL)
                            }else{
                                selected_category <- input$Deconvolution_Heatmap_sample_selection_meta_data_group
                                n_sample_selected <- sum(meta_data[,input$Deconvolution_Heatmap_sample_selection_meta_data] == selected_category)
                                if(n_sample_selected == 0){
                                    Deconvolution_Heatmap_sample_selection_meta_data_status('No matching sample found. Please check your selection.')
                                    return(NULL)
                                }
                                Deconvolution_Heatmap_sample_selection_meta_data_status(paste0(n_sample_selected, ' samples are selected.'))
                                Input_samples(meta_data[meta_data[,input$Deconvolution_Heatmap_sample_selection_meta_data] == selected_category,]$sample)
                                return(NULL)
                            }
                        }
                    #



                })
            #

            # input cell type
                Input_celltypes <- reactiveVal(NULL)
                observe({
                    if(is.null(deconv_table())){
                        Input_celltypes(NULL)
                        return(NULL)
                    }
                    if(input$Deconvolution_Heatmap_celltype_selection == 'A'){
                        Input_celltypes(rownames(deconv_table()))
                        return(NULL)
                    }else if(input$Deconvolution_Heatmap_celltype_selection == 'B'){
                        if(length(input$Deconvolution_Heatmap_celltype_selection_table_rows_selected) == 0){
                            Input_celltypes(NULL)
                            return(NULL)
                        }else{
                            Input_celltypes(rownames(deconv_table())[input$Deconvolution_Heatmap_celltype_selection_table_rows_selected])
                            return(NULL)
                        }
                    }else{
                        Input_celltypes(NULL)
                        return(NULL)
                    }
                })
            #
        #

        # plot data preparation (long format for heatmap/barplot)
            # status
                Deconvolution_plot_status <- reactiveVal(NULL)
                output$Deconvolution_plot_status <- renderText({Deconvolution_plot_status()})
            #

            # start
                deconv_long <- reactiveVal(NULL)
                isCalculating_deconv_long <- reactiveVal(FALSE)
                observeEvent(input$Deconvolution_Heatmap_start,{
                    isCalculating_deconv_long(TRUE)
                    deconv_table_tmp <- deconv_table()

                    # cell type selection
                    if(length(Input_celltypes()) == 0 || is.null(Input_celltypes())){
                        show_alert(title='Error.', text='Please select at least one cell type.', type='error')
                        Deconvolution_plot_status('Please select at least one cell type.')
                        deconv_long(NULL)
                        isCalculating_deconv_long(FALSE)
                        return(NULL)
                    }
                    Selected_celltypes <- Input_celltypes()

                    # sample selection
                    if(length(Input_samples()) == 0 || is.null(Input_samples())){
                        show_alert(title='Error.', text='Please select at least one sample.', type='error')
                        Deconvolution_plot_status('Please select at least one sample.')
                        deconv_long(NULL)
                        isCalculating_deconv_long(FALSE)
                        return(NULL)
                    }
                    Selected_samples <- Input_samples()

                    # clustering
                    d <- dist(t(deconv_table_tmp[,intersect(colnames(deconv_table_tmp), Selected_samples), drop = FALSE]))  # clustering
                    hc <- hclust(d)
                    ordered_samples <- hc$labels[hc$order]

                    deconv_mat <- as.matrix(deconv_table_tmp)
                    deconv_mat <- deconv_mat[Selected_celltypes, ordered_samples, drop = FALSE] # Selected_celltypes <- 'T cells'
                    cell_types <- rownames(deconv_mat)
                    samples <- colnames(deconv_mat)
                    df_long <- expand.grid(CellType = cell_types, Sample = samples)
                    df_long$Score <- as.vector(deconv_mat)
                    df_long$Sample <- factor(df_long$Sample, levels = rev(ordered_samples))  # ggplotでは下から上なのでrev()
                    deconv_long(df_long)
                    isCalculating_deconv_long(FALSE)
                    return(NULL)
                })
            #
        #
    ##

    ## Correlation with genes - gene input, cell type selection, filtering, computation
        # Input genes
            Correlation_gene <- reactiveVal(NULL)

            # status
                Deconvolution_Gene_correlation_genes_status <- reactiveVal(NULL)
                output$Deconvolution_Gene_correlation_genes_status <- renderText({ Deconvolution_Gene_correlation_genes_status() })
            #

            # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
                output$Deconvolution_Gene_correlation_genes <- renderUI({ textAreaInput(session$ns("Deconvolution_Gene_correlation_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
                observe({
                    if(length(input$Deconvolution_Gene_correlation_from_custom_geneset) > 0 && input$Deconvolution_Gene_correlation_from_custom_geneset == TRUE){
                        shinyjs::disable("Deconvolution_Gene_correlation_genes")
                    } else {
                        shinyjs::enable("Deconvolution_Gene_correlation_genes")
                    }
                })

            #

            # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
                output$Deconvolution_Gene_correlation_from_custom_geneset_select <- renderUI({
                    if(length(input$Deconvolution_Gene_correlation_from_custom_geneset) > 0 && input$Deconvolution_Gene_correlation_from_custom_geneset == TRUE){
                        gene_sets_names <- c(Custom_genesets$Geneset.name)
                        selectInput(session$ns('Deconvolution_Gene_correlation_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                    } else {
                        return(NULL)
                    }
                })

            #

            # Set the input genes
                observe({
                    if(length(input$Deconvolution_Gene_correlation_genes) == 0 || length(input$Deconvolution_Gene_correlation_from_custom_geneset) == 0){
                        Correlation_gene(NULL)
                        Deconvolution_Gene_correlation_genes_status(NULL)
                        return(NULL)
                    }else if(input$Deconvolution_Gene_correlation_from_custom_geneset == FALSE){
                        # custom select: off -> manual

                        if(all(grepl("^\\s*$", input$Deconvolution_Gene_correlation_genes))){
                            Deconvolution_Gene_correlation_genes_status('Please enter gene names in the box above, one gene per line.')
                            Correlation_gene(NULL)
                            return(NULL)
                        }

                        # when there are gene names inputted
                        genes_tmp <- unique(unlist(strsplit(input$Deconvolution_Gene_correlation_genes, split="\n")))
                        genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                        Correlation_gene(genes_tmp)
                        Deconvolution_Gene_correlation_genes_status(paste0("You have manually input ", length(Correlation_gene()), " gene(s)."))

                    }else if(input$Deconvolution_Gene_correlation_from_custom_geneset == TRUE){
                        # custom select: on -> custom geneset
                        if(length(input$Deconvolution_Gene_correlation_from_custom_geneset_select) == 0 || input$Deconvolution_Gene_correlation_from_custom_geneset_select == 'None'){
                            Deconvolution_Gene_correlation_genes_status("Please select a custom geneset above first.")
                            Correlation_gene(NULL)
                            return(NULL)
                        }

                        genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$Deconvolution_Gene_correlation_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                        Correlation_gene(genes)
                        Deconvolution_Gene_correlation_genes_status(paste0("You have input ", length(Correlation_gene()), " gene(s) from your selected custom geneset."))

                    }
                })
            #
        #

        # Select a cell type
            output$Deconvolution_Gene_correlation_select_celltype <- renderUI({
                if(is.null(deconv_table())){
                    selectInput('Deconvolution_Gene_correlation_select_celltype', 'Select a Cell type',  c('--Run deconvolution first--'='None'))
                }else{
                    celltype_names <- rownames(deconv_table())
                    selectInput(session$ns('Deconvolution_Gene_correlation_select_celltype'), 'Select a Cell type',  c('None'='None', celltype_names))
                }
            })

        #

        # Sample filtering setting

            # status
                Deconvolution_filter_selection_number <- reactiveVal(NULL)
                output$Deconvolution_filter_selection_number <- renderText({ Deconvolution_filter_selection_number() })
            #

            # variables
                All_sample_flag <- reactiveVal(TRUE) # default use all the samples for survival analysis
                filtered_sample_ids_reactive <- reactiveVal(NULL) # store the filtered sample ids when users choose to use a specific category of samples for survival analysis
                filtered_sample_ids <- reactiveVal(NULL) # store the filtered samples id after clicling the botton
            #

            # when users choose a category for filtering, show the category selection dropdown
                # group selection dropdown
                    output$Deconvolution_filter_selection <- renderUI({
                        if(length(input$Deconvolution_filter) == 0 || input$Deconvolution_filter == 'A'){
                            return(NULL)
                        }else{
                            selectInput(session$ns("Deconvolution_filter_selection"), "Filtering by:", c('None'='None', colnames(Meta_data())))
                        }
                    })
                #

                # category selection dropdown
                    output$Deconvolution_filter_selection_category <- renderUI({
                        if(length(input$Deconvolution_filter) == 0 || input$Deconvolution_filter == 'A'){
                            return(NULL)
                        }else{
                            if(length(input$Deconvolution_filter_selection) == 0 || is.null(input$Deconvolution_filter_selection) ||  input$Deconvolution_filter_selection == 'None'){
                                selectInput(session$ns("Deconvolution_filter_selection_category"), "Category:", c('None'='None'))
                            }else{
                                selectInput(session$ns("Deconvolution_filter_selection_category"), "Category:", c('None'='None', unique(Meta_data()[,input$Deconvolution_filter_selection])))
                            }
                        }
                    })
                #

                # show the number of samples. When no filtering, show the number of all the samples
                    observe({
                        if(!is.null(Meta_data())){
                            if(length(input$Deconvolution_filter) > 0 && input$Deconvolution_filter == 'A'){
                                Deconvolution_filter_selection_number(paste0("The total number of samples is ", nrow(Meta_data()), "."))

                            }else if(length(input$Deconvolution_filter) > 0 && input$Deconvolution_filter == 'B'){
                                if(length(input$Deconvolution_filter_selection) > 0 && input$Deconvolution_filter_selection != 'None' && length(input$Deconvolution_filter_selection_category) > 0 && input$Deconvolution_filter_selection_category != 'None'){
                                    num <- nrow(Meta_data()[Meta_data()[,input$Deconvolution_filter_selection] %in% input$Deconvolution_filter_selection_category, ])
                                    filtered_sample_ids_reactive(Meta_data()[Meta_data()[,input$Deconvolution_filter_selection] %in% input$Deconvolution_filter_selection_category, ]$sample)
                                    Deconvolution_filter_selection_number(paste0("You have chosen to use the samples in category ", input$Deconvolution_filter_selection_category, " of ", input$Deconvolution_filter_selection, " for the correlation analysis. \nThe number of the selected samples is ", num, "."))
                                }else{
                                    filtered_sample_ids_reactive(NULL)
                                    Deconvolution_filter_selection_number("Please select a category for filtering.")
                                }
                            }else{
                                Deconvolution_filter_selection_number(NULL)
                            }
                        }else{
                            Deconvolution_filter_selection_number(NULL)
                        }
                    })
                #
            #

        #

        # calculate the correlation
            # status
                Deconvolution_Gene_correlation_status0 <- reactiveVal('Please set the parameters and click \'Start correlation\'.')
                output$Deconvolution_Gene_correlation_status0 <- renderText({ Deconvolution_Gene_correlation_status0() })
            #

            # start
                isCalculating_Deconvolution_gene_correlation <- reactiveVal(FALSE)
                Deconvolution_gene_correlation <- reactiveVal(NULL)
                observeEvent(input$Deconvolution_Gene_correlation_start, {
                    isCalculating_Deconvolution_gene_correlation(TRUE)
                    df_geneEx <- Gene_expression()

                    # when no deonv table
                        if(is.null(deconv_table())){
                            show_alert(title='Error.', text='Please do the deconvolution first.', type='error')
                            Deconvolution_Gene_correlation_status0("Please do deconvolution first.")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                        deconv_table <- deconv_table() # deconv_table[1:3, 1:3]
                    #

                    # when no cell type is selected
                        if(input$Deconvolution_Gene_correlation_select_celltype == 'None'){
                            show_alert(title='Error.', text='Please select a cell type to compare.', type='error')
                            Deconvolution_Gene_correlation_status0("Please choose the cell type")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                    #

                    # when no gene is inputted
                        if(is.null(Correlation_gene()) || length(Correlation_gene()) == 0){
                            show_alert(title='Error.', text='Please input the genes to calculate the correlation.', type='error')
                            Deconvolution_Gene_correlation_status0("Please enter genes (line by line)")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                    #

                    # none of the gene are included in the gene expression
                        found_genes <- Correlation_gene()[Correlation_gene() %in% rownames(df_geneEx)]
                        not_found_genes <- Correlation_gene()[!Correlation_gene() %in% rownames(df_geneEx)]
                        if(length(found_genes) == 0){
                            show_alert(title='Error.', text='None of the inputted genes are found in the gene expression dataset. Please check the gene names and make sure they are in the dataset.', type='error')
                            Deconvolution_Gene_correlation_status0("None of the inputted genes are found in the gene expression dataset. Please check the gene names and make sure they are in the dataset.")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                    #

                    # when no method is selected
                        if(length(input$Deconvolution_Gene_correlation_method) == 0){
                            show_alert(title='Error.', text='Please select the method for correlation.', type='error')
                            Deconvolution_Gene_correlation_status0("Please select the method for correlation.")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                    #

                    # when user chooses to filter samples but no category is selected or no sample in the selected category
                        if(length(input$Deconvolution_filter) > 0 && input$Deconvolution_filter == 'B'){
                            if(length(input$Deconvolution_filter_selection) == 0 || input$Deconvolution_filter_selection == 'None' || length(input$Deconvolution_filter_selection_category) == 0 || input$Deconvolution_filter_selection_category == 'None' || is.null(filtered_sample_ids_reactive()) || length(filtered_sample_ids_reactive()) == 0){
                                show_alert(title='Error.', text='Please select a category for filtering.', type='error')
                                Deconvolution_Gene_correlation_status0("Please select a category for filtering, and make sure there are samples in the selected category.")
                                Deconvolution_gene_correlation(NULL)
                                isCalculating_Deconvolution_gene_correlation(FALSE)
                                return(NULL)
                            }else{
                                All_sample_flag(FALSE)
                                filtered_sample_deconvolution <- intersect(filtered_sample_ids_reactive(), colnames(deconv_table))
                                filtered_sample_deconvolution <- intersect(colnames(df_geneEx), filtered_sample_deconvolution)
                                filtered_sample_ids(filtered_sample_deconvolution)
                            }
                        }else{
                            All_sample_flag(TRUE)
                            filtered_sample_deconvolution <- colnames(deconv_table)
                            filtered_sample_deconvolution <- intersect(colnames(df_geneEx), filtered_sample_deconvolution)
                            filtered_sample_ids(filtered_sample_deconvolution)
                        }
                        if(length(filtered_sample_deconvolution) <= 1){
                            show_alert(title='Error.', text='At least 2 samples are needed to calculate correlations. Please reselect the category.', type='error')
                            Deconvolution_Gene_correlation_status0("At least 2 samples are needed to calculate correlations. Please reselect the category. \nNote: Please check if the samples in the metadata are correctly matched with the samples in the gene expression data.")
                            Deconvolution_gene_correlation(NULL)
                            isCalculating_Deconvolution_gene_correlation(FALSE)
                            return(NULL)
                        }
                    #

                    # Extract the Cell abundance, gene expression
                        cell_type <- input$Deconvolution_Gene_correlation_select_celltype # cell_type <- 'T cells'
                        deconv_table_cell <- deconv_table[cell_type, filtered_sample_deconvolution, drop=FALSE]
                        df_geneEx_gene <- df_geneEx[found_genes ,filtered_sample_deconvolution, drop=FALSE]
                    #

                    # correlation
                        df_cor_out <- data.frame(Gene=c(), r=c(), p=c())
                        deconv_table_cell <- deconv_table_cell[cell_type,]
                        method=input$Deconvolution_Gene_correlation_method # method = 'spearman'
                        for ( gene2 in found_genes){ # gene2 = found_genes[1]
                            gene_ex <- unlist(df_geneEx_gene[gene2,])
                            c <- cor.test(deconv_table_cell, gene_ex, method=method)
                            r <- c$estimate
                            p <- c$p.value
                            df_cor_tmp <- data.frame(Gene=gene2, r=r, p=p)
                            df_cor_out <- rbind(df_cor_out, df_cor_tmp)
                        }
                        df_cor_out <- df_cor_out[order(df_cor_out$p, decreasing=F),]
                        df_cor_out$cell_type <- cell_type
                        rownames(df_cor_out) <- NULL
                    #

                    # status
                        # show the cell type and the number of genes in how many samples and correlation method, number of gene not found if needed and show the name of those genes.
                        message <- paste0("The correlation between the abundance of ", cell_type, " and the expression of ", length(found_genes), " gene(s) across ", length(filtered_sample_deconvolution), " sample(s) using ", method, " has been calculated. \n")
                        if(length(not_found_genes) > 0){
                            message <- paste0(message, length(not_found_genes), " gene(s) were not found in the gene expression dataset: \n\n", paste(not_found_genes, collapse=', '), ".")
                        }
                        Deconvolution_Gene_correlation_status0(message)
                        Deconvolution_gene_correlation(df_cor_out)
                        isCalculating_Deconvolution_gene_correlation(FALSE)
                        return(NULL)
                    #
                })
            #
        #
    ##

    # Return reactive values needed by plot server
    list(
        deconv_table                              = deconv_table,
        deconv_long                               = deconv_long,
        isCalculating_deconv_long                 = isCalculating_deconv_long,
        Deconvolution_gene_correlation            = Deconvolution_gene_correlation,
        isCalculating_Deconvolution_gene_correlation = isCalculating_Deconvolution_gene_correlation,
        All_sample_flag                           = All_sample_flag,
        filtered_sample_ids                       = filtered_sample_ids
    )
}
