% IMPORT
% import constant for solving
%#const rm=16.
% import modified action-M.lp
#include "./encoding/action-M-m-mod.lp".

% import of needed information of robots
robot(R) :- init(object(robot,R),_).
isRobot(robot(R)) :- robot(R).

% import positions and moves
position((X,Y)) :- init(object(node,N),value(at,(X,Y))).
move_im(robot(R),D,T) :- occurs(object(robot,R),action(move,D),T). 
% import first position of each robot
position_im(robot(R),(X,Y),0) :- init(object(robot,R),value(at,(X,Y))).
position_im(robot(R),(X+DX,Y+DY),T+1) :- occurs(object(robot,R),action(move,(DX,DY)),T+1), position_im(robot(R),(X,Y),T).

% MISC
% define directions
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
direction((0,0)).
% define nextto statement
nextto((X,Y),(DX,DY),(X',Y')) :- direction((DX,DY)), position((X,Y)), position((X',Y')), (X,Y)=(X'-DX,Y'-DY), (X',Y')=(X+DX,Y+DY).

% TIME MANAGEMENT
% set time for new plan dynamically
% starting with the first collision
time(1..T+1) :- first_collision(T).
% and ending with the new horizon
time(T+1..(R+S)) :- first_collision(T), max_range(R,_), steps(S,_).

% set time for randomly generated moves
random_time((T')..(T'+P)) :- first_collision(T'), P=rm.

% determine max time
1{max_time(T): time(T), time(T'), T>=T'}1 :- time(_).
:- max_time(T), time(T), time(T'), T<T'.
% determine range of each robot
1{max_range(T,robot(R)): position_im(robot(R),_,T), position_im(robot(R),_,T'), T>=T'}1 :- position_im(robot(R),_,_).
:- max_range(T,robot(R)), position_im(robot(R),_,T), position_im(robot(R),_,T'), T<T'.

% COLLISION DETECTION
% robots want to enter the same node simultaneously
collision((X,Y),T,robot(R),robot(R')) :- position_im(robot(R),(X,Y),T), position_im(robot(R'),(X,Y),T), R!=R', not collision((X,Y),T,robot(R'),robot(R)).

% robots want to switch places
collision((X,Y),T,robot(R),robot(R')) :- position_im(robot(R),(X,Y),T), position_im(robot(R'),(X',Y'),T), position_im(robot(R),(X',Y'),T+1), position_im(robot(R'),(X,Y),T+1), R!=R', not collision(_,T,robot(R'),robot(R)).

% one robot standing still (might need a rework)
collision((X,Y),T,R,R') :- position_im(robot(R),(X,Y),T'), position_im(robot(R'),(X,Y),T), not position_im(robot(R),_,T'+P), S=T-T', P=1..S, T'<T, R!=R'.

% find first collison
1{first_collision(T): collision(_,T,_,_), collision(_,T',_,_), T<=T'}1 :- collision(_,_,_,_).
:- first_collision(T), collision(_,T,_,_), collision(_,T',_,_), T>T'.


% PLAN ADOPTING
% adopt plans if there aren't any collisions any collisions
move(robot(R),D,T) :- move_im(robot(R),D,T), not collision(_,_,_,_).

% adopt plan for all robots until T' (first collision)
move(robot(R),D,T) :- move_im(robot(R),D,T), first_collision(T'), T<T'.
position(robot(R),C,T) :- position_im(robot(R),C,T), first_collision(T'), T<T'.

% MOVE GENERATION
% set first random positions to one timestep before the first collision
random_position(robot(R),C,T-1) :- position(robot(R),C,T-1), first_collision(T).
% generate random movement
{ random_move(robot(R),D,T) : direction(D) } :- random_time(T), isRobot(robot(R)), first_collision(T'), T>=T'.

% CHECKPOINTS
% set checkpoints
% set checkpoint after collision, if goal is far away
checkpoint(C,robot(R),1) :-  position_im(robot(R),C,T+1), first_collision(T), max_range(T',robot(R)), T'-T>=4.
% set checkpoint at goal if its near
checkpoint(C,robot(R),2) :-  position_im(robot(R),C,T'), first_collision(T), max_range(T',robot(R)), T'-T<4.
:- checkpoint(C,robot(R),2), not position(robot(R),C,T), max_time(T).
:- checkpoint(C,robot(R),1), not position(robot(R),C,_).
% calculate and minimize steps for each robot
steps(S,robot(R)) :- random_position(robot(R),C,T), checkpoint(C,robot(R),_), first_collision(T'), S=T-(T'-1).
#minimize {S: steps(S,_) }.

% set movement according to amount of steps
move(robot(R),D,T) :- random_move(robot(R),D,T), steps(S,robot(R)), first_collision(T'), T<=(T'-1)+S.
% adopt original plan after that
move(robot(R),D,T+S-2) :- move_im(robot(R),D,T), steps(S,robot(R)), first_collision(T'), checkpoint(_,robot(R),1), T>T'+1.

% restrictions to robot movement and positioning
:- move(robot(R),D,T), move(robot(R),D',T), D!=D'.
:- random_move(robot(R),D,T), random_move(robot(R),D',T), D!=D'.
:- position(robot(R),C,_), isRobot(robot(R)), not position(C).
:- position(robot(R),C,T), position(robot(R'),C,T), R!=R'.
:- random_position(robot(R),C,_), isRobot(robot(R)), not position(C).
:- random_position(robot(R),C,T), random_position(robot(R'),C,T), R!=R'.
:- position(robot(R),C,T), position_im(robot(R),C',T'), max_time(T), max_range(T',robot(R)), C!=C'.

#show.
#show occurs'(object(robot,R),action(move,D),T) : move(robot(R),D,T).
