program heatbath_serial
    implicit none
    integer,parameter                                   :: dp= selected_real_kind(15,300)
    integer                                             :: box_size=100, margin=2, i,j,N,total_size,end_index
    integer                                             :: max_steps
    real(kind=dp),allocatable,dimension(:,:)            :: square,new_square
    logical                                             :: converged

    total_size=box_size+margin
    end_index=total_size-1
    
    allocate(square(0:end_index,0:end_index))
    allocate(new_square(0:end_index,0:end_index))
    
    square=0.0_dp
    new_square=0.0_dp
    N=0
    converged=.false.
    max_steps=100000000
    print*,"max steps "max_steps
    print*," "
    
    !set inital temps in new square
    new_square(50,50)=10_dp
    new_square(40,60)=7.2_dp
    new_square(70,25)=-1.2_dp
    
    !at this point square is all zeros and new_square has the intal conditions
    !will be copied over to square after next step

    do N=1,max_steps
        !copy over new_square array
        square=new_square
        new_square=0.0
        !square now holds all teh data from the previous step
        
        !do averages, iterate over elements 1 to 100, missing 0 and 101, in both directions
        do i=1,box_size
            do j=1,box_size
                !calcuate new point
                new_square(i,j) = (square(i,j)+square(i+1,j)+square(i-1,j)+square(i,j+1)+square(i,j-1))/5.0_dp
            enddo
        enddo
        
        if(mod(N,10000)<tiny(1.0))then
            print*,"iteration ",N,"finished"
        endif
        
        !convergence test, will break out of N loop once convergence reached
        converged=all(abs(square-new_square)<10E-20)
        if(converged)exit
        
    enddo
    
    print*,"converged, T at (5.5,5.5)= ",square(55,55)," after ",N,"iterations"
    
    !deallocate arrays
    deallocate(square)
    deallocate(new_square)
    
endprogram heatbath_serial
