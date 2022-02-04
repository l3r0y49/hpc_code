#!/bin/sh
rm -f poisson.in

#define properties

#debug options
debug=false
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

h=100

#scale factor must be chosen such that a*h/pgm_scale_factor & b*h/pgm_scale_factor < 100,
#and both integers for correct .pgm production
pgm_scale_factor=1

#convergence factor - MUST be 1 <=w< 2
w=1.0
w_array=$(seq 1.0 0.05 1.95)

#Max iterations over box
# max_steps=100000000
max_steps=100000

#accuracy degree for convergence 
accuraccy=0.00001

#(MPI version)
#threads=10

for w in $w_array
do

    #create input file
    echo $debug >> poisson.in
    echo $specific_case_b >> poisson.in
    echo $a >> poisson.in
    echo $b >> poisson.in
    echo $q1 >> poisson.in
    echo $x1 >> poisson.in
    echo $y1 >> poisson.in
    echo $q2 >> poisson.in
    echo $x2 >> poisson.in
    echo $y2 >> poisson.in
    echo $h >> poisson.in
    echo $w >> poisson.in
    echo $max_steps >> poisson.in
    echo $accuraccy >> poisson.in
    echo $pgm_scale_factor >> poisson.in
    echo "w ${w}"
    
    #poission SOR run
    ./poisson_serial.exe < poisson.in

    mv phi_print_b.pgm w_tests/phi_print_b_h_${h}_w_${w}.pgm 

    rm -f poisson.in
done
