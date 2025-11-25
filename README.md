# NIFTY 50 Stock Dashboard - R Shiny Version

A comprehensive stock market dashboard built with R Shiny for analyzing NIFTY 50 stocks. This application provides interactive visualizations, real-time news, and detailed financial analysis.

## Features

- **Interactive Stock Analysis**: Real-time price charts, candlestick charts, and volume analysis
- **Industry Comparison**: Market share analysis and industry performance comparison
- **News Integration**: Latest financial news using SerpAPI
- **Dark Theme**: Modern dark UI optimized for financial data analysis
- **Responsive Design**: Works on desktop and tablet devices
- **Data Filtering**: Filter by industry, date range, and stock selection

## Screenshots

The dashboard includes:
- Stock price history with line and candlestick charts
- Trading volume analysis
- Industry-wise market share visualization
- Real-time news feed for selected stocks
- Key financial metrics display

## Installation

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/JosephJonathanFernandes/stock-tracker.git
   cd stock-tracker
   ```

2. **Install required R packages**:
   ```r
   # Run the installation script
   source("install_packages.R")
   
   # Or install packages manually
   install.packages(c(
     "shiny", "shinydashboard", "DT", "dplyr", "readr", 
     "lubridate", "tidyr", "plotly", "ggplot2", "httr", 
     "jsonlite", "shinycssloaders", "htmltools"
   ))
   ```

3. **Ensure data files are present**:
   - `NIFTY50_all.csv` - Stock price data
   - `stock_metadata.csv` - Company metadata

4. **Run the application**:
   ```r
   # In R console or RStudio
   shiny::runApp("app.R")
   
   # Or run in browser
   shiny::runApp("app.R", launch.browser = TRUE)
   ```

## File Structure

```
stock-tracker/
├── app.R                 # Main Shiny application
├── utils.R               # Utility functions for data processing
├── charts.R              # Chart creation functions
├── news.R                # News fetching functions
├── install_packages.R    # Package installation script
├── requirements.R        # List of required packages
├── assets/
│   └── style.css         # Custom CSS for dark theme
├── NIFTY50_all.csv      # Stock price data
├── stock_metadata.csv    # Company information
└── README.md            # This file
```

## Configuration

### News API Setup

The application uses SerpAPI for fetching real-time news. To configure:

1. Get a SerpAPI key from [serpapi.com](https://serpapi.com)
2. Update the `SERPAPI_KEY` variable in `news.R`
3. Alternatively, set it as an environment variable:
   ```r
   Sys.setenv(SERPAPI_KEY = "your_api_key_here")
   ```

### Data Sources

- **Stock Data**: Historical NIFTY 50 stock prices
- **Metadata**: Company information including industry classification
- **News**: Real-time financial news via SerpAPI

## Usage

1. **Select Industry**: Filter stocks by industry sector
2. **Choose Stock**: Search and select specific stocks
3. **Set Date Range**: Analyze data for custom time periods
4. **View Charts**: Toggle between line and candlestick charts
5. **Read News**: Get latest news for selected stocks

## Key Features Explained

### Data Processing (`utils.R`)
- Data loading and merging functionality
- Filtering and aggregation functions
- Statistical calculations

### Visualizations (`charts.R`)
- Interactive Plotly charts with dark theme
- Candlestick and line charts for price analysis
- Volume analysis and industry comparisons
- Responsive design for different screen sizes

### News Integration (`news.R`)
- Real-time news fetching via SerpAPI
- Sentiment analysis of news headlines
- Fallback to mock data when API is unavailable

### UI/UX (`app.R`)
- Modern Shiny Dashboard layout
- Responsive value boxes for key metrics
- Interactive filters and controls
- Dark theme optimized for financial data

## Customization

### Adding New Chart Types
To add new visualizations, create functions in `charts.R` following the existing pattern:

```r
plot_new_chart <- function(df, symbol) {
  # Your Plotly code here
  return(plotly_object)
}
```

### Modifying the Theme
Update `assets/style.css` to customize colors, fonts, and layout.

### Adding New Data Sources
Extend `utils.R` with new data loading functions and update the main app accordingly.

## Performance Optimization

- Data is loaded once at startup for better performance
- Reactive expressions are used to minimize unnecessary computations
- CSS and JavaScript are optimized for smooth interactions
- Large datasets are handled efficiently with R's data.table equivalents

## Troubleshooting

### Common Issues

1. **Package Installation Errors**:
   ```r
   # Update R and try again
   update.packages()
   ```

2. **Data Loading Issues**:
   - Ensure CSV files are in the correct format
   - Check file paths and permissions

3. **Chart Not Displaying**:
   - Verify plotly package installation
   - Check browser console for JavaScript errors

4. **News Not Loading**:
   - Verify SerpAPI key configuration
   - Check internet connection
   - Review API usage limits

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- NIFTY 50 data providers
- SerpAPI for news integration
- R Shiny and Plotly communities
- Dark theme inspired by modern financial applications

## Migration Notes

This R Shiny version replaces the original Python Streamlit application with:
- **Enhanced Performance**: Better handling of large datasets
- **More Interactive Charts**: Advanced Plotly integration
- **Professional UI**: Shiny Dashboard framework
- **Better Modularity**: Separated concerns across multiple R files
- **Improved News Integration**: More robust API handling

### Differences from Python Version

- Uses Shiny instead of Streamlit for web framework
- Plotly charts are more deeply integrated with R
- Better reactive programming model
- More sophisticated error handling
- Enhanced CSS theming capabilities

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/JosephJonathanFernandes/stock-tracker) or contact the maintainers.