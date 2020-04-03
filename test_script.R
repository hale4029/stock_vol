# Load packages ----
#install.packages("quantmod")
#install.packages("PerformanceAnalytics")

library(quantmod)
library(PerformanceAnalytics)

dataInput <- ({ getSymbols("SPY", src = "yahoo",
                 from = '2013-01-01',
                 to = '2017-06-27',
                 auto.assign = FALSE)
})

finalInput <- ({
  window <- 30
  spy_rolling_sd <- na.omit(rollapply(dataInput, window, function(x) StdDev(x)))
})

if (TRUE) {
  spy_rolling_sd <- na.omit(rollapply(dataInput, window, function(x) StdDev(x)))
} else {
  spy_rolling_sd <- na.omit(rollapply(dataInput, window, function(x) StdDev.annualized(x, scale = 252)))
}

finalInput <- ({
  window <- 30
  spy_rolling_sd <- na.omit(rollapply(dataInput, window, function(x) StdDev.annualized(x, scale = 252)))
})
  
output$plot <- renderPlot({
  chartSeries(finalInput(), theme = chartTheme("white"), type = "line", log.scale = input$log, TA = NULL)
})

