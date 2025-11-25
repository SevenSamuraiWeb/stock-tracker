# Unit Tests for Stock Dashboard
# Test suite for core functionality

library(testthat)
library(shiny)

# Source the functions to test
source("../utils.R")
source("../charts.R")
source("../config.R")

# Test Configuration
test_that("Configuration loads correctly", {
  expect_true(is.list(APP_CONFIG))
  expect_true(is.list(DATA_CONFIG))
  expect_true(is.list(API_CONFIG))
  expect_true("name" %in% names(APP_CONFIG))
  expect_true("version" %in% names(APP_CONFIG))
})

# Test Data Loading Functions
test_that("Data loading functions work", {
  # Test with mock data
  mock_nifty <- data.frame(
    Date = as.Date(c("2023-01-01", "2023-01-02")),
    Symbol = c("RELIANCE", "TCS"),
    Close = c(2500, 3200),
    Volume = c(1000000, 800000),
    stringsAsFactors = FALSE
  )
  
  mock_metadata <- data.frame(
    Symbol = c("RELIANCE", "TCS"),
    `Company Name` = c("Reliance Industries", "Tata Consultancy Services"),
    Industry = c("ENERGY", "IT"),
    stringsAsFactors = FALSE
  )
  
  # Test get_stock_list function
  stock_list <- get_stock_list(mock_nifty)
  expect_true(is.data.frame(stock_list))
  expect_equal(nrow(stock_list), 2)
  expect_true(all(c("Symbol") %in% names(stock_list)))
  
  # Test get_industry_list function  
  industries <- get_industry_list(mock_metadata)
  expect_true(is.character(industries))
  expect_true(length(industries) >= 1)
})

# Test Utility Functions
test_that("Utility functions work correctly", {
  # Test format_currency
  expect_equal(format_currency(1234.56), "₹ 1,234.56")
  expect_equal(format_currency(NA), "N/A")
  
  # Test format_large_number
  expect_equal(format_large_number(1000), "1.00K")
  expect_equal(format_large_number(1000000), "1.00M")
  expect_equal(format_large_number(1000000000), "1.00B")
  expect_equal(format_large_number(NA), "N/A")
})

# Test Data Filtering
test_that("Data filtering works correctly", {
  mock_data <- data.frame(
    Date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")),
    Symbol = c("RELIANCE", "TCS", "RELIANCE"),
    Close = c(2500, 3200, 2550),
    Industry = c("ENERGY", "IT", "ENERGY"),
    stringsAsFactors = FALSE
  )
  
  # Test symbol filtering
  filtered <- filter_data(mock_data, stock_symbol = "RELIANCE")
  expect_equal(nrow(filtered), 2)
  expect_true(all(filtered$Symbol == "RELIANCE"))
  
  # Test industry filtering
  filtered <- filter_data(mock_data, industry = "IT")
  expect_equal(nrow(filtered), 1)
  expect_true(all(filtered$Industry == "IT"))
  
  # Test date filtering
  start_date <- as.Date("2023-01-02")
  end_date <- as.Date("2023-01-03")
  filtered <- filter_data(mock_data, start_date = start_date, end_date = end_date)
  expect_equal(nrow(filtered), 2)
})

# Test Chart Functions (Basic structure tests)
test_that("Chart functions return plotly objects", {
  mock_data <- data.frame(
    Date = as.Date(c("2023-01-01", "2023-01-02")),
    Symbol = c("RELIANCE", "RELIANCE"),
    Close = c(2500, 2550),
    Open = c(2480, 2520),
    High = c(2580, 2600),
    Low = c(2460, 2500),
    Volume = c(1000000, 1200000),
    stringsAsFactors = FALSE
  )
  
  # Test that functions don't throw errors
  expect_error(plot_stock_price(mock_data, "RELIANCE"), NA)
  expect_error(plot_candlestick(mock_data, "RELIANCE"), NA)
  expect_error(plot_volume(mock_data, "RELIANCE"), NA)
})

# Test Error Handling
test_that("Error handling works correctly", {
  # Test with empty data
  empty_data <- data.frame()
  
  expect_no_error(get_stock_list(empty_data))
  expect_no_error(get_industry_list(empty_data))
  
  # Test with NULL data
  expect_no_error(get_stock_list(NULL))
  expect_no_error(get_industry_list(NULL))
})

# Performance Tests
test_that("Functions perform within acceptable time", {
  # Generate larger mock dataset
  n_rows <- 1000
  mock_large_data <- data.frame(
    Date = seq(from = as.Date("2020-01-01"), by = "day", length.out = n_rows),
    Symbol = rep(c("RELIANCE", "TCS", "INFY", "HDFC", "ICICI"), length.out = n_rows),
    Close = runif(n_rows, 1000, 5000),
    Volume = runif(n_rows, 100000, 5000000),
    Industry = rep(c("ENERGY", "IT", "IT", "FINANCIAL", "FINANCIAL"), length.out = n_rows),
    stringsAsFactors = FALSE
  )
  
  # Test that operations complete within reasonable time (5 seconds)
  expect_lt(system.time(get_stock_list(mock_large_data))["elapsed"], 5)
  expect_lt(system.time(filter_data(mock_large_data, stock_symbol = "RELIANCE"))["elapsed"], 5)
})