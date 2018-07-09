# Elizabeth Wicks
# IMA Bootcamp Project 1
# Analyzing Nice Ride 2016 data set
# Locations2016 is the file with locations data
# Rides2016 is the file with rides data

### WARNING: THIS IS A HOT MESS ###
### READ AT YOUR OWN PERIL ###

library(ggplot2)    
library(dplyr)  
library(infer)
library(broom)
library(mosaic)
library(lubridate)
library(ggmap)

Rides2016 <- read.csv("C:/Users/Elizabeth/Documents/Nice_ride_data_2016_season/Nice_ride_trip_history_2016_season.csv")
Locations2016 <- read.csv("C:/Users/Elizabeth/repos/IMA Bootcamp Project 1/Nice-Ride-Routing/Nice_Ride_2016_Station_Locations.csv")

head(Rides2016,6)
head(Locations2016)

head(MergedRides,6)

MN <- get_map("Minneapolis", zoom=13)
ggmap(MN) + 
  geom_segment(data=MergedRides, aes(x=start_long, y=start_lat,
                                     xend=end_long, yend=end_lat), alpha=0.07)

# This pulls date information
mydate <- as.factor(c("10/26/2016 13:20"))
as.factor(hour(mdy_hm(mydate)))
as.factor(month(mdy_hm(mydate)))
as.factor(minute(mdy_hm(mydate)))
as.factor(day(mdy_hm(mydate)))
as.factor(wday(mdy_hm(mydate), label = TRUE))

head(Rides2016)          

Locations2016$X = NULL          
head(Locations2016)

#join the Stations and Rides    
MergedRides <- Rides2016 %>%
  left_join(Locations2016, by=c(Start.station = "Station")) %>%
  rename(start_lat=Latitude, start_long=Longitude) %>%
  left_join(Locations2016, by=c(End.station = "Station")) %>%
  rename(end_lat=Latitude, end_long=Longitude)


# adding time data: hour minute day month
MergedRides <- MergedRides %>% 
  mutate(Start.month=month(mdy_hm(Start.date)), Start.day=day(mdy_hm(Start.date)), 
  Start.hour=hour(mdy_hm(Start.date)), Start.min = minute(mdy_hm(Start.date)))

MergedRides <- MergedRides %>% 
  mutate(End.month=month(mdy_hm(End.date)), End.day=day(mdy_hm(End.date)), 
         End.hour=hour(mdy_hm(End.date)), End.min = minute(mdy_hm(End.date)))

# adding day of week data
MergedRides <- MergedRides %>% mutate(Start.wday=wday(mdy_hm(Start.date),label=TRUE))
MergedRides <- MergedRides %>% mutate(End.wday=wday(mdy_hm(End.date),label=TRUE))

head(MergedRides)


