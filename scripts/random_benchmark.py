import numpy as np
import os
import sys
from pathlib import Path

PATH = '../benchmarks'

# code is mostly copied from the group Hannes, Tom, Julian (https://github.com/tzschmidt/PlanMerger/blob/main/scripts/benchmark_engine/BenchmarkEngine/benchmark.py)
# we just added orders, products and a way to output it as an instance file

def gen_benchmark_data(size_x, size_y, n_robots, random_seed=None):
	if size_x * size_y > n_robots * 2:
		robot_pos = []
		shelf_pos = []
		if random_seed:
			np.random.seed(random_seed)

	for n in range(n_robots):
		not_unique_pos = True
		while not_unique_pos:
			r_pos = [np.random.randint(1, size_x + 1), np.random.randint(1, size_y + 1)]
			s_pos = [np.random.randint(1, size_x + 1), np.random.randint(1, size_y + 1)]
			if (r_pos not in robot_pos + shelf_pos) and (s_pos not in shelf_pos + robot_pos) and r_pos != s_pos:
				not_unique_pos = False
		robot_pos.append(r_pos)
		shelf_pos.append(s_pos)

	name = 'x' + str(size_x) + '_y' + str(size_y) + '_n' + str(size_x*size_y) +	'_r' + str(n_robots) + '_s' + str(n_robots) + '_ps' + str(0) + '_pr' + str(n_robots) + '_u' + str(n_robots) + '_o' + str(n_robots) + '.lp'

	return (size_x, size_y), robot_pos, shelf_pos, name

def format_output(map, robot_pos, shelf_pos):
	nodes_str = []
	robots_str = []
	shelves_str = []
	products_str = []
	orders_str = []
	i = 1
	for x in range(map[0]):
		for y in range(map[1]):
			nodes_str.append(f'init(object(node,{i}),value(at,({x + 1},{y + 1}))).')
			i += 1

	for i in range(0, len(robot_pos)):
		robots_str.append(f'init(object(robot,{i + 1}),value(at,({robot_pos[i][0]},{robot_pos[i][1]}))).')
		shelves_str.append(f'init(object(shelf,{i + 1}),value(at,({shelf_pos[i][0]},{shelf_pos[i][1]}))).')
		products_str.append(f'init(object(product,{i + 1}),value(on,({i + 1},1))).')
		orders_str.append(f'init(object(order,{i + 1}),value(line,({i + 1},1))).')

	return '\n'.join(nodes_str) + '\n' + '\n'.join(robots_str) + '\n' + '\n'.join(shelves_str) + '\n' + '\n'.join(products_str) + '\n' + '\n'.join(orders_str)

def output(instance, name):
	benchmarks = os.listdir(PATH)
	amount = len(benchmarks) - 2

	Path(PATH + '/benchmark-' + str(amount+1)).mkdir(parents=True, exist_ok=True)

	with open(PATH + '/benchmark-' + str(amount+1) + '/' + name, 'w') as file:
		file.write(instance)

size_x = sys.argv[1]
size_y = sys.argv[2]
n_rob = sys.argv[3]

map, robots, shelves, name = gen_benchmark_data(int(size_x),int(size_y),int(n_rob))
instance = format_output(map, robots, shelves)

output(instance, name)
