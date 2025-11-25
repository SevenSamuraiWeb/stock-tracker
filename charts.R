# Chart Functions for Stock Dashboard
# R equivalent of charts.py

library(plotly)
library(dplyr)

#' Create an interactive line chart for stock closing price
#' 
#' @param df Dataframe with stock data
#' @param symbol Stock symbol for title
#' @return Plotly object
plot_stock_price <- function(df, symbol) {
  p <- plot_ly(df, x = ~Date, y = ~Close, type = 'scatter', mode = 'lines',
               line = list(color = '#60a5fa', width = 2),
               hovertemplate = paste(
                 "<b>Date:</b> %{x}<br>",
                 "<b>Price:</b> ₹%{y:.2f}<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = paste(symbol, "Stock Price History"),
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "Date",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      yaxis = list(
        title = "Price (INR)",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff'),
      hovermode = 'x unified'
    )
  
  return(p)
}

#' Create a candlestick chart for the stock
#' 
#' @param df Dataframe with stock data
#' @param symbol Stock symbol for title
#' @return Plotly object
plot_candlestick <- function(df, symbol) {
  p <- plot_ly(df, x = ~Date, type = "candlestick",
               open = ~Open, high = ~High, low = ~Low, close = ~Close,
               increasing = list(line = list(color = '#00ff00')),
               decreasing = list(line = list(color = '#ff0000')),
               hovertemplate = paste(
                 "<b>Date:</b> %{x}<br>",
                 "<b>Open:</b> ₹%{open:.2f}<br>",
                 "<b>High:</b> ₹%{high:.2f}<br>",
                 "<b>Low:</b> ₹%{low:.2f}<br>",
                 "<b>Close:</b> ₹%{close:.2f}<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = paste(symbol, "Candlestick Chart"),
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "Date",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151',
        rangeslider = list(visible = FALSE)
      ),
      yaxis = list(
        title = "Price (INR)",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff')
    )
  
  return(p)
}

#' Create a bar chart for trading volume
#' 
#' @param df Dataframe with stock data
#' @param symbol Stock symbol for title
#' @return Plotly object
plot_volume <- function(df, symbol) {
  p <- plot_ly(df, x = ~Date, y = ~Volume, type = 'bar',
               marker = list(color = '#60a5fa'),
               hovertemplate = paste(
                 "<b>Date:</b> %{x}<br>",
                 "<b>Volume:</b> %{y:,.0f}<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = paste(symbol, "Trading Volume"),
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "Date",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      yaxis = list(
        title = "Volume",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff')
    )
  
  return(p)
}

#' Create a pie chart showing market share by industry (based on Volume)
#' 
#' @param df Dataframe with all stock data
#' @return Plotly object
plot_industry_pie <- function(df) {
  # Group by Industry and sum Volume
  industry_vol <- df %>%
    group_by(Industry) %>%
    summarise(Volume = sum(Volume, na.rm = TRUE), .groups = 'drop') %>%
    arrange(desc(Volume))
  
  p <- plot_ly(industry_vol, labels = ~Industry, values = ~Volume, type = 'pie',
               textinfo = 'label+percent',
               textposition = 'outside',
               hovertemplate = paste(
                 "<b>Industry:</b> %{label}<br>",
                 "<b>Volume:</b> %{value:,.0f}<br>",
                 "<b>Percentage:</b> %{percent}<br>",
                 "<extra></extra>"
               ),
               marker = list(
                 colors = c('#60a5fa', '#34d399', '#fbbf24', '#f87171', '#a78bfa', 
                           '#fb7185', '#4ade80', '#38bdf8', '#fb923c', '#c084fc'),
                 line = list(color = '#1f2937', width = 2)
               )) %>%
    layout(
      title = list(
        text = "Market Share by Industry (Volume)",
        font = list(color = '#ffffff', size = 16)
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff'),
      showlegend = TRUE,
      legend = list(
        font = list(color = '#ffffff'),
        bgcolor = 'rgba(31, 41, 55, 0.8)'
      )
    )
  
  return(p)
}

#' Create a bar chart comparing average closing price across industries
#' 
#' @param df Dataframe with all stock data
#' @return Plotly object
plot_industry_comparison <- function(df) {
  # Group by Industry and calculate average closing price
  industry_avg <- df %>%
    group_by(Industry) %>%
    summarise(AvgClose = mean(Close, na.rm = TRUE), .groups = 'drop') %>%
    arrange(desc(AvgClose))
  
  p <- plot_ly(industry_avg, x = ~reorder(Industry, AvgClose), y = ~AvgClose, 
               type = 'bar',
               marker = list(color = '#60a5fa'),
               hovertemplate = paste(
                 "<b>Industry:</b> %{x}<br>",
                 "<b>Avg Price:</b> ₹%{y:.2f}<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = "Average Stock Price by Industry",
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "Industry",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff', size = 10),
        tickangle = -45,
        gridcolor = '#374151'
      ),
      yaxis = list(
        title = "Avg Price (INR)",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff'),
      margin = list(b = 150)  # Extra bottom margin for rotated labels
    )
  
  return(p)
}

#' Create a time series chart showing multiple stocks comparison
#' 
#' @param df Dataframe with stock data
#' @param symbols Vector of stock symbols to compare
#' @return Plotly object
plot_stocks_comparison <- function(df, symbols) {
  # Filter data for selected symbols and normalize prices
  comparison_data <- df %>%
    filter(Symbol %in% symbols) %>%
    group_by(Symbol) %>%
    arrange(Date) %>%
    mutate(
      first_price = first(Close),
      normalized_price = (Close / first_price) * 100
    ) %>%
    ungroup()
  
  p <- plot_ly(comparison_data, x = ~Date, y = ~normalized_price, 
               color = ~Symbol, type = 'scatter', mode = 'lines',
               line = list(width = 2),
               hovertemplate = paste(
                 "<b>Stock:</b> %{fullData.name}<br>",
                 "<b>Date:</b> %{x}<br>",
                 "<b>Normalized Price:</b> %{y:.2f}%<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = "Stock Price Comparison (Normalized)",
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "Date",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      yaxis = list(
        title = "Normalized Price (%)",
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff'),
      legend = list(
        font = list(color = '#ffffff'),
        bgcolor = 'rgba(31, 41, 55, 0.8)'
      ),
      hovermode = 'x unified'
    )
  
  return(p)
}

#' Create a correlation heatmap for selected stocks
#' 
#' @param df Dataframe with stock data
#' @param symbols Vector of stock symbols to analyze
#' @return Plotly object
plot_correlation_heatmap <- function(df, symbols) {
  # Create a wide format dataframe with closing prices
  wide_data <- df %>%
    filter(Symbol %in% symbols) %>%
    select(Date, Symbol, Close) %>%
    pivot_wider(names_from = Symbol, values_from = Close, values_fn = mean)
  
  # Calculate correlation matrix
  cor_matrix <- cor(wide_data[,-1], use = "complete.obs")
  
  # Convert to long format for plotting
  cor_data <- expand.grid(X = rownames(cor_matrix), Y = colnames(cor_matrix))
  cor_data$Correlation <- as.vector(cor_matrix)
  
  p <- plot_ly(cor_data, x = ~X, y = ~Y, z = ~Correlation, 
               type = "heatmap",
               colorscale = list(c(0, "red"), c(0.5, "white"), c(1, "green")),
               zmid = 0,
               hovertemplate = paste(
                 "<b>%{x}</b> vs <b>%{y}</b><br>",
                 "<b>Correlation:</b> %{z:.3f}<br>",
                 "<extra></extra>"
               )) %>%
    layout(
      title = list(
        text = "Stock Price Correlation Matrix",
        font = list(color = '#ffffff', size = 16)
      ),
      xaxis = list(
        title = "",
        tickfont = list(color = '#ffffff'),
        tickangle = -45
      ),
      yaxis = list(
        title = "",
        tickfont = list(color = '#ffffff')
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = '#ffffff')
    )
  
  return(p)
}