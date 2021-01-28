import os
import matplotlib.pyplot as plt
import numpy as np
import webbrowser

colors = ['red', 'blue', 'yellow', 'green', 'purple', 'pink', 'orange', 'grey', 'lime', 'black']


class Benchmark:

    def __init__(self, *inp, verbose=0):

        if len(inp) == 1:
            path = inp[0]
            self.path = path
            
            self.name = path.split('/')[-1]
            inits, robot_movements, instance = self.read_benchmark_files(path)
            #print(inits)
            # initialise the dictionaries (self.robots and self.shelves) and the lists (self.nodes, self.highways)
            self.robots, self.shelves, self.nodes, self.highways = self.format_benchmark_inits(inits)
            #print(self.format_benchmark_inits(inits))
            # initialise the dictionary self.original_plans which contains the original plans movements
            self.original_plans = self.format_benchmark_movements(robot_movements)

            # Fill the original plans with [0,0] movements at the timesteps where there is not movement
            self.original_plans = self.get_filled_plans(self.original_plans)
            
            h = self.get_benchmark_horizon(instance)
            if h == -1:
                raise RuntimeError("Bechmark Format Error : The Benchmark hast to contain a time horizon in the form"
                                   "(#const horizon=[0>h])")
            self.horizon = h

            if verbose:
                print(f"nodes: {self.nodes}")
                print(f"highways: {self.highways}")
                print(f"shelves: {self.shelves}")
                print(f"robots: {self.robots}")
                print(f"original plans: {self.original_plans}")
                self.plot()

        else:
            raise ValueError("Benchmarks can only be initialised with either (benchmark_path) or "
                             "(inits, robot_movements) as parameters")

        """
        elif len(inp) == 2:
            inits = inp[0]
            robot_movements = inp[1]
            # initialise the dictionaries (self.robots and self.shelves) and the lists (self.nodes, self.highways)
            self.robots, self.shelves, self.nodes, self.highways = self.format_benchmark_inits(inits)
            # initialise the dictionary self.original_plans which contains the original plans movements
            self.original_plans = self.format_benchmark_movements(robot_movements)

            # Fill the original plans with [0,0] movements at the timesteps where there is not movement
            self.original_plans = self.get_filled_plans(self.original_plans)

            if verbose:
                print(f"nodes: {self.nodes}")
                print(f"highways: {self.highways}")
                print(f"shelves: {self.shelves}")
                print(f"robots: {self.robots}")
                print(f"original plans: {self.original_plans}")
                self.plot()
        """

    @staticmethod
    def read_benchmark_files(path):
        instance, plans = Benchmark.import_benchmark(path)
        
        #print(Benchmark.split_statements(instance))
        inits = Benchmark.split_statements(instance)['init']
        robot_movements = []
        for i, plan in enumerate(plans):
            robot_movements += Benchmark.split_statements(plan)['occurs']
        return inits, robot_movements, instance

    @staticmethod
    def import_benchmark(path):
        if os.path.isdir(path):
            if os.path.isdir(path + "/full_instance") and os.path.isdir(path + "/plans"):
                first_lp_instance = list(filter(lambda x: x.endswith('.lp'), os.listdir(path + '/full_instance')))[0]
                f = open(f"{path}/full_instance/{first_lp_instance}", "r")
                instance = f.read()
                f.close()

                plans = []
                for plan in os.listdir(path + "/plans"):
                    if plan.split('.')[-1] == 'lp':
                        f = open(f"{path}/plans/{plan}", "r")
                        plans.append(f.read().replace('\n', ' '))
                        f.close()

                return instance.replace('\n', ' '), plans
            else:
                raise ValueError(
                    "The given directory structure for the selected benchmark is incompatible with this programm")
                # Not the correct Benchmark structure
        else:
            raise ValueError("Cannot find the directory given")
            # Not the right path selected

    @staticmethod
    def split_statements(strng):
        res = {}
        strng_split = strng.split()
        for s in strng_split:
            if s.endswith('.'):
                open_b_count = s.count('(')
                closed_b_count = s.count(')')
                if open_b_count and open_b_count == closed_b_count:
                    s_content = ')'.join(('('.join(s.split('(')[1:])).split(')')[:-1])
                    if s.split('(')[0] in res:
                        res[s.split('(')[0]].append(s_content)
                    else:
                        res[s.split('(')[0]] = [s_content]
        return res

    @staticmethod
    def get_benchmark_horizon(strng):
        horizon = -1
        strng_split = strng.split()
        for s in strng_split:
            if s.endswith('.'):
                if 'horizon' in s:
                    horizon = int(s.split('=')[-1][:-1])
        
        return horizon

    @staticmethod
    def format_benchmark_inits(inits):
        # [robots, shelves, nodes, highways]
        res = [{}, {}, [], []]

        for init in inits:
            name = Benchmark.get_object_name(init)
            #print(name)
            if name[0] == 'robot':
                res[0][int(name[1])] = Benchmark.get_object_value(init)
            elif name[0] == 'shelf':
                res[1][int(name[1])] = Benchmark.get_object_value(init)
            elif name[0] == 'node':
                res[2].append(Benchmark.get_object_value(init))
            elif name[0] == 'highway':
                res[3].append(Benchmark.get_object_value(init))

        return res[0], res[1], res[2], res[3]

    @staticmethod
    def format_benchmark_movements(robot_movements):
        res = {}
        for movement in robot_movements:
            time_step = int(movement.split(',')[-1])
            action = ','.join(movement.split(',')[:-1])

            name = Benchmark.get_object_name(action)
            if int(name[1]) in res:
                res[int(name[1])].append([time_step, Benchmark.get_object_value(action)])
            else:
                res[int(name[1])] = [[time_step, Benchmark.get_object_value(action)]]
        return res

    @staticmethod
    def get_object_name(strng):
        return strng.split('(')[1].split(')')[0].split(',')

    @staticmethod
    def get_object_value(strng):
        val_str = (')'.join(strng.split(')')[1:]))[1:]
        val_content_str = ('('.join(val_str.split('(')[1:]))[:-1]
        values_str = ','.join(val_content_str.split(',')[1:])
        return [int(val) for val in values_str[1:-1].split(',')]

    @staticmethod
    def get_filled_plans(plans):
        filled_plans = plans
        max_t = max(max([[move[0] for move in plan] for plan in list(filled_plans.values())], key=lambda x: max(x)))
        for robot_id in list(filled_plans.keys()):
            plan = filled_plans[robot_id]
            plan_sorted = sorted(plan, key=lambda x: x[0])

            for t in range(1, max_t):
                # insert missing [0,0] movements at timesteps where there is no movement (in between)
                if plan_sorted[t - 1][0] != t:
                    plan_sorted = plan_sorted[:t - 1] + [[t, [0, 0]]] + plan_sorted[t - 1:]
                # insert missing [0,0] movements at timesteps where there is no movement
                # (at the end if t still smaller than max_t)
                elif t == len(plan_sorted) and t < max_t:
                    plan_sorted = plan_sorted + [[t, [0, 0]]]
            filled_plans[robot_id] = plan_sorted
        return filled_plans

    def calculate_plan_positions(self, plan, robot_id):
        plan_sorted = sorted(plan, key=lambda x: x[0])
        
        start_pos = self.robots[robot_id]

        times = [0]
        positions = [start_pos]
        pos = np.array(start_pos)
        for move in plan_sorted:
            pos += np.array(move[1])
            times.append(move[0])
            positions.append(list(pos))
        return times, np.array(positions)

    def check_solution(self, plans):
        position_data = []
        max_t = - np.inf
        for plan in list(zip(plans.keys(), plans.values())):
            time, pos = self.calculate_plan_positions(plan[1], plan[0])
            position_data.append(pos)
            if max(time) > max_t:
                max_t = max(time)
        position_data = np.array(position_data)

        vertex_conflicts = self.get_vertex_conflicts(position_data)
        edge_conflicts = self.get_edge_conflicts(position_data)
        invalid_movements = self.get_invalid_movements(position_data)

        conflicts = {'vertex_conflicts': vertex_conflicts, 'edge_conflicts': edge_conflicts}
        return not vertex_conflicts and not edge_conflicts, conflicts, invalid_movements, max_t

    def get_invalid_movements(self, position_data):
        invalid_movements = []
        for robot_id, plan_pos in enumerate(position_data):
            for t, pos in enumerate(plan_pos):
                if list(pos) not in self.nodes:
                    invalid_movements.append([t, pos])
        return invalid_movements

    @staticmethod
    def get_vertex_conflicts(position_data):
        vertex_conflicts = []
        # for each robot's plan go through every step and compare with the other robots positions
        for robot_id, plan_pos in enumerate(position_data):
            for t, pos in enumerate(plan_pos):
                for other_plan in np.concatenate((position_data[:robot_id], position_data[robot_id + 1:])):
                    # check if the robot and any of the other robots are at the same place at the same time
                    if (pos == other_plan[t]).all():
                        conflicts_tmp = [[c[0], list(c[1])] for c in vertex_conflicts]
                        if [t, list(pos)] not in conflicts_tmp:
                            vertex_conflicts.append([t, pos])
        return vertex_conflicts

    @staticmethod
    def get_edge_conflicts(position_data):
        edge_conflicts = []
        # for each robot's plan go through every step and compare with the other robots positions
        for robot_id, plan_pos in enumerate(position_data):
            for t, pos in enumerate(plan_pos):
                for other_plan in np.concatenate((position_data[:robot_id], position_data[robot_id + 1:])):
                    # check if the robot and any of the other robots are switching positions
                    if t + 1 < len(other_plan):
                        if (pos == other_plan[t + 1]).all():
                            if t + 1 < len(plan_pos):
                                if (plan_pos[t + 1] == other_plan[t]).all():
                                    # check if the edge conflict is not already detected, but from the other robot
                                    conflicts_tmp = [[c[0], list(c[1]), list(c[2])] for c in edge_conflicts]
                                    if [t, list(other_plan[t]), list(pos)] not in conflicts_tmp:
                                        edge_conflicts.append([t, pos, other_plan[t]])
        return edge_conflicts

    @staticmethod
    def read_movements_from_file(path):
        if os.path.isfile(path):
            if path.endswith('.lp'):
                f = open(path, "r")
                plans = f.read()
                f.close()

                robot_movements = Benchmark.split_statements(plans)['occurs']
                moves = Benchmark.format_benchmark_movements(robot_movements)
                res = Benchmark.get_filled_plans(moves)

                return res

    def plot(self, plans=None, original_plans=True, scale_factor=1, show_text=True, edge_conflicts=None,
             vertex_conflicts=None, save_path=None):
        np_nodes = np.array(self.nodes)
        max_x = np_nodes[:, 0].max()
        max_y = np_nodes[:, 1].max()

        fig, ax = plt.subplots(figsize=(max_x * 3 * scale_factor, max_y * 2 * scale_factor))
        ax.set_xlim(0, max_x)
        ax.set_ylim(0, max_y)
        ax.grid()
        ax.set_xticks(list(range(max_x + 1)))
        ax.set_yticks(list(range(max_y + 1)))
        # plt.gca().set_xticklabels([])
        # plt.gca().set_yticklabels([])

        for node in self.nodes:
            if node not in self.highways:
                rectangle = plt.Rectangle((node[0] - 1, node[1] - 1), 1, 1, fc='blue', alpha=0.125)
                ax.add_patch(rectangle)

        for highway in self.highways:
            rectangle = plt.Rectangle((highway[0] - 1, highway[1] - 1), 1, 1, fc='green', alpha=0.125)
            ax.add_patch(rectangle)

        for robot in list(zip(self.robots.keys(), self.robots.values())):
            ax.scatter(robot[1][0] - 0.5, robot[1][1] - 0.5, s=(10 ** 3.5) * scale_factor, c=colors[robot[0] - 1],
                       marker='s', alpha=0.5)
            if scale_factor >= 0.5 and show_text:
                ax.annotate(f'robot {robot[0]}', (robot[1][0] - 0.63, robot[1][1] - 0.53))

        for shelf in list(zip(self.shelves.keys(), self.shelves.values())):
            ax.scatter(shelf[1][0] - 0.5, shelf[1][1] - 0.5, s=(10 ** 3.5) * scale_factor, c=colors[shelf[0] - 1],
                       marker='o', alpha=0.5)
            if scale_factor >= 0.5 and show_text:
                ax.annotate(f'shelf {shelf[0]}', (shelf[1][0] - 0.62, shelf[1][1] - 0.53))

        if original_plans:
            for plan in list(zip(self.original_plans.keys(), self.original_plans.values())):
                times, positions = self.calculate_plan_positions(plan[1], plan[0])
                ax.plot(positions.T[0] - 0.5, positions.T[1] - 0.5, c=colors[plan[0] - 1], alpha=0.125,
                        linewidth=5 * scale_factor,
                        marker='o')

        if plans:
            for plan in list(zip(plans.keys(), plans.values())):
                times, positions = self.calculate_plan_positions(plan[1], plan[0])
                ax.plot(positions.T[0] - 0.5, positions.T[1] - 0.5, c=colors[plan[0] - 1], alpha=0.25,
                        linewidth=15 * scale_factor,
                        marker='o', markersize=15 * scale_factor)

        if edge_conflicts:
            print('plotting edges')
            for conflict in edge_conflicts:
                pos = [(conflict[1][0] + conflict[2][0]) / 2, (conflict[1][1] + conflict[2][1]) / 2]
                ax.scatter(pos[0] - 0.5, pos[1] - 0.5, s=(10 ** 3) * scale_factor, c='red', marker='$[EC]$', alpha=0.75)

        if vertex_conflicts:
            for conflict in vertex_conflicts:
                ax.scatter(conflict[1][0] - 0.5, conflict[1][1] - 0.5, s=(10 ** 3) * scale_factor, c='red',
                           marker='$[VC]$', alpha=0.75)

        if save_path:
            print(f'saving plot at {save_path}')
            plt.savefig(save_path)
        else:
            plt.show()


class BenchmarkBinder:

    def __init__(self):
        self.benchmarks = []

    def add_benchmark(self, benchmark):
        self.benchmarks.append(benchmark)

    def add_benchmark_from_path(self, path):
        self.benchmarks.append(Benchmark(path))

    def remove_benchmark(self, index):
        if 0 <= index < len(self.benchmarks):
            del self.benchmarks[index]

    def get_benchmarks(self):
        return self.benchmarks

    def evaluate(self, plans):
        # TODO : implement the plan generation here also with time tracking for the calculation time and remove the
        #        actually unnecessary plans parameter
        if len(plans) == len(self.benchmarks) > 0:
            # Remove all of the old plot images in the output/imgs folder
            image_list = [f for f in os.listdir('E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\imgs') if f.endswith(".png")]
            for f in image_list:
                os.remove(os.path.join('E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\imgs', f))

            conflict_list = []
            name_list = []
            path_list = []
            image_paths = []
            invalid_movement_list = []
            in_horizon_list = []
            for i, benchmark in enumerate(self.benchmarks):
                print(benchmark.name)
                _, conflicts, invalid_movements, max_t = benchmark.check_solution(plans[i])
                conflict_list.append(conflicts)
                name_list.append(benchmark.name)
                path_list.append(benchmark.path)
                invalid_movement_list.append(invalid_movements)
                in_horizon_list.append(max_t <= benchmark.horizon)
                #image_path=os.path.dirname((os.path.dirname(os.path.dirname(os.path.dirname(os.getcwd())))))
                #print(image_path)
                #image_path = image_path + "\output\imgs\b_{1}.png"
                #image_path=f"E:\Programme\Github\output\imgs\img_{i}.png"
                image_path=f"E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\imgs\img_{i}.png"
                print(image_path )
                benchmark.plot(vertex_conflicts=conflicts['vertex_conflicts'], edge_conflicts=conflicts['edge_conflicts'],
                               save_path=image_path, plans=plans[i])
                image_paths.append(image_path)

            self.output_html(conflict_list, name_list, path_list, image_paths, invalid_movement_list, in_horizon_list)

            html_file_path = '/'.join(os.path.realpath(__file__).split('/')[:-2]) + '/output/out.html'
            self.open_html_file(html_file_path)
        else:
            raise ValueError("The Benchmark Binder is either empty or the length of plans is not equal to the length of"
                             "the Benchmark Binder")

    @staticmethod
    def open_html_file(path):
        url = f"file://{path}"
        #webbrowser.register('firefox',constructor=, preferred=True)
        # new=2 to open in a new tab, if possible
        webbrowser.get("C:\Program Files\Mozilla Firefox\firefox.exe %s").open(url, new=2)

    @staticmethod
    def output_html(results, names, paths, image_paths, invalid_movements, in_horizon):
        if len(results) == len(names) == len(paths) == len(image_paths) == len(invalid_movements) == len(in_horizon):
            f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\quick.html", "r")
            quick = f.read()
            f.close()

            out = []
            quick_list = []
            for result_index in range(len(results)):
                f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\ertex_conflict.html", "r")
                vc_template = f.read()
                f.close()

                f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\edge_conflict.html", "r")
                ec_template = f.read()
                f.close()

                vcs = []
                #print(results[result_index]['vertex_conflicts'])
                for vc in results[result_index]['vertex_conflicts']:
                    tmp = vc_template.replace('{{ X }}', f'{vc[1][0]}')
                    tmp = tmp.replace('{{ Y }}', f'{vc[1][1]}')
                    tmp = tmp.replace('{{ T }}', f'{vc[0]}')
                    vcs.append(tmp)

                ecs = []
                
                for ec in results[result_index]['edge_conflicts']:
                    tmp = ec_template.replace('{{ X1 }}', f'{ec[1][0]}')
                    tmp = tmp.replace('{{ Y1 }}', f'{ec[1][1]}')
                    tmp = tmp.replace('{{ X2 }}', f'{ec[2][0]}')
                    tmp = tmp.replace('{{ Y2 }}', f'{ec[2][1]}')
                    tmp = tmp.replace('{{ T }}', f'{ec[0]}')
                    ecs.append(tmp)

                ims = []
                for im in invalid_movements[result_index]:
                    tmp = vc_template.replace('{{ X }}', f'{im[1][0]}')
                    tmp = tmp.replace('{{ Y }}', f'{im[1][1]}')
                    tmp = tmp.replace('{{ T }}', f'{im[0]}')
                    ims.append(tmp)

                quick_with_id = quick.replace('{{ B INDEX }}', f'{result_index + 1}')

                f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\enchmark.html", "r")
                b_template = f.read()
                f.close()

                benchmark_out = b_template.replace('{{ VERTEX CONFLICTS }}', '\n'.join(vcs))
                benchmark_out = benchmark_out.replace('{{ EDGE CONFLICTS }}', '\n'.join(ecs))
                benchmark_out = benchmark_out.replace('{{ INVALID MOVEMENTS }}', '\n'.join(ims))
                benchmark_out = benchmark_out.replace('{{ NAME }}', names[result_index])
                benchmark_out = benchmark_out.replace('{{ PATH }}', paths[result_index])
                benchmark_out = benchmark_out.replace('{{ IN HORIZON }}', ['passed', 'not-passed'][int(not in_horizon[result_index])])
                benchmark_out = benchmark_out.replace('{{ VC PASSED }}', ['passed', 'not-passed'][int(bool(vcs))])
                benchmark_out = benchmark_out.replace('{{ EC PASSED }}', ['passed', 'not-passed'][int(bool(ecs))])
                benchmark_out = benchmark_out.replace('{{ IM PASSED }}', ['passed', 'not-passed'][int(bool(ims))])

                if not vcs and not ecs and not ims and in_horizon[result_index]:
                    benchmark_out = benchmark_out.replace('{{ PASSED }}', 'passed')
                    quick_list.append(quick_with_id.replace('{{ PASSED }}', 'passed'))
                else:
                    benchmark_out = benchmark_out.replace('{{ PASSED }}', 'not-passed')
                    quick_list.append(quick_with_id.replace('{{ PASSED }}', 'not-passed'))
              
                benchmark_out = benchmark_out.replace('{{ IMAGE }}', '/'.join(image_paths[result_index].split('/')[1:]))
                res = benchmark_out.replace('{{ B INDEX }}', f'{result_index + 1}')

                out.append(res)

            f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\index.html", "r")
            res_template = f.read()
            f.close()

            f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\main.css", "r")
            style = f.read()
            f.close()

            out_string = res_template.replace('{{ BENCHMARKS }}', '\n'.join(out))
            out_string = out_string.replace('{{ STYLE }}', style)
            out_string = out_string.replace('{{ QUICK }}', '\n'.join(quick_list))

            f = open("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\output\out.html", "w")
            f.write(out_string)
            f.close()