library(shiny)
library(dplyr)

startdate <- as.character(min(participants$date, na.rm = T))
enddate <- as.character(max(participants$date, na.rm = T))

ui <- fluidPage(
   dateRangeInput("daterange1", label = "Tournament Date Range:", start = startdate, end = enddate, min = startdate, max = enddate),
               
  plotOutput("hist"),
  tableOutput("stats")
  )

server <- function(input, output) {
  output$hist <- renderPlot({
    participants %>% filter(date >= input$daterange1[1] & date <= input$daterange1[2])
    title <- "Distribution of List Points"
    hist(participants$points, breaks = sqrt(nrow(participants)), main = title)})
  
  dt_f <- reactive({
    participants %>% 
      filter(date >= input$daterange1[1] & date <= input$daterange1[2]) %>%
      summarise(min = min(x), mean = mean(x), median = median(x), max = max(x))
    
  })
  output$stats <- renderTable(dt_f)
}

shinyApp(ui = ui, server = server)

