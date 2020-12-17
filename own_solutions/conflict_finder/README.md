## Our Solutions

The conflict finder takes two (or more) plans as input and outputs conflict predicates.
These predicates show where an conflict has occured and which type of conflict it is.
Currently we distinguish 2 types of conflicts (marked by 0 and 1 respectively).

Type 0
These are so called "present" conflicts, where a robot wants to move onto a node, that another robot is already occupying.
This will lead to a conflict if the robot currently occupying the node is not moving.
The reason for that being that there can only be one robot on a node at a time.

Type 1
These are so called "future" conflicts, where two robots want to move onto the same node. 
This will lead to an conflict as there can only be one robot on a node at a time. 

Known Problems:
We are aware that in their current implementations this program takes a lot of time to run.
This will be changed in future releases.
