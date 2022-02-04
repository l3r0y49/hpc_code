        subroutine scale_to_int_array_average(scale_factor)
            real(kind=dp),intent(in)   :: scale_factor
            integer                    :: i,j,incrament
            real(kind=dp)              :: running_tot
            
            incrament= int(scale_factor)
            !iterate over sim space, sampling at the correct interval for pgm file
                
            do i=1,a_int_length-1
                do j=1,b_int_length-1
                
                !running total over the last incrament
                running_tot=running_tot+box(i,j)
                
                !at end of increament add average over last section of incrament
                if(j==incrament)then
                    !max grey value in pgm is 255, multiply by max charge value q_max/255 to increase constrast
                    int_box(i/incrament+1,j/incrament+1) = int(running_tot/real(incrament))
                    running_tot=0.0_dp
                endif
                enddo
            enddo
            
        endsubroutine
