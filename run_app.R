# Quick Launch Script for NIFTY 50 Stock Dashboard
# This script will install missing packages and launch the Shiny app

# Clear console
cat("\014")

# Print welcome message
cat("=======================================================\n")
cat("      NIFTY 50 Stock Dashboard - R Shiny Version      \n")
cat("=======================================================\n\n")

# Check if required packages are installed
cat("Checking required packages...\n")

required_packages <- c(
  "shiny", "shinydashboard", "DT", "dplyr", "readr", 
  "lubridate", "tidyr", "plotly", "httr", "jsonlite",
  "shinycssloaders", "htmltools"
)

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, dependencies = TRUE, quiet = TRUE)
} else {
  cat("✓ All required packages are installed!\n")
}

# Check if data files exist
cat("\nChecking data files...\n")
if (file.exists("NIFTY50_all.csv") && file.exists("stock_metadata.csv")) {
  cat("✓ Data files found!\n")
} else {
  cat("⚠ Warning: Data files not found. Please ensure NIFTY50_all.csv and stock_metadata.csv are in the current directory.\n")
}

# Launch the application
cat("\nLaunching Shiny application...\n")
cat("The dashboard will open in your default web browser.\n")
cat("Press Ctrl+C in the console to stop the application.\n\n")

# Set options for better performance
options(
  shiny.maxRequestSize = 100 * 1024^2,  # 100 MB max file size
  shiny.trace = FALSE,                   # Disable tracing for performance
  warn = -1                             # Suppress warnings during startup
)

# Launch the app
if (file.exists("app.R")) {
  shiny::runApp("app.R", launch.browser = TRUE, quiet = TRUE)
} else {
  cat("Error: app.R not found in current directory.\n")
  cat("Please navigate to the correct directory and try again.\n")
}