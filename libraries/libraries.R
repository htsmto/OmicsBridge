
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
# --- Heavy-load resource guard -------------------------------------------------
# Used to warn the user before a heavy data load (scRNA .rds, Epigenome
# bigWig/BAM tracks, Clinical cohort tables) if the host is already under
# heavy CPU/RAM load, or if the file(s) about to be loaded likely won't fit
# in currently-free RAM -- either can crash this shared shiny-server host.
RESOURCE_CPU_THRESHOLD  <- 90   # % aggregate CPU (see ui/sidebar.R's monitor)
RESOURCE_MEM_THRESHOLD  <- 85   # % RAM already in use
RESOURCE_MEM_MULTIPLIER <- 3    # safety factor: parsed-in-R size vs on-disk size

# Combines three signals: current CPU% (reused from the sidebar monitor's
# periodic reading above, to avoid a blocking re-measurement here), current
# RAM% (checked fresh -- an instantaneous read, no cost to redo), and the
# on-disk size of `file_paths` (0, 1, or many; summed) against currently-free
# RAM. Missing/NA/nonexistent paths are ignored (falls back to usage-only
# checks). There is no reliable way to predict whether a specific load will
# push CPU to 100% -- that cost mostly comes from what runs *after* loading
# (UMAP, GSVA, xCell, decompression) -- so the CPU check is deliberately just
# "is the host already close to saturated right now".
resources_are_low <- function(session, file_paths = NULL,
                               cpu_threshold = RESOURCE_CPU_THRESHOLD,
                               mem_threshold = RESOURCE_MEM_THRESHOLD,
                               mem_multiplier = RESOURCE_MEM_MULTIPLIER) {
  cpu_pct <- if (!is.null(session$userData$sysmon)) isolate(session$userData$sysmon$cpu_pct) else NA_real_
  mem <- tryCatch(ps::ps_system_memory(), error = function(e) NULL)
  mem_pct <- if (!is.null(mem)) round(mem$percent) else NA_real_

  file_bytes <- NA_real_
  if (!is.null(file_paths)) {
    file_paths <- file_paths[!is.na(file_paths) & nzchar(file_paths) & file.exists(file_paths)]
    if (length(file_paths) > 0) file_bytes <- sum(file.size(file_paths), na.rm = TRUE)
  }
  file_too_big <- !is.na(file_bytes) && !is.null(mem) && (file_bytes * mem_multiplier) >= mem$avail
  cpu_high <- !is.na(cpu_pct) && cpu_pct >= cpu_threshold
  mem_high <- !is.na(mem_pct) && mem_pct >= mem_threshold

  list(low = cpu_high || mem_high || file_too_big,
       cpu_pct = cpu_pct, mem_pct = mem_pct, file_bytes = file_bytes,
       mem_avail = if (!is.null(mem)) mem$avail else NA_real_,
       reason = if (file_too_big) "file_size" else if (mem_high) "mem" else if (cpu_high) "cpu" else "ok")
}

# Guards `do_load()` behind resources_are_low(). Runs `do_load()` immediately
# if resources look fine; otherwise shows a confirmSweetAlert() (the app's
# existing "are you sure?" pattern, see e.g.
# modules/Database/02_Database_Upload_server.R) with a size-aware message,
# deferring `do_load()` until confirmed via the companion
# heavyLoadConfirmObserver() below (which the caller must register once per
# `confirm_id`, alongside the observer that calls guardHeavyLoad()).
# `on_cancel()`, if given, runs instead if the user cancels (e.g. to reset a
# "loading..." flag left set by the caller before calling this).
guardHeavyLoad <- function(session, confirm_id, do_load, on_cancel = NULL,
                            what = "this data", file_paths = NULL) {
  status <- resources_are_low(session, file_paths)
  if (!status$low) {
    do_load()
    return(invisible(TRUE))
  }

  if (is.null(session$userData$pending_loads)) session$userData$pending_loads <- new.env()
  assign(confirm_id, do_load, envir = session$userData$pending_loads)
  assign(paste0(confirm_id, "__cancel"), on_cancel, envir = session$userData$pending_loads)

  size_note <- if (!is.na(status$file_bytes)) {
    sprintf(" This data is ~%.2f GB; only ~%.2f GB RAM is currently free.",
            status$file_bytes / 1024^3, status$mem_avail / 1024^3)
  } else ""
  shinyWidgets::confirmSweetAlert(
    session = session, inputId = session$ns(confirm_id),
    title = "Server resources are low",
    text = sprintf(
      "Current usage -- CPU: %s%%, RAM: %s%%.%s Loading %s now may overload the server and cause it to crash for everyone. Continue anyway?",
      ifelse(is.na(status$cpu_pct), "unknown", status$cpu_pct),
      ifelse(is.na(status$mem_pct), "unknown", status$mem_pct), size_note, what
    ),
    type = "warning", btn_labels = c("Cancel", "Load anyway"), btn_colors = c("#5b5d6e", "#d9534f")
  )
  invisible(FALSE)
}

# Call once per `confirm_id`, alongside the observer that calls
# guardHeavyLoad() with that same id, to wire up the confirmation dialog's
# buttons to the deferred do_load()/on_cancel() stashed there.
heavyLoadConfirmObserver <- function(input, session, confirm_id) {
  observeEvent(input[[confirm_id]], {
    if (isTRUE(input[[confirm_id]])) {
      fn <- get0(confirm_id, envir = session$userData$pending_loads)
      if (!is.null(fn)) fn()
    } else if (isFALSE(input[[confirm_id]])) {
      cancel_fn <- get0(paste0(confirm_id, "__cancel"), envir = session$userData$pending_loads)
      if (!is.null(cancel_fn)) cancel_fn()
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
}
