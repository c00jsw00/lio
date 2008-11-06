/* headers */
#include <iostream>
#include <cassert>
#include "common.h"
#include "init.h"
#include "cubes.h"
using namespace std;
using namespace G2G;

/* external function prototypes */
void gpu_compute_cube_functions(void);

/* global variables */
namespace G2G {
	FortranVars fortran_vars;
}

/* definitions */
#define FORTRAN_MAX_ATOMS 1875
#define FORTRAN_NG 1500
#define FORTRAN_NL 10

/* methods */
extern "C" void gpu_init_(const unsigned int& norm, const unsigned int& natom, double* r, double* Rm, const unsigned int* Iz, const unsigned int* Nr,
										 const unsigned int* Nr2, unsigned int* Nuc, const unsigned int& M, unsigned int* ncont, const unsigned int* nshell, double* c,
					           double* a, double* RMM, const unsigned int& M18, const unsigned int& M5, const unsigned int& nco, const unsigned int& nopt,
                     const unsigned int& Iexch, double* e, double* e2, double* e3, double* wang, double* wang2, double* wang3)
{
	printf("<======= GPU Code Initialization ========>\n");
	fortran_vars.atoms = natom;
	_DBG(cout << natom << " atoms" << endl);
	assert(natom <= MAX_ATOMS);

	assert(nopt == 0);

	cudaMemcpyToSymbol("gpu_atoms", &fortran_vars.atoms, sizeof(fortran_vars.atoms), 0, cudaMemcpyHostToDevice);

	fortran_vars.normalize = norm;
	float normalization_factor = (fortran_vars.normalize ? (1.0/sqrt(3)) : 1.0);
	cudaMemcpyToSymbol("gpu_normalization_factor", &normalization_factor, sizeof(float), 0, cudaMemcpyHostToDevice);
	
	fortran_vars.s_funcs = nshell[0];
	fortran_vars.p_funcs = nshell[1] / 3;
	fortran_vars.d_funcs = nshell[2] / 6;
	fortran_vars.spd_funcs = fortran_vars.s_funcs + fortran_vars.p_funcs + fortran_vars.d_funcs;
	fortran_vars.m = M;	
	fortran_vars.nco = nco;
	cudaMemcpyToSymbol("gpu_nco", &fortran_vars.nco, sizeof(uint), 0, cudaMemcpyHostToDevice);	
	
	_DBG(cout << boolalpha << "normalize? " << fortran_vars.normalize << " | spd: " << fortran_vars.s_funcs << " " << fortran_vars.p_funcs << " " << fortran_vars.d_funcs << " | m: " << fortran_vars.m << " nco: " << fortran_vars.nco << endl);
	
	fortran_vars.iexch = Iexch;	
	cudaMemcpyToSymbol("gpu_Iexch", &Iexch, sizeof(Iexch), 0, cudaMemcpyHostToDevice);	
	//HostMatrix<uint>::to_constant<uint>("gpu_iexch", Iexch);
	
	fortran_vars.atom_positions_pointer = FortranMatrix<double>(r, fortran_vars.atoms, 3, FORTRAN_MAX_ATOMS);
	
	fortran_vars.atom_types.resize(fortran_vars.atoms);
	for (uint i = 0; i < fortran_vars.atoms; i++) { fortran_vars.atom_types.get(i) = Iz[i] - 1; }	
	
	fortran_vars.shells1.resize(fortran_vars.atoms);
	fortran_vars.shells2.resize(fortran_vars.atoms);
	for (uint i = 0; i < fortran_vars.atoms; i++) { fortran_vars.shells1.get(i) = Nr[Iz[i] /* - 1*/]; }
	for (uint i = 0; i < fortran_vars.atoms; i++) { fortran_vars.shells2.get(i) = Nr2[Iz[i] /*- 1*/]; }
		
	fortran_vars.rm.resize(fortran_vars.atoms);
	for (uint i = 0; i < fortran_vars.atoms; i++) { fortran_vars.rm.get(i) = Rm[Iz[i] /*-1*/]; }
	
	fortran_vars.nucleii = FortranMatrix<uint>(Nuc, fortran_vars.m, 1, 1);
	
	fortran_vars.contractions = FortranMatrix<uint>(ncont, fortran_vars.m, 1, 1);
	fortran_vars.a_values = FortranMatrix<double>(a, fortran_vars.m, MAX_CONTRACTIONS, FORTRAN_NG);
	fortran_vars.c_values = FortranMatrix<double>(c, fortran_vars.m, MAX_CONTRACTIONS, FORTRAN_NG);		
	//fortran_vars.rmm_input_ndens1 = FortranMatrix<double>(RMM, (fortran_vars.m * (fortran_vars.m + 1)) / 2);
	fortran_vars.rmm_input = FortranMatrix<double>(RMM + (M18 - 1), fortran_vars.m, fortran_vars.nco, fortran_vars.m);
	fortran_vars.rmm_output = FortranMatrix<double>(RMM + (M5 - 1), (fortran_vars.m * (fortran_vars.m + 1)) / 2);
	
	fortran_vars.e1 = FortranMatrix<double>(e, SMALL_GRID_SIZE, 3, SMALL_GRID_SIZE);
	fortran_vars.e2 = FortranMatrix<double>(e2, MEDIUM_GRID_SIZE, 3, MEDIUM_GRID_SIZE);
	fortran_vars.e3 = FortranMatrix<double>(e3, BIG_GRID_SIZE, 3, BIG_GRID_SIZE);
	fortran_vars.wang1 = FortranMatrix<double>(wang, SMALL_GRID_SIZE, 1, SMALL_GRID_SIZE);
	fortran_vars.wang2 = FortranMatrix<double>(wang2, MEDIUM_GRID_SIZE, 1, MEDIUM_GRID_SIZE);
	fortran_vars.wang3 = FortranMatrix<double>(wang3, BIG_GRID_SIZE, 1, BIG_GRID_SIZE);

	fortran_vars.atom_atom_dists = HostMatrix<double>(fortran_vars.atoms, fortran_vars.atoms);
	fortran_vars.nearest_neighbor_dists = HostMatrix<double>(fortran_vars.atoms);
}

extern "C" void gpu_reload_atom_positions_(void) {	
	printf("<======= GPU Reload Atom Positions ========>\n");
	HostMatrix<float3> atom_positions(fortran_vars.atoms);	// gpu version (float3)
	fortran_vars.atom_positions.resize(fortran_vars.atoms);	// cpu version (double3)
	for (uint i = 0; i < fortran_vars.atoms; i++) {
		double3 pos(fortran_vars.atom_positions_pointer.get(i, 0), fortran_vars.atom_positions_pointer.get(i, 1), fortran_vars.atom_positions_pointer.get(i, 2));
		fortran_vars.atom_positions.get(i) = pos;
		atom_positions.get(i) = make_float3(pos.x, pos.y, pos.z);		
	}
	atom_positions.to_constant("gpu_atom_positions");
}

extern "C" void gpu_new_grid_(const unsigned int& grid_type) {
	cout << "<======= GPU New Grid Loading (" << grid_type << ")========>" << endl;
	switch(grid_type) {
		case 0:
			fortran_vars.grid_type = SMALL_GRID; fortran_vars.grid_size = SMALL_GRID_SIZE;
			fortran_vars.e = fortran_vars.e1; fortran_vars.wang = fortran_vars.wang1;
			fortran_vars.shells = fortran_vars.shells1;
		break;
		case 1:
			fortran_vars.grid_type = MEDIUM_GRID; fortran_vars.grid_size = MEDIUM_GRID_SIZE;
			fortran_vars.e = fortran_vars.e2; fortran_vars.wang = fortran_vars.wang2;
			fortran_vars.shells = fortran_vars.shells2;
		break;
		case 2:
			fortran_vars.grid_type = BIG_GRID; fortran_vars.grid_size = BIG_GRID_SIZE;
			fortran_vars.e = fortran_vars.e3; fortran_vars.wang = fortran_vars.wang3;
			fortran_vars.shells = fortran_vars.shells2;
		break;
	}	
	
	regenerate_cubes();
	gpu_compute_cube_functions();
}
