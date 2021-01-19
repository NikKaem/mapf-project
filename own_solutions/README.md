## Our Solutions

Currently you can find two distinct programs that we created.
The first one being an conflict finder and the other one being an plan merger.

The conflict finder can be found in the directory "conflict_finder"
It takes two (or more) plans as input and outputs conflict predicates.
These predicates show where an conflict has occured and which type of conflict it is.
Currently we distinguish 2 types of conflicts (marked by 0 and 1 respectively).


The plan merger can be found in the directory "plan_merger_1".
It takes two (or more) plans as input and outputs a joint plan without conflicts.

Known Problems:
We are aware that in their current implementations both programs take a lot of time to run.
This will be changed in future releases.




Benchmarks:
Merger.lp
( clingo -opt-mode=optN -n0 )

Example Command: 
clingo --opt-mode=optN -n0 merger.lp "..\benchmarks\Easy\benchmark conflict square\plan_robot1.lp" "..\benchmarks\Easy\benchmark conflict square\plan_robot2.lp" -c horizon=0

Hardware: Marius E.V.A.-Build
Processor: AMD Ryzen 7 3800X 8-Core Processor 3,90 GHz
RAM: 16 GB
Windows 10 running Anaconda

Standard Horizon= 10 (Except if the reference Horizon is more than that)

| Instance Name  | Time | Models | Found Horizon (Minimum) |Reference Horizon |
| Own Benchmarks | ---- | -------|-------------------------| ------------- |
| Center Conflict  | 0.007s  | 1 | 2 |  2 |
| Conflict Square  | 0.023s  | 5 | 1???? | 2|
| Corridor  | 0.027s  | 5 | 1???? |  6 |

| Tarek| ---- | -------|-------------------------| ------------- |
| Center Conflict  | Content Cell  | Models | |
| Content Cell  | Content Cell  | Models| |

| Own Benchmarks | ---- | -------|-------------------------| ------------- |
| Center Conflict  | Content Cell  | Models | |
| Content Cell  | Content Cell  | Models| |

| Own Benchmarks | ---- | -------|-------------------------| ------------- |
| Center Conflict  | Content Cell  | Models | |
| Content Cell  | Content Cell  | Models| |

| Own Benchmarks | ---- | -------|-------------------------| ------------- |
| Center Conflict  | Content Cell  | Models | |
| Content Cell  | Content Cell  | Models| |

Producing plans for each robot
clingo "..\benchmarks\Easy\benchmark corridor\x3_y5_n10_r2_s2_ps1_pr2_u2_o2_N001.lp" ..\encodings\m\action-M.lp ..\encodings\m\goal-M.lp ..\encodings\m\output-M.lp --out-atomf='%s.' -V0 -c horizon=5

