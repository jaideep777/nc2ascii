# this file specifies the locations and name of all input files
# this line is comment (there MUST be a space after #)

> FORCING_DATA_DIRS

forcing_data_dir	/home/jaideep/Data
# var |	  dir
ba		Fire_BA_GFED4.1s/nc
ba0.5	Fire_BA_GFED4.1s/nc

> FORCING_VARIABLE_DATA
# name | unit 	|	prefix   		|	start_yr |	end_yr | nyrs/file | nlevs |    T mode			| Interpolation
ba	    %			GFED_4.1s 			1997 		2016		20			1		linear			 coarsegrain
ba0.5	%			GFED_4.1s_0.5deg	1997		2016		20			1		linear			 coarsegrain

# file name will be taken as "prefix.yyyy.nc" or "prefix.yyyy-yyyy.nc"
# value types: ins (instantaneous), sum, avg (not used as of now)
# time_interp_modes: auto, hold, lter (not used as of now)
#	hold = hold previous value till next value is available
#	lter = interpolate in-between values (using previous and next times)
#	auto = hold for avg variables, lter for ins variables, sum-conservative random for sum variables

> STATIC_INPUT_FILES
# var	|	nlevs | interp			| file 
pop			1		coarsegrain		  World_population_density/GHS_POP_GPW42000_GLOBE_R2015A_54009_1k_v1_0/GHS_pop_GPW42000_reprojected_Globe.nc

> MASKS
# var	|	interp 			| file 


> TIME
timestep 	monthly
start_date	2002-1-1
start_time	0:0:0
end_date	2002-1-31
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
outfile 	test.txt


> END


