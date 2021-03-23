time(1..horizon).
col(0..horizon).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(DX,DY),(X',Y')) :- direction((DX,DY)), position((X,Y)), position((X',Y')),
                                 (X,Y)=(X'-DX,Y'-DY), (X',Y')=(X+DX,Y+DY).

%grabbing the input

robot(R)                     :- init(object(robot,R),          _).
shelf(S)                     :- init(object(shelf,S),          _).
station(P)                   :- init(object(pickingStation,P), _).
product(A)                   :- init(object(product,A),        _).


    isRobot(robot(R)) :- robot(R).
    isShelf(shelf(S)) :- shelf(S).
isStation(station(P)) :- station(P).
isProduct(product(A)) :- product(A).
    isOrder(order(O)) :- order(O).

  order(      O            ) :- init(object(order,O),          _).
ordered(order(O),product(A)) :- init(object(order,O),          value(line,(A,_))).      % IGNORING QUANTITIES
 target(order(O),station(P)) :- init(object(order,O),          value(pickingStation,P)).

shelved(shelf(S),product(A)) :- init(object(product,A),        value(on,(S,_))).        % IGNORING QUANTITIES

position(           (X,Y))   :- init(object(node,_),           value(at,(X,Y))).

position(station(P),(X,Y))   :- init(object(pickingStation,P), value(at,(X,Y))).

position(  robot(R),(X,Y),0) :- init(object(robot,R),          value(at,(X,Y))).
position(  shelf(S),(X,Y),0) :- init(object(shelf,S),          value(at,(X,Y))).

highway(            C    )   :- init(object(highway,_),        value(at,C)).

step_move(robot(R),D,T,0) :- occurs(object(robot, R), action(move,D), T).
step_pickup(robot(R),shelf(S),T,0) :- occurs(object(robot, R), action(pickup,object(shelf,S)), T).
step_putdown(robot(R),shelf(S),T,0) :- occurs(object(robot, R), action(putdown,object(shelf,S)), T).


%transfer the step_move with the highest collision depth to move/4, trying to have one move/4 per Robot per Time
move(R,D,T,N) :- step_move(R,D,T,N), collision(R,T-1,N).


%definning the collision variable

collision(R,T,N+1) :- wait(R,T), collision(R,T-1,N), horizon>T.
collision(R,T,N+1) :- dodge_who(R,_,T), collision(R,T-1,N), horizon>T.
collision(R,T,N+1) :- s_coll(R,T), collision(R,T-1,N), horizon>T.
collision(R,T,N+1) :- nmc_dodge(R,T), collision(R,T-1,N), horizon>T.
collision(R,T+1,N) :- collision(R,T,N), not collision(R,T+1,N+1), horizon>T.
collision(R,0,0) :- isRobot(R).



%COLLISION TYPE 1: 2 robots want to move to same field (vertex collision)
%SOLUTION: robot with highest ID needs to wait

%the first flag checks for the robot's collision depth. The one with greater depth has higher priority. the second flag is a tiebreaker based on robot ID in case both have the same col depth.
%not dodge_who(R2) because wait is not allowed to take precedence over a dodge command
wait(R2,T) :- move(R1,D1,T,N1), move(R2,D2,T,N2), position(R1,C1',T-1), N1>N2, nextto(C1',D1,C), position(R2,C2',T-1), nextto(C2',D2,C), not dodge_who(R2,_,T), not wait(R1,T).

%the not dodge_who(R1) is to make sure they don't wait for someone who isn't coming anyway because they had to dodge rather than move
wait(R2,T) :- move(R1,D1,T,N), move(R2,D2,T,N), position(R1,C1',T-1), R2>R1, nextto(C1',D1,C), position(R2,C2',T-1), nextto(C2',D2,C), not dodge_who(R2,_,T), not dodge_who(R1,_,T), not no_dodge(R2,T).

%introduce a wait for a robot waiting for its spot to be vacated by another robot who also triggered a wait
wait(R2,T) :- move(R2,(DX,DY),T,N), position(R2,C2',T-1), nextto(C2',(DX,DY),C), position(R1,C,T-1), wait(R1,T), not move(R1,(-DX,-DY),T,_).

%a new wait to work in tandem with the no_dodge flag (as seen in benchmark16 mod1), forcing the higher priority robot to wait in the edge case
wait(R1,T) :- move(R1,D1,T,_), move(R2,D2,T,_), position(R1,C1',T-1), R2>R1, nextto(C1',D1,C), position(R2,C2',T-1), nextto(C2',D2,C), no_dodge(R2,T).

%B-domain specific wait

wait(R2,T) :- move(R2,D,T,N1), pickup(R1,_,T), position(R1,C1,T-1), position(R2,C2,T-1), nextto(C2,D,C1), not nmc_dodge(R2,T).

wait(R2,T) :- move(R2,D,T,N1), putdown(R1,_,T), position(R1,C1,T-1), position(R2,C2,T-1), nextto(C2,D,C1), not nmc_dodge(R2,T).

%wait for shelf to come back

wait(R1,T) :- move(R1,D,T,N), step_pickup(R1,S,T+1,N), carries(_,S,T), collision(R1,T-1,N).



%COLLISION TYPE 2: 2 robots want to swap places (edge collision)
%SOLUTION: robot with higher ID needs to vacate its spot, then return to it in the next step
%FOUND PROBLEMS: if robot with higher priority stops on the new field, other robot needs to find a new path to goal, SOLUTION: nmc_dodge

%definition of the collision type
dodge_coll(R1,R2,T) :- move(R1,D1,T,N1), move(R2,D2,T,N2), position(R1,C1,T-1), R2>R1, nextto(C1,D1,C2), position(R2,C2,T-1), nextto(C2,D2,C1).

%calculate valid spots to dodge to
dodge_where(R1,D,T) :- dodge_coll(R1,R2,T), direction(D), nextto(C1,D,C1'), position(R1,C1,T-1), position(R2,C2,T-1), C1'!=C2, step_move(R2,D2,T+1,N2), D!=D2, collision(R2,T-1,N2).
dodge_where(R2,D,T) :- dodge_coll(R1,R2,T), direction(D), nextto(C2,D,C2'), position(R1,C1,T-1), position(R2,C2,T-1), C2'!=C1, step_move(R1,D2,T+1,N1), D!=D2, collision(R1,T-1,N1).

%in case the robot not dodging finishes before T+1
dodge_where(R1,D,T) :- dodge_coll(R1,R2,T), direction(D), nextto(C1,D,C1'), position(R1,C1,T-1), position(R2,C2,T-1), C1'!=C2, not step_move(R2,_,T+1,N2), collision(R2,T-1,N2).
dodge_where(R2,D,T) :- dodge_coll(R1,R2,T), direction(D), nextto(C2,D,C2'), position(R1,C1,T-1), position(R2,C2,T-1), C2'!=C1, not step_move(R1,_,T+1,N1), collision(R1,T-1,N1).

%if robot can't dodge
no_dodge(R1,T) :- not dodge_where(R1,_,T), dodge_coll(R1,R2,T), dodge_where(R2,_,T).
no_dodge(R2,T) :- not dodge_where(R2,_,T), dodge_coll(R1,R2,T), dodge_where(R1,_,T).
:- no_dodge(R,T), dodge_where(R,_,T).

%if found areas to dodge to are actually occupied by another robot
occ_dodge(R1,T) :- dodge_where(R1,(DX,DY),T), dodge_coll(R1,R2,T), position(R1,C1,T-1), position(R3,C3,T-1), nextto(C1,(DX,DY),C3), R3!=R2, R3!=R1, position(R4,C4,T-1), nextto(C1,(-DX,-DY),C4), R4!=R3, R4!=R2, R4!=R1, isRobot(R3), isRobot(R4).
occ_dodge(R2,T) :- dodge_where(R2,(DX,DY),T), dodge_coll(R1,R2,T), position(R2,C2,T-1), position(R3,C3,T-1), nextto(C2,(DX,DY),C3), R3!=R2, R3!=R1, position(R4,C4,T-1), nextto(C2,(-DX,-DY),C4), R4!=R3, R4!=R2, R4!=R1, isRobot(R3), isRobot(R4).

%if robots encounter each other in a tunnel and one has to dodge backwards
%doubled up here because our dodge_coll only checks for R2>R1; these are all possible first steps
back_dodge(R1,T) :- dodge_coll(R1,R2,T), not dodge_where(R1,_,T), not dodge_where(R2,_,T), collision(R1,T-1,N1), collision(R2,T-1,N2), N2>N1, not back_dodge(R2,T).
back_dodge(R1,T) :- dodge_coll(R1,R2,T), not dodge_where(R1,_,T), not dodge_where(R2,_,T), collision(R1,T-1,N), collision(R2,T-1,N), R1>R2, not back_dodge(R2,T).
back_dodge(R2,T) :- dodge_coll(R1,R2,T), not dodge_where(R1,_,T), not dodge_where(R2,_,T), collision(R1,T-1,N1), collision(R2,T-1,N2), N2<N1, not back_dodge(R1,T).
back_dodge(R2,T) :- dodge_coll(R1,R2,T), not dodge_where(R1,_,T), not dodge_where(R2,_,T), collision(R1,T-1,N), collision(R2,T-1,N), R1<R2, not back_dodge(R1,T).

%in case neither robot can dodge but for different reasons, the no_dodge robot gets higher priority and forces the other to dodge backwards
back_dodge(R2,T) :- dodge_coll(R1,R2,T), not dodge_where(R1,_,T), occ_dodge(R2,T).
back_dodge(R1,T) :- dodge_coll(R1,R2,T), not dodge_where(R2,_,T), occ_dodge(R1,T).

%these happen after one of the aforementioned first steps and are written in such a way that a robot that began going backwards keeps doing so
back_dodge(R1,T) :- dodge_coll(R1,R2,T), collision(R1,T-1,_), collision(R2,T-1,_), not dodge_where(R1,_,T), not dodge_where(R2,_,T), back_dodge(R1,T-1), not deadend(R1,T).
back_dodge(R2,T) :- dodge_coll(R1,R2,T), collision(R1,T-1,_), collision(R2,T-1,_), not dodge_where(R2,_,T), not dodge_where(R1,_,T),  back_dodge(R2,T-1), not deadend(R2,T).
back_dodge(R1,T) :- dodge_coll(R1,R2,T), back_dodge(R2,T-1), deadend(R2,T).
back_dodge(R2,T) :- dodge_coll(R1,R2,T), back_dodge(R1,T-1), deadend(R1,T).

%to prevent a deadlock in case a robot would dodge backwards into a tunnel where it has not way of dodging out of the way, like bench16 mod2
deadend(R1,T) :- dodge_coll(R1,R2,T), back_dodge(R1,T-1), move(R2,D,T,_), position(R1,C1,T-1), not nextto(C1,D,_).
deadend(R2,T) :- dodge_coll(R1,R2,T), back_dodge(R2,T-1), move(R1,D,T,_), position(R2,C2,T-1), not nextto(C2,D,_).

%deciding who dodges
%basic dodges, the robot with lower collision depth will be forced to dodge, or in case of equal col. depth the robot with higher ID
1{dodge_who(R1,D,T) : dodge_where(R1,D,T)}1 :- dodge_coll(R1,R2,T), N2>N1, collision(R1,T-1,N1), collision(R2,T-1,N2), not no_dodge(R1,T), not occ_dodge(R1,T), not no_dodge(R2,T), not back_dodge(R1,T), not back_dodge(R2,T).
1{dodge_who(R2,D,T) : dodge_where(R2,D,T)}1 :- dodge_coll(R1,R2,T), N1>=N2, collision(R1,T-1,N1), collision(R2,T-1,N2), not no_dodge(R1,T), not no_dodge(R2,T), not occ_dodge(R2,T), not back_dodge(R2,T), not back_dodge(R1,T).
%special case, where the robot with higher priority will dodge if the lower priority robot's spots are taken by other robots
1{dodge_who(R2,D,T) : dodge_where(R2,D,T)}1 :- dodge_coll(R1,R2,T), occ_dodge(R1,T), not no_dodge(R2,T).
1{dodge_who(R1,D,T) : dodge_where(R1,D,T)}1 :- dodge_coll(R1,R2,T), occ_dodge(R2,T), not no_dodge(R1,T).
%special case, where higher priority robot dodges, if lower priority robot can't dodge in the first place
1{dodge_who(R1,D,T) : dodge_where(R1,D,T)}1 :- dodge_coll(R1,R2,T), no_dodge(R2,T), not occ_dodge(R1,T).
1{dodge_who(R2,D,T) : dodge_where(R2,D,T)}1 :- dodge_coll(R1,R2,T), no_dodge(R1,T), not occ_dodge(R2,T).
%special case, where a robot has to "dodge backwards", say in a tunnel
dodge_who(R1,D,T) :- move(R2,D,T+1,N), dodge_coll(R1,R2,T), back_dodge(R1,T).
dodge_who(R2,D,T) :- move(R1,D,T+1,N), dodge_coll(R1,R2,T), back_dodge(R2,T).

%apply the dodge move to final move/3 in preparation of merge and insert a (step_)move back to the previously vacated spot from where to continue
move(R,D,T) :- dodge_who(R,D,T), collision(R,T-1,N).
step_move(R,(X1,Y1),T+1,N+1) :- dodge_who(R,(-X1,-Y1),T), collision(R,T-1,N), horizon>T.


%COLLISION TYPE 4: robot can't return to the spot it dodged from (M domain only)
%SOLUTION: reshuffling of 2 moves in the dodging robot, no move collision(nmc_dodge)

%define collsion type
nmc_dodge(R,T) :- dodge_who(R,_,T-1), position(R,C,T-1), move(R,D,T,N), collision(R,T-2,N-1), nextto(C,D,C'), position(R',C',T-1), not move(R',_,T,N'), collision(R',T-1,N').

%shifting of the moves, apply step_move that would have happened in T+1 to move in T, then apply the move that was supposed to return robot to vacated spot after
move(R,D,T) :- step_move(R,D,T+1,N), nmc_dodge(R,T), collision(R,T-1,N).
step_move(R,D,T+1,N+1):- step_move(R,D,T,N), nmc_dodge(R,T), collision(R,T-1,N).


%FINAL STEPS


%adjusting the plan in case of collisions(needing to include that T1 smaller horizon?)

%case wait
step_move(R,D,T1+1,N+1) :- step_move(R,D,T1,N), wait(R,T), collision(R,T-1,N),(T1+1)>T, horizon>T1.

step_pickup(R,S,T1+1,N+1) :- step_pickup(R,S,T1,N), wait(R,T), collision(R,T-1,N),(T1+1)>T, horizon>T1.

step_putdown(R,S,T1+1,N+1) :- step_putdown(R,S,T1,N), wait(R,T), collision(R,T-1,N),(T1+1)>T, horizon>T1.

%case dodge
step_move(R,D,T1+2,N+1) :- step_move(R,D,T1,N), dodge_who(R,_,T), (T1+1)>T, collision(R,T-1,N), horizon>(T1-1).

step_pickup(R,S,T1+2,N+1) :- step_pickup(R,S,T1,N), dodge_who(R,_,T), collision(R,T-1,N),(T1+1)>T, horizon>(T1-1).

step_putdown(R,S,T1+2,N+1) :- step_putdown(R,S,T1,N), dodge_who(R,_,T), collision(R,T-1,N),(T1+1)>T, horizon>(T1-1).

%case nmc_dodge

step_move(R,D,T1,N+1) :- step_move(R,D,T1,N), nmc_dodge(R,T), collision(R,T-1,N), T1>(T+1), horizon>T1.

step_pickup(R,S,T1,N+1) :- step_pickup(R,S,T1,N), nmc_dodge(R,T),  collision(R,T-1,N), T1>(T+1), horizon>T1.

step_putdown(R,S,T1,N+1) :- step_putdown(R,S,T1,N), nmc_dodge(R,T), collision(R,T-1,N), T1>(T+1), horizon>T1.

%shelf collision

s_coll(R,T) :- move(R,D,T,N), position(S',C',T-1), position(R,C,T-1), nextto(C,D,C'), carries(R,S,T-1), isShelf(S'), not carries(_,S',T), not nmc_dodge(R,T), collision(R,T-1,N).

1{move(R,D,T) : direction(D), D!=D'}1 :- s_coll(R,T), move(R,D',T,N), collision(R,T-1,N).




pickup(R,S,T) :- step_pickup(R,S,T,N), collision(R,T-1,N).
putdown(R,S,T) :- step_putdown(R,S,T,N), collision(R,T-1,N).



%defining move/3
move(R,D,T) :- move(R,D,T,N), not wait(R,T), not dodge_who(R,_,T), not s_coll(R,T), not nmc_dodge(R,T), not putdown(R,_,T), not pickup(R,_,T).

{  move(R,D,T,N) : direction(D);
   pickup(R,S,T) :   isShelf(S), not step_pickup(R',S,T',_), R'!=R, isRobot(R'), T'>T, time(T');
  putdown(R,S,T) :   isShelf(S)} 1 :- isRobot(R), time(T), not step_move(R,_,T,N), not step_pickup(R,_,T,N), not step_putdown(R,_,T,N), collision(R,T-1,N).



% - move/3 ----------------------------------------------------------------------
position(R,C,T) :- move(R,D,T), position(R,C',T-1),     nextto(C',D,C), time(T).
                :- move(R,D,T), position(R,C ,T-1), not nextto(C ,D,_).

% - pickup/3
carries(R,S,T)  :- pickup(R,S,T), time(T), position(R,C,T-1), position(S,C,T-1).

                :- pickup(R,S,T), carries(R,_,T-1).
                :- pickup(R,S,T), carries(_,S,T-1).
                :- pickup(R,S,T),  position(R,C,T-1), not position(S,C,T-1).
                :- pickup(R,S,T),  position(S,C,T-1), not position(R,C,T-1).
                
% - putdown/3
:- putdown(R,S,T), not carries(R,S,T-1).
:- putdown(R,S,T), position(R,C,T-1), position(_,C).
:- putdown(R,S,T), position(R,C,T-1), highway(C).

% - inertia ---------------------------------------------------------------------
position(R,C,T) :- position(R,C,T-1), not move(R,_,T), isRobot(R), time(T).
carries(R,S,T)  :- carries(R,S,T-1), not putdown(R,S,T), isRobot(R), isShelf(S), time(T).

% - (in)direct effects ----------------------------------------------------------
position(S,C,T) :- position(R,C,T  ),     carries(R,S,T), isShelf(S), time(T).
position(S,C,T) :- position(S,C,T-1), not carries(_,S,T), isShelf(S), time(T).

% - edge collision --------------------------------------------------------------
moveto(C',C,T) :- nextto(C',D,C), position(R,C',T-1), move(R,D,T).
 :- moveto(C',C,T), moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
 :- { position(R,C,T) : isRobot(R) }  > 1, position(C), time(T).
 :- { position(S,C,T) : isShelf(S) }  > 1, position(C), time(T).

% - auxiliaries -----------------------------------------------------------------
 :- { position(R,C,T) } != 1, isRobot(R), time(T).
 :- { position(S,C,T) } != 1, isShelf(S), time(T).

 :- { carries(R,S,T) } > 1, isRobot(R), time(T).
 :- { carries(R,S,T) } > 1, isShelf(S), time(T).
 
processed(A,R) :- ordered(O,A), shelved(shelf(S),A), isRobot(robot(R)), position(shelf(S),C,0), position(robot(R),C,horizon), R=S.
processed(A)   :- processed(A,R).

:- ordered(O,A), not processed(A).
:- not position(S,C,horizon), position(S,C,0), isShelf(S).
:- carries(_,_,horizon).
 
#show occurs'(object(robot,R), action(move,D),T) :    move(robot(R),D,T).
 

