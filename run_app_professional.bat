@echo off
echo ================================
echo Professional Stock Tracker v2.0
echo ================================

REM Check if R is installed and accessible
echo Checking R installation...
R --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: R is not installed or not in PATH
    echo Please install R from https://cran.r-project.org/
    pause
    exit /b 1
)

echo R installation found.

REM Check if stock data exists
if not exist "stock_data.csv" (
    echo WARNING: stock_data.csv not found
    echo Some features may not work properly
    echo.
)

REM Set environment variables for development
set STOCK_TRACKER_PRODUCTION=false
set STOCK_TRACKER_PORT=4300
set STOCK_TRACKER_HOST=127.0.0.1
set LOG_LEVEL=INFO
set ENABLE_MONITORING=true

echo.
echo Starting Professional Stock Tracker...
echo Application will be available at: http://127.0.0.1:4300
echo.
echo Press Ctrl+C to stop the application
echo =====================================

REM Start the Shiny application
R -e "source('app.R')"

echo.
echo Application stopped.
pause