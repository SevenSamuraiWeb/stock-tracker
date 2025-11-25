# Install Required R Packages for Stock Dashboard
# Run this script before running the Shiny application

# List of required packages
required_packages <- c(
  "shiny",
  "shinydashboard", 
  "DT",
  "dplyr",
  "readr", 
  "lubridate",
  "tidyr",
  "plotly",
  "ggplot2",
  "httr",
  "jsonlite",
  "rvest",
  "shinycssloaders",
  "htmltools",
  "htmlwidgets",
  "shinyWidgets"
)

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