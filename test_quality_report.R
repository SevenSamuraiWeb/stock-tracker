source('config.R')
source('validation.R')
source('utils.R')

data_list <- load_data(DATA_CONFIG$nifty_file, DATA_CONFIG$metadata_file)
if (is.null(data_list)) stop('Failed to load data')

df_raw <- data_list$merged_df
vr <- validate_stock_data(df_raw)
cat('Validation valid:', vr$valid, '\n')
cat('Issues:\n')
print(vr$issues)
cat('\nGenerated HTML report:\n')
cat(generate_quality_report(vr))
