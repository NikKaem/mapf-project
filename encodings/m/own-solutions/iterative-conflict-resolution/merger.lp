%#const horizon=1.

time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

%get start positions
position(R,(X,Y),0,0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
position(R,(X+D1,Y+D2),T,0) :- occurs(object(robot,R),action(move,(D1,D2)),T), position(R,(X,Y),T-1,0).

% ----------------- Conflict Detection ---------------------------------------------------------------

% finished predicate for robots, extra conflict type

%generate a vertex conflict (robots try to access the same square) for one of the robots
conflict_vertex(R1,R2,T,L+1) :- position(R1,(X,Y),T,L), position(R2,(X,Y),T,L), R2>R1, L<=horizon.

%generate a edge conflict (robots try to cross over each other) for one the robots
conflict_edge(R1,R2,T,L+1) :- position(R1,(X,Y),T,L), position(R1,(X',Y'),T+1,L), position(R2,(X',Y'),T,L), position(R2,(X,Y),T+1,L), R2>R1, L<=horizon.

% ----------------- Robot who reacts to the conflict -------------------------------------------------

% ----------------- Robot who reacts to the vertex conflict ------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R1,(X,Y),T,L) :- position(R1,(X,Y),T,L-1), conflict_vertex(R1,R2,T',L), T<T'.

%generate waiting move for conflict time
position(R1,(X,Y),T,L) :- position(R1,(X,Y),T-1,L-1), conflict_vertex(R1,R2,T,L).

%generate planned moves one time step later
position(R1,(X,Y),T+1,L) :- position(R1,(X,Y),T,L-1), conflict_vertex(R1,R2,T',L), T>=T'.

%generate all planned moves for the other robot one conflict layer higher
position(R2,(X,Y),T,L) :- position(R2,(X,Y),T,L-1), conflict_vertex(R1,R2,T',L).

% ----------------- Robot who reacts to the edge conflict --------------------------------------------

%generate all adjacent nodes that the robot can go to and pick one 

p_candidate(R1,R2,(X+DX,Y+DY),L) :- node(X+DX,Y+DY), DX=-1..1, DY=-1..1, |DX+DY| == 1, position(R1,(X,Y),T,L-1), conflict_edge(R1,R2,T,L), not position(R2,(X+DX,Y+DY),T+2,L-1), not position(R2,(X+DX,Y+DY),T,L-1).
adj_nodes(R1,R2,(X,Y),L) :- p_candidate(R1,R2,(X,Y),L).

s_candidate(R2,R1,(X+DX,Y+DY),L) :- not p_candidate(R1,R2,_,L), node(X+DX,Y+DY), DX=-1..1, DY=-1..1, |DX+DY| == 1, position(R2,(X,Y),T,L-1), conflict_edge(R1,R2,T,L), not position(R1,(X+DX,Y+DY),T+2,L-1), not position(R1,(X+DX,Y+DY),T,L-1).
adj_nodes(R2,R1,(X,Y),L) :- s_candidate(R2,R1,(X,Y),L).

t_candidate(R1,R2,(X,Y),L) :- not p_candidate(R1,R2,_,L), not s_candidate(R2,R1,_,L), position(R2,(X,Y),T+2,L-1), conflict_edge(R1,R2,T,L).
adj_nodes(R1,R2,(X,Y),L) :- t_candidate(R1,R2,(X,Y),L).

%q_candidate(R2,R1,(X,Y),L) :- not p_candidate(R1,R2,_,L), not s_candidate(R2,R1,_,L), not t_candidate(R1,R2,_,L), position(R1,(X,Y),T+2,L-1), conflict_edge(R1,R2,T,L).
%adj_nodes(R2,R1,(X,Y),L) :- q_candidate(R2,R1,(X,Y),L).

1{dodge_node(R,R',(X,Y),L) : adj_nodes(R,R',(X,Y),L)}1 :- conflict_edge(R1,R2,_,L).

%generate all moves until the conflict arises for the robot who has to react to the conflict 
position(R,(X,Y),T,L) :- position(R,(X,Y),T,L-1), dodge_node(R,R',_,L), conflict_edge(R1,R2,T',L), T<=T'.

%let robot move to dodge node
position(R,(X,Y),T+1,L) :- dodge_node(R,R',(X,Y),L), conflict_edge(R1,R2,T,L).

%generate planned moves two time steps later (implicitly going back from dodge node)
position(R,(X,Y),T+2,L) :- position(R,(X,Y),T,L-1), dodge_node(R,R',_,L), conflict_edge(R1,R2,T',L), T>=T'.

%generate all planned moves for the other robot one conflict layer higher
position(R',(X,Y),T,L) :- position(R',(X,Y),T,L-1), dodge_node(R,R',_,L), conflict_edge(R1,R2,T',L).

%------------------ Output ---------------------------------------------------------------------------

%generate the highest conflict layer each robot achieved
highest_conflict_layer(R,L_Max-1) :- position(R,(_,_),0,0), L_Max == #sum{1,L:position(R,(_,_),_,L)}.

%generate conflict free solution based on the highest conflict layer
position'(R,(X,Y),T) :- position(R,(X,Y),T,L), highest_conflict_layer(R,L).

:- T_Max == #sum{1,T:position(R,(_,_),T,_)}, not time(T_Max-1).

occurs'(object(robot,R),action(move,(X'-X,Y'-Y)),T+1) :- position(R,(X,Y),T), position(R,(X',Y'),T+1).

%#show position'/4.
%#show conflict_vertex/4.
%#show conflict_edge/4.
%#show dodge_node/4.
#show occurs'/3.
