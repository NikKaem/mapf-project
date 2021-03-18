%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 5
%Grid size Y: 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.
#const horizon=4.

%init
init(object(node, 11), value(at, (1, 3))).
init(object(node, 7), value(at, (2, 2))).
init(object(node, 12), value(at, (2, 3))).
init(object(node, 17), value(at, (2, 4))).
init(object(node, 23), value(at, (3, 5))).
init(object(node, 18), value(at, (3, 4))).
init(object(node, 13), value(at, (3, 3))).
init(object(node, 8), value(at, (3, 2))).
init(object(node, 3), value(at, (3, 1))).
init(object(node, 9), value(at, (4, 2))).
init(object(node, 14), value(at, (4, 3))).
init(object(node, 19), value(at, (4, 4))).
init(object(node, 15), value(at, (5, 3))).
init(object(highway, 12), value(at, (2, 3))).
init(object(highway, 13), value(at, (3, 3))).
init(object(highway, 8), value(at, (3, 2))).
init(object(highway, 14), value(at, (4, 3))).
init(object(highway, 18), value(at, (3, 4))).
init(object(highway, 7), value(at, (2, 2))).
init(object(highway, 17), value(at, (2, 4))).
init(object(highway, 19), value(at, (4, 4))).
init(object(highway, 9), value(at, (4, 2))).
init(object(robot,3), value(at,(5,3))).
init(object(robot,3), value(max_energy,0)).
init(object(robot,3), value(energy,0)).
init(object(shelf,3), value(at,(1,3))).
init(object(product,3),value(on,(3,1))).
init(object(order,3),value(pickingStation,0)).
init(object(order,3),value(line,(3,1))).
