%Inputs -----------------------------------------------------------------------------------
%conflict(Type,C1,C2,SameC,R1,R2,T)

%Getting the Inputs and Predicates.

%Getting the Instance Size ----------------------------------------------------

%Getting the Time Horizion ------------------------------------------------------

%Getting Start position
position(R,(X,Y),0):-init(object(robot, R), value(at, (X, Y))).

%Getting the next position when moving
position(R,(X+X',Y+Y')),T):-position(R,(X,Y),T-1),move(R,(X',Y'),T-1).

%Getting the Final Position -------------------------------------------------


%getting move predicates
move(R,D,T):-occurs(object(robot, R), action(move, D, T)).

%getting moveto predicates
moveto((X',Y'),(X'+DX,Y'+DY),T):-move(R,(DX,DY),T),position(R,(X',Y'),T).


%EXECUTION------------------------------------------------------------------------------


%position inertia
position(R,C,T):-position(R,C,T-1), not move(R,_,T-1).

%every conflict has to be solved



%conflict(Max-Current,_,C1,C2,SameC,R1,R2,T):-Current==#sum{1:conflict(ID,_,C1,C2,SameC,R1,R2,T)} ,Max==#sum{1:conflict(_,C1,C2,SameC,R1,R2,T)}

%solvedConflict(R1+R2+SameC) :- conflict(Type,C1,C2,SameC,R1,R2,T).

:- not solvedConflict(C1+C2+SameC), conflict(Type,C1,C2,SameC,R1,R2,T).


%Output -----------------------------------------------------------------------------------
%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).

#show occurs/3.