#!/bin/bash

clingo --out-atomf="%s." -c horizon=2 ./encoding_plan_create.lp ./robot_1.lp | grep occurs > plan_r1.lp

clingo --out-atomf="%s." -c horizon=4 ./encoding_plan_create.lp ./robot_2.lp | grep occurs > plan_r2.lp
