program q6_ac2071
use omp_lib
use omp_lib_kinds
implicit none

integer,parameter                           :: dp= selected_real_kind(15,300)
integer,parameter                           :: li= selected_int_kind(16)
real(kind=dp), dimension(12)                :: N_array= (/10e+3,2*10e+3,5*10e+3,10e+4,2*10e+4,5*10e+4,10e+5,2*10e+5,5*10E+5,10e+6,&
2*10e+6,5*10e+6/)
! real(kind=dp), dimension(1)                :: N_array= (/10e+6/)
real(kind=dp), dimension(:),allocatable     :: A,B
real(kind=dp)                               :: N
integer(kind=li)                            :: i, j,threads, int_N
real(kind=dp)                               :: start_time=0.0_dp, end_time=0.0_dp,total_sum

!loop over all N in N_array
do j=1,size(N_array)
    !select N
    N=N_array(j)
    int_N=int(N,kind=li)
    
    allocate(A(int_N))
    allocate(B(int_N))
    total_sum=0.0_dp


    !$OMP parallel private(i) shared (int_N,A,B) reduction(+:total_sum)
    start_time = omp_get_wtime()
    threads = omp_get_num_threads()

    !carry out sum
    !$OMP do
    do i=1,int_N
        !removed dependencies 
        A(i) = real(i,kind=dp)
        B(i) = A(i)*A(i)
        A(i) = A(i) + sqrt(abs(sin(B(i))))*2.34_dp
        !$OMP atomic
        total_sum = total_sum + A(i)
    enddo
    !$OMP end do
    end_time = omp_get_wtime()
    !$omp end parallel

    print*,N, total_sum, (end_time-start_time),threads
    
    deallocate(A)
    deallocate(B)
    
enddo

endprogram
