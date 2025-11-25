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

#' Enhanced stock price plot with regression analysis
#' 
#' @param data Stock data
#' @param symbol Stock symbol to plot
#' @param regression_results Regression analysis results
#' @param show_trend Whether to show trend lines
#' @return Plotly chart with regression analysis
plot_stock_price_with_regression <- function(data, symbol, regression_results, show_trend = TRUE) {
  if (is.null(data) || nrow(data) == 0) {
    return(plot_ly() %>% 
      add_annotations(
        text = "No data available",
        xref = "paper", yref = "paper",
        x = 0.5, y = 0.5, showarrow = FALSE,
        font = list(color = "white")
      ) %>%
      layout(
        plot_bgcolor = '#1f2937',
        paper_bgcolor = '#1f2937'
      ))
  }
  
  # Main price line
  p <- plot_ly(data, x = ~Date, y = ~Close, type = "scatter", mode = "lines",
               name = "Close Price",
               line = list(color = "#60a5fa", width = 3),
               hovertemplate = "<b>Close Price</b><br>Date: %{x}<br>Price: ₹%{y:.2f}<extra></extra>")
  
  # Add moving averages if data is sufficient
  if (nrow(data) >= 7) {
    data$ma_7 <- zoo::rollmean(data$Close, k = 7, fill = NA, align = "right")
    p <- p %>% add_trace(
      data = data,
      x = ~Date, y = ~ma_7,
      type = "scatter", mode = "lines",
      name = "7-day MA",
      line = list(color = "#FFA500", width = 1.5),
      hovertemplate = "<b>7-day MA</b><br>Date: %{x}<br>Price: ₹%{y:.2f}<extra></extra>"
    )
  }
  
  if (nrow(data) >= 20) {
    data$ma_20 <- zoo::rollmean(data$Close, k = 20, fill = NA, align = "right")
    p <- p %>% add_trace(
      data = data,
      x = ~Date, y = ~ma_20,
      type = "scatter", mode = "lines",
      name = "20-day MA",
      line = list(color = "#FF69B4", width = 1.5),
      hovertemplate = "<b>20-day MA</b><br>Date: %{x}<br>Price: ₹%{y:.2f}<extra></extra>"
    )
  }
  
  # Add regression analysis if available and requested
  if (!is.null(regression_results) && show_trend) {
    # Add trend line
    if (!is.null(regression_results$model_data)) {
      # Ensure model data and fitted values are aligned to the same length
      trend_data <- as.data.frame(regression_results$model_data)
      fitted_values <- as.numeric(fitted(regression_results$model))
      n_trend <- min(nrow(trend_data), length(fitted_values))
      if (n_trend > 0) {
        trend_df <- trend_data[seq_len(n_trend), , drop = FALSE]
        trend_df$.fitted <- fitted_values[seq_len(n_trend)]

        p <- p %>% add_trace(
          data = trend_df,
          x = ~Date, y = ~.fitted,
          type = "scatter", mode = "lines",
          name = paste("Trend Line (", regression_results$model_type, ")"),
          line = list(color = "#FFD700", width = 2, dash = "dot"),
          hovertemplate = "<b>Trend</b><br>Date: %{x}<br>Price: ₹%{y:.2f}<extra></extra>"
        )
      }
    }
    
    # Add predictions
    if (!is.null(regression_results$predictions)) {
      # Coerce to data.frame and ensure columns have compatible lengths
      pred_data <- as.data.frame(regression_results$predictions)
      if (nrow(pred_data) > 0) {
        pred_data <- head(pred_data, 15)
        required_cols <- c("Date", "predicted_price", "upper_bound", "lower_bound")
        if (all(required_cols %in% colnames(pred_data))) {
          # Trim to the minimum available length across required columns
          lens <- sapply(pred_data[required_cols], length)
          n_pred <- min(lens)
          if (n_pred > 0) {
            pred_data <- pred_data[seq_len(n_pred), , drop = FALSE]

            p <- p %>% add_trace(
              data = pred_data,
              x = ~Date, y = ~predicted_price,
              type = "scatter", mode = "lines+markers",
              name = "Price Forecast",
              line = list(color = "#FF6B6B", width = 2),
              marker = list(size = 4, color = "#FF6B6B"),
              hovertemplate = "<b>Forecast</b><br>Date: %{x}<br>Price: ₹%{y:.2f}<extra></extra>"
            )

            # Add confidence band traces (ensure same length)
            p <- p %>% add_trace(
              data = pred_data,
              x = ~Date, y = ~upper_bound,
              type = "scatter", mode = "lines",
              name = "Upper Confidence",
              line = list(color = "rgba(255, 107, 107, 0.3)", width = 1),
              showlegend = FALSE,
              hoverinfo = "skip"
            ) %>% add_trace(
              data = pred_data,
              x = ~Date, y = ~lower_bound,
              type = "scatter", mode = "lines",
              name = "Lower Confidence", 
              line = list(color = "rgba(255, 107, 107, 0.3)", width = 1),
              fill = "tonexty", fillcolor = "rgba(255, 107, 107, 0.1)",
              showlegend = FALSE,
              hoverinfo = "skip"
            )
          }
        }
      }
    }
  }
  
  # Enhanced layout
  title_text <- paste(symbol, "- Price Analysis with Regression")
  if (!is.null(regression_results)) {
    trend_dir <- regression_results$trend$direction
    r_squared <- round(regression_results$trend$r_squared, 3)
    title_text <- paste(title_text, "| Trend:", trend_dir, "| R² =", r_squared)
  }
  
  p <- p %>%
    layout(
      title = list(text = title_text, 
                   font = list(color = "white", size = 18)),
      xaxis = list(
        title = "Date", 
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      yaxis = list(
        title = "Price (₹)", 
        titlefont = list(color = '#ffffff'),
        tickfont = list(color = '#ffffff'),
        gridcolor = '#374151'
      ),
      plot_bgcolor = '#1f2937',
      paper_bgcolor = '#1f2937',
      font = list(color = "white"),
      showlegend = TRUE,
      legend = list(
        x = 0.02, y = 0.98,
        bgcolor = "rgba(0,0,0,0.7)",
        bordercolor = "white",
        borderwidth = 1,
        font = list(color = 'white')
      ),
      annotations = if (!is.null(regression_results)) {
        list(
          list(
            text = paste(
              "<b>Regression Analysis</b><br>",
              "Model:", tools::toTitleCase(gsub("_", " ", regression_results$model_type)), "<br>",
              "30-day forecast:", regression_results$metrics$expected_return_percent, "% return<br>",
              "Risk level:", if (regression_results$metrics$price_volatility_percent < 3) "Low" else if (regression_results$metrics$price_volatility_percent < 7) "Medium" else "High"
            ),
            xref = "paper", yref = "paper",
            x = 0.98, y = 0.98, xanchor = "right", yanchor = "top",
            showarrow = FALSE,
            font = list(color = "white", size = 11),
            bgcolor = "rgba(0,0,0,0.8)",
            bordercolor = "white",
            borderwidth = 1
          )
        )
      } else NULL
    )
  
  return(p)
}