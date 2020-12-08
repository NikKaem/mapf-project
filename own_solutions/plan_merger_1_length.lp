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
init(object([object type], [object ID]), value(at, ([X], [Y]))).
init(object(robot, [robot ID]), value(carries, [shelf ID]))).
init(object(robot, [robot ID]), value(max_energy, [max energy])).
init(object(robot, [robot ID]), value(energy, [energy])).
init(object(robot, [robot ID]), value(energy_cost, ([action], [energy cost]))).
init(object(order, [order ID]), value(line, ([product ID], [product amount]))).
init(object(order, [order ID]), value(line, ([product ID])).
init(object(order, [order ID]), value(pickingStation, [picking station ID])).
init(object(product, [product ID]), value(on, ([shelf ID], [product amount]))).

#include "../asprillo-encodings/action-M.lp"
#include "../asprillo-encodings/input.lp"

