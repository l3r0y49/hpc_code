#!/bin/sh
rm -f poisson_mpi.in

#define properties

#debug options
debug=true
specific_case_b=true

#box dimensions
a=4.0
b=6.0

#particle 1 properties
q1=1.0
# x1=3.0
# y1=3.0

# # part b coordinates
x1=3.1415926535897932
y1=2.7182818284590452

#particle 2 properties
q2=-2.0
# x2=2.0
# y2=5.0

# # part b coordinates
x2=1.6180339887487848
y2=4.6692016091029906

#grid size/ resolution (number of array indexes per unit box size)
# e.g. a*h = 4*100 box size = 400

h=200

#scale factor must be chosen such that a*h/pgm_scale_factor & b*h/pgm_scale_factor < 100,
#and both integers for correct .pgm production
pgm_scale_factor=2

#convergence factor - MUST be 1 <=w< 2
w=1.6

#Max iterations over box
# max_steps=100000000
max_steps=100000

#accuracy degree for convergence 
accuraccy=0.0001

#(MPI version)
thread_count=4

export OMP_NUM_THREADS=$thread_count

#create input file
echo $debug >> poisson_mpi.in
echo $specific_case_b >> poisson_mpi.in
echo $a >> poisson_mpi.in
echo $b >> poisson_mpi.in
echo $q1 >> poisson_mpi.in
echo $x1 >> poisson_mpi.in
echo $y1 >> poisson_mpi.in
echo $q2 >> poisson_mpi.in
echo $x2 >> poisson_mpi.in
echo $y2 >> poisson_mpi.in
echo $h >> poisson_mpi.in
echo $w >> poisson_mpi.in
echo $max_steps >> poisson_mpi.in
echo $accuraccy >> poisson_mpi.in
echo $pgm_scale_factor >> poisson_mpi.in
echo $threads >> poisson_mpi.in

#poission SOR run
./poisson_omp.exe < poisson_mpi.in

mv phi_print_b.pgm phi_print_b_threads_${thread_count}_h_${h}_w_${w}.pgm 

rm -f poisson_mpi.in
