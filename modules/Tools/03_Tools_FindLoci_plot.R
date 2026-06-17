# =============================================================================
# Tools - Chromosomal Locus Finder: Plot
# File: modules/Tools/03_Tools_FindLoci_plot.R
# Purpose: Genomic region result table rendering and download handler for
#          the Find Loci tool. Consumes reactive values from the search
#          sub-module.
# Edit this file when: changing the output format (BED3 vs BED6), adding
#                       cytoband info, or modifying the download handler.
# =============================================================================

findloci_plot_server <- function(input, output, session, convert_table, final_converted_gene_list) {

        # display table
            output$Find_genome_loci_table <- renderDataTable({
            if(is.null(convert_table())){
                tmp <- data.frame(list('chr'=character(0), 'start'=character(0), 'end'=character(0), 'strand'=character(0), 'gene_id'=character(0), 'gene_name'=character(0)), stringsAsFactors = FALSE )
                datatable(tmp, options = list(scrollX = TRUE, pageLength = 10 ))
            }else{
                datatable( convert_table(), options = list(scrollX = TRUE, pageLength = 10 ), rownames = FALSE)
            }
            })

        # download the table
            output$Find_genome_loci_table_download <- downloadHandler(
              filename = function(){paste0("Find_Genome_Loci_", Sys.Date(), ".tsv")},
              content = function(fname){ write.table(convert_table(), fname, sep='\t',  quote=FALSE, row.names = FALSE) }
            )
        #
}
