#!/bin/bash
FOLDER=output_ssaplus_pureNN
EXPT=mod1_full

mkdir -p $FOLDER/$EXPT

make 

## Aggregate training data
#./nc2asc train params_newdata/params_ip.r
#Rscript Rscripts/prepare_train_eval_datasets.R

# Train NN
cd tensorflow
./runtf 
cd ..
cd $FOLDER
mv y_predic_ba_* ce_and_accuracy.txt weights_ba.txt $EXPT/
cd ..

# Run trained NN on data
./nc2asc eval params_newdata/params_ip.r $FOLDER/$EXPT/weights_ba.txt
cdo ifthen /home/jaideep/Data/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,49.75 fire.2002-1-1-2015-12-31.nc fire_pred_masked.nc
mv fire.2002-1-1-2015-12-31.nc fire_pred_masked.nc $FOLDER/$EXPT

# Plot results
cd Rscripts
Rscript plot_aggregate_maps_timeseries.R 

cd ..

