# Load packages ----
library(shiny)
library(quantmod)
library(PerformanceAnalytics)
library(glue)

# User interface ----
ui <- fluidPage(
  titlePanel("Stock Volatility"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Enter a stock ticker to examine."),
      textInput("symb", "Symbol", "SPY"),
      
      dateRangeInput("dates",
                     "Date range",
                     start = "2018-01-01",
                     end = as.character(Sys.Date())),
      
      br(),
      br(),
      
      
      sliderInput("integer", "Window:",
                  min = 0, max = 60,
                  value = 30),
      
      checkboxInput("adjust",
                    "Annualize Volatility", value = FALSE)
      ),
    
    mainPanel(plotOutput("plot"))
    )
)

# Server logic
server <- function(input, output) {
  
  dataInput <- reactive({
    data = getSymbols(input$symb, src = "yahoo",
               from = input$dates[1],
               to = input$dates[2],
               auto.assign = FALSE)
  
    #Logarithmic return - Infinite-periods, compounded, continuous.
    asset_returns_xts <- na.omit(Return.calculate(data[,4], method = "log"))
    
    window = input$integer
    if (!input$adjust) {
      spy_rolling_sd <- na.omit(rollapply(asset_returns_xts,
                                window, function(x) round(StdDev(x) * 100, 2)))
    } else {
      spy_rolling_sd <- na.omit(rollapply(asset_returns_xts,
                                window, function(x) round(StdDev.annualized(x) * 100, 2)))
    }
  })
  

  output$plot <- renderPlot({
    chartSeries(dataInput(), theme = chartTheme("white"),
                type = "line", log.scale = FALSE, TA = NULL,
                name = glue('{input$symb} {input$integer} Day Rolling Volatility (%)'))
  })
  
}

# Run the app
shinyApp(ui, server)
