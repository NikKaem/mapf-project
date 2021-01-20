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
clingo --opt-mode=optN -n0 merger_wip.lp "..\benchmarks\Easy\benchmark conflict square\plan_robot1.lp" "..\benchmarks\Easy\benchmark conflict square\plan_robot2.lp" -c horizon=0

Hardware: Marius E.V.A.-Build
Processor: AMD Ryzen 7 3800X 8-Core Processor 3,90 GHz
RAM: 16 GB
Windows 10 running Anaconda

Standard Horizon= iteratively increasing horizon (Found Horizon is minimum)

Merger.lp
| Instance Name  | Time | Models | Found Horizon (Minimum) |Reference Horizon |
| Own Benchmarks | ---- | -------|-------------------------| ------------- |
| Center Conflict  | 0.007s  | 1 | 2 |  2 |
| Conflict Square  | 0.023s  | 5 | 1???? | 2|
| Corridor  | 0.027s  | 5 | 1???? |  6 |


Merger_wip.lp
| Instance Name   | Time    | Models | Found Horizon (Minimum) |Reference Horizon |
| Own Benchmarks  | ------  | -------|-------------------------| -------------    |
| Center Conflict | 0.008s  | 1      | 3                       |  2               |
| Conflict Square | 0.009s  | 1      | 9                       |  2               |
| Corridor        | 0.010s  | 1      | 11                      |  6               |
| other side      | 0.844s  | 89     | 15                      |  8               |

| Tarek           |         |        |                         |                  |
| forced waiting  | 0.011s  | 1      | 14                      |  9               |
|forced waiting v2| 0.012s  | 1      | 15???                   | 16               |
|mov obstacles    | 0.018s  | 2      | 12                      | 11               |

|Tom Julian Hannes|         |        |                         |                  |
| vertex level 1  | 0.008s  | 1      | 5                       |  5   note1       |
| edge level 1    | 0.006s  | 1      | 4                       |  1   note2       |
|mult vertex lev3 | 68.275s | 12825+ | 10                      |  1   note2       |
|mult edge level3 | 0.432s  | 151    | 11                      |  2   note2       |
|mult wait level2 | 0.006s  | 1      | 4                       |  3   note1       |

note1= We found this ourselves as the authors did not include a reference.
note2= Found ourselves, but asprillo auto assigns shelfs.

Producing plans for each robot (Our Solutions)
clingo "..\benchmarks\Easy\benchmark corridor\x3_y5_n10_r2_s2_ps1_pr2_u2_o2_N001.lp" ..\encodings\m\action-M.lp ..\encodings\m\goal-M.lp ..\encodings\m\output-M.lp --out-atomf='%s.' -V0 -c horizon=5
Producing Plans for each robot (other solutions)
clingo instance.lp "E:\Programme\Github\Asprillo main\mapf-project\encodings\m\action-M.lp" "E:\Programme\Github\Asprillo main\mapf-project\encodings\m\goal-M.lp" "E:\Programme\Github\Asprillo main\mapf-project\encodings\m\output-M.lp" --out-atomf='%s.' -V0 -c horizon=7
