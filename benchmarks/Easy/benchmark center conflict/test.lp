%#const horizon=1.
time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

%get start positions
position(R,(X,Y),0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
position(R,(X+D1, Y+D2),T) :- occurs(object(robot,R),action(move,(D1,D2)),T), position(R,(X,Y),T-1).

%generate a vertex conflict (robots try to access the same square) for one of the robots
conflict_vertex(R1,T) :- position(R1,(X,Y),T), position(R2,(X,Y),T), R2>R1.

%generate a edge conflict (robots try to cross over each other) for one the robots
conflict_edge(R1,T) :- position(R1,(X,Y),T), position(R1,(X',Y'),T+1), position(R2,(X',Y'),T), position(R2,(X,Y),T+1), R2>R1.

% ----------------- Robot who reacts to the conflict -------------------------------------------------

% ----------------- Robot who reacts to the vertex conflict ------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
move(R,(D1,D2),T1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict_vertex(R,T2), T1<T2.

%generate waiting move for conflict time
move(R,(0,0),T) :- conflict_vertex(R,T).

%generate planned moves one time step later
move(R,(D1,D2),T1+1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict_vertex(R,T2), T1>=T2.

% ----------------- Robot who reacts to the edge conflict --------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
move(R,(D1,D2),T1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict_edge(R,T2), T1<T2.

adj_nodes(X+DX,Y+DY) :- node(X+DX,Y+DY), DX=-1..1, DY=-1..1, |DX+DY| == 1, position(R,(X,Y),T), conflict_edge(R,T).
% need to figure out how to pick one of the adjacent nodes we generated above

% that works but it would also consider nodes that are not initialized
%1{move(R1,(X+1,Y),T+1);move(R1,(X-1,Y),T+1);move(R1,(X,Y+1),T+1);move(R1,(X,Y-1),T+1)}1 :- position(R1,(X,Y),T), conflict_edge(R1,T).

% generate planned moves one time step later [probably some editing necessary after dodging is done]
move(R,(D1,D2),T1+1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict_edge(R1,T2), T1>=T2.

% ----------------- Robot who ignores the conflict ---------------------------------------------------

%generate all moves for the robot who can ignore the conflict
move(R,(D1,D2),T) :- occurs(object(robot,R),action(move,(D1,D2)),T), not conflict_vertex(R,_), not conflict_edge(R,_).

%------------------ Output ---------------------------------------------------------------------------

%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).

%occurs(object(robot, R), action(move, D), T):- move(R,D,T).

#show nodeX/2.