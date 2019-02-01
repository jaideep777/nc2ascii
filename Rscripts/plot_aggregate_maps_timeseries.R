rm(list = ls())

## CREATE timeseries	
library(ncdf4)
library(chron)

fire_dir = "~/codes/PureNN_fire"
output_dir = "output_globe_runs_v1"
model_dir = "SEAS_mod5_cruts_cld_cruvp_pop_prevnpp"

# for (model_dir in list.files(path = paste0(fire_dir,"/",output_dir), no.. = T, pattern = "mod")){

fire_obs_file = "/home/jaideep/Data/Fire_BA_GFED4.1s/nc/GFED_4.1s_1deg.1997-2016.nc"  # Need absolute path here
fire_pred_file = "fire.2003-1-1-2015-12-31.nc"

start_date  = "2003-1-1"
end_date    = "2014-12-31"

# Get model_dir from command line
args = commandArgs(trailingOnly = T)
l = (strsplit(x = args, split = "="))
opt = unlist(lapply(l, "[[", 1))
spec = unlist(lapply(l, "[[", 2))

findOpt = function(o){
  ! (is.null(spec[opt==o]) | length(which(opt == o)) == 0)
}

if (findOpt("model_dir")) model_dir = spec[opt=="model_dir"]
if (findOpt("output_dir")) output_dir = spec[opt=="output_dir"]


# cat("model_dir = ", model_dir, "\n")
# cat("output_dir = ", output_dir, "\n")

source(paste0(fire_dir, "/Rscripts/utils.R"))

mha_per_m2 = 0.0001/1e6


# for (mod in c("gfed_xcf")){ #}, "xdxl", "xlmois", "xts", "xpop", "xrh", "xwsp", "xrh_lmois")){
#
#   for (i in 1:10){
    # model = paste0(mod, "_", i)

    setwd(paste0(fire_dir,"/",output_dir, "/", model_dir ))
    system("mkdir -p figures", ignore.stderr = T)

    # SSAPLUS
    # system("/usr/local/cdo-1.6.7/bin/cdo ifthen /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc fire.2007-1-1-2015-12-31.nc fire_pred_masked.nc")
    # system("/usr/local/cdo-1.6.7/bin/cdo selyear,2007/2015 -ifthen /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,49.75 /media/jaideep/WorkData/Fire_G/fire_BA/burned_area_0.5deg.2001-2016.nc fire_obs_masked_2007-2015.nc")
    # system("/usr/local/cdo-1.6.7/bin/cdo monmean -selyear,2007/2015 -ifthen /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,49.75 /media/jaideep/Totoro/Data/Fire_BA_GFED4.1s/nc/GFED_4.1s_0.5deg.1997-2016.nc fire_gfed_masked_selyear.nc")

    # ## India
    # system("/usr/local/cdo-1.6.7/bin/cdo ifthen /media/jaideep/WorkData/Fire_G/forest_type/IIRS/netcdf/ftmask_0.5deg.nc fire.2007-1-1-2015-12-31.nc fire_pred_masked.nc")
    # system("/usr/local/cdo-1.6.7/bin/cdo selyear,2007/2015 -ifthen /media/jaideep/WorkData/Fire_G/forest_type/IIRS/netcdf/ftmask_0.5deg.nc -sellonlatbox,66.75,98.25,6.75,38.25 /media/jaideep/WorkData/Fire_G/fire_BA/burned_area_0.5deg.2001-2016.nc fire_obs_masked_2007-2015.nc")
    # # system("/usr/local/cdo-1.6.7/bin/cdo monmean -selyear,2007/2015 -ifthen /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,49.75 /media/jaideep/WorkData/Fire_G/fire_BA_GFED/GFED4.0_MQ_0.5deg.1995-2016.nc fire_gfed_masked_selyear.nc")

    ## SAS
    # system("/usr/local/cdo-1.6.7/bin/cdo ifthen -sellonlatbox,60.25,99.75,5.25,29.75 /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc fire.2007-1-1-2015-12-31.nc fire_pred_masked.nc")
    # system("/usr/local/cdo-1.6.7/bin/cdo selyear,2007/2015 -ifthen -sellonlatbox,60.25,99.75,5.25,29.75 /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,29.75 /media/jaideep/WorkData/Fire_G/fire_BA/burned_area_0.5deg.2001-2016.nc fire_obs_masked_2007-2015.nc")
    # system("/usr/local/cdo-1.6.7/bin/cdo monmean -selyear,2007/2015 -ifthen /media/jaideep/WorkData/Fire_G/forest_type/MODIS/ftmask_MODIS_0.5deg.nc -sellonlatbox,60.25,99.75,5.25,29.75 /media/jaideep/WorkData/Fire_G/fire_BA_GFED/GFED4.0_MQ_0.5deg.1995-2016.nc fire_gfed_masked_selyear.nc")

    # glimits = c(66.75, 98.25, 6.75, 38.25) # India
    # glimits = c(60.25,99.75,5.25,29.75)  # sas

    fire_pred_filename = paste0(fire_dir,"/",output_dir, "/", model_dir, "/", fire_pred_file)
    fire_pred = NcCreateOneShot(filename = fire_pred_filename, var_name = "fire")
    fire_pred$time = fire_pred$time - 15
    fire_pred$time = as.Date("2003-1-15") + 365.2524/12*(0:156)
    fire_pred = NcClipTime(fire_pred, start_date, end_date)
    fire_pred$data = fire_pred$data - 0.000
    fire_pred$data[fire_pred$data < 0.00] = 0

    glimits = c(fire_pred$lons[1],
                fire_pred$lons[length(fire_pred$lons)],
                fire_pred$lats[1],
                fire_pred$lats[length(fire_pred$lats)])  # get limits from predicted data

    slices_per_yr_pred = 365.2524/as.numeric(mean(diff(fire_pred$time[-length(fire_pred$time)])))

    lat_res = mean(diff(fire_pred$lats))*111e3
    lon_res = mean(diff(fire_pred$lons))*111e3
    cell_area = t(matrix(ncol = length(fire_pred$lons), data = rep(lat_res*lon_res*cos(fire_pred$lats*pi/180), length(fire_pred$lons) ), byrow = F ))

    fire_obs = NcCreateOneShot(filename = fire_obs_file, var_name = "ba", glimits = glimits)
    fire_obs$time = as.Date("1997-1-15") + 365.2524/12*(0:239)
    fire_obs = NcClipTime(fire_obs,  start_date, end_date)
    fire_obs$data[is.na(fire_pred$data)] = NA

    slices_per_yr_obs = 365.2524/as.numeric(mean(diff(fire_obs$time[-length(fire_obs$time)])))

    ts_pred = apply(X = fire_pred$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    ts_obs = apply(X = fire_obs$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    tmpcor = cor(ts_pred, ts_obs)



    # p_obs1 = p_obs[which(obs_t >= "2007-1-1" & obs_t <= "2015-12-31")]/55.5/55.5e6
    # t1 = obs_t[which(obs_t >= "2007-1-1" & obs_t <= "2015-12-31")]

    ts_obs_yr = (tapply(X = ts_obs, INDEX = strftime(fire_obs$time, "%Y"), FUN = mean))*12
    ts_pred_yr = (tapply(X = ts_pred, INDEX = strftime(fire_pred$time, "%Y"), FUN = mean))*12
    tmpcor_yoy = cor(ts_pred_yr, ts_obs_yr)

    # plot(ts_obs_yr~unique(strftime(obs_t, "%Y")), ylim=c(0,75))
    # points(ts_pred_yr~unique(strftime(obs_t, "%Y")), type="l", col="blue")
    # plot(ts_obs_yr~ts_pred_yr)

    slice_pred = apply(X = fire_pred$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*slices_per_yr_pred
    slice_pred = slice_pred*cell_area

    slice_obs = apply(X = fire_obs$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*slices_per_yr_obs
    slice_obs = slice_obs*cell_area

    slice_obs[is.na(slice_pred)] = 0
    slice_pred[is.na(slice_pred)] = 0

    spacor = cor(as.numeric(slice_pred), as.numeric(slice_obs))
    # write.table(x = spacor, file = "spacor.txt", row.names = F, col.names = F)

    # spatcor = matrix(nrow = dim(fire_pred$data)[1], ncol = dim(fire_pred$data)[2])
    # spatcor_yoy = matrix(nrow = dim(fire_pred$data)[1], ncol = dim(fire_pred$data)[2])
    # for (i in 1:dim(spatcor)[1]){
    #   for (j in 1:dim(spatcor)[2]){
    #     spatcor[i,j] = cor(fire_pred$data[i,j,], fire_obs$data[i,j,])
    #     spatcor_yoy[i,j] = cor(tapply(X = fire_obs$data[i,j,], INDEX = strftime(fire_obs$time, "%Y"), FUN = mean)*12,
    #                            tapply(X = fire_pred$data[i,j,], INDEX = strftime(fire_pred$time, "%Y"), FUN = mean)*12
    #                           )
    #   }
    # }
    # image(t(matrix(seq(-1,1,length.out=100), nrow=1)), col=colorRampPalette(c("red", "white", "blue"))(100), zlim=c(-1,1))
    # image(spatcor, col = colorRampPalette(c("red", "white", "blue"))(100), zlim=c(-1,1))
    # image(spatcor_yoy, col = colorRampPalette(c("red", "white", "blue"))(100), zlim=c(-1,1))
    
    
    # cols = createPalette(c("black", "blue","green3","yellow","red"),c(0,25,50,100,1000), n = 1000)
    # cols = createPalette(c("black", "black", "black","blue","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000)
    cols = createPalette(c("black", "blue4", "blue", "skyblue", "cyan","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000) #gfed

    png(filename = paste0("figures/all_seasons", "(",model_dir,")_testDataset.png"),res = 300,width = 844*3,height = 800*3*1.5) # 520 for sasplus, india, 460 for SAS
    layout(matrix(c(1,1,
                    1,1,
                    2,2,
                    2,2,
                    2,2,
                    # 3,3,
                    # 2,3,
                    3,3,
                    3,3,
                    3,3), ncol=2,byrow = T))  # vertical
    par(mar=c(4,5,4,1), oma=c(1,1,1,1), cex.lab=1.5, cex.axis=1.5)

    plot(y=ts_obs, x=fire_obs$time, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area")
    points(ts_pred, x= fire_pred$time, type="l", col="red", lwd=2)
    mtext(cex = 1, line = .5, text = sprintf("Correlations: Temporal = %.2f, IA = %.2f, Spatial = %.2f", tmpcor, tmpcor_yoy, spacor))
    # axis(side = 1, labels = strftime(fire_obs$time, format="%m")[seq(1,200,by=2)], at=fire_obs$time[seq(1,200,by=2)])
    # par(mfrow=c(1,2))

    image(fire_pred$lon, fire_pred$lat, slice_pred/cell_area, col = cols, zlim = c(0,1), xlab="Longitude",ylab = "Latitude")
    mtext(cex = 1, line = .5, text = sprintf("Total BA = %.2f Mha", sum(slice_pred, na.rm=T)*0.0001/1e6))
    mtext(cex = 1, line = 2.3, text = "Predicted", col="blue")
    # plot(shp, add=T)

    image(fire_obs$lon, fire_obs$lat, slice_obs/cell_area, col = cols, zlim = c(0,1),xlab = "Longitude",ylab = "Latitude")
    mtext(cex = 1, line = .5, text = sprintf("Total BA = %.2f Mha", sum(slice_obs)*0.0001/1e6))
    mtext(cex = 1, line = 2.3, text = "GFED4.1s", col="blue")
    # plot(shp, add=T)

    # image(x=), fire_obs$lat, slice_obs, col = cols, zlim = c(0,1),xlab = "Longitude",ylab = "Latitude")

    # slice_gfed = apply(X = fire_gfed$data, FUN = sum, MARGIN = c(1,2))/9
    # slice_gfed[ftmask$data == 0] = 0
    # image(fire_gfed$lon,fire_gfed$lat,slice_gfed,col = cols,zlim = c(0,1),xlab = "Longitude",ylab = "Latitude",cex.lab=1.6)
    # mtext(line = .5, text = sprintf("Total BA = %.2f", sum(slice_gfed)*55.5e3*55.5e3*0.0001/1e6))
    # # plot(shp, add=T)

    mtext(text = "All seasons",side = 3,line = 1,outer = T)
    dev.off()

    cat(model_dir, "\t", tmpcor, "\t", tmpcor_yoy, "\t", spacor, "\t", sum(slice_pred, na.rm=T)*0.0001/1e6, "\n")
    cat(tmpcor, "\t", tmpcor_yoy, "\t", spacor, "\t", sum(slice_pred, na.rm=T)*0.0001/1e6, "\n", file = "metrics.txt")
#   }
#   cat("\n\n\n")
# }
