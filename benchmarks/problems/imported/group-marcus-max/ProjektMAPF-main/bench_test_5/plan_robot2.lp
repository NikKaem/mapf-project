occurs(object(robot,2),action(move,(0,1)),1). 
occurs(object(robot,2),action(move,(0,1)),2). 
occurs(object(robot,2),action(move,(0,1)),3). 
occurs(object(robot,2),action(move,(0,1)),4).

%init
init(object(node, 12), value(at, (2, 3))).
init(object(node, 3), value(at, (3, 1))).
init(object(node, 8), value(at, (3, 2))).
init(object(node, 13), value(at, (3, 3))).
init(object(node, 18), value(at, (3, 4))).
init(object(node, 23), value(at, (3, 5))).
init(object(node, 14), value(at, (4, 3))).
init(object(node, 15), value(at, (5, 3))).
init(object(node, 11), value(at, (1, 3))).
init(object(highway, 14), value(at, (4, 3))).
init(object(highway, 13), value(at, (3, 3))).
init(object(highway, 8), value(at, (3, 2))).
init(object(highway, 12), value(at, (2, 3))).
init(object(highway, 18), value(at, (3, 4))).
init(object(robot,2), value(at,(3,1))).
init(object(robot,2), value(max_energy,0)).
init(object(robot,2), value(energy,0)).
init(object(shelf,2), value(at,(3,5))).
init(object(product,2),value(on,(2,1))).
init(object(order,2),value(pickingStation,0)).
init(object(order,2),value(line,(2,1))).
