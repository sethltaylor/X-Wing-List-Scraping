library(shiny)
library(plyr)
library(dplyr)

participants <- readRDS("Participants.rds")

startdate <- as.character(min(participants$date, na.rm = T))
enddate <- as.character(max(participants$date, na.rm = T))
countrylist <- as.list(unique(participants$country))

ui <- fluidPage(
   dateRangeInput("daterange", label = "Tournament Date Range:", start = startdate, end = enddate, min = startdate, max = enddate),
   selectInput("country", label = "Country", choices = countrylist),
   selectInput('format', label = "Format", choices = levels(participants$format_id)),
   sliderInput("slider", "Initiative Range in List",
               min = 0, max = 6, value = c(0, 6)),
   sliderInput("slider2", "Minimum Number of Players at Tournament", min = 1, max = max(participants$n), value = 1),
 
  plotOutput("hist"),
  tableOutput("stats")
  )

server <- function(input, output) {
 
  output$hist <- renderPlot({
    title <- "Distribution of List Points"
    p <-participants %>% 
      filter(date >= input$daterange[1] & date <= input$daterange[2] & country %in% input$country & Min >= input$slider[1] & Max <= input$slider[2] 
             & format_id %in% input$format & n >= input$slider2)
      hist(p$points, main = title, breaks = 50, xlab = "Points")
      })
  
  output$stats <- renderTable({
    p <-participants %>% 
      filter(date >= input$daterange[1] & date <= input$daterange[2] & country %in% input$country & Min >= input$slider[1] & Max <= input$slider[2] 
             & format_id %in% input$format & n >= input$slider2)
      ddply(p, "factions" , summarise , Max = max(points, na.rm = T), Min = min(points, na.rm = T), Mean = mean(points, na.rm = T), Median = median(points, na.rm = T), '75th Percentile' = quantile(points,0.75,na.rm = T),'25th Percentile' = quantile(points,0.25,na.rm = T))
    })
      
}

shinyApp(ui = ui, server = server)

