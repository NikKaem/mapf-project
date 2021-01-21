% moving_obstacles.lp
% horizon=11

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 9
%Grid size Y: 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

%init
init(object(node, 2), value(at, (2, 1))).
init(object(node, 11), value(at, (2, 2))).
init(object(node, 20), value(at, (2, 3))).
init(object(node, 29), value(at, (2, 4))).
init(object(node, 38), value(at, (2, 5))).
init(object(node, 47), value(at, (2, 6))).
init(object(node, 3), value(at, (3, 1))).
init(object(node, 12), value(at, (3, 2))).
init(object(node, 21), value(at, (3, 3))).
init(object(node, 30), value(at, (3, 4))).
init(object(node, 39), value(at, (3, 5))).
init(object(node, 48), value(at, (3, 6))).
init(object(node, 4), value(at, (4, 1))).
init(object(node, 13), value(at, (4, 2))).
init(object(node, 22), value(at, (4, 3))).
init(object(node, 31), value(at, (4, 4))).
init(object(node, 40), value(at, (4, 5))).
init(object(node, 49), value(at, (4, 6))).
init(object(node, 5), value(at, (5, 1))).
init(object(node, 14), value(at, (5, 2))).
init(object(node, 23), value(at, (5, 3))).
init(object(node, 32), value(at, (5, 4))).
init(object(node, 41), value(at, (5, 5))).
init(object(node, 50), value(at, (5, 6))).
init(object(node, 6), value(at, (6, 1))).
init(object(node, 15), value(at, (6, 2))).
init(object(node, 24), value(at, (6, 3))).
init(object(node, 33), value(at, (6, 4))).
init(object(node, 42), value(at, (6, 5))).
init(object(node, 51), value(at, (6, 6))).
init(object(node, 7), value(at, (7, 1))).
init(object(node, 16), value(at, (7, 2))).
init(object(node, 25), value(at, (7, 3))).
init(object(node, 34), value(at, (7, 4))).
init(object(node, 43), value(at, (7, 5))).
init(object(node, 52), value(at, (7, 6))).
init(object(node, 8), value(at, (8, 1))).
init(object(node, 26), value(at, (8, 3))).
init(object(node, 35), value(at, (8, 4))).
init(object(node, 44), value(at, (8, 5))).
init(object(node, 53), value(at, (8, 6))).
init(object(node, 9), value(at, (9, 1))).
init(object(node, 18), value(at, (9, 2))).
init(object(node, 27), value(at, (9, 3))).
init(object(node, 36), value(at, (9, 4))).
init(object(node, 45), value(at, (9, 5))).
init(object(node, 54), value(at, (9, 6))).
init(object(node, 10), value(at, (1, 2))).
init(object(node, 19), value(at, (1, 3))).
init(object(node, 28), value(at, (1, 4))).
init(object(node, 37), value(at, (1, 5))).
init(object(node, 46), value(at, (1, 6))).
init(object(node, 1), value(at, (1, 1))).
init(object(node, 17), value(at, (8, 2))).
init(object(highway, 4), value(at, (4, 1))).
init(object(highway, 6), value(at, (6, 1))).
init(object(highway, 14), value(at, (5, 2))).
init(object(highway, 49), value(at, (4, 6))).
init(object(highway, 41), value(at, (5, 5))).
init(object(highway, 51), value(at, (6, 6))).
init(object(highway, 52), value(at, (7, 6))).
init(object(highway, 53), value(at, (8, 6))).
init(object(highway, 44), value(at, (8, 5))).
init(object(highway, 47), value(at, (2, 6))).
init(object(highway, 38), value(at, (2, 5))).
init(object(highway, 2), value(at, (2, 1))).
init(object(highway, 11), value(at, (2, 2))).
init(object(highway, 10), value(at, (1, 2))).
init(object(highway, 9), value(at, (9, 1))).
init(object(highway, 18), value(at, (9, 2))).
init(object(highway, 8), value(at, (8, 1))).
init(object(highway, 17), value(at, (8, 2))).
init(object(highway, 7), value(at, (7, 1))).
init(object(highway, 15), value(at, (6, 2))).
init(object(highway, 16), value(at, (7, 2))).
init(object(highway, 42), value(at, (6, 5))).
init(object(highway, 43), value(at, (7, 5))).
init(object(highway, 3), value(at, (3, 1))).
init(object(highway, 12), value(at, (3, 2))).
init(object(highway, 48), value(at, (3, 6))).
init(object(highway, 39), value(at, (3, 5))).
init(object(highway, 40), value(at, (4, 5))).
init(object(highway, 13), value(at, (4, 2))).
init(object(highway, 20), value(at, (2, 3))).
init(object(highway, 19), value(at, (1, 3))).
init(object(highway, 28), value(at, (1, 4))).
init(object(highway, 29), value(at, (2, 4))).
init(object(highway, 27), value(at, (9, 3))).
init(object(highway, 36), value(at, (9, 4))).
init(object(highway, 35), value(at, (8, 4))).
init(object(highway, 26), value(at, (8, 3))).
init(object(highway, 23), value(at, (5, 3))).
init(object(highway, 32), value(at, (5, 4))).
init(object(robot,1), value(at,(1,6))).
init(object(robot,1), value(max_energy,0)).
init(object(robot,1), value(energy,0)).
init(object(robot,2), value(at,(9,6))).
init(object(robot,2), value(max_energy,0)).
init(object(robot,2), value(energy,0)).
init(object(robot,3), value(at,(5,1))).
init(object(robot,3), value(max_energy,0)).
init(object(robot,3), value(energy,0)).
init(object(robot,4), value(at,(1,5))).
init(object(robot,4), value(max_energy,0)).
init(object(robot,4), value(energy,0)).
init(object(shelf,1), value(at,(7,3))).
init(object(product,1),value(on,(1,1))).
init(object(shelf,2), value(at,(3,3))).
init(object(product,2),value(on,(2,2))).
init(object(shelf,3), value(at,(5,6))).
init(object(product,3),value(on,(3,3))).
init(object(shelf,4), value(at,(9,5))).
init(object(product,4),value(on,(4,4))).
init(object(pickingStation,1), value(at,(1,1))).
init(object(order,1),value(pickingStation,1)).
init(object(order,1),value(line,(1,1))).
init(object(order,2),value(pickingStation,1)).
init(object(order,2),value(line,(2,2))).
init(object(order,3),value(pickingStation,1)).
init(object(order,3),value(line,(3,3))).
init(object(order,4),value(pickingStation,1)).
init(object(order,4),value(line,(4,4))).




% plans for robot 3 and 4
move(robot(4),(1,0),1).
move(robot(4),(1,0),2). 
move(robot(4),(1,0),3). 
move(robot(3),(0,1),1). 
move(robot(3),(0,1),2). 
move(robot(3),(0,1),3). 
occurs(object(robot,4),action(move,(1,0)),1). 
occurs(object(robot,4),action(move,(1,0)),2). 
occurs(object(robot,4),action(move,(1,0)),3). 
occurs(object(robot,3),action(move,(0,1)),1). 
occurs(object(robot,3),action(move,(0,1)),2). 
occurs(object(robot,3),action(move,(0,1)),3). 
position(robot(4),(2,5),1). 
position(robot(4),(3,5),2). 
position(robot(4),(4,5),3). 
position(robot(3),(5,2),1). 
position(robot(3),(5,3),2). 
position(robot(3),(5,4),3). 
position(robot(3),(5,1),0). 
position(robot(4),(1,5),0). 
occurs(object(robot,4),action(move,(1,0)),4). 
occurs(object(robot,4),action(move,(1,0)),5). 
occurs(object(robot,4),action(move,(1,0)),6). 
occurs(object(robot,4),action(move,(1,0)),7). 
occurs(object(robot,4),action(move,(1,0)),8). 
position(robot(4),(5,5),4). 
position(robot(4),(6,5),5). 
position(robot(4),(7,5),6). 
position(robot(4),(8,5),7). 
position(robot(4),(9,5),8). 
move(robot(3),(0,1),5). 
move(robot(3),(0,1),6). 
move(robot(4),(1,0),4). 
move(robot(4),(1,0),5). 
move(robot(4),(1,0),6). 
move(robot(4),(1,0),7). 
move(robot(4),(1,0),8). 
occurs(object(robot,3),action(move,(0,1)),5). 
occurs(object(robot,3),action(move,(0,1)),6). 
position(robot(3),(5,4),4). 
position(robot(3),(5,5),5).
