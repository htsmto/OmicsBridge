# =============================================================================
# Tools - Network Plot Server
# File: modules/Tools/06_Tools_NetworkPlot_server.R
# Purpose: Renders an interactive gene/protein interaction network using
#          visNetwork. Fetches interaction data from OmniPathR and allows
#          users to select hub genes and filter by interaction type.
# Edit this file when: changing the interaction database, network layout
#                       algorithm, or node/edge styling.
# Libraries required: OmniPathR, visNetwork, igraph (see libraries_tools.R)
# =============================================================================

# suppressMessages(library(visNetwork))
# suppressMessages(library(igraph))

tools_networkplot_Server  <- function(input, output, session) {
    ## Input and status
        # status
            Network_input_table_visNet_status_input <- reactiveVal(NULL)
            Network_input_table_visNet_status_table <- reactiveVal(NULL)
            Network_input_table_visNet_status_plot <- reactiveVal(NULL)

        # show status
            output$Network_input_table_visNet_status_input <- renderText({ Network_input_table_visNet_status_input() })
            output$Network_input_table_visNet_status_table <- renderText({ Network_input_table_visNet_status_table() })
            output$Network_input_table_visNet_status_plot <- renderText({ Network_input_table_visNet_status_plot() })

        # Input data
            Network_input_data <- reactiveVal(NULL)

    ## 

    ## Data loading
        # observe data loading
            observe({
                # Use example
                if(input$Network_input_example){
                    edges <- data.frame(
                    from = c("STAT1", "STAT1", "STAT1", "STAT1", "STAT2", "STAT2", "STAT2", "STAT3", "STAT3", "STAT3", "STAT3", "STAT5", "STAT5", "STAT5", "STAT3", "STAT5", "STAT1", "STAT2", "STAT2", "STAT3", "STAT1", "STAT2", "STAT3", "STAT5"),
                    to = c("IRF1", "GBP1", "ISG15", "MX1", "ISG15",  "IRF9", "OAS1", "SAA1", "CRP", "VEGF", "MYC", "CSN2", "WAP", "BCL2L1",  "BCL2L1", "CISH", "IL6", "MX1", "IL6", "IL6", "SOCS1", "SOCS1", "SOCS1", "SOCS1"),
                    weight = c(10.0, 5.8, 2.9, 1.7, 10.9,  0.5, 12.0, 5.8, 1.9, 3.7, 1.0, 2.8, 7.9, 1.7, 5.0, 8.8, 6.0, 1.9, 2.9,10.9, 10.0, 5.0, 6.0, 8.0)
                    )
                    Network_input_data(edges)
                    Network_input_table_visNet_status_input('Example data loaded')
                    return()
                }

                # data loading from a file
                if(length(input$Network_input_file) == 0 || is.null(input$Network_input_file)){
                    Network_input_table_visNet_status_input('Please input the data by uploading a file or use the example data')
                    Network_input_data(NULL)
                    return()
                }else{
                    # load data
                    edges <- read.delim(input$Network_input_file$datapath, header = TRUE, stringsAsFactors = FALSE, sep='\t',check.names = FALSE)

                    # check if the data has the required columns
                    required_cols <- c("from", "to", "weight")
                    if(!all(required_cols %in% colnames(edges))){
                        Network_input_table_visNet_status_input('The input data must have three columns: "from", "to" and "weight". Please check your data and try again.')
                        Network_input_data(NULL)
                        return()
                    }

                    # update status
                    Network_input_table_visNet_status_input('Data loaded successfully')
                    Network_input_data(edges)
                    return()
                }

            })

        # show input data table
            output$Network_input_table <- DT::renderDataTable({ 
                if(!is.null(Network_input_data())){
                    datatable(Network_input_data(), options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10)) 
                }else{
                    tmp <- data.frame(list(from=character(0), to=character(0), weight=numeric(0)), stringsAsFactors = FALSE )
                    datatable(tmp, options = list(scrollX = TRUE, scrollY = TRUE, pageLength = 10)) 
                }
            })
    ##

    ## plot
        # show plot
            output$Network_input_table_visNet <- renderVisNetwork({
                # check if the data is loaded
                if(is.null(Network_input_data())){
                    Network_input_table_visNet_status_plot('Please input the data')
                    return(NULL)
                }

                # check if the data has the required columns
                if(length(nrow(Network_input_data()))== 0 ){
                    Network_input_table_visNet_status_plot('Please input the data')
                    return(NULL)
                }

                # make a graph object
                graph <- graph_from_data_frame(Network_input_data(), directed = TRUE)
                V(graph)$size <- igraph::degree(graph)
                V(graph)$size <- 5 + (V(graph)$size - min(V(graph)$size)) / (max(V(graph)$size) - min(V(graph)$size)) * 25
                nodes <- data.frame(id = V(graph)$name, 
                                    label = V(graph)$name, 
                                    size = V(graph)$size)
                nodes$shape <- ifelse(nodes$label %in% unique(Network_input_data()$from), input$Network_input_shape_from, input$Network_input_shape_to)
                nodes$color <- ifelse(nodes$label %in% unique(Network_input_data()$from), input$Network_input_color_from, input$Network_input_color_to)
                edges <- data.frame(from = Network_input_data()$from, 
                                    to = Network_input_data()$to,
                                    width = Network_input_data()$weight)

                # show an arrow 
                if(input$Network_input_arrow){
                    edges$arrows <- 'to'
                }

                # status
                Network_input_table_visNet_status_plot(NULL)

                # plot
                network <- visNetwork(nodes, edges, height = "1000px", width = "100%")
                network <- visOptions(network, highlightNearest = TRUE, nodesIdSelection=TRUE)
                network

            })

        
        # output$Network_input_table_visNet_status <- renderText({'Please input the data'})


}