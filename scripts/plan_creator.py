import clingo
import os

PATH_BENCHMARKS = '../benchmarks'
PATH_ENCODINGS = '../encodings'

def num_of_instance_robots(path):

    num = 0
    with open(path, 'r') as file:
        for line in file:
            if line.find('init(object(') != -1 and line[12] == 'r':
                num +=1

    return num


def extract_single_robot_from_instance(path, robot_id):

    with open(path, 'r') as file:
        single_robot_instance = ''
        for line in file:
            if line.find('init(object(') != -1:
                if line[12] == 'n' or line[12] == 'h':
                    single_robot_instance += line
                if (line[12] == 'r' or line[12] == 's' or line[12] == 'o') and line[18] == str(robot_id):
                    single_robot_instance += line
                if line[12] == 'p' and line[20] == str(robot_id):
                    single_robot_instance += line

    return single_robot_instance


def solve_for_single_robot(instance, horizon):

    with open(PATH_ENCODINGS + '/m/goal-M.lp') as file:
        goal = file.read()
    with open(PATH_ENCODINGS + '/m/output-M.lp') as file:
        output = file.read()
    with open(PATH_ENCODINGS + '/m/action-M.lp') as file:
        next(file)
        action = file.read()
    with open(PATH_ENCODINGS + '/input.lp') as file:
        input = file.read()

    benchmark = instance + goal + output + action + input + '#const horizon=' + str(horizon) + '.'

    solver = clingo.Control()
    solver.add('base', [], benchmark)
    solver.ground([('base', [])])
    solution = solver.solve(yield_=True)

    res = ''
    with solution as handle:
            for m in handle:
                res = "{}".format(m)
            handle.get()

    return res.split()


def create_single_plan_for_single_benchmark(benchmark_solution, robot_id, path):

    with open(path + '/plan_robot' + str(robot_id) + '.lp', 'w') as file:
        for predicate in benchmark_solution:
            if (predicate[0] == 'o'):
                file.write(predicate + '\n')


def create_all_plans_for_single_benchmark(path):

    for file in os.listdir(path):
        if file[0] == 'x' and file[len(file)-3:len(file)] == '.lp':
            path_benchmark = path + '/' + file

    for i in range(0, num_of_instance_robots(path_benchmark)):

        robot_id = i+1

        if 'plan_robot' + str(robot_id) + '.lp' in os.listdir(path):
            continue

        instance = extract_single_robot_from_instance(path_benchmark, robot_id)

        solution = []
        horizon = 1
        while solution == []:
            solution = solve_for_single_robot(instance, horizon)
            horizon += 1

        create_single_plan_for_single_benchmark(solution, robot_id, path)


def create_all_plans_for_every_benchmark():

    for dir in os.listdir(PATH_BENCHMARKS):
        if dir[0] == 'b':
            create_all_plans_for_single_benchmark(PATH_BENCHMARKS + '/' + dir)

create_all_plans_for_every_benchmark()
