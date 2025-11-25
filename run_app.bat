@echo off
echo Starting NIFTY 50 Stock Dashboard...
echo.

REM Check if data files exist
if not exist "NIFTY50_all.csv" (
    echo Error: NIFTY50_all.csv not found!
    echo Please ensure the data file is in the current directory.
    pause
    exit /b 1
)

if not exist "stock_metadata.csv" (
    echo Error: stock_metadata.csv not found!  
    echo Please ensure the metadata file is in the current directory.
    pause
    exit /b 1
)

echo Data files found! ✓
echo Launching R Shiny application...
echo.
echo The dashboard will open in your default web browser.
echo Press Ctrl+C to stop the application.
echo.

"C:\Program Files\R\R-4.4.1\bin\Rscript.exe" -e "shiny::runApp('app.R', launch.browser = TRUE)"

pause