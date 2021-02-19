This merger is based on a idea presented in the CBS Algorithm of https://www.sciencedirect.com/science/article/pii/S0004370214001386


In this approach we take the original plan, but cut out a "window" of time steps around conflicts. 
The size of this window is given via the variable "window".
Thus we take the plan until the first conflict and the plan after the last conflict.
We then randomly generate new moves.
Every time we find a conflict we resolve it by giving on of the robots a "permit".
Only the robot with the permit may enter a conflict square. Everyone else has to adapt.


-> works fine most of the time, queues make problems (Benchmark 6, maybe more)