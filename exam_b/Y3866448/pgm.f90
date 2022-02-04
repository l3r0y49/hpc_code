module pgm

    implicit none
    private
    public  ::pgm_write, pgm_read
    
    integer             :: istat
    integer             :: out_unit = 20 !I/O variables
    
    contains
        subroutine pgm_write(lattice,filename)
        integer,dimension(:,:),intent(in) ::lattice
        character(len=*),intent(in)       ::filename
        integer,dimension(2)              ::dimensions
        integer                           ::j,i
        
        dimensions = shape(lattice)
        open(file=filename,unit=out_unit,status='replace',action='write',iostat = istat)
        if(istat /= 0) stop "Error opening file"
        !pgm magic number
        write (out_unit,11) 'P2'
        !width, height
        write (out_unit,12) dimensions(1),dimensions(2)
        !max gray value
        write (out_unit,13) 255
        
        !loop through grid
        do j= 1,dimensions(2)
            do i= 1,dimensions(1)
                write (out_unit,*) lattice(i,j)
                enddo
            enddo
            close (unit=out_unit,iostat = istat)
            if(istat /= 0) stop "Error closing file"
            
            11 format(a2)
            12 format(i3,1x,i3)
            13 format(i5)
            
        close(unit= out_unit,iostat = istat)
        if(istat /= 0) stop "Error opening file"
        print*, "plot complete"
        
    endsubroutine 
    
    subroutine pgm_read(array,filename)
        integer,allocatable,dimension(:,:)::array
        character (len=*),intent(in)      ::filename
        integer,dimension(2)              ::dimensions
        
        open(file=filename,unit=out_unit,status='old',action='read',iostat = istat)
        if(istat /= 0) stop "Error opening file"
        !pgm magic number
        read (out_unit,11)
        !width, height
        read (out_unit,12) dimensions(1),dimensions(2)
        !max gray value
        read (out_unit,13)
        
        print*,dimensions
        
        allocate (array(dimensions(1),dimensions(2)), stat = istat)
        if(istat/=0) stop "Error allocating array"
        
        
        read (out_unit,*) array(:,:)
        
        close (unit=out_unit,iostat = istat)
        if(istat /= 0) stop "Error closing file"
            
        11 format(a2)
        12 format(i3,1x,i3)
        13 format(i5)
        
        print*, "read complete"
        

    endsubroutine 
endmodule pgm
