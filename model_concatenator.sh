#!/bin/bash

OUTDIR=output_globe
#MERGED_MOD='NHAF_mod84.5_pr_cld_pop'	# best
MERGED_MOD='NHAF_mod84.5_pr_cld_pop' 	# minimal
MERGED_TP=minimal_v5

##best 
#MODELS=('SHAF_mod176.5_gppl1_ts_cld'
#'SA_mod502.5_gpp_gppm1s_pr_ts_cld_pop_rdtot'
#'SEAS_mod510.5_gpp_gppm1_pr_ts_cld_vp_pop_rdtot'
#'TCAM_mod497.5_gpp_gppl1_pr_ts_cld_ftmap11'
#'BONA_mod504.5_gpp_gppl1_pr_ts_cld_vp'
#'AUS_mod440.5_gpp_gppl1_ts_cld_vp'
#'CEAS_mod216.5_gppl1_pr_cld_vp'
#'BOAS_mod232.5_gppm1_pr_ts_vp'
#'EQAS_mod112.5_pr_ts_cld'
#'EUME_mod80.5_pr_cld' )

#minimal
MODELS=('SHAF_mod176.5_gppl1_ts_cld'
'SA_mod496.5_gpp_gppm1s_pr_ts_cld'
'SEAS_mod500.5_gpp_gppm1_pr_ts_cld_pop'
'TCAM_mod480.5_gpp_gppl1_pr_ts'
'BONA_mod448.5_gpp_gppl1_pr'
'AUS_mod400.5_gpp_gppl1_cld'
'CEAS_mod216.5_gppl1_pr_cld_vp'
'BOAS_mod232.5_gppm1_pr_ts_vp'
'EQAS_mod64.5_pr' 
'EUME_mod80.5_pr_cld' )

cp ${OUTDIR}/$MERGED_MOD/fire.200*.nc merged_models/${MERGED_TP}/tmp.nc
for mod in "${MODELS[@]}"; do
	echo $mod
	cdo mergegrid merged_models/${MERGED_TP}/tmp.nc ${OUTDIR}/$mod/fire.200*.nc merged_models/${MERGED_TP}/tmp2.nc
	mv merged_models/${MERGED_TP}/tmp2.nc merged_models/${MERGED_TP}/tmp.nc
done
mv merged_models/${MERGED_TP}/tmp.nc merged_models/${MERGED_TP}/fire.2002-1-1-2015-12-31.nc



