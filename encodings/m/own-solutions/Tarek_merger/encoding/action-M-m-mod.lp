% - move/3 ----------------------------------------------------------------------
position(robot(R),C,T) :- move(robot(R),D,T), position(robot(R),C',T-1), nextto(C',D,C).
:- move(robot(R),D,T), position(robot(R),C,T-1), not nextto(C,D,_).

% - inertia ---------------------------------------------------------------------
position(robot(R),C,T) :- position(robot(R),C,T-1), not move(robot(R),_,T), isRobot(robot(R)), time(T).

% - edge collision --------------------------------------------------------------
moveto(C',C,T) :- nextto(C',D,C), position(robot(R),C',T-1), move(robot(R),D,T).
:- moveto(C',C,T), moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
:- { position(robot(R),C,T) : isRobot(robot(R)) }  > 1, position(C), time(T).

% - auxiliaries -----------------------------------------------------------------
:- { position(robot(R),C,T) } != 1, isRobot(robot(R)), time(T).    % REDUNDANT but PERFORMANT?
%--------------------------------------------------------------------------------


% - random_move/3 ----------------------------------------------------------------------
random_position(robot(R),C,T) :- random_move(robot(R),D,T), random_position(robot(R),C',T-1), nextto(C',D,C).
:- random_move(robot(R),D,T), random_position(robot(R),C,T-1), not nextto(C,D,_).
% - inertia ---------------------------------------------------------------------
random_position(robot(R),C,T) :- random_position(robot(R),C,T-1), not random_move(robot(R),_,T), isRobot(robot(R)), random_time(T).

% - edge collision --------------------------------------------------------------
random_moveto(C',C,T) :- nextto(C',D,C), random_position(robot(R),C',T-1), random_move(robot(R),D,T).
:- random_moveto(C',C,T), random_moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
:- { random_position(robot(R),C,T) : isRobot(robot(R)) }  > 1, position(C), random_time(T).

% - auxiliaries -----------------------------------------------------------------
:- { random_position(robot(R),C,T) } != 1, isRobot(robot(R)), random_time(T).   % REDUNDANT but PERFORMANT?
%--------------------------------------------------------------------------------
