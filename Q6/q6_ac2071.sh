#!/bin/sh

threads="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
# threads="1 2 3 4"

#loop over threads
for T in $threads
do
    export export OMP_NUM_THREADS=$T
    #execute code
    ./q6_ac2071.exe
done
