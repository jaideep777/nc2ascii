#include <iostream>
#include "../include/multincreader.h"
#include "../include/nnet.h"
//#include "../include/runs.h"
using namespace std;

//float ba_classes_mids[] = {0.000000,   0.500000,   1.414214,   2.828427,   5.656854,  11.313708,  22.627417,  45.254834,  90.509668, 181.019336, 362.038672, 724.077344};

float ba_classes_mids[] = {
	         0.0, 1.333521e-06, 2.371374e-06, 4.216965e-06, 7.498942e-06, 1.333521e-05, 2.371374e-05, 4.216965e-05, 7.498942e-05, 1.333521e-04, 2.371374e-04,
	4.216965e-04, 7.498942e-04, 1.333521e-03, 2.371374e-03, 4.216965e-03, 7.498942e-03, 1.333521e-02, 2.371374e-02, 4.216965e-02, 7.498942e-02, 1.333521e-01,
	2.371374e-01, 4.216965e-01, 7.498942e-01};

string regions_names[] = {"BONA (Boreal North America)",				// 1
				          "TENA (Temperate North America)",				// 2
				          "CEAM (Central America)",						// 3
				          "NHSA (Northern Hemisphere South America)",	// 4
				          "SHSA (Southern Hemisphere South America)",	// 5
				          "EURO (Europe)",								// 6
				          "MIDE (Middle East)",							// 7
				          "NHAF (Northern Hemisphere Africa)",			// 8
				          "SHAF (Southern Hemisphere Africa)",			// 9
				          "BOAS (Boreal Asia)",							// 10
				          "CEAS (Central Asia)",						// 11
				          "SEAS (Southeast Asia)",						// 12
				          "EQAS (Equatorial Asia)",						// 13
				          "AUST (Australia and New Zealand)"};			// 14

	
bool train, eval;

DenseNet fireNet;
gVar fire;

inline int printRunHeader(string s, double gt0, double gtf, int ns, int ds){
	cout << "\n****************************************************************\n\n";
	cout << s << " will run for " << ns << " steps.\n";
	cout << "\t" << gt2string(gt0) << " --- " << gt2string(gtf) << "\n";
	cout << "progress will be displayed after every " << ds << " steps\n";
	if (ds == 1) cout << "progress (#steps) >> ";
	else cout << "progress (%) >> "; cout.flush();
}


void init_eval(MultiNcReader &R, string wts_file, string out_dir){

	cout << "> Running in EVAL mode." << endl;
	
	try{
		cout << "> Reading Weights file " << wts_file;
		fireNet.initFromFile(wts_file, true);
		fireNet.activation_fcn = elu;
		cout << " | DONE.\n";
		fireNet.print();	
	}
	catch(string msg){
		cout << "Failed to open " << msg << endl;
		exit(-1);
	}
	
	int nmonths = (R.gday_tf - R.gday_t0 + 1 + 0.5)/365.2524*12; 
	vector <double> tvec(R.nsteps);
//	if (R.time_step == "fortnightly"){
//		tvec.resize(2*nmonths);
//		for (int i=0; i<2*nmonths; ++i) tvec[i] = (R.gday_t0+6 + i*365.2524/12/2 - R.gday_tb)*24.0;
//	}
//	else if (R.time_step == "monthly"){
//		tvec.resize(nmonths);
//		for (int i=0; i<nmonths; ++i) tvec[i] = (R.gday_t0+14 + i*365.2524/12 - R.gday_tb)*24.0;
//	}
	for (int t=0; t<R.nsteps; ++t) tvec[t] = (R.gday_t0 - R.gday_tb)*24.0 + t*R.dt;
	

	vector <float> levs1(1,0);
	fire = gVar("fire", "-", "hours since "+gday2ymd(R.gday_tb));
	fire.setCoords(tvec, levs1, R.mglats, R.mglons);
	fire.fill(fire.missing_value);

	string fname = out_dir + "/fire."+R.sim_date0+"-"+R.sim_datef+".nc";
	cout << "Creating output nc file: " << fname << endl;
	fire.createNcOutputStream(fname);

}


void write_eval(MultiNcReader &R, string vars_file){

	static int tc = 0;	
	
	for (int ilat=0; ilat<R.mglats.size(); ++ilat){
	for (int ilon=0; ilon<R.mglons.size(); ++ilon){
		
		int r1 = 12;
		int r2 = 12;
		
		int region = R.getVar("region")(ilon, ilat, 0);
		if (region != r1 && region != r2) continue;
		
		if (! R.ismasked(ilon,ilat)){ 
			float ba_pred = 0;
			vector <float> x;
			
			ifstream fin(vars_file.c_str());
			string var;
			while (fin >> var){
				float val;
				if      (var == "ftmap11") val = R.getVar("ftmap")(ilon, ilat, 11);
				else if (var == "lat")     val = R.mglats[ilat];
				else                       val = R.getVar(var)(ilon, ilat, 0);

				if (var == "rdtp3")  val = log(val + 1);
				if (var == "rdtp4")  val = log(val + 1);

				if (var == "pop")    val = log(val + 1);
				if (var == "gfedl1") val = log(val + 1e-5);
				if (var == "pr")     val = log(val + 1);
				if (var == "rdtot")  val = log(val + 1);
				if (var == "gfedl06") val = log(val + 1e-5);
				if (var == "gfedl04") val = log(val + 1e-5);
				
				
				x.push_back(val);
			}

		
//			x.push_back(R.getVar("cru_ts")(ilon, ilat, 0));
////			x.push_back(log(1+R.getVar("rd_tp3")(ilon, ilat, 0)));
//			x.push_back((R.getVar("rd_tp4")(ilon, ilat, 0)));
//			x.push_back(R.getVar("cld")(ilon, ilat, 0));
////			x.push_back(R.getVar("ndr")(ilon, ilat, 0));

//			x.push_back(R.getVar("cru_vp")(ilon, ilat, 0));
//			x.push_back((R.getVar("pop")(ilon, ilat, 0)));
////			x.push_back(log(1+R.getVar("pr")(ilon, ilat, 0)));
////			x.push_back(R.getVar("prev_pr")(ilon, ilat, 0));
//			x.push_back(R.getVar("prev_npp")(ilon, ilat, 0));
////			x.push_back(log(1e-5+R.getVar("prev_ba")(ilon, ilat, 0)));
////			x.push_back(log(1+R.getVar("npp")(ilon, ilat, 0)));

////			x.push_back(R.getVar("wsp")(ilon, ilat, 0));

			for (int ilev=0; ilev<R.getVar("ftmap").nlevs-1; ++ilev)	// this excludes ftmap11 (croplands)
				x.push_back(R.getVar("ftmap")(ilon, ilat, ilev));


//			for (int i=0; i< x.size(); ++i) cout << x[i] << " ";
//			cout << endl;

			Matrix X(1, x.size(), x);
			Matrix Y = fireNet.forward_prop(X, true);

			for (int i=0; i<Y.m*Y.n; ++i) ba_pred += ba_classes_mids[i]*Y.data[i];
			fire(ilon, ilat, 0) = ba_pred; //exp(nfires/6.7)-1;

		}
		else{
			fire(ilon, ilat, 0) = fire.missing_value; //exp(nfires/6.7)-1;
		}

	}
	}
	
	fire.writeVar(tc);
	++tc;
//	cout << tc << endl;

}


int main_run(MultiNcReader &R, string vars_file){

	int dstep = R.nsteps/40+1;

	printRunHeader("Main run", R.gday_t0, R.gday_t0 + (R.nsteps-1)*(R.dt/24.0), R.nsteps, dstep);
	cout << endl;

	for (int istep = 0; istep < R.nsteps; ++istep){
		
		double t = R.nc_read_frame(istep);
		
//		if (istep == 0){
//			for (int i=0; i<R.vars.size(); ++i){
//				string fname = R.vars[i].varname + int2str(istep) + ".nc";
//				R.vars[i].writeOneShot(fname);
//			}

//			for (int i=0; i<R.static_vars.size(); ++i){
//				string fname = R.static_vars[i].varname + int2str(istep) + ".nc";
//				R.static_vars[i].writeOneShot(fname);
//			}
//		}		

		if (train) R.ascii_write_frame(t);
		if (train) R.nc_write_frame(istep);

		if (eval) write_eval(R, vars_file);
		
//		if (istep % dstep == 0) {cout << "."; cout.flush();}
	}	

	cout << " > 100%\n";
}


// usage: ./nc2asc 

int main(int argc, char ** argv){

	// ~~~~~~ Essentials ~~~~~~~~
	// set NETCDF error behavior to non-fatal
	//NcError err(NcError::silent_nonfatal);
	
	// speficy log file for gsm
	ofstream gsml("output/gsm_log.txt");
	gsm_log = &gsml;

	train = (string(argv[1]) == "train");
	eval = (string(argv[1]) == "eval");

	MultiNcReader R(argv[2]);
	if (train) R.ascout = true;
	if (train) R.ncout  = true;

	R.init();

	string out_dir, weights_file, vars_file;
	if (eval) {
		out_dir = argv[3];
		weights_file = out_dir + "/" + argv[4];
		vars_file = out_dir + "/" + argv[5];
		init_eval(R, weights_file, out_dir);
	}


	main_run(R, vars_file);

	if (eval) fire.closeNcOutputStream();

	R.close();

	
	return 0;
}




