####################################
### Elizabeth Wicks ################
### Traveling salesman problem #####
####################################

# Suppose we have data from niceride3.mod
# Recall we have x[i,j] = 1 if we make a trip 
# from station i to j, and 0 otherwise.
# Make a new graph with vertices V that are ordered pairs (i,j)
# where i,j are stations with x[i,j]=1.
# The distance from A=(i,j) to B=(k,l) in V 
# (denoted D[A,B]) is the distance calculated by Eric
# from station j to station k.
# Now we have W dock workers. They start at the NRHQ
# and we assume they each need to make a single cycle 
# with the constraint
# that the total time they spend traveling (calculate this from 
# the distance some how - e.g. assume a low travel speed of 10mph
# in order to incorporate breaks, traffic, and the time it takes to load
# and unload bikes) is less than T hours. T is the time period
# used in niceride3.mod. 
# The other constraint is that each vertex in V must be traveled
# through exactly once. 
# We want to minimize the total distance traveled by all workers.


########### Reset ################
reset;
##################################



########### Data #################
# define set of vertices
# each vertex is an ordered pair (i,j) of stations
# we assume that we can travel between any two vertices
# IMPORTANT: V[1] = NRHQ! This is where workers start and stop
# their tour (need to pick up trucks for moving bikes)
# so V \ V[1] = {(i,j):x[i,j]=1, i, j are stations}
set V;

# D[(i,j),(k,l)] = distance from station j to k
param D {V,V} >=0;

# set of total workers available during time T
set W;

# length of time period that workers have to move bikes (e.g. T=4 hours)
param T >=0;

# speed that each driver travels, assume constant for all drivers
param speed >=0;
##################################



########### Variables ############
# x[k,l,w]= binary variable that equals
# 1 if worker w travels from k to l at some point in their tour
# 0 otherwise
var x {V,V,W} binary;

# integer variable that indicates when vertex i is used in worker w's tour
# e.g. a cycle 1 -> 3 -> 2 -> 4 -> 1 by worker w would have
# u[1,w]=1, u[3,w]=2, u[2,w]=3, u[4,w]=4. 
# Last stop of the tour (since it's a cycle)
# isn't encoded in the u variable.
var u {V, W} integer;
##################################



########### Objective ############
# NB: the total distance traveled by all workers will be this distance plus the 
# distance given by the solution to niceride3.mod
minimize distance: sum{i in V, j in V, w in W} D[i,j]*x[i,j,w];
##################################



########### Constraints ##########
# Workers need to complete their tour in T hours
s.t. time_cons {w in W}: sum{i in V, j in V} D[i,j]/speed*x[i,j,w] <= T;

# Don't include vertices
s.t. no_loops {w in W, i in V, j in V: i=j}: x[i,j,w]=0;

# Ensure that all drivers depart from node 1
s.t. dep_node1 {w in W, i in V: i=1}: sum{j in V} x[i,j,w]=1;

# Ensure that all drivers return to node 1
s.t. ret_node1 {w in W, j in V: j=1}: sum{i in V} x[i,j,w]=1;

# Ensure that exactly one driver leaves each node
s.t. leave_nodes {i in V}: sum{j in V, w in W} x[i,j,w]=1;

# Ensure that exactly one driver enters each node
s.t. enter_nodes {j in V}: sum{i in V, w in W} x[i,j,w]=1;

# subtour elimination constraints (Miller-Tucker-Zemlin)
# every tour starts at vertex 1 = NRHQ
s.t. sub_cons1 {w in W, i in V: i = 1}: u[i,w]=1;
# you can't visit more vertices than exist in V
s.t. sub_cons2 {w in W, i in V: i >= 2}: 2 <= u[i,w] <= card(V);
# no subtours allowed
s.t. sub_cons3 {w in W, i in V, j in V: i<>j and i >= 2 and j >= 2}: 
# u[i,w] - u[j,w] + card(V)*x[i,j,w]<=card(V)-1;
u[i,w]+1 <= u[j,w]+(card(V)-1)*(1-x[i,j,w]);
# u[i,w] = 0 if the worker never visits i
s.t. sub_cons4 {w in W, i in V}: u[i,w]<=sum{j in V} x[i,j,w]*card(V);

# Choose the solver	
option solver gurobi;
# option solver cplex;