import clingo
import os
import sys
import time
import csv
import pandas as pd
from pathlib import Path

PATH_MERGER = '../encodings/m/own-solutions'
PATH_BENCHMARKS = '../benchmarks'

ITERATIONS = 10

# Calls clingo to solve instance with specific merger approach
# Arguments: Path to the instance, Path to the approach, max amount of steps a robot is allowed to take
# Returns: List with a predicate for each element which describes the solution to the robot specific instance
def solve_instance_with_approach(path_to_benchmark, path_to_approach, horizon):

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

	start = time.time()
	
	solver.ground([('base', [])])
	solver.solve()

	end = time.time()

	return end-start

	
def benchmarking():
	
	solutions = pd.read_csv(PATH_BENCHMARKS + '/solutions_benchmarks.csv').filter(items=['benchmark','approach','horizon'])
	
	with open('desired_benchmarks.txt', 'r') as file:
		desired_benchmarks = [benchmark for benchmark in file.read().splitlines() if benchmark[0] != '#']
		
	with open('desired_approaches.txt', 'r') as file:
		desired_approaches = [approach for approach in file.read().splitlines() if approach[0] != '#']
	
	for approach in desired_approaches:

		path_to_approach = PATH_MERGER + '/' + approach

		for benchmark in desired_benchmarks:
			
			for i in range(0, ITERATIONS):

				path_to_benchmark = PATH_BENCHMARKS + '/' + benchmark
				
				# load solutions.csv and look up solution horizon for approach and benchmark
				try:
					solution_horizon = solutions.loc[solutions['benchmark'].str.contains(desired_benchmarks[0]) & solutions['approach'].str.contains(desired_approaches[0]), ['horizon']].values[0,0]
				except IndexError:
					break
				
				if solution_horizon == -1:
					break
					
				solution_time = solve_instance_with_approach(path_to_benchmark, path_to_approach, solution_horizon)
				
				with open(PATH_BENCHMARKS + '/stats_benchmarks.csv', 'a') as file:
					writer = csv.writer(file, lineterminator='\n')
					writer.writerow([approach, benchmark, solution_time])
	
benchmarking()
