program MPI_springs
use mpi
implicit none
integer,parameter                                 :: dp= selected_real_kind(15,300)
integer,parameter                                 :: long_int= selected_int_kind(16)

integer                :: ierror,myrank, comm_size,status(1:MPI_STATUS_SIZE), left_rank, right_rank,i
real,dimension(2)      :: r0 ,r_minus1, r_plus1
real                   :: local_energy, energy, spring_length_1_sqr, spring_length_2_sqr

call MPI_Init(ierror)

call MPI_Comm_rank(MPI_comm_world,myrank,ierror)

call MPI_Comm_size(MPI_comm_world,comm_size,ierror)

! if(myrank.eq.0)then
!     print*,"Comm_size",comm_size
! endif

if(myrank.eq.0)then
    r0=(/0.0_dp,0.0_dp/)
elseif(myrank.eq.1)then
    r0=(/1.0_dp,1.0_dp/)
elseif(myrank.eq.2)then
    r0=(/0.5_dp,0.5_dp/)
else
    r0=(/0.2_dp,0.7_dp/)
endif
    
call MPI_Barrier(MPI_comm_world,ierror)

!go left and right in array of ranks 0 1 2 3 with wraparound
left_rank=mod(myrank+3,4)
right_rank=mod(myrank+1,4)

if(myrank.eq.0)then
    print*,"myrank",myrank
    print*,"left_rank",left_rank
    print*,"right_rank",right_rank
endif

!send cords to neighbours
if(myrank.eq.0)then
    print*,"sending"
endif

do i=1,comm_size
    call MPI_Barrier(MPI_comm_world,ierror)
    if(i==myrank+1)then
        print*,i
        call MPI_Send(r0(1),2,MPI_REAL,left_rank,12,MPI_COMM_WORLD,ierror)
        if(ierror/=0) stop "Error in sending data on processor"

        call MPI_Recv(r_minus1(1),2,MPI_REAL,left_rank,12,MPI_COMM_WORLD,status,ierror)
        if(ierror/=0) stop "Error in reciving data on processor"
    endif
enddo


 do i=1,comm_size
    call MPI_Barrier(MPI_comm_world,ierror)
    if(i==myrank+1)then
        print*,i
        call MPI_Send(r0,2,MPI_REAL,right_rank,13,MPI_COMM_WORLD,ierror)
        if(ierror/=0) stop "Error in sending data on processor"
    
        call MPI_Recv(r_plus1,2,MPI_REAL,right_rank,13,MPI_COMM_WORLD,status,ierror)
        if(ierror/=0) stop "Error in reciving data on processor"
!recive coords from neighbours
    endif
enddo

if(myrank.eq.0)then
    print*,"Recived"
endif

!calucate x for each spring
spring_length_1_sqr = (r_minus1(1)-r0(1))**2+(r_minus1(2)-r0(2))**2
spring_length_2_sqr = (r_plus1(1)-r0(1))**2+(r_plus1(2)-r0(2))**2

if(myrank.eq.0)then
    print*,"spring_length_1_sqr",spring_length_1_sqr
    print*,"spring_length_2_sqr",spring_length_2_sqr
endif

!calculate local energy
local_energy = 0.5_dp*(spring_length_1_sqr+spring_length_2_sqr)



call MPI_Finalize(ierror)

endprogram
