# =============================================================================
# DataOverview - MainPlot: Axis Selection
# File: modules/DataOverview/04_01_DataOverview_MainPlot_axis.R
# Purpose: Dynamically renders the X and Y axis selector dropdowns for the
#          main scatter plot. Choices update whenever df_ex() changes
# Edit this file when: changing axis options, adding a Z-axis, adjusting the
#                       'None' default behaviour, or adding auto-selected
#                       axes for another data type.
# =============================================================================

# Default x/y columns for recognised data types, keyed by the columns that
# identify them. Add an entry here to auto-select axes for another data type.
mainplot_default_xy <- function(col_names) {
  # if (all(c("log2FoldChange", "-log10.pvalue") %in% col_names)) {
  #   return(list(x = "log2FoldChange", y = "-log10.pvalue")) # RNAseq (DEG)
  # }
  # if (all(c("logFC", "log10_score") %in% col_names)) {
  #   return(list(x = "logFC", y = "log10_score")) # CRISPR screening
  # }
  # if (all(c("LFC", "-log10(p.value)") %in% col_names)) {
  #   return(list(x = "LFC", y = "-log10(p.value)")) # CRISPR screening (sgRNA)
  # }
  list(x = "None", y = "None")
}

mainplot_axis_server <- function(input, output, session, df_ex) {

  # --- [0] Reset axes on dataset change ---------------------------------------
  # The choices shown in Scat.X/Scat.Y (below) only refresh once df_ex()
  # changes and the renderUI round-trips back to the browser. Until then,
  # input$scat.x/scat.y still hold the previous dataset's column names, which
  # can crash downstream filters that index the new df_ex() by a column it
  # doesn't have. Updating them immediately to the new dataset's default axes
  # (or "None" if no default is recognised) closes that window.
  observeEvent(df_ex(), {
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      default_x <- "None"
      default_y <- "None"
    } else {
      defaults  <- mainplot_default_xy(names(df_ex()))
      default_x <- defaults$x
      default_y <- defaults$y
    }
    updateSelectInput(session, "scat.x", selected = default_x)
    updateSelectInput(session, "scat.y", selected = default_y)
  }, ignoreInit = TRUE)

  # --- [1] X-axis selector ---------------------------------------------------
  # Generates a selectInput whose choices are the column names of df_ex().
  # When no data is loaded the choice list is empty (defaults to 'None').
  output$Scat.X <- renderUI({
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      X_axis_name <- c()
      default_x <- "None"
    } else {
      X_axis_name <- names(df_ex())
      default_x <- mainplot_default_xy(X_axis_name)$x
    }
    selectInput(session$ns("scat.x"), "x", c("None" = "None", X_axis_name), selected = default_x)
  })

  # --- [2] Y-axis selector ---------------------------------------------------
  # Same pattern as X. Both are separate renderUI calls so that changing one
  # does not invalidate the other unnecessarily.
  output$Scat.Y <- renderUI({
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      Y_axis_name <- c()
      default_y <- "None"
    } else {
      Y_axis_name <- names(df_ex())
      default_y <- mainplot_default_xy(Y_axis_name)$y
    }
    selectInput(session$ns("scat.y"), "y", c("None" = "None", Y_axis_name), selected = default_y)
  })
}
