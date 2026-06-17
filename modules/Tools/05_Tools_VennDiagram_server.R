# =============================================================================
# Tools - Venn Diagram Server
# File: modules/Tools/05_Tools_VennDiagram_server.R
# Purpose: Renders a 2- or 3-set Venn diagram from user-supplied gene lists
#          (text input or uploaded files). Outputs the intersection list and
#          a downloadable SVG/PNG plot.
# Edit this file when: changing the number of supported sets, the diagram
#                       library (VennDiagram vs ggVennDiagram), or colour scheme.
# =============================================================================

# suppressMessages(library(eulerr))

tools_venndiagram_Server  <- function(input, output, session) {
    ## Input and status
        # status
            Venn_Diagram_status_input <- reactiveVal(NULL)
            Venn_Diagram_show_overlap_status <- reactiveVal(NULL)
            Venn_Diagram_status_plot <- reactiveVal(NULL)

        # data
            Venn_Diagram_data <- reactiveVal(NULL)
            Overlap_to_show <- reactiveVal(NULL)

        # show the status
            output$Venn_Diagram_status_input <- renderText({ Venn_Diagram_status_input() })
            output$Venn_Diagram_show_overlap_status <- renderText({ Venn_Diagram_show_overlap_status() })
            output$Venn_Diagram_status_plot <- renderText({ Venn_Diagram_status_plot() })

    ##

    ## UI for condiotional panel
        # the conditional panel seems not working
        # input fot the group #3
            output$Venn_Diagram_Group3 <- renderUI({
                if(input$Venn_Diagram_method == 'B'){
                    fluidRow(
                        column(12, textInput(session$ns("Venn_Diagram_Group3_name"), "Group 3 title")),
                        column(12, textAreaInput(session$ns("Venn_Diagram_Group3_element"), "Group 3 element"))
                    )
                }else{
                    return(NULL)
                }
            })

        # Overlap elements (2D)
            output$Venn_Diagram_show_overlap_2D_ui <- renderUI({
                if(input$Venn_Diagram_method == 'A'){
                    fluidRow(
                        column(12, selectInput(session$ns('Venn_Diagram_show_overlap_2D'), 'Choose a category',  
                            c('None'='None', 
                            'in Group1 & Group2', 
                            'only in Group1', 
                            'only in Group2'), selected = 'None')),
                        column(12, verbatimTextOutput(session$ns("Venn_Diagram_show_overlap_2D_list")))
                    )
                }else{
                    return(NULL)
                }
            })

        # Overlap elements (3D)
            output$Venn_Diagram_show_overlap_3D_ui <- renderUI({
                if(input$Venn_Diagram_method == 'B'){
                    fluidRow(
                        column(12, selectInput(session$ns('Venn_Diagram_show_overlap_3D'), 'Choose a category',  
                            c('None'='None', 
                            'in Group1 & Group2 & Group3', 
                            'in Group1 & Group2', 
                            'in Group2 & Group3', 
                            'in Group3 & Group1', 
                            'in Group1 & Group2 but not in Group3', 
                            'in Group2 & Group3 but not in Group1',
                            'in Group3 & Group1 but not in Group2', 
                            'Only in Group1',
                            'Only in Group2',
                            'Only in Group3'), selected = 'None')),
                        column(12, verbatimTextOutput(session$ns("Venn_Diagram_show_overlap_3D_list")))
                    )
                }else{
                    return(NULL)
                }
            })

    ## Setting up the venn data and get overlap
        # Set up the data
            observe({
                # check initialisation
                if(length(input$Venn_Diagram_Group1_name) == 0 || length(input$Venn_Diagram_Group2_name) == 0 || length(input$Venn_Diagram_Group1_element) == 0 || length(input$Venn_Diagram_Group2_element) == 0){
                    return(NULL)
                }

                # when method is not selected
                if(length(input$Venn_Diagram_method) == 0){
                    Venn_Diagram_status_input('Please choose the method.')
                    Venn_Diagram_data(NULL)
                    Overlap_to_show(NULL)
                    return(NULL)
                }

                # when group names or elements are not filled
                if(nchar(input$Venn_Diagram_Group1_name) == 0 || nchar(input$Venn_Diagram_Group2_name) == 0 || nchar(input$Venn_Diagram_Group1_element) == 0 || nchar(input$Venn_Diagram_Group2_element) == 0){
                    Venn_Diagram_status_input('Please fill in the Group names/elements.')
                    Venn_Diagram_data(NULL)
                    Overlap_to_show(NULL)
                    return(NULL)
                }

                # when 3D Venn diagram is selected, check group 3
                if(input$Venn_Diagram_method == 'B'){
                    if(nchar(input$Venn_Diagram_Group3_name) == 0 || nchar(input$Venn_Diagram_Group3_element) == 0){
                        Venn_Diagram_status_input('Please fill in the Group 3 name/element.')
                        Venn_Diagram_data(NULL)
                        Overlap_to_show(NULL)
                        return(NULL)
                    }
                }

                # if all the input is correct, set up the data
                group1_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group1_element, split = "\n")))
                group1_elements <- group1_elements[group1_elements != ''] # remove empty elements
                group2_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group2_element, split = "\n")))
                group2_elements <- group2_elements[group2_elements != ''] # remove empty elements
                tmp <- list(group1_name = group1_elements, group2_name=group2_elements)
                if(input$Venn_Diagram_method == 'B'){ # 3D
                    group3_elements <- unique(unlist(strsplit(input$Venn_Diagram_Group3_element, split = "\n")))
                    group3_elements <- group3_elements[group3_elements != ''] # remove empty elements
                    tmp <- list(group1_name = group1_elements, group2_name=group2_elements, group3_name=group3_elements)
                }
                Venn_Diagram_data(tmp)
                Venn_Diagram_status_input(NULL)
            })

        # Get the overlap to show
            observe({
                # when the data is not set
                if(is.null(Venn_Diagram_data())){
                    Overlap_to_show(NULL)
                    Venn_Diagram_show_overlap_status('Please input the group names/elements first.')
                    return(NULL)
                }

                # start
                venn_data <- Venn_Diagram_data()

                # 2D
                if(input$Venn_Diagram_method == "A"){
                    # When nothing is selected
                    if(length(input$Venn_Diagram_show_overlap_2D) == 0 || input$Venn_Diagram_show_overlap_2D == 'None'){
                        Overlap_to_show(NULL)
                        Venn_Diagram_show_overlap_status('Please choose a category to show the overlap elements.')
                        return(NULL)
                    }

                    # When a category is selected
                    if(input$Venn_Diagram_show_overlap_2D == 'in Group1 & Group2'){
                        overlap <- intersect(venn_data$group1_name, venn_data$group2_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group1 and Group2.'))
                    }else if(input$Venn_Diagram_show_overlap_2D == 'only in Group1'){
                        only_group1 <- setdiff(venn_data$group1_name, venn_data$group2_name)
                        Overlap_to_show(only_group1)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(only_group1), ' elements only in Group1.'))
                    }else if(input$Venn_Diagram_show_overlap_2D == 'only in Group2'){
                        only_group2 <- setdiff(venn_data$group2_name, venn_data$group1_name)
                        Overlap_to_show(only_group2)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(only_group2), ' elements only in Group2.'))
                    }
                }else{ # 3D
                    # When nothing is selected
                    if(length(input$Venn_Diagram_show_overlap_3D) == 0 || input$Venn_Diagram_show_overlap_3D == 'None'){
                        Overlap_to_show(NULL)
                        Venn_Diagram_show_overlap_status('Please choose a category to show the overlap elements.')
                        return(NULL)
                    }

                    # When a category is selected
                    if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2 & Group3'){
                        overlap <- intersect(intersect(venn_data$group1_name, venn_data$group2_name), venn_data$group3_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group1, Group2 and Group3.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2 but not in Group3'){
                        overlap <- setdiff(intersect(venn_data$group1_name, venn_data$group2_name), venn_data$group3_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group1 and Group2 but not in Group3.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group1'){
                        only_group1 <- setdiff(setdiff(venn_data$group1_name, venn_data$group2_name), venn_data$group3_name)
                        Overlap_to_show(only_group1)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(only_group1), ' elements only in Group1.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group2'){
                        only_group2 <- setdiff(setdiff(venn_data$group2_name, venn_data$group1_name), venn_data$group3_name)
                        Overlap_to_show(only_group2)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(only_group2), ' elements only in Group2.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'Only in Group3'){
                        only_group3 <- setdiff(setdiff(venn_data$group3_name, venn_data$group1_name), venn_data$group2_name)
                        Overlap_to_show(only_group3)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(only_group3), ' elements only in Group3.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group2 & Group3 but not in Group1'){
                        overlap <- setdiff(intersect(venn_data$group2_name, venn_data$group3_name), venn_data$group1_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group2 and Group3 but not in Group1.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group3 & Group1 but not in Group2'){
                        overlap <- setdiff(intersect(venn_data$group3_name, venn_data$group1_name), venn_data$group2_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group3 and Group1 but not in Group2.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group1 & Group2'){
                        overlap <- intersect(venn_data$group1_name, venn_data$group2_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group1 and Group2.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group2 & Group3'){
                        overlap <- intersect(venn_data$group2_name, venn_data$group3_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group2 and Group3.'))
                    }else if(input$Venn_Diagram_show_overlap_3D == 'in Group3 & Group1'){
                        overlap <- intersect(venn_data$group3_name, venn_data$group1_name)
                        Overlap_to_show(overlap)
                        Venn_Diagram_show_overlap_status(paste0('There are ', length(overlap), ' elements in the overlap of Group3 and Group1.'))
                    }
                }
                
            })

        # show the overlap
            # 2D
            output$Venn_Diagram_show_overlap_2D_list <- renderText({
                if(is.null(Overlap_to_show())){
                    return(NULL)
                }else{
                    paste(Overlap_to_show(), collapse='\n')
                }
            })

            # 3D
            output$Venn_Diagram_show_overlap_3D_list <- renderText({
                if(is.null(Overlap_to_show())){
                    return(NULL)
                }else{
                    paste(Overlap_to_show(), collapse='\n')
                }
            })

    ##

    ## Plot
        # plot
        output$Venn_Diagram_plot <- renderPlot({
            # copy
            Venn_data <- Venn_Diagram_data()

            # when the data is not set, return NULL
            if(is.null(Venn_data)){
                Venn_Diagram_status_plot('Please input the group names/elements first.')
                return(ggplot())
            }

            # convert to euler data
            euler_data <- euler(Venn_data)
            Venn_Diagram_status_plot(NULL)

            # plot
            if(input$Venn_Diagram_method == 'A'){
              plot(euler_data,
                fills = list(fill=c(input$Venn_Diagram_plot_col1_colour, input$Venn_Diagram_plot_col2_colour), alpha=0.7),
                quantities = list(cex = input$Venn_Diagram_plot_label.font.size),
                legend = list(labels = c(input$Venn_Diagram_Group1_name, input$Venn_Diagram_Group2_name), cex = input$Venn_Diagram_plot_legend_size)
              )
            }else if(input$Venn_Diagram_method == 'B'){
              plot(euler_data,
                fills = list(fill=c(input$Venn_Diagram_plot_col1_colour, input$Venn_Diagram_plot_col2_colour, input$Venn_Diagram_plot_col3_colour), alpha=0.7),
                quantities = list(cex = input$Venn_Diagram_plot_label.font.size),
                legend = list(labels = c(input$Venn_Diagram_Group1_name, input$Venn_Diagram_Group2_name, input$Venn_Diagram_Group3_name), cex = input$Venn_Diagram_plot_legend_size)
              )
            }
        }, width=reactive(input$Venn_Diagram_plot.width), height=reactive(input$Venn_Diagram_plot.height), res=300)

}