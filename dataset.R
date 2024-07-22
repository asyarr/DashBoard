############################
######## LIBRIRIES ########
###########################

library(dplyr)
library(tidyr)
library(rvest)
library(quantmod)
library(httr)
library(tibble)

############################
#####  kaggle Dataset #####
###########################

## Read csv file:
df1 <- read.csv("netflix_titles.csv", header = T, sep = ",", encoding = "UTF-8")

## Fix duration and cast columns 

ds_netflix_titles_1 <- df1 %>%
  separate(duration, into = c("duration_num","duration_type"), sep = " ")
  
### Deleting rows with problems:
ds_netflix_titles<- ds_netflix_titles_1[-c(5542, 5795, 5814), ]
  
## Separating actors
ds_netflix_titles <- ds_netflix_titles %>%
  separate_rows(cast, sep=", ")

## Export file ##
write.csv2(ds_netflix_titles,"ds_netflix_titles.csv", sep = ";")

############################
##### Wiki html Table #####
###########################

## URL Wiki
oscars_url <- "https://en.wikipedia.org/wiki/List_of_Academy_Award%E2%80%93winning_films"

## Getting Oscars Table

# Fist attempt - gives error
#ds_oscars <- read_html(oscars_url) %>%
 # htmtl_nodes("table") %>%
  #html_table()

## Using X-path
ds_oscars <- read_html(oscars_url) %>%
  html_node(xpath = '//*[@id="mw-content-text"]/div[1]/table') %>%
  html_table() %>%
  select(title = Film, Awards)

write.csv2(ds_oscars, "ds_oscars.csv")

############################
#########  IMDB  ##########
###########################

# URL
imdb_url <- "https://www.imdb.com/chart/top/"



# Function to ajust the User-Agent
custom_headers <- add_headers(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Accept-Language" = "en"
)

page <- imdb_url %>% 
  GET(custom_headers) %>% 
  content()

# getting the titles of the films in english

ds_movie_titles <- page %>% 
  html_nodes("a .ipc-title__text") %>% 
  html_text()

ds_movie_titles

# getting the IMDB rating

ds_imdb_rating <- read_html(imdb_url) %>%
  html_nodes(".ipc-rating-star--rating") %>%
  html_text()
  
# creating imdb table

ds_imdb <- as.tibble(cbind(title= ds_movie_titles, rating = ds_imdb_rating))

write.csv2(ds_imdb, "ds_imdb.csv")

  
  
############################
## Yahoo Finance Stocks  ##
###########################

# getting the stock history

getSymbols("NFLX", src = "yahoo")

# fix row names and select the columns

ds_stocks <- as.data.frame(NFLX) %>%
  rownames_to_column(var = "date") %>%
  select(date, price = NFLX.Close, volume = NFLX.Volume)

write.csv2(ds_stocks, "ds_stock.csv")
