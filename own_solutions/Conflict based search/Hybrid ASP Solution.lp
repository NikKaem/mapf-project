Main Idea:
use predicate
constraint(Robot, Vertex, Timestep).



Take paths from Robots
Check for Collision

If Collision, add constraint for one of the robots
1{constraint(Robot1,Vertex,Timestep),constraint(Robot2,Vertex,Timestep)}1 :- collision

Find new paths, however we first adapt to orignal plan from 0 to Conflict_Timestep - #ChangeTime
Where #ChangeTime is an constant that tells us how many steps before and after the conflict may be changed.

We could also use an iterative search with an constant maximum.
Start with #ChangeTime=1 till the Maximum and output the path with the shortest length.
