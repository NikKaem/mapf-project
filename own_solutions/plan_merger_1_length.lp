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


#include "../encodings/action-M.lp"
#include "../encodings/input.lp"

%Conflict Predicate
% conflict( ID, Type, Cell, Robot1, Robot2, Timestep)

%Conflict -> Same Cell for two (or more) Robots in the same Timestep -> Future 
conflict(ID,Fut,SameC,R1,R2,T):- moveto(C1,SameC,T),moveto(C2,SameC,T),position(R1,C1,T),position(R2,C2,T),C1!=C2.

%Conflict -> One Robot wants to go where another Robot is at the Timestep T -> Present 
conflict(ID,Pre,SameC,R1,R2,T):- moveto(C1,SameC,T),position(R1,C1,T),position(R2,SameC,T), not move(R2,_,T).

