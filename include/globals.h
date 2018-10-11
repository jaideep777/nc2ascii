#ifndef GLOBALS_H
#define GLOBALS_H

#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <gsm.h>
using namespace std;

const float hrsPerMonth = 24*365.2524f/12.0f;
//const float pi = 3.14159265358;

// log file!
extern ofstream log_fout;
extern bool info_on, debug_on;
#define loginfo  if (info_on)  log_fout << "<info> "
#define logdebug if (debug_on) log_fout << "<debug> "

// simulation time
extern string sim_date0, sim_t0, sim_datef, sim_tf;
extern float dt, dt_spinbio;
extern int sim_start_yr;
extern double gday_t0, gday_tf, gday_tb;
extern string tunits_out;
//extern double spin_gday_t0;
//extern double spin_bio_gday_t0;
extern string time_step;

// Model grid params
extern float mglon0, mglonf, mglat0, mglatf, mgdlon, mgdlat, mgdlev;
extern int mgnlons, mgnlats, mgnlevs;
extern vector <float> mglons, mglats, mglevs;
extern vector <double> mgtimes;
extern vector <float> grid_limits;

extern int nsteps;	// number of steps for which sim will run
extern int nsteps_spin; // number of spinup steps
extern int dstep; // progress display step 

// single point output
extern float xlon, xlat;
extern int i_xlon, i_xlat;
extern string pointOutFile;
extern bool spout_on;
extern ofstream sp_fout, point_fout;
extern bool l_ncout;


extern vector <gVar> vars;
extern vector <gVar> static_vars;
extern vector <gVar> mask_vars;

//// georeferenced variables
//extern gVar msk;		// mask
//extern gVar vegtype;	// forest type fractions
//extern gVar elev;		// elevation
//extern gVar albedo;		// surface albedo

//extern gVar pr;		// Precipitation (pr) 
//extern gVar rh;		// Relative Humidity (rh) 
//extern gVar ts;		// Surface Temperature (ts) 
//extern gVar wsp;	// Wind Speed (wsp) 
//extern gVar npp;	// NPP (npp) 
//extern gVar ffev;

//extern gVar canbio;		// canopy biomass
//extern gVar canbio_max;	// max canopy biomass for LAI calculation, set during canbio prerun
//extern gVar lmois;		// litter moisture (kg/m2 = mm)
//extern gVar cmois;		// canopy moisture content (kg/m2 = mm) 
//extern gVar dxl;		// litter layer thickness
//extern gVar fire;		// fire!
//extern gVar dfire;		// daily fire indices
//extern gVar ndr; 		// net downward radiation
//extern gVar ps;			// surface pressure
//extern gVar evap;		// potential evaporation rate
//extern gVar cld;		// cloud fraction


#endif

