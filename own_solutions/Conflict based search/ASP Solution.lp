%Input MAPF Instance (Directed Graph, labeled agents)

% These are our active nodes and the labeled robots

%Root.constraints= empty set

%We can do this just by adding no constraints.

% root.solution = find individual paths by low_level()

%Given as the first inputs to the program

%root.cost = SIC (Root.solution)

%calculate distance between goal and robot -> optimal individual path


%insert Root to OPEN

%A* always begins by expanding a state and inserting its successors into the open list (denoted OPEN).
%Maybe a List?
%Open(Node_depth, Node)
%So starting with

%Open(0,Root)

%while OPEN not empty do:

%Maybe 
%:- not Open(Max_Node_depth,_),#sum=1,node_depth:Open(node_depth,_)
 
	%P <- best node from OPEN //lowest solution cost	
	
	%
	
	
	%Validate the paths in P until a conflict occurs
	
	%conflict(Node_depth,Path_ID, Robot1,Robot2, Vertex, Timestep) :- determine conflicts (Maybe only once? See Line 12 in Original Code)
	
	%if P has no conflict then
	
	%finish(Path_ID):-not conflict(_,Path_ID,_,_,_)
		
		%return P.solution //P is goal
		
		%start outputting only for finish(Path_ID). (But maybe only once per Programm call?)
    %C <- first conflict (a_i,a_j,v,t) in P
	
	%conflict(Min_Node_depth,Path_ID,R1,R2,Vertex,Timestep)
    
    %for each agent in C do

	%Add :- conflict(Min_Node_depth,Path_ID,R1,R2,Vertex,Timestep) to every following rule
        
		%A<- new node
		
		%Probably combined with Line 23 in Original Code
		
        %A.constraints<-P.constraints + (a_i,v,t)
		
		%constraint(Min_Node_depth+1(?),Path_ID,R1,Vertex,Timestep):- conflict(Min_Node_depth,Path_ID,R1,R2,Vertex,Timestep) %get new constraint
		%constraint(Min_Node_depth+1(?),Path_ID,R1,Vertex,Timestep):- constraint(Min_Node_depth,Path_ID,R(?),Vertex2,Timestep2),conflict(Min_Node_depth,Path_ID,R1,R2,Vertex,Timestep)%copy old constraints
        
		%A.solution <- P.solution
		
		%copy old path up to this point
		
        %Update A.solution by invoking low level (a_i)
		
		%Get new Paths for Robot 
		
        %A.cost=SIC(A.solution)
		
		%calculate distance between goal and robot -> optimal individual path
		
        %if A.cost < infinity //A solution was found then
		
		%IDK
		
            %Insert A to OPEN
			
			%Open(Node_depth+1,A).
        