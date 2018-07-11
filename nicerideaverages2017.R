###################################
## Elizabeth Wicks ################
## 07-10-18 #######################
###################################

# Import necessary packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggmap)
library(readr) 
library(data.table) # need for Elizabeth's code

# read stationFluxHoursdata.csv file
stationFluxHours <- read.csv("C:/Users/Elizabeth/repos/IMA Bootcamp Project 1/Nice-Ride-Routing/HourlyFlux_and_InOut_17.csv")

# removes redundant X column
stationFluxHours$X <- NULL

# remove holidays from data analysis
holidays = c("2016-5-8","2016-5-30" ,"2016-6-19",
              "2016-7-4" ,"2016-9-5" ,"2016-10-10",
              "2016-11-11","2016-11-24" ,"2016-11-25")
stationFluxHours <- stationFluxHours %>% 
  filter(!date %in% holidays) 


#################################################
### avg flux per weekday per station ############
#################################################


# create new station flux analysis 
stationFluxAvgWeekday <- stationFluxHours %>%
  subset(select = c("Stationnumber","Name","weekday","RidesOut","RidesIn","Rideoutminusin"))

require(data.table)
stationFluxAvgWeekday <- data.table(stationFluxAvgWeekday)
stationFluxAvgWeekday <- stationFluxAvgWeekday[,list(RidesOut=mean(RidesOut),
                                                     RidesIn=mean(RidesIn),
                                                     Rideoutminusin=mean(Rideoutminusin)), 
                                               by = "Stationnumber,Name,weekday"]

# orders the data set by station number
stationFluxAvgWeekday <- stationFluxAvgWeekday[order(stationFluxAvgWeekday$Stationnumber),]

# writes stationFluxAvgWeekday to CSV
write.csv(stationFluxAvgWeekday, file = "stationFluxAvgWeekday17.csv")


#################################################
### avg flux per hour per weekday per station ###
### in 2017 - no sampling #######################
#################################################


stationFluxAvgHour <- stationFluxHours %>%
  subset(select = c("Stationnumber","Name","weekday","hour","RidesOut","RidesIn","Rideoutminusin"))

require(data.table)
stationFluxAvgHour <- data.table(stationFluxAvgHour)
stationFluxAvgHour <- stationFluxAvgHour[,list(RidesOut=mean(RidesOut),
                                               RidesIn=mean(RidesIn),
                                        Rideoutminusin=mean(Rideoutminusin)), 
                                        by = "Stationnumber,Name,weekday,hour"]

# orders the data set by station number, weekday, hour
stationFluxAvgHour <- stationFluxAvgHour[order(stationFluxAvgHour$Stationnumber,
                                               stationFluxAvgHour$weekday,
                                               stationFluxAvgHour$hour),]

write.csv(stationFluxAvgHour, file = "stationFluxAvgHour17.csv")


###########################################
### TO DO: break up into ##################
### mornings, lunchtime, evenings, etc ####
###########################################

# break up the day into blocks - can experiment with placement and size
# 0:00 to 5:00
# 5:00 to 10:00 (morning rush hour)
# 10:00 to 14:00 (lunch hour)
# 14:00 to 19:00 (evening rush hour)
# 19:00 to 0:00

# TO DO: need to figure out how to group by hour
#stationFluxAvgHourBlocks <- stationFluxHours %>%
#  subset(select = c("Stationnumber","Name","weekday","hour","RidesOut","RidesIn","Rideoutminusin"))

#require(data.table)
#stationFluxAvgHour <- data.table(stationFluxAvgHour)
#stationFluxAvgHour <- stationFluxAvgHour[,list(RidesOut=mean(RidesOut),
#                                               RidesIn=mean(RidesIn),
#                                               Rideoutminusin=mean(Rideoutminusin)), 
#                                         by = "Stationnumber,Name,weekday,hour"]

# orders the data set by station number, weekday, hour
#stationFluxAvgHour <- stationFluxAvgHour[order(stationFluxAvgHour$Stationnumber,
#                                               stationFluxAvgHour$weekday,
#                                               stationFluxAvgHour$hour),]

#write.csv(stationFluxAvgHour, file = "stationFluxAvgHour17.csv")


