%#const horizon=1.
time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

%get start positions
position(R,(X,Y),0,0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
position(R,(X+D1,Y+D2),T,0) :- occurs(object(robot,R),action(move,(D1,D2)),T), position(R,(X,Y),T-1,0).

%generate a vertex conflict (robots try to access the same square) for one of the robots
conflict_vertex(R1,T,L1) :- position(R1,(X,Y),T,L1), position(R2,(X,Y),T,L2), R2>R1.

%generate a edge conflict (robots try to cross over each other) for one the robots
conflict_edge(R1,T,L1) :- position(R1,(X,Y),T,L1), position(R1,(X',Y'),T+1,L1), position(R2,(X',Y'),T,L2), position(R2,(X,Y),T+1,L2), R2>R1.

% ----------------- Robot who reacts to the conflict -------------------------------------------------

% ----------------- Robot who reacts to the vertex conflict ------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R,(X,Y),T1,L+1) :- position(R,(X,Y),T1,L), conflict_vertex(R,T2,L), T1<T2.

%generate waiting move for conflict time
position(R,(X,Y),T,L+1) :- position(R,(X,Y),T-1,L), conflict_vertex(R,T,L).

%generate planned moves one time step later
position(R,(X,Y),T1+1,L+1) :- position(R,(X,Y),T1,L), conflict_vertex(R,T2,L), T1>=T2.

% ----------------- Robot who reacts to the edge conflict --------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R,(X,Y),T1,L+1) :- position(R,(X,Y),T1,L), conflict_edge(R,T2,L), T1<T2.

%generate all adjacent nodes that the robot can go to and pick one 
adj_nodes(X+DX,Y+DY,L) :- node(X+DX,Y+DY), DX=-1..1, DY=-1..1, |DX+DY| == 1, conflict_edge(R,T,L), position(R,(X,Y),T,L).
1{dodge_node(X,Y,L) : adj_nodes(X,Y,L)}1. 

%let robot move to dodge node and back afterwards
%position(R,(X,Y),T,L+1) :- dodge_node(X,Y,L), conflict_edge(R,T,L).
position(R,(X,Y),T+1,L+1) :- position(R,(X,Y),T,L), conflict_edge(R,T,L).

% generate planned moves two time steps later
position(R,(X,Y),T1+2,L+1) :- position(R,(X,Y),T1,L), conflict_edge(R,T2,L), T1>=T2.

% ----------------- Robot who ignores the conflict ---------------------------------------------------

%[not necessary i guess]
%generate all moves for the robot who can ignore the conflict
%position(R,(X,Y),T,L+1) :- position(R,(X,Y),T,L), not conflict_vertex(R,_,L).

%------------------ Output ---------------------------------------------------------------------------

%generate the highest conflict layer each robot achieved
highest_conflict_layer(R,L_Max-1) :- init(object(robot,R),value(at,(_,_))), L_Max == #sum{1,L:position(R,(_,_),_,L)}.

%generate conflict free solution based on the highest conflict layer
position'(R,(X,Y),T,L) :- position(R,(X,Y),T,L), highest_conflict_layer(R,L).

%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).
%occurs(object(robot, R), action(move, D), T):- move(R,D,T).

#show dodge_node/3.