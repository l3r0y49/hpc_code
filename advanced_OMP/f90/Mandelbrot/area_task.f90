program area_mandelbrot
  implicit none
!
  integer, parameter :: sp = kind(1.0)   
  integer, parameter :: dp = kind(1.0d0)
  integer :: i, j, iter, numoutside,numoutside_task
  integer, parameter :: npoints = 2000, maxiter = 2000
  real (kind=dp) :: area, error
  complex (kind=dp) :: c , z

  !additions
  integer :: OMP_GET_NUM_THREADS,OMP_GET_THREAD_NUM
  integer :: nthreads,tnumber

!
! Calculate area of mandelbrot set
!
!    Outer loops runs over npoints, initialize z=c
!
!    Inner loop has the iteration z=z*z+c, and threshold test
!

!!$  !$OMP PARALLEL DEFAULT(PRIVATE)
!!$  nthreads = OMP_GET_NUM_THREADS()
!!$  tnumber=OMP_GET_THREAD_NUM()
!!$  print *,"Hello world from thread",tnumber+1," of",nthreads
!!$  !$OMP END PARALLEL


  numoutside = 0 

!$OMP parallel default(private) shared(numoutside)
!NB not allowed to pass reduction variables into tasks!
!!$   print *,'starting parallel block with thread=',omp_get_thread_num()
!$OMP single 
!!$   print *,'starting single block with thread=',omp_get_thread_num()
  do i = 0,npoints-1 
!$OMP task
     do j= 0,npoints-1 
        numoutside_task=0
        c = cmplx(-2.0+(2.5*i)/npoints + 1.0d-07,(1.125*j)/npoints + 1.0d-07)
        z = c
        iter = 0 
        do while (iter < maxiter) 
           z = z*z + c 
           iter = iter + 1
           if (real(z)*real(z)+aimag(z)*aimag(z) > 4) then
              !NB use task-private here to minimize use of atomic
              numoutside_task = numoutside_task + 1 
              exit
           endif
        end do 
!NB multiple threads/tasks could be writing to numoutside as it is shared
!   so need to use atomic instead ...
!$OMP atomic
        numoutside=numoutside+numoutside_task
     end do
!$OMP end task
  end do
!$OMP end single
!$OMP end parallel

!
! Output results
!
  area = 2.0*2.5*1.125 * real(npoints*npoints-numoutside)/real(npoints*npoints)
  error = area/real(npoints)
  print *, "Area of Mandelbrot set = ",area," +/- ",error
!
  stop
end program area_mandelbrot
