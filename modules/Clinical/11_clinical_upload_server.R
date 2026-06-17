# =============================================================================
# Clinical - Dataset Upload Server (Orchestrator)
# File: modules/Clinical/11_clinical_upload_server.R
# Purpose: Manages the upload and registration of new clinical cohorts.
#          Workflow:
#            1. Display existing cohorts stored in Clinical_data_database.tsv
#            2. Accept user-uploaded files (expression, survival, metadata,
#               mutation MAF) with validation
#            3. Write valid uploads to the data directory and update the
#               database TSV so the new cohort appears in DataSelection
#            4. Provide a delete / rename interface for existing cohorts
# Edit this file when: changing the upload validation logic, the expected
#                       file format for clinical data, or the database TSV schema.
# =============================================================================

clinical_upload_server <- function(input, output, session){
    source("modules/Clinical/11_clinical_upload_validation.R", local = TRUE)
    source("modules/Clinical/11_clinical_upload_processing.R", local = TRUE)

    vals <- upload_validation_server(input, output, session)

    upload_processing_server(
        input, output, session,
        Clinical_dataset          = vals$Clinical_dataset,
        Clinical_dataset_original = vals$Clinical_dataset_original,
        new_cohort_status         = vals$new_cohort_status,
        gx_table                  = vals$gx_table,
        sur_table                 = vals$sur_table,
        meta_table                = vals$meta_table,
        mut_table                 = vals$mut_table,
        gx_file_path              = vals$gx_file_path,
        sur_file_path             = vals$sur_file_path,
        meta_file_path            = vals$meta_file_path,
        mut_file_path             = vals$mut_file_path
    )
}
