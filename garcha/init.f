c MAIN SUBROUTINE ----------------------------------------------------
C DFT calculation with gaussian basis sets
c---------------------------------------------------------------------
c
      implicit real*8 (a-h,o-z)
c
c PARAMETERS - DYNAMICAL VECTOR ONLY -------------------
c
c ngDyn : number of atoms * number basis functions
c ngdDyn: number of atoms * number auxiliar functions
c Ngrid : number of grid points (LS-SCF part)
c norbit : number of MO
c
c Ngrid may be set to 0 , in the case of using Num. Integ.
c
      parameter (ngDyn=700)
      parameter (ngdDyn=700)
c      parameter (ngDyn=450)
c      parameter (ngdDyn=450)

      
c     parameter (ngDyn=66)
c     parameter (ngdDyn=95)

 
      parameter (norbit=80,Ngrid=6000)
c
      parameter (ng3=4*ngDyn)
c      parameter (ng2=(7*ngDyn*(ngDyn+1)/2+3*ngdDyn*(ngdDyn+1)/2+
c     >           ngDyn+ngDyn*norbit+Ngrid)*10)
c para version en memoria
      parameter (ng2=5*ngDyn*(ngDyn+1)/2+3*ngdDyn*(ngdDyn+1)/2+
     >           ngDyn+ngDyn*norbit+Ngrid+ngDyn*(NgDyn+1)/2*NgdDyn)

      dimension X(ngDyn,ng3),XX(ngdDyn,ngdDyn),P(ng2)
      write(*,*) (ngDyn*ng3+ngdDyn**2+ng2)*8*1.0D-06, '  Memoria en MB'
c version en memoria
c
c--------------------------------------------------------
      call drive(ng2,ngDyn,ngdDyn,P,X,XX)
c
      end
c---------------------------------------------------------------------
