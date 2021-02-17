import clingo
import os

# Path to the folder where all the benchmarks are stored
#
# Prerequisits:
# Each benchmark needs to be in a seperate folder which has to have a name starting with 'b'
#   -> advisable to call all the folders 'benchmark-**identification**'
# Instance file has to begin with 'x' and needs the fjle extension '.lp'
#   -> advisable to stick to the naming scheme from the guideline x_y_n_r_s_ps_pr_o.lp
# Instances should only contain one occur predicate for the robot (no energy specifications)
# Instances have to stick to the scheme where robot1 only picks product1 from shelf1 as order1 etc.
PATH_BENCHMARKS = '../benchmarks'

# Path to the folder where the standard clingo encodings are stored
PATH_ENCODINGS = '../encodings'


# Counts number of robots in one instance based on number of robot occurs
# -> doesn't work for energy specifications, might need to be changed to a different logic (e.g. RegEx)
# Arguments: Path to the instance
# Returns: Number of robots in the instance
def num_of_instance_robots(path):

    num = 0
    with open(path, 'r') as file:
        for line in file:
            # count every init(object(robot,..)) predicate
            if line.find('init(object(') != -1 and line[12] == 'r':
                num +=1

    return num


# Extracts every predicate which is relevant for the robot with robot_id and builds a string with it
# -> might be better to use proper RegEx to find relevant predicates
# Arguments: Path to the instance, ID of one instance robot
# Returns: String which includes every relevant predicate of robot with robot_id
def extract_single_robot_from_instance(path, robot_id):

    with open(path, 'r') as file:
        single_robot_instance = ''
        for line in file:
            # checks every init(object()) predicate for relevance
            if line.find('init(object(') != -1:
                # nodes and highways are relevant
                if line[12] == 'n' or line[12] == 'h':
                    single_robot_instance += line
                # robots, shelfs and orders are relevant as long as the robot_id is identical to the argument
                if (line[12] == 'r' or line[12] == 's' or line[12] == 'o') and line[18] == str(robot_id):
                    single_robot_instance += line
                # products are relevant as long as the robot_id is identical to the argument
                if line[12] == 'p' and line[20] == str(robot_id):
                    single_robot_instance += line

    return single_robot_instance


# Calls clingo to solve robot specific instance with standard encodings for the M domain
# Arguments: Path to the instance, max amount of steps a robot is allowed to take
# Returns: List with a predicate for each element which describes the solution to the robot specific instance
def solve_for_single_robot(instance, horizon):

    with open(PATH_ENCODINGS + '/m/goal-M.lp') as file:
        goal = file.read()
    with open(PATH_ENCODINGS + '/m/output-M.lp') as file:
        output = file.read()
    with open(PATH_ENCODINGS + '/m/action-M.lp') as file:
        # needs to skip the first line which is '#include input.lp' since this causes problems
        next(file)
        action = file.read()
    with open(PATH_ENCODINGS + '/input.lp') as file:
        input = file.read()

    # build benchmark string out of robot specific instance, encodings and the horizon constant
    benchmark = instance + goal + output + action + input + '#const horizon=' + str(horizon) + '.'

    # clingo solving and solution formatting
    # code is basically mirrored from the group Hannes, Tom, Julian (https://github.com/tzschmidt/PlanMerger/blob/main/scripts/benchmark_engine/BenchmarkEngine/benchmark.py)
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


# Creates a file with the name 'plan_robotX.lp' (with X being the robot_id) based on the moves clingo found
# Arguments: String which includes the occurs predicates from clingo, ID of the instance specific robot, path to the benchmark folder
# Returns: /
def create_single_plan_for_single_instance(instance_solution, robot_id, path):

    with open(path + '/plan_robot' + str(robot_id) + '.lp', 'w') as file:
        for predicate in instance_solution:
            # only copy the moves the robot takes into the plan file
            if (predicate[0] == 'o'):
                file.write(predicate + '.\n')


# Creates a file with the name 'plan_robotX.lp' (with X being the robot_id) based on the moves clingo found
# Arguments: String which includes the occurs predicates from clingo, ID of the instance specific robot, path to the benchmark folder
# Returns: /
def create_all_plans_for_single_instance(path):

    # find the instance file (named x_y_...) in the specific benchmark folder and expand the path to it
    for file in os.listdir(path):
        if file[0] == 'x' and file[len(file)-3:len(file)] == '.lp':
            path_instance = path + '/' + file

    # iterates over every robot specified in the instance
    for i in range(0, num_of_instance_robots(path_instance)):

        # robot_id starts at 1
        robot_id = i+1

        # if a plan already exists for this robot skip it
        if 'plan_robot' + str(robot_id) + '.lp' in os.listdir(path):
            continue

        # generate robot specific instance
        instance = extract_single_robot_from_instance(path_instance, robot_id)

        # iterate over the horizon constant until a solution is found by clingo (=> list is not empty)
        solution = []
        horizon = 1
        while solution == []:
            solution = solve_for_single_robot(instance, horizon)
            horizon += 1

        create_single_plan_for_single_instance(solution, robot_id, path)


# Iterates over every subfolder of the benchmark folder and calls for the plan creation function
# Arguments: /
# Returns: /
def create_all_plans_for_every_instance():

    for dir in os.listdir(PATH_BENCHMARKS):
        if dir[0] == 'b':
            create_all_plans_for_single_instance(PATH_BENCHMARKS + '/' + dir)


create_all_plans_for_every_instance()
