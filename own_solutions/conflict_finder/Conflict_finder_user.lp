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

%Not required as we redefined it
%#include "../encodings/action-M.lp"
%#include "../encodings/input.lp"

%Getting the Inputs and Predicates.

%Getting Start position
position(R,(X,Y),0):-init(object(robot, R), value(at, (X, Y))).

%Getting the next position when moving
position(R,(X+X',Y+Y'),T):-position(R,(X,Y),T-1),move(R,(X',Y'),T-1).

%position inertia
position(R,C,T):-position(R,C,T-1), not move(R,_,T-1).

%getting move predicates
move(R,D,T):-occurs(object(robot, R), action(move, D), T).

%getting moveto predicates
moveto((X',Y'),(X'+DX,Y'+DY),T):-move(R,(DX,DY),T),position(R,(X',Y'),T).



%Conflict Predicate
%General format: conflict(Type, Cell, Robot1, Robot2, Timestep)

%Type 
%1 = Same Cell for two (or more) Robots in the same Timestep -> Future 
%0 = One Robot wants to go where another Robot is at the Timestep T -> Present 
conflicttype(1).
conflicttype(0).

%Conflict -> Same Cell for two (or more) Robots in the same Timestep -> Future 
conflict(1,C1,C2,SameC,R1,R2,T):- moveto(C1,SameC,T),moveto(C2,SameC,T),position(R1,C1,T),position(R2,C2,T),C1!=C2,conflicttype(1).
conflict(1,SameC,R1,R2,T):-conflict(1,_,_,SameC,R1,R2,T).

%Conflict -> One Robot wants to go where another Robot is at the Timestep T -> Present 
conflict(0,C1,SameC,SameC,R1,R2,T):- moveto(C1,SameC,T),position(R1,C1,T),position(R2,SameC,T), not move(R2,_,T),conflicttype(0).
conflict(0,SameC,R1,R2,T):-conflict(0,_,_,SameC,R1,R2,T).

%Output
#show conflict/5.