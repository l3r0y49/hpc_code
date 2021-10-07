program q0_ac2071
    implicit none
    integer,parameter       :: dp=selected_real_kind(15,300)
    real(kind=dp),parameter :: PI=4.d0*datan(1.d0)
    integer                 :: N,i, N_max
    real(kind=dp)           :: pi_calc, prec=1E-11
    logical                 :: found=.false.
    
    !set max value of N
    N_max=1000000
    
    !loop over possible N values
    !balance will be series precicion as N-->infinity and bit error
    do N=1,N_max
        
        !Reset pi value
        pi_calc = 0.0_dp
        
        !carry out summation part of eqution
        do i=1,N
            pi_calc = pi_calc + 1_dp/(1_dp+((real(i,kind=dp)-0.5_dp)/real(N,kind=dp))**2)
        enddo
        
        !carry out the rest of the equation
        pi_calc = 4_dp/real(N,kind=dp)*pi_calc
        
        !access accuracy
        if(abs(PI-pi_calc)<prec)then
            !set flag, quit once answer found
            found=.true.
            exit
        endif
    enddo
    
    !if an answer is found
    if(found.eqv..true.)then
        !print results
        print*, "N", N
        print*, "pi calulated", pi_calc
        print*, "PI", PI
        print*, "% difference", (abs(PI-pi_calc)/PI)*100_dp
        print*, "Detection precision", prec
    else
        !Print answer not found message
        print*,"Program end"
        print*,"No N found for precision threshold"
        print*, "Detection precision", prec
    endif
endprogram 
