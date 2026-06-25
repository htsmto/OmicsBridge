# =============================================================================
# IntegrateTwoDataset - Side-By-Side View: Data
# File: modules/IntegrateTwoDataset/01_IntegrateTwoDataset_SideBySide_data.R
# Purpose: Handles dataset loading, UI selectors for Data1 and Data2,
#          gene matching between datasets, and outlier selection logic.
# Edit this file when: changing dataset loading logic, the synchronisation
#                       of the two dataset selectors, or gene selection methods.
# =============================================================================

side_by_side_data_server <- function(input, output, session) {
    ## Input, Data selection
        # inital
            Dataset <- reactiveVal({data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE))})
        #

        # reload database
            observeEvent(input$reload_database, {
                Dataset(data.frame(read.delim('data/Database.tsv', sep='\t', header=T,check.names = FALSE)))
            })
        #

        # direction select
            Integrate_data_map_direction_note <- reactiveVal(NULL)
            output$Integrate_data_map_direction_note <- renderText({Integrate_data_map_direction_note()})

            observe({
                # column(5, radioButtons(ns("Integrate_data_map_direction"), "", choices = c('See the selected genes from Data1 onto Data2'='A', 'See the selected genes from Data2 onto Data1'='B'), selected='A')),
                # A -> Genes selected in Data1 will be highlighted in Data2
                # B -> Genes selected in Data2 will be highlighted in Data1
                if(input$Integrate_data_map_direction == 'A'){
                    Integrate_data_map_direction_note("Genes selected in Data1 will be highlighted in Data2")
                }else if(input$Integrate_data_map_direction == 'B'){
                    Integrate_data_map_direction_note("Genes selected in Data2 will be highlighted in Data1")
                }
            })
        #

        # UI
            # functions
                # data selection function
                    dataset_select_button_creation <- function(df_tmp, Name, Seuqenced_by, Experiments, Data_type ){
                        req(df_tmp)
                        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
                        if(length(Seuqenced_by) == 0 || length(Experiments) || length(Data_type) == 0){
                            return(selectInput(session$ns(Name), 'Dataset select', c('None'='None', unique(df_tmp$Dataset)) ))
                        }

                        if(length(Seuqenced_by)!= 0 || Seuqenced_by!='None'){
                            df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by,]
                            tmp <- unique(df_tmp$Dataset)
                        }else if(length(Experiments)!=0 || Experiments!='None'){
                            df_tmp <- df_tmp[df_tmp$Experiment == Experiments,]
                            tmp <- unique(df_tmp$Dataset)
                        }else if(length(Data_type)!=0 || Data_type!='None'){
                            df_tmp <- df_tmp[df_tmp$Data.type == Data_type,]
                            tmp <- unique(df_tmp$Dataset)
                        }else{
                            tmp <- NULL
                        }
                        selectInput(session$ns(Name), 'Dataset select', c('None'='None', tmp))
                    }
                #

                # data from who
                    Seuqenced_by_select_button_creation <- function(df_tmp,Name){
                        req(df_tmp)
                        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
                        selectInput(session$ns(Name), 'Data from', c('None'= 'None', unique(df_tmp$Data.from)))
                    }
                #

                # data from which experiment
                    Experiments_select_button_creation <- function(df_tmp,Name,Seuqenced_by ){
                        req(df_tmp)
                        req(Seuqenced_by)
                        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
                        if(length(Seuqenced_by) != 0 || Seuqenced_by!='None'){
                            df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by, ]
                            tmp <- unique(df_tmp$Experiment)
                        }else{
                            tmp <- NULL
                        }
                        selectInput(session$ns(Name), 'Experiment', c('None'= 'None', tmp))
                    }
                #

                # data type function
                    Data_type_select_button_creation <- function(df_tmp,Name,Seuqenced_by, Experiments ){
                        req(df_tmp)
                        req(Seuqenced_by)
                        req(Experiments)
                        df_tmp <- df_tmp[df_tmp$Data.Class == 'B',]
                        if(length(Seuqenced_by)!=0 || Seuqenced_by!='None'){
                            df_tmp <- df_tmp[df_tmp$Data.from == Seuqenced_by,]
                            tmp <- unique(df_tmp$Data.type)
                        }else if(length(Experiments)!=0 || Experiments!='None'){
                            df_tmp <- df_tmp[df_tmp$Experiment == Experiments,]
                            tmp <- unique(df_tmp$Data.type)
                        }else{
                            tmp <- unique(df_tmp$Data.type)
                        }
                        selectInput(session$ns(Name), 'Data type', c('None'= 'None', tmp))
                    }
                #

                # data loading
                    data_load <- function(selected_data){
                        if(length(selected_data) == 0 || selected_data == 'None'){
                            return(NULL)
                        }else{
                            path <- Dataset()[Dataset()$Dataset == selected_data, ]$Path
                            if(file.exists(path)){
                                df_tmp <- read.table(path, sep='\t', header=T,check.names = FALSE)
                                df_tmp <- replace_infinite_values_df(df_tmp)
                                return(df_tmp)
                            }else{
                                return(NULL)
                            }
                        }
                    }
                #


                # select X and Y
                    Select_x <- function(df_tmp, object_name){
                        if(length(df_tmp) == 0 || is.null(df_tmp)){
                            X_axis_name <- c()
                        }else{
                            X_axis_name <- colnames(df_tmp)
                        }
                        selectInput(session$ns(object_name), 'x', c('None'='None', X_axis_name))
                    }
                    Select_y <- function(df_tmp, object_name){
                        if(length(df_tmp) == 0 || is.null(df_tmp)){
                            Y_axis_name <- c()
                        }else{
                            Y_axis_name <- colnames(df_tmp)
                        }
                        selectInput(session$ns(object_name), 'y', c('None'='None', Y_axis_name))
                    }
                #
            #

            # selection and filtering button
                # Data1
                    output$Integrate_data1_Seuqenced_by <- renderUI({ Seuqenced_by_select_button_creation(Dataset(), 'Integrate_data1_Seuqenced_by') })
                    output$Integrate_data1_Experiments <- renderUI({ Experiments_select_button_creation(Dataset(), 'Integrate_data1_Experiments', input$Integrate_data1_Seuqenced_by) })
                    output$Integrate_data1_Data_type <- renderUI({ Data_type_select_button_creation(Dataset(), 'Integrate_data1_Data_type', input$Integrate_data1_Seuqenced_by, input$Integrate_data1_Experiments) })
                    output$Integrate_data1_select <- renderUI({ dataset_select_button_creation(Dataset(), 'Integrate_data1_select', input$Integrate_data1_Seuqenced_by, input$Integrate_data1_Experiments, input$Integrate_data1_Data_type) })
                #

                # Data2
                    output$Integrate_data2_Seuqenced_by <- renderUI({ Seuqenced_by_select_button_creation(Dataset(), 'Integrate_data2_Seuqenced_by') })
                    output$Integrate_data2_Experiments <- renderUI({ Experiments_select_button_creation(Dataset(), 'Integrate_data2_Experiments', input$Integrate_data2_Seuqenced_by) })
                    output$Integrate_data2_Data_type <- renderUI({ Data_type_select_button_creation(Dataset(), 'Integrate_data2_Data_type', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments) })
                    output$Integrate_data2_select <- renderUI({ dataset_select_button_creation(Dataset(), 'Integrate_data2_select', input$Integrate_data2_Seuqenced_by, input$Integrate_data2_Experiments, input$Integrate_data2_Data_type) })
                #
            #
        #

        # data loading reactives
            df_data1 <- reactive({ data_load(input$Integrate_data1_select) })
            df_data2 <- reactive({ data_load(input$Integrate_data2_select) })
        #

        # X and Y (data1 and data2)
            output$Integrate_data1_Scat.X <- renderUI({ Select_x(df_data1(), 'Integrate_data1_Scat.X') })
            output$Integrate_data2_Scat.X <- renderUI({ Select_x(df_data2(), 'Integrate_data2_Scat.X') })
            output$Integrate_data1_Scat.Y <- renderUI({ Select_y(df_data1(), 'Integrate_data1_Scat.Y') })
            output$Integrate_data2_Scat.Y <- renderUI({ Select_y(df_data2(), 'Integrate_data2_Scat.Y') })
        #

        # get outliers (function). Return the extracted dataframe from the data-mapping side.
            get_outliers <- function(df_main_plot, X_thr_method, Y_thr_method, selected_x, selected_y, x_threshold_1, x_threshold_2, y_threshold_1, y_threshold_2, method, brush_point){

                # when the data is no loaded
                    if(is.null(df_main_plot)){
                        return(NULL)
                    }
                #

                # If X and Y are not selected, no graph will be plotted, and no genes will be selected.
                    if(selected_x=='None' || selected_y=='None'){
                        return(NULL)
                    }
                #

                # A = set the threshold to select genes
                if(method=='A'){
                    if(X_thr_method == 'A' & Y_thr_method == 'A'){ # both X and Y are none
                        return(NULL)
                    }else{
                        df_main_plot_thre <- switch(X_thr_method,
                            "A" = df_main_plot,
                            "B" = df_main_plot[df_main_plot[selected_x] > x_threshold_1, ],
                            "C" = df_main_plot[df_main_plot[selected_x] < x_threshold_2, ],
                            "D" = df_main_plot[(df_main_plot[selected_x] > x_threshold_2) & (df_main_plot[selected_x] < x_threshold_1), ],
                            "E" = df_main_plot[(df_main_plot[selected_x] < x_threshold_2) | (df_main_plot[selected_x] > x_threshold_1), ],
                        )
                        df_main_plot_thre <- switch(Y_thr_method,
                            "A" = df_main_plot_thre,
                            "B" = df_main_plot_thre[df_main_plot_thre[selected_y] > y_threshold_1, ],
                            "C" = df_main_plot_thre[df_main_plot_thre[selected_y] < y_threshold_2, ],
                            "D" = df_main_plot_thre[(df_main_plot_thre[selected_y] > y_threshold_2) & (df_main_plot_thre[selected_y] < y_threshold_1), ],
                            "E" = df_main_plot_thre[(df_main_plot_thre[selected_y] < y_threshold_2) | (df_main_plot_thre[selected_y] > y_threshold_1), ],
                        )
                        return(df_main_plot_thre)
                    }
                }else{ # B = brush points on the plot to select genes
                    brushedPoints(df_main_plot, brush_point, xvar = selected_x, yvar = selected_y)
                }
            }
        #

        # get outlisers (return: dataframe)
            data1_outliers <- reactive({ get_outliers(df_data1(), input$Integrate_data1_thr_X_method, input$Integrate_data1_thr_Y_method, input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, input$Integrate_data1_thr_X1, input$Integrate_data1_thr_X2, input$Integrate_data1_thr_Y1, input$Integrate_data1_thr_Y2, input$Integrate_data1_Gene_selection, input$Integrate_data1_plot_brush) })
            data2_outliers <- reactive({ get_outliers(df_data2(), input$Integrate_data2_thr_X_method, input$Integrate_data2_thr_Y_method, input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, input$Integrate_data2_thr_X1, input$Integrate_data2_thr_X2, input$Integrate_data2_thr_Y1, input$Integrate_data2_thr_Y2, input$Integrate_data2_Gene_selection, input$Integrate_data2_plot_brush) })
        #

        # show selected gene numbers
            Integrate_data1_selected_gene_num <- reactiveVal(NULL)
            Integrate_data2_selected_gene_num <- reactiveVal(NULL)
            output$Integrate_data1_selected_gene_num <- renderText({ Integrate_data1_selected_gene_num() })
            output$Integrate_data2_selected_gene_num <- renderText({ Integrate_data2_selected_gene_num() })

            show_select_status <- function(method, X_filter, Y_filter, X1, X2, Y1, Y2){
                if(method=='B'){
                    return("Select genes by brushing points on the plot.")
                }else{
                    X_status <- switch(X_filter,
                        "A" = 'X: None; ',
                        "B" = paste0('X > ', X1, '; '),
                        "C" = paste0('X < ', X2, '; '),
                        "D" = paste0('X > ', X2, ' & X < ', X1, '; '),
                        "E" = paste0('X < ', X2, ' | X > ', X1, '; '),
                    )
                    Y_status <- switch(Y_filter,
                        "A" = 'Y: None.',
                        "B" = paste0('Y > ', Y1, '.'),
                        "C" = paste0('Y < ', Y2, '.'),
                        "D" = paste0('Y > ', Y2, ' & Y < ', Y1, '.'),
                        "E" = paste0('Y < ', Y2, ' | Y > ', Y1, '.'),
                    )
                    return(paste0("Select genes by ", X_status, Y_status))
                }
            }

            observe({
                if(length(data1_outliers()) == 0 || is.null(data1_outliers())){
                    Integrate_data1_selected_gene_num("Slected gene numbers: 0\n\n(Please load a dataset, and select the X and Y. \nThen  select genes on the plot.)")
                }else{
                    # show the number of selected genes, the thresholds and the method used for selection can be added in the future.
                    method_and_setting <- show_select_status(input$Integrate_data1_Gene_selection, input$Integrate_data1_thr_X_method, input$Integrate_data1_thr_Y_method, input$Integrate_data1_thr_X1, input$Integrate_data1_thr_X2, input$Integrate_data1_thr_Y1, input$Integrate_data1_thr_Y2)
                    Integrate_data1_selected_gene_num(paste0('Slected gene numbers: ', length(data1_outliers()$id), '\n\n', method_and_setting))
                }
            })

            observe({
                if(length(data2_outliers()) == 0 || is.null(data2_outliers())){
                    Integrate_data2_selected_gene_num("Slected gene numbers: 0\n\n(Please load a dataset, and select the X and Y. \nThen  select genes on the plot.)" )
                }else{
                    method_and_setting <- show_select_status(input$Integrate_data2_Gene_selection, input$Integrate_data2_thr_X_method, input$Integrate_data2_thr_Y_method, input$Integrate_data2_thr_X1, input$Integrate_data2_thr_X2, input$Integrate_data2_thr_Y1, input$Integrate_data2_thr_Y2)
                    Integrate_data2_selected_gene_num(paste0('Slected gene numbers: ', length(data2_outliers()$id), '\n\n', method_and_setting))
                }
            })

        #

        # get outliers (duplicate reactive from original – preserved as-is)
            data1_outliers <- reactive({ get_outliers(df_data1(), input$Integrate_data1_thr_X_method, input$Integrate_data1_thr_Y_method, input$Integrate_data1_Scat.X, input$Integrate_data1_Scat.Y, input$Integrate_data1_thr_X1, input$Integrate_data1_thr_X2, input$Integrate_data1_thr_Y1, input$Integrate_data1_thr_Y2, input$Integrate_data1_Gene_selection, input$Integrate_data1_plot_brush) })
            data2_outliers <- reactive({ get_outliers(df_data2(), input$Integrate_data2_thr_X_method, input$Integrate_data2_thr_Y_method, input$Integrate_data2_Scat.X, input$Integrate_data2_Scat.Y, input$Integrate_data2_thr_X1, input$Integrate_data2_thr_X2, input$Integrate_data2_thr_Y1, input$Integrate_data2_thr_Y2, input$Integrate_data2_Gene_selection, input$Integrate_data2_plot_brush) })
        #

    return(list(
        df_data1       = df_data1,
        df_data2       = df_data2,
        data1_outliers = data1_outliers,
        data2_outliers = data2_outliers
    ))
}
