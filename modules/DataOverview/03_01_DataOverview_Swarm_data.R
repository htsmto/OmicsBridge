# =============================================================================
# DataOverview - Swarm Plot: Data
# File: modules/DataOverview/03_01_DataOverview_Swarm_data.R
# Purpose: Handles gene input (manual text or custom geneset), builds the
#          per-gene expression score tables, and manages the gene selection
#          table displayed to the user.
# Edit this file when: changing gene input modes, expression table logic,
#                       group extraction from sample names, or log transform.
# =============================================================================

swarm_data_server <- function(input, output, session, Original_geneset_list, df_datasets) {
    ## variable, initial settings
        # Input settings
            status_gene <- reactiveVal(NULL)
            gene_list_mannual <- reactiveVal(NULL)
            gene_list_custom <- reactiveVal(NULL)
            Input_is_ready <- reactiveVal(0) # flag. 0:not ready, 1:gene_list_mannual is ready, 2:gene_list_custom is ready.

        # Expression score table
            df_gene_expression_map <- reactiveVal(NULL)
            status_expression <- reactiveVal(NULL)
            Selected_genes <- reactiveVal(NULL)
            Ex_table_ready <- reactiveVal(FALSE) # flag. FALSE: not ready, TRUE: ready

    ## show the status
        output$status_gene <- renderText({status_gene()})
        output$status_expression <- renderText({status_expression()})

    ##

    ## Input setting
        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$target_genes_manual <- renderUI({ textAreaInput(session$ns("target_genes_manual"), "Enter gene names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$target_genes_from_custom_geneset) > 0 && input$target_genes_from_custom_geneset == TRUE){
                    shinyjs::disable("target_genes_manual")
                } else {
                    shinyjs::enable("target_genes_manual")
                }
            })

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$target_genes_from_custom_geneset_select <- renderUI({
                if(length(input$target_genes_from_custom_geneset) > 0 && input$target_genes_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Original_geneset_list$Geneset.name)
                    selectInput(session$ns('target_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })

        # show the list of the genes in a table (column(12, dataTableOutput(ns("target_gene_table")) ))
            # manually inputted genes
                observe({
                    if(length(input$target_genes_manual) > 0){
                        # This work only when the user choose to inpyt gene manually
                        if(length(input$target_genes_from_custom_geneset) == 0 || input$target_genes_from_custom_geneset == FALSE){
                            # when nothing is inputted or the genes names are just spaces (' ')
                            if(all(grepl("^\\s*$", input$target_genes_manual))){
                                status_gene('Please enter gene names in the box above, one gene per line.')
                                gene_list_mannual(NULL)
                                return(NULL)
                            }

                            # when there are gene names inputted
                            genes_tmp <- unique(unlist(strsplit(input$target_genes_manual, split="\n")))
                            genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                            gene_list_mannual(genes_tmp)
                            status_gene(paste0("You have manually input ", length(gene_list_mannual()), " gene(s)."))
                        }
                    }
                })

            # genes from custom geneset
                observe({
                    req(input$target_genes_from_custom_geneset_select)
                    if(input$target_genes_from_custom_geneset_select == 'None'){
                        status_gene("Please select a custom geneset above first.")
                        gene_list_custom(NULL)
                        return(NULL)
                    }else{
                        genes <- strsplit(Original_geneset_list[Original_geneset_list$Geneset.name %in% input$target_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                        gene_list_custom(genes)
                        status_gene(paste0("You have input ", length(gene_list_custom()), " gene(s) from your selected custom geneset."))
                    }
                })

            # show the gene list in a table
                output$target_gene_table <- renderDataTable({
                    if(length(input$target_genes_from_custom_geneset) > 0 && input$target_genes_from_custom_geneset == TRUE){
                        if(is.null(gene_list_custom())){
                            Input_is_ready(0)
                            return(NULL)
                        } else {
                            Input_is_ready(2)
                            datatable(data.frame(Gene = gene_list_custom()), selection = list(mode='multiple'), options = list(scrollX = TRUE, pageLength = 5 ), rownames = FALSE) # , options = list(scrollX = TRUE, scrollY=TRUE)
                        }
                    } else {
                        if(is.null(gene_list_mannual())){
                            Input_is_ready(0)
                            return(NULL)
                        } else {
                            Input_is_ready(1)
                            datatable(data.frame(Gene = gene_list_mannual()), selection = list(mode='multiple'), options = list(scrollX = TRUE, pageLength = 5 ), rownames = FALSE)
                        }
                    }
                })

    ##

    ## Expression score table
        # Selected genes
            observe({
                if(Input_is_ready() == 0 || (is.null(input$target_gene_table_rows_selected) || length(input$target_gene_table_rows_selected) == 0)){
                    Selected_genes(NULL)
                } else if(Input_is_ready() == 1){
                    Selected_genes(gene_list_mannual()[input$target_gene_table_rows_selected])
                } else if(Input_is_ready() == 2){
                    Selected_genes(gene_list_custom()[input$target_gene_table_rows_selected])
                }
            })

        # if multiple genes are selected, show a select botton for the expression table
            output$expression_score_multi_input <- renderUI({
                if(length(Selected_genes()) >= 1){
                    fluidRow(
                        column(9, helpText(HTML("<br>Which gene do you want to show in the expression score table?"))),
                        column(3, selectInput(session$ns('expression_score_multi_input'), '', choices = Selected_genes()))
                    )
                } else {
                    return(NULL)
                }
            })

        # gene a table for the expression score of the selected genes
            observe({
                # when there input are not ready, return NULL
                if(Input_is_ready() == 0){
                    df_gene_expression_map(NULL)
                    status_expression("Please input the genes you want to show in the swarm plot first.")
                    Ex_table_ready(FALSE)
                    return(NULL)
                }

                # when the inputs are ready but nothing is selected in the gene table, return NULL
                if(is.null(input$target_gene_table_rows_selected) || length(input$target_gene_table_rows_selected) == 0){
                    df_gene_expression_map(NULL)
                    status_expression("Please select gene(s) from the table above to see the expression scores.")
                    Ex_table_ready(FALSE)
                    return(NULL)
                }

                # when gene(s) are selected.
                Selected_genes <- Selected_genes()
                df_tmp <- df_datasets()

                # See if the genes are really in the dataset
                if(any(!(Selected_genes %in% df_tmp$id))){
                    not_found_genes <- Selected_genes[!(Selected_genes %in% df_tmp$id)]
                    df_gene_expression_map(NULL)
                    status_expression(paste0("The following gene(s) is/are not found in the dataset: ", paste(not_found_genes, collapse = ", "), ". \nPlease select another gene."))
                    Ex_table_ready(FALSE)
                    return(NULL)
                }


                # Make a list of the expression tables
                map_tmp <- list()
                for (gene_tmp in Selected_genes){
                    # gene_tmp <- Selected_genes[1]

                    # extract the expression scores of the selected gene of the selected target samples
                    target_samples <- grep("_(R|r)ep.+$", colnames(df_tmp), value=TRUE)
                    gene_num <- which(df_tmp$id==gene_tmp)
                    df_gene <- data.frame(t(df_tmp[gene_num,target_samples]))
                    colnames(df_gene) <- c('Expression')

                    # Add group information. The sample names should be in the format of (Group Name)_RepN or (Group Name)_repN.
                    Group <- c()
                    for (i in strsplit(rownames(df_gene), '_')){
                      tmp <- ''
                      for(j in 1:(length(i)-1)){
                        tmp <- paste0(tmp, i[j],'_')
                      }
                      tmp <- substr(tmp, 1, nchar(tmp)-1)
                      Group <- c(Group, tmp)
                    }
                    df_gene$Group <- Group
                    df_gene$Group <- factor(Group, levels=unique(Group[order(Group)]))
                    df_gene <- df_gene[order(df_gene$Group), ]

                    # log2 transformation if the checkbox is checked
                    if(length(input$logsclae) > 0 && input$logsclae == TRUE){
                        df_gene$Expression <- log2(df_gene$Expression + 1)
                    }

                    # add the expression data to the map
                    map_tmp[[gene_tmp]] <- df_gene
                }

                # update the status and the reactive value for the expression score table
                status_expression(paste0('You selected ', paste(Selected_genes, collapse = ", "), '.'))
                df_gene_expression_map(map_tmp)
                Ex_table_ready(TRUE)


            })



        # display the expression score table
            output$expression_score_table <- renderDataTable({
                if(is.null(df_gene_expression_map())){
                    datatable( data.frame(Message = "No gene selected"))
                } else {
                    if(length(input$expression_score_multi_input) > 0){
                        datatable(df_gene_expression_map()[[input$expression_score_multi_input]], options = list(scrollX = TRUE, pageLength = 10 ))
                    }
                }
            })
        #
        # download the table
            output$outFile_expression_download <- downloadHandler(
                filename = function(){paste0(input$expression_score_multi_input, "_Swarm_plot_data.tsv")},
                content = function(fname){ write.table(df_gene_expression_map()[[input$expression_score_multi_input]], fname, sep='\t',  quote=F) }
            )

    ##

    return(list(
        df_gene_expression_map = df_gene_expression_map,
        Ex_table_ready         = Ex_table_ready
    ))
}
