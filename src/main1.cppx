#include <iostream>
#include "../include/init.h"
#include "../include/globals.h"
#include "../include/nnet.h"
#include <cmath>
#include <cstdlib>
using namespace std;

extern vector <gVar*> model_variables;	
extern map <string, string> static_var_files; 	// 
extern int init_modelvar(gVar &v, string var_name, string unit, int nl, vector<double> times_vec, ostream& lfout);

bool train, eval;

DenseNet fireNet;

ofstream train_fout;

float fire_classes_mids[] = {0, 1, 2, 8, 32, 128, 512, 1024};
float ba_classes_mids[] = {0.000000,   0.500000,   1.414214,   2.828427,   5.656854,  11.313708,  22.627417,  45.254834,  90.509668, 181.019336, 362.038672, 724.077344};

string tres = "monthly";

void init_train(){
	cout << "> Running in TRAIN mode." << endl;

	if (train){
		train_fout.open((out_dir+"/train_data.txt").c_str());
		// print header
		train_fout << "year" << "\t" << "month" << "\t" << "day" << "\t";
		train_fout << "lon" << "\t" << "lat" << "\t";
		train_fout << "forest_frac" << "\t" << "barren_frac" << "\t" << "agri_frac" << "\t";

		for (int i=0; i<model_variables.size(); ++i){
			if (model_variables[i]->varname != "vegtype")
				train_fout << model_variables[i]->varname << "\t";
		}
		train_fout << endl;
	}

}

void init_eval(){

	cout << "> Running in EVAL mode." << endl;
	
	try{
		fireNet.initFromFile(out_dir+"/weights_ba.txt", true);
		fireNet.activation_fcn = elu;
		fireNet.print();	
	}
	catch(string msg){
		cout << "Failed to open " << msg << endl;
		exit(-1);
	}
	
	int nmonths = (gday_tf - gday_t0 + 1 + 0.5)/365.2524*12; 
	vector <double> tvec;
	if (tres == "fortnightly"){
		tvec.resize(2*nmonths);
		for (int i=0; i<2*nmonths; ++i) tvec[i] = (gday_t0+6 + i*365.2524/12/2 - gday_tb)*24.0;
	}
	else if (tres == "monthly"){
		tvec.resize(nmonths);
		for (int i=0; i<nmonths; ++i) tvec[i] = (gday_t0+14 + i*365.2524/12 - gday_tb)*24.0;
	}
	init_modelvar( fire,  "fire",  "-",  1, tvec, log_fout); 

	string fname = out_dir+"/fire."+sim_date0+"-"+sim_datef+".nc";
	fire.createNcOutputStream(fname);

}


void write_train(int yr, int mon, int day){

	for (int ilat=0; ilat<mglats.size(); ++ilat){
	for (int ilon=0; ilon<mglons.size(); ++ilon){
//				if (ilat != i_xlat || ilon != i_xlon) continue;
//		if (msk(ilon,ilat,0) < 0.01 || msk(ilon, ilat,0) == msk.missing_value) continue;

		// write sample to training dataset				
		if (train){
			float forest_frac = 1 - vegtype(ilon, ilat, barren_pft_code) - vegtype(ilon, ilat, agri_pft_code);
			float cell_area = mgdlat*111e3*mgdlon*111e3*cos(mglats[ilat]*3.14159265/180);
			ba(ilon,ilat,0) /= cell_area;

			train_fout << yr << "\t" << mon << "\t" << day << "\t";
			train_fout << mglons[ilon] << "\t" << mglats[ilat] << "\t";
			train_fout << forest_frac << "\t" << vegtype(ilon, ilat, barren_pft_code) << "\t" << vegtype(ilon, ilat, agri_pft_code) << "\t";

			for (int i=0; i<model_variables.size(); ++i){
				string vname = model_variables[i]->varname;
				if (vname != "vegtype"){
					if (vname == "ffev")
						train_fout << (*model_variables[i])(ilon, ilat, 0)*daysInMonth(yr, mon) << "\t"; 
					else	
						train_fout << (*model_variables[i])(ilon, ilat, 0) << "\t"; 
				}
			}
			train_fout << endl;
		}
		
	}
	}

}

void write_eval(){

	static int tc = 0;
	
	for (int ilat=0; ilat<mglats.size(); ++ilat){
	for (int ilon=0; ilon<mglons.size(); ++ilon){
//		if (ilat != i_xlat || ilon != i_xlon) continue;
//		if (msk(ilon,ilat,0) < 0.01 || msk(ilon, ilat,0) == msk.missing_value) continue;

		// write nnet(sample) to nc file
		if (eval){

			if (mglons[ilon] == 88 && mglats[ilat] == 26.5){
				cout << rh(ilon, ilat, 0) << "\t"
					 << ts(ilon, ilat, 0) << "\t"
					 << wsp(ilon, ilat, 0) << "\t"
					 << dxl (ilon, ilat, 0) << "\t"
					 << lmois(ilon, ilat, 0)	 << " | \t";
//				cout << endl;
			}

			float x[] = {rh(ilon, ilat, 0),
						 ts(ilon, ilat, 0),
						 wsp(ilon, ilat, 0),
						 dxl (ilon, ilat, 0),
						 lmois(ilon, ilat, 0),
						 log(1+pop(ilon,ilat,0)),
						 vegtype(ilon, ilat, agri_pft_code)
						};
			Matrix X(1,7,x);
			Matrix Y = fireNet.forward_prop(X, true);
//			float nfires = 0;
//			for (int i=0; i<Y.m*Y.n; ++i) nfires += fire_classes_mids[i]*Y.data[i];

//					if (ilat == i_xlat && ilon == i_xlon){
//						cout << "X = ";
//						for (int k=0; k<3;++k) cout << X.data[k] << " ";
//						cout << "; Y = ";
//						for (int k=0; k<8;++k) cout << Y.data[k] << " ";
//						cout << "; fires predicted = " << nfires << endl;
//					}
			

			float ba_pred = 0;
			for (int i=0; i<Y.m*Y.n; ++i) ba_pred += ba_classes_mids[i]/1024.0*Y.data[i];

//			ba_pred -= 0.001;
//			if (ba_pred < 0) ba_pred = 0;
			//if (mglons[ilon] == 88 && mglats[ilat] == 26.5) cout << ba_pred << endl;
			fire(ilon, ilat, 0) = ba_pred; //exp(nfires/6.7)-1;
		}

	}
	}
	
	fire.writeVar(tc);
	++tc;
//	cout << tc << endl;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--> main_run()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int main_run(){

	int dstep = nsteps/40+1;

	int yr0 = gt2year(gday_t0);
	int mon0 = gt2month(gday_t0);

	int yrf = gt2year(gday_tf);
	int monf = gt2month(gday_tf);
	cout << "> Aggregation will run from " << yr0 << "-" << mon0 << " ---> " << yrf << "-" << monf << endl;

	int daystep = 0;
	if (tres == "monthly") daystep = 30.5;
	else if (tres == "fortnightly") daystep = 15;

	for (int yr = yr0; yr <= yrf; ++yr){
		for (int mon = mon0; mon <= monf; ++mon){
			for (int day = 1; day < 30; day+=daystep){
			
				if (yr == yrf && mon == monf) continue; 

				// construct range
				double gt0, gtf;
				
				double end_day;
				if (tres == "fortnightly") 	end_day = (day<15)? 16 : daysInMonth(yr,mon)+1;
				else if (tres == "monthly") end_day = daysInMonth(yr,mon)+1;

				gt0 = ymd2gday(yr,mon, day) + hms2xhrs("0:0:0");
				gtf = ymd2gday(yr,mon, end_day) + hms2xhrs("0:0:0") - 1.0/24;

				cout << "\taggregating " << gt2string(gt0) << " --- " << gt2string(gtf) << endl;

				// read variables
				for (int i=0; i<model_variables.size(); ++i){
					if (static_var_files.find(model_variables[i]->varname) != static_var_files.end()) continue; // variable is static
					if (model_variables[i]->varname == "fire") continue;
					
					model_variables[i]->readVar_reduce_mean(gt0, gtf);
					
				}			
												
				// write variables in train/eval mode
				if (train) write_train(yr, mon, day+6);
				if (eval) write_eval(); 
			}			
		}		
	}	

	
	cout << " > Done\n";
}








int main(int argc, char ** argv){

	if (argc < 2) {
		cout << "Need run mode as argument (train / eval)";
		return 1; 
	}
	
	train = (string(argv[1]) == "train");
	eval = (string(argv[1]) == "eval");
	
	if (argc > 2){
		sim_name = argv[2];
		out_dir += "_" + sim_name;
		params_dir += "_" + sim_name;
	}

	// ~~~~~~ Essentials ~~~~~~~~
	// set NETCDF error behavior to non-fatal
	NcError err(NcError::silent_nonfatal);
	
	// speficy log file for gsm
	ofstream gsml((out_dir+"/gsm_log.txt").c_str());
	gsm_log = &gsml;


	init_firenet();
	
	if (train) init_train();
	if (eval) init_eval();

	main_run();
	
//	cout << "here" << endl;
	if (train) train_fout.close();
	if (eval) fire.closeNcOutputStream();
	
	return 0;
	
}




