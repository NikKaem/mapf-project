


processed(A,R) :- ordered(O,A), shelved(shelf(S),A), isRobot(robot(R)), position(shelf(S),C,0), position(robot(R),C,horizon), R=S.
processed(A)   :- processed(A,R).

:- ordered(O,A), not processed(A).
:- not position(S,C,horizon), position(S,C,0), isShelf(S).
:- carries(_,_,horizon).
