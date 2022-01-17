program heatbath_mpi
use mpi
implicit none
    integer                :: ierror,myrank, comm_size,status(1:MPI_STATUS_SIZE)

    integer,parameter                                   :: dp= selected_real_kind(15,300)
    integer                                             :: box_size_y,box_size_x, margin, i,j,N,total_size_x
    integer                                             :: max_steps,end_index_x,total_size_y,end_index_y
    real(kind=dp),allocatable,dimension(:,:)            :: square,new_square
    logical                                             :: converged
    real(kind=dp)                                       :: start_time, end_time, time

    call MPI_Init(ierror)

    call MPI_Comm_rank(MPI_comm_world,myrank,ierror)

    call MPI_Comm_size(MPI_comm_world,comm_size,ierror)
    
    print*,"mpi rank",myrank
    
    box_size_y=100
    box_size_x=box_size_y/comm_size
    margin=2
    
    !divide into strips according to mpi rank
    total_size_y=box_size+margin
    total_size_x=box_size_x+margin

    end_index_y=total_size_y-1
    end_index_x=total_size_x-1
    
    allocate(square(0:end_index_x,0:end_index_y))
    allocate(new_square(0:end_index_x,0:end_index_y))
    
    square=0.0_dp
    new_square=0.0_dp
    N=0
    converged=.false.
    max_steps=100000000
    print*,"max steps "max_steps
    print*," "
    
    !set inital temps in new square
    
    !test if x coord is in given strip to set inital temps
    if( ((myrank+1)*box_size_x-50) >0.0.and. ((myrank+1)*box_size_x-50)<box_size_x)then
        new_square((myrank+1)*box_size_x-50,50)=10_dp
    endif
    
    if(((myrank+1)*box_size_x)-40<box_size_x.and.((myrank+1)*box_size_x-40)<box_size_x)then
        new_square((myrank+1)*box_size_x-40,60)=7.2_dp
    endif
    
    if(((myrank+1)*box_size_x)-70<box_size_x.and.((myrank+1)*box_size_x-70)<box_size_x)then
        new_square((myrank+1)*box_size_x-70,25)=-1.2_dp
    endif
    
    stop_time=MPI_WTIME()
    do N=1,max_steps
        !copy over new_square array
        square=new_square
        new_square=0.0
        !square now holds all the data from the previous step
        
        !update all halos mpi recive wait send wait
        !Needs to fill the boarders between each of the strips on each mpi rank
        
        ! requires testing and further development if time
        if(myrank>0)then

            call MPI_IRECV(square(:,0),1,MPI_DOUBLE_PREC,myrank-1,4,MPI_COMM_WORLD,1,errcode)
            !call revice first for performance, data is removed from buffer as soon as it is sent to it
        endif
        
        if(myrank<comm_size)then
        !recive from left
        call MPI_SEND(square(:,end_index_x),1,MPI_DOUBLE_PREC,myrank+1,3,MPI_COMM_WORLD,2,errcode)
        !call revice first for performance, data is removed from buffer as soon as it is sent to it
        endif
        
        call MPI_WAIT(2,send_status,errcode)

        call MPI_WAIT(1,recv_status,errcode)
        
        !do averages, iterate over elements 1 to 100, missing 0 and 101, in both directions
        do i=1,box_size_x
            do j=1,box_size_y
                !calcuate new point
                new_square(i,j) = (square(i,j)+square(i+1,j)+square(i-1,j)+square(i,j+1)+square(i,j-1))/5.0_dp
                
            enddo
        enddo
        
        if(mod(N,10000)<tiny(1.0))then
            print*,"iteration ",N,"finished on rank",myrank
        endif
        
        converged=all(abs(square-new_square)<10E-20)
        if(converged)exit
    enddo
    stop_time=MPI_WTIME()
    time=(stop_time-start_time)*1000.0_dp
    
    if(((myrank+1)*box_size_x-50) >0.0.and. ((myrank+1)*box_size_x-50)<box_size_x)then
        print*,"converged, T at (5.5,5.5)= ",square((myrank+1)*box_size_x-55,55)," after ",N,"iterations in",time,"ms."
    endif
    
    !deallocate arrays
    deallocate(square)
    deallocate(new_square)
    
    call MPI_Finalize(ierror)

endprogram heatbath_mpi
