program Q3
  use omp_lib
  use omp_lib_kinds
  implicit none

  integer,parameter :: dp= selected_real_kind(15,300)
  integer, parameter :: N=6
  integer, parameter :: chunk_size=2
  integer, dimension(1:N) :: a,b,c
  real(kind=dp) :: start_time=0.0_dp, end_time=0.0_dp, test1_time, test2_time
  real(kind=dp) ::test3_time, total_time
  
  !$OMP PARALLEL
  !$  print *,"Thread",OMP_GET_THREAD_NUM()+1," of",OMP_GET_NUM_THREADS()
  !$OMP END PARALLEL

  call array_setup
  call array_print('after setup')
  call test1
  call array_print('after test1')
  test1_time=end_time-start_time
  print*,"test1 time: ", test1_time, "seconds"
  

  call array_setup
  call test2
  call array_print('after test2')
  test2_time=end_time-start_time
  print*,"test2 time: ", test2_time, "seconds"
    
  call array_setup
  call test3
  call array_print('after test3')
  test3_time=end_time-start_time
  print*,"test3 time: ", test3_time, "seconds"
  
  total_time=test1_time+test2_time+test3_time
  print*,"total time: ", total_time, "seconds"

contains

  subroutine array_setup
    implicit none
    integer :: i

    do i=1,N
       a(i)=2*i
       b(i)=i*i
       c(i)=i*i-i+2
    end do

  end subroutine array_setup

  subroutine array_print(test)
    implicit none
    character(len=*) :: test
    integer :: i

    print *,test
    do i=1,N
       print *,i,a(i),b(i),c(i)
    end do

  end subroutine array_print

  subroutine test1
    implicit none
    integer :: i

    !$OMP parallel private(i) shared(a,b,c) 
!     schedule(static,chunk_size)
    start_time = omp_get_wtime()
    !$OMP do
    do i=2,N
       a(i-1)=b(i)
       c(i)=a(i)
    end do
    !$OMP end do
    end_time = omp_get_wtime()
    !$OMP end parallel

  end subroutine test1

  subroutine test2
    implicit none
    integer :: i

    !$OMP parallel private(i) shared(a,b,c) 
!     schedule(static,chunk_size)
    start_time = omp_get_wtime()
    !$OMP do
    do i=2,N
       a(i-1)=b(i)
       a(i)=c(i)
    end do
    !$OMP end do
    end_time = omp_get_wtime()
    !$OMP end parallel

  end subroutine test2

  subroutine test3
    implicit none
    integer :: i

    !$OMP parallel private(i) shared(a,b,c) 
!     schedule(static,chunk_size)
    start_time = omp_get_wtime()
    !$OMP do
    do i=2,N
       b(i)=a(i-1)
       a(i)=c(i)
    end do
    !$OMP end do
    end_time = omp_get_wtime()
    !$OMP end parallel

  end subroutine test3

end program Q3
