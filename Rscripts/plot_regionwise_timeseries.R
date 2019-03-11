## CREATE timeseries	
library(ncdf4)
library(chron)

fire_dir = "~/codes/PureNN_fire"
output_dir = "merged_models"
model_dir = "minimal_v5"

fire_obs_file = "/home/jaideep/Data/Fire_BA_GFED4.1s/nc/GFED_4.1s_1deg.1997-2016.nc"  # Need absolute path here
fire_pred_file = "fire.2002-1-1-2015-12-31.nc"

start_date  = "2002-1-1"
end_date    = "2015-12-31"

regions_names = c("BONA", #(Boreal North America)",
                  "TENA", #(Temperate North America)",
                  "CEAM", #(Central America)",
                  "NHSA", #(Northern Hemisphere South America)",
                  "SHSA", #(Southern Hemisphere South America)",
                  "EURO", #(Europe)",
                  "MIDE", #(Middle East)",
                  "NHAF", #(Northern Hemisphere Africa)",
                  "SHAF", #(Southern Hemisphere Africa)",
                  "BOAS", #(Boreal Asia)",
                  "CEAS", #(Central Asia)",
                  "SEAS", #(Southeast Asia)",
                  "EQAS", #(Equatorial Asia)",
                  "AUST") #(Australia and New Zealand)")

pfts_modis = 1:11
pftnames_modis = c("Evergreen Needleleaf Forest", 
                   "Evergreen Broadleaf Foreat",  
                   "Deciduous Needleleaf Forest", 
                   "Deciduous Broadleaf Forest",
                   "Mixed Forests",
                   "Closed Shrublands",
                   "Open Shrublands",
                   "Woody Savannas",
                   "Savannas",
                   "Grasslands",
                   "Croplands")



source(paste0(fire_dir, "/Rscripts/utils.R"))

mha_per_m2 = 0.0001/1e6

# for (mod in c("gfed_xcf")){ #}, "xdxl", "xlmois", "xts", "xpop", "xrh", "xwsp", "xrh_lmois")){
#   
#   for (i in 1:10){
# model = paste0(mod, "_", i)

setwd(paste0(fire_dir,"/",output_dir, "/", model_dir ))
system("mkdir -p figures", ignore.stderr = T)

regions_file = nc_open(filename = "/home/jaideep/Data/Fire_BA_GFED4.1s/ancil/basis_regions_1deg.nc")
regions = ncvar_get(regions_file, "region")

dft_file = nc_open(filename = "/home/jaideep/Data/forest_type/MODIS/dft_MODIS_global_12lev_agri-bar_lt0.5_1deg.nc")
dft = ncvar_get(dft_file, "ft")


fire_pred_filename = paste0(fire_dir,"/",output_dir, "/", model_dir, "/", fire_pred_file)
fire_pred = NcCreateOneShot(filename = fire_pred_filename, var_name = "fire")
# fire_pred$time = fire_pred$time - 15
# fire_pred$time = as.Date("2003-1-15") + 365.2524/12*(0:155)
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

regions1 = array(data = rep(regions, length(fire_pred$time)), dim = c(dim(regions), length(fire_pred$time)) )

png(filename = paste0("figures/regionwise_timeseries_1_", "(",model_dir,").png"),res = 300,width = 400*5,height = 844*5) # 520 for sasplus, india, 460 for SAS 
par(mfrow = c(7,2), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.lab=1.5, cex.axis=1.5)

for (i in 1:14){
  # for(ft in 1:11){
  ts_pred = apply(X = fire_pred$data, FUN = function(x){sum((x*cell_area)[regions == i], na.rm=T)}, MARGIN = 3)*0.0001/1e6
  ts_obs = apply(X = fire_obs$data, FUN = function(x){sum((x*cell_area)[regions == i], na.rm=T)}, MARGIN = 3)*0.0001/1e6
  # ts_pred = apply(X = fire_pred$data, FUN = function(x){sum((x*cell_area)[dft == ft], na.rm=T)}, MARGIN = 3)*0.0001/1e6
  # ts_obs = apply(X = fire_obs$data, FUN = function(x){sum((x*cell_area)[dft == ft], na.rm=T)}, MARGIN = 3)*0.0001/1e6
  # ts_pred = apply(X = fire_pred$data, FUN = function(x){sum((x*cell_area), na.rm=T)}, MARGIN = 3)*0.0001/1e6
  # ts_obs = apply(X = fire_obs$data, FUN = function(x){sum((x*cell_area), na.rm=T)}, MARGIN = 3)*0.0001/1e6
  
  tmpcor = cor(ts_pred, ts_obs)
  
  ts_obs_yr = (tapply(X = ts_obs, INDEX = strftime(fire_obs$time, "%Y"), FUN = sum))
  ts_pred_yr = (tapply(X = ts_pred, INDEX = strftime(fire_pred$time, "%Y"), FUN = sum))
  tmpcor_yoy = cor(ts_pred_yr, ts_obs_yr)
  
  # plot(y=ts_obs, x=fire_obs$time, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area", ylim=c(0, 1.1*max(c(ts_obs, ts_pred))) )
  # points(ts_pred, x= fire_pred$time, type="l", col="red", lwd=2)
  # mtext(cex = 1, line = .5, text = sprintf("%s | T = %.2f, IA = %.2f", regions_names[i], tmpcor, tmpcor_yoy))
  
  mod_obs = lm(ts_obs_yr~seq(2002,2015))
  mod_pred = lm(ts_pred_yr~seq(2002,2015))

  # plot(y=ts_obs, x=fire_obs$time, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area", ylim=c(0.9*min(c(ts_obs, ts_pred)), 1.1*max(c(ts_obs, ts_pred))) )
  
  plot(y=ts_obs_yr, x=2002:2015, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area", ylim=c(0.9*min(c(ts_obs_yr, ts_pred_yr)), 1.1*max(c(ts_obs_yr, ts_pred_yr))) )
  abline(mod_obs, col="orange")
  points(ts_pred_yr, x=2002:2015, type="l", col="red", lwd=2)
  abline(mod_pred, col="red")
  mtext(cex = 1, line = .5, text = sprintf("%s | T = %.2f, IA = %.2f", regions_names[i], tmpcor, tmpcor_yoy))
  # # mtext(cex = 1, line = .5, text = sprintf("%s, %s | T = %.2f, IA = %.2f", regions_names[i], pftnames_modis[ft], tmpcor, tmpcor_yoy))
  # # }  
  
  
  # plot(y=ts_obs_yr-fitted(mod_obs), x=2003:2014, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area" )
  # points(ts_pred_yr-fitted(mod_pred), x=2003:2014, type="l", col="red", lwd=2)
  
}

dev.off()

# png(filename = paste0("figures/regionwise_timeseries_2_", "(",model_dir,").png"),res = 300,width = 844*3,height = 844*3) # 520 for sasplus, india, 460 for SAS 
# par(mfrow = c(7,1), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.lab=1.5, cex.axis=1.5)
# 
# for (i in 8:14){
#   ts_pred = apply(X = fire_pred$data, FUN = function(x){sum((x*cell_area)[regions == i], na.rm=T)}, MARGIN = 3)*0.0001/1e6
#   ts_obs = apply(X = fire_obs$data, FUN = function(x){sum((x*cell_area)[regions == i], na.rm=T)}, MARGIN = 3)*0.0001/1e6
#   tmpcor = cor(ts_pred, ts_obs)
#   
#   ts_obs_yr = (tapply(X = ts_obs, INDEX = strftime(fire_obs$time, "%Y"), FUN = sum))
#   ts_pred_yr = (tapply(X = ts_pred, INDEX = strftime(fire_pred$time, "%Y"), FUN = sum))
#   tmpcor_yoy = cor(ts_pred_yr, ts_obs_yr)
#   
#   plot(y=ts_obs, x=fire_obs$time, col="orange2", type="o", cex=1.2, lwd=1.5, xlab="", ylab="Burned area", ylim=c(0, 0.2+max(max(ts_obs), max(ts_pred))) )
#   points(ts_pred, x= fire_pred$time, type="l", col="red", lwd=2)
#   mtext(cex = 1, line = .5, text = sprintf("Region = %s | Correlations: Temporal = %.2f, IA = %.2f", regions_names[i], tmpcor, tmpcor_yoy))
# }
# 
# dev.off()
# par(mfrow=c(5,2))
# for (ft in 1:11){
# plot(as.numeric(spatcor[dft==ft])~as.numeric(x[dft==ft]), pch=19, main=pftnames_modis[ft], xlim=c(0,1), ylim=c(-1,1))
# }


par(mfrow=c(2,1))


