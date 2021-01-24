library(shiny)
library(plyr)
library(dplyr)

participants <- readRDS("Participants.rds")

startdate <- as.character(min(participants$date, na.rm = T))
enddate <- as.character(max(participants$date, na.rm = T))


ui <- fluidPage(
   dateRangeInput("daterange", label = "Tournament Date Range:", start = startdate, end = enddate, min = startdate, max = enddate),
               
  plotOutput("hist"),
  tableOutput("stats")
  )

server <- function(input, output) {
  output$hist <- renderPlot({
    title <- "Distribution of List Points"
    p <- participants %>% 
      filter(date >= input$daterange[1] & date <= input$daterange[2])
    outlier_cutoff = quantile(p$points,0.75) - 5 * IQR(p$points)
    index_outlier_ROT = which(p$points<outlier_cutoff)
      hist(p$points[-index_outlier_ROT], main = title, xlab = "Points")
      })
  
  output$stats <- renderTable({
    p<- participants %>% 
      filter(date >= input$daterange[1] & date <= input$daterange[2])
      ddply(p, "factions" , summarise , Max = max(points, na.rm = T), Min = min(points, na.rm = T), Mean = mean(points, na.rm = T), Median = median(points, na.rm = T), '75th Percentile' = quantile(points,0.75,na.rm = T),'25th Percentile' = quantile(points,0.25,na.rm = T))
    })
      
}

shinyApp(ui = ui, server = server)

