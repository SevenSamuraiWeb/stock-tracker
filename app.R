# NIFTY 50 Stock Dashboard in R
# Main Shiny Application

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(shinycssloaders)
library(htmltools)

# Source utility functions
source("utils.R")
source("charts.R")
source("news.R")

# Load data
data_list <- load_data("NIFTY50_all.csv", "stock_metadata.csv")
df <- data_list$merged_df
metadata <- data_list$metadata

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "📈 NIFTY 50 Dashboard"),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
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
  })
}

# Run the application
shinyApp(ui = ui, server = server)