# Load packages ----
#install.packages("quantmod")
#install.packages("PerformanceAnalytics")
library(shiny)
library(quantmod)
library(PerformanceAnalytics)


# User interface ----
ui <- fluidPage(
  titlePanel("Stock Volatility"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Select a stock to examine."),
      textInput("symb", "Symbol", "SPY"),
      
      dateRangeInput("dates",
                     "Date range",
                     start = "2013-01-01",
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
    window = input$integer
    if (!input$adjust) {
      spy_rolling_sd <- na.omit(rollapply(data$SPY.Close, window, function(x) StdDev(x)))
    } else {
      spy_rolling_sd <- na.omit(rollapply(data$SPY.Close, window, function(x) StdDev.annualized(x, scale = 12)))
    }
    return(spy_rolling_sd)
  })
  

  output$plot <- renderPlot({
    chartSeries(dataInput(), theme = chartTheme("white"),
                type = "line", log.scale = FALSE, TA = NULL)
  })
  
}

# Run the app
shinyApp(ui, server)
