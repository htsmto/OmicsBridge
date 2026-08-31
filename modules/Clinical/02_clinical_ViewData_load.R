# =============================================================================
# Clinical - View Data: Data Loading
# File: modules/Clinical/02_clinical_ViewData_load.R
# Purpose: Loads expression, survival, metadata, and mutation data files for
#          the selected clinical cohort and exposes them as reactiveVals.
# Edit this file when: changing file parsing logic, adding new data types
#                       (e.g. CNV, methylation), or modifying status messages.
# =============================================================================

viewdata_load_server <- function(input, output, session, dataset_name, ex_path, surv_path, meta_path, mut_path) {
    ## status outputs and result reactiveVals for each of the four data types
        Clinical_View_Geneexpression_status <- reactiveVal()
        output$Clinical_View_Geneexpression_status <- renderText({ Clinical_View_Geneexpression_status() })
        gene_expression_data <- reactiveVal(NULL)

        Clinical_View_Survival_status <- reactiveVal()
        output$Clinical_View_Survival_status <- renderText({ Clinical_View_Survival_status() })
        survival_data <- reactiveVal(NULL)

        Clinical_View_MetaData_status <- reactiveVal()
        output$Clinical_View_MetaData_status <- renderText({ Clinical_View_MetaData_status() })
        meta_data <- reactiveVal(NULL)

        Clinical_View_mutation_status <- reactiveVal()
        output$Clinical_View_mutation_status <- renderText({ Clinical_View_mutation_status() })
        mutation_data <- reactiveVal(NULL)
    ##

    ## Load all four data types together whenever the cohort selection changes.
    ## Combined behind one CPU/RAM resource check -- see guardHeavyLoad() in
    ## app.R -- since up to four files load together on a single selection.
        observeEvent(dataset_name(), {
            # when nothing is selected, reset all four and stop
            if(is.null(dataset_name())){
                Clinical_View_Geneexpression_status('Please select a clinical dataset to view the gene expression data. A preview table will be shown below.')
                gene_expression_data(NULL)
                Clinical_View_Survival_status('Please select a clinical dataset to view the survival data. A preview table will be shown below.')
                survival_data(NULL)
                Clinical_View_MetaData_status('Please select a clinical dataset to view the meta data. A preview table will be shown below.')
                meta_data(NULL)
                Clinical_View_mutation_status('Please select a clinical dataset to view the mutation data. A preview table will be shown below.')
                mutation_data(NULL)
                return(NULL)
            }

            existing_paths <- c(ex_path(), surv_path(), meta_path(), mut_path())

            do_load <- function() {
                # Expression
                if(is.null(ex_path()) || file.exists(ex_path()) == FALSE){
                    Clinical_View_Geneexpression_status('No gene expression data available for this dataset.')
                    gene_expression_data(NULL)
                }else{
                    gene_expression_data(read.table(ex_path(), sep='\t', header=T, row.names=1, check.names = FALSE))
                    Clinical_View_Geneexpression_status(paste0('The dataset contains ', nrow(gene_expression_data()), ' genes and ', ncol(gene_expression_data()), ' samples.'))
                }

                # Survival
                if(is.null(surv_path()) || file.exists(surv_path()) == FALSE){
                    Clinical_View_Survival_status('No survival data available for this dataset.')
                    survival_data(NULL)
                }else{
                    survival_data(read.table(surv_path(), header=T, check.names = FALSE, sep='\t'))
                    Clinical_View_Survival_status(paste0('The dataset contains ', nrow(survival_data()), ' samples.'))
                }

                # Meta data
                if(is.null(meta_path()) || file.exists(meta_path()) == FALSE){
                    Clinical_View_MetaData_status('No meta data available for this dataset.')
                    meta_data(NULL)
                }else{
                    meta_data(read.delim(meta_path(), header=T,check.names = FALSE))
                    Clinical_View_MetaData_status(paste0('The dataset contains ', nrow(meta_data()), ' samples and ', ncol(meta_data()), ' metadata columns.'))
                }

                # Mutation data
                if(is.null(mut_path()) || file.exists(mut_path()) == FALSE){
                    Clinical_View_mutation_status('No mutation data available for this dataset.')
                    mutation_data(NULL)
                }else{
                    mutation_data(read.delim(mut_path(), header=T, check.names = FALSE))
                    sample_num <- unique(mutation_data()$sample)
                    Clinical_View_mutation_status(paste0('The dataset contains the mutation information of ', length(sample_num), ' samples'))
                }
            }

            on_cancel <- function() {
                Clinical_View_Geneexpression_status('Loading cancelled.')
                Clinical_View_Survival_status('Loading cancelled.')
                Clinical_View_MetaData_status('Loading cancelled.')
                Clinical_View_mutation_status('Loading cancelled.')
            }

            guardHeavyLoad(session, "confirm_clinical_load", do_load, on_cancel = on_cancel,
                            what = "this clinical cohort's data (expression/survival/meta/mutation)",
                            file_paths = existing_paths)
        })
        heavyLoadConfirmObserver(input, session, "confirm_clinical_load")
    ##

    ## return the loaded data tables
        return(list(
            gene_expression_data = gene_expression_data,
            survival_data        = survival_data,
            meta_data            = meta_data,
            mutation_data        = mutation_data
        ))

    ##
}
