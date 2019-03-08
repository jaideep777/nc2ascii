#!/bin/bash

OUTDIR=output_globe
#MERGED_MOD='NHAF_mod140.2_gfedl1_cld_vp'	# best
MERGED_MOD=AF_mod56.5_ts_cld_vp 	# minimal
MERGED_TP=climate_only

#best 
MODELS=(NHAF_mod14.5_vp_pop_rdtot 
SHAF_mod90.4_gppm1s_ts_cld_pop 
)

#minimal
#MODELS=('SHAF_mod152.2_gfedl1_ts_cld'
#		'SA_mod48.1_pr_ts'
#		'SEAS_mod216.2_gfedl1_gppm1_ts_cld'
#		'CEAM_mod112.2_gppl1_pr_ts'
#		'TENA_mod240.2_gfedl1_gppl1_pr_ts'
#		'BONA_mod164.1_gfedl1_pr_vp'
#		'AUS_mod93.2_gppl1_ts_cld_vp_rdtot'
#		'CEAS_mod200.2_gfedl1_gppm1_cld')

cp ${OUTDIR}/$MERGED_MOD/fire.200*.nc merged_models/${MERGED_TP}/tmp.nc
for mod in "${MODELS[@]}"; do
	echo $mod
	cdo mergegrid merged_models/${MERGED_TP}/tmp.nc ${OUTDIR}/$mod/fire.200*.nc merged_models/${MERGED_TP}/tmp2.nc
	mv merged_models/${MERGED_TP}/tmp2.nc merged_models/${MERGED_TP}/tmp.nc
done
mv merged_models/${MERGED_TP}/tmp.nc merged_models/${MERGED_TP}/fire.nc



