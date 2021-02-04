#!/bin/bash

# Variables
HRZN=7

# generating plan for robot/order with id = 1
clingo $@ --outf=0 -V0 --out-atomf=%s. --quiet=1,2,2 -c horizon=${HRZN} -c rid=1 -c oid=1 asprilo-encodings/m/merge/encoding/encoding-m.lp lab/instance.lp | head -n1 > lab/individual_plans/plan_r1.lp

# generating plan for robot/order with id = 2
clingo $@ --outf=0 -V0 --out-atomf=%s. --quiet=1,2,2 -c horizon=${HRZN} -c rid=2 -c oid=2 asprilo-encodings/m/merge/encoding/encoding-m.lp lab/instance.lp | head -n1 > lab/individual_plans/plan_r2.lp

# merging individual plans
clingo $@ --outf=0 -V0 --out-atomf=%s. --quiet=1,2,2 asprilo-encodings/m/merge/merge.lp lab/individual_plans/{plan_r1.lp,plan_r2.lp} | head -n1 > lab/merged_plan.lp

# visualization
viz -t lab/instance.lp lab/merged_plan.lp


