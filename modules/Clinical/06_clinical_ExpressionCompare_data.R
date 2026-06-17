# =============================================================================
# Clinical - Expression Comparison: Data Preparation
# File: modules/Clinical/06_clinical_ExpressionCompare_data.R
# Purpose: Handles data prep, gene input, and group selection for expression
#          comparison. Returns reactive values consumed by the plot sub-server.
# Edit this file when: changing gene input logic, group/subtype selection UI,
#                       or the pivot table construction before the statistical test.
# =============================================================================

expr_compare_data_server <- function(input, output, session, Gene_expression, Meta_data, Custom_genesets) {
    ## Input and Settings ----
        ## Input genes
            Gene_expression_gene <- reactiveVal(NULL)

            # status
                Expression_subtype_genes_status <- reactiveVal(NULL)
                output$Expression_subtype_genes_status <- renderText({ Expression_subtype_genes_status() })
            #

            # manual gene input. If the checkbox is checked, disable the manual gene input; if unchecked, enable the manual gene input.
                output$Expression_subtype_genes <- renderUI({ textAreaInput(session$ns("Expression_subtype_genes"), "Enter genes names", placeholder = "GeneA\nGeneB\nGeneC", width = '100%') })
                observe({
                    if(length(input$Expression_subtype_genes_from_custom_geneset) > 0 && input$Expression_subtype_genes_from_custom_geneset == TRUE){
                        shinyjs::disable("Expression_subtype_genes")
                    } else {
                        shinyjs::enable("Expression_subtype_genes")
                    }
                })

            #

            # custom gene select button. Open when the user click the checkbox "Use the genes from a custom gene set"
                output$Expression_subtype_genes_from_custom_geneset_select <- renderUI({
                    if(length(input$Expression_subtype_genes_from_custom_geneset) > 0 && input$Expression_subtype_genes_from_custom_geneset == TRUE){
                        gene_sets_names <- c(Custom_genesets$Geneset.name)
                        selectInput(session$ns('Expression_subtype_genes_from_custom_geneset_select'), 'Select a custom geneset',  c('None'='None', gene_sets_names))
                    } else {
                        return(NULL)
                    }
                })

            #

            # Set the input genes
                observe({
                    if(length(input$Expression_subtype_genes) == 0 || length(input$Expression_subtype_genes_from_custom_geneset) == 0){
                        Gene_expression_gene(NULL)
                        Expression_subtype_genes_status(NULL)
                        return(NULL)
                    }else if(input$Expression_subtype_genes_from_custom_geneset == FALSE){
                        # custom select: off -> manual

                        if(all(grepl("^\\s*$", input$Expression_subtype_genes))){
                            Expression_subtype_genes_status('Please enter gene names in the box above, one gene per line.')
                            Gene_expression_gene(NULL)
                            return(NULL)
                        }

                        # when there are gene names inputted
                        genes_tmp <- unique(unlist(strsplit(input$Expression_subtype_genes, split="\n")))
                        genes_tmp <- genes_tmp[!grepl("^\\s*$", genes_tmp)] # remove empty gene names
                        Gene_expression_gene(genes_tmp)
                        Expression_subtype_genes_status(paste0("You have manually input ", length(Gene_expression_gene()), " gene(s)."))

                    }else if(input$Expression_subtype_genes_from_custom_geneset == TRUE){
                        # custom select: on -> custom geneset
                        if(length(input$Expression_subtype_genes_from_custom_geneset_select) == 0 || input$Expression_subtype_genes_from_custom_geneset_select == 'None'){
                            Expression_subtype_genes_status("Please select a custom geneset above first.")
                            Gene_expression_gene(NULL)
                            return(NULL)
                        }

                        genes <- strsplit(Custom_genesets[Custom_genesets$Geneset.name %in% input$Expression_subtype_genes_from_custom_geneset_select, ]$Genes, split=', ')[[1]]
                        Gene_expression_gene(genes)
                        Expression_subtype_genes_status(paste0("You have input ", length(Gene_expression_gene()), " gene(s) from your selected custom geneset."))

                    }
                })
            #
        ##

        ## Group category
            # UI
                output$Expression_subtype_groupBy <- renderUI({
                    if(length(Meta_data()) == 0 || is.null(Meta_data())){
                        selectInput(session$ns('Expression_subtype_groupBy'), 'Group by', c('--Please choose a cohort first--'='None'))
                    }else{
                        selectInput(session$ns('Expression_subtype_groupBy'), 'Group by', c('None'='None', colnames(Meta_data())))
                    }
                })
            #

            # status
                Expression_subtype_subtype_number <- reactiveVal(NULL)
                output$Expression_subtype_subtype_number <- renderText({ Expression_subtype_subtype_number() })
            #

            # check how many subtypes there are
                observe({
                    if(length(input$Expression_subtype_groupBy) == 0 || input$Expression_subtype_groupBy =='None'){
                        Expression_subtype_subtype_number('Please select a category for grouping the samples.')
                    }else{
                        tmp <- unlist(unique(Meta_data()[input$Expression_subtype_groupBy]))
                        tmp <- tmp[tmp!='']
                        tmp <- na.omit(tmp) # length(Meta_data[group_by][is.na(Meta_data[group_by])])
                        num_blanck <- length(Meta_data()[input$Expression_subtype_groupBy][Meta_data()[input$Expression_subtype_groupBy]==''])
                        num_na <- length(Meta_data()[input$Expression_subtype_groupBy][is.na(Meta_data()[input$Expression_subtype_groupBy])])
                        num_nd <- num_blanck + num_na
                        Expression_subtype_subtype_number(paste0("There are ", length(tmp), " subtypes in total. (", num_nd, " samples with blank or NA value)"))
                    }
                })

            #

            # when the user choose to use only two subtypes
                            # column(12, materialSwitch(ns('Expression_subtype_choose_two_subtypes_only'), 'Want to compare only two subtypes?', value=FALSE, status='info') ),
                            # column(12, htmlOutput(ns('Expression_subtype_choose_two_subtypes_only_select')))
                Expression_subtype_choose_two_subtypes_only_select_status <- reactiveVal(NULL)
                output$Expression_subtype_choose_two_subtypes_only_select_status <- renderText({ Expression_subtype_choose_two_subtypes_only_select_status() })
                two_subtype_only_flag <- reactiveVal(FALSE)

                output$Expression_subtype_choose_two_subtypes_only_select <- renderUI({
                    if(length(input$Expression_subtype_choose_two_subtypes_only) == 0 || input$Expression_subtype_choose_two_subtypes_only == FALSE){
                        Expression_subtype_choose_two_subtypes_only_select_status(NULL)
                        two_subtype_only_flag(FALSE)
                        return(NULL)
                    } else {
                        if(length(input$Expression_subtype_groupBy) == 0 || input$Expression_subtype_groupBy =='None'){
                            Expression_subtype_choose_two_subtypes_only_select_status('Please select a category for grouping the samples first.')
                            two_subtype_only_flag(FALSE)
                            return(NULL)
                        }else{
                            group_by_category <- input$Expression_subtype_groupBy
                            subtypes <- unique(Meta_data()[, group_by_category])
                            subtypes <- subtypes[!grepl("^\\s*$", subtypes)] # remove blank subtypes
                            subtypes <- subtypes[!is.na(subtypes)] # remove NA subtypes
                            if(length(subtypes) <= 2){
                                Expression_subtype_choose_two_subtypes_only_select_status('Not enough subtypes to compare.')
                                two_subtype_only_flag(FALSE)
                                return(NULL)
                            }else{
                                Expression_subtype_choose_two_subtypes_only_select_status(NULL)
                                two_subtype_only_flag(TRUE)
                                fluidRow(
                                    column(6, selectInput(session$ns('Expression_subtype_choose_two_subtypes_only_select_1'), 'Select subtype 1', c('None'='None', subtypes))),
                                    column(6, selectInput(session$ns('Expression_subtype_choose_two_subtypes_only_select_2'), 'Select subtype 2', c('None'='None', subtypes)))
                                )
                            }
                        }
                    }
                })
            #

        ##

    ##

    ## Start test
        # status
            Expression_subtype_status <- reactiveVal(NULL)
            output$Expression_subtype_status <- renderText({ Expression_subtype_status() })
        #

        # start
            isCalculating <- reactiveVal(FALSE)
            Expression_compare_test_result_table <- reactiveVal(NULL)
            Expression_compare_pivot_table_for_plot <- reactiveVal(NULL)
            observeEvent(input$Expression_subtype_start,{ # make a pivot table for the test
                isCalculating(TRUE)

                # when the metadata is not loaded
                    if(length(Meta_data()) == 0 || is.null(Meta_data())){
                        show_alert(title='Error.',text='Please load the cohort first.', type='error')
                        Expression_subtype_status('Please load the cohort first.')
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # when no input gene
                    if(length(Gene_expression_gene()) == 0 || is.null(Gene_expression_gene())){
                        show_alert(title='Error.',text='Please input genes or select a custom gene set.', type='error')
                        Expression_subtype_status('Please input genes or select a custom gene set.')
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # when the group by category is not selected
                    if(length(input$Expression_subtype_groupBy) == 0 || input$Expression_subtype_groupBy =='None'){
                        show_alert(title='Error.',text='Please select a category for grouping the samples.', type='error')
                        Expression_subtype_status('Please select a category for grouping the samples.')
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # extract the sample with category information, remove the samples with NA or blank value in the selected category
                    df_meta <- Meta_data()
                    group_by <- input$Expression_subtype_groupBy
                    df_meta_subtype <- df_meta[, c('sample', group_by)] # head(df_meta_subtype)
                    df_meta_subtype <- df_meta_subtype[!is.na(df_meta_subtype[,group_by]),]
                    df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] != '',]
                    df_meta_subtype[,group_by] <- as.character(df_meta_subtype[,group_by])

                    # if you selected to compare only two subtypes, further filter the samples to keep only the two selected subtypes
                        if(length(input$Expression_subtype_choose_two_subtypes_only) > 0 && input$Expression_subtype_choose_two_subtypes_only == TRUE){
                            if(length(input$Expression_subtype_choose_two_subtypes_only_select_1) == 0 || length(input$Expression_subtype_choose_two_subtypes_only_select_2) == 0 || input$Expression_subtype_choose_two_subtypes_only_select_1 == 'None' || input$Expression_subtype_choose_two_subtypes_only_select_2 == 'None'){
                                show_alert(title='Error.',text='Please select two subtypes to compare.', type='error')
                                Expression_subtype_status('Please select two subtypes to compare.')
                                isCalculating(FALSE)
                                return(NULL)
                            } else {
                                if(two_subtype_only_flag() == TRUE){
                                    subtype1 <- input$Expression_subtype_choose_two_subtypes_only_select_1
                                    subtype2 <- input$Expression_subtype_choose_two_subtypes_only_select_2
                                    df_meta_subtype <- df_meta_subtype[df_meta_subtype[,group_by] %in% c(subtype1, subtype2),]
                                }
                            }
                        }
                #

                # when the category is only one, show error and stop
                    if(length(unique(df_meta_subtype[,group_by])) == 1){
                        show_alert(title='Error.',text='There is only one subgroup for the selected category. We cannot perform the comparison. Please try with other categories.', type='error')
                        Expression_subtype_status('There is only one subgroup for the selected category. We cannot perform the comparison. \nPlease try with other categories.')
                        isCalculating(FALSE)
                        return(NULL)
                    }
                #

                # get the gene expression data
                    df_geneEx <- Gene_expression()
                    genes <- intersect(Gene_expression_gene(), rownames(df_geneEx))
                    not_found_genes <- setdiff(Gene_expression_gene(), rownames(df_geneEx))

                    # when no gene is found in the dataset, show error and stop
                        if(length(genes) == 0){
                            show_alert(title='Error.',text='None of the inputted genes are included in the dataset. Please make sure the gene names are correct and do not include unnecessary spaces.', type='error')
                            Expression_subtype_status('None of the inputted genes are included in the dataset. \nPlease make sure the gene names are correct and do not include unnecessary spaces.')
                            isCalculating(FALSE)
                            return(NULL)
                        }
                    #

                    df_gene_EX_gene <- data.frame(t(df_geneEx[genes,])) # head(df_gene_EX_gene)genes='CXCL10'
                    df_gene_EX_gene$sample <- rownames(df_gene_EX_gene)
                #


                # merge the meta data with the gene expression data, make a pivot table for the test
                    df_tmp <- merge(df_gene_EX_gene, df_meta_subtype, by='sample') # head(df_tmp)
                    df_out <- df_tmp %>% pivot_longer(cols=all_of(genes), names_to='Genes', values_to='Expression') # head(df_out)

                #

                # Do test
                # if subtypes are more than 2, do kruskal-wallis test; if there are only 2 subtypes, do wilcox test.

                    if(length(unique(df_meta_subtype[,group_by])) == 2){ # when 2 subtypes
                        df_test <- data.frame('Gene'=c(), 'Statistic (Wilcoxon)'=c(), 'P.value'=c())
                        for (gene in genes){
                            # wilcox.test
                            df_out_tmp <- df_out[df_out$Genes == gene,]
                            group1 <- df_out_tmp[df_out_tmp[,group_by] == unique(unlist(df_out[,group_by]))[1],]$Expression
                            group2 <- df_out_tmp[df_out_tmp[,group_by] == unique(unlist(df_out[,group_by]))[2],]$Expression
                            df_test_tmp <- wilcox.test(group1, group2) # str(df_test)
                            p <- df_test_tmp$p.value
                            statistic <- df_test_tmp$statistic
                            tmp <- data.frame('Gene'=gene, 'Statistic (Wilcoxon)'=statistic, 'P.value'=p)
                            df_test <- rbind(df_test, tmp)
                        }
                    }else{
                        df_test <- data.frame('Gene'=c(), 'Statistic (Kruskal-Wallis)'=c(), 'P.value'=c())
                        for (gene in genes){
                            # kruskal.test
                            df_out_tmp <- df_out[df_out$Genes == gene,]
                            df_test_tmp <- kruskal.test(as.formula(paste('Expression', '~', group_by)), data=df_out_tmp) # str(df_test)
                            p <- df_test_tmp$p.value
                            statistic <- df_test_tmp$statistic
                            tmp <- data.frame('Gene'=gene, 'Statistic (Kruskal-Wallis)'=statistic, 'P.value'=p)
                            df_test <- rbind(df_test, tmp)
                        }
                    }
                    df_test <- df_test[order(df_test$`P.value`),] # order by p value
                    rownames(df_test) <- NULL
                    Expression_compare_test_result_table(df_test)
                    Expression_compare_pivot_table_for_plot(df_out)
                #

                # update the status. Tell the user how many genes are included in the test and how many genes are not found in the dataset in which category and how many subtypes are included in the test.
                # also, tell the method used for the test (kruskal-wallis or wilcox) based on the number of subtypes.
                # if some genes are not found, show the gene names as well
                    message <- paste0(
                        "You compared ", length(genes), " gene(s) between subtypes. \n",
                        "The grouping category is '", group_by, "' which includes ", length(unique(df_meta_subtype[,group_by])), " subtypes. \n",
                        "The test used is ", ifelse(length(unique(df_meta_subtype[,group_by])) == 2, "Wilcoxon test.", "Kruskal-Wallis test."), "\n\n",
                        if(length(not_found_genes) > 0){
                            paste(length(not_found_genes), " gene(s) that you inputted are not found in the dataset: \n", paste(not_found_genes, collapse=', '), ". ")
                        }
                    )
                    Expression_subtype_status(message)

                    isCalculating(FALSE)
                    return()
                #


            })
        #

    ##

    return(list(
        isCalculating                       = isCalculating,
        Expression_compare_test_result_table = Expression_compare_test_result_table,
        Expression_compare_pivot_table_for_plot = Expression_compare_pivot_table_for_plot
    ))
}
