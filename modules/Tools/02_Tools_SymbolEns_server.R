# =============================================================================
# Tools - Gene Symbol <-> Ensembl ID Conversion Server
# File: modules/Tools/02_Tools_SymbolEns_server.R
# Purpose: Converts between HGNC gene symbols and Ensembl gene IDs using the
#          BioMart mapping table. Supports bulk conversion with a downloadable
#          result table.
# Edit this file when: updating the reference table or adding support for
#                       additional gene ID types (e.g. Entrez, RefSeq).
# =============================================================================

tools_symbolens_Server <- function(input, output, session) {
    ## initla settings
        # Inputs and Settings
            symbolens_status_input <- reactiveVal("Please enter genes in the input box and click the 'Convert genes' button to start the conversion.")
            input_gene_list <- reactiveVal(NULL)

        # Table
            symbolens_status_table <- reactiveVal("Conversion table will be displayed here.")
            convert_table <- reactiveVal(NULL)

        # results
            symbolens_status_result <- reactiveVal("Converted genes will be displayed here.")
            final_converted_gene_list <- reactiveVal(NULL)


        # show status
            output$symbolens_status_input <- renderText({ symbolens_status_input() })
            output$symbolens_status_table <- renderText({ symbolens_status_table() })
            output$symbolens_status_result <- renderText({ symbolens_status_result() })        
            
    ##

    ## Inputs and Settings 
        # input genes
            observe({
                if(length(input$Gene_Ensembl_input_gene) > 0){
                    # when there are nothing in the text box
                    if(nchar(input$Gene_Ensembl_input_gene) == 0){
                        input_gene_list(NULL)
                    } else {
                        # when there are genes in the text box
                        # if all of them are '', then set input_gene_list to NULL
                        gene_list <- unique(unlist(strsplit(input$Gene_Ensembl_input_gene, split='\n')))
                        gene_list <- gene_list[gene_list != ''] # remove empty elements
                        if(length(gene_list) == 0){
                            input_gene_list(NULL)
                        } else {
                            input_gene_list(gene_list)
                        }
                    }
                } else {
                    input_gene_list(NULL)
                }
            })

    ##

    ## Convertion table 
        # convert start
            observeEvent(input$Gene_Ensembl_convert_start,{
                # if there is no gene in the input, show error message
                if(is.null(input_gene_list())){
                    symbolens_status_input('Please enter at least one gene in the input box.')
                    show_alert(title = "Error", text = "Please enter at least one gene in the input box.", type = "error")
                } else {
                    symbolens_status_input(NULL) # clear status message

                    # Check all the options are set
                    if(is.null(input$Gene_Ensembl_spieces) || is.null(input$Gene_Ensembl_input_type) || is.null(input$Gene_Ensembl_output_type)){
                        symbolens_status_input('Please select Species, Input type and Output type.')
                        show_alert(title = "Error", text = "Please select Species, Input type and Output type.", type = "error")
                        return(NULL)
                    } 

                    # convertion
                    input_genes <- input_gene_list()
                    converted_df <- data.frame(input=input_genes)
                    if(input$Gene_Ensembl_spieces == 'A'){
                        input_column <- switch(input$Gene_Ensembl_input_type,
                            "A" = 'Human.Gene.name',
                            "B" = 'Human.Gene.stable.ID',
                            "C" = 'Human.Gene.stable.ID.version'
                        )
                        output_column <- switch(input$Gene_Ensembl_output_type,
                            "A" = 'Human.Gene.name',
                            "B" = 'Human.Gene.stable.ID',
                            "C" = 'Human.Gene.stable.ID.version'
                        )
                        colnames(converted_df) <- input_column
                        converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
                        converted <- distinct(converted) # library(dplyr)
                    }else{
                        input_column <- switch(input$Gene_Ensembl_input_type,
                            "A" = 'Mouse.gene.name',
                            "B" = 'Mouse.gene.stable.ID',
                            "C" = 'Mouse.gene.stable.ID.version'
                        )
                        output_column <- switch(input$Gene_Ensembl_output_type,
                            "A" = 'Mouse.gene.name',
                            "B" = 'Mouse.gene.stable.ID',
                            "C" = 'Mouse.gene.stable.ID.version'
                        )
                        colnames(converted_df) <- input_column
                        converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
                        converted <- distinct(converted) # library(dplyr)
                    }

                    # update
                    convert_table(converted)
                    final_converted_gene_list(converted[[output_column]])

                    # if there is no gene converted successfully, show error message
                    if(sum(!is.na(converted[[output_column]])) == 0){
                        symbolens_status_table('No gene was converted successfully. Please check your input and settings.')
                        symbolens_status_result('No gene was converted successfully. Please check your input and settings.')
                        show_alert(title = "Error", text = "No gene was converted successfully. Please check your input and settings.", type = "error")
                    }

                    # show status. How many genes were converted successfully, how many genes were not converted, and show the list of genes that were not converted.
                    num_input_genes <- length(input_genes)
                    num_converted_genes <- sum(!is.na(converted[[output_column]]))
                    num_not_converted_genes <- sum(is.na(converted[[output_column]]))
                    not_converted_genes <- converted[[input_column]][is.na(converted[[output_column]])]
                    symbolens_status_table(paste0("Total input genes: ", num_input_genes, "\nSuccessfully converted genes: ", num_converted_genes, "\nNot converted genes: ", num_not_converted_genes, "\nList of not converted genes: ", paste(not_converted_genes, collapse = ", ")))

                    # show the list of converted genes
                    symbolens_status_result(paste(final_converted_gene_list()[!is.na(final_converted_gene_list())], collapse = "\n"))

                }
            })

        # display table
            output$Gene_Ensembl_convert_table <- renderDataTable({
            if(is.null(convert_table())){
                tmp <- data.frame(list('Human.Gene'=character(0), 'Mouse.Gene'=character(0)), stringsAsFactors = FALSE )
                datatable( tmp, options = list(scrollX = TRUE, pageLength = 10 )) 
            }else{
                datatable( convert_table(), options = list(scrollX = TRUE, pageLength = 10 )) 
            }
            })

        # download the table
            output$Gene_Ensembl_convert_table_download <- downloadHandler(
              filename = function(){paste0("Gene_Ensembl_Conversion_", Sys.Date(), ".tsv")}, 
              content = function(fname){ write.table(convert_table(), fname, sep='\t',  quote=FALSE, row.names = FALSE) }
            )

    ##
}