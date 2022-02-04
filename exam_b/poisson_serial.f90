program poisson_serial
    use pgm, only : pgm_write, pgm_read
    implicit none
    integer,parameter                                   :: dp= selected_real_kind(15,300)
    real(kind=dp)                                       :: h,a,b,q1,x1,y1,q2,x2,y2,w,accuracy_threshold,q_max
    integer                                             :: N,max_steps,a_int_length,b_int_length
    integer                                             :: x1_int_location,y1_int_location,x2_int_location,y2_int_location
    real(kind=dp),allocatable,dimension(:,:)            :: box
    integer,allocatable,dimension(:,:)                  :: int_box
    logical                                             :: debug, converged, all_phi_updates_skipped, specific_case_b
    character(20)                                       :: out_file='phi_print.pgm',out_file_b='phi_print_b.pgm'
    
    !read in parameters
    call read_in()
    call check_input_values()
    call initial_properties()

    !allocate simulation space
    allocate(box(a_int_length,b_int_length))
    
    !set inital simulation space conditions
    box=0.0_dp
    !place charges
    box(x1_int_location,y1_int_location) = q1
    box(x2_int_location,y2_int_location) = q2
    
    
    !carry out SOR sycles untill convergence reached
    do N=1,max_steps
    
        if(debug.eqv..true.)then
            if(mod(N,1000_dp)==0)then
                print*,N
            endif
        endif
        
        all_phi_updates_skipped=.true.
        
        !do a SOR pass over grid. will be MPI thread in MPI version
        call SOR_pass(all_phi_updates_skipped)
        
        if(all_phi_updates_skipped.eqv..true.)then
        
            !no changes to phi values, all at convergence, therefore SOR completed
            if(debug.eqv..true.)then
                print*, "System converged after: ",N," SOR cycles"
            endif
            converged=.true.
            exit
        endif
    enddo
    
    !check if covergence or just max_steps reached
    if(converged.eqv..false.)then
        print*, "System hasn't converged after: ",max_steps," SOR cycles"
    endif
    
    call pgm_out()
    
    !deallocate sim space at end of program
    deallocate(box)
    
    contains
    
        subroutine SOR_pass(skipped_phi_updates)
            logical,intent(inout)      ::skipped_phi_updates
            integer                    :: i,j
            real(kind=dp)              :: updated_phi
            
            !boundary values left of of loops to maintian a grounded edge for the system
            do i=2,a_int_length-1
                do j=2,b_int_length-1
                    
                    !calcuate new phi value
                    updated_phi=new_phi(box(i,j),i,j)
                    
                    !if not converged, update value in sim space and boolean flag
                    if(abs(box(i,j)-updated_phi)>accuracy_threshold)then
                        
                        box(i,j)=updated_phi
                        skipped_phi_updates=.false.
                    endif
                    
!                     if(debug.eqv..true.)then
!                         print*,"New Phi value: ",updated_phi
!                         print*,"skipped_phi_update: ",skipped_phi_updates
!                     endif
                enddo
            enddo
        
        endsubroutine 
    
        subroutine initial_properties()
                !set default flags
                converged=.false.
                all_phi_updates_skipped=.false.
                N=0
    
                !find max charge value q_max
                q_max=q1
                if (q2>q_max)q_max=q2
    
                !convert real lengths and positions to integers
                a_int_length = int(a*h)
                b_int_length = int(b*h)
                print*,b_int_length
                x1_int_location = int(x1*h)
                y1_int_location = int(y1*h)
                x2_int_location = int(x2*h)
                y2_int_location = int(y2*h)
        endsubroutine
    
        subroutine pgm_out()
            
            if(specific_case_b.eqv..true.)then
                !print out required coords
                print*, "r_A= ",box(300,300)
                print*, "r_B= ",box(150,450)
                print*, "r_C= ",box(120,20)
            endif
            
            !allocate int array for pgm output
            allocate(int_box(a_int_length,b_int_length))
    
            !max grey value in pgm is 255, multiply by max charge value q_max/255 to increase constrast
            
            !             print*, box(301,:)
            print*, box(300,:)
            print*,maxval(abs(box))
            
            box = box*128_dp/maxval(abs(box))+128_dp
            
            print*, box(300,:)
            
             int_box = int(box)

            if(specific_case_b.eqv..true.)then
                !write out to pgm file using pgm module from 2nd yr labs
                call pgm_write(int_box,out_file_b)
            else
                !write out to pgm file using pgm module from 2nd yr labs
                call pgm_write(int_box,out_file)
            endif
            !deallocate int sim space at end of program
            deallocate(int_box)
            
        endsubroutine
    
        real(kind=dp) function new_phi(old_phi,x_coord,y_coord)
            real(kind=dp), intent (in) ::  old_phi
            integer, intent (in)       :: x_coord,y_coord
            
            !calculate new_phi value at current i,j exit
            new_phi = old_phi + w*(U(x_coord,y_coord)-old_phi)
            
        endfunction new_phi
        
        real(kind=dp) function U(x_coord,y_coord)
            integer, intent (in)     :: x_coord,y_coord
            real(kind=dp)            :: charge_term
            
            !check if grid point is at a charge location
            !if so, set charge_term to q value
            !else charge_term=0.0
            charge_term=0.0_dp
            
            !check against charge 1
            if((x_coord==x1_int_location).and.(y_coord==y1_int_location))then
                charge_term=q1
            endif
            
            !check againts charge 2
            if((x_coord==x2_int_location).and.(y_coord==y2_int_location))then
                charge_term=q2
            endif
            
            !calucate U value for current coords
            U=0.25_dp*(box(x_coord+1,y_coord)+box(x_coord-1,y_coord)+box(x_coord,y_coord+1)+box(x_coord,y_coord-1)+charge_term)
            
        endfunction U
    
        subroutine read_in()
        
        !routine to read input file with error handling
            read(*,*,end=200,err=800) debug
            read(*,*,end=200,err=800) specific_case_b
            read(*,*,end=200,err=800) a
            read(*,*,end=200,err=800) b
            read(*,*,end=200,err=800) q1
            read(*,*,end=200,err=800) x1
            read(*,*,end=200,err=800) y1
            read(*,*,end=200,err=800) q2
            read(*,*,end=200,err=800) x2
            read(*,*,end=200,err=800) y2
            read(*,*,end=200,err=800) h
            read(*,*,end=200,err=800) w
            read(*,*,end=200,err=800) max_steps
            read(*,*,end=200,err=800) accuracy_threshold
            
            !sucessful read
            return
        200 continue
            print*,'read_in: error end of file in std. in'
            stop
        800 continue
            print*,'read_in: error in std. in'
            stop
        endsubroutine read_in
        
        subroutine check_input_values()
        
            !check input file is read correctly
            if(debug.eqv..true.)then
                print*,"Debug values"
                print*, "Debug: ",debug
                print*, "specific_case_b: ",specific_case_b
                print*, "a:",a
                print*, "b: ",b
                print*, "q1: ",q1
                print*, "x1: ",x1
                print*, "y1: ",y1
                print*, "q2: ",q2
                print*, "x2: ",x2
                print*, "y2: ",y2
                print*, "h: ",h
                print*, "w: ",w
                print*, "max_steps: ",max_steps
                print*, "accuracy_threshold: ",accuracy_threshold
            endif
            return
        endsubroutine check_input_values
    
endprogram poisson_serial
