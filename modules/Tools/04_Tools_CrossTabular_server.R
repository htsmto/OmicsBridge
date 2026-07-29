# =============================================================================
# Tools - Cross-Tabular Analysis Server
# File: modules/Tools/04_Tools_CrossTabular_server.R
# Purpose: Creates a contingency table (cross-tabulation) from two categorical
#          metadata columns and runs a chi-squared or Fisher's exact test.
# Edit this file when: changing the statistical test, adding OR/RR calculation,
#                       or modifying the visualisation (mosaic plot, heatmap).
# =============================================================================

tools_crosstabular_Server <- function(input, output, session) {
    ## Initial varialbes
        # Status
            cross_table_status_input <- reactiveVal("Please input the group names and values to create a 2x2 table.")
            cross_table_status <- reactiveVal("Please input the group names and values to create a 2x2 table.")
            Cross_tabulation_plot_status <- reactiveVal("Please input the group names and values to create a 2x2 table.")

        # Contingency table
            cross_table <- reactiveVal(NULL)

        # Plot
            Cross_tabulation_plot <- reactiveVal(NULL)

        # show the status
            output$cross_table_status_input <- renderText({cross_table_status_input()})
            output$cross_table_status <- renderText({cross_table_status()})
            output$Cross_tabulation_plot_status <- renderText({Cross_tabulation_plot_status()})

    ##

    ## Creat a contingency table amd display the table
        # create a table
        observe({
            # check if all the group names are set
            if(length(input$Cross_tabulation_Row1) == 0 || length(input$Cross_tabulation_Row2) == 0 || length(input$Cross_tabulation_col1) == 0 || length(input$Cross_tabulation_col2) == 0){
                cross_table(NULL)
                return()
            }
            
            # check if all the grou names are not empty
             if(input$Cross_tabulation_Row1 == '' || input$Cross_tabulation_Row2 == '' || input$Cross_tabulation_col1 == '' || input$Cross_tabulation_col2 == ''){
                cross_table_status_input("Group names are not set. Please input the group names.")
                cross_table_status <- reactiveVal("Please input the group names and values to create a 2x2 table.")
                cross_table(NULL)
                return()
            }
            
            # check if all the group names are unique, for Row and Column, respectively
            if(input$Cross_tabulation_Row1 == input$Cross_tabulation_Row2){
                cross_table_status_input("Row group names are duplicated. Please make sure the row group names are different.")
                cross_table_status <- reactiveVal("Please input the group names and values to create a 2x2 table.")
                cross_table(NULL)
                return()
            }
            if(input$Cross_tabulation_col1 == input$Cross_tabulation_col2){
                cross_table_status_input("Column group names are duplicated. Please make sure the column group names are different.")
                cross_table_status <- reactiveVal("Please input the group names and values to create a 2x2 table.")
                cross_table(NULL)
                return()
            }

            # if everything is ok, create the contingency table
            tmp <- data.frame(A=c(input$Cross_tabulation_val1,input$Cross_tabulation_val3), B=c(input$Cross_tabulation_val2,input$Cross_tabulation_val4))
            rownames(tmp) <- c(input$Cross_tabulation_Row1, input$Cross_tabulation_Row2)
            colnames(tmp) <- c(input$Cross_tabulation_col1, input$Cross_tabulation_col2)
            cross_table(tmp)
            cross_table_status_input(NULL)
            cross_table_status(NULL)
        })

        # show the table
        output$Cross_tabulation_table <- renderDataTable({
            if(length(cross_table()) == 0 || is.null(cross_table())){
                tmp <- data.frame("Column Group1"=c(0,0), "Column Group2"=c(0,0))
                rownames(tmp) <- c("Row Group1", "Row Group2")
                datatable(tmp)
            }else{
                datatable( cross_table()) 
            }
        })

    ##

    ## Do test
        # test and show the result
        output$cross_table_Statistic <- renderText({
            df_cross <- cross_table()

            # check if the table is created
            if(length(df_cross) == 0 || is.null(df_cross)){
            return('Please input the group names and values first.')
            }

            # if all the values in the table are 0, it is considered as no data
            if(length(df_cross[df_cross==0])==4){
            return('Please input the group names and values first.')
            }

            # perform the test
                if(input$cross_table_Statistic_method == 'A'){
                chi2_res <- chisq.test(df_cross)
                paste0('P-value: ', chi2_res$p.value)
            }else{
                fisher_res <- fisher.test(df_cross)
                paste0('P-value: ',fisher_res$p.value)
            }

        })

    ##

    ## Plot
        # Update the ggplot object
        observe({
            # copy the table
            df_cross <- cross_table()

            # check if the table is created. Check also if all the values in the table are 0, it is considered as no data
            if(length(df_cross) == 0 || is.null(df_cross) || length(df_cross[df_cross==0])==4){
                Cross_tabulation_plot_status('Please input the group names and values first.')
                Cross_tabulation_plot(ggplot())
                return()
            }

            # melt the table for ggplot
            col_group <- colnames(df_cross)
            df_cross$Row_group <- rownames(df_cross)
            df_cross_melt <- pivot_longer(df_cross, cols=-Row_group, names_to = 'Column_group')
            
            # check if the plot method is chosen
            if(length(input$Cross_tabulation_plot_method) == 0){
                Cross_tabulation_plot_status('Please choose the plot method') 
                Cross_tabulation_plot(ggplot())
                return()
            }

            # Plot
            p <- ggplot(df_cross_melt, aes(x=Row_group, y=value, fill=Column_group))    

            # Plot type
            if(input$Cross_tabulation_plot_method == 'A'){ # stack bar plot (percentile)
                p <- p + geom_bar(stat='identity', position='fill')
                p <- p + ylab('Percentage')
            }else if(input$Cross_tabulation_plot_method == 'C'){ # stack bar plot (original count)
                p <- p + geom_bar(stat='identity')
                p <- p + ylab('Count')
            }else if(input$Cross_tabulation_plot_method == 'D'){ # dodge bar plot (original count)
                p <- p + geom_bar(stat='identity', position='dodge')
                p <- p + ylab('Count')
            }

            # other settings
            p <- p + theme(
                    axis.title = element_text(size = input$Cross_tabulation_plot_XY_title.font.size),
                    axis.title.x= element_blank(),
                    axis.text.x = element_text(size = input$Cross_tabulation_plot_X_label.font.size),
                    axis.text.y = element_text(size = input$Cross_tabulation_plot_Y_label.font.size),
                    legend.text = element_text(size = input$Cross_tabulation_plot_legend_size),
                    legend.title = element_blank(),
                    legend.key.size = unit(2, "mm"),
                    legend.margin = margin(-10, 0, 0, 0),legend.spacing.x = unit(0, "mm"),legend.spacing.y = unit(0, "mm"),
                    panel.grid.major = element_line(linewidth = 0.1),
                    panel.grid.minor = element_line(linewidth = 0.05),
                    axis.ticks = element_line(linewidth=0.1),
                    axis.ticks.length = unit(0.5, "pt")
                )

            # colour settings
            colours <- setNames(c(input$Cross_tabulation_plot_col1_colour,input$Cross_tabulation_plot_col2_colour), col_group)
            p <- p + scale_fill_manual(values = colours)

            # white background settings
            if(input$Cross_tabulation_plot_col2_colour_while_background){
                p <- p + theme(
                        panel.grid = element_blank(), 
                        panel.border=element_blank(), 
                        axis.line = element_line(color='black', linewidth=0.1),
                        panel.background = element_rect(fill="white", size=0),
                        panel.grid.major = element_blank(),
                        panel.grid.minor = element_blank()
                    )
            }

            # rotate x label settings
            if(input$Cross_tabulation_plot_rotate_x){
                if(!is.na(input$Cross_tabulation_plot_rotate_x_angle) || input$Cross_tabulation_plot_rotate_x_angle != ''){
                    angle <- as.integer(input$Cross_tabulation_plot_rotate_x_angle) %% 360
                    if( angle %% 90 == 0 ){
                        p <- p + theme(axis.text.x = element_text(angle = angle, vjust = 1, hjust= 0.5))
                    }else{
                        p <- p + theme(axis.text.x = element_text(angle = angle, vjust = 1, hjust= 1))
                    }
                }
            }

            # update the plot status and plot object
            Cross_tabulation_plot_status(NULL)
            Cross_tabulation_plot(p)

        })

        # show the plot
        output$Cross_tabulation_plot <- renderPlot({
            Cross_tabulation_plot()
        }, width=reactive(input$Cross_tabulation_plot.width), height=reactive(input$Cross_tabulation_plot.height), res=300)
    ## 


}