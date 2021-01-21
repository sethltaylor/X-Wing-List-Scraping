library(httr)
library(jsonlite)
library(httr)
library(dplyr)
library(purrr)
library(tidyr)
library(tibble)
library(lubridate)

#Scraping list of tournaments
tournaments <- GET("http://listfortress.com/api/v1/tournaments/")
tournaments <- fromJSON(rawToChar(tournaments$content))
tournaments

#Generating list of tournament urls
urls <- paste0("http://listfortress.com/api/v1/tournaments/", tournaments$id)

#Scraping urls
data <- lapply(urls, GET)

#Pulling out content item from list of scraped urls
data <- map(data, 6)
#Converting content from JSON
data <- lapply(data, function(x) fromJSON(rawToChar(x)))

#Grabbing participants dataframe from each URL (12th item in list of lists) and binding it 
participants <-do.call("rbind", lapply(data, "[[", 12))

#Cleaning JSON for parsing
participants$list_json <- trimws(participants$list_json)
#Remove NAs
participants <- participants[!is.na(participants$list_json),]
participants <- participants[!(participants$list_json == ""),]
#Removing one record with invalid json
participants <- participants[!(participants$id == 3301),]

#Trying to parse lists json
participants$lists <- map(participants$list_json, fromJSON)

#Grabbing factions
participants$factions <- lapply(participants$lists, "[[", 'faction')
#Grabbing points values 
participants$points <- lapply(lists, "[[", 'points')

#Dropping list columns
participants <- select(participants, 1:9, 13,14)

#Merge back in tournament location and date

participants <- merge(participants, tournaments[,c('id', 'state', 'country', 'date', 'format_id')], by.x = 'tournament_id', by.y = 'id', all.x = T)

#Convering dates
participants$date <- as.Date(participants$date, "%Y-%m-%d")

