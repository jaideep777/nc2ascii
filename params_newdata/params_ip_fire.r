# this file specifies the locations and name of all input files
# this line is comment (there MUST be a space after #)

> FORCING_DATA_DIRS

forcing_data_dir	/media/jaideep/WorkData/Fire_G
# var |	  dir
ts		ncep_reanalysis/ts
rh		ncep_reanalysis/rhum
wsp		ncep_reanalysis/wsp
pr		precip_imd
npp		GPP_modis
cld		ncep_reanalysis/cld

> FORCING_VARIABLE_DATA
# name | unit 	|	prefix   	|	start_yr |	end_yr | nyrs/file | nlevs | mode
ts		 K			air.sig995		2000		2015		1			1
rh		 %			rhum.sig995		2000		2015		1			1
wsp		 m/s		wsp.sig995		2000		2015		1			1	
pr		 mm/day		rf_imd			2000		2015		1			1
npp		 gC/m2/s	npp				2000		2015		16			1
cld		 -			tcdc.eatm.gauss	2000		2015		1			1

# file name will be taken as "prefix.yyyy.nc" or "prefix.yyyy-yyyy.nc"
# value types: ins (instantaneous), sum, avg (not used as of now)
# time_interp_modes: auto, hold, lter (not used as of now)
#	hold = hold previous value till next value is available
#	lter = interpolate in-between values (using previous and next times)
#	auto = hold for avg variables, lter for ins variables, sum-conservative random for sum variables

> STATIC_INPUT_FILES
# var	|	nlevs | file 
msk			1		util_data/masks/surta_india_0.2.nc
vegtype		8		forest_type/IIRS/netcdf/ftmap_iirs_8pft.nc
albedo		1		albedo/albedo.avg.2004.nc
elev		1		util_data/elevation/elev.0.5-deg.nc

> TIME
timestep 	fortnightly
start_date	2005-1-7
start_time	0:0:0
end_date	2006-12-31
end_time	23:0:0	
dt			24
base_date	1950-1-1

> MODEL_GRID
lon0	66.5
lonf	67.5
lat0	6.5
latf	7.5
dlat	0.5
dlon	0.5


> END


