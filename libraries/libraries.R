
cat("Loading libraries...\n")

suppressMessages(library(shiny))
suppressMessages(library(shinyjs))
suppressMessages(library(shinydashboard))
suppressMessages(library(shinyWidgets))
suppressMessages(library(shinycssloaders))
suppressMessages(library(ggplot2))
suppressMessages(library(ggrepel))
suppressMessages(library(DT))


# Replace Inf with 1.1x the column's max finite value, -Inf with 1.1x the min
# finite value (e.g. a -log10(pvalue) column is Inf when pvalue == 0). Leaves
# non-numeric vectors / columns with no finite values untouched.
replace_infinite_values <- function(x) {
  if (!is.numeric(x)) return(x)
  finite_vals <- x[is.finite(x)]
  if (length(finite_vals) == 0) return(x)
  x[is.infinite(x) & x > 0] <- 1.1 * max(finite_vals)
  x[is.infinite(x) & x < 0] <- 1.1 * min(finite_vals)
  x
}

# Apply replace_infinite_values() to every numeric column of a data.frame.
replace_infinite_values_df <- function(df) {
  df[] <- lapply(df, replace_infinite_values)
  df
}

cat("Libraries loaded.\n")