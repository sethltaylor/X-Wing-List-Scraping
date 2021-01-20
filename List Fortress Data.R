library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(tidyr)
library(tibble)
library(stringr)

#Scraping list of tournaments
tournaments <- GET("http://listfortress.com/api/v1/tournaments/")
tournaments <- fromJSON(rawToChar(tournaments$content))
tournaments

#Generating list of tournament urls
urls <- paste0("http://listfortress.com/api/v1/tournaments/", tournaments$id)

#Scraping urls
data <- lapply(urls, GET)

#Pulling out content item from list of scraped urls
test <- map(data, 6)
#Converting content from JSON
test <- lapply(test, function(x) fromJSON(rawToChar(x)))

#Grabbing participants dataframe from each URL (12th item in list of lists) and binding it 
participants <-do.call("rbind", lapply(test, "[[", 12))

#Merge location information back into participants list



#Old testing code for one tournament 
#nznat <- GET("http://listfortress.com/api/v1/tournaments/261")
#nznat <- fromJSON(rawToChar(nznat$content))
#data <- nznat$participants

#data$points <- str_match(data$list_json, "(?<=\\points\\\":d+")

#nznat_raw <- content(nznat)
#data_raw <- enframe(unlist(nznat_raw))

