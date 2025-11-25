# News Functions for Stock Dashboard
# R equivalent of news.py

library(httr)
library(jsonlite)

# SerpAPI Key (Note: In production, this should be stored as an environment variable)
SERPAPI_KEY <- "83a797dd6b54afb51050fbe8a91b922c9de4c514e744e5b700dc0eb33465b3b4"

#' Fetch news using SerpAPI
#' 
#' @param query Stock symbol or company name to search for
#' @param max_results Maximum number of news items to return (default: 5)
#' @return List of news items
fetch_news <- function(query, max_results = 5) {
  tryCatch({
    # Construct API request
    params <- list(
      engine = "google_news",
      q = paste(query, "stock news"),
      gl = "in",
      hl = "en",
      api_key = SERPAPI_KEY
    )
    
    # Make API request
    response <- GET("https://serpapi.com/search", query = params)
    
    # Check if request was successful
    if (status_code(response) == 200) {
      results <- content(response, "parsed")
      
      news_items <- list()
      
      if ("news_results" %in% names(results) && length(results$news_results) > 0) {
        # Extract top news items
        for (i in 1:min(max_results, length(results$news_results))) {
          item <- results$news_results[[i]]
          news_items[[i]] <- list(
            title = ifelse(is.null(item$title), "No title", item$title),
            link = ifelse(is.null(item$link), "#", item$link),
            source = ifelse(is.null(item$source), "Unknown source", item$source),
            date = ifelse(is.null(item$date), "Unknown date", item$date),
            snippet = ifelse(is.null(item$snippet), "No description available", item$snippet),
            thumbnail = ifelse(is.null(item$thumbnail), "https://via.placeholder.com/100", item$thumbnail)
          )
        }
      }
      
      return(news_items)
    } else {
      warning(paste("API request failed with status:", status_code(response)))
      return(get_mock_news(query))
    }
  }, error = function(e) {
    warning(paste("Failed to fetch news:", e$message))
    return(get_mock_news(query))
  })
}

#' Get mock news data for demonstration
#' 
#' @param stock_name Stock symbol or name
#' @return List of mock news items
get_mock_news <- function(stock_name) {
  mock_news <- list(
    list(
      title = paste(stock_name, "reports strong Q3 earnings"),
      link = "#",
      source = "Financial Times",
      date = "2 hours ago",
      snippet = paste(stock_name, "has exceeded market expectations with a 15% rise in net profit..."),
      thumbnail = "https://via.placeholder.com/100"
    ),
    list(
      title = paste("Market analysis: Is", stock_name, "a buy right now?"),
      link = "#",
      source = "Bloomberg",
      date = "5 hours ago",
      snippet = "Analysts are divided on the short-term outlook, but long-term fundamentals remain strong...",
      thumbnail = "https://via.placeholder.com/100"
    ),
    list(
      title = paste(stock_name, "announces new strategic partnership"),
      link = "#",
      source = "Reuters",
      date = "1 day ago",
      snippet = "The company has entered into a joint venture to expand its footprint in the renewable energy sector...",
      thumbnail = "https://via.placeholder.com/100"
    ),
    list(
      title = paste("Institutional investors increase stake in", stock_name),
      link = "#",
      source = "Economic Times",
      date = "2 days ago",
      snippet = "Foreign institutional investors have shown increased confidence by raising their holdings...",
      thumbnail = "https://via.placeholder.com/100"
    ),
    list(
      title = paste(stock_name, "stock hits 52-week high on positive sentiment"),
      link = "#",
      source = "CNBC",
      date = "3 days ago",
      snippet = "The stock reached new heights following the company's latest quarterly results and forward guidance...",
      thumbnail = "https://via.placeholder.com/100"
    )
  )
  
  return(mock_news)
}

#' Fetch financial news headlines for multiple stocks
#' 
#' @param symbols Vector of stock symbols
#' @param max_per_stock Maximum news items per stock (default: 3)
#' @return Named list where each element is a list of news for a stock
fetch_multi_stock_news <- function(symbols, max_per_stock = 3) {
  news_data <- list()
  
  for (symbol in symbols) {
    news_data[[symbol]] <- fetch_news(symbol, max_per_stock)
    # Add a small delay to respect API rate limits
    Sys.sleep(0.5)
  }
  
  return(news_data)
}

#' Get market sentiment based on news headlines
#' 
#' @param news_items List of news items
#' @return List with sentiment score and description
analyze_news_sentiment <- function(news_items) {
  if (length(news_items) == 0) {
    return(list(
      score = 0,
      description = "No news available",
      color = "gray"
    ))
  }
  
  # Simple keyword-based sentiment analysis
  positive_keywords <- c("strong", "rise", "gain", "profit", "growth", "increase", 
                        "positive", "up", "high", "beat", "exceed", "partnership", 
                        "expansion", "confidence", "buy", "bullish")
  
  negative_keywords <- c("fall", "drop", "loss", "decline", "decrease", "negative", 
                        "down", "low", "miss", "weak", "concern", "sell", "bearish", 
                        "risk", "challenge")
  
  positive_count <- 0
  negative_count <- 0
  total_words <- 0
  
  for (item in news_items) {
    # Combine title and snippet for analysis
    text <- tolower(paste(item$title, item$snippet))
    words <- unlist(strsplit(text, "\\s+"))
    total_words <- total_words + length(words)
    
    positive_count <- positive_count + sum(words %in% positive_keywords)
    negative_count <- negative_count + sum(words %in% negative_keywords)
  }
  
  # Calculate sentiment score (-1 to 1)
  if (positive_count + negative_count == 0) {
    score <- 0
  } else {
    score <- (positive_count - negative_count) / (positive_count + negative_count)
  }
  
  # Determine sentiment description and color
  if (score > 0.2) {
    description <- "Positive"
    color <- "green"
  } else if (score < -0.2) {
    description <- "Negative"
    color <- "red"
  } else {
    description <- "Neutral"
    color <- "blue"
  }
  
  return(list(
    score = round(score, 3),
    description = description,
    color = color,
    positive_mentions = positive_count,
    negative_mentions = negative_count
  ))
}

#' Format news date to relative time
#' 
#' @param date_string Date string from news API
#' @return Formatted relative time string
format_news_date <- function(date_string) {
  # This is a simple implementation - in a real app, you might want more sophisticated date parsing
  if (is.null(date_string) || date_string == "" || date_string == "Unknown date") {
    return("Unknown date")
  }
  
  # Return as-is for now, but could implement relative time formatting
  return(date_string)
}

#' Create news summary for dashboard
#' 
#' @param symbol Stock symbol
#' @param max_items Maximum number of news items to include
#' @return List with news summary data
create_news_summary <- function(symbol, max_items = 5) {
  news_items <- fetch_news(symbol, max_items)
  sentiment <- analyze_news_sentiment(news_items)
  
  return(list(
    symbol = symbol,
    news_count = length(news_items),
    news_items = news_items,
    sentiment = sentiment,
    last_updated = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  ))
}