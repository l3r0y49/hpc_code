#include <omp.h>
#include <cstdio>
#include <vector>

int main(){
    
    long threads =-1;
    unsigned long i =0;
    long N=100000000; 
    long total_sum=0;
    double start_time=0.0;
    double end_time=0.0;
    
    std::vector<double> array_N;
    
    array_N.reserve(N);
    array_N.resize(N);
    
    //Set each array elem,ent to its index +1
    for(unsigned long j=0; j<array_N.size(); ++j){
        array_N[j]=j+1;
    }
    
    //sum up in parallel, with timing
    #pragma omp parallel private(i) shared(N,array_N) reduction(+:total_sum)
    {
        start_time = omp_get_wtime();
        threads = omp_get_num_threads();
        #pragma omp for 
            for(i=0; i<array_N.size(); ++i){
                    total_sum+=array_N[i];
                }
        end_time = omp_get_wtime();
    }
    
    printf("Total sum: %li \n",total_sum);
    printf("Time: %f seconds \n",(end_time-start_time));
    printf("Threads: %li \n",threads);
}
