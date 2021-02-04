Input: Mapf Instance

Root.constraints= empty set
root.solution = find individual paths by low_level()
root.cost = SIC (Root.solution) //sum of individual costs heuristic (SIC)
insert Root to OPEN
while OPEN not empty do:
	P <- best node from OPEN //lowest solution cost	
	Validate the paths in P until a conflict occurs
	if P has no conflict then
		return P.solution //P is goal
    C <- first conflict (a_i,a_j,v,t) in P
    
    if shouldMerge(a_i,a_j) //Optional MA-CBS only then
    
    for each agent in C do  
        A<- new node
        A.constraints<-P.constraints + (a_i,v,t)
        A.solution <- P.solution
        Update A.solution by invoking low level (a_i)
        A.cost=SIC(A.solution)
        if A.cost < infinity //A solution was found then
            Insert A to OPEN
        