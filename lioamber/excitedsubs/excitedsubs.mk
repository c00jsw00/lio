included :=

included += ExcProp.f90
included += fcaApp.f90
included += basis_exc.f90
included += tda.f90
included += initvec.f90
included += vecMOtomatMO.f90
included += matMOtomatAO.f90
included += solve_focks.f90
included += MtoIANV.f90
included += addInt.f90
included += diagonH.f90
included += residual.f90
included += new_vectors.f90
included += norma.f90
included += OscStr.f90
included += TransDipole.f90
included += ObtainOsc.f90
included += PrintResults.f90
included += calc2eFITT.f90
included += RelaxedDensity.f90
included += GenerateDensities.f90
included += Zvector.f90
included += ChangeBasisF.f90
included += Rcalculate.f90
included += PCG_solve.f90
included += forcesexc.f90
included += WSgradcalc.f90
included += HVgradcalc.f90
included += COUgradcalc.f90
included += tsh_probabilities.f90
included += intSG_Exc.f90
included += reduced_space.f90
included += truncated_MOs.f90
included += energy_specific.f90
included += getcubegen_excited.f90


$(OBJPATH)/excitedsubs.o: $(included) excitedsubs.mk
