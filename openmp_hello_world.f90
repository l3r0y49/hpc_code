program openmp_hello_world
use omp_lib
use omp_lib_kinds
implicit none

integer     ::threads,my_thread=-1
threads = omp_get_num_threads()

!$omp parallel private (my_thread)
my_thread = omp_get_thread_num()
threads = omp_get_num_threads()

print*, "Hello world from thread",my_thread,"of",omp_get_num_threads()

!$omp end parallel

endprogram
