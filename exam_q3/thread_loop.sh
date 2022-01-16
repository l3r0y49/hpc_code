#!/bin/sh

#thread_list=$(seq 1 1 8)
thread_list=$(seq 1 1 4)
thread_count=0

mkdir results/

for thread_count in $thread_list
do  
    export OMP_NUM_THREADS=$thread_count
    time=$(date +"%T")
    output_file=exam_q3_t_num_${thread_count}_${time}.out
    ./exam_q3.exe > $output_file
    mv $output_file results/
done

mv results/ run_${time}/
