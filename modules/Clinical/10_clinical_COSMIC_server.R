# =============================================================================
# Clinical - COSMIC Cancer Gene Census Server
# File: modules/Clinical/10_clinical_COSMIC_server.R
# Purpose: Looks up user-supplied gene names against the COSMIC Cancer Gene
#          Census (CGC) database and displays matching records. Helps users
#          quickly check whether genes of interest are known cancer drivers.
# Edit this file when: updating the CGC database file, adding new columns to
#                       the result table, or changing the gene matching logic.
# Data file: data/Cancer_Gene_Census_30_Mar_2025.tsv (update periodically)
# =============================================================================

clinical_COSMIC_server <- function(input, output, session,  Custom_genesets) {
    # database
        CGC_Database <- read.table('data/Cancer_Gene_Census_30_Mar_2025.tsv', sep='\t', header=T,check.names = FALSE)
    #

    # Input genes
        CGC_input_gene <- reactiveVal(NULL)
        # status
            CGC_input_gene_status <- reactiveVal(NULL)
            output$CGC_input_gene_status <- renderText({ CGC_input_gene_status() })
        #

        # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
            output$CGC_input_gene <- renderUI({ textAreaInput(session$ns("CGC_input_gene"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
            observe({
                if(length(input$CGC_input_gene_from_custom_geneset) > 0 && input$CGC_input_gene_from_custom_geneset == TRUE){
                    shinyjs::disable("CGC_input_gene")
                } else {
                    shinyjs::enable("CGC_input_gene")
                }
            })

        #

        # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
            output$CGC_input_gene_from_custom_geneset_select <- renderUI({
                if(length(input$CGC_input_gene_from_custom_geneset) > 0 && input$CGC_input_gene_from_custom_geneset == TRUE){
                    gene_sets_names <- c(Custom_genesets()$Geneset.name)
                    selectInput(session$ns('CGC_input_gene_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                } else {
                    return(NULL)
                }
            })
        
        #

        # Set the input genes
            observe({
                if(length(input$CGC_input_gene) == 0 || length(input$CGC_input_gene_from_custom_geneset) == 0){
                    CGC_input_gene(NULL)
                    CGC_input_gene_status(NULL)
                    return(NULL)
                }else if(input$CGC_input_gene_from_custom_geneset == FALSE){
                    # custom select: off -> manual

                    if(all(grepl("^\\s*$", input$CGC_input_gene))){
                        CGC_input_gene_status('Please enter gene names in the box above, one gene per line.')
                        CGC_input_gene(NULL)
                        return(NULL)
                    }

                    # when there are gene names inputted
                    genes_tmp <- unique(unlist(strsplit(input$CGC_input_gene, split="\n")))
                    genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                    CGC_input_gene(genes_tmp)
                    CGC_input_gene_status(paste0("You have manually input ", length(CGC_input_gene()), " gene(s)."))

                }else if(input$CGC_input_gene_from_custom_geneset == TRUE){
                    # custom select: on -> custom geneset
                    if(length(input$CGC_input_gene_from_custom_geneset_select) == 0 || input$CGC_input_gene_from_custom_geneset_select == 'None'){
                        CGC_input_gene_status("Please select a custom geneset above first.")
                        CGC_input_gene(NULL)
                        return(NULL)
                    }

                    genes <- strsplit(Custom_genesets()[Custom_genesets()$Geneset.name %in% input$CGC_input_gene_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                    CGC_input_gene(genes)
                    CGC_input_gene_status(paste0("You have input ", length(CGC_input_gene()), " gene(s) from your selected custom geneset."))
                }
            })
        #
    ##

    ## table
        # status
            CGC_table_status <- reactiveVal(NULL)
            output$CGC_table_status <- renderText({ CGC_table_status() })
        #

        # prepare the table
            CGC_table_data <- reactiveVal(CGC_Database)
            observe({
                if(is.null(CGC_input_gene())){
                    CGC_table_data(CGC_Database)
                    CGC_table_status("No input gene. Displaying the entire Cancer Gene Census database.")
                }else{
                    CGC_Database_tmp <- CGC_Database[CGC_Database[,'Gene Symbol'] %in% CGC_input_gene(), ]
                    if(nrow(CGC_Database_tmp) == 0){
                        tmp <- data.frame(Message = "No genes from your input are found in the Cancer Gene Census database. Please check your input.")
                        CGC_table_data(tmp)
                        CGC_table_status("No genes from your input are found in the Cancer Gene Census database. Please check your input.")
                    }else{
                        CGC_table_data(CGC_Database_tmp)
                        CGC_table_status(paste0(nrow(CGC_Database_tmp), " gene(s) from your input are found in the Cancer Gene Census database."))
                    }
                }
            })
        #

        # render the table
            output$CGC_table <- renderDataTable({ 
                datatable(CGC_table_data(), options = list(scrollX = TRUE, pageLength = 10, fixedColumns = list(leftColumns=1)), rownames=FALSE)
            })
        
        # download the table
            output$CGC_table_download <- downloadHandler(
                filename = function(){"Cancer_predisposition_genes.tsv"}, 
                content = function(fname){ write.table(CGC_table_data(), fname, sep='\t', row.names=F, quote=F) }
            )
        #
        

}
