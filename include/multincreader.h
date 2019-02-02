#ifndef MULTI_NC_READER_H
#define MULTI_NC_READER_H

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
	string 				interpolation;			// spatial interpolation strategy - bilinear, nn, or coarsegrain?
	
	vector <string>		fnames;					// list of filenames (genrated during init)
	
	ip_data(); 
	ip_data(string _n, string _u, string _fnp, int _sy, int _ey, int _ny, int _nl, string _mode, string _interpolation); 
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

	// log file!
	ofstream log_fout;
	bool info_on, debug_on;

	// output
	bool ascout, ncout;
	string pointOutFile, ncoutDir;
	ofstream point_fout;

	// global variables for use in this file only
	string attrbegin;

	map <string, string> data_dirs;			// list of named dirs
	map <string, ip_data> ip_data_map;		// ---
	map <string, string> static_var_files; 	// 
	map <string, int> static_var_nlevs; 	// 
	map <string, string> static_var_interp; 	// 
	map <string, string> mask_var_files; 	// 
	map <string, string> mask_var_interp; 	// 

	vector <gVar*> model_variables;			// using a vector here allows control over order of variables
	map<string, gVar*> all_vars_map;			// using a map here allows quick searching of variables by name 

	public:
	vector <gVar> vars;
	vector <gVar> static_vars;
	vector <gVar> mask_vars;

	public:
	
	MultiNcReader(string file);
	
	gVar& getVar(string s);
	bool hasVar(string s);
	
	int read_params_file();
	int create_sim_config();

	int init_modelvar(gVar &v, string var_name, string unit, int nl, vector<double> times_vec, ostream& lfout);

	int init_vars();
	
	int init();

	double nc_read_frame(int istep);

	int ascii_write_frame(double gt);
	int nc_write_frame(int islice);

	int close();

	bool ismasked(int ilon, int ilat);

};



#endif



