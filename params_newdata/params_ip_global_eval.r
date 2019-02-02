# this file specifies the locations and name of all input files
# this line is comment (there MUST be a space after #)

> FORCING_DATA_DIRS

forcing_data_dir	/home/chethana/Data

# var |	  dir
# ts			ncep_reanalysis/ts
ts			Fire
vp			Fire
# cru_tmx		CRU_TS4.02
rh			Fire
wsp			Fire
# trmm		precip_trmm/combined/reordered_dims
pr			Fire
prl1		Fire
prl2		Fire
# ndr			ndr_daily
gppl1		Fire
gppl2		Fire
gppm1		Fire
gppm1s		Fire
# ffev		fire_events_modis/india/fire_modis_0.5
# ba		fire_BA/fire_fire_calib
gfed		Fire
gfedl1		Fire
cld			Fire
# prev_cld	MODISAL2_cloud_fraction/nc_merged
pop			Fire
	

> FORCING_VARIABLE_DATA
# name | unit 	|	prefix   		|	start_yr |	end_yr | nyrs/file | nlevs |    T mode			| Interpolation
# ts		 K			air.sig995			2000		2015		1			1		linear			 bilinear
ts	 	 degC		ts					2003		2015		13			1		linear			 none
vp	 	 hPa		vp					2003		2015		13			1		linear			 none
# cru_tmx	 degC		cru_ts4.02.tmx		1901		2017		117			1		linear			 coarsegrain
rh		 %			rh					2003		2015		13			1		linear			 none
wsp		 m/s		wsp					2003		2015		13			1		linear			 none
# trmm	 mm/day		pr.trmm-perm		2000		2015		1			1		linear			 coarsegrain
pr		 mm/day		pr					2003		2015		13			1		linear			 none
prl1	 mm/day		prl1				2003		2015		13			1		linear			 none
prl2	 mm/day		prl2				2003		2015		13			1		linear			 none
# ndr		 W/m2/hr	ndr_daily			2000		2000		1			1		cyclic_yearly	 bilinear
# npp		 gC/m2/s	npp					2000		2015		16			1		linear			 bilinear
# ffev	 f/day		fire_events			2000		2015		1			1		linear			 bilinear
# ba	 m2			burned_area_0.5deg	2001		2016		16			1		linear		 	 bilinear
gfed	 %			gfed				2003 		2015		13			1		linear			 none
gfedl1	 %			gfedl1				2003 		2015		13			1		linear			 none
cld		 -			cld					2003		2015		13			1		linear			 none
# prev_ba	 %			GFED_4.1s			1997 		2016		20			1		prev_yearly		 coarsegrain
gppl1 	 gC/m2/s	gppl1				2003		2015		13			1		linear			 none
gppl2 	 gC/m2/s	gppl2				2003		2015		13			1		linear			 none
gppm1 	 gC/m2/s	gppm1				2003		2015		13			1		linear			 none
gppm1s 	 gC/m2/s	gppm1s				2003		2015		13			1		linear		 	 none
# prev_pr	 mm/day		pr.trmm-perm		2000		2015		1			1		prev_yearly		 coarsegrain		
# prev_cld -			MODAL2_M_CLD_FR		2001		2018		1			1		prev_yearly		 coarsegrain
pop		 - 			pop					2003		2015		13			1		linear			 none

# file name will be taken as "prefix.yyyy.nc" or "prefix.yyyy-yyyy.nc"
# value types: ins (instantaneous), sum, avg (not used as of now)
# time_interp_modes: auto, hold, lter (not used as of now)
#	hold = hold previous value till next value is available
#	lter = interpolate in-between values (using previous and next times)
#	auto = hold for avg variables, lter for ins variables, sum-conservative random for sum variables

> STATIC_INPUT_FILES
# var	|	nlevs | interp			| file 
ftmap 		12 		coarsegrain		  forest_type/MODIS/ftmap_modis_global_0.25deg_12levs.nc
# elev		1		bilinear		  util_data/elevation/elev.0.5-deg.nc
dft			1		nearest		  	  forest_type/MODIS/dft_MODIS_global_12lev_agri-bar_lt0.5_1deg.nc
# pop			1		coarsegrain		  World_population_density/GHS_POP_GPW42000_GLOBE_R2015A_54009_1k_v1_0/GHS_pop_GPW42000_reprojected_Globe.nc    
rdtot	 	1 		coarsegrain		  Global_road_density/GRIP4_density_total/grip4_total_dens_m_km2.nc		
# rd_tp1	 	1 		coarsegrain		  Global_road_density/GRIP4_density_tp1/grip4_tp1_dens_m_km2.nc		
# rd_tp2	 	1 		coarsegrain		  Global_road_density/GRIP4_density_tp2/grip4_tp2_dens_m_km2.nc		
rdtp3	 	1 		coarsegrain		  Global_road_density/GRIP4_density_tp3/grip4_tp3_dens_m_km2.nc		
rdtp4	 	1 		coarsegrain		  Global_road_density/GRIP4_density_tp4/grip4_tp4_dens_m_km2.nc		
# rd_tp5	 	1 		coarsegrain		  Global_road_density/GRIP4_density_tp5/grip4_tp5_dens_m_km2.nc		
region		1		nearest		  	  Fire_BA_GFED4.1s/ancil/basis_regions.nc


> MASKS
# var	|	interp 			| file 
ftmask		none 	  	  	  forest_type/MODIS/ftmask_MODIS_global_1deg.nc
msk			bilinear 	 	  util_data/masks/surta_global_0.5_sl.nc


> TIME
timestep 	monthly
start_date	2003-1-1
start_time	0:0:0
end_date	2015-12-31
end_time	23:0:0	
dt			24
base_date	1950-1-1


> MODEL_GRID
lon0	-179.5
lonf	179.5
lat0	-89.5
latf	89.5
dlat	1
dlon	1


> OUTPUT_FILE
outfile 	output_globe/train_data.txt


> END


