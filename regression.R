# Linear Regression Analysis Module
# Advanced statistical modeling for stock price prediction and trend analysis

library(dplyr)
library(broom)
library(forecast)

#' Perform linear regression on stock price data
#' 
#' @param data Stock data with Date and Close columns
#' @param symbol Stock symbol for analysis
#' @param days_ahead Number of days to predict (default: 30)
#' @return List with model results, predictions, and statistics
perform_linear_regression <- function(data, symbol = NULL, days_ahead = 30) {
  tryCatch({
    # Check if required packages are available
    if (!requireNamespace("zoo", quietly = TRUE)) {
      warning("zoo package not available, using simplified calculations")
      use_zoo <- FALSE
    } else {
      use_zoo <- TRUE
    }
    
    # Filter data by symbol if provided
    if (!is.null(symbol) && "Symbol" %in% names(data)) {
      filtered_data <- data %>% filter(Symbol == symbol)
      if (nrow(filtered_data) == 0) {
        stop(paste("No data found for symbol:", symbol))
      }
    } else {
      filtered_data <- data
    }
    
    # Ensure we have required columns and enough data
    required_cols <- c("Date", "Close")
    missing_cols <- setdiff(required_cols, names(filtered_data))
    if (length(missing_cols) > 0) {
      stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
    }
    
    if (nrow(filtered_data) < 10) {
      stop("Insufficient data for regression analysis (minimum 10 points required)")
    }
    
    # Prepare data for regression
    model_data <- filtered_data %>%
      arrange(Date) %>%
      mutate(
        date_numeric = as.numeric(Date),
        day_index = row_number(),
        log_close = log(Close)  # Log transformation for better modeling
      )
    
    # Add moving averages and volatility using available functions
    if (use_zoo) {
      model_data <- model_data %>%
        mutate(
          ma_7 = zoo::rollmean(Close, k = 7, fill = NA, align = "right"),
          ma_20 = zoo::rollmean(Close, k = 20, fill = NA, align = "right"),
          volatility = zoo::rollapply(Close, width = 20, FUN = sd, fill = NA, align = "right")
        )
    } else {
      # Simple moving average calculation without zoo
      model_data$ma_7 <- NA
      model_data$ma_20 <- NA
      model_data$volatility <- NA
      
      for (i in 7:nrow(model_data)) {
        model_data$ma_7[i] <- mean(model_data$Close[(i-6):i], na.rm = TRUE)
      }
      for (i in 20:nrow(model_data)) {
        model_data$ma_20[i] <- mean(model_data$Close[(i-19):i], na.rm = TRUE)
        model_data$volatility[i] <- sd(model_data$Close[(i-19):i], na.rm = TRUE)
      }
    }
    
    model_data <- model_data %>%
      filter(!is.na(Close) & !is.infinite(log_close))
    
    # Multiple regression models
    models <- list()
    
    # 1. Simple linear regression (price vs time)
    models$simple <- lm(Close ~ day_index, data = model_data)
    
    # 2. Log-linear regression (log price vs time)
    models$log_linear <- lm(log_close ~ day_index, data = model_data)
    
    # 3. Polynomial regression (quadratic)
    models$polynomial <- lm(Close ~ poly(day_index, 2), data = model_data)
    
    # 4. Multiple regression with moving averages (if enough data)
    if (use_zoo && sum(!is.na(model_data$ma_20)) > 20) {
      models$multiple <- lm(Close ~ day_index + ma_7 + ma_20 + volatility, 
                           data = model_data %>% filter(!is.na(ma_20)))
    }
    
    # Select best model based on R-squared
    model_summaries <- lapply(models, function(m) {
      summary_stats <- summary(m)
      list(
        r_squared = summary_stats$r.squared,
        adj_r_squared = summary_stats$adj.r.squared,
        aic = AIC(m),
        rmse = sqrt(mean(residuals(m)^2))
      )
    })
    
    best_model_name <- names(model_summaries)[which.max(sapply(model_summaries, function(x) x$adj_r_squared))]
    best_model <- models[[best_model_name]]
    
    # Generate predictions
    last_day <- max(model_data$day_index)
    last_date <- max(model_data$Date)
    
    # Future data points for prediction
    future_data <- data.frame(
      day_index = (last_day + 1):(last_day + days_ahead),
      Date = seq.Date(from = last_date + 1, by = "day", length.out = days_ahead)
    )
    
    # Add moving averages for multiple regression model
    if (best_model_name == "multiple") {
      # Use last available values for MA prediction (simplified approach)
      last_ma_7 <- tail(model_data$ma_7[!is.na(model_data$ma_7)], 1)
      last_ma_20 <- tail(model_data$ma_20[!is.na(model_data$ma_20)], 1)
      last_volatility <- tail(model_data$volatility[!is.na(model_data$volatility)], 1)
      
      future_data$ma_7 <- last_ma_7
      future_data$ma_20 <- last_ma_20
      future_data$volatility <- last_volatility
    }
    
    # Make predictions with confidence intervals
    if (best_model_name == "log_linear") {
      # Transform back from log scale
      log_predictions <- predict(best_model, newdata = future_data, interval = "prediction")
      predictions_df <- data.frame(
        Date = future_data$Date,
        predicted_price = exp(log_predictions[, "fit"]),
        lower_bound = exp(log_predictions[, "lwr"]),
        upper_bound = exp(log_predictions[, "upr"])
      )
    } else {
      predictions <- predict(best_model, newdata = future_data, interval = "prediction")
      predictions_df <- data.frame(
        Date = future_data$Date,
        predicted_price = predictions[, "fit"],
        lower_bound = predictions[, "lwr"],
        upper_bound = predictions[, "upr"]
      )
    }
    
    # Calculate trend statistics
    slope <- coef(models$simple)[2]
    trend_direction <- ifelse(slope > 0, "Upward", ifelse(slope < 0, "Downward", "Flat"))
    trend_strength <- abs(slope) / mean(model_data$Close) * 100  # Percentage slope
    
    # Performance metrics
    current_price <- tail(model_data$Close, 1)
    predicted_30_day <- tail(predictions_df$predicted_price, 1)
    expected_return <- (predicted_30_day - current_price) / current_price * 100
    
    # Risk metrics
    price_volatility <- sd(model_data$Close) / mean(model_data$Close) * 100
    prediction_uncertainty <- mean((predictions_df$upper_bound - predictions_df$lower_bound) / predictions_df$predicted_price) * 100
    
    # Compile results
    results <- list(
      symbol = symbol,
      model_type = best_model_name,
      model = best_model,
      model_summary = summary(best_model),
      all_models = models,
      model_comparison = model_summaries,
      
      # Predictions
      predictions = predictions_df,
      
      # Trend analysis
      trend = list(
        direction = trend_direction,
        slope = slope,
        strength_percent = round(trend_strength, 3),
        r_squared = model_summaries[[best_model_name]]$r_squared,
        adjusted_r_squared = model_summaries[[best_model_name]]$adj_r_squared
      ),
      
      # Performance metrics
      metrics = list(
        current_price = current_price,
        predicted_30_day = predicted_30_day,
        expected_return_percent = round(expected_return, 2),
        price_volatility_percent = round(price_volatility, 2),
        prediction_uncertainty_percent = round(prediction_uncertainty, 2),
        rmse = model_summaries[[best_model_name]]$rmse,
        aic = model_summaries[[best_model_name]]$aic
      ),
      
      # Data used for modeling
      model_data = model_data,
      analysis_date = Sys.time()
    )
    
    log_info(paste("Linear regression completed for", symbol %||% "dataset", 
                   "using", best_model_name, "model with R² =", 
                   round(results$trend$r_squared, 4)))
    
    return(results)
    
  }, error = function(e) {
    log_error(paste("Error in linear regression analysis:", e$message))
    return(list(error = e$message))
  })
}

#' Generate regression analysis report
#' 
#' @param regression_results Results from perform_linear_regression
#' @return Formatted analysis report
generate_regression_report <- function(regression_results) {
  if (is.null(regression_results)) {
    return("No regression analysis results available.")
  }
  
  results <- regression_results
  
  report_lines <- c(
    paste("# Linear Regression Analysis Report"),
    if (!is.null(results$symbol)) paste("**Stock Symbol:**", results$symbol) else "**Dataset Analysis**",
    paste("**Analysis Date:**", format(results$analysis_date, "%Y-%m-%d %H:%M:%S")),
    paste("**Model Type:**", tools::toTitleCase(gsub("_", " ", results$model_type))),
    "",
    "## Model Performance",
    paste("- **R-squared:**", round(results$trend$r_squared, 4), "(", round(results$trend$r_squared * 100, 2), "% variance explained)" ),
    paste("- **Adjusted R-squared:**", round(results$trend$adjusted_r_squared, 4)),
    paste("- **RMSE:**", paste("$", round(results$metrics$rmse, 2))),
    paste("- **AIC:**", round(results$metrics$aic, 2)),
    "",
    "## Trend Analysis",
    paste("- **Trend Direction:**", results$trend$direction, 
          ifelse(results$trend$direction == "Upward", "📈", 
                 ifelse(results$trend$direction == "Downward", "📉", "➡️"))),
    paste("- **Trend Strength:**", round(results$trend$strength_percent, 3), "% per day"),
    paste("- **Daily Slope:**", paste("$", round(results$trend$slope, 4))),
    "",
    "## Price Predictions (30-day forecast)",
    paste("- **Current Price:**", paste("$", round(results$metrics$current_price, 2))),
    paste("- **Predicted 30-day Price:**", paste("$", round(results$metrics$predicted_30_day, 2))),
    paste("- **Expected Return:**", paste(results$metrics$expected_return_percent, "%")),
    "",
    "## Risk Assessment",
    paste("- **Price Volatility:**", paste(results$metrics$price_volatility_percent, "%")),
    paste("- **Prediction Uncertainty:**", paste(results$metrics$prediction_uncertainty_percent, "%")),
    paste("- **Risk Level:**", 
          if (results$metrics$price_volatility_percent < 2) "Low 🟢" 
          else if (results$metrics$price_volatility_percent < 5) "Medium 🟡" 
          else "High 🔴"),
    "",
    "## Model Comparison",
    "| Model | R² | Adj. R² | RMSE | AIC |",
    "|-------|----|---------|----- |-----|")
  
  # Add model comparison table
  for (model_name in names(results$model_comparison)) {
    stats <- results$model_comparison[[model_name]]
    report_lines <- c(
      report_lines,
      paste("|", tools::toTitleCase(gsub("_", " ", model_name)), 
            "|", round(stats$r_squared, 4),
            "|", round(stats$adj_r_squared, 4),
            "|", round(stats$rmse, 2),
            "|", round(stats$aic, 2), "|")
    )
  }
  
  report_lines <- c(
    report_lines,
    "",
    "## Interpretation",
    if (results$trend$r_squared > 0.7) "✅ **Strong predictive model** - High confidence in trend analysis" 
    else if (results$trend$r_squared > 0.4) "⚠️ **Moderate predictive model** - Reasonable trend indication"
    else "❌ **Weak predictive model** - Low confidence, consider additional factors",
    "",
    if (results$metrics$expected_return_percent > 5) "📈 **Positive outlook** - Model suggests potential upward movement"
    else if (results$metrics$expected_return_percent < -5) "📉 **Negative outlook** - Model suggests potential downward movement"
    else "➡️ **Neutral outlook** - Model suggests stable price movement",
    "",
    "## Recommendations",
    paste("- **Investment Horizon:** Consider", 
          if (results$metrics$price_volatility_percent < 3) "long-term"
          else "short to medium-term", "strategies"),
    paste("- **Risk Management:** Implement",
          if (results$metrics$prediction_uncertainty_percent > 20) "tight stop-losses"
          else "standard risk controls"),
    "- **Monitoring:** Review model performance weekly and retrain with new data",
    "",
    "---",
    "*This analysis is for educational purposes only and should not be considered as investment advice.*",
    paste("*Report generated by Professional Stock Tracker v2.0 on", Sys.Date(), "*")
  )
  
  return(paste(report_lines, collapse = "\n"))
}

#' Calculate support and resistance levels using regression
#' 
#' @param data Stock data
#' @param symbol Stock symbol
#' @return Support and resistance levels
calculate_support_resistance <- function(data, symbol = NULL) {
  tryCatch({
    if (!is.null(symbol)) {
      filtered_data <- data %>% filter(Symbol == symbol)
    } else {
      filtered_data <- data
    }
    
    if (nrow(filtered_data) < 20) {
      return(NULL)
    }
    
    # Calculate pivot points using High, Low, Close
    if (all(c("High", "Low", "Close") %in% names(filtered_data))) {
      recent_data <- filtered_data %>%
        arrange(desc(Date)) %>%
        head(50)  # Last 50 trading days
      
      # Simple support/resistance calculation
      support_level <- quantile(recent_data$Low, 0.1)  # 10th percentile of lows
      resistance_level <- quantile(recent_data$High, 0.9)  # 90th percentile of highs
      
      # Regression-based trend support/resistance
      recent_data$day_index <- 1:nrow(recent_data)
      
      high_model <- lm(High ~ day_index, data = recent_data)
      low_model <- lm(Low ~ day_index, data = recent_data)
      
      # Project trend lines
      future_high <- predict(high_model, newdata = data.frame(day_index = nrow(recent_data) + 5))
      future_low <- predict(low_model, newdata = data.frame(day_index = nrow(recent_data) + 5))
      
      return(list(
        support_static = round(support_level, 2),
        resistance_static = round(resistance_level, 2),
        support_trend = round(future_low, 2),
        resistance_trend = round(future_high, 2),
        current_price = round(tail(filtered_data$Close, 1), 2)
      ))
    }
    
    return(NULL)
  }, error = function(e) {
    log_error(paste("Error calculating support/resistance:", e$message))
    return(NULL)
  })
}

# Null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}