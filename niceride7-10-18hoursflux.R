###################################
## Elizabeth Wicks ################
###################################

# Import necessary packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggmap)
library(readr) 
library(data.table) # need for Elizabeth's code

# Messing around 

# read stationFluxHoursdata.csv file
stationFluxHours <- read.csv("stationFluxHoursdata.csv")

# removes random X column that got created when reading file
stationFluxHours$X <- NULL

# WHY WONT IT GROUP THINGS
# stationFluxHours <- as.data.frame(stationFluxHours)
#stationFluxHours <- stationFluxHours %>%
#  group_by(Stationnumber) 

# create new station flux analysis
stationFluxAvgWeekday <- stationFluxHours %>%
  subset(select = c("Stationnumber","weekday","Rideoutminusin"))

require(data.table)
stationFluxAvgWeekday <- data.table(stationFluxAvgWeekday)
stationFluxAvgWeekday <- stationFluxAvgWeekday[,list(Rideoutminusin=mean(Rideoutminusin)), 
                                     by = "Stationnumber,weekday"]

# writes stationFluxAvgWeekday to CSV
write.csv(stationFluxAvgWeekday, file = "stationFluxAvgWeekdaydata.csv")

