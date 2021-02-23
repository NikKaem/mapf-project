%#const horizon=1.

time(1..horizon).

% ----------------- Prerequisites --------------------------------------------------------------------

%get every initialized node
node(X,Y) :- init(object(node,_), value(at, (X,Y))).

goal_node(R,(X,Y)) :- init(object(shelf,R),value(at,(X,Y))).

position(R,(X,Y),0) :- init(object(robot, R), value(at, (X, Y))).

% ----------------- Move Generation ------------------------------------------------------------------

adj_node(R,(X+DX,Y+DY),T) :- position(R,(X,Y),T), node(X+DX,Y+DY), DX=-1..1, DY=-1..1, 1{|DX+DY| == 1;(DX,DY) == (0,0)}1, T<horizon.
1{position(R,(X,Y),T+1) : adj_node(R,(X,Y),T)}1 :- adj_node(R,_,T).

#heuristic position(R,(X,Y),T) : position(R,_,0),node(X,Y),time(T). [2, init]
%Bias first search towards generating position
#heuristic position(R,(X,Y),T) : position(R,_,0),node(X,Y),time(T). [2,factor]
%Propagate Bias for search through search
#heuristic position(R,(X,Y),T) : position(R,_,0),node(X,Y),time(T). [1,sign]
%Bias towards true for position

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




