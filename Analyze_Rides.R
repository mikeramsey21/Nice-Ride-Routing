# Import necessary packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggmap)

# Import dataset
rides <- read.csv("Nice_ride_trip_history_2016_season.csv", na.strings=c(""))
locations <- read.csv("Nice_Ride_2016_Station_Locations.csv")
locations$X <- NULL

# Fix NRHQ Problem
locations$Terminal <- as.character(locations$Terminal)
locations[144,1] <- "NRHQ"
locations$Terminal <- as.factor(locations$Terminal)

# Join Stations and rides data sets   
data <- rides %>%
  left_join(locations, by=c(Start.station.number = "Terminal")) %>%
  rename(start_lat=Latitude, start_long=Longitude) %>%
  left_join(locations, by=c(End.station.number = "Terminal")) %>%
  rename(end_lat=Latitude, end_long=Longitude)

# Create new columns
data <- data %>%
  mutate(Startingdate = date(mdy_hm(Start.date)), 
         Startinghour = hour(mdy_hm(Start.date)),
         Startingminute = minute(mdy_hm(Start.date)),
         Startingweekday = wday(mdy_hm(Start.date)),
         Endingdate = date(mdy_hm(End.date)), 
         Endinghour = hour(mdy_hm(End.date)),
         Endingminute = minute(mdy_hm(End.date)),
         Endingweekday = wday(mdy_hm(Start.date)))
data$Start.date <- NULL
data$End.date <- NULL

# Delete duration time of less than 60 seconds
data <- data %>%
  filter(data$Total.duration..seconds. > 60)