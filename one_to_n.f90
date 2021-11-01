program one_to_n
use omp_lib
use omp_lib_kinds
implicit none

integer,parameter                                 :: dp= selected_real_kind(15,300)
integer,parameter                                 :: long_int= selected_int_kind(16)
integer (kind=long_int)                           :: i,N=100000000, total_sum=0,threads
integer (kind=long_int),dimension(:),allocatable  :: array_N
real(kind=dp)                                     :: start_time=0.0_dp, end_time=0.0_dp

allocate(array_N(N))

!set each element to its index
do i=1,N
    array_N(i)=i
enddo

!sum each element to its index in parallel

!$OMP parallel private(i) shared (N,array_N) reduction(+:total_sum)
start_time = omp_get_wtime()
threads = omp_get_num_threads()
!$OMP do
do i=1,N
    total_sum=total_sum + array_N(i)
enddo
!$OMP end do
end_time = omp_get_wtime()
!$omp end parallel

print*,"Total sum: ", total_sum
print*,"Time: ", end_time-start_time, "seconds"
print*,"Threads: ", threads

deallocate(array_N)
endprogram
