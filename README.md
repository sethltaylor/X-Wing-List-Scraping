# X-Wing Miniatures Game List Scraping

## Background
Star Wars: X-wing Miniatues Games (X-wing TMG or X-wing) is a tactical miniatures game where players control small squads of starfighters from throughout the Star Wars universe. Each pilot/ship combiniation and upgrade card in X-wing is assigned a point value, denoting its value or threat within a squad. In competitive formats, squads are capped at 200 points. 

Each pilot has a set intiative value from 1 to 6, which determines when they move and shoot. Players set ship manuevers in secret and reveal and execute those maneunevers in initaitive order (1 first, 6 last). Becasue manuevers are set in secret and executed in initiative order, players with higher intiative ships have more information to inform decision making. In the event of intiative ties, ties are resolved in favor of the player with the higher "bid", which is equal to 200 - the number of points in their squad. For example, if a player's squad is 196 points they would have a 4 point bid. 

## Purpose
The tradeoff between maximizing the point value of your squad (and therefore its power) and maximzing your bid (and therefore gaining more information in matchups where there are initiative ties) is a critcial component of competitive squad building. 

To assist players in better understanding how their opponents are valuing this tradeoff I've used the https://listfortress.com/ API to scrape X-Wing Miniatures Game 2.0 tournament data, and have deployed a R Shiny app examining x-wing squad points distribution here:

https://sethltaylor.shinyapps.io/X-Wing-Points-Scraping/

## Progress

Update (10/4/21): A recent game design change has eliminated bidding from squad building, so I am ending development of this tool. 

Future features include:
- ~~Filtering by format (Extended, Hyperspace, Custom)~~ (Complete)
- Filtering by ~~country~~ and state (and maybe store) (Completed for country)
- Toggling between data from all lists and lists that have made the top 32 and top 8 in tournaments
- ~~Selecting tournaments with greater than X amount of players~~ (Complete)
- ~~Bids by pilot initiative~~ (Complete)


