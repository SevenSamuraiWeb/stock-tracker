# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Improvements to UI styling and data-quality display
- Defensive plotting fixes (trace-length alignment)
- Predictions table formatting and styling

## [2.0.0] - 2025-11-25
### Added
- Regression analysis module with multiple model types and forecasts
- Data Quality tab with HTML report, missing-data plot, and distribution charts
- `PROJECT_REPORT.md` and professional documentation updates
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`

### Fixed
- Plotly `recycle_columns` error by aligning trace lengths
- Missing `log_info()` wrapper for logging
- Sidebar `Data Quality` menu linking to correct tab

### Changed
- Predictions table now uses numeric columns with `DT::formatCurrency`
- Added CSS rules under `assets/style.css` for `.predictions-table` to improve readability


## [1.0.0] - Initial baseline
- Initial project skeleton and basic dashboard features.