library(httr)
library(jsonlite)
library(httr)
library(plyr)
library(dplyr)
library(purrr)
library(tidyr)
library(googlesheets4)

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
participants$points <- lapply(participants$lists, "[[", 'points')

#Extracting ship info from pilots dataframe in lists. 

#Extracting ship and id for all pilot dataframes that have ship and id 
lst1 <- lapply(participants$lists, function(x) {
  x1 <- x$pilots
  if(all(c("id", "ship") %in% names(x1))) {
    x1[c("id", "ship")]
  }
})
#Create index between participants dataframe and list of ship info where length in list of ship info isn't zero
i1 <- sapply(lst1, NROW) > 0
#Binding participant id to list of ship info based on index
lst1[i1] <- Map(cbind, p_id = participants$id[i1], lst1[i1])
#Binding ship info into dataframe
shipinfo <- do.call(rbind, lst1)

#Reading in sheets with pilot initiatives from googlesheets
initiative <- read_sheet("https://docs.google.com/spreadsheets/d/1b-IL-_sSAH2hKrmKgrO9hqDtFSjA1xwnJha-SGVff5c/edit#gid=675279571")


#Merge intiative list back to ship info
shipinfo <- merge(shipinfo, initiative, all.x = T)
#Create max, min, median initiative for each list ID
list_inits <- shipinfo %>% 
  group_by(p_id) %>% 
  summarise(Min = min(initiative), Max = max(initiative), Median = median(initiative))

#Merge initiative summary to participants list
participants <- merge(participants, list_inits, by.x = 'id', by.y = 'p_id', all.x = T)

#Dropping list columns
participants <- select(participants, -10, -11,-12)

#Convert factions and points to appropriate form
participants$factions <- as.character(participants$factions)
participants$points <- as.numeric(as.character(participants$points))

#Merge back in tournament location and date

participants <- merge(participants, tournaments[,c('id', 'state', 'country', 'date', 'format_id')], by.x = 'tournament_id', by.y = 'id', all.x = T)

#Convering dates
participants$date <- as.Date(participants$date, "%Y-%m-%d")
#fix date
participants$date[participants$date == '0021-02-15'] <- "2021-02-15"

#Convert format id 1 = extended, 2 = 2nd edition, 3 = custom, 4 = other, 34 = hyperspace
participants$format_id <- as.factor(participants$format_id)
participants$format_id <- mapvalues(participants$format_id, c(1, 2, 3, 4, 34), c('Extended', '2nd Edition', 'Custom', 'Other', 'Hyperspace'))

#Convert factions to factor and fix levels
participants$factions <- as.factor(participants$factions)
participants$factions <- mapvalues(participants$factions, c("firstorder", "galacticempire", 'galacticrepublic', 'rebelalliance', 'resistance', 'scumandvillainy','separatistalliance'),
                                                          c("First Order", "Empire", "Republic", "Rebels", "Resistance", "Scum", "CIS"))

#Convert state and country to factor

#Create count of participants at each tournament
tournamentparticipants  <- participants %>% group_by(tournament_id) %>% count(tournament_id)
participants <- merge(participants, tournamentparticipants, all.x = T)
#Tag data prior to last points update
participants$current <- ifelse(participants$date >= "2020-11-24", TRUE, FALSE)

#Remove points greater than 200 and less than 100 
participants <- participants[which(participants$points <= 200 & participants$points >=100),]

saveRDS(participants, "Participants.rds")
