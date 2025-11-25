@echo off
echo ================================
echo Professional Stock Tracker v2.0
echo ================================

REM Set R path
set R_PATH="C:\Program Files\R\R-4.4.1\bin\R.exe"

echo Checking R installation...
if not exist %R_PATH% (
    echo ERROR: R not found at %R_PATH%
    echo Please verify R installation path
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

REM Install required packages
echo Installing R packages...
echo Installing core packages...
%R_PATH% --no-restore --slave --no-save -e "if (!require('shiny', quietly=TRUE)) { install.packages('shiny', repos='https://cran.r-project.org'); }"
%R_PATH% --no-restore --slave --no-save -e "if (!require('shinydashboard', quietly=TRUE)) { install.packages('shinydashboard', repos='https://cran.r-project.org'); }"
%R_PATH% --no-restore --slave --no-save -e "if (!require('DT', quietly=TRUE)) { install.packages('DT', repos='https://cran.r-project.org'); }"
%R_PATH% --no-restore --slave --no-save -e "if (!require('futile.logger', quietly=TRUE)) { install.packages('futile.logger', repos='https://cran.r-project.org'); }"
%R_PATH% --no-restore --slave --no-save -e "if (!require('broom', quietly=TRUE)) { install.packages('broom', repos='https://cran.r-project.org'); }"
echo Package installation complete!

REM Set environment variables for development
set STOCK_TRACKER_PRODUCTION=false
set STOCK_TRACKER_PORT=4300
set STOCK_TRACKER_HOST=127.0.0.1
set LOG_LEVEL=INFO
set ENABLE_MONITORING=true

echo.
echo Starting Professional Stock Tracker with Regression Analysis...
echo Application will be available at: http://127.0.0.1:4300
echo.
echo Press Ctrl+C to stop the application
echo =====================================

REM Start the Shiny application
%R_PATH% --no-restore --slave --no-save -e "source('app.R')"

echo.
echo Application stopped.
pause