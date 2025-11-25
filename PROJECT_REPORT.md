# Stock Tracker — Project Report

Date: 2025-11-25

Prepared by: Joseph Jonathan Fernandes, Nihaal Virgincar, Pratik Nayak, Rajivkumar Naik

---

## Project Overview

Stock Tracker is an interactive R Shiny dashboard for analysis of NIFTY 50 stocks. The project provides data ingestion, validation and quality checks, interactive visualization (time-series, candlesticks, volume, correlations), and an integrated regression analysis module that produces forecasts, trend metrics, and downloadable reports.

The application is designed for analysts and traders who want a quick, exploratory workspace with reproducible outputs and exportable artifacts.

## Contributors

- Joseph Jonathan Fernandes — Lead developer, app architecture, regression module
- Nihaal Virgincar — Frontend UI/UX and charting (Plotly) improvements
- Pratik Nayak — Data validation, ETL utilities, test harnesses
- Rajivkumar Naik — Packaging, installer scripts, logging and deployment helper scripts

## Key Features

- Data ingestion from CSV sources (`NIFTY50_all.csv`, `stock_metadata.csv`)
- Data quality and validation dashboard with missing-data analysis and distribution charts
- Interactive charts built with Plotly: line charts, candlestick charts, moving averages, and correlation heatmaps
- Regression analysis module supporting multiple model types (linear, log-linear, polynomial, multiple regression) with:
  - Model summaries, R² and diagnostic metrics
  - Multi-day forecasts and confidence bands
  - Price predictions table with currency formatting
  - Downloadable markdown reports summarizing the analysis
- Defensive logging using `futile.logger` with a custom wrapper to centralize messages and performance metrics
- Installer script to ensure required R packages are present on the host
- Test scripts for targeted verification of the data pipeline and regression outputs

## Architecture and Code Layout

Top-level files and folders:

- `app.R` — Main Shiny UI and server logic
- `regression.R` — Regression engine, prediction generation, helper metrics
- `charts.R` — Plotly chart builders and helpers (price chart, candlesticks, regression overlay)
- `validation.R` — Data quality checks and summary report generation
- `utils.R` — Data loading and helper utilities
- `logger.R` — Logging initialization and wrappers around `futile.logger`
- `assets/style.css` — Application styling for dark theme (custom styles for predictions table)
- `install_packages.R` and `run_app.bat`/`run_with_regression.bat` — Environment setup and launch helpers
- `tests/` (ad-hoc test scripts) — `basic_test.R`, `test_regression_run.R`, `test_quality_report.R`

Design notes:

- UI is built using `shinydashboard` with modular server-side functions.

- Reactive flows: user selects symbol/date range → filtered data used for charts/metrics → regression triggered by explicit button press (`Run Analysis`).
