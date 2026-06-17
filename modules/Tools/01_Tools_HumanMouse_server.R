# =============================================================================
# Tools - Human/Mouse Gene ID Conversion Server
# File: modules/Tools/01_Tools_HumanMouse_server.R
# Purpose: Converts gene symbols between human and mouse using a pre-built
#          BioMart mapping table (biomart_comparison_chart.tsv). Returns a
#          table of matched/unmatched genes and a download handler.
# Edit this file when: updating the BioMart reference table or changing the
#                       matching strategy (1:1 vs 1:many).
# =============================================================================

tools_humanmouse_Server <- function(input, output, session) {
    ## Initial settings
        # Inputs and Settings
            status_input <- reactiveVal("Please enter genes in the input box and click the 'Convert genes' button to start the conversion.")
            input_gene_list <- reactiveVal(NULL)

        # Table
            status_table <- reactiveVal("Conversion table will be displayed here.")
            convert_table <- reactiveVal(NULL)

        # Final result
            status_result <- reactiveVal("Converted genes will be displayed here.")
            final_converted_gene_list <- reactiveVal(NULL)
        
        # show status
            output$status_input <- renderText({ status_input() })
            output$status_table <- renderText({ status_table() })
            output$status_result <- renderText({ status_result() })

    ##

    ## Inputs and Settings 
        # input genes
            observe({
                if(length(input$human_mouse_convert_input_gene) > 0){
                    # when there are nothing in the text box
                    if(nchar(input$human_mouse_convert_input_gene) == 0){
                        input_gene_list(NULL)
                    } else {
                        # when there are genes in the text box
                        # if all of them are '', then set input_gene_list to NULL
                        gene_list <- unique(unlist(strsplit(input$human_mouse_convert_input_gene, split='\n')))
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
            observeEvent(input$human_mouse_convert_start,{
                # if there is no gene in the input, show error message
                if(is.null(input_gene_list())){
                    status_input('Please enter at least one gene in the input box.')
                    show_alert(title = "Error", text = "Please enter at least one gene in the input box.", type = "error")
                } else {
                    status_input(NULL) # clear status message

                    # Check all the options are set
                    if(is.null(input$human_mouse_convert_direction) || is.null(input$human_mouse_convert_input_type) || is.null(input$human_mouse_convert_output_type)){
                        status_input('Please select conversion direction, input type and output type.')
                        show_alert(title = "Error", text = "Please select conversion direction, input type and output type.", type = "error")
                        return(NULL)
                    } 

                    # convertion
                    input_genes <- input_gene_list()
                    converted_df <- data.frame(input=input_genes)
                    if(input$human_mouse_convert_direction == 'A'){
                        input_column <- switch(input$human_mouse_convert_input_type,
                            "A" = 'Mouse.gene.name',
                            "B" = 'Mouse.gene.stable.ID',
                            "C" = 'Mouse.gene.stable.ID.version'
                        )
                        output_column <- switch(input$human_mouse_convert_output_type,
                            "A" = 'Human.Gene.name',
                            "B" = 'Human.Gene.stable.ID',
                            "C" = 'Human.Gene.stable.ID.version'
                        )
                        colnames(converted_df) <- input_column
                        converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
                        converted <- distinct(converted) 
                    }else if(input$human_mouse_convert_direction == 'B'){
                        input_column <- switch(input$human_mouse_convert_input_type,
                        "A" = 'Human.Gene.name',
                        "B" = 'Human.Gene.stable.ID',
                        "C" = 'Human.Gene.stable.ID.version'
                        )
                        output_column <- switch(input$human_mouse_convert_output_type,
                        "A" = 'Mouse.gene.name',
                        "B" = 'Mouse.gene.stable.ID',
                        "C" = 'Mouse.gene.stable.ID.version'
                        )
                        colnames(converted_df) <- input_column
                        converted <- merge(converted_df, human_mouse_biomart_data[, c(input_column, output_column)], by=input_column, all.x =TRUE)
                        converted <- distinct(converted) 
                    }

                    # update
                    convert_table(converted)
                    final_converted_gene_list(converted[[output_column]])

                    # if there is no gene converted successfully, show error message
                    if(sum(!is.na(converted[[output_column]])) == 0){
                        status_table('No gene was converted successfully. Please check your input and settings.')
                        status_result('No gene was converted successfully. Please check your input and settings.')
                        show_alert(title = "Error", text = "No gene was converted successfully. Please check your input and settings.", type = "error")
                    }

                    # show status. How many genes were converted successfully, how many genes were not converted, and show the list of genes that were not converted.
                    num_input_genes <- length(input_genes)
                    num_converted_genes <- sum(!is.na(converted[[output_column]]))
                    num_not_converted_genes <- sum(is.na(converted[[output_column]]))
                    not_converted_genes <- converted[[input_column]][is.na(converted[[output_column]])]
                    status_table(paste0("Total input genes: ", num_input_genes, "\nSuccessfully converted genes: ", num_converted_genes, "\nNot converted genes: ", num_not_converted_genes, "\nList of not converted genes: ", paste(not_converted_genes, collapse = ", ")))

                    # show the list of converted genes
                    status_result(paste(final_converted_gene_list()[!is.na(final_converted_gene_list())], collapse = "\n"))

                }
            })

        # display table
            output$human_mouse_convert_table <- renderDataTable({
            if(is.null(convert_table())){
                tmp <- data.frame(list('Human.Gene'=character(0), 'Mouse.Gene'=character(0)), stringsAsFactors = FALSE )
                datatable( tmp, options = list(scrollX = TRUE, pageLength = 10 )) 
            }else{
                datatable( convert_table(), options = list(scrollX = TRUE, pageLength = 10 )) 
            }
            })

        # download the table
            output$human_mouse_convert_table_download <- downloadHandler(
              filename = function(){paste0("Human_Mouse_Conversion_", Sys.Date(), ".tsv")}, 
              content = function(fname){ write.table(convert_table(), fname, sep='\t',  quote=FALSE, row.names = FALSE) }
            )

    ##
}
