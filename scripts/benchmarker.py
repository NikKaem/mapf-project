import clingo
import os
import sys
import time
import pandas as pd
from pathlib import Path

# Prerequisits:
# - benchmark subfolders need to start with b -> advisable to call them 'benchmark*identification*'
# - folder including the merger approaches can only contain subfolders for different approaches
# - merger approaches need to be in seperate folders and need to be called merger.lp


PATH_MERGER = '../encodings/m/own-solutions'
PATH_BENCHMARKS = '../benchmarks'

MAX_HORIZON = 25
ITERATIONS = 10

# transform each occurs'() predicate
# the apostrophe will be removed
# a full stop will be added to the end of each element
# create a new file with the transformed occurs() predicates
# generate occurs() array through transform_occurs and read_occurs
# put each occurs() predicate into a new line
def create_plan(array, path, approach):

    path_to_solution = path + '/solution/' + approach
    Path(path_to_solution).mkdir(parents=True, exist_ok=True)

    with open(path_to_solution + '/merged_plan.lp', 'w') as file:
        for occur in array:
            occur = occur[:6] + occur[7:]
            file.write(occur + '.\n')


# Calls clingo to solve instance with specific merger approach
# Arguments: Path to the instance, Path to the approach, max amount of steps a robot is allowed to take
# Returns: List with a predicate for each element which describes the solution to the robot specific instance
def solve_instance_with_approach(instance, approach, horizon):

    benchmark = '#const horizon=' + str(horizon) + '.\n'

    for f in os.listdir(instance):
        if f[len(f)-3:len(f)] == '.lp':
            with open(instance + '/' + f) as file:
                benchmark += file.read()

    with open(approach + '/merger.lp') as file:
        benchmark += file.read()

    # clingo solving and solution formatting
    # code is mostly copied from the group Hannes, Tom, Julian (https://github.com/tzschmidt/PlanMerger/blob/main/scripts/benchmark_engine/BenchmarkEngine/benchmark.py)
    solver = clingo.Control()
    solver.add('base', [], benchmark)

    start = time.time()
    solver.ground([('base', [])])
    solution = solver.solve(yield_=True)

    # can read out statistics with solver.statistics -> returns dict
    end = time.time()

    res = ''
    with solution as handle:
            for m in handle:
                res = "{}".format(m)
            handle.get()

    return res.split(), end-start


def iterate_until_solution(path_to_approach, path_to_benchmark, starting_horizon):

    horizon = starting_horizon
    solution = []
    sum_time = 0
    while solution == []:

        horizon += 1

        if horizon > MAX_HORIZON:
            return [], -1, -1, -1

        print(path_to_approach, ' -------- ', path_to_benchmark, ' -------- horizon: ', horizon)
        solution, runtime = solve_instance_with_approach(path_to_benchmark, path_to_approach, horizon)

        sum_time += runtime


    return solution, runtime, sum_time, horizon


# Counts number of robots in one instance based on number of robot occurs
# -> doesn't work for energy specifications, might need to be changed to a different logic (e.g. RegEx)
# Arguments: Path to the instance
# Returns: Number of robots in the instance
def num_of_instance_robots(path):

    num = 0
    for f in os.listdir(path):
        if f[0] == 'p':
            num +=1

    return num


def supervisor(args):

    if args[1] != '0':
        desired_benchmarks = ['benchmark-' + args[1]]
    else :
        desired_benchmarks = [folder for folder in os.listdir(PATH_BENCHMARKS) if folder[0] == 'b']

    if args[2] != '0':
        desired_approaches = [args[2]]
    else:
        desired_approaches = [folder for folder in os.listdir(PATH_MERGER)]

    if args[1] == '0' and args[2] == '0':
        amount = ITERATIONS
        to_csv = True
    else:
        amount = 1

    measurements = pd.DataFrame(columns=['benchmark', 'solution_time', 'calculation_time', 'solution_horizon', 'number_of_robots', 'attempt'])

    for approach in desired_approaches:

        path_to_approach = PATH_MERGER + '/' + approach

        row_counter = 0
        for benchmark in desired_benchmarks:

			solution_horizon = 0
			calc_time = 0
            for i in range(0, amount):

                data = [None] * 6

                path_to_benchmark = PATH_BENCHMARKS + '/' + benchmark

                num_robots = num_of_instance_robots(path_to_benchmark)

                if approach == 'iterative-conflict-resolution' and num_robots > 2:
                    solution = []
                    solution_time = -1
                    calc_time = -1
                    solution_horizon = -1
                else:
					if i == 0:
                    	solution, solution_time, calc_time, solution_horizon = iterate_until_solution(path_to_approach, path_to_benchmark, 0)
					else:
						solution, solution_time = iterate_until_solution(path_to_approach, path_to_benchmark, solution_horizon-1)

                data[0] = benchmark
                data[1] = solution_time
                data[2] = calc_time
                data[3] = solution_horizon
                data[4] = num_robots

                measurements.loc[row_counter] = data
                row_counter += 1

                if solution_time == -1:
                    break

            create_plan(solution, path_to_benchmark, approach)

        if to_csv:
            measurements.to_csv(path_to_approach + '/data.csv')

supervisor(sys.argv)
