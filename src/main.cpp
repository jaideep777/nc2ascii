#include <iostream>
#include "../include/multincreader.h"
//#include "../include/globals.h"
//#include "../include/runs.h"
using namespace std;


inline int printRunHeader(string s, double gt0, double gtf, int ns, int ds){
	cout << "\n****************************************************************\n\n";
	cout << s << " will run for " << ns << " steps.\n";
	cout << "\t" << gt2string(gt0) << " --- " << gt2string(gtf) << "\n";
	cout << "progress will be displayed after every " << ds << " steps\n";
	if (ds == 1) cout << "progress (#steps) >> ";
	else cout << "progress (%) >> "; cout.flush();
}


int main_run(MultiNcReader &R){

	int dstep = R.nsteps/40+1;

	printRunHeader("Main run", R.gday_t0, R.gday_t0 + (R.nsteps-1)*(R.dt/24.0), R.nsteps, dstep);
	cout << endl;

	for (int istep = 0; istep < R.nsteps; ++istep){
		
		double t = R.read_nc_input_files(istep);
		R.write_ascii_output(t);
		
//		if (istep % dstep == 0) {cout << "."; cout.flush();}
	}	

	cout << " > 100%\n";
}




int main(int argc, char ** argv){

	// ~~~~~~ Essentials ~~~~~~~~
	// set NETCDF error behavior to non-fatal
	NcError err(NcError::silent_nonfatal);
	
	// speficy log file for gsm
	ofstream gsml("output/gsm_log.txt");
	gsm_log = &gsml;

//	// create a grid limits vector for convenience
//	float glimits[] = {0, 150, -60, 60};
//	vector <float> glim(glimits, glimits+4);
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~
	MultiNcReader R(argv[1]);

	R.init_firenet();
	
//	prerun_canbio_ic();
//	prerun_lmois_ic();
	main_run(R);
	
	R.close_firenet();
	
	return 0;
}


