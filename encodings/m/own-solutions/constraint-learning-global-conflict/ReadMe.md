This merger is based on a idea presented in the CBS Algorithm of https://www.sciencedirect.com/science/article/pii/S0004370214001386


In this approach we take the original plan until the first conflict. 
However to solve every benchmark we start generating random moves for every robot as soon as the first conflict is found. (This solves the "queue Problem" benchmark-6)
Every time we find a conflict we resolve it by giving on of the robots a "permit".
Only the robot with the permit may enter a conflict square. Everyone else has to adapt.
