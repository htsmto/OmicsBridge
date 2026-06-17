# =============================================================================
# Clinical - View Data: Data Loading
# File: modules/Clinical/02_clinical_ViewData_load.R
# Purpose: Loads expression, survival, metadata, and mutation data files for
#          the selected clinical cohort and exposes them as reactiveVals.
# Edit this file when: changing file parsing logic, adding new data types
#                       (e.g. CNV, methylation), or modifying status messages.
# =============================================================================

viewdata_load_server <- function(input, output, session, dataset_name, ex_path, surv_path, meta_path, mut_path) {
    ## Expression
        # status
            Clinical_View_Geneexpression_status <- reactiveVal()
            output$Clinical_View_Geneexpression_status <- renderText({ Clinical_View_Geneexpression_status() })

        # load the expression data
            gene_expression_data <- reactiveVal(NULL)
            observe({
                # check if the dataset is selected
                if(is.null(dataset_name())){
                    Clinical_View_Geneexpression_status('Please select a clinical dataset to view the gene expression data. A preview table will be shown below.')
                    gene_expression_data(NULL)
                    return(NULL)

                }else{
                    # check if the expression data path is available or the data path exsits
                    if(is.null(ex_path()) || file.exists(ex_path()) == FALSE){
                        Clinical_View_Geneexpression_status('No gene expression data available for this dataset.')
                        gene_expression_data(NULL)
                        return(NULL)
                    }else{
                        # load the expression data
                        gene_expression_data(read.table(ex_path(), sep='\t', header=T, row.names=1, check.names = FALSE))
                        Clinical_View_Geneexpression_status(paste0('The dataset contains ', nrow(gene_expression_data()), ' genes and ', ncol(gene_expression_data()), ' samples.'))
                        return(NULL)
                    }
                }
            })

        #

    ##

    ## Survival
        # status
            Clinical_View_Survival_status <- reactiveVal()
            output$Clinical_View_Survival_status <- renderText({ Clinical_View_Survival_status() })
        #

        # load the survival data
            survival_data <- reactiveVal(NULL)
            observe({
                # check if the dataset is selected
                if(is.null(dataset_name())){
                    Clinical_View_Survival_status('Please select a clinical dataset to view the survival data. A preview table will be shown below.')
                    survival_data(NULL)
                    return(NULL)

                }else{
                    # check if the survival data path is available or the data path exsits
                    if(is.null(surv_path()) || file.exists(surv_path()) == FALSE){
                        Clinical_View_Survival_status('No survival data available for this dataset.')
                        survival_data(NULL)
                        return(NULL)
                    }else{
                        # load the survival data
                        survival_data(read.table(surv_path(), header=T, check.names = FALSE, sep='\t'))
                        Clinical_View_Survival_status(paste0('The dataset contains ', nrow(survival_data()), ' samples.'))
                        return(NULL)
                    }
                }
            })

        #

    ##

    ## Meta data
        # status
            Clinical_View_MetaData_status <- reactiveVal()
            output$Clinical_View_MetaData_status <- renderText({ Clinical_View_MetaData_status() })
        #

        # load the meta data
            meta_data <- reactiveVal(NULL)
            observe({
                # check if the dataset is selected
                if(is.null(dataset_name())){
                    Clinical_View_MetaData_status('Please select a clinical dataset to view the meta data. A preview table will be shown below.')
                    meta_data(NULL)
                    return(NULL)

                }else{
                    # check if the meta data path is available or the data path exsits
                    if(is.null(meta_path()) || file.exists(meta_path()) == FALSE){
                        Clinical_View_MetaData_status('No meta data available for this dataset.')
                        meta_data(NULL)
                        return(NULL)
                    }else{
                        # load the meta data
                        meta_data(read.delim(meta_path(), header=T,check.names = FALSE))
                        Clinical_View_MetaData_status(paste0('The dataset contains ', nrow(meta_data()), ' samples and ', ncol(meta_data()), ' metadata columns.'))
                        return(NULL)
                    }
                }
            })

        #

    ##

    ## Mutation data
        # status
            Clinical_View_mutation_status <- reactiveVal()
            output$Clinical_View_mutation_status <- renderText({ Clinical_View_mutation_status() })
        #

        # load the mutation data
            mutation_data <- reactiveVal(NULL)
            observe({
                # check if the dataset is selected
                if(is.null(dataset_name())){
                    Clinical_View_mutation_status('Please select a clinical dataset to view the mutation data. A preview table will be shown below.')
                    mutation_data(NULL)
                    return(NULL)

                }else{
                    # check if the mutation data path is available or the data path exsits
                    if(is.null(mut_path()) || file.exists(mut_path()) == FALSE){
                        Clinical_View_mutation_status('No mutation data available for this dataset.')
                        mutation_data(NULL)
                        return(NULL)
                    }else{
                        # load the mutation data
                        mutation_data(read.delim(mut_path(), header=T, check.names = FALSE))
                        sample_num <- unique(mutation_data()$sample)
                        Clinical_View_mutation_status(paste0('The dataset contains the mutation information of ', length(sample_num), ' samples'))
                        return(NULL)
                    }
                }
            })

        #

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
