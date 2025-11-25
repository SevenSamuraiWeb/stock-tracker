# Data Validation Module
# Ensures data quality and integrity

library(dplyr)
library(lubridate)

#' Validate NIFTY 50 stock data
#' 
#' @param df Stock data dataframe
#' @return List with validation results and cleaned data
validate_stock_data <- function(df) {
  start_time <- Sys.time()
  issues <- list()
  cleaned_data <- df
  
  tryCatch({
    # Check required columns
    required_cols <- c("Date", "Symbol", "Open", "High", "Low", "Close", "Volume")
    missing_cols <- setdiff(required_cols, names(df))
    
    if (length(missing_cols) > 0) {
      issues$missing_columns <- missing_cols
      log_error(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
      return(list(valid = FALSE, issues = issues, data = NULL))
    }
    
    # Validate data types
    if (!"Date" %in% class(df$Date) && !"POSIXct" %in% class(df$Date)) {
      cleaned_data$Date <- tryCatch({
        as.Date(cleaned_data$Date)
      }, error = function(e) {
        issues$date_conversion <<- "Failed to convert Date column"
        return(cleaned_data$Date)
      })
    }
    
    # Check for missing values in critical columns
    critical_cols <- c("Date", "Symbol", "Close")
    for (col in critical_cols) {
      missing_count <- sum(is.na(cleaned_data[[col]]))
      if (missing_count > 0) {
        issues[[paste0("missing_", tolower(col))]] <- missing_count
      }
    }
    
    # Remove rows with missing critical data
    initial_rows <- nrow(cleaned_data)
    cleaned_data <- cleaned_data %>%
      filter(!is.na(Date), !is.na(Symbol), !is.na(Close))
    
    removed_rows <- initial_rows - nrow(cleaned_data)
    if (removed_rows > 0) {
      issues$rows_removed <- removed_rows
      log_data_load("Data cleaning", removed_rows, paste("rows removed due to missing critical data"))
    }
    
    # Validate numeric columns
    numeric_cols <- c("Open", "High", "Low", "Close", "Volume")
    for (col in numeric_cols) {
      if (col %in% names(cleaned_data)) {
        # Check for negative values (except for returns/changes)
        negative_count <- sum(cleaned_data[[col]] < 0, na.rm = TRUE)
        if (negative_count > 0 && !grepl("change|return", tolower(col))) {
          issues[[paste0("negative_", tolower(col))]] <- negative_count
        }
        
        # Check for extreme outliers (more than 100x median)
        median_val <- median(cleaned_data[[col]], na.rm = TRUE)
        if (!is.na(median_val) && median_val > 0) {
          outliers <- sum(cleaned_data[[col]] > median_val * 100, na.rm = TRUE)
          if (outliers > 0) {
            issues[[paste0("outliers_", tolower(col))]] <- outliers
          }
        }
      }
    }
    
    # Validate OHLC relationships
    if (all(c("Open", "High", "Low", "Close") %in% names(cleaned_data))) {
      invalid_ohlc <- cleaned_data %>%
        filter(High < Low | High < Open | High < Close | Low > Open | Low > Close) %>%
        nrow()
      
      if (invalid_ohlc > 0) {
        issues$invalid_ohlc <- invalid_ohlc
      }
    }
    
    # Check date continuity and duplicates
    if (nrow(cleaned_data) > 0) {
      # Check for duplicate symbol-date combinations
      duplicates <- cleaned_data %>%
        group_by(Symbol, Date) %>%
        summarise(count = n(), .groups = 'drop') %>%
        filter(count > 1) %>%
        nrow()
      
      if (duplicates > 0) {
        issues$duplicate_records <- duplicates
      }
      
      # Check date range
      date_range <- range(cleaned_data$Date, na.rm = TRUE)
      issues$date_range <- list(
        start = min(date_range),
        end = max(date_range),
        span_days = as.numeric(diff(date_range))
      )
    }
    
    # Performance metrics
    duration <- as.numeric(Sys.time() - start_time)
    log_performance("Data validation", duration, paste("Rows:", nrow(cleaned_data)))
    
    # Return results
    result <- list(
      valid = length(issues) == 0 || all(names(issues) %in% c("date_range")),
      issues = issues,
      data = cleaned_data,
      summary = list(
        total_rows = nrow(cleaned_data),
        total_symbols = length(unique(cleaned_data$Symbol)),
        date_range = if(nrow(cleaned_data) > 0) range(cleaned_data$Date) else c(NA, NA),
        validation_time = duration
      )
    )
    
    if (result$valid) {
      log_data_load("Data validation passed", nrow(cleaned_data), duration)
    } else {
      log_error("Data validation failed", paste("Issues found:", length(issues)))
    }
    
    return(result)
    
  }, error = function(e) {
    log_error("Data validation error", e$message)
    return(list(
      valid = FALSE,
      issues = list(validation_error = e$message),
      data = NULL,
      summary = NULL
    ))
  })
}

#' Validate metadata file
#' 
#' @param metadata_df Metadata dataframe
#' @return List with validation results
validate_metadata <- function(metadata_df) {
  issues <- list()
  
  tryCatch({
    # Check required columns
    required_cols <- c("Symbol", "Company Name", "Industry")
    missing_cols <- setdiff(required_cols, names(metadata_df))
    
    if (length(missing_cols) > 0) {
      issues$missing_columns <- missing_cols
    }
    
    # Check for missing values
    for (col in required_cols) {
      if (col %in% names(metadata_df)) {
        missing_count <- sum(is.na(metadata_df[[col]]) | metadata_df[[col]] == "")
        if (missing_count > 0) {
          issues[[paste0("missing_", gsub(" ", "_", tolower(col)))]] <- missing_count
        }
      }
    }
    
    # Check for duplicate symbols
    if ("Symbol" %in% names(metadata_df)) {
      duplicates <- sum(duplicated(metadata_df$Symbol))
      if (duplicates > 0) {
        issues$duplicate_symbols <- duplicates
      }
    }
    
    return(list(
      valid = length(issues) == 0,
      issues = issues,
      summary = list(
        total_companies = nrow(metadata_df),
        industries = if("Industry" %in% names(metadata_df)) length(unique(metadata_df$Industry)) else 0
      )
    ))
    
  }, error = function(e) {
    log_error("Metadata validation error", e$message)
    return(list(
      valid = FALSE,
      issues = list(validation_error = e$message),
      summary = NULL
    ))
  })
}

#' Generate data quality report
#' 
#' @param validation_result Result from validate_stock_data
#' @return Formatted HTML report
generate_quality_report <- function(validation_result) {
  if (is.null(validation_result) || is.null(validation_result$summary)) {
    return("<p>No validation data available</p>")
  }
  
  summary <- validation_result$summary
  issues <- validation_result$issues
  
  # Create HTML report
  html <- paste0(
    "<div class='quality-report'>",
    "<h4>📊 Data Quality Report</h4>",
    "<div class='metrics'>",
    "<div class='metric'>",
    "<span class='label'>Total Records:</span>",
    "<span class='value'>", format(summary$total_rows, big.mark = ","), "</span>",
    "</div>",
    "<div class='metric'>",
    "<span class='label'>Unique Symbols:</span>",
    "<span class='value'>", summary$total_symbols, "</span>",
    "</div>",
    "<div class='metric'>",
    "<span class='label'>Date Range:</span>",
    "<span class='value'>", 
    if(!is.na(summary$date_range[1])) paste(summary$date_range[1], "to", summary$date_range[2]) else "N/A",
    "</span>",
    "</div>",
    "</div>"
  )
  
  # Add issues section if any
  if (length(issues) > 0) {
    html <- paste0(html, "<h5>⚠️ Data Issues:</h5><ul>")
    for (issue_name in names(issues)) {
      if (issue_name != "date_range") {
        html <- paste0(html, "<li>", issue_name, ": ", issues[[issue_name]], "</li>")
      }
    }
    html <- paste0(html, "</ul>")
  } else {
    html <- paste0(html, "<div class='success'>✅ No data quality issues found</div>")
  }
  
  html <- paste0(html, "</div>")
  return(html)
}