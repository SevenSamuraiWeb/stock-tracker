# Data Export Module
# Provides functionality to export data and reports

library(openxlsx)
library(jsonlite)

#' Export stock data to Excel
#' 
#' @param data Stock data to export
#' @param filename Output filename
#' @param symbol Stock symbol (optional)
#' @return Success status
export_to_excel <- function(data, filename = "stock_data_export.xlsx", symbol = NULL) {
  tryCatch({
    # Create workbook
    wb <- createWorkbook()
    
    # Add data sheet
    if (!is.null(symbol)) {
      sheet_name <- paste("Data", symbol, sep = "_")
    } else {
      sheet_name <- "Stock_Data"
    }
    
    addWorksheet(wb, sheet_name)
    writeData(wb, sheet_name, data)
    
    # Add summary sheet if data is available
    if (nrow(data) > 0) {
      summary_data <- data %>%
        group_by(Symbol) %>%
        summarize(
          Records = n(),
          Date_Range = paste(min(Date), "to", max(Date)),
          Avg_Price = round(mean(Close, na.rm = TRUE), 2),
          Max_Price = round(max(Close, na.rm = TRUE), 2),
          Min_Price = round(min(Close, na.rm = TRUE), 2),
          Total_Volume = sum(Volume, na.rm = TRUE),
          .groups = "drop"
        )
      
      addWorksheet(wb, "Summary")
      writeData(wb, "Summary", summary_data)
    }
    
    # Save workbook
    saveWorkbook(wb, filename, overwrite = TRUE)
    
    log_info(paste("Data exported to Excel:", filename))
    return(TRUE)
  }, error = function(e) {
    log_error(paste("Error exporting to Excel:", e$message))
    return(FALSE)
  })
}

#' Export stock data to CSV
#' 
#' @param data Stock data to export
#' @param filename Output filename
#' @return Success status
export_to_csv <- function(data, filename = "stock_data_export.csv") {
  tryCatch({
    write_csv(data, filename)
    log_info(paste("Data exported to CSV:", filename))
    return(TRUE)
  }, error = function(e) {
    log_error(paste("Error exporting to CSV:", e$message))
    return(FALSE)
  })
}

#' Export stock data to JSON
#' 
#' @param data Stock data to export
#' @param filename Output filename
#' @return Success status
export_to_json <- function(data, filename = "stock_data_export.json") {
  tryCatch({
    json_data <- toJSON(data, pretty = TRUE, auto_unbox = TRUE)
    writeLines(json_data, filename)
    log_info(paste("Data exported to JSON:", filename))
    return(TRUE)
  }, error = function(e) {
    log_error(paste("Error exporting to JSON:", e$message))
    return(FALSE)
  })
}

#' Generate comprehensive report
#' 
#' @param data Stock data
#' @param symbol Stock symbol
#' @return Report content
generate_stock_report <- function(data, symbol = NULL) {
  if (is.null(data) || nrow(data) == 0) {
    return("No data available for report generation.")
  }
  
  # Filter data by symbol if provided
  if (!is.null(symbol)) {
    data <- data %>% filter(Symbol == symbol)
    if (nrow(data) == 0) {
      return(paste("No data available for symbol:", symbol))
    }
  }
  
  # Calculate statistics
  stats <- data %>%
    summarize(
      total_records = n(),
      date_range = paste(min(Date), "to", max(Date)),
      avg_price = round(mean(Close, na.rm = TRUE), 2),
      median_price = round(median(Close, na.rm = TRUE), 2),
      max_price = round(max(Close, na.rm = TRUE), 2),
      min_price = round(min(Close, na.rm = TRUE), 2),
      price_volatility = round(sd(Close, na.rm = TRUE), 2),
      avg_volume = round(mean(Volume, na.rm = TRUE), 0),
      total_volume = sum(Volume, na.rm = TRUE)
    )
  
  # Create report
  report_lines <- c(
    if (!is.null(symbol)) paste("# Stock Report for", symbol) else "# Stock Data Report",
    paste("Generated on:", Sys.time()),
    "",
    "## Summary Statistics",
    paste("- Total Records:", format(stats$total_records, big.mark = ",")),
    paste("- Date Range:", stats$date_range),
    paste("- Average Price: $", stats$avg_price),
    paste("- Median Price: $", stats$median_price),
    paste("- Maximum Price: $", stats$max_price),
    paste("- Minimum Price: $", stats$min_price),
    paste("- Price Volatility: $", stats$price_volatility),
    paste("- Average Volume:", format(stats$avg_volume, big.mark = ",")),
    paste("- Total Volume:", format(stats$total_volume, big.mark = ",")),
    ""
  )
  
  # Add top performers if multiple symbols
  if (is.null(symbol) && "Symbol" %in% names(data)) {
    top_performers <- data %>%
      group_by(Symbol) %>%
      summarize(avg_price = mean(Close, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(avg_price)) %>%
      head(5)
    
    if (nrow(top_performers) > 0) {
      report_lines <- c(
        report_lines,
        "## Top 5 Stocks by Average Price",
        paste("1.", top_performers$Symbol[1], "- $", round(top_performers$avg_price[1], 2))
      )
      
      for (i in 2:min(5, nrow(top_performers))) {
        report_lines <- c(
          report_lines,
          paste(paste0(i, "."), top_performers$Symbol[i], "- $", round(top_performers$avg_price[i], 2))
        )
      }
      
      report_lines <- c(report_lines, "")
    }
  }
  
  # Add recent performance if time series data available
  if ("Date" %in% names(data)) {
    recent_data <- data %>%
      arrange(desc(Date)) %>%
      head(30)  # Last 30 records
    
    if (nrow(recent_data) > 1) {
      price_change <- recent_data$Close[1] - recent_data$Close[nrow(recent_data)]
      percent_change <- (price_change / recent_data$Close[nrow(recent_data)]) * 100
      
      report_lines <- c(
        report_lines,
        "## Recent Performance (Last 30 Records)",
        paste("- Price Change: $", round(price_change, 2)),
        paste("- Percentage Change:", round(percent_change, 2), "%"),
        paste("- Direction:", if (price_change >= 0) "UP ↗" else "DOWN ↘"),
        ""
      )
    }
  }
  
  # Footer
  report_lines <- c(
    report_lines,
    "---",
    "Report generated by Professional Stock Tracker v2.0",
    paste("Data as of:", Sys.time())
  )
  
  return(paste(report_lines, collapse = "\n"))
}

#' Save report to file
#' 
#' @param report_content Report content
#' @param filename Output filename
#' @return Success status
save_report <- function(report_content, filename = "stock_report.md") {
  tryCatch({
    writeLines(report_content, filename)
    log_info(paste("Report saved:", filename))
    return(TRUE)
  }, error = function(e) {
    log_error(paste("Error saving report:", e$message))
    return(FALSE)
  })
}