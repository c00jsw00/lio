subroutine linear_response(MatCoef,VecEne,Xexc,Eexc,M,Mlr,Nvirt,NCO,dim,code)
! This routine perform a Davidson diagonalization in order to obtain
! Excitation Energies and Transition vectors of excited states

! Inputs
! MatCoef: Molecular Orbitals Coefficients
! VecEne : Molecular Orbitals Energies

! Ouputs
! Xexc: Transition Density of all excited states
! Eexc: Excitation Energies
use garcha_mod  , only: npas
use excited_data, only: nstates, fittExcited, use_last, guessLR, max_subs
   implicit none
   integer, intent(in) :: M, Mlr, Nvirt, NCO, dim, code
   LIODBLE, intent(in)  :: MatCoef(M,Mlr), VecEne(Mlr)
   LIODBLE, intent(out) :: Xexc(dim,nstates), Eexc(nstates)

   character(len=8) :: char_max
   integer :: maxIter, iter, vec_dim, first_vec, newvec
   integer :: Subdim, ii
   LIODBLE, dimension(:,:), allocatable :: AX,H,eigvec,tvecMO
   LIODBLE, dimension(:,:), allocatable :: RitzVec,ResMat
   LIODBLE, dimension(:), allocatable :: eigval, val_old, Osc
   logical :: conv
   conv = .false. ! Convergence criteria bool

   call g2g_timer_start("LINEAR RESPONSE")
   if ( code == 0 ) then
      print*, ""
      print*,"======================================="
      print*,"        LINEAR RESPONSE - TDA"
      print*,"======================================="
      print*, ""
   elseif ( code == 1 ) then
      print*, ""
      print*,"======================================="
      print*,"        SECOND LINEAR RESPONSE         "
      print*,"======================================="
      print*, ""
!      write(*,"(1X,A,I2,1X,A)") "ABSORPTION SPECTRA OF",state_LR,"EXCITED STATE"
      print*, ""
    else
      print*, "There isn't Third Linear Response implemented"
      stop
   endif

   ! Check Input Variables
   if ( nstates > dim ) then
      print*, "Number of Excited States That You Want is Bigger than &
               & Dimension Matrix "
      nstates = dim
      print*, "We will calculate", nstates
   endif

   ! Davidson Initialization
   allocate(val_old(nstates),Osc(nstates))
   ! TODO: 4 is the initial vectors for each excitated state ( INPUT ).
   val_old = 1.0d0; vec_dim = 4 * nstates
   if ( npas > 1 .and. use_last ) vec_dim = nstates
   first_vec = 0; newvec = 0
   if ( vec_dim >= dim ) then
      vec_dim = dim; Subdim  = dim
      maxIter = 1; max_subs = dim
   else
      if ( max_subs > dim ) max_subs = dim
      maxIter = 50; Subdim = vec_dim
   endif
   allocate(AX(dim,max_subs),tvecMO(dim,max_subs))

   ! Initial Guess
   call vec_init(VecEne,tvecMO,dim,vec_dim,Mlr,NCO,Nvirt,dim,&
                 Subdim,maxIter)

   allocate(RitzVec(dim,nstates),ResMat(dim,nstates))
   RitzVec = 0.0d0

   ! Print Information
   write (char_max, '(i8)') max_subs
   write(*,"(1X,A,22X,I3,2X,I3,2X,I3,2X,I3)") "NCO, NVIRT, M, Mlr",NCO,Nvirt,M,Mlr
   write(*,"(1X,A,11X,I5)") "DIMENSION OF FULL MATRIX",dim
   write(*,"(1X,A,23X,A)") "MAX SUBSPACE",adjustl(char_max)
   write(*,"(1X,A,20X,I2)") "MAX ITERATIONES",maxIter
   write(*,"(1X,A,3X,I4)") "NUMBER OF INITIAL TRIALS VECTORS",vec_dim
   write(*,"(1X,A,3X,L1)") "USING FITTING TO ERI?",fittExcited

   ! DAVIDSON START
   do iter=1,maxIter
      call g2g_timer_start("Iteration LR")
      write(*,"(A)") " "
      write(*,"(1X,A,6X,I2)") "ITERATION:",iter
      write(*,"(1X,A,7X,I4)") "SUBSPACE:",Subdim
      write(*,"(1X,A,1X,I4)") "VECTORS INSIDE:",vec_dim

      ! This routine calculate Fock and form The Excited Matrix.
      call solve_focks(MatCoef,tvecMO,AX,M,Mlr,NCO,Nvirt,dim,max_subs, &
                       vec_dim,Subdim,first_vec)
 
      ! AX += (Ea-Ei)*Xia 
      call addInt(AX,VecEne,tvecMO,dim,Mlr,Subdim,NCO,vec_dim,first_vec)

      ! We obtain subspace matrix
      allocate(H(Subdim,Subdim))
      call dgemm('T','N',Subdim,Subdim,dim,1.0d0,tvecMO,dim,AX,&
                  dim,0.0d0,H,Subdim)

      ! Diagonalization of Subspace Matrix
      if(allocated(eigvec)) deallocate(eigvec)
      if(allocated(eigval)) deallocate(eigval)
        allocate(eigvec(Subdim,Subdim),eigval(Subdim))
      call diagonH(H,Subdim,eigval,eigvec)
      deallocate(H)

      ! Energy-Specific TDA.
      call energy_specific(eigvec,eigval,Subdim,nstates)

      ! Change subspace to full space - Obtain Ritz Vector
      call dgemm('N','N',dim,nstates,Subdim,1.0d0,tvecMO,dim,&
                 eigvec,Subdim,0.0d0,RitzVec,dim)

      ! When do not perform davidson diagonalization
      if ( maxIter == 1 ) then
         call OscStr(RitzVec,eigval,MatCoef,Osc,M,Mlr,NCO,Nvirt,dim,nstates)
         call PrintResults(RitzVec,eigval,Osc,dim,nstates,Mlr,NCO)
         exit
      endif

      ! Obtain residual vectors
      call residual(eigval,eigvec,RitzVec,AX,ResMat,dim,Subdim,nstates)

      ! Check Convergence and append new vectors
      conv = .false.; newvec = 0
      call new_vectors(ResMat,eigval,VecEne,tvecMO,val_old,dim,Subdim,&
                       nstates,Mlr,NCO,newvec,conv)
      if ( conv .eqv. .true. ) then
         write(*,*) ""
         write(*,"(1X,A,I2,1X,A)") "CONVERGED IN:",iter,"ITERATIONS"
         call OscStr(RitzVec,eigval,MatCoef,Osc,M,Mlr,NCO,Nvirt,dim,nstates)
         call PrintResults(RitzVec,eigval,Osc,dim,nstates,Mlr,NCO)
         exit
      else
         ! Actualization of vectors index
         first_vec = Subdim
         Subdim = Subdim + newvec
         vec_dim = newvec
      endif
      call g2g_timer_stop("Iteration LR")
   enddo ! END DAVIDSON ITERATION

   ! Return Eigvectors and Excitation Energies
   Xexc = RitzVec; Eexc = eigval(1:nstates)

   ! Saving Eigenvectors as initial guess in the next step
   if ( use_last ) then
      if (allocated(guessLR)) deallocate(guessLR)
      allocate(guessLR(dim,nstates)); guessLR = Xexc
   endif
  
   ! Free Memory
   deallocate(RitzVec,eigval,eigvec,ResMat,AX,tvecMO)
   deallocate(val_old,Osc)

end subroutine linear_response
