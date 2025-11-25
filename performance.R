# Performance Monitoring Module
# Tracks application performance metrics

library(shiny)

# Performance tracking variables
.performance_metrics <- new.env()
.performance_metrics$start_time <- Sys.time()
.performance_metrics$page_loads <- 0
.performance_metrics$chart_renders <- 0
.performance_metrics$data_filters <- 0
.performance_metrics$api_calls <- 0

#' Track performance metric
#' 
#' @param metric_name Name of the metric to track
#' @param increment How much to increment by (default: 1)
track_metric <- function(metric_name, increment = 1) {
  if (exists(metric_name, envir = .performance_metrics)) {
    .performance_metrics[[metric_name]] <- .performance_metrics[[metric_name]] + increment
  } else {
    .performance_metrics[[metric_name]] <- increment
  }
}

#' Time a function execution
#' 
#' @param func Function to execute
#' @param metric_name Name for logging
#' @return Result of function execution
time_function <- function(func, metric_name = "operation") {
  start_time <- Sys.time()
  result <- func()
  duration <- as.numeric(Sys.time() - start_time)
  
  log_performance(metric_name, duration)
  
  return(result)
}

#' Get current performance metrics
#' 
#' @return List of current metrics
get_performance_metrics <- function() {
  uptime <- as.numeric(Sys.time() - .performance_metrics$start_time, units = "hours")
  
  metrics <- list(
    uptime_hours = round(uptime, 2),
    page_loads = .performance_metrics$page_loads %||% 0,
    chart_renders = .performance_metrics$chart_renders %||% 0,
    data_filters = .performance_metrics$data_filters %||% 0,
    api_calls = .performance_metrics$api_calls %||% 0,
    avg_charts_per_session = round((.performance_metrics$chart_renders %||% 0) / max(.performance_metrics$page_loads %||% 1, 1), 2)
  )
  
  return(metrics)
}

#' Create performance dashboard
#' 
#' @return HTML content for performance metrics
create_performance_dashboard <- function() {
  metrics <- get_performance_metrics()
  
  # Create value boxes for key metrics
  boxes <- tagList(
    fluidRow(
      column(3,
        valueBox(
          value = paste(metrics$uptime_hours, "hrs"),
          subtitle = "Uptime",
          icon = icon("clock"),
          color = "green"
        )
      ),
      column(3,
        valueBox(
          value = metrics$page_loads,
          subtitle = "Page Loads",
          icon = icon("eye"),
          color = "blue"
        )
      ),
      column(3,
        valueBox(
          value = metrics$chart_renders,
          subtitle = "Charts Rendered",
          icon = icon("chart-bar"),
          color = "yellow"
        )
      ),
      column(3,
        valueBox(
          value = metrics$api_calls,
          subtitle = "API Calls",
          icon = icon("exchange-alt"),
          color = "red"
        )
      )
    ),
    fluidRow(
      column(12,
        box(
          title = "Performance Summary",
          status = "primary",
          solidHeader = TRUE,
          width = NULL,
          tableOutput("performance_table")
        )
      )
    )
  )
  
  return(boxes)
}

#' Monitor memory usage
#' 
#' @return Memory usage information
get_memory_usage <- function() {
  # Get memory info (works on most systems)
  tryCatch({
    gc_info <- gc()
    memory_used <- sum(gc_info[, 2])  # Used memory in MB
    
    return(list(
      used_mb = round(memory_used, 2),
      r_objects = length(ls(.GlobalEnv)),
      gc_info = gc_info
    ))
  }, error = function(e) {
    return(list(
      used_mb = "N/A",
      r_objects = length(ls(.GlobalEnv)),
      error = e$message
    ))
  })
}

# Null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}