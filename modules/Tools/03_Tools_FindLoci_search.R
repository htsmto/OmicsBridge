# =============================================================================
# Tools - Chromosomal Locus Finder: Search
# File: modules/Tools/03_Tools_FindLoci_search.R
# Purpose: Gene/loci search logic, input handling, and status messages for
#          the Find Loci tool. Returns reactive values consumed by the plot
#          sub-module.
# Edit this file when: updating the coordinate reference file, changing input
#                       parsing logic, or adding new search directions.
# =============================================================================

findloci_search_server <- function(input, output, session) {
    ## Initial settings
        # Inputs and Settings
            Find_genome_loci_status_input <- reactiveVal("Please enter genes in the input box and click the 'Convert genes' button to start the conversion.")
            input_gene_list <- reactiveVal(NULL)

        # Table
            Find_genome_loci_status_table <- reactiveVal("The result table will be displayed here.")
            convert_table <- reactiveVal(NULL)

        # Final result
            Find_genome_loci_status_result <- reactiveVal("Gene names or their coordinates will be listed here.")
            final_converted_gene_list <- reactiveVal(NULL)

        # show status
            output$Find_genome_loci_status_input <- renderText({ Find_genome_loci_status_input() })
            output$Find_genome_loci_status_table <- renderText({ Find_genome_loci_status_table() })
            output$Find_genome_loci_status_result <- renderText({ Find_genome_loci_status_result() })

    ##

    ## Inputs and Settings
        # input genes or coordinates
            observe({
                if(length(input$Find_genome_loci_input) > 0){
                    # when there are nothing in the text box
                    if(nchar(input$Find_genome_loci_input) == 0){
                        input_gene_list(NULL)
                    } else {
                        # when there are genes in the text box
                        # if all of them are '', then set input_gene_list to NULL
                        gene_list <- unique(unlist(strsplit(input$Find_genome_loci_input, split='\n')))
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

    ## Searching table
        # search start
            observeEvent(input$Find_genome_loci_start,{
                # if there is no gene in the input, show error message
                if(is.null(input_gene_list())){
                    Find_genome_loci_status_input('Please enter at least one gene or coordinate in the input box.')
                    show_alert(title = "Error", text = "Please enter at least one gene or coordinate in the input box.", type = "error")
                    return()
                } else {
                    Find_genome_loci_status_input(NULL) # clear status message

                    # Check all the options are set
                    if(is.null(input$Find_genome_loci_direction) || is.null(input$Choose_genome)){
                        Find_genome_loci_status_input('Please select the method and genome.')
                        show_alert(title = "Error", text = "Please select the method and genome.", type = "error")
                        return()
                    } else {
                        # start searching. Gene => Coordinates
                        if(input$Find_genome_loci_direction == 'A'){
                            genes_tmp <- input_gene_list()

                            # check if the input genes are in the database(Gene_coords_GRch38)
                            genes_found <- genes_tmp[genes_tmp %in% Gene_coords_GRch38$gene_name]
                            genes_not_found <- genes_tmp[!genes_tmp %in% Gene_coords_GRch38$gene_name]

                            # if there are no genes successfully found, show error message
                            if(length(genes_found) == 0){
                                Find_genome_loci_status_table('No input gene can be found in the database. Please check your input gene names and try again.')
                                show_alert(title = "Error", text = "No input gene can be found in the database. Please check your input gene names and try again.", type = "error")
                                return()
                            }

                            # find the cordinates of the found genes
                            Gene_coords_GRch38_focus <- Gene_coords_GRch38[Gene_coords_GRch38$gene_name %in% genes_found,]
                            coord <- paste0(Gene_coords_GRch38_focus$chr, ':', Gene_coords_GRch38_focus$start, '-',  Gene_coords_GRch38_focus$end)

                            # update the objects for table and final result
                            convert_table(Gene_coords_GRch38_focus)
                            final_converted_gene_list(paste(coord, collapse = '\n'))

                            # show status. How many genes were successfully found, how many genes were not found, and show the list of genes that were not found.
                            num_input_genes <- length(genes_tmp)
                            num_converted_genes <- length(genes_found)
                            num_not_converted_genes <- length(genes_not_found)
                            Find_genome_loci_status_table(paste0("Total input genes: ", num_input_genes, "\nSuccessfully found genes: ", num_converted_genes, "\nNot found genes: ", num_not_converted_genes, "\nList of not found genes: ", paste(genes_not_found, collapse = ", ")))

                            # show the list of found coordinates
                            Find_genome_loci_status_result(final_converted_gene_list())

                        }
                    }
                }
            })

    ##

    return(list(
        convert_table = convert_table,
        final_converted_gene_list = final_converted_gene_list
    ))
}
