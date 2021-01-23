library(shiny)
library(dplyr)

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
      
      hist(p$points, breaks = sqrt(nrow(participants)), main = title)})
  
  output$stats <- renderTable({
    p <- participants %>% 
      filter(date >= input$daterange[1] & date <= input$daterange[2])
    as.array(summary(p$points))
    })
      
}

shinyApp(ui = ui, server = server)

