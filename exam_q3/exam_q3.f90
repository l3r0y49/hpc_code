program Q3
  use omp_lib
  implicit none

  integer, parameter :: N=6
  integer, parameter :: chunk_size=2
  integer, dimension(1:N) :: a,b,c

  !$OMP PARALLEL
  !$  print *,"Thread",OMP_GET_THREAD_NUM()+1," of",OMP_GET_NUM_THREADS()
  !$OMP END PARALLEL

  call array_setup
  call array_print('after setup')
  call test1
  call array_print('after test1')

  call array_setup
  call test2
  call array_print('after test2')

  call array_setup
  call test3
  call array_print('after test3')

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

    !$OMP parallel do private(i) shared(a,b,c) schedule(static,chunk_size)
    do i=2,N
       a(i-1)=b(i)
       c(i)=a(i)
    end do
    !$OMP end parallel do

  end subroutine test1

  subroutine test2
    implicit none
    integer :: i

    !$OMP parallel do private(i) shared(a,b,c) schedule(static,chunk_size)
    do i=2,N
       a(i-1)=b(i)
       a(i)=c(i)
    end do
    !$OMP end parallel do

  end subroutine test2

  subroutine test3
    implicit none
    integer :: i

    !$OMP parallel do private(i) shared(a,b,c) schedule(static,chunk_size)
    do i=2,N
       b(i)=a(i-1)
       a(i)=c(i)
    end do
    !$OMP end parallel do

  end subroutine test3

end program Q3
