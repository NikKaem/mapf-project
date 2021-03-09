import clingo
import time
import os
import csv
from pathlib import Path

# Prerequisits:
# - benchmark subfolders need to start with b -> advisable to call them 'benchmark*identification*'
# - folder including the merger approaches can only contain subfolders for different approaches
# - merger approaches need to be in separate folders and need to be called merger.lp

PATH_MERGER = '../encodings/m/own-solutions'
PATH_BENCHMARKS = '../benchmarks'

MAX_HORIZON = 25

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
def solve_instance_with_approach(path_to_benchmark, path_to_approach, horizon, mode):

	instance = '#const horizon=' + str(horizon) + '.\n'

	for f in os.listdir(path_to_benchmark):
		if f[len(f)-3:len(f)] == '.lp':
			with open(path_to_benchmark + '/' + f) as file:
				instance += file.read()

	with open(path_to_approach + '/merger.lp') as file:
		instance += file.read()

    # clingo solving and solution formatting
    # code is mostly copied from the group Hannes, Tom, Julian (https://github.com/tzschmidt/PlanMerger/blob/main/scripts/benchmark_engine/BenchmarkEngine/benchmark.py)
	solver = clingo.Control()
	solver.add('base', [], instance)
	
	if mode == 1:
		start = time.time()
		
		solver.ground([('base', [])])
		solution = solver.solve(yield_=True)

		end = time.time()

		res = ''
		with solution as handle:
			for m in handle:
				res = "{}".format(m)
			handle.get()

		return res.split(), end-start
	
	if mode==0:
		solver.ground([('base', [])])
		solver.solve()
		return int(solver.statistics['problem']['lp']['atoms'])


def iterate_until_solution(path_to_approach, path_to_benchmark):

	solution = []
	horizon = 0
	sum_time = 0
	while solution == []:

		horizon += 1

		if horizon > MAX_HORIZON:
			return [], -1, -1, -1

		print(path_to_approach, ' -------- ', path_to_benchmark, ' -------- horizon: ', horizon)
		solution, runtime = solve_instance_with_approach(path_to_benchmark, path_to_approach, horizon, 1)

		sum_time += runtime
		 
	statistics = solve_instance_with_approach(path_to_benchmark, path_to_approach, horizon, 0)
	
	return solution, sum_time, horizon, statistics


def solution_finder():

	with open('desired_benchmarks.txt', 'r') as file:
		desired_benchmarks = [benchmark for benchmark in file.read().splitlines() if benchmark[0] != '#']
		
	with open('desired_approaches.txt', 'r') as file:
		desired_approaches = [approach for approach in file.read().splitlines() if approach[0] != '#']

	for approach in desired_approaches:

		path_to_approach = PATH_MERGER + '/' + approach

		for benchmark in desired_benchmarks:

			path_to_benchmark = PATH_BENCHMARKS + '/' + benchmark

			solution, calc_time, solution_horizon, statistics = iterate_until_solution(path_to_approach, path_to_benchmark)

			with open(PATH_BENCHMARKS + '/solutions_benchmarks.csv', 'a') as file:
				writer = csv.writer(file, lineterminator='\n')
				writer.writerow([benchmark, approach, calc_time, solution_horizon, statistics])
			
			if solution != []:
				create_plan(solution, path_to_benchmark, approach)
	
solution_finder()
