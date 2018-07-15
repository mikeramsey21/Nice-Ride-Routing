# Problem 6 in HW 1 IMA Bootcamp
# Special case of uncapacitated facility location problem
# Locations are cluster of points
# Stores are other points
# transportation cost is distance between them
# want to minimize distance between points 
# in each cluster and their cluster center

# In general, the best way to do this is to make yij be the fractions
# of demands satisfied by location i to store j
# then your only data are the demands, opening cost, and trans_cost
# This only shows up in the objective function
# and not in the constraints!

# good practice to reset at the start of each model
reset;

# param opening_cost {Locations};

param numpoints >=0;

set Locations := 1 .. numpoints;

set Stores := 1 .. numpoints;

param opening_cost {Locations} :=0;

# demands are 1 since you need to put it in one cluster
param demands {Stores} :=1;

param xCoord {Stores};

param yCoord {Stores};

# defining a matrix where trans_cost_ij = dist from i to j
# the transportation cost
param trans_cost {i in Locations, j in Stores} :=
sqrt((xCoord[i]-xCoord[j])^2+(yCoord[i]-yCoord[j])^2);

# this makes x a binary variable
# x[i] =1 if DC opened, 0 otherwise
var x {Locations} binary;

# says that yij is non-negative
var y {Locations, Stores} >=0;

# removed opening cost
minimize total_cost: sum{l in Locations} opening_cost[l]*x[l]+
sum{l in Locations, s in Stores} demands[s]*trans_cost[l,s]*y[l,s];
# could also multiply previous line by x[l]
# AMPL defines + as higher priority than sum

# the following says that the number of trucks
# sent from location l to store s = y[l,s] is 0 if x[l] is 0
# if x[l] is 1, then y[l,s] <= demands[s], the demands of store s
s.t. y_cons {l in Locations, s in Stores} : y[l,s] <= x[l];

# don't get the negative in Rochester 1 if you use >=
s.t. demand_cons {s in Stores}: sum{l in Locations} y[l,s] = 1;

# number of clusters (or locations, if you want to specify)
s.t. cardinality: sum{l in Locations} x[l]=2;

# Answer: points 6,9 are the cluster centers
# to get which points are in which cluster 
# look at the yij matrix
# Cluster with point 6: 1,2,3,4,5,6,7,10,15,16,18
# all others in the cluster with point 9
# objective is 25.35562445 (total distance from cluster
# centers)

#############################################
# General notes on optimization
# for convex function, any local min is a global min
# some solvers only solve for local min, so be careful
# it's much easier to solve for local min
# concept of local min only applies to continuous optimization problems
# for optimization with discrete variables, no concept of local min!
# only global min.

