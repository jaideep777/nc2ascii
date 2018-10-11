#include <iostream>
#include "../include/init.h"
#include "../include/globals.h"
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

extern map<string, ip_data> ip_data_map;


int main_run(){

	int dstep = nsteps/40+1;

	printRunHeader("Main run", gday_t0, gday_t0 + (nsteps-1)*(dt/24.0), nsteps, dstep);
	cout << endl;

	for (int istep = 0; istep < nsteps; ++istep){
		
		double t = read_nc_input_files(istep);
		write_ascii_output(t);
		
//		if (istep % dstep == 0) {cout << "."; cout.flush();}
	}	

	cout << " > 100%\n";
}




int main(){

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

	init_firenet();
	
//	prerun_canbio_ic();
//	prerun_lmois_ic();
	main_run();
	
	close_firenet();
	
	return 0;
}


