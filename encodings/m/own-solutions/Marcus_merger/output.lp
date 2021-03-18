%#show.
%#show init/2.

#show occurs(object(robot,R), action(move,D),     T) :    move(robot(R),D,T).
%#show occurs(object(robot,R), action(pickup,object(shelf,S)),   T) :    pickup(robot(R),shelf(S),T).
%#show occurs(object(robot,R), action(putdown,object(shelf,S)),  T) :    putdown(robot(R),shelf(S),T).
