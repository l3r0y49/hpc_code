program ping_pong
use mpi
implicit none

integer         ::ierror,myrank, comm_size, my_data, status(1:MPI_STATUS_SIZE)

call MPI_Init(ierror)

call MPI_Comm_rank(MPI_comm_world,myrank,ierror)

call MPI_Comm_size(MPI_comm_world,comm_size,ierror)

my_data = myrank

print*,"Inital Data: ",my_data,"from my processor: ",myrank+1

!send data
if(myrank.eq.0) then
    call MPI_Send(my_data,1,MPI_INTEGER,1,12,MPI_COMM_WORLD,ierror)
    if(ierror/=0) stop "Error in sending data on processor" 
elseif(myrank.eq.0) then
    call MPI_Recv(my_data,1,MPI_INTEGER,0,12,MPI_COMM_WORLD,status,ierror)
    if(ierror/=0) stop "Error in reciving data on processor"
endif

print*,"Ping data: ",my_data,"from processor: ",myrank+1

my_data = myrank

!send it back again
if(myrank.eq.1) then
    call MPI_Send(my_data,1,MPI_INTEGER,0,12,MPI_COMM_WORLD,ierror)
    if(ierror/=0) stop "Error in sending data on processor"
elseif(myrank.eq.0) then
    call MPI_Recv(my_data,1,MPI_INTEGER,1,12,MPI_COMM_WORLD,status,ierror)
    if(ierror/=0) stop "Error in reciving data on processor"
endif

print*,"Pong data: ",my_data,"from processor: ",myrank+1

call MPI_Finalize(ierror)

endprogram
