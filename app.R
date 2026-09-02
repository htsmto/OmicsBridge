# =============================================================================
# OmicsBridge - Main Application Entry Point
# File: app.R
# Purpose: Assembles the Shiny UI from modular components, and wires up the
#          server with lazy-loading so that heavy modules (Seurat, clusterProfiler,
#          etc.) are only loaded the first time a user navigates to that tab.
#
# Edit this file when:
#   - Adding a new top-level tab / module
#   - Changing global upload size limits
#   - Adjusting which modules are loaded eagerly vs. lazily
# =============================================================================

# --- [1] Global options -------------------------------------------------------
# Allow large file uploads (e.g., count matrices, BAM-derived tables).
# 10 GB limit; adjust if needed.
options(shiny.maxRequestSize = 10000 * 1024^2)


# --- [2] Core libraries & UI components --------------------------------------
# libraries.R loads only the lightweight Shiny-related packages needed to
# render the shell of the app (shiny, shinydashboard, shinyjs, etc.).
# Heavy bioinformatics libraries are sourced per-module below.
source('libraries/libraries.R')
suppressMessages(library(ps))  # host CPU/RAM stats for the sidebar system monitor

source("ui/header.R")   # dashboardHeader definition
source("ui/sidebar.R")  # dashboardSidebar with menu items
source("ui/body.R")     # dashboardBody: sources all module wrappers and
                        # defines each tabItem — UI files only at this stage


# --- [2b] Sidebar system monitor (CPU/RAM) ------------------------------------
# Host-wide CPU/RAM usage, shown as two progress bars at the bottom of the
# sidebar (see ui/sidebar.R for the "cpu_usage_bar" / "mem_usage_bar" widgets).
# This reflects the whole shiny-server host, not just this session's R
# process, since the host is shared across multiple users/apps.

# Number of CPU cores on this host (e.g. 2). ps_system_cpu_times() already
# sums ticks across all cores, so the busy % computed from it below is
# already normalized to 0-100% average utilization across every core
# combined -- the same convention `top`'s "%Cpu(s):" summary line uses.
# 100% therefore means "fully saturated across all N cores", not "1 core
# maxed out" -- baked into the CPU bar's title below so that's unambiguous.
n_cores <- ps::ps_cpu_count()

# Computes host CPU busy % since the previous ps_system_cpu_times() reading.
# `prev` is NULL on the first call (no delta yet -> pct = NA).
get_cpu_usage <- function(prev) {
  cur <- ps::ps_system_cpu_times()
  pct <- NA_real_
  if (!is.null(prev)) {
    dt <- sum(cur) - sum(prev)
    di <- cur[["idle"]] - prev[["idle"]]
    if (dt > 0) pct <- round(100 * (1 - di / dt))
  }
  list(pct = pct, ticks = cur)
}

# Reads /proc/stat's per-core lines ("cpu0", "cpu1", ...) -- the aggregate
# "cpu" line is skipped; that's handled separately by get_cpu_usage(). `ps`
# has no per-core function, so this reads /proc/stat directly (Linux-only,
# same convention the aggregate calculation above is built on). Returns a
# named list, one numeric tick vector per core, in /proc/stat's column order
# (user, nice, system, idle, ...).
read_percpu_ticks <- function() {
  lines <- readLines("/proc/stat")
  core_lines <- grep("^cpu[0-9]+ ", lines, value = TRUE)
  ticks <- lapply(core_lines, function(l) as.numeric(strsplit(trimws(sub("^cpu[0-9]+", "", l)), "\\s+")[[1]]))
  names(ticks) <- sub(" .*", "", core_lines)
  ticks
}

# Computes each core's busy % since `prev` (a value previously returned by
# this function's $ticks). `prev` NULL on the first call -> pct is NULL.
get_percpu_usage <- function(prev) {
  cur <- read_percpu_ticks()
  pct <- NULL
  if (!is.null(prev)) {
    pct <- vapply(names(cur), function(nm) {
      dt <- sum(cur[[nm]]) - sum(prev[[nm]])
      di <- cur[[nm]][4] - prev[[nm]][4]  # column 4 = idle
      if (dt > 0) round(100 * (1 - di / dt)) else NA_real_
    }, numeric(1))
  }
  list(pct = pct, ticks = cur)
}

# Returns current host memory usage as a percentage and a "used / total GB" label.
get_memory_usage <- function() {
  mem <- ps::ps_system_memory()
  list(
    pct   = round(mem$percent),
    label = sprintf("%.1f / %.1f GB", mem$used / 1024^3, mem$total / 1024^3)
  )
}

# Wires a periodic host-wide CPU/RAM monitor into the "cpu_usage_bar" /
# "mem_usage_bar" shinyWidgets progressBars declared in ui/sidebar.R.
# Call once from server().
systemMonitorServer <- function(input, output, session, interval_ms = 3000) {
  cpu_prev    <- reactiveVal(NULL)
  percpu_prev <- reactiveVal(NULL)
  percpu_pct  <- reactiveVal(NULL)

  # Shared with the resource guard below (see guardHeavyLoad()) via
  # session$userData, which is a plain environment shared across the entire
  # app -- including every module's session proxy -- so any module can read
  # the latest CPU% without a new parameter threaded through its call chain.
  session$userData$sysmon <- reactiveValues(cpu_pct = NA_real_)

  observe({
    invalidateLater(interval_ms, session)

    cpu <- get_cpu_usage(isolate(cpu_prev()))
    cpu_prev(cpu$ticks)
    if (!is.na(cpu$pct)) {
      session$userData$sysmon$cpu_pct <- cpu$pct
      shinyWidgets::updateProgressBar(session, "cpu_usage_bar", value = cpu$pct, total = 100,
                                       title = paste0("CPU usage (", n_cores, " cores)"))
    }

    percpu <- get_percpu_usage(isolate(percpu_prev()))
    percpu_prev(percpu$ticks)
    if (!is.null(percpu$pct)) percpu_pct(percpu$pct)

    mem <- get_memory_usage()
    shinyWidgets::updateProgressBar(session, "mem_usage_bar", value = mem$pct, total = 100,
                                     title = paste0("RAM usage (", mem$label, ")"))
  })

  # Per-core text list, e.g. "cpu1: 10%/100%" -- renders under the CPU bar
  # (see ui/sidebar.R). Reactive on percpu_pct(), so it updates whenever a
  # new reading lands, independent of the imperative updateProgressBar calls
  # above (which only affect the two bar widgets, not this plain-text list).
  output$cpu_percore_usage <- renderUI({
    pct <- percpu_pct()
    if (is.null(pct)) return(NULL)
    tagList(lapply(seq_along(pct), function(i) {
      tags$div(class = "cpu-percore-line", sprintf("cpu%d: %d%%/100%%", i, pct[[i]]))
    }))
  })
}


# --- [3] Assemble UI ----------------------------------------------------------
# Inject custom CSS / JS, then wrap header + sidebar + body into the standard
# shinydashboard layout.
ui <- tagList(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
        tags$script(src = "custom.js")
    ),
    dashboardPage(header, sidebar, body)
)


# --- [4] Server function ------------------------------------------------------
server <- function(input, output, session) {

    # --- [4-1] Always-on modules --------------------------------------------
    # These modules are lightweight and required as soon as the app starts
    # (database browsing, gene set management, and documentation).
    databaseModuleServer("db")
    originalgenesetModuleServer("original_geneset")
    wiki_documentModuleServer("wiki_document")
    systemMonitorServer(input, output, session)


    # --- [4-2] Lazy-loading tracker ------------------------------------------
    # `loaded` is a reactiveValues object used as a per-session flag store.
    # Each tab name is used as a key; once set to TRUE the server for that
    # module will not be registered again, preventing duplicate reactive chains.
    loaded <- reactiveValues()


    # --- [4-3] Tab-driven lazy loading ----------------------------------------
    # When the user navigates to a tab for the first time:
    #   1. Set the loaded flag to prevent re-execution on subsequent visits.
    #   2. Source the module's library file (if it has one).
    #   3. Call moduleServer — this registers the reactive logic for that tab.
    #   4. Wrap in tryCatch so a broken module shows a notification rather than
    #      crashing the whole session.
    #   5. Use withProgress for tabs that load slowly so the user gets feedback.
    observeEvent(input$sidebar, {
        tab <- input$sidebar

        # Skip if this tab's server has already been registered.
        if (isTRUE(loaded[[tab]])) return()
        loaded[[tab]] <- TRUE

        if (tab == "Data_Overview") {
            # Count & Comparison Data Overview: loads clusterProfiler, fgsea, GSVA, etc.
            withProgress(message = "Loading Count & Comparison Data Overview tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_DataOverview.R")
                    dataoverviewModuleServer("data_overview")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Data Overview module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "scRNA") {
            # scRNA-seq: Seurat can take 20-40 s to load on first use.
            withProgress(message = "Loading Seurat library — this may take ~30 seconds on first use...", value = 0.2, {
                tryCatch({
                    suppressMessages(library(Seurat))
                    setProgress(0.8, message = "Initializing scRNA module...")
                    scRNAModuleServer("scRNA")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load scRNA module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Clinical_dataset") {
            # Clinical analysis: survival, deconvolution, mutation plotting, etc.
            withProgress(message = "Loading clinical analysis tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_Clinical.R", local = TRUE)
                    clinicalModuleServer("clinical")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Clinical module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Tools") {
            # Utility tools: gene ID conversion, locus finder, Venn diagrams, etc.
            tryCatch({
                source("libraries/libraries_tools.R", local = TRUE)
                toolsModuleServer("tools")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Tools module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })

        } else if (tab == "igv") {
            # Epigenome: IGV browser, motif scanning, genome-wide visualisation.
            withProgress(message = "Loading epigenome visualisation tools...", value = 0.5, {
                tryCatch({
                    source("libraries/libraries_Epigenome.R")
                    EpigenomeModuleServer("igv")
                }, error = function(e) {
                    showNotification(
                        paste("Failed to load Epigenome module:", conditionMessage(e)),
                        type = "error", duration = 15
                    )
                })
            })

        } else if (tab == "Compare_across_datasets") {
            # Cross-dataset comparison: relatively lightweight.
            tryCatch({
                DatasetsCompareModuleServer("datasets_compare")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Datasets Compare module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })

        } else if (tab == "Integrate_two_dataset") {
            # Side-by-side integration of two datasets.
            tryCatch({
                source('libraries/libraries_IntegrateTwoDataset.R', local = TRUE)
                IntegrateTwoDatasetModuleServer("integrate_two_dataset")
            }, error = function(e) {
                showNotification(
                    paste("Failed to load Integrate Two Datasets module:", conditionMessage(e)),
                    type = "error", duration = 15
                )
            })
        }
    })
}


# --- [5] Launch the app -------------------------------------------------------
shinyApp(ui, server)
