%Inputs:
%conflict(Fut,C1,C2,SameC,R1,R2,T)

%Getting the Inputs and Predicates.

%Getting the Instance Size ----------------------------------------------------

%Getting the Time Horizion ------------------------------------------------------

%Getting Start position
position(R,(X,Y),0):-init(object(robot, R), value(at, (X, Y))).

%Getting the next position when moving
position(R,(X+X',Y+Y')),T):-position(R,(X,Y),T-1),move(R,(X',Y'),T-1).

%Getting the Final Position -------------------------------------------------


%position inertia
position(R,C,T):-position(R,C,T-1), not move(R,_,T-1).

%getting move predicates
move(R,D,T):-occurs(object(robot, R), action(move, D, T)).

%getting moveto predicates
moveto((X',Y'),(X'+DX,Y'+DY),T):-move(R,(DX,DY),T),position(R,(X',Y'),T).



%Conflict Predicate
%General format: conflict( ID, Type, Cell, Robot1, Robot2, Timestep)

%Conflict -> Same Cell for two (or more) Robots in the same Timestep -> Future 
conflict(ID,Fut,SameC,R1,R2,T):- moveto(C1,SameC,T),moveto(C2,SameC,T),position(R1,C1,T),position(R2,C2,T),C1!=C2.

%Conflict -> One Robot wants to go where another Robot is at the Timestep T -> Present 
conflict(ID,Pre,SameC,R1,R2,T):- moveto(C1,SameC,T),position(R1,C1,T),position(R2,SameC,T), not move(R2,_,T).

#show conflict/6.