%#const horizon=1.

time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

%get start positions
planned_position(R,(X,Y),0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
planned_position(R,(X+DX,Y+DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T), planned_position(R,(X,Y),T-1).

time(R,T_max-1) :- T_max = #sum{1,T:planned_position(R,_,T)}, planned_position(R,_,0).
max_time(T_max) :- T_max = #max{T:time(R,T)}.

artificial_position(R,(X,Y),T+1) :- time(R,T'), planned_position(R,(X,Y),T'), max_time(T_max), time(T), T>=T', T<T_max. 

initial_position(R,(X,Y),T) :- planned_position(R,(X,Y),T).
initial_position(R,(X,Y),T) :- artificial_position(R,(X,Y),T).

goal_node(R,(X,Y)) :- init(object(shelf,R),value(at,(X,Y))).

% ----------------- Conflict Detection ---------------------------------------------------------------

%generate a vertex conflict (robots try to access the same square) for every robot who's part of the conflict
conflict(R,T) :- initial_position(R,(X,Y),T), initial_position(R',(X,Y),T), R!=R'.

%generate a edge conflict (robots try to cross over each other) for every robot who's part of the conflict
conflict(R,T) :- initial_position(R,(X,Y),T-1), initial_position(R,(X',Y'),T), initial_position(R',(X',Y'),T-1), initial_position(R',(X,Y),T), R!=R'.

% ----------------- Copy Moves Till Conflict ---------------------------------------------------------

first_conflict(R,T_min) :- T_min = #min{T:conflict(R,T)}, initial_position(R,_,0), T_min!=#sup.

position(R,(X,Y),T) :- initial_position(R,(X,Y),T), first_conflict(R,T'), T<T'.

position(R,(X,Y),T) :- initial_position(R,(X,Y),T), not first_conflict(R,_), T<=horizon.

% ----------------- Move Generation ------------------------------------------------------------------

adj_node(R,(X+DX,Y+DY),T) :- first_conflict(R,T'), position(R,(X,Y),T), node(X+DX,Y+DY), DX=-1..1, DY=-1..1, 1{|DX+DY| == 1;(DX,DY) == (0,0)}1, T<horizon, T>=T'-1.
1{position(R,(X,Y),T+1) : adj_node(R,(X,Y),T)}1 :- adj_node(R,_,T).

:- position(R,(X,Y),T), position(R',(X,Y),T), R!=R'.
:- position(R,(X,Y),T-1), position(R,(X',Y'),T), position(R',(X',Y'),T-1), position(R',(X,Y),T), R!=R'.
:- position(R,(X,Y),horizon), goal_node(R,(X',Y')), (X,Y) != (X',Y').

% ----------------- Output ------------------------------------------------------------------

occurs'(object(robot,R),action(move,(X'-X,Y'-Y)),T+1) :- position(R,(X,Y),T), position(R,(X',Y'),T+1).

%#show max_time/1.
%#show initial_position/3.
%#show position/3.
%#show first_conflict/2.
%#show adj_node/3.
%#show conflict/2.
%#show goal_node/2.
#show occurs'/3.




