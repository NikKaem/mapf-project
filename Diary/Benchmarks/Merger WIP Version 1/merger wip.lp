%#const horizon=1.
time(1..horizon).
max(0..horizon).
% ----------------- Prerequisites --------------------------------------------------------------------
%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).
%get start positions
position(R,(X,Y),0,0) :- init(object(robot, R), value(at, (X, Y))).
%generate every position a robot has at a given time
position(R,(X+D1,Y+D2),T,0) :- occurs(object(robot,R),action(move,(D1,D2)),T), position(R,(X,Y),T-1,0).
% ----------------- Conflict Detection ---------------------------------------------------------------
%generate a vertex conflict (robots try to access the same square) for one of the robots
conflict_vertex(R1,R2,T,L1) :- position(R1,(X,Y),T,L1), position(R2,(X,Y),T,L2), R2>R1, max(L).
%generate a edge conflict (robots try to cross over each other) for one the robots
conflict_edge(R1,R2,T,L1) :- position(R1,(X,Y),T,L1), position(R1,(X',Y'),T+1,L1), position(R2,(X',Y'),T,L2), position(R2,(X,Y),T+1,L2), R2>R1, max(L).
% ----------------- Robot who reacts to the conflict -------------------------------------------------
% ----------------- Robot who reacts to the vertex conflict ------------------------------------------
%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R1,(X,Y),T1,L+1) :- position(R1,(X,Y),T1,L), conflict_vertex(R1,R2,T2,L), T1<T2, max(L).
%generate waiting move for conflict time
position(R1,(X,Y),T,L+1) :- position(R1,(X,Y),T-1,L), conflict_vertex(R1,R2,T,L), max(L).
%generate planned moves one time step later
position(R1,(X,Y),T1+1,L+1) :- position(R1,(X,Y),T1,L), conflict_vertex(R1,R2,T2,L), T1>=T2, max(L).
% ----------------- Robot who reacts to the edge conflict --------------------------------------------
%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R1,(X,Y),T1,L+1) :- position(R1,(X,Y),T1,L), conflict_edge(R1,R2,T2,L), T1<=T2, max(L).
%generate all adjacent nodes that the robot can go to and pick one 
adj_nodes(X+DX,Y+DY,L,R1) :- node(X+DX,Y+DY), DX=-1..1, DY=-1..1, |DX+DY| == 1, conflict_edge(R1,R2,T,L), position(R1,(X,Y),T,L).
1{dodge_node(X,Y,L,R) : adj_nodes(X,Y,L,R)}1 :- conflict_edge(R,_,_,L).  
% what if no adjacent nodes -> backtracking
%let robot move to dodge node and back afterwards
position(R1,(X,Y),T+1,L+1) :- dodge_node(X,Y,L,R1), conflict_edge(R1,R2,T,L), max(L).
:- dodge_node(X,Y,L,R1), position(R2,(X,Y),T+2,L), conflict_edge(R1,R2,T,L).
:- dodge_node(X,Y,L,R1), position(R2,(X,Y),T,L), conflict_edge(R1,R2,T,L).
position(R1,(X,Y),T+2,L+1) :- position(R1,(X,Y),T,L), conflict_edge(R1,R2,T,L), max(L).
% generate planned moves two time steps later
position(R1,(X,Y),T1+3,L+1) :- position(R1,(X,Y),T1,L), conflict_edge(R1,R2,T2,L), T1>=T2, max(L).
%------------------ Output ---------------------------------------------------------------------------
%generate the highest conflict layer each robot achieved
highest_conflict_layer(R,L_Max-1) :- position(R,(_,_),0,0), L_Max == #sum{1,L:position(R,(_,_),_,L)}.
%generate conflict free solution based on the highest conflict layer
position'(R,(X,Y),T,L) :- position(R,(X,Y),T,L), highest_conflict_layer(R,L).
% any move T > horizon
% limit maximum layers?

%Robots have be at shelf when ending
:- time(horizon), not position'(S,(X,Y), horizon,_), init(object(order,_),value(line,(product_id))),init(object(shelf,S),value(at,(X,Y))),init(object(product,product_id),value(on,(S,_))).
:- time(horizon), not position'(S,(X,Y), horizon,_), init(object(order,_),value(line,(product_id,_))),init(object(shelf,S),value(at,(X,Y))),init(object(product,product_id),value(on,(S,_))).




%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).
%occurs(object(robot, R), action(move, D), T):- move(R,D,T).
#show conflict_vertex/4.
#show conflict_edge/4.
#show dodge_node/4.
#show position/4.