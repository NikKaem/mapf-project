from BenchmarkEngine.benchmark import Benchmark, BenchmarkBinder

if __name__ == '__main__':

    # Initialising a new Benchmark with it's folders path
    b1 = Benchmark("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\Our_Benchmarks_revamped\center_conflict")
    b2 = Benchmark("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\Our_Benchmarks_revamped\conflict_square")
    b3 = Benchmark("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\Our_Benchmarks_revamped\corridor")
    b4 = Benchmark("E:\Programme\Github\Asprillo_main\mapf-project\Other_Groups\Our_Benchmarks_revamped\other_side")

    # creating a new empty binder
    binder = BenchmarkBinder()

    # adding a benchmark to the binder
    binder.add_benchmark(b1)
    binder.add_benchmark(b2)
    binder.add_benchmark(b3)
    binder.add_benchmark(b4)

    # preprocessing for the file that contains the calculated occurs. (won't be necessary in the future)
    
 

    # evaluation of all the benchmarks stored in the binder
    binder.evaluate([b1.original_plans, b2.original_plans, b3.original_plans, b4.original_plans
                    ])

    # Be careful not to evaluate 2 Binders at the same time because the plot images are always deleted before a new
    # evaluation takes place
