# Simple test to check what's causing the app to stop
library(shiny)

# Source all required files
tryCatch({
  source("config.R")
  cat("Config loaded successfully\n")
}, error = function(e) {
  cat("Error loading config:", e$message, "\n")
})

tryCatch({
  source("utils.R")
  cat("Utils loaded successfully\n")
}, error = function(e) {
  cat("Error loading utils:", e$message, "\n")
})

tryCatch({
  source("logger.R")
  cat("Logger loaded successfully\n")
}, error = function(e) {
  cat("Error loading logger:", e$message, "\n")
})

tryCatch({
  source("validation.R")
  cat("Validation loaded successfully\n")
}, error = function(e) {
  cat("Error loading validation:", e$message, "\n")
})

tryCatch({
  source("charts.R")
  cat("Charts loaded successfully\n")
}, error = function(e) {
  cat("Error loading charts:", e$message, "\n")
})

tryCatch({
  source("regression.R")
  cat("Regression loaded successfully\n")
}, error = function(e) {
  cat("Error loading regression:", e$message, "\n")
})

# Test data loading
tryCatch({
  data_list <- load_data(DATA_CONFIG$nifty_file, DATA_CONFIG$metadata_file)
  if (is.null(data_list)) {
    cat("Data loading returned NULL\n")
  } else {
    cat("Data loaded successfully, rows:", nrow(data_list$merged_df), "\n")
  }
}, error = function(e) {
  cat("Error loading data:", e$message, "\n")
})

cat("Test complete\n")