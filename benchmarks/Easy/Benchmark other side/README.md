## Example: Other Side

#Idea behind this

This benchmark can be used to test both the assignment of tasks and the merging of plans.
It has two test cases that make it possible to find significant errors.
The first test would be for the assignment of shelves to robots. 
With an "perfect" assignment it is possible that no conflicts arise, however if there are some sub-optimal assignment conflicts will arise.

This inefficient assignment is used to test the plan merger (and can be found in the directory "plans for each robot".)
Every Conflict should have enough space, so that solutions may be found without needing to check for many feasibility constraints.

All in all this benchmark should be a good indicator for the general state of the plan merger and task assigner respectively. 

#General Information
Grid Size: 5 x 5
Number of Robots: 3

#Additional Information
Minimal Time Horizon with "perfect" assignment: 4

Minimal Time Horizon with given assignments for each individual robot: 8




