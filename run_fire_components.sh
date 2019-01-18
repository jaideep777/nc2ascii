#!/bin/bash
FOLDER=output_globe
MODEL=AF_mod12

VARS=(cru_ts rd_tp4 cld cru_vp pop prev_npp )
USEV=(     1      0   0      0   0        0 )

#################################################################
#	Update code, folder names etc as per specified variables    #
#################################################################

rm -f nn_vars.txt tensorflow/nn_vars.py
touch nn_vars.txt 
N=${#VARS[@]}	# get length of variables array
XID="X_ids = ["
for ((i=0; i<$N; ++i)); do
#	echo ${VARS[$i]}
	if ((${USEV[$i]} == 1)); then
		echo ${VARS[$i]} >> nn_vars.txt
		V=$(sed "s/_//g" <<< ${VARS[$i]})	# remove underscore from variable name (for folder naming)
		MODEL=${MODEL}_$V					# append variable to model name
		XID=${XID}"ID_${VARS[$i]}, " 		# append to the X_ids array for tensorflow code
	fi
done
echo MODEL = $MODEL
XID=$(sed '$ s/.$//' <<< $XID)				# remove the trailing comma
XID=${XID}"] + ID_ft" 						# Add forest type
echo $XID

XIDLINE=$(grep -rn "X\_ids \= \[" tensorflow/nn_const_data_fire_v5_pureNN.py | cut -f1 -d:)	# Get the line that defines X_ids in the tensorflow code file
echo $XIDLINE
sed -i "${XIDLINE}s/.*/${XID}/" tensorflow/nn_const_data_fire_v5_pureNN.py	# Replace this line with the newly created X_ids 
echo "New -- " $XID

mkdir -p $FOLDER/$MODEL

make 

##################################################################
##	Run fire components                                         #
##################################################################

### Aggregate training data
##./nc2asc train params_newdata/params_ip_global.r
##Rscript Rscripts/prepare_train_eval_datasets.R

# Train NN
cd tensorflow
. runtf 
cd ..
cd $FOLDER
mv y_predic_ba_* ce_and_accuracy.txt weights_ba.txt $MODEL/
cd ..

# Run trained NN on data
./nc2asc eval params_newdata/params_ip_global.r $FOLDER/$MODEL/weights_ba.txt
###cdo ifthen /home/jaideep/Data/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,49.75 fire.2002-1-1-2015-12-31.nc fire_pred_masked.nc
mv fire.2003-1-1-2015-12-31.nc $FOLDER/$MODEL

# Plot results
cd Rscripts
Rscript plot_aggregate_maps_timeseries.R model_dir=$MODEL output_dir=$FOLDER

cd ..



