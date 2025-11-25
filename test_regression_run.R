# Quick test for regression function
source('config.R')
source('logger.R')
source('validation.R')
source('utils.R')
source('regression.R')
source('charts.R')

# load data
data_list <- load_data(DATA_CONFIG$nifty_file, DATA_CONFIG$metadata_file)
if (is.null(data_list)) stop('Failed to load data')

df_raw <- data_list$merged_df

# pick a symbol
sym <- df_raw$Symbol[1]
cat('Testing symbol:', sym, '\n')

res <- tryCatch({
  perform_linear_regression(df_raw, symbol = sym, days_ahead = 10)
}, error = function(e) { cat('ERROR:', e$message, '\n'); NULL })

if (is.null(res)) {
  cat('Regression returned NULL\n')
} else {
  cat('Model type:', res$model_type, '\n')
  cat('Predictions rows:', nrow(res$predictions), '\n')
  print(head(res$predictions))
}
