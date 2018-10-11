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


class MultiNcReader{
	public:
	
	string params_file;

	int nvars;	// number of variables in the reader (exckuding masks)
	
	// simulation time
	string sim_date0, sim_t0, sim_datef, sim_tf;
	float dt;
//	int sim_start_yr;
	double gday_t0, gday_tf, gday_tb;
	string tunits_out;		
	string time_step;		// daily / monthly / yearly, etc.

	// Model grid params
	float mglon0, mglonf, mglat0, mglatf, mgdlon, mgdlat, mgdlev;
	int mgnlons, mgnlats, mgnlevs;
	vector <float> mglons, mglats, mglevs;
	vector <double> mgtimes;
	vector <float> grid_limits;

	int nsteps;			// number of steps for which sim will run
//	int nsteps_spin; 	// number of spinup steps
//	int dstep; 			// progress display step 

	// log file!
	ofstream log_fout;
	bool info_on, debug_on;

	// single point output
//	float xlon, xlat;
//	int i_xlon, i_xlat;
	string pointOutFile;
//	bool spout_on;
//	ofstream sp_fout;
	ofstream point_fout;
//	bool l_ncout;

	// global variables for use in this file only
	string attrbegin;
//	bool l_ip_init_done;

	map <string, string> data_dirs;			// list of named dirs
	map <string, ip_data> ip_data_map;		// ---
	map <string, string> static_var_files; 	// 
	map <string, int> static_var_nlevs; 	// 
	map <string, string> mask_var_files; 	// 
//	map <string, bool> writeVar_flags;		// 
//	map <string, bool> writeVarSP_flags;	// maps from var_name to other things

	vector <gVar*> model_variables;			// using a vector here allows control over order of variables
	map<string, gVar*> all_vars_map;			// using a map here allows quick searching of variables by name 

	public:
	vector <gVar> vars;
	vector <gVar> static_vars;
	vector <gVar> mask_vars;

	public:
	
	MultiNcReader(string file);
	
	gVar& getVar(string s);
	
	int read_ip_params_file();
	int create_sim_config();

	int init_modelvar(gVar &v, string var_name, string unit, int nl, vector<double> times_vec, ostream& lfout);

	int init_vars();
	int init_firenet();

	double read_nc_input_files(int istep);

	int write_ascii_output(double gt);
	int write_nc_output(int islice);

	int close_firenet();

};



#endif



