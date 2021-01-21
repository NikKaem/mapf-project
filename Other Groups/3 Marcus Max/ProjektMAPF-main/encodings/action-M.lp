#include "./input.lp".

time(1..horizon).
col(0..horizon).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(DX,DY),(X',Y')) :- direction((DX,DY)), position((X,Y)), position((X',Y')),
                                 (X,Y)=(X'-DX,Y'-DY), (X',Y')=(X+DX,Y+DY).

step_move(robot(R),D,T,0) :- plan_occurs(object(robot, R), action(move,D), T).

%transfering the step_move with highest col dept to move/4, trying to only having one move/4 per R per T

move(R,D,T,N) :- step_move(R,D,T,N), collision(R,T-1,N).

 
collision(R,T,N+1) :- wait(R,T,N).
collision(R,T,N+1) :- dodge_who(R,_,T,N).
collision(R,T,N+1) :- nmc_dodge(R,T,N).
collision(R,T,N+1) :- frd_where(R,_,T,N).
collision(R,T+1,N) :- collision(R,T,N), not collision(R,T+1,N+1), horizon>T.
collision(R,0,0) :- isRobot(R).


%replaced by line 21 because more compact
%collision(R,T+1,N) :- collision(R,T,N), not wait(R,T,N), not dodge_who(R,_,T,N), horizon>(T-1), not nmc_dodge(R,T,N), not frd_where(R,_,T,N).


%COLLISION TYPE: 2 robots want to move to same field
%SOLVING: robot with highest ID needs to wait

wait(R2,T,N2) :- move(R1,D1,T,N1), move(R2,D2,T,N2), position(R1,C1',T-1), R2>R1, nextto(C1',D1,C), position(R2,C2',T-1), nextto(C2',D2,C).


%COLLISION TYPE: 2 robots want to swap places
%SOLVING: robot with highest ID needs to dodge, moving it onto the same field in the next timestep
%EXPECTED PROBLEMS: if robot with lower ID stops on the new field, needs to find a new path, solved via nmc_dodge


dodge_coll(R1,R2,T,N1,N2) :- move(R1,D1,T,N1), move(R2,D2,T,N2), position(R1,C1,T-1), R2>R1, nextto(C1,D1,C2), position(R2,C2,T-1), nextto(C2,D2,C1).

dodge_where(R1,D,T) :- dodge_coll(R1,R2,T,N1,N2), direction(D), nextto(C1,D,C1'), position(R1,C1,T-1), position(R2,C2,T-1), C1'!=C2, step_move(R2,D2,T+1,N2), D!=D2.

dodge_where(R2,D,T) :- dodge_coll(R1,R2,T,N1,N2), direction(D), nextto(C2,D,C2'), position(R1,C1,T-1), position(R2,C2,T-1), C2'!=C1, step_move(R1,D2,T+1,N1), D!=D2.

%if no step_move/4 exists in T+1, use below

dodge_where(R1,D,T) :- dodge_coll(R1,R2,T,N1,N2), direction(D), nextto(C1,D,C1'), position(R1,C1,T-1), position(R2,C2,T-1), C1'!=C2, not step_move(R2,_,T+1,N2).

dodge_where(R2,D,T) :- dodge_coll(R1,R2,T,N1,N2), direction(D), nextto(C2,D,C2'), position(R1,C1,T-1), position(R2,C2,T-1), C2'!=C1, not step_move(R1,_,T+1,N1).


1{dodge_who(R1,D,T,N1) : dodge_where(R1,D,T)}1 :- dodge_coll(R1,_,T,N1,N2), N2>N1.
1{dodge_who(R2,D,T,N2) : dodge_where(R2,D,T)}1 :- dodge_coll(_,R2,T,N1,N2), N1>=N2.

move(R,D,T) :- dodge_who(R,D,T,N).
step_move(R,(X1,Y1),T+1,N+1) :- dodge_who(R,(-X1,-Y1),T,N), horizon>T.

%COLLISION: robot y dodges, but robot x finishes on the return field (m domain only)
%SOLUTION: swapping return and next step_move
%NoMoveCollision_dodge = nmc_dodge

nmc_dodge(R1,T,N) :- dodge_coll(R1,R2,T-1,_,_), position(R1,C1,T-1), move(R1,D,T,N), position(R2,C2,T-1), not step_move(R2,_,T,_), nextto(C1,D,C2).

nmc_dodge(R2,T,N) :- dodge_coll(R1,R2,T-1,_,_), position(R1,C1,T-1), move(R2,D,T,N), position(R2,C2,T-1), not step_move(R1,_,T,_), nextto(C2,D,C1).

move(R,D,T) :- step_move(R,D,T+1,N), nmc_dodge(R,T,N).
step_move(R,D,T+1,N+1) :- step_move(R,D,T,N), nmc_dodge(R,T,N).

%COLLISION: robot x finishes in path of robot y (m domain only)
%SOLUTION: letting the finished robot dodge
%FinishedRobot_dodge = fr_dodge; frd is flag to test if other doges exist

frd(R1,R2,T,N1,N2) :- not dodge_coll(R1,R2,T1,N1,N2), time(T1), T1=T, not nmc_dodge(R2,T2,N), time(T2), T2=T, not nmc_dodge(R1,T3,N), time(T3), T3=T, isRobot(R1), isRobot(R2), collision(R2,T-1,N2), collision(R1,T-1,N1), col(N), R2>R1.

fr_dodge(R1,R2,T,N1,N2) :- frd(R1,R2,T,N1,N2), move(R2,D2,T,N2), position(R1,C1,T-1), position(R2,C2,T-1), nextto(C2,D2,C1), not step_move(R1,_,T,_).

fr_dodge(R2,R1,T,N2,N1) :- frd(R1,R2,T,N1,N2), move(R1,D1,T,N1), position(R1,C1,T-1), position(R2,C2,T-1), nextto(C1,D1,C2), not step_move(R2,_,T,_).

%Rd: Robot who dodges; RM: robot who moves normally; ND, NM their respective collision dept

1{frd_where(RD,D,T,ND) : direction(D), nextto(C1,D,C1'), position(RD,C1,T-1), position(RM,C2,T-1), C1'!=C2, step_move(RM,D2,T+1,NM), D!=D2}1 :- fr_dodge(RD,RM,T,ND,NM).

move(R,D,T) :- frd_where(R,D,T,_).
step_move(R,(X1,Y1),T+1,N+1) :- frd_where(R,(-X1,-Y1),T,N), horizon>T.


%COLLISION: robot x is forced to dodge backwards, in direction of plan of robot y
%SOLUTION: WIP


%adjusting the plan(needing to include that T1 smaller horizon?

step_move(R,D,T1+1,N+1) :- step_move(R,D,T1,N), wait(R,T,N), (T1+1)>T, horizon>T1.
step_move(R,D,T1+2,N+1) :- step_move(R,D,T1,N), dodge_who(R,_,T,N), (T1+1)>T, horizon>(T1-1).
step_move(R,D,T1,N+1) :- step_move(R,D,T1,N), nmc_dodge(R,T,N), T1>(T+1), horizon>T1.


%defining move/3

move(R,D,T) :- move(R,D,T,N), not wait(R,T,N), not dodge_who(R,_,T,N), not nmc_dodge(R,T,N), not frd_where(R,_,T,N).



% - move/3 ----------------------------------------------------------------------
position(R,C,T) :- move(R,D,T), position(R,C',T-1), nextto(C',D,C), not wait(R,T,_).
                :- move(R,D,T), position(R,C ,T-1), not nextto(C ,D,_).

% - inertia ---------------------------------------------------------------------
position(R,C,T) :- position(R,C,T-1), not move(R,_,T), isRobot(R), time(T).

% - edge collision --------------------------------------------------------------
moveto(C',C,T) :- nextto(C',D,C), position(R,C',T-1), move(R,D,T).
 :- moveto(C',C,T), moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
 :- { position(R,C,T) : isRobot(R) }  > 1, position(C), time(T).

% - auxiliaries -----------------------------------------------------------------
 :- { position(R,C,T) } != 1, isRobot(R), time(T).    % REDUNDANT but PERFORMANT?
 
