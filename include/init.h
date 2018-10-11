#ifndef INIT_H
#define INIT_H

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <map>
using namespace std;

#include <gsm.h>


// this class stores all meta-info of input variables
class ip_data {
public:
	// data supplied from ip-params file
	string 				name;					// variable name
	string 				unit;					// unit
	string 				fname_prefix;			// prefix in filename
	int 				start_yr, end_yr;		// start yr, end yr 
	int 				nyrs_file;				// #yrs in file (1 or more)
	int 				nlevs;
	string 				mode;					// should data be interpreted as linear (exact date provided must be looked for OR cyclic - only day in year is relevant)
	
	vector <string>		fnames;					// list of filenames (genrated during init)
	
	ip_data(); 
	ip_data(string _n, string _u, string _fnp, int _sy, int _ey, int _ny, int _nl, string _mode); 
	int generate_filenames(string dir = "");
	void print(ostream &fout1);
	
};

// READ PARAMS FILES
int read_ip_params_file();
int read_sim_config_file();
int read_veg_params_file();


int init_firenet();

double read_nc_input_files(int istep);

int write_ascii_output(double gt);
int write_nc_output(int islice);

int close_firenet();

#endif



