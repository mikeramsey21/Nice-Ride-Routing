##################################
### Mike's code ##################
##################################

# Import necessary packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggmap)

# Import dataset
rides <- read.csv("C:/Users/Elizabeth/Documents/Nice_ride_data_2016_season/Nice_ride_trip_history_2016_season.csv", na.strings=c(""))
locations <- read.csv("C:/Users/Elizabeth/repos/IMA Bootcamp Project 1/Nice-Ride-Routing/Nice_Ride_2016_Station_Locations.csv")
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
         Startingweekday = wday(mdy_hm(Start.date),label = T),
         Endingdate = date(mdy_hm(End.date)), 
         Endinghour = hour(mdy_hm(End.date)),
         Endingminute = minute(mdy_hm(End.date)),
         Endingweekday = wday(mdy_hm(Start.date), label = T))
data$Start.date <- NULL
data$End.date <- NULL

# Delete duration time of less than 60 seconds
data <- data %>%
  filter(data$Total.duration..seconds. > 60)


############################################
### Elizabeth's code for creating a ########
### new data set with only information #####
### we care about ##########################
############################################

# creates subset of data only collecting data on rides out
stationFluxOut <- subset(data, 
                select = c("Start.station.number","Nb.Docks.x",
                          "start_lat","start_long","Startingdate",
                          "Startingweekday","Startinghour","Startingminute"))

# adds columns which take boolean values 
# indicating that this piece of data is a ride out
stationFluxOut <- stationFluxOut %>%
  mutate(Rideout=TRUE,Ridein=FALSE)

# changes station number, docks, lat, and long variable names 
# (in prep for merge with rides in data frame)
names(stationFluxOut) <- c("Stationnumber","Numdocks",
                           "Latitude","Longitude","date",
                           "weekday","hour","minute", "Rideout","Ridein")

# creates subset of data only collecting data on rides in
stationFluxIn <- subset(data, 
                select = c("End.station.number","Nb.Docks.y",
                        "end_lat","end_long","Endingdate",
                        "Endingweekday","Endinghour","Endingminute"))

# adds columns which take boolean values 
# indicating that this piece of data is a ride in
stationFluxIn <- stationFluxIn %>%
  mutate(Rideout=FALSE,Ridein=TRUE)

# changes station number, docks, lat, and long variable names (in prep for merge)
names(stationFluxIn) <- c("Stationnumber","Numdocks",
                           "Latitude","Longitude","date",
                           "weekday","hour","minute", "Rideout","Ridein")

# now we combine both data frames vertically into one big data frame
stationFlux <- rbind(stationFluxOut,stationFluxIn)

# now we can just manipulate the stationFlux data frame to find out whatever
# information we need. Since R interprets booleans as 0,1 we can add and subtract
# Rideout, Ridein to get flux for whatever period of time we are considering.
 
