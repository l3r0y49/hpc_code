program q3_ac2071
implicit none
integer, parameter :: precision=kind(1.0)
integer, parameter :: double=kind(1.d0)

real (kind=precision) :: a,b
real (kind=double) :: c_d,d_d

a=tiny(1.0)
b=huge(1.0)

c_d=tiny(1.d0)
d_d=huge(1.d0)

print*, "smallest single precision number:",a,"binary digits:", digits(a)
print*, "largest single precision number:",b,"binary digits:", digits(b)
print*, "snallest double precision number:",c_d,"binary digits:", digits(c_d)
print*, "largest double precision number:",d_d,"binary digits:", digits(d_d)

end program q3_ac2071
