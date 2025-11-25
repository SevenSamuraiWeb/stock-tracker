# Utility Functions for Stock Dashboard
# R equivalent of utils.py

library(dplyr)
library(readr)
library(lubridate)

#' Load and merge NIFTY 50 data and stock metadata
#' 
#' @param nifty_path Path to NIFTY 50 CSV file
#' @param metadata_path Path to stock metadata CSV file
#' @return List containing merged dataframe and metadata
load_data <- function(nifty_path, metadata_path) {
  tryCatch({
    # Load NIFTY 50 data
    df <- read_csv(nifty_path, show_col_types = FALSE)
    df$Date <- as_date(df$Date)
    
    # Load Metadata
    metadata <- read_csv(metadata_path, show_col_types = FALSE)
    
    # Merge on Symbol
    merged_df <- df %>%
      left_join(metadata, by = "Symbol")
    
    return(list(
      merged_df = merged_df,
      metadata = metadata
    ))
  }, error = function(e) {
    warning(paste("Error loading data:", e$message))
    return(NULL)
  })
}

#' Filter dataframe based on user inputs
#' 
#' @param df Input dataframe
#' @param stock_symbol Stock symbol to filter by
#' @param start_date Start date for filtering
#' @param end_date End date for filtering
#' @param industry Industry to filter by
#' @return Filtered dataframe
filter_data <- function(df, stock_symbol = NULL, start_date = NULL, end_date = NULL, industry = NULL) {
  filtered_df <- df
  
  if (!is.null(stock_symbol)) {
    filtered_df <- filtered_df %>% filter(Symbol == stock_symbol)
  }
  
  if (!is.null(industry)) {
    filtered_df <- filtered_df %>% filter(Industry == industry)
  }
  
  if (!is.null(start_date) && !is.null(end_date)) {
    start_date <- as_date(start_date)
    end_date <- as_date(end_date)
    filtered_df <- filtered_df %>% 
      filter(Date >= start_date & Date <= end_date)
  }
  
  return(filtered_df)
}

#' Get list of unique stock symbols and company names
#' 
#' @param df Input dataframe
#' @return Dataframe with Symbol and Company Name columns
get_stock_list <- function(df) {
  if (!is.null(df) && nrow(df) > 0) {
    return(
      df %>%
        select(Symbol, `Company Name`) %>%
        distinct() %>%
        arrange(Symbol)
    )
  }
  return(data.frame(Symbol = character(), `Company Name` = character()))
}

#' Get list of unique industries
#' 
#' @param df Input dataframe
#' @return Vector of unique industry names
get_industry_list <- function(df) {
  if (!is.null(df) && nrow(df) > 0) {
    return(sort(unique(df$Industry)))
  }
  return(character())
}

#' Get formatted stock choices for selectInput
#' 
#' @param df Input dataframe
#' @return Named vector suitable for Shiny selectInput choices
get_stock_choices <- function(df) {
  stock_list <- get_stock_list(df)
  if (nrow(stock_list) > 0) {
    choices <- paste(stock_list$Symbol, "-", stock_list$`Company Name`)
    names(choices) <- choices
    return(choices)
  }
  return(character())
}

#' Calculate basic statistics for a stock
#' 
#' @param df Input dataframe for a single stock
#' @return List with basic statistics
calculate_stock_stats <- function(df) {
  if (nrow(df) == 0) {
    return(list(
      avg_price = NA,
      avg_volume = NA,
      volatility = NA,
      total_trades = NA
    ))
  }
  
  return(list(
    avg_price = mean(df$Close, na.rm = TRUE),
    avg_volume = mean(df$Volume, na.rm = TRUE),
    volatility = sd(df$Close, na.rm = TRUE),
    total_trades = sum(df$Trades, na.rm = TRUE)
  ))
}

#' Get latest stock data
#' 
#' @param df Input dataframe
#' @param symbol Stock symbol
#' @return Single row dataframe with latest data for the stock
get_latest_stock_data <- function(df, symbol) {
  stock_data <- df %>% 
    filter(Symbol == symbol) %>%
    arrange(desc(Date)) %>%
    slice_head(n = 1)
  
  return(stock_data)
}

#' Format currency values
#' 
#' @param value Numeric value
#' @param currency Currency symbol (default: "₹")
#' @return Formatted string
format_currency <- function(value, currency = "₹") {
  if (is.na(value)) return("N/A")
  paste(currency, format(round(value, 2), nsmall = 2, big.mark = ","))
}

#' Format large numbers with appropriate suffixes
#' 
#' @param value Numeric value
#' @return Formatted string with K, M, B suffixes
format_large_number <- function(value) {
  if (is.na(value)) return("N/A")
  
  if (value >= 1e9) {
    return(paste0(format(round(value / 1e9, 2), nsmall = 2), "B"))
  } else if (value >= 1e6) {
    return(paste0(format(round(value / 1e6, 2), nsmall = 2), "M"))
  } else if (value >= 1e3) {
    return(paste0(format(round(value / 1e3, 2), nsmall = 2), "K"))
  } else {
    return(format(value, big.mark = ","))
  }
}