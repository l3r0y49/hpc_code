program MPI_hello
use mpi
implicit none

integer         ::ierror,myrank, comm_size,i

call MPI_Init(ierror)

call MPI_Comm_rank(MPI_comm_world,myrank,ierror)

call MPI_Comm_size(MPI_comm_world,comm_size,ierror)

do i=1,comm_size
    call MPI_Barrier(MPI_comm_world,ierror)
    if(i==myrank+1)then
        print*,"Hello World from processor",myrank+1,"of",comm_size
    endif
enddo

call MPI_Finalize(ierror)

endprogram MPI_hello
