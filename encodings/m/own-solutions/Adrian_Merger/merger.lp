conflict_nr(0..c_nr).
time(0..horizon).

isRobot(robot(R)) :- init(object(robot,R),_).
position((X,Y))   :- init(object(node,_), value(at,(X,Y))).
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(DX,DY),(X',Y')) :- direction((DX,DY)), position((X,Y)), position((X',Y')), (X',Y')=(X+DX,Y+DY).

% Rename occurs/3 to move/4 ---------------------------------------------------------------------------------------------------------------
move(R,D,T,0) :- occurs(object(robot,R),action(move,D),T).


% Define position -------------------------------------------------------------------------------------------------------------------------
position(R,C,0,0) :- init(object(robot,R), value(at,C)).
position(R,C,T,A) :- move(R,D,T,A), position(R,C',T-1,A), nextto(C',D,C).
                  :- move(R,D,T,A), position(R,C ,T-1,A), not nextto(C ,D,_).
position(R,C,T,A) :- position(R,C,T-1,A), not move(R,_,T,A), conflict_nr(A), isRobot(robot(R)), time(T).


% Define end position ---------------------------------------------------------------------------------------------------------------------
goal(R,C) :- position(R,C,horizon,0).
:- position(R,C,horizon,_), goal(R,C'), C!=C'.


% Conflict Detection - Standard -----------------------------------------------------------------------------------------------------------
conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T,A), R1!=R2, conflict_nr(A).
conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T-1,A), position(R2,C1,T,A),
						R1!=R2, conflict_nr(A).

						
% Conflict Detection - Strict Plan --------------------------------------------------------------------------------------------------------
%conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T,A), R1!=R2, conflict_nr(A), not strict_plan(R1).
%conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T-1,A), position(R2,C1,T,A),
%						R1!=R2, conflict_nr(A), not strict_plan(R1).
						
%:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T,A), R1!=R2, conflict_nr(A), strict_plan(R1), strict_plan(R2).
%:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T-1,A), position(R2,C1,T,A),
%	R1!=R2, conflict_nr(A), strict_plan(R1), strict_plan(R2).


% Conflict Detection - Priority -----------------------------------------------------------------------------------------------------------
%conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T,A), R1!=R2, conflict_nr(A),
%						p_priority(R1,P1), p_priority(R2,P2), P1<=P2.
%conflict(R1,T,A)	:- position(R1,C1,T-1,A), position(R1,C2,T,A), position(R2,C2,T-1,A), position(R2,C1,T,A),
%						R1!=R2, conflict_nr(A), p_priority(R1,P1), p_priority(R2,P2), P1<=P2.

%p_priority(R,P) :- priority(R,P).
%p_priority(R,0) :- not priority(R,_), isRobot(robot(R)).

% Conflict Selection ----------------------------------------------------------------------------------------------------------------------
1{solving_conflict(R,T,A) : conflict(R,T,A)}1 :- conflict(_,_,A).
:- conflict(_,T,A), solving_conflict(_,T',A), T'>T.


% Minimize Number of Conflicts ------------------------------------------------------------------------------------------------------------
#minimize {1,(R,T,A): solving_conflict(R,T,A)}.


% Conflict Solving ------------------------------------------------------------------------------------------------------------------------
0{move(R,D,T,A+1) : direction(D), nextto(C,D,_)}1 :- solving_conflict(R,T,A), position(R,C,T-1,A).

position(R,C,T-1,A+1) 		:- solving_conflict(R',T,A), isRobot(robot(R)), position(R,C,T-1,A).
move(R,D,T',A+1) 			:- solving_conflict(R',T,A), isRobot(robot(R)), R!=R', move(R,D,T',A), T'>=T.

% No move taken ---------------------------------------------------------------------------------------------------------------------------
move(R,D,T'+1,A+1) 			:- solving_conflict(R,T,A), not move(R,_,T,A+1), move(R,D,T',A), T'>=T, time(T').


% Random move taken -----------------------------------------------------------------------------------------------------------------------
1{step_back(R,(DX',DY'),T_B,A+1) : time(T_B), T_B<=horizon, T_B>T}1:- solving_conflict(R,T,A), move(R,(DX,DY),T,A+1), DX'=-DX, DY'=-DY.
move(R,D,T,A) :- step_back(R,D,T,A).
move(R,D,T'+1,A+1) 			:- solving_conflict(R,T,A), step_back(R,_,T_B,A+1), move(R,D,T',A), T'>=T, T<T_B-1.
move(R,D,T'+2,A+1) 			:- step_back(R,_,T_B,A+1), move(R,D,T',A), T'>=T_B-1.


% Integrity Constraints -------------------------------------------------------------------------------------------------------------------
:- move(_,_,T,_), T>horizon.
:- position(_,_,T,_), T>horizon.
:- move(_,_,_,A), A>c_nr.
:- position (_,_,_,A), A>c_nr.
:- conflict(_,T,_), T>=horizon.
:- conflict(_,_,A), A>=c_nr.




% Generate merged plan --------------------------------------------------------------------------------------------------------------------
new_move(R,D,T) :- move(R,D,T,MAX_C), MAX_C == #max{A: position(R,C,T-1,A)}.
occurs'(object(robot,R),action(move,D),T) :- new_move(R,D,T).

% Output ----------------------------------------------------------------------------------------------------------------------------------
#show occurs'/3.