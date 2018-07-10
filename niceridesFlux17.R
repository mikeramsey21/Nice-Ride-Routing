# Import necessary packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggmap)

#Mike's import code:
# Import dataset
rides <- read.csv("Nice_ride_trip_history_2017_season.csv")
locations <- read.csv("Nice_Ride_2017_Station_Locations.csv")
locations$X <- NULL

rides <- rides %>%
  filter(Start.station.number != "")
names(locations)
levels(rides$Start.station.number)

# Fix NRHQ Problem
#locations$Terminal <- as.character(locations$Terminal)
#locations[144,1] <- "NRHQ"
#locations$Terminal <- as.factor(locations$Terminal)
#levels(locations$Terminal)
#levels(rides$Start.station.number)
# Join Stations and rides data sets   
data <- rides %>%
  left_join(locations, by=c(Start.station.number = "Number")) %>%
  rename(start_lat=Latitude, start_long=Longitude) %>%
  left_join(locations, by=c(End.station.number = "Number")) %>%
  rename(end_lat=Latitude, end_long=Longitude)

names(data)
# Create new columns
data <- data %>%
  mutate(Startingdate = date(mdy_hm(Start.date)), 
         Startinghour = hour(mdy_hm(Start.date)),
         Startingminute = minute(mdy_hm(Start.date)),
         Startingweekday = wday(mdy_hm(Start.date),label = TRUE),
         Endingdate = date(mdy_hm(End.date)), 
         Endinghour = hour(mdy_hm(End.date)),
         Endingminute = minute(mdy_hm(End.date)),
         Endingweekday = wday(mdy_hm(Start.date), label = TRUE))
data$Start.date <- NULL
data$End.date <- NULL
names(data)
# Delete duration time of less than 60 seconds
data <- data %>%
  filter(data$Total.duration..Seconds. > 60)


############################################
### Elizabeth's code for creating a ########
### new data set with only information #####
### we care about ##########################
############################################

names(data)
# creates subset of data only collecting data on rides out
stationFluxOut <- subset(data, 
                         select = c("Start.station.number","Total.docks.x",
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
                        select = c("End.station.number","Total.docks.y",
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

# add a new column Rideoutminusin
# NB: may not need this column for all applications
stationFlux <- stationFlux %>%
  mutate(Rideoutminusin=Rideout-Ridein)

# now we can just manipulate the stationFlux data frame to find out whatever
# information we need. Since R interprets booleans as 0,1 we can add and subtract
# Rideout, Ridein to get flux for whatever period of time we are considering.


#############################################
### Example: flux&rides in/out by the hour###
#############################################






#Make a table with the rides in, out, and flux per hour per station
stationDemandHours <- stationFlux
require(data.table)
stationDemandHours <- data.table(stationDemandHours)
stationDemandHours <- stationDemandHours[,list(RidesOut =sum(Rideout), RidesIn = sum(Ridein), Rideoutminusin=sum(Rideoutminusin)),by=list(Stationnumber, date, weekday, hour)]

stationDemandHours <- stationDemandHours %>%
  left_join(locations, by=c(Stationnumber = "Number"))

#################################
### numbers by the day #########
#################################
#Do the same thing, but per day
stationDemandDays <- stationFlux
require(data.table)
stationDemandDays <- data.table(stationDemandDays)
stationDemandDays <- stationDemandDays[,list(RidesOut =sum(Rideout), RidesIn = sum(Ridein), Rideoutminusin=sum(Rideoutminusin)),by=list(Stationnumber, date, weekday)]

stationDemandDays <- stationDemandDays %>%
  left_join(locations, by=c(Stationnumber = "Number"))

###################################
#####  Problem stations? ##########
###################################

#identify stations which lose or gain a lot of bikes per day
#feel free to play with numbers here to see what happens (I tried .75 which was interesting)
problemStationsdaily <- stationDemandDays %>%
  filter(Rideoutminusin > 0.5*Total.docks | -1*Rideoutminusin > 0.5*Total.docks) 

problemStationsdailycounts <- problemStationsdaily %>%
  group_by(Name) %>%
  summarise(count = n())

####################################
######### Static Stations? #########
####################################x

#identify stations that don't get a lot of use by counting how many times a station uses a small portion of its bikes
#these stations could be candidates for moving bikes around
#could also change numbers depending on what we want
stationsHighDemanddaily <- stationDemandDays%>%
  filter(RidesOut > 0.25*Total.docks | RidesIn > 0.25*Total.docks) 

stationHighDemanddailycounts <- stationsHighDemanddaily %>%
  group_by(Name) %>%
  summarise(count = n())

stationHighDemanddailycounts <- stationHighDemanddailycounts %>%
  left_join(locations, by=c(Name = "Name")) %>%
  select( c("Name", "count", "Total.docks"))

lowdemandStations <- stationHighDemanddailycounts %>%
  filter(count < 30)


#do the same thing but hourly
#i.e. identify stations which lose or gain a lot of bikes per hour
problemStations <- stationDemandHours %>%
  filter(Rideoutminusin > 0.5*Total.docks | -1*Rideoutminusin > 0.5*Total.docks) 

problemStationscounts <- problemStations %>%
  group_by(Name) %>%
  summarise(count = n())

#identify stations that don't get much use on an hourly basis by counting how many times a small number of its bikes get used
#I haven't compared this to daily rates yet but could be interesting?
stationsHighDemand <- stationDemandHours %>%
  filter(RidesOut > 0.25*Total.docks | RidesIn > 0.25*Total.docks) 

stationHighDemandcounts <- stationsHighDemand %>%
  group_by(Name) %>%
  summarise(count = n())

# this is some code which Elizabeth found online that turns stationFluxHours into 
# a data table instead of a data frame. Then, it groups it by the listed parameters
# and replaces Rideoutminusin with the sum for all of the rows that have the same
# Stationnumber, date, weekday, and hour


# first remove extra columns from stationFlux
# this might be a required step in order to make the next block of code function,
# but I am not sure
#It seems to work ok without it! On the other hand, the data.table lines are key and it doesn't work without them
stationFluxHours <- subset(stationFlux, 
                           select = -c(Numdocks,Latitude,Longitude,Ridein,Rideout,minute))

require(data.table)
stationFluxHours <- data.table(stationFluxHours)
stationFluxHours <- stationFluxHours[,list(Rideoutminusin=sum(Rideoutminusin)), 
                                     by = "Stationnumber,date,weekday,hour"]


# the output is a data table with columns: 
# Stationnumber,date,weekday,hour,Rideoutminusin


