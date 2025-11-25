# Package Installation Script for Professional Stock Tracker
# This script installs all required R packages

cat("===================================\n")
cat("Professional Stock Tracker Setup\n")
cat("===================================\n\n")

# List of required packages organized by category
core_packages <- c(
  "shiny",
  "shinydashboard", 
  "DT",
  "plotly",
  "shinycssloaders"
)

data_packages <- c(
  "dplyr",
  "readr", 
  "tidyr",
  "lubridate"
)

# Professional features packages
professional_packages <- c(
  "futile.logger",
  "testthat",
  "digest",
  "config",
  "broom",        # For tidy statistical modeling
  "forecast",     # For time series forecasting
  "zoo"           # For rolling window calculations
)

optional_packages <- c(
  "httr",
  "jsonlite",
  "ggplot2",
  "htmltools",
  "htmlwidgets",
  "shinyWidgets"
)

# Combine all package lists
required_packages <- c(core_packages, data_packages, professional_packages, optional_packages)

# Function to install packages if they're not already installed
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat(paste("Installing package:", pkg, "\n"))
      install.packages(pkg, dependencies = TRUE)
    } else {
      cat(paste("Package", pkg, "is already installed\n"))
    }
  }
}

# Install missing packages
cat("Checking and installing required packages...\n")
install_if_missing(required_packages)

cat("\nAll required packages are now installed!\n")
cat("You can now run the Shiny application with:\n")
cat("shiny::runApp('app.R')\n")

# Verify installation
cat("\nVerifying package installation...\n")
all_installed <- TRUE
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste("ERROR: Failed to install", pkg, "\n"))
    all_installed <- FALSE
  }
}

if (all_installed) {
  cat("✓ All packages successfully installed!\n")
} else {
  cat("✗ Some packages failed to install. Please install them manually.\n")
}