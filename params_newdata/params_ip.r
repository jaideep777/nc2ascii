# this file specifies the locations and name of all input files
# this line is comment (there MUST be a space after #)

> FORCING_DATA_DIRS

forcing_data_dir	/home/jaideep/Data
# var |	  dir
ts		ncep_reanalysis/ts
rh		ncep_reanalysis/rhum
wsp		ncep_reanalysis/wsp
pr		precip_trmm/combined/reordered_dims
ndr		ndr_daily
npp		GPP_modis
# ffev	fire_events_modis/india/fire_modis_0.5
# ba		fire_BA/fire_fire_calib
gfed	Fire_BA_GFED4.1s/nc
prev_ba	Fire_BA_GFED4.1s/nc
cld		ncep_reanalysis/cld
prev_npp	GPP_modis

> FORCING_VARIABLE_DATA
# name | unit 	|	prefix   		|	start_yr |	end_yr | nyrs/file | nlevs |    T mode			| Interpolation
ts		 K			air.sig995			2000		2015		1			1		linear			
rh		 %			rhum.sig995			2000		2015		1			1		linear			
wsp		 m/s		wsp.sig995			2000		2015		1			1		linear			
pr		 mm/day		pr.trmm-perm		2000		2015		1			1		linear			
ndr		 W/m2/hr	ndr_daily			2000		2000		1			1		cyclic_yearly	
npp		 gC/m2/s	npp					2000		2015		16			1		linear			
# ffev	 f/day		fire_events			2000		2015		1			1		linear			
# ba		 m2			burned_area_0.5deg	2001		2016		16			1		linear		
gfed	 %			GFED_4.1s_0.5deg	1997 		2016		20			1		linear			
cld		 -			tcdc.eatm.gauss		2000		2015		1			1		linear			
prev_ba	 %			GFED_4.1s_0.5deg	1997 		2016		20			1		prev_yearly		
prev_npp gC/m2/s	npp					2000		2015		16			1		prev_yearly

# file name will be taken as "prefix.yyyy.nc" or "prefix.yyyy-yyyy.nc"
# value types: ins (instantaneous), sum, avg (not used as of now)
# time_interp_modes: auto, hold, lter (not used as of now)
#	hold = hold previous value till next value is available
#	lter = interpolate in-between values (using previous and next times)
#	auto = hold for avg variables, lter for ins variables, sum-conservative random for sum variables
	
> STATIC_INPUT_FILES
# var	|	nlevs | file 
ftmap 		11 		forest_type/MODIS/ftmap_modis_SASplus_0.5deg_11levs_noMixed.nc
elev		1		util_data/elevation/elev.0.5-deg.nc
dft			1		forest_type/MODIS/dft_MODIS11lev_agri-bar_lt0.5_0.5deg.nc
pop			1		World_population_density/GHS_POP_GPW42000_GLOBE_R2015A_54009_1k_v1_0/GHS_pop_GPW42000_SSAplus_0.5deg.nc

> MASKS
# var	|	file 
ftmask		forest_type/MODIS/ftmask_MODIS_0.5deg.nc
msk			util_data/masks/surta_global_0.5_sl.nc


> TIME
timestep 	monthly
start_date	2007-1-1
start_time	0:0:0
end_date	2015-12-31
end_time	23:0:0	
dt			24
base_date	1950-1-1


> MODEL_GRID
lon0	60.25
lonf	99.75
lat0	5.25
latf	49.75
dlat	0.5
dlon	0.5


> OUTPUT_FILE
outfile 	output_ssaplus_pureNN/train_data.txt


> END


