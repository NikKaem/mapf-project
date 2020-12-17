%#const horizon=1.
time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get start positions
position(R,(X,Y),0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
position(R,(X+D1, Y+D2),T) :- occurs(object(robot,R),action(move,(D1,D2)),T), position(R,(X,Y),T-1).

%generate a conflict for one of the robots
conflict(R1,T) :- position(R1,(X,Y),T), position(R2,(X,Y),T), R2>R1.

% ----------------- Robot who reacts to the conflict -------------------------------------------------

%generate all moves until the conflict arises for the robot who has to react to the conflict 
move(R,(D1,D2),T1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict(R,T2), T1<T2.

%generate waiting move for conflict time
move(R,(0,0),T) :- conflict(R,T).

%generate planned moves one time step later
move(R,(D1,D2),T1+1) :- occurs(object(robot,R),action(move,(D1,D2)),T1), conflict(R,T2), T1>=T2.

% ----------------- Robot who ignores the conflict ---------------------------------------------------

%generate all moves for the robot who can ignore the conflict
move(R,(D1,D2),T) :- occurs(object(robot,R),action(move,(D1,D2)),T), not conflict(R,_).

%------------------ Output ---------------------------------------------------------------------------

%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).

%occurs(object(robot, R), action(move, D), T):- move(R,D,T).

#show move/3.