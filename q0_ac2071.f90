program q0_ac2071
    implicit none
    
    integer,parameter     :: dp=selected_real_kind(15,300)
    integer               :: N,i, N_max
    real(kind=dp)         :: pie
    
    N_max=10000000
    
    do N=1,N_max
    
        pie = 0.0_dp
        do i=1,N
        
            pie = pie + 1_dp/(1_dp+((real(i,kind=dp)-0.5_dp)/real(N,kind=dp))**2)
    
        enddo
    
        pie = 4_dp/real(N,kind=dp)*pie
    
        print*, ""
        print*, "N", N
        print*, "pie", pie
        print*, ""
    
    enddo
    
endprogram 
