#################################################
## Elizabeth Wicks ##############################
## Bike travel solution ignoring dock workers ###
#################################################



###### Assumptions ###############
# Fix a weekday w (e.g. Monday) ##
# During that day, we deliver bikes from 0:00 hours
# to 23:00 hours (would need to alter this assumption)
# code hours as 0,1,2, ... , 23
# We assume we can complete a transfer of bikes
# from station i to station j within 1 hour
# We ignore the fact that we need dock workers to transport bikes
# We move bikes hourly
# We run through this in one day
##################################



########### Reset ################
reset;
##################################



########### Data #################
# define set of vertices
# each vertex represents a nice ride station
# we assume that we can travel between any two vertices
set V;

# H is the set of hours in a day
# 24 in this case starting at 0:00 ending at 23:00
# can adapt this to only do certain deliveries
set H;

# D[i,j] = distance from station i to j
param D {V,V} >=0;

# I[i] = initial number of bikes at station i at hour 0:00
# this could be a variable rather than data?
# idea: make a dynamic delivery schedule. take the data of # of bikes
# at station i at hour 0:00 and run the AMPL code to get the driver's 
# schedule for the day
param I {V}>=0;

# RIO[i,h] = estimated number of rides in minus number of rides out 
# at hour h at station i (our estimate is the average for 2017)
# at the fixed weekday w!!!
# taken directly from the stationFluxAvgHour17.csv file
# on the website
# NOTE: I did "rides out minus in" in the csv file. 
# so might need to put in negative signs at some point
param RIO {V,H};

# n[i] = number of docks at station i
param n {V}>=0;

# total number of bikes available
param B >=0;
##################################



########### Variables ############
# x[i,j,h]= binary variable that equals
# 1 if bikes were moved from station i to j at hour h
# 0 otherwise
var x {V,V,H} binary;

# y[i,j,h] = number of bikes moved from station i to j at hour h
var y {V,V,H} >=0;

# N[i,h] = number of bikes at station i at time h
var N {V,H};
##################################



########### Objective ############
minimize distance: sum{i in V, j in V, h in H} D[i,j]*x[i,j,h];
##################################



########### Constraints ##########
# we don't move bikes at hour 0:00
s.t. nomove {i in V, j in V, h in H: h = 0}: y[i,j,h]=0;

# the number of bikes at station i is the sum of the initial number of bikes
# plus the rides in minus rides out
# plus the bikes delivered in minus the bikes delivered out
# for some reason this line is not working!!!
s.t. num_bikes {i in V, h in H}:  
	N[i,h]=I[i]+sum{j in V, l in H: l<=h} y[j,i,l]-y[i,j,l]+RIO[i,l];

# how x depends on y
# this forces y >=1 if x = 1, y>=0 if x=0
s.t. num_moves {i in V, j in V, h in H}: x[i,j,h]<=y[i,j,h];
# this forces y = 0 if x=0, also can't move more bikes than are present at the station
s.t. num_moves2 {i in V, j in V, h in H}: y[i,j,h]<=x[i,j,h]*N[i,h];


# we want a min of 20% of docks filled at all times
# we want a max of 80% of docks filled at all times
# could change these parameters and set them as data
s.t. fill_cons {i in V, h in H}: .2*n[i] <= N[i,h] <= .8*n[i];
##################################
