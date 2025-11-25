# NIFTY 50 Stock Dashboard in R
# Professional Shiny Application with Enhanced Features
# Version 2.0.0

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(shinycssloaders)
library(htmltools)
library(futile.logger)

# Load configuration and utilities
source("config.R")
source("logger.R")
source("validation.R")
source("utils.R")
source("regression.R")  # Load regression analysis module
source("charts.R")
source("news.R")

# Initialize logging
init_logging()
log_startup()

# Load and validate data
start_time <- Sys.time()
log_data_load("Starting data load process")

data_list <- load_data(DATA_CONFIG$nifty_file, DATA_CONFIG$metadata_file)
if (is.null(data_list)) {
  log_error("Failed to load data files")
  stop("Could not load required data files. Please check file paths and format.")
}

df_raw <- data_list$merged_df
metadata <- data_list$metadata

# Validate data quality
validation_result <- validate_stock_data(df_raw)
if (!validation_result$valid) {
  log_error("Data validation failed", paste("Issues:", length(validation_result$issues)))
  # Use raw data but log warnings
  df <- df_raw
} else {
  df <- validation_result$data
}

# Validate metadata
metadata_validation <- validate_metadata(metadata)
if (!metadata_validation$valid) {
  log_error("Metadata validation issues", paste(names(metadata_validation$issues), collapse = ", "))
}

load_duration <- as.numeric(Sys.time() - start_time)
log_performance("Data loading and validation", load_duration, 
               paste("Rows:", nrow(df), "| Symbols:", length(unique(df$Symbol))))

# Define UI
ui <- dashboardPage(
  dashboardHeader(
    title = paste("📈", APP_CONFIG$name, "v", APP_CONFIG$version),
    titleWidth = 350
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Regression Analysis", tabName = "regression", icon = icon("line-chart")),
      menuItem("Data Quality", tabName = "data_quality", icon = icon("check-circle")),
      menuItem("About", tabName = "about", icon = icon("info-circle")),
      hr(),
      h4("🔍 Filter Options", style = "color: white; margin-left: 15px;"),
      
      # Industry Filter
      selectInput(
        inputId = "industry_filter",
        label = "Select Industry:",
        choices = c("All", get_industry_list(df)),
        selected = "All"
      ),
      
      # Stock Search (will be updated based on industry)
      selectInput(
        inputId = "stock_search",
        label = "Search Stock:",
        choices = NULL
      ),
      
      # Date Range
      dateInput(
        inputId = "start_date",
        label = "Start Date:",
        value = min(df$Date, na.rm = TRUE),
        min = min(df$Date, na.rm = TRUE),
        max = max(df$Date, na.rm = TRUE)
      ),
      
      dateInput(
        inputId = "end_date",
        label = "End Date:",
        value = max(df$Date, na.rm = TRUE),
        min = min(df$Date, na.rm = TRUE),
        max = max(df$Date, na.rm = TRUE)
      ),
      
      br(),
      div(
        style = "margin: 15px;",
        p("Built with R Shiny", style = "color: #9ca3af; font-size: 12px;")
      )
    )
  ),
  
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #0e1117;
          color: #fafafa;
        }
        .main-header .navbar {
          background-color: #1f2937 !important;
        }
        .main-header .logo {
          background-color: #1f2937 !important;
        }
        .main-sidebar {
          background-color: #262730 !important;
        }
        .box {
          background-color: #1f2937;
          border: 1px solid #374151;
          color: #fafafa;
        }
        .box-header {
          color: #ffffff;
        }
      "))
    ),
    
    tabItems(
      tabItem(tabName = "dashboard",
        # Stock Title and Industry
        fluidRow(
          column(12,
            h2(textOutput("stock_title"), style = "color: #ffffff;"),
            h4(textOutput("stock_industry"), style = "color: #60a5fa;")
          )
        ),
        
        # Key Metrics Row
        fluidRow(
          valueBoxOutput("closing_price"),
          valueBoxOutput("volume"),
          valueBoxOutput("day_high"),
          valueBoxOutput("day_low")
        ),
        
        # Charts Row
        fluidRow(
          column(8,
            box(
              title = "Price History", 
              status = "primary", 
              solidHeader = TRUE,
              width = NULL,
              height = "450px",
              radioButtons(
                inputId = "chart_type",
                label = "Chart Type:",
                choices = c("Line" = "line", "Candlestick" = "candlestick"),
                selected = "line",
                inline = TRUE
              ),
              withSpinner(plotlyOutput("price_chart", height = "350px"))
            )
          ),
          column(4,
            box(
              title = "Volume Analysis", 
              status = "primary", 
              solidHeader = TRUE,
              width = NULL,
              height = "450px",
              withSpinner(plotlyOutput("volume_chart", height = "380px"))
            )
          )
        ),
        
        # Industry Analysis Row
        fluidRow(
          column(6,
            box(
              title = "Market Share by Industry", 
              status = "info", 
              solidHeader = TRUE,
              width = NULL,
              height = "400px",
              withSpinner(plotlyOutput("industry_pie", height = "350px"))
            )
          ),
          column(6,
            box(
              title = "Average Price by Industry", 
              status = "info", 
              solidHeader = TRUE,
              width = NULL,
              height = "400px",
              withSpinner(plotlyOutput("industry_comparison", height = "350px"))
            )
          )
        ),
        
        # News Section
        fluidRow(
          column(12,
            box(
              title = textOutput("news_title"), 
              status = "warning", 
              solidHeader = TRUE,
              width = NULL,
              withSpinner(uiOutput("news_content"))
            )
          )
        )
      ),
      
      # Regression Analysis Tab
      tabItem(tabName = "regression",
        fluidRow(
          column(12,
            box(
              title = "Linear Regression Analysis",
              status = "primary",
              solidHeader = TRUE,
              width = NULL,
              collapsible = TRUE,
              
              fluidRow(
                column(4,
                  selectInput("regression_symbol", "Select Stock:",
                             choices = NULL,
                             selected = NULL)
                ),
                column(3,
                  numericInput("forecast_days", "Forecast Days:",
                             value = 30, min = 1, max = 90, step = 1)
                ),
                column(3,
                  br(),
                  actionButton("run_regression", "Run Analysis",
                             class = "btn-primary",
                             style = "width: 100%")
                ),
                column(2,
                  br(),
                  checkboxInput("show_trend", "Show Trend", value = TRUE)
                )
              )
            )
          )
        ),
        
        # Regression Results
        fluidRow(
          column(6,
            box(
              title = "Model Summary",
              status = "info",
              solidHeader = TRUE,
              width = NULL,
              height = "400px",
              verbatimTextOutput("regression_summary")
            )
          ),
          column(6,
            box(
              title = "Price Predictions",
              status = "success",
              solidHeader = TRUE,
              width = NULL,
              height = "400px",
              DT::dataTableOutput("predictions_table")
            )
          )
        ),
        
        # Regression Charts
        fluidRow(
          column(12,
            box(
              title = "Price Analysis with Regression",
              status = "primary",
              solidHeader = TRUE,
              width = NULL,
              height = "500px",
              withSpinner(plotlyOutput("regression_chart", height = "450px"))
            )
          )
        ),
        
        # Regression Report
        fluidRow(
          column(12,
            box(
              title = "Analysis Report",
              status = "warning",
              solidHeader = TRUE,
              width = NULL,
              collapsible = TRUE,
              collapsed = TRUE,
              div(
                style = "max-height: 400px; overflow-y: auto;",
                uiOutput("regression_report")
              ),
              br(),
              downloadButton("download_regression_report", "Download Report",
                           class = "btn-success")
            )
          )
        )
      ),
      
      # Data Quality Tab
      tabItem(tabName = "data_quality",
        fluidRow(
          column(12,
            box(
              title = "Data Quality Assessment",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              
              h4("Data Validation Results"),
              htmlOutput("data_quality_summary"),
              
              h4("Missing Data Analysis"),
              plotlyOutput("missing_data_plot", height = "300px"),
              
              h4("Data Distribution"),
              plotlyOutput("data_distribution_plot", height = "400px")
            )
          )
        )
      ),
      
      # About Tab
      tabItem(tabName = "about",
        fluidRow(
          column(12,
            box(
              title = "About NIFTY 50 Stock Dashboard",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              
              h3("Professional Stock Market Analysis Tool"),
              p("This dashboard provides comprehensive analysis of NIFTY 50 stocks with advanced features including:"),
              
              tags$ul(
                tags$li("Real-time stock data visualization"),
                tags$li("Linear regression analysis and price forecasting"),
                tags$li("Interactive charts with technical indicators"),
                tags$li("Data quality assessment and validation"),
                tags$li("Export capabilities for reports and data")
              ),
              
              h4("Features"),
              tags$div(
                style = "margin: 20px 0;",
                tags$h5("📈 Dashboard"),
                p("Interactive overview with key metrics, price trends, and performance indicators."),
                
                tags$h5("📊 Regression Analysis"),
                p("Advanced statistical modeling including multiple regression types, trend analysis, and price predictions."),
                
                tags$h5("🔍 Data Quality"),
                p("Comprehensive data validation, missing data analysis, and distribution assessment."),
                
                tags$h5("💾 Export Options"),
                p("Download charts, reports, and data in multiple formats for further analysis.")
              ),
              
              h4("Technical Information"),
              p("Built with R Shiny, using advanced statistical packages for professional-grade analysis."),
              
              h4("Version"),
              p("Version 2.0.0 - Enhanced with Linear Regression Analysis"),
              
              h4("Developer"),
              p("Joseph Jonathan Fernandes")
            )
          )
        )
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Reactive function to update stock choices based on industry filter
  observe({
    if (input$industry_filter == "All") {
      filtered_df <- df
    } else {
      filtered_df <- df %>% filter(Industry == input$industry_filter)
    }
    
    stock_choices <- get_stock_choices(filtered_df)
    
    updateSelectInput(
      session,
      "stock_search",
      choices = stock_choices,
      selected = stock_choices[1]
    )
  })
  
  # Reactive filtered data
  filtered_data <- reactive({
    req(input$stock_search, input$start_date, input$end_date)
    
    selected_symbol <- strsplit(input$stock_search, " - ")[[1]][1]
    
    filter_data(df, selected_symbol, input$start_date, input$end_date)
  })
  
  # Get current stock symbol
  current_symbol <- reactive({
    req(input$stock_search)
    strsplit(input$stock_search, " - ")[[1]][1]
  })
  
  # Stock title
  output$stock_title <- renderText({
    paste("📈", current_symbol(), "Stock Dashboard")
  })
  
  # Stock industry
  output$stock_industry <- renderText({
    req(current_symbol())
    industry <- df %>% 
      filter(Symbol == current_symbol()) %>% 
      pull(Industry) %>% 
      first()
    paste("Industry:", industry)
  })
  
  # Value boxes for key metrics
  output$closing_price <- renderValueBox({
    data <- filtered_data()
    if (nrow(data) > 0) {
      latest <- tail(data, 1)
      prev <- if(nrow(data) > 1) tail(data, 2)[1,] else latest
      
      change <- latest$Close - prev$Close
      valueBox(
        value = paste("₹", format(latest$Close, nsmall = 2)),
        subtitle = paste("Change:", format(change, nsmall = 2)),
        icon = icon("chart-line"),
        color = if(change >= 0) "green" else "red"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Closing Price",
        icon = icon("chart-line"),
        color = "blue"
      )
    }
  })
  
  output$volume <- renderValueBox({
    data <- filtered_data()
    if (nrow(data) > 0) {
      latest <- tail(data, 1)
      prev <- if(nrow(data) > 1) tail(data, 2)[1,] else latest
      
      change <- latest$Volume - prev$Volume
      valueBox(
        value = format(latest$Volume, big.mark = ","),
        subtitle = paste("Change:", format(change, big.mark = ",")),
        icon = icon("chart-bar"),
        color = "blue"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Volume",
        icon = icon("chart-bar"),
        color = "blue"
      )
    }
  })
  
  output$day_high <- renderValueBox({
    data <- filtered_data()
    if (nrow(data) > 0) {
      latest <- tail(data, 1)
      valueBox(
        value = paste("₹", format(latest$High, nsmall = 2)),
        subtitle = "Day High",
        icon = icon("arrow-up"),
        color = "green"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Day High",
        icon = icon("arrow-up"),
        color = "blue"
      )
    }
  })
  
  output$day_low <- renderValueBox({
    data <- filtered_data()
    if (nrow(data) > 0) {
      latest <- tail(data, 1)
      valueBox(
        value = paste("₹", format(latest$Low, nsmall = 2)),
        subtitle = "Day Low",
        icon = icon("arrow-down"),
        color = "red"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Day Low",
        icon = icon("arrow-down"),
        color = "blue"
      )
    }
  })
  
  # Price chart
  output$price_chart <- renderPlotly({
    data <- filtered_data()
    symbol <- current_symbol()
    
    if (nrow(data) > 0) {
      if (input$chart_type == "line") {
        plot_stock_price(data, symbol)
      } else {
        plot_candlestick(data, symbol)
      }
    } else {
      plot_ly() %>% 
        add_annotations(
          text = "No data available for selected period",
          xref = "paper", yref = "paper",
          x = 0.5, y = 0.5, showarrow = FALSE
        )
    }
  })
  
  # Volume chart
  output$volume_chart <- renderPlotly({
    data <- filtered_data()
    symbol <- current_symbol()
    
    if (nrow(data) > 0) {
      plot_volume(data, symbol)
    } else {
      plot_ly() %>% 
        add_annotations(
          text = "No data available",
          xref = "paper", yref = "paper",
          x = 0.5, y = 0.5, showarrow = FALSE
        )
    }
  })
  
  # Industry pie chart
  output$industry_pie <- renderPlotly({
    plot_industry_pie(df)
  })
  
  # Industry comparison chart
  output$industry_comparison <- renderPlotly({
    plot_industry_comparison(df)
  })
  
  # News title
  output$news_title <- renderText({
    paste("📰 Latest News for", current_symbol())
  })
  
  # News content
  output$news_content <- renderUI({
    symbol <- current_symbol()
    news_items <- fetch_news(symbol)
    
    if (length(news_items) > 0) {
      news_cards <- lapply(news_items, function(item) {
        div(
          class = "news-card",
          style = "background-color: #1f2937; padding: 15px; border-radius: 10px; margin-bottom: 10px; border: 1px solid #374151;",
          h4(
            a(href = item$link, target = "_blank", item$title, style = "color: #60a5fa; text-decoration: none;"),
            style = "margin-top: 0; color: #60a5fa;"
          ),
          p(paste(item$source, "•", item$date), style = "font-size: 0.8em; color: #9ca3af; margin: 5px 0;"),
          p(item$snippet, style = "color: #fafafa; margin: 0;")
        )
      })
      do.call(tagList, news_cards)
    } else {
      div(
        style = "padding: 20px; text-align: center;",
        p("No news found.", style = "color: #9ca3af;")
      )
    }
  # Update regression stock choices
  observe({
    if (input$industry_filter == "All") {
      filtered_df <- df
    } else {
      filtered_df <- df %>% filter(Industry == input$industry_filter)
    }
    
    stock_choices <- get_stock_choices(filtered_df)
    updateSelectInput(
      session,
      "regression_symbol",
      choices = stock_choices,
      selected = stock_choices[1]
    )
  })
  
  # Regression Analysis
  regression_results <- eventReactive(input$run_regression, {
    req(input$regression_symbol, input$forecast_days)
    
    withProgress(message = "Running regression analysis...", value = 0, {
      incProgress(0.3, detail = "Analyzing historical data...")
      
      tryCatch({
        selected_symbol <- strsplit(input$regression_symbol, " - ")[[1]][1]
        stock_data <- df %>% filter(Symbol == selected_symbol)
        
        if (nrow(stock_data) == 0) {
          return(list(error = "No data found for selected symbol"))
        }
        
        results <- perform_linear_regression(
          data = stock_data,
          symbol = selected_symbol,
          days_ahead = input$forecast_days
        )
        
        incProgress(0.7, detail = "Generating predictions...")
        
        if (!is.null(results)) {
          log_info(paste("Regression analysis completed for", selected_symbol))
        }
        
        incProgress(1, detail = "Complete!")
        return(results)
        
      }, error = function(e) {
        log_error(paste("Regression analysis failed:", e$message))
        return(list(error = paste("Analysis failed:", e$message)))
      })
    })
  })
  
  # Regression model summary
  output$regression_summary <- renderText({
    results <- regression_results()
    if (is.null(results)) {
      return("No regression analysis results. Click 'Run Analysis' to start.")
    }
    
    # Check for errors
    if (!is.null(results$error)) {
      return(paste("Error:", results$error))
    }
    
    # Format model summary
    paste(
      paste("Model Type:", tools::toTitleCase(gsub("_", " ", results$model_type))),
      paste("R-squared:", round(results$trend$r_squared, 4)),
      paste("Adjusted R-squared:", round(results$trend$adjusted_r_squared, 4)),
      paste("RMSE: ₹", round(results$metrics$rmse, 2)),
      paste("AIC:", round(results$metrics$aic, 2)),
      "",
      paste("Trend Direction:", results$trend$direction),
      paste("Daily Slope: ₹", round(results$trend$slope, 4)),
      paste("Trend Strength:", round(results$trend$strength_percent, 3), "% per day"),
      "",
      paste("Current Price: ₹", round(results$metrics$current_price, 2)),
      paste("30-day Forecast: ₹", round(results$metrics$predicted_30_day, 2)),
      paste("Expected Return:", results$metrics$expected_return_percent, "%"),
      "",
      paste("Price Volatility:", results$metrics$price_volatility_percent, "%"),
      paste("Prediction Uncertainty:", results$metrics$prediction_uncertainty_percent, "%"),
      sep = "\n"
    )
  })
  
  # Predictions table (use numeric datatable and format currency for readability)
  output$predictions_table <- DT::renderDataTable({
    results <- regression_results()
    if (is.null(results) || is.null(results$predictions)) {
      return(DT::datatable(data.frame(Message = "No predictions available"), options = list(dom = 't'), rownames = FALSE))
    }

    predictions <- as.data.frame(results$predictions)
    if (nrow(predictions) == 0) {
      return(DT::datatable(data.frame(Message = "No predictions available"), options = list(dom = 't'), rownames = FALSE))
    }

    predictions <- predictions %>%
      mutate(
        Date = as.Date(Date),
        Confidence_Range = upper_bound - lower_bound
      ) %>%
      select(Date, predicted_price, lower_bound, upper_bound, Confidence_Range) %>%
      head(15)

    dt <- DT::datatable(
      predictions,
      rownames = FALSE,
      class = 'predictions-table',
      options = list(
        pageLength = 10,
        scrollY = "300px",
        scrollCollapse = TRUE,
        searching = FALSE,
        ordering = TRUE,
        dom = 't'
      ),
      colnames = c("Date", "Predicted Price", "Lower Bound", "Upper Bound", "Confidence Range")
    ) %>%
      DT::formatCurrency(c("predicted_price", "lower_bound", "upper_bound", "Confidence_Range"), currency = "₹", interval = 3, mark = ",", digits = 2)

    dt
  })
  
  # Regression chart
  output$regression_chart <- renderPlotly({
    results <- regression_results()
    if (is.null(results)) {
      return(plot_ly() %>% 
        add_annotations(
          text = "Run regression analysis to see chart",
          xref = "paper", yref = "paper",
          x = 0.5, y = 0.5, showarrow = FALSE,
          font = list(color = "white")
        ) %>%
        layout(
          plot_bgcolor = '#1f2937',
          paper_bgcolor = '#1f2937'
        ))
    }
    
    # Create enhanced chart with regression
    selected_symbol <- strsplit(input$regression_symbol, " - ")[[1]][1]
    stock_data <- df %>% filter(Symbol == selected_symbol)
    
    plot_stock_price_with_regression(stock_data, selected_symbol, results, input$show_trend)
  })
  
  # Regression analysis report
  output$regression_report <- renderUI({
    results <- regression_results()
    if (is.null(results)) {
      return(tags$p("No regression analysis results available.", style = "color: white;"))
    }
    
    report_text <- generate_regression_report(results)
    
    # Convert markdown to HTML (basic conversion)
    report_html <- gsub("\n", "<br>", report_text)
    report_html <- gsub("# (.*?)<br>", "<h3 style='color: #3498db; margin-top: 20px;'>\\1</h3>", report_html)
    report_html <- gsub("## (.*?)<br>", "<h4 style='color: #f39c12; margin-top: 15px;'>\\1</h4>", report_html)
    report_html <- gsub("\\*\\*(.*?)\\*\\*", "<strong>\\1</strong>", report_html)
    report_html <- gsub("- (.*?)<br>", "<li style='margin-bottom: 5px;'>\\1</li>", report_html)
    
    HTML(paste("<div style='color: white; line-height: 1.6;'>", report_html, "</div>"))
  })
  
  # Download regression report
  output$download_regression_report <- downloadHandler(
    filename = function() {
      selected_symbol <- strsplit(input$regression_symbol, " - ")[[1]][1]
      paste("regression_report_", selected_symbol, "_", Sys.Date(), ".md", sep = "")
    },
    content = function(file) {
      results <- regression_results()
      if (!is.null(results)) {
        report_text <- generate_regression_report(results)
        writeLines(report_text, file)
      }
    },
    contentType = "text/markdown"
  )
  
  # Data Quality Outputs
  output$data_quality_summary <- renderUI({
    validation_result <- validate_stock_data(df_raw)
    report_html <- generate_quality_report(validation_result)
    HTML(report_html)
  })
  
  output$missing_data_plot <- renderPlotly({
    missing_data <- df_raw %>%
      summarise_all(~sum(is.na(.))) %>%
      tidyr::pivot_longer(everything(), names_to = "Column", values_to = "Missing_Count") %>%
      mutate(Percentage = round((Missing_Count / nrow(df_raw)) * 100, 2)) %>%
      filter(Missing_Count > 0)
    
    if (nrow(missing_data) == 0) {
      p <- plot_ly() %>%
        add_annotations(
          text = "No missing data found!",
          xref = "paper", yref = "paper",
          x = 0.5, y = 0.5, showarrow = FALSE,
          font = list(color = "green", size = 16)
        )
    } else {
      p <- plot_ly(
        data = missing_data,
        x = ~Column,
        y = ~Percentage,
        type = "bar",
        marker = list(color = "red"),
        text = ~paste("Missing:", Missing_Count),
        textposition = "outside"
      ) %>%
        layout(
          title = "Missing Data by Column",
          xaxis = list(title = "Columns"),
          yaxis = list(title = "Missing Data (%)")
        )
    }
    
    p
  })
  
  output$data_distribution_plot <- renderPlotly({
    # Price distribution for selected stocks
    sample_data <- df_raw %>%
      filter(Symbol %in% c("RELIANCE", "TCS", "INFY", "HDFCBANK", "ICICIBANK")) %>%
      select(Symbol, Close)
    
    p <- plot_ly(
      data = sample_data,
      x = ~Close,
      color = ~Symbol,
      type = "histogram",
      alpha = 0.7
    ) %>%
      layout(
        title = "Price Distribution for Major Stocks",
        xaxis = list(title = "Closing Price (₹)"),
        yaxis = list(title = "Frequency"),
        barmode = "overlay"
      )
    
    p
  })
  
  })
}

# Run the application
shinyApp(ui = ui, server = server)