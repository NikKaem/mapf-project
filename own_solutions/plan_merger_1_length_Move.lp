%Inputs -----------------------------------------------------------------------------------
%possible inputs: (Maybe?) 
%imported from visualizer

%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).
%occurs(object(robot, [RobotID]), action(pickup, ()), [time step]).
%occurs(object(robot, [RobotID]), action(putdown, ()), [time step]).
%occurs(object(robot, [RobotID]), action(charge, [charged amount]), [time step]).
%occurs(object(robot, [RobotID]), action(deliver, ([order ID],[product ID],[product amount])), [time step]).
%occurs(object(robot, [RobotID]), action(deliver, ([order ID], [product ID])), [time step]).

%Instance Format
%init(object([object type], [object ID]), value(at, ([X], [Y]))).
%init(object(robot, [robot ID]), value(carries, [shelf ID]))).
%init(object(robot, [robot ID]), value(max_energy, [max energy])).
%init(object(robot, [robot ID]), value(energy, [energy])).
%init(object(robot, [robot ID]), value(energy_cost, ([action], [energy cost]))).
%init(object(order, [order ID]), value(line, ([product ID], [product amount]))).
%init(object(order, [order ID]), value(line, ([product ID])).
%init(object(order, [order ID]), value(pickingStation, [picking station ID])).
%init(object(product, [product ID]), value(on, ([shelf ID], [product amount]))).

%move Format
%moveto(C',C,T)
%move(R,D,T)


%Getting the Inputs and Predicates.

%Getting the Instance Size ----------------------------------------------------

%Getting the Time Horizion ------------------------------------------------------
%#const horizon=1.
time(1..horizon).

%Getting Start position
position(R,(X,Y),0):-init(object(robot, R), value(at, (X, Y))).

%Getting the Final Position -------------------------------------------------
Final(S,(X,Y)):- init(object(shelf, S), value(at, (X, Y))).

%getting move predicates
move(R,D,T):-occurs(object(robot, R), action(move, D, T)),position.

%getting moveto predicates
moveto((X',Y'),(X'+DX,Y'+DY),T):-move(R,(DX,DY),T),position(R,(X',Y'),T).

%Directions
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.




%EXECUTION------------------------------------------------------------------------------

%Getting the Fields next to the current one
nextto((X,Y),(DX,DY),(X',Y')) :- direction((DX,DY)), position((X,Y)), position((X',Y')), (X,Y)=(X'-DX,Y'-DY), (X',Y')=(X+DX,Y+DY).

%Getting the next position when moving
position(R,(X+X',Y+Y')),T):-position(R,(X,Y),T-1),move(R,(X',Y'),T-1).

%position inertia
position(R,C,T):-position(R,C,T-1), not move(R,_,T-1).

%conflicts require new moves
%conflict two robots want to go to the same node in the timestep T
1 { new_move(R,D,T) : direction(D),D } 1:- moveto(C1,SameC,T),moveto(C2,SameC,T),position(R1,C1,T),position(R2,C2,T),C1!=C2.

%conflict a robot wants to go to a node another robot is already on.
1 { new_move(R,D,T) : direction(D) } 1 :- moveto(C1,SameC,T),position(R1,C1,T),position(R2,SameC,T), not move(R2,_,T).

%Getting Moveto for all new moves
new_moveto((X',Y'),(X'+DX,Y'+DY),T):- new_move(R,(DX,DY),T),position(R,(X',Y'),T).

%Getting Moveto for all unchanged moves
new_moveto(C',C,T):- moveto(C',C,T), not new_moveto(C',C,T).

%Every Goal has to be reached
:- not position(R,C,horizon),Final(S,C). 



%Output -----------------------------------------------------------------------------------

%Formating the moves we did not change.
new_move(R,D,T):- move(R,D,T), not new_move(R,D,T).

%Plan Format
%occurs(object(robot, [RobotID]), action(move, ([X], [Y])), [time step]).

occurs(object(robot, R), action(move, D), T):- new_move(R,D,T).

#show occurs/3.