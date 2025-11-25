#!/bin/bash
# Production Deployment Script for Professional Stock Tracker
# Optimized for production environment deployment

echo "======================================="
echo "Professional Stock Tracker Deployment"
echo "Version: 2.0.0"
echo "======================================="

# Set production environment variables
export STOCK_TRACKER_PRODUCTION=true
export STOCK_TRACKER_PORT=${PORT:-3838}
export STOCK_TRACKER_HOST=${HOST:-0.0.0.0}
export LOG_LEVEL=${LOG_LEVEL:-INFO}
export SHINY_WORKERS=${SHINY_WORKERS:-4}
export MEMORY_LIMIT=${MEMORY_LIMIT:-2048}

# Security settings
export SECRET_KEY=${SECRET_KEY:-$(openssl rand -hex 32)}
export ENABLE_AUTH=${ENABLE_AUTH:-false}

# Performance settings
export DATA_REFRESH_HOURS=${DATA_REFRESH_HOURS:-1}
export CACHE_SIZE_MB=${CACHE_SIZE_MB:-500}
export API_RATE_LIMIT=${API_RATE_LIMIT:-100}

echo "Environment Configuration:"
echo "  Port: $STOCK_TRACKER_PORT"
echo "  Host: $STOCK_TRACKER_HOST" 
echo "  Workers: $SHINY_WORKERS"
echo "  Memory Limit: $MEMORY_LIMIT MB"
echo "  Log Level: $LOG_LEVEL"
echo ""

# Check for R installation
if ! command -v R &> /dev/null; then
    echo "ERROR: R is not installed or not in PATH"
    echo "Please install R version 4.0 or higher"
    exit 1
fi

echo "✓ R installation found"

# Check for required data files
if [[ ! -f "stock_data.csv" ]]; then
    echo "WARNING: stock_data.csv not found"
    echo "Some features may not work properly"
fi

# Check for configuration files
if [[ ! -f "config.R" ]]; then
    echo "ERROR: config.R not found"
    echo "Please ensure all configuration files are present"
    exit 1
fi

echo "✓ Configuration files found"

# Create logs directory if it doesn't exist
mkdir -p logs

# Create production optimization
export R_GC_MEM_GROW=3
export R_NSIZE=4000000
export R_VSIZE=16777216

echo "Starting Professional Stock Tracker in PRODUCTION mode..."
echo "Application will be available at: http://$STOCK_TRACKER_HOST:$STOCK_TRACKER_PORT"
echo ""
echo "To stop the application, press Ctrl+C"
echo "======================================="

# Start the application with production settings
exec R --no-restore --no-save -e "
  # Load deployment configuration
  source('deployment.R')
  
  # Start application
  shiny::runApp(
    appDir = '.',
    host = '$STOCK_TRACKER_HOST',
    port = as.numeric('$STOCK_TRACKER_PORT'),
    launch.browser = FALSE
  )
"