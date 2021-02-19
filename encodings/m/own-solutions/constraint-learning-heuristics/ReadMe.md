This merger is based on a idea presented in the CBS Algorithm of https://www.sciencedirect.com/science/article/pii/S0004370214001386

We take the path till the first conflict. 
We then randomly generate new moves.
Every time we find a conflict we resolve it by giving on of the robots a "permit".
Only the robot with the permit may enter a conflict square. Everyone else has to adapt.

In this approach we also added heuristics for better performance.
(Forward Search for Position and Prioritizing finding a permit)

-> works fine most of the time, queues make problems (Benchmark 6, maybe more)