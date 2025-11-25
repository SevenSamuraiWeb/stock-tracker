# Stock Tracker Application
# Professional R Shiny Stock Analysis Platform

# DEPLOYMENT CONFIGURATION
# ========================

# Application Configuration
APP_VERSION <- "2.0.0"
APP_NAME <- "Professional Stock Tracker"
APP_DESCRIPTION <- "Advanced stock analysis platform with real-time data visualization and news integration"

# Production Settings
PRODUCTION_MODE <- Sys.getenv("STOCK_TRACKER_PRODUCTION", "false") == "true"
PORT <- as.numeric(Sys.getenv("STOCK_TRACKER_PORT", "3838"))
HOST <- Sys.getenv("STOCK_TRACKER_HOST", "0.0.0.0")

# Performance Settings
MAX_WORKERS <- as.numeric(Sys.getenv("SHINY_WORKERS", "4"))
MEMORY_LIMIT_MB <- as.numeric(Sys.getenv("MEMORY_LIMIT", "2048"))

# Security Settings
ENABLE_AUTH <- Sys.getenv("ENABLE_AUTH", "false") == "true"
SECRET_KEY <- Sys.getenv("SECRET_KEY", "change-me-in-production")

# Database Configuration (for future use)
DB_HOST <- Sys.getenv("DB_HOST", "localhost")
DB_PORT <- as.numeric(Sys.getenv("DB_PORT", "5432"))
DB_NAME <- Sys.getenv("DB_NAME", "stock_tracker")
DB_USER <- Sys.getenv("DB_USER", "postgres")
DB_PASSWORD <- Sys.getenv("DB_PASSWORD", "")

# API Configuration
API_RATE_LIMIT <- as.numeric(Sys.getenv("API_RATE_LIMIT", "100"))  # requests per hour
API_TIMEOUT <- as.numeric(Sys.getenv("API_TIMEOUT", "30"))  # seconds

# Monitoring Configuration
ENABLE_MONITORING <- Sys.getenv("ENABLE_MONITORING", "true") == "true"
LOG_LEVEL <- Sys.getenv("LOG_LEVEL", if (PRODUCTION_MODE) "INFO" else "DEBUG")
METRICS_COLLECTION <- Sys.getenv("METRICS_COLLECTION", "true") == "true"

# Data Configuration
DATA_REFRESH_INTERVAL <- as.numeric(Sys.getenv("DATA_REFRESH_HOURS", "1"))  # hours
CACHE_SIZE_LIMIT <- as.numeric(Sys.getenv("CACHE_SIZE_MB", "500"))  # MB
AUTO_CLEANUP <- Sys.getenv("AUTO_CLEANUP", "true") == "true"

# Feature Flags
ENABLE_NEWS <- Sys.getenv("ENABLE_NEWS", "true") == "true"
ENABLE_CHARTS <- Sys.getenv("ENABLE_CHARTS", "true") == "true"
ENABLE_EXPORT <- Sys.getenv("ENABLE_EXPORT", "true") == "true"
ENABLE_ALERTS <- Sys.getenv("ENABLE_ALERTS", "false") == "true"

# Print deployment info
if (PRODUCTION_MODE) {
  cat("=== PRODUCTION DEPLOYMENT ===\n")
  cat(paste("Application:", APP_NAME, "v", APP_VERSION, "\n"))
  cat(paste("Host:", HOST, "Port:", PORT, "\n"))
  cat(paste("Workers:", MAX_WORKERS, "Memory Limit:", MEMORY_LIMIT_MB, "MB\n"))
  cat(paste("Authentication:", if (ENABLE_AUTH) "ENABLED" else "DISABLED", "\n"))
  cat(paste("Monitoring:", if (ENABLE_MONITORING) "ENABLED" else "DISABLED", "\n"))
  cat("=============================\n")
} else {
  cat("=== DEVELOPMENT MODE ===\n")
  cat(paste("App:", APP_NAME, "v", APP_VERSION, "\n"))
  cat(paste("Running on:", HOST, ":", PORT, "\n"))
  cat("======================\n")
}

# Environment validation
validate_environment <- function() {
  required_packages <- c("shiny", "shinydashboard", "plotly", "dplyr", "readr")
  missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
  
  if (length(missing_packages) > 0) {
    stop(paste("Missing required packages:", paste(missing_packages, collapse = ", ")))
  }
  
  # Check data file exists
  if (!file.exists("stock_data.csv")) {
    warning("Stock data file not found. Some features may not work properly.")
  }
  
  # Validate API key if news is enabled
  if (ENABLE_NEWS && nchar(Sys.getenv("SERPAPI_API_KEY", "")) == 0) {
    warning("SERPAPI_API_KEY not set. News features will be disabled.")
  }
  
  cat("Environment validation completed successfully.\n")
}

# Run validation
tryCatch({
  validate_environment()
}, error = function(e) {
  cat("DEPLOYMENT ERROR:", e$message, "\n")
  if (PRODUCTION_MODE) {
    stop("Cannot start in production mode with validation errors")
  }
})

# Export configuration for use in other modules
DEPLOYMENT_CONFIG <- list(
  version = APP_VERSION,
  production = PRODUCTION_MODE,
  port = PORT,
  host = HOST,
  log_level = LOG_LEVEL,
  enable_monitoring = ENABLE_MONITORING,
  enable_news = ENABLE_NEWS,
  enable_charts = ENABLE_CHARTS,
  api_rate_limit = API_RATE_LIMIT,
  data_refresh_interval = DATA_REFRESH_INTERVAL
)