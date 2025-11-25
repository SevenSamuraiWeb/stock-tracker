# Data Cache Module
# Implements intelligent caching for improved performance

library(digest)

# Create cache environment
.cache <- new.env()
.cache$data <- new.env()
.cache$metadata <- new.env()
.cache$hits <- 0
.cache$misses <- 0

#' Generate cache key from parameters
#' 
#' @param ... Parameters to include in key generation
#' @return MD5 hash as cache key
generate_cache_key <- function(...) {
  params <- list(...)
  digest(params, algo = "md5")
}

#' Store data in cache
#' 
#' @param key Cache key
#' @param data Data to cache
#' @param ttl Time to live in seconds (default: 1 hour)
store_cache <- function(key, data, ttl = 3600) {
  timestamp <- Sys.time()
  
  .cache$data[[key]] <- data
  .cache$metadata[[key]] <- list(
    timestamp = timestamp,
    ttl = ttl,
    expires = timestamp + ttl,
    size = object.size(data)
  )
  
  # Clean expired entries periodically
  if (length(.cache$data) %% 50 == 0) {
    clean_expired_cache()
  }
}

#' Retrieve data from cache
#' 
#' @param key Cache key
#' @return Cached data or NULL if not found/expired
get_cache <- function(key) {
  if (!exists(key, envir = .cache$data)) {
    .cache$misses <- .cache$misses + 1
    return(NULL)
  }
  
  metadata <- .cache$metadata[[key]]
  
  # Check if expired
  if (Sys.time() > metadata$expires) {
    remove(key, envir = .cache$data)
    remove(key, envir = .cache$metadata)
    .cache$misses <- .cache$misses + 1
    return(NULL)
  }
  
  .cache$hits <- .cache$hits + 1
  return(.cache$data[[key]])
}

#' Cached data loader
#' 
#' @param cache_key Unique identifier for cache
#' @param load_function Function to execute if cache miss
#' @param ttl Cache time to live in seconds
#' @return Data from cache or freshly loaded
cached_data_load <- function(cache_key, load_function, ttl = 3600) {
  # Try to get from cache first
  cached_result <- get_cache(cache_key)
  
  if (!is.null(cached_result)) {
    log_info(paste("Cache hit for key:", cache_key))
    return(cached_result)
  }
  
  # Cache miss - load data
  log_info(paste("Cache miss for key:", cache_key, "- loading fresh data"))
  
  result <- tryCatch({
    load_function()
  }, error = function(e) {
    log_error(paste("Error loading data for cache key", cache_key, ":", e$message))
    NULL
  })
  
  # Store in cache if successful
  if (!is.null(result)) {
    store_cache(cache_key, result, ttl)
  }
  
  return(result)
}

#' Clean expired cache entries
clean_expired_cache <- function() {
  current_time <- Sys.time()
  expired_keys <- c()
  
  for (key in ls(.cache$metadata)) {
    metadata <- .cache$metadata[[key]]
    if (current_time > metadata$expires) {
      expired_keys <- c(expired_keys, key)
    }
  }
  
  # Remove expired entries
  for (key in expired_keys) {
    if (exists(key, envir = .cache$data)) {
      remove(key, envir = .cache$data)
    }
    if (exists(key, envir = .cache$metadata)) {
      remove(key, envir = .cache$metadata)
    }
  }
  
  if (length(expired_keys) > 0) {
    log_info(paste("Cleaned", length(expired_keys), "expired cache entries"))
  }
}

#' Get cache statistics
#' 
#' @return List with cache performance stats
get_cache_stats <- function() {
  total_requests <- .cache$hits + .cache$misses
  hit_rate <- if (total_requests > 0) .cache$hits / total_requests else 0
  
  # Calculate total cache size
  total_size <- 0
  cache_entries <- length(ls(.cache$data))
  
  for (key in ls(.cache$metadata)) {
    if (!is.null(.cache$metadata[[key]]$size)) {
      total_size <- total_size + as.numeric(.cache$metadata[[key]]$size)
    }
  }
  
  list(
    entries = cache_entries,
    hits = .cache$hits,
    misses = .cache$misses,
    hit_rate = round(hit_rate * 100, 2),
    total_size_mb = round(total_size / 1024 / 1024, 2)
  )
}

#' Clear all cache
clear_cache <- function() {
  rm(list = ls(.cache$data), envir = .cache$data)
  rm(list = ls(.cache$metadata), envir = .cache$metadata)
  .cache$hits <- 0
  .cache$misses <- 0
  log_info("Cache cleared")
}

#' Preload common data into cache
preload_cache <- function() {
  log_info("Preloading cache with common data...")
  
  # Preload stock data with common filters
  tryCatch({
    # Load full dataset
    full_data_key <- generate_cache_key("stock_data", "all")
    cached_data_load(full_data_key, function() {
      log_info("Preloading full stock dataset")
      load_data()
    }, ttl = 7200)  # 2 hours for full dataset
    
    # Preload popular stocks
    popular_stocks <- c("AAPL", "GOOGL", "MSFT", "AMZN", "TSLA")
    
    for (stock in popular_stocks) {
      stock_key <- generate_cache_key("filtered_data", stock)
      cached_data_load(stock_key, function() {
        log_info(paste("Preloading data for", stock))
        data <- load_data()
        if (!is.null(data)) {
          filter_data(data, stock_symbol = stock)
        }
      }, ttl = 1800)  # 30 minutes for individual stocks
    }
    
    log_info("Cache preload completed successfully")
  }, error = function(e) {
    log_error(paste("Error during cache preload:", e$message))
  })
}