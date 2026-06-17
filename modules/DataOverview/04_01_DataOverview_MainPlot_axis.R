# =============================================================================
# DataOverview - MainPlot: Axis Selection
# File: modules/DataOverview/04_01_DataOverview_MainPlot_axis.R
# Purpose: Dynamically renders the X and Y axis selector dropdowns for the
#          main scatter plot. Choices update whenever df_ex() changes.
# Edit this file when: changing axis options, adding a Z-axis, or adjusting
#                       the 'None' default behaviour.
# =============================================================================

mainplot_axis_server <- function(input, output, session, df_ex) {

  # --- [1] X-axis selector ---------------------------------------------------
  # Generates a selectInput whose choices are the column names of df_ex().
  # When no data is loaded the choice list is empty (defaults to 'None').
  output$Scat.X <- renderUI({
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      X_axis_name <- c()
    } else {
      X_axis_name <- names(df_ex())
    }
    selectInput(session$ns("scat.x"), "x", c("None" = "None", X_axis_name))
  })

  # --- [2] Y-axis selector ---------------------------------------------------
  # Same pattern as X. Both are separate renderUI calls so that changing one
  # does not invalidate the other unnecessarily.
  output$Scat.Y <- renderUI({
    if (length(df_ex()) == 0 || is.null(df_ex())) {
      Y_axis_name <- c()
    } else {
      Y_axis_name <- names(df_ex())
    }
    selectInput(session$ns("scat.y"), "y", c("None" = "None", Y_axis_name))
  })
}
