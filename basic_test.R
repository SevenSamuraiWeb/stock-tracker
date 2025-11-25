# Simple test without complex dependencies
cat("Testing basic R functionality...\n")

# Test basic package loading
required_packages <- c("shiny", "shinydashboard", "DT", "plotly", "dplyr", "readr", "lubridate")

for (pkg in required_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("✓", pkg, "loaded successfully\n"))
  } else {
    cat(paste("✗", pkg, "failed to load\n"))
  }
}

cat("Package loading complete\n")

# Test data loading
cat("Testing data loading...\n")
tryCatch({
  df <- read.csv("NIFTY50_all.csv")
  cat(paste("✓ NIFTY50_all.csv loaded,", nrow(df), "rows\n"))
}, error = function(e) {
  cat(paste("✗ Error loading NIFTY50_all.csv:", e$message, "\n"))
})

tryCatch({
  metadata <- read.csv("stock_metadata.csv")
  cat(paste("✓ stock_metadata.csv loaded,", nrow(metadata), "rows\n"))
}, error = function(e) {
  cat(paste("✗ Error loading stock_metadata.csv:", e$message, "\n"))
})

cat("Basic test complete!\n")