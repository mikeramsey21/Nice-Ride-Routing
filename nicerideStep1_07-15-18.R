##########################
## Elizabeth Wicks #######
## 07-15-18 ##############
##########################

# This is work done for the average Monday morning (5am to 10am) 
# that can be generalized to any time period.

######## Step 1 ##########
##########################
# It assumes that we measure the number of bikes at each station at some 
# predetermined time (e.g. 4am) and then predict how many bikes will 
# be left at the station at 10am. We flag a station if it is predicted
# to go under 20% capacity (source) or over 80% capacity (sink).
# Then we create a csv file with this data.
# (NB: in this particular scenario we assume the initial number of bikes is
# 50% of station capacity (didn't have enough time to get real data). 
# But if we have real data, you can put that into the data set.)

########## Step 2 #########
###########################
# Feed this data into the AMPL clustering problem 
# (with parameter number of workers)
# it will create a cluster (based on distance) for each worker

######### Step 3 ##########
###########################
# Then for each cluster, run the single traveling salesman problem
# To get a delivery schedule for that salesman.
# Comments: this should not increase the cost too much
# originally had 2 salesmen, might need 3-4 now
# At 10am, repeat the process for 10am-2pm
# at 2pm, repeat the process for 2pm-8pm etc

stationFluxAvgHour <- read.csv("C:/Users/Elizabeth/repos/IMA Bootcamp Project 1/Nice-Ride-Routing/stationFluxAvgHour17.csv")

sFAH <- stationFluxAvgHour %>%
  filter(5<=stationFluxAvgHour$hour & stationFluxAvgHour$hour<=10 & stationFluxAvgHour$weekday=="Mon")

sFAH <- sFAH %>%
  subset(select=c("Stationnumber","Name","Rideoutminusin"))

require(data.table)
sFAH <- data.table(sFAH)
sFAH <- sFAH[,list(Rideoutminusin=sum(Rideoutminusin)), 
             by = "Stationnumber,Name"]

write.csv(sFAH, file="sFAHmondaymorning.csv")

# need to combine with # of docks data
docksdata <- read.csv("C:/Users/Elizabeth/repos/IMA Bootcamp Project 1/Nice-Ride-Routing/Flux_and_InOut_17.csv")

# only get total dock information
docksdata <- docksdata %>%
  subset(select=c(Stationnumber,Total.docks))


# remove duplicates
require(data.table)
docksdata <- data.table(docksdata)
docksdata <- docksdata[,list(Total.docks=mean(Total.docks)),
                       by = "Stationnumber"]

# write docksdata to csv
write.csv(docksdata, "docksdata.csv")

# join docksdata to the other data
alldata <- left_join(docksdata,sFAH)

# add initial data
alldata <- alldata %>%
  mutate(Initialbikes=floor(0.5*Total.docks))

# give predicted number of bikes at the station at the end of time period
alldata <- alldata %>%
  mutate(Predbikes = Initialbikes-Rideoutminusin)

# only lists sinks = where the predicted number of bikes in the station
# at the end of the time period is greater than 80% of the station docks
sinks <- alldata %>%
  filter(alldata$Predbikes >= alldata$Total.docks*(.8))
# there are 13 of these

# write to csv file
write.csv(sinks, file="sinksMonMorning.csv")

# only lists sources = where the predicted number of bikes in the station at
# the end of the time period is less than 20% of the station docks
sources <- alldata %>%
  filter(alldata$Predbikes <= alldata$Total.docks*(.2))
# there are 39 of these

# write to csv file
write.csv(sources, file="sourcesMonMorning.csv")

# combine sources and sinks
problemStations <- rbind(sources,sinks)

# write to csv file
write.csv(problemStations, file="probStationsMonMorning.csv")