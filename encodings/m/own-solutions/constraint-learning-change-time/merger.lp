%#const horizon=1.
#const window=2.

time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

%get start positions
planned_position(R,(X,Y),0) :- init(object(robot, R), value(at, (X, Y))).

%generate every position a robot has at a given time
planned_position(R,(X+DX,Y+DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T), planned_position(R,(X,Y),T-1).

duration(R,T_max-1) :- T_max = #sum{1,T:planned_position(R,_,T)}, planned_position(R,_,0).
max_duration(T_max) :- T_max = #max{T:duration(R,T)}.

artificial_position(R,(X,Y),T+1) :- duration(R,T'), planned_position(R,(X,Y),T'), max_duration(T_max), time(T), T>=T', T<T_max. 

initial_position(R,(X,Y),T) :- planned_position(R,(X,Y),T).
initial_position(R,(X,Y),T) :- artificial_position(R,(X,Y),T).

goal_node(R,(X,Y)) :- init(object(shelf,R),value(at,(X,Y))).

% ----------------- Conflict Detection ---------------------------------------------------------------

%generate a vertex conflict (robots try to access the same square) for every robot who's part of the conflict
conflict(R,(X,Y,X,Y),T) :- initial_position(R,(X,Y),T), initial_position(R',(X,Y),T), R!=R'.

%generate a edge conflict (robots try to cross over each other) for every robot who's part of the conflict
conflict(R,(X,Y,X',Y'),T) :- initial_position(R,(X,Y),T-1), initial_position(R,(X',Y'),T), initial_position(R',(X',Y'),T-1), initial_position(R',(X,Y),T), R!=R', R>R'.
conflict(R',(X,Y,X',Y'),T) :- conflict(R,(X,Y,X',Y'),T), initial_position(R',(X',Y'),T-1), R!=R'.

% ----------------- Change Time Generation ---------------------------------------------------------

change_time(R,T') :- conflict(R,_,T), T'=T-window..T, T'>0, T'<=horizon. 

% ----------------- Copy Moves Till Conflict ---------------------------------------------------------

%first_conflict(R,T_min) :- T_min = #min{T:conflict(R,_,T)}, initial_position(R,_,0), T_min!=#sup.





%position(R,(X,Y),T) :- initial_position(R,(X,Y),T), first_conflict(R,T'), T<T'.

position(R,(X,Y),T) :- initial_position(R,(X,Y),T), not change_time(R,T), T<=horizon.

% ----------------- Move Generation ------------------------------------------------------------------

% generate every possible move randomly after first conflict
adj_node(R,(X+DX,Y+DY),T) :- change_time(R,T+1), position(R,(X,Y),T), node(X+DX,Y+DY), DX=-1..1, DY=-1..1, 1{|DX+DY| == 1;(DX,DY) == (0,0)}1, T<horizon.
%1{position(R,(X,Y),T+1) : adj_node(R,(X,Y),T)}1 :- adj_node(R,_,T).

% für jede position existiert adj_node
%:- not position(R,(X,Y),T), not adj_node(R,(X,Y),T-1), change_time(R,T).
%:- position(R,(X,Y),T), position(R,(X',Y'),T+1), DX=-1..1, DY=-1..1, not |DX+DY| == 1, not (DX,DY) == (0,0), X'=X+DX, Y'=Y+DY, T<horizon.
%:- position(R,(X,Y),T), position(R,(X+DX,Y+DY),T+1), DX=-1..1, DY=-1..1, |DX|+|DY| >= 2, T<horizon.
%:- position(R,(X,Y),T), position(R,(X',Y'),T+1), |X'-X|+|Y'-Y|>=2.

%:- position(R,(X,Y),T_max), position(R,(X',Y'),T_max+1), T_max = #max{T:change_time(R,T)}, DX=X'-X, DY=Y'-Y, |DX|+|DY| >= 2.


%generate a vertex conflict (robots try to access the same square) for every robot who's part of the conflict
conflict(R,(X,Y,X,Y),T) :- position(R,(X,Y),T), position(R',(X,Y),T), R!=R'.
%generate a edge conflict (robots try to cross over each other) for every robot who's part of the conflict
conflict(R,(X,Y,X',Y'),T) :- position(R,(X,Y),T-1), position(R,(X',Y'),T), position(R',(X',Y'),T-1), position(R',(X,Y),T), R!=R', R>R'.
conflict(R',(X,Y,X',Y'),T) :- conflict(R,(X,Y,X',Y'),T), position(R',(X',Y'),T-1), R!=R'.

% give permission to one of the robots to access the conflict square
1{permit(R,(X'',Y'',X''',Y'''),T) : conflict(R,_,T), position(R,(X'',Y''),T), position(R,(X''',Y'''), T-1) }1 :- conflict(_,(X,Y,X',Y'),T).

% throw out every model where a not permitted robot accesses the conflict square
:- permit(R,(X,Y,_,_),T), position(R',(X,Y),T), R!=R'.
:- permit(R,(X,Y,X',Y'),T), position(R',(X,Y),T-1), position(R',(X',Y'),T), R!=R'.

% final position equals goal position
:- position(R,(X,Y),horizon), goal_node(R,(X',Y')), (X,Y) != (X',Y').

% #heuristics
% #minimize{position, position != position(T-1)}

% ----------------- Output ------------------------------------------------------------------

occurs'(object(robot,R),action(move,(X'-X,Y'-Y)),T+1) :- position(R,(X,Y),T), position(R,(X',Y'),T+1).

%#show max_time/1.
%#show initial_position/3.
%#show position/3.
%#show first_conflict/2.
%#show adj_node/3.
%#show conflict/3.
%#show permit/3.
%#show goal_node/2.
#show occurs'/3.
%#show change_time/2.




