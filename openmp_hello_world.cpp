#include <omp.h>
#include <cstdio>

int main(){
    
    int threads =-1;
    int my_thread=-1;
    
    #pragma omp parallel private(my_thread)
    {

        my_thread=omp_get_thread_num();
        threads=omp_get_num_threads();
        printf("Hello world from thread number %i of %i \n",my_thread,threads);
        
    }
    
    
    
}
