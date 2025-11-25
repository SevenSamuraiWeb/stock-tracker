# Logging Utility for Stock Dashboard
# Provides structured logging functionality

library(futile.logger)

#' Initialize logging system
#' 
#' @param config Logging configuration from config.R
#' @return TRUE if successful
init_logging <- function(config = LOGGING_CONFIG) {
  tryCatch({
    # Create logs directory if it doesn't exist
    log_dir <- dirname(config$file)
    if (!dir.exists(log_dir)) {
      dir.create(log_dir, recursive = TRUE)
    }
    
    # Set log level
    flog.threshold(config$level)
    
    # Configure file appender if specified
    if (!is.null(config$file)) {
      flog.appender(appender.file(config$file))
    }
    
    # Also log to console if enabled
    if (config$console) {
      flog.appender(appender.console(), name = "console")
    }
    
    flog.info("Logging system initialized successfully")
    return(TRUE)
  }, error = function(e) {
    warning(paste("Failed to initialize logging:", e$message))
    return(FALSE)
  })
}

#' Log application startup
log_startup <- function() {
  flog.info("========================================")
  flog.info("NIFTY 50 Stock Dashboard Starting")
  flog.info(paste("Version:", APP_CONFIG$version))
  flog.info(paste("Host:", APP_CONFIG$host))
  flog.info(paste("Port:", APP_CONFIG$port))
  flog.info(paste("R Version:", R.version.string))
  flog.info("========================================")
}

#' General info logging wrapper
#'
#' @param msg Message to log at INFO level
log_info <- function(msg) {
  tryCatch({
    flog.info(msg)
  }, error = function(e) {
    # Fallback to console if logging fails
    message(paste("INFO:", msg))
  })
}

#' Log data loading events
#' 
#' @param file_name Name of the file being loaded
#' @param rows Number of rows loaded
#' @param duration Time taken to load
log_data_load <- function(file_name, rows = NULL, duration = NULL) {
  msg <- paste("Data loaded:", file_name)
  if (!is.null(rows)) msg <- paste(msg, "| Rows:", format(rows, big.mark = ","))
  if (!is.null(duration)) msg <- paste(msg, "| Duration:", round(duration, 3), "seconds")
  flog.info(msg)
}

#' Log user interactions
#' 
#' @param action User action performed
#' @param details Additional details about the action
log_user_action <- function(action, details = NULL) {
  msg <- paste("User action:", action)
  if (!is.null(details)) msg <- paste(msg, "|", details)
  flog.debug(msg)
}

#' Log errors with context
#' 
#' @param error_msg Error message
#' @param context Additional context about where error occurred
log_error <- function(error_msg, context = NULL) {
  msg <- paste("ERROR:", error_msg)
  if (!is.null(context)) msg <- paste(msg, "| Context:", context)
  flog.error(msg)
}

#' Log performance metrics
#' 
#' @param operation Name of operation being measured
#' @param duration Time taken in seconds
#' @param details Additional performance details
log_performance <- function(operation, duration, details = NULL) {
  msg <- paste("Performance:", operation, "| Duration:", round(duration, 3), "seconds")
  if (!is.null(details)) msg <- paste(msg, "|", details)
  
  # Log as warning if operation takes too long
  if (duration > 5) {
    flog.warn(msg)
  } else {
    flog.debug(msg)
  }
}

#' Log application shutdown
log_shutdown <- function() {
  flog.info("NIFTY 50 Stock Dashboard Shutting Down")
  flog.info("========================================")
}