scRNA_Feature_ui <- function(ns) {
    fluidRow(
        # Inputs and Setting
        column(4,
            box(width=12, status='info', title='Inputs and Settings',collapsible=TRUE, 
                fluidRow(
                    column(12, helpText(HTML("You can draw a feature plot to show the expression of a gene across all the cells in the UMAP plot here."))),
                    column(12, htmlOutput(ns("scRNA_FeaturePlot_gene"))),
                    column(12, materialSwitch(ns('scRNA_FeaturePlot_gene_from_custom_geneset'), 'Use genes from a custom gene set', value=FALSE, status='info') ),
                    conditionalPanel(condition = paste0("input['", ns("scRNA_FeaturePlot_gene_from_custom_geneset"), "'] == true"),
                        column(12, htmlOutput(ns('scRNA_FeaturePlot_gene_from_custom_geneset_select')))
                    ),
                    column(12, h5('Select a gene below:') ),
                    column(12, verbatimTextOutput(ns('scRNA_FeaturePlot_status_gene_input')) ),
                    column(12, DT::dataTableOutput(ns("scRNA_FeaturePlot_gene_table")) ),
                    column(12, h5('\n')),
                )
            )
        ),
        
        # plot
        column(8,
            box(width=12, status='danger', title='Plot', 
                tabsetPanel(
                    # Feature Plot
                    tabPanel('Feature Plot (UMAP)',
                        fluidRow(
                            column(12, h4('\n') ) ,
                            column(10, verbatimTextOutput(ns('scRNA_FeaturePlot_status_plot')) ),
                            column(2, 
                                dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10) ),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_fig.height'), 'Fig height', min=300, max=3000, value=700, step=10) ),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_XY_label.font.size'), 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_XY_title.font.size'), 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_graph.title.font.size'), 'Graph title font size', min=0.1, max=10, value=4, step=0.1) ),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_legend_size'), 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_dot_size'), 'Dot size', min=0.01, max=2, value=0.01, step=0.01)),
                                        column(6, sliderInput(ns('scRNA_FeaturePlot_dot_size_bg'), 'Dot size (background)', min=0.01, max=2, value=0.05, step=0.01)),
                                        column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_highest_colour'), 'Colour for the highest expression', value='red') ),
                                        column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_lowest_colour'), 'Colour for the lowest expression', value='white') ),
                                        column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_zero_colour'), 'Colour for zero expression (background)', value='#676767')),
                                        column(12, materialSwitch(ns('scRNA_FeaturePlot_white_background'), 'Use white background', value=FALSE, status = "success"))
                                    ),circle = FALSE, status = "success", icon = icon("gear"), width = "700px", right=TRUE, tooltip = tooltipOptions(title = "Plot Options")
                                )
                            ),                                
                            column(12, withSpinner(plotOutput(ns("scRNA_FeaturePlot_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') )
                        )
                    ),

                    # Violin plot
                    tabPanel('Violin Plot',
                        fluidRow(
                            column(12, h4('\n') ) ,

                            # status
                            column(10, verbatimTextOutput(ns('scRNA_VlnPlot_vln_status'))),

                            # plot options
                            column(2,
                                dropdownButton( 
                                    h4(strong("Plot Options")),
                                    fluidRow(
                                        column(6,sliderInput(ns('scRNA_vln_vln_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10)),
                                        column(6,sliderInput(ns('scRNA_vln_vln_fig.height'), 'Fig height', min=300, max=3000, value=500, step=1)),
                                        column(6,sliderInput(ns('scRNA_vln_vln_X_label_size'), 'X label size', min=0.1, max=10, value=3, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_vln_vln_Y_label_size'), 'Y label size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_vln_vln_Y_title_size'), 'X/Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_vln_vln_legend_size'), 'Legend size', min=0.1, max=10, value=4, step=0.1)),
                                        column(12, h5(strong('Graph display area:'))),
                                        column(6, numericInput(ns('scRNA_vln_vln_ylim_min'), 'Min Y-axis:', value=NA, step=0.1)),
                                        column(6, numericInput(ns('scRNA_vln_vln_ylim_max'), 'Max Y-axis:', value=NA, step=0.1)),
                                        column(4, materialSwitch(ns('scRNA_vln_vln_white_back'), 'Use white background',  status = "success")),
                                        column(4, materialSwitch(ns('scRNA_vln_vln_rotate_x'), 'Rotate X axis label', status = "success")),
                                        column(4, materialSwitch(ns('scRNA_vln_vln_hide_jitter'), 'Hide jitter plots', status = "success", value=TRUE)),
                                    ),circle = FALSE, status = "success", icon = icon("gear"), width = "700px", right=TRUE, tooltip = tooltipOptions(title = "Plot Options")
                                )
                            ),

                            # group by options
                            column(6, htmlOutput(ns('scRNA_VlnPlot_groupBy')) ),

                            # plot
                            column(12, withSpinner(plotOutput(ns("scRNA_VlnPlot_vln"), width="100%", height="100%"), type=5, color='#0dc5c1') ),

                            # select groups to show in the violin plot
                            column(12, materialSwitch(ns('scRNA_VlnPlot_vln_select_group'), 'Select the groups to show',  status = "danger")),
                            conditionalPanel(condition = paste0("input['", ns('scRNA_VlnPlot_vln_select_group'), "'] == true"),
                                column(12, h5(strong("Please select the groups to use in the violin plot below:"))),
                                column(8, DT::dataTableOutput(ns("scRNA_VlnPlot_vln_select_group_table"))),
                            ),
                        )
                    ),

                    # Dot plot
                    tabPanel('Dot Plot',                            
                        fluidRow(
                            column(12, h4('\n') ) ,

                            # status
                            column(10, verbatimTextOutput(ns('scRNA_DotPlot_dot_status'))),

                            # plot options
                            column(2, 
                                dropdownButton( 
                                    h4(strong("Plot Options")),
                                    fluidRow(
                                        column(6,sliderInput(ns('scRNA_dot_fig.width'), 'Fig width', min=300, max=3000, value=900, step=10)),
                                        column(6,sliderInput(ns('scRNA_dot_fig.height'), 'Fig height', min=300, max=3000, value=500, step=1)),
                                        column(6,sliderInput(ns('scRNA_dot_X_label_size'), 'X label size', min=0.1, max=10, value=2, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_dot_Y_label_size'), 'Y label size', min=0.1, max=10, value=2.5, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_dot_Y_title_size'), 'Y title size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_dot_legend_size'), 'Legend size', min=0.1, max=10, value=4, step=0.1)),
                                        column(6,sliderInput(ns('scRNA_dot_dotScale'), 'Dot scale', min=0.1, max=5, value=0.9, step=0.1))
                                    ),
                                    fluidRow(
                                        column(6,colourpicker::colourInput(ns('scRNA_dot_high_col'), 'Colour (High expression)', value='blue')),
                                        column(6,colourpicker::colourInput(ns('scRNA_dot_low_col'), 'Colour (low expression)', value='lightgrey')),
                                    ),
                                    circle = FALSE, status = "success", icon = icon("gear"), width = "700px", right=TRUE, tooltip = tooltipOptions(title = "Plot Options")
                                )
                            ),

                            # group by options
                            column(6, htmlOutput(ns('scRNA_DotPlot_groupBy')) ),
                            column(6,
                                h3('\n'),
                                materialSwitch(ns('scRNA_DotPlot_dot_show_all_genes'), 'Show all the input genes', value=FALSE, status='danger') ,
                                helpText(HTML("If you select this option, all the input genes will be shown in the dot plot together. The order of the genes will be preserved. Please note that if you have too many input genes, the dot plot may take a while to show up."))
                            ),

                            # plot
                            column(12, withSpinner(plotOutput(ns("scRNA_DotPlot_dot"), width="100%", height="100%"), type=5, color='#0dc5c1')),


                            # select groups to show in the dot plot
                            column(12, materialSwitch(ns('scRNA_DotPlot_dot_select_group'), 'Select the groups to show',  status = "danger")),
                            conditionalPanel(condition = paste0("input['", ns('scRNA_DotPlot_dot_select_group'), "'] == true"),
                                column(12, h5(strong("Please select the groups to use in the dot plot below:"))),
                                column(8, DT::dataTableOutput(ns("scRNA_DotPlot_dot_select_group_table"))),
                            )                                

                        )
                    ),

                    # Pie chart
                    tabPanel('Pie Chart',
                        fluidRow(
                            column(12, h4('\n') ) ,

                            # status
                            column(10, verbatimTextOutput(ns('scRNA_fraction_status')) ),

                            # plot options
                            column(2, 
                                dropdownButton( h4(strong("Plot Options")),
                                    fluidRow(
                                        column(6,sliderInput(ns('scRNA_fraction_fig.width'), 'Fig width', min=300, max=3000, value=1000, step=10)),
                                        column(6,sliderInput(ns('scRNA_fraction_fig.height'), 'Fig height', min=300, max=3000, value=500, step=10)),
                                        column(6,sliderInput(ns('scRNA_fraction_label_size'), 'Label size', min=1, max=30, value=4, step=1)),
                                        column(6,sliderInput(ns('scRNA_fraction_group_name_size'), 'Group name size', min=10, max=40, value=15, step=1)),
                                        column(6,sliderInput(ns('scRNA_fraction_legend_size'), 'Legend size', min=3, max=30, value=10, step=1)),
                                        column(6, h3('')),
                                        column(6,colourpicker::colourInput(ns('scRNA_fraction_expressing_colour'), "Colour for 'Expressing'",  value='#3467ff')),
                                        column(6,colourpicker::colourInput(ns('scRNA_fraction_non_expressing_colour'), "Colour for 'Non.expressing'", value='#f3fbff')),
                                        column(6, materialSwitch(ns('scRNA_fraction_hide_legend'), 'Hide legends', value=FALSE, status = "success")),
                                        column(6, materialSwitch(ns('scRNA_fraction_hide_label'), 'Hide labels', value=FALSE, status = "success"))
                                    ),circle = FALSE, right=TRUE, status = "success", icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                )
                            ),

                            # group by options
                            column(6, htmlOutput(ns('scRNA_fraction_groupBy')) ),
                            column(6, h3('\n') ),

                            # plot
                            column(12, withSpinner(plotOutput(ns("scRNA_fraction_piechart"), width="100%", height="100%"), type=5, color='#0dc5c1')),

                            # select groups to show in the Pie chart
                            column(12, materialSwitch(ns('scRNA_PieChart_select_group'), 'Select the groups to show',  status = "danger")),
                            conditionalPanel(condition = paste0("input['", ns('scRNA_PieChart_select_group'), "'] == true"),
                                column(12, h5(strong("Please select the groups to use in the pie chart below:"))),
                                column(8, DT::dataTableOutput(ns("scRNA_PieChart_select_group_table"))),
                            )

                        )
                    ),

                    # Signature analysis
                    tabPanel('Gene Set Signature (AUC Score) Feature Plot',
                        column(12, helpText(HTML("This will calculate the signature score for each cell based on the input gene list using the AUCell method, and show the signature score in the feature plot (UMAP and violin plot). <br>
                                Here, all the genes in the input gene list will be used to calculate the signature score, not the only gene you selected. <br>
                                Please note that the AUCell method will determine the active gene set in each cell based on the ranking of the gene expression in that cell. So, if you want to use this method to calculate the signature score for a gene set, it is recommended to input a gene set with more than 10 genes. <br>
                                <span style='color: red;'>This takes 1~3 minutes depending on the size of the input genes and the size of the scRNA dataset. Please be patient.</span>
                            "))),    
                        column(4, actionButton(ns("scRNA_FeaturePlot_gene_signature_start"), "Calculate the signature score", style="color: #ffffff; background-color: #d82a2a; border-color: #bd0000") ),
                        column(12, h5('\n') ) ,
                        column(10, verbatimTextOutput(ns('scRNA_FeaturePlot_gene_signature_all_status')) ),
                        
                        column(12, h3('\n')),
                        
                        # Plots
                        column(12,
                            tabsetPanel(

                                # Feature Plot
                                tabPanel('Feature Plot',
                                    fluidRow(
                                    column(12, h4('') ) ,
                                    column(10, verbatimTextOutput(ns('scRNA_FeaturePlot_gene_signature_status')) ),
                                    column(2,
                                        dropdownButton( h4(strong("Plot Options")),
                                            fluidRow(
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_fig.width'), 'Fig width (Feature plot)', min=300, max=3000, value=700, step=10) ),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_fig.height'), 'Fig height (Feature plot)', min=300, max=3000, value=500, step=10) ),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_XY_label.font.size'), 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_XY_title.font.size'), 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_legend_size'), 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_dot_size'), 'Dot size', min=0.01, max=2, value=0.01, step=0.01)),
                                                column(6, sliderInput(ns('scRNA_FeaturePlot_gene_signature_dot_size_bg'), 'Dot size (background)', min=0.01, max=2, value=0.05, step=0.01)),
                                                column(6, h4('')),
                                                column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_gene_signature_highest_colour'), 'Colour for the highest expression', value='#5A05F7') ),
                                                column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_gene_signature_lowest_colour'), 'Colour for the lowest expression', value='white') ),
                                                column(4, colourpicker::colourInput(ns('scRNA_FeaturePlot_gene_signature_zero_colour'), 'Colour for zero (background)', value='#676767')),
                                                column(12, materialSwitch(ns('scRNA_FeaturePlot_gene_signature_white_background'), 'Use white background', value=FALSE, status = "success"))
                                            ),circle = FALSE, status = "success", right=TRUE, icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                        ),
                                    ),
                                    column(12, withSpinner(plotOutput(ns("scRNA_FeaturePlot_gene_signature_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') )
                                    )                            
                                ),

                                # Violin plot
                                tabPanel('Violin Plot',
                                    fluidRow(
                                        column(12, h4('') ) ,
                                        column(8, htmlOutput(ns('scRNA_violin_gene_signature_groupby')) ),
                                        column(10, verbatimTextOutput(ns('scRNA_violin_gene_signature_status'))),
                                        column(2,
                                            dropdownButton( h4(strong("Plot Options")),
                                                fluidRow(
                                                    column(6, sliderInput(ns('scRNA_violin_gene_signature_fig.width'), 'Fig width (Violin plot)', min=300, max=3000, value=900, step=10) ),
                                                    column(6, sliderInput(ns('scRNA_violin_gene_signature_fig.height'), 'Fig height (Violin plot)', min=300, max=3000, value=600, step=10) ),
                                                    column(6, sliderInput(ns('scRNA_violin_gene_signature_XY_label.font.size'), 'X/Y label font size', min=0.1, max=10, value=4, step=0.1) ),
                                                    column(6, sliderInput(ns('scRNA_violin_gene_signature_XY_title.font.size'), 'X/Y title font size', min=0.1, max=10, value=4, step=0.1) ),
                                                    column(6, sliderInput(ns('scRNA_violin_gene_signature_legend_size'), 'Legend font size', min=0.1, max=10, value=4, step=0.1)),
                                                    column(6, h4('')),
                                                    column(12, h5(strong('Graph display area:'))),
                                                    column(6, numericInput(ns('scRNA_violin_gene_signature_ylim_min'), 'Min Y-axis:', value=NA, step=0.1)),
                                                    column(6, numericInput(ns('scRNA_violin_gene_signature_ylim_max'), 'Max Y-axis:', value=NA, step=0.1)),
                                                    column(4, materialSwitch(ns('scRNA_violin_gene_signature_white_background'), 'Use white background', value=FALSE, status = "success")),
                                                    column(4, materialSwitch(ns('scRNA_violin_gene_signature_rotate_x'), 'Rotate X axis label', value=TRUE, status = "success")),
                                                    column(4, materialSwitch(ns('scRNA_violin_gene_signature_hide_jitter'), 'Hide jitter plots', status = "success", value=TRUE)),
                                                ),circle = FALSE, status = "success", right=TRUE, icon = icon("gear"), width = "700px",  tooltip = tooltipOptions(title = "Plot Options")
                                            )
                                        ),
                                        column(12, withSpinner(plotOutput(ns("scRNA_violin_gene_signature_plot"), width="100%", height="100%"), type=5, color='#0dc5c1') ),
                                        column(12, materialSwitch(ns('scRNA_violin_gene_signature_select_group'), 'Select the groups to show',  status = "danger")),
                                        conditionalPanel(condition = paste0("input['", ns("scRNA_violin_gene_signature_select_group"), "'] == true"),
                                            column(12, h5("Select the groups to use in the violin plot below:")),
                                            column(8, DT::dataTableOutput(ns("scRNA_violin_gene_signature_select_group_table")))
                                        ),
                                    )
                                )
                            )
                        )

                    )


                )
            )
        )
    )
}

