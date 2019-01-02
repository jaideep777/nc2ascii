## CREATE timeseries	
library(ncdf4)
library(chron)

fire_dir = "~/codes/PureNN_fire"
output_dir = "output_globe_1deg_2"
model_dir = "mod9_cruts_rd3_cld_rh"
  
fire_obs_file = "/home/jaideep/Data/Fire_BA_GFED4.1s/nc/GFED_4.1s_1deg.1997-2016.nc"  # Need absolute path here
fire_pred_file = "fire.2003-1-1-2015-12-31.nc"

start_date  = "2003-1-1"
end_date    = "2015-11-30"

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
    fire_obs$month = as.numeric(strftime(fire_obs$time, format = "%m"))
    fire_obs = NcClipTime(fire_obs,  start_date, end_date)

    slices_per_yr_obs = 365.2524/as.numeric(mean(diff(fire_obs$time[-length(fire_obs$time)])))
    
    ts_pred = apply(X = fire_pred$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    ts_obs = apply(X = fire_obs$data, FUN = function(x){sum(x*cell_area, na.rm=T)}, MARGIN = 3)*0.0001/1e6
    tmpcor = cor(ts_pred, ts_obs)
    
    
    f = function(x){
      x
    }
    
    # cols = createPalette(c("black", "blue","green3","yellow","red"),c(0,250,500,750,1000), n = 1000)
    cols = createPalette(c("black", "blue","green3","yellow","red"),c(0,25,50,100,1000), n = 1000)
    cols = createPalette(c("black", "blue4", "blue", "skyblue", "cyan","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000) #gfed
    # cols = createPalette(c("black", "black", "black", "black","blue","mediumspringgreen","yellow","orange", "red","brown"),c(0,0.2,0.5,1,2,5,10,20,50,100)*1000, n = 1000)
    
    # library(rgdal)
    # shp <- readOGR(dsn = "/media/jaideep/WorkData/Fire_G/util_data/india_boundaries/india_st.shp")
    
    seasons = list(FMAM = c(2,3,4,5), JJAS = c(6,7,8,9), ON = c(10,11,12,1))
    names = c("summer", "monsoon", "postmonsoon_winter")
    seasmonths = c("FMAM", "JJAS", "ONDJ")
    
    for (sea in 1:length(seasons)){
      png(filename = paste0("figures/", names[sea], "(",model_dir,").png"),res = 300,width = 1200*3,height = 2700) # 2700 for ssaplus, india, 2200 for SAS 
      # layout(matrix(c(1,2,3,4,5,6,7,8),2,4,byrow = F))  # horizontal
      layout(matrix(c(1,2,3,4,5,6,7,8),4,2,byrow = T))  # vertical
      par(mar=c(4,4,3,1), oma=c(1,2,6,2), cex.lab=3, cex.axis=1.5)
      for(i in seasons[[sea]]){
        # slice_pred<- fire_pred$data[,,i]
        slice_pred = apply(X = fire_pred$data[,,which(fire_pred$month == i)], FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))
        # slice_pred[ftmask$data == 0] = 0
        slice_pred[is.nan(slice_pred)] = NA
        image(fire_pred$lon,fire_pred$lat,slice_pred,col = cols,zlim = c(0,1), xlab="Longitude",ylab = "Latitude",cex.lab=1.6)
        mtext(cex = 0.8, line = .5, text = sprintf("Total BA = %.2f", sum(slice_pred*cell_area, na.rm=T)*0.0001/1e6))
        # plot(shp, add=T, col="white")
        
        slice_obs = apply(X = fire_obs$data[,,which(fire_obs$month == i)], FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))
        # slice_obs = slice_obs/cell_area
        # slice_obs = (diffuse(slice_obs, 0.1, 0))
        # slice_obs[ftmask$data == 0] = 0
        slice_obs[is.na(slice_pred)] = NA
        slice_obs[is.nan(slice_obs)] = NA
        image(fire_obs$lon,fire_obs$lat,slice_obs,col = cols,zlim = c(0,1),xlab = "Longitude",ylab = "Latitude",cex.lab=1.6)
        mtext(cex = 0.8, line = .5, text = sprintf("Total BA = %.2f", sum(slice_obs*cell_area, na.rm=T)*0.0001/1e6))
        # plot(shp, add=T, col="white")
        
      }
      mtext(text = seasmonths[sea],side = 3,line = 1,outer = T)
      dev.off()
    }
    
    #########
    
 
#   }
#   cat("\n\n\n")
# }	
