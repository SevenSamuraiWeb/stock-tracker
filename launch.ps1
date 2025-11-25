# PowerShell Script to Launch NIFTY 50 Stock Dashboard
# Double-click this file or run from PowerShell to start the application

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "      NIFTY 50 Stock Dashboard - R Shiny Version      " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# Check if R is installed
try {
    $rVersion = & Rscript --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ R is installed and accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ R not found. Please install R from https://cran.r-project.org/" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if required files exist
$requiredFiles = @("app.R", "utils.R", "charts.R", "news.R", "NIFTY50_all.csv", "stock_metadata.csv")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "✗ Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Host "✓ All required files found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting the Shiny application..." -ForegroundColor Yellow
Write-Host "This may take a moment to install packages and load data..." -ForegroundColor Yellow
Write-Host "The dashboard will open in your default web browser." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the application." -ForegroundColor Red
Write-Host ""

# Launch the R application
try {
    & Rscript run_app.R
} catch {
    Write-Host "Error launching the application: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}