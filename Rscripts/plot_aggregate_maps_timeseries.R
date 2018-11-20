## CREATE timeseries	
library(ncdf4)
library(chron)

fire_dir = "~/codes/PureNN_fire"
source(paste0(fire_dir, "/Rscripts/utils.R"))

# for (mod in c("gfed_xcf")){ #}, "xdxl", "xlmois", "xts", "xpop", "xrh", "xwsp", "xrh_lmois")){
#   
#   for (i in 1:10){
    # model = paste0(mod, "_", i)
    model = "mod1"
    
    sim_name           <- paste0("ssaplus_pureNN/", model)
    suffix = ""
    if (sim_name != "") suffix = paste0(suffix,"_",sim_name)
    output_dir = paste0("output",suffix)
    
    
    setwd(paste0(fire_dir,"/output",suffix ))
    
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
    # 
    
    glimits = c(60.25,99.75,5.25,49.75)  # ssaplus
    # glimits = c(66.75, 98.25, 6.75, 38.25) # India
    # glimits = c(60.25,99.75,5.25,29.75)  # sas
    
    
    fire_pred = NcCreateOneShot(filename = "fire_pred_masked.nc", var_name = "fire", glimits = glimits)
    fire_pred$time = fire_pred$time - 15
    fire_pred = NcClipTime(fire_pred, "2007-1-1", "2015-11-30")
    # fire_pred = NcClipTime(fire_pred, "2008-1-1", "2010-12-31")
    fire_pred$data = fire_pred$data - 0.0005
    fire_pred$data[fire_pred$data < 0.00] = 0
    
    cell_area = t(matrix(ncol = length(fire_pred$lons), data = rep(55.5e3*55.5e3*cos(fire_pred$lats*pi/180), length(fire_pred$lons) ), byrow = F ))
    
    fire_obs = NcCreateOneShot(filename = "../fire_gfed_masked_2007-2015.nc", var_name = "ba", glimits = glimits)
    fire_obs = NcClipTime(fire_obs, "2007-1-1", "2015-11-30")
    # fire_obs = NcClipTime(fire_obs, "2008-1-1", "2010-12-31")
    
    # for (i in 1:dim(fire_obs$data)[3]) fire_obs$data[,,i] = fire_obs$data[,,i]*cell_area
    
    ts_pred = apply(X = fire_pred$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    ts_obs = apply(X = fire_obs$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    tmpcor = cor(ts_pred, ts_obs)
    
    
    
    # p_obs1 = p_obs[which(obs_t >= "2007-1-1" & obs_t <= "2015-12-31")]/55.5/55.5e6
    # t1 = obs_t[which(obs_t >= "2007-1-1" & obs_t <= "2015-12-31")]
    
    ts_obs_yr = (tapply(X = ts_obs, INDEX = strftime(fire_obs$time, "%Y"), FUN = sum))
    ts_pred_yr = (tapply(X = ts_pred, INDEX = strftime(fire_pred$time, "%Y"), FUN = sum))
    tmpcor_yoy = cor(ts_pred_yr, ts_obs_yr)
    
    # plot(ts_obs_yr~unique(strftime(obs_t, "%Y")), ylim=c(0,75))
    # points(ts_pred_yr~unique(strftime(obs_t, "%Y")), type="l", col="blue")
    # plot(ts_obs_yr~ts_pred_yr)
    
    slice_pred = apply(X = fire_pred$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*24
    slice_pred = slice_pred*cell_area
    slice_pred[is.na(slice_pred)] = 0
    
    slice_obs = apply(X = fire_obs$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*24 
    slice_obs = slice_obs*cell_area
    slice_obs[is.na(slice_obs)] = 0
    
    spacor = cor(as.numeric(slice_pred), as.numeric(slice_obs))
    # write.table(x = spacor, file = "spacor.txt", row.names = F, col.names = F)
    
    cols = createPalette(c("black", "blue","green3","yellow","red"),c(0,25,50,100,1000), n = 1000)
    cols = createPalette(c("black", "black", "black","blue","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000)
    cols = createPalette(c("black", "blue4", "blue", "skyblue", "cyan","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000) #gfed 
    
    png(filename = paste0("figures/all_seasons", "(",model,")_testDataset.png"),res = 300,width = 600*3,height = 520*3) # 520 for sasplus, india, 460 for SAS 
    layout(matrix(c(1,1,
                    1,1,
                    2,3,
                    2,3,
                    2,3), ncol=2,byrow = T))  # vertical
    par(mar=c(4,5,3,1), oma=c(1,1,1,1), cex.lab=1.5, cex.axis=1.5)
    
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
    
    cat(model, "\t", spacor, "\t", tmpcor, "\t", tmpcor_yoy, "\t", sum(slice_pred, na.rm=T)*0.0001/1e6, "\n")
#   }
#   cat("\n\n\n")
# }	
