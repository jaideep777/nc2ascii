rm(list=ls())

library(ncdf4)
library(chron)
rm(list = ls())
#### PREDICTED FIRES - CALIBRATION ####

fire_dir = "/home/jaideep/codes/PureNN_fire"
output_dir = "output_globe"
model_dir = "AF_mod256.5_gfedl1"
data_dir= "/home/jaideep/Data"

# for (model_dir in list.files(path = paste0(fire_dir,"/",output_dir), no.. = T, pattern = "mod")){
cat(model_dir, "\n")

# region_name = strsplit(model_dir, split = "_")[[1]][1]
regions_list = list(BONA = c(1), TCAM = c(2,3), TENA=c(2), CEAM=c(3), SA = c(4,5), NHAF=c(8), SHAF = c(9), AF=c(8,9), CEAS= c(11), SEAS=c(12), AUS = c(14), GLOBE = 1:14)
# reg = get(region_name, regions_list)

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

source(paste0(fire_dir,"/Rscripts/utils.R"))

# dataset = "eval"
# datg = read.fireData_gfed(dataset = dataset, dir=paste0(fire_dir, "/",output_dir, "/", model_dir), regions=reg)

regnc = nc_open(paste0(data_dir,"/Fire_BA_GFED4.1s/ancil/basis_regions_1deg.nc"))  
regions = ncvar_get(regnc, varid = "region")

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

dft_file = nc_open(filename = "/home/jaideep/Data/forest_type/MODIS/dft_MODIS_global_12lev_agri-bar_lt0.5_1deg.nc")
dft = ncvar_get(dft_file, "ft")


tsnc  = NcCreateOneShot(paste0(data_dir,"/Fire/ts.2003-2015.nc"), var_name = "ts")
tsnc  = NcClipTime(tsnc,  start_date, end_date)

vpnc  = NcCreateOneShot(paste0(data_dir,"/Fire/vp.2003-2015.nc"), var_name = "vp")
vpnc  = NcClipTime(vpnc,  start_date, end_date)

cldnc  = NcCreateOneShot(paste0(data_dir,"/Fire/cld.2003-2015.nc"), var_name = "cld")
cldnc  = NcClipTime(cldnc,  start_date, end_date)

gppl1nc  = NcCreateOneShot(paste0(data_dir,"/Fire/gppl1.2003-2015.nc"), var_name = "gppl1")
gppl1nc  = NcClipTime(gppl1nc,  start_date, end_date)

gppm1nc  = NcCreateOneShot(paste0(data_dir,"/Fire/gppm1.2003-2015.nc"), var_name = "gppm1")
gppm1nc  = NcClipTime(gppm1nc,  start_date, end_date)

gppm1snc  = NcCreateOneShot(paste0(data_dir,"/Fire/gppm1s.2003-2015.nc"), var_name = "gppm1s")
gppm1snc  = NcClipTime(gppm1snc,  start_date, end_date)

gfedl1nc  = NcCreateOneShot(paste0(data_dir,"/Fire/gfedl1.2003-2015.nc"), var_name = "gfedl1")
gfedl1nc$data[gfedl1nc$data > 1e18]  = NA
gfedl1nc  = NcClipTime(gfedl1nc,  start_date, end_date)

popnc  = NcCreateOneShot(paste0(data_dir,"/Fire/pop.2003-2015.nc"), var_name = "pop")
popnc$data[popnc$data > 1e18]  = NA
popnc  = NcClipTime(popnc,  start_date, end_date)

ts_slice = apply(X = tsnc$data, MARGIN = c(1,2), FUN = mean)
vp_slice = apply(X = vpnc$data, MARGIN = c(1,2), FUN = mean)
cld_slice = apply(X = cldnc$data, MARGIN = c(1,2), FUN = mean)
pop_slice = apply(X = popnc$data, MARGIN = c(1,2), FUN = mean)
gppl1_slice = apply(X = gppl1nc$data, MARGIN = c(1,2), FUN = mean)
gppm1_slice = apply(X = gppm1nc$data, MARGIN = c(1,2), FUN = mean)
gfedl1_slice = apply(X = gfedl1nc$data, MARGIN = c(1,2), FUN = mean)


fire_pred_filename = paste0(fire_dir,"/",output_dir, "/", model_dir, "/", fire_pred_file)
fire_pred = NcCreateOneShot(filename = fire_pred_filename, var_name = "fire")
fire_pred$time = fire_pred$time - 15
fire_pred$time = as.Date("2003-1-15") + 365.2524/12*(0:155)
fire_pred = NcClipTime(fire_pred, start_date, end_date)
# fire_pred$data = fire_pred$data - 0.000
# fire_pred$data[fire_pred$data < 0.00] = 0

fire_pred = gfedl1nc

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

slice_pred = apply(X = fire_pred$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*slices_per_yr_pred
slice_pred = slice_pred*cell_area

slice_obs = apply(X = fire_obs$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*slices_per_yr_obs
slice_obs = slice_obs*cell_area



# xnc=gfedl1nc
# ync=vpnc
# znc = fire_obs
# zpnc = fire_pred

plot.niche_xy = function(xnc, ync, znc, zpnc, region_name, bins = c(100,100), ...){
  region_indices = get(region_name, regions_list)
  r1 = region_indices[1]
  r2 = region_indices[length(region_indices)]
  reg = regions
  reg[reg != r1 & reg != r2] = NA
  
  xnc$data[is.na(reg)] = NA
  ync$data[is.na(reg)] = NA
  znc$data[is.na(reg)] = NA
  zpnc$data[is.na(reg)] = NA
  
  x = as.numeric(xnc$data)
  y = as.numeric(ync$data)
  z = as.numeric(znc$data)
  zp= as.numeric(zpnc$data)
  
  breaks_x = seq(min(x, na.rm=T), max(x, na.rm=T), length.out=bins[1])
  breaks_y = seq(min(y, na.rm=T), max(y, na.rm=T), length.out=bins[2])
  
  xclass = cut(x, breaks = breaks_x)
  yclass = cut(y, breaks = breaks_y)
  mat      = tapply(X = z,   INDEX = list(xclass, yclass), FUN = function(x)(mean(x,na.rm=T)))
  mat_pred = tapply(X = zp,  INDEX = list(xclass, yclass), FUN = function(x)(mean(x,na.rm=T)))
  
  t_x  = apply(X = xnc$data, MARGIN = 3, FUN = function(x) {mean(x, na.rm=T)})
  t_y  = apply(X = ync$data, MARGIN = 3, FUN = function(x) {mean(x, na.rm=T)})
  t_z  = apply(X = znc$data, MARGIN = 3, FUN = function(x) {mean(x, na.rm=T)})
  t_zp  = apply(X = zpnc$data, MARGIN = 3, FUN = function(x) {mean(x, na.rm=T)})
  
  t_x_yr = tapply(X = t_x, INDEX = strftime(xnc$time, "%Y"), FUN = mean)
  t_y_yr = tapply(X = t_y, INDEX = strftime(ync$time, "%Y"), FUN = mean)
  t_z_yr = tapply(X = t_z, INDEX = strftime(znc$time, "%Y"), FUN = mean)
  t_zp_yr = tapply(X = t_zp, INDEX = strftime(zpnc$time, "%Y"), FUN = mean)
  
  mod_x = lm(t_x_yr~seq(1,12))
  mod_y = lm(t_y_yr~seq(1,12))
  
  par(mfrow=c(2,2))
  par(mar=c(4,5,1,1), oma=c(1,1,4,1), cex.lab=1.5, cex.axis=1.5)
  
  cols_niche = createPalette(c("black", "blue4", "blue", "cyan", "green", "yellow", "red", "brown"), c(0,0.002, 0.005, 0.02, 0.05, 0.2, 0.5, 1), 100)
  image(mat, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, ...)
  segments(fitted(mod_x)[-length(fitted(mod_x))], fitted(mod_y)[-length(fitted(mod_y))],
           fitted(mod_x)[-1], fitted(mod_y)[-1],
           col=colorRampPalette(c("black", "magenta"))(12), lwd=3 )

  image(mat_pred, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, ...)
  segments(fitted(mod_x)[-length(fitted(mod_x))], fitted(mod_y)[-length(fitted(mod_y))],
           fitted(mod_x)[-1], fitted(mod_y)[-1],
           col=colorRampPalette(c("black", "magenta"))(12), lwd=3 )

  # image(mat, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, xlim=c(min(t_x_yr), max(t_x_yr)), ylim=c(min(t_y_yr), max(t_y_yr)), ...)
  # segments(fitted(mod_x)[-length(fitted(mod_x))], fitted(mod_y)[-length(fitted(mod_y))],
  #          fitted(mod_x)[-1], fitted(mod_y)[-1],
  #          col=colorRampPalette(c("black", "magenta"))(12), lwd=3 )
  # 
  # image(mat_pred, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, xlim=c(min(t_x_yr), max(t_x_yr)), ylim=c(min(t_y_yr), max(t_y_yr)), ...)
  # segments(fitted(mod_x)[-length(fitted(mod_x))], fitted(mod_y)[-length(fitted(mod_y))],
  #          fitted(mod_x)[-1], fitted(mod_y)[-1],
  #          col=colorRampPalette(c("black", "magenta"))(12), lwd=3 )

  mtext(region_name, side = 3, outer = TRUE, cex=1.3)
  
#   image(mat_pred, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, ...)
# 
  # lons = c(27.5, -0.5  )
  # lats = c(7.5,  +9.5  )
#   for (i in 1:length(lons)){
#   
#   tx1 = xnc$data[which(xnc$lons == lons[i]), which(xnc$lats == lats[i]),]
#   ty1 = ync$data[which(ync$lons == lons[i]), which(ync$lats == lats[i]),]
#   tz1 = znc$data[which(znc$lons == lons[i]), which(znc$lats == lats[i]),]
#   tzp1 = zpnc$data[which(zpnc$lons == lons[i]), which(zpnc$lats == lats[i]),]
#   #   
# #   segments(tx1[-length(tx1)], ty1[-length(ty1)],
# #            tx1[-1], ty1[-1],
# #            col=colorRampPalette(c("black", "white"))(12*12), lwd=1.5 )
# # 
# #   
#   tx1_yr = tapply(X = tx1, INDEX = strftime(xnc$time, "%Y"), FUN = mean)
#   ty1_yr = tapply(X = ty1, INDEX = strftime(ync$time, "%Y"), FUN = mean)
#   tz1_yr = tapply(X = tz1, INDEX = strftime(xnc$time, "%Y"), FUN = mean)
#   tzp1_yr = tapply(X = tzp1, INDEX = strftime(ync$time, "%Y"), FUN = mean)
  # 
# #  image(mat_pred, zlim=c(0,0.2), x = breaks_x, y=breaks_y, col=cols_niche, xlim=c(min(tx1_yr), max(tx1_yr)), ylim=c(min(ty1_yr), max(ty1_yr)), ...)
#   segments(tx1_yr[-length(tx1_yr)], ty1_yr[-length(ty1_yr)],
#            tx1_yr[-1], ty1_yr[-1],
#            col=colorRampPalette(c("black", "magenta"))(12), lwd=3 )
# 
#   
#   }  
}

# NHAF
plot.niche_xy(gfedl1nc, cldnc, fire_obs, fire_pred, region_name = "NHAF", xlab="Cumm. BA", ylab="Cloud Cover")
plot.niche_xy(cldnc, vpnc, fire_obs, fire_pred, region_name = "NHAF", xlab="Cloud Cover", ylab="Vapour Pressure")

# SEAS
plot.niche_xy(gfedl1nc, gppm1nc, fire_obs, fire_pred, region_name = "SEAS", xlab="Cumm. BA", ylab="Cumm CY GPP", bins=25)
plot.niche_xy(gfedl1nc, tsnc, fire_obs, fire_pred, region_name = "SEAS", xlab="Cumm. BA", ylab="Temperature", bins=25)
plot.niche_xy(cldnc, vpnc, fire_obs, fire_pred, region_name = "SEAS", xlab="Cloud Cover", ylab="Vapour pressure", bins=50)
plot.niche_xy(gfedl1nc, cldnc, fire_obs, fire_pred, region_name = "SEAS", xlab="Cumm. BA", ylab="Cloud Cover", bins=25)

plot.niche_xy(popnc, vpnc, fire_obs, fire_pred, region_name = "SHAF", xlim=c(0,600), ylim=c(0,35), xlab="Population Density", ylab="Vapour Pressure")
plot.niche_xy(popnc, vpnc, fire_obs, fire_pred, region_name = "NHAF", bins=c(200,100), xlim=c(0,600), ylim=c(0,35), xlab="Population Density", ylab="Vapour Pressure")
plot.niche_xy(popnc, vpnc, fire_obs, fire_pred, region_name = "AF", bins=c(200,100), xlim=c(0,600), ylim=c(0,35), xlab="Population Density", ylab="Vapour Pressure")

plot.niche_xy(popnc, cldnc, fire_obs, fire_pred, region_name = "SHAF", xlab="Population Density", ylab="Cloud Cover")
plot.niche_xy(cldnc, tsnc, fire_obs, fire_pred, region_name = "SHAF", xlab="Cloud Cover", ylab="Temperature")

plot.niche_xy(gppm1snc, cldnc, fire_obs, fire_pred, region_name = "SHAF", xlab="Cumm. GPP", ylab="Cloud Cover")

###

# plot.niche = function(datf, name="", max.baclass=25){
#   # png(filename = paste0("niche(",model,"_",name,").png"), width = 400*3, height = 500*3, res = 300)
#   png(filename = paste0("niche(",model,"_",name,").png"), width = 512*3, height = 790*3, res = 300)
#   
#   par(mfrow = c(4,2), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5)
#   
# 
#   regnc = nc_open(paste0("~/Data/Fire_BA_GFED4.1s/ancil/basis_regions_1deg.nc"))  
#   regions = ncvar_get(regnc, varid = "region")
# 
#   tsnc  = NcCreateOneShot(paste0(data_dir,"/ts.2003-2015.nc"), var_name = "ts")
#   vpnc  = NcCreateOneShot(paste0(data_dir,"/vp.2003-2015.nc"), var_name = "vp")
#   cldnc = NcCreateOneShot(paste0(data_dir,"/cld.2003-2015.nc"), var_name = "cld")
# 
#   af = regions
#   af[af != 8 & af != 9] = NA
#   
# #  af_rep = array(data = rep(af, dim(tsnc$data)[3]), dim = dim(tsnc$data))
# 
#   x_bins = seq(min(datf$cru_ts), max(datf$cru_ts), length.out=50)
#   y_bins = seq(min(datf$cru_vp), max(datf$cru_vp), length.out=50)
#   tsclass = cut(datf$cru_ts, breaks = x_bins)
#   vpclass = cut(datf$cru_vp, breaks = y_bins)
#   mat      = tapply(X = (datf$ba),      INDEX = list(tsclass, vpclass), FUN = mean)
#   mat_pred = tapply(X = (datf$ba.pred), INDEX = list(tsclass, vpclass), FUN = mean)
#   
#   t_ts  = apply(X = tsnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})
#   t_vp  = apply(X = vpnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})
#   t_cld = apply(X = cldnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})
# 
#   niche_cols = createPalette(c("green4", "green", "limegreen", "cyan", "mediumspringgreen","yellow","orange", "red", "brown", "black"),c(0,0.2,0.5,1,2,5,10,20,50, 100)*1000, n = 1000) #gfed
#   image(z=mat, x=x_bins, y=y_bins, zlim=c(0, 0.5), col=niche_cols)
#   image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), col=niche_cols)
# 
#   t_ts_yr = tapply(X = t_ts, INDEX = strftime(tsnc$time, "%Y"), FUN = mean)
#   t_vp_yr = tapply(X = t_vp, INDEX = strftime(vpnc$time, "%Y"), FUN = mean)
# 
#   mod_ts = lm(t_ts~seq(1,156))
#   mod_vp = lm(t_vp~seq(1,156))
#   image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), xlim = c(min(t_ts), max(t_ts)), ylim = c(min(t_vp), max(t_vp)), col=niche_cols)
#   points(x=fitted(mod_ts), y = fitted(mod_vp), pch = 20, col=colorRampPalette(c("black", "white"))(156))
#   # points(x=(t_ts_yr), y = (t_vp_yr), pch = 20, cex=1, col=colorRampPalette(c("black", "white"))(156/12))
# #   subplot( 
# # #    function(){
# #       image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), xlim = c(min(t_ts), max(t_ts)), ylim = c(min(t_vp), max(t_vp)), col=niche_cols),
# #  #     points(x=fitted(mod_ts), y = fitted(mod_vp), pch = 20, col=colorRampPalette(c("black", "white"))(156))
# #   #  },
# #     x=grconvertX(c(0.75,1), from='npc'),
# #     y=grconvertY(c(0,0.25), from='npc'),
# #     type='fig', pars=list( mar=c(1.5,1.5,0,0)+0.1) )
#   
# 
#   # plot(datf$rh~datf$ts, pch=20, cex=0.1, col=col.obs, xlim=c(270-273.16,320-273.16), xlab = "Temperature", ylab="Rel Humidity")
#   # points(datf$rh~datf$ts, pch=20, cex=datf$baclass/4, col=col.obs)
#   # plot(datf$rh~datf$ts, pch=20, cex=0.1, col=col.pred, xlim=c(270-273.16,320-273.16), xlab = "Temperature", ylab="Rel Humidity")
#   # points(datf$rh~datf$ts, pch=20, cex=datf$baclass_pred/4, col=col.pred)
#   
# 
#   # plot(datf$agri_frac~datf$forest_frac, pch=20, cex=0.1, col=col.obs, xlab = "Pop dens", ylab="Agri Frac")
#   # points(datf$agri_frac~datf$forest_frac, pch=20, cex=datf$baclass/4, col=col.obs)
#   # plot(datf$agri_frac~datf$forest_frac, pch=20, cex=0.1, col=col.pred, xlab = "Pop dens", ylab="Agri Frac")
#   # points(datf$agri_frac~datf$forest_frac, pch=20, cex=datf$baclass_pred/3, col=col.pred)
# 
#   # plot(datf$forest_frac~datf$logpop, pch=20, cex=0.1, col=col.obs, xlab = "Pop dens", ylab="Forest Frac")
#   # points(datf$forest_frac~datf$logpop, pch=20, cex=datf$baclass/4, col=col.obs)
#   # plot(datf$forest_frac~datf$logpop, pch=20, cex=0.1, col=col.pred, xlab = "Pop dens", ylab="Forest Frac")
#   # points(datf$forest_frac~datf$logpop, pch=20, cex=datf$baclass_pred/3, col=col.pred)
#   # 
#   dev.off()
# }

# setwd(paste0(fire_dir,"/fire_aggregateData/output",suffix,"/figures" ))
# 
# plot.niche(datf, "ALL")  # MIXED
# 
# 
# png(filename = paste0("niche_scale.png"), width = 512*3, height = 790*3, res = 300)
# 
# par(mfrow = c(4,2), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5)
# 
# plot(x=1:11, y=rep(3,11), xlim=c(0,12), ylim=c(1,7), pch=20, cex=(1:11/4), col=colorRampPalette(colors = c("mediumspringgreen","red"))(11)[1:11])
# text(x = 1:11, y=2.2)
# text("O Fire Class  ", x=6, y=1.5)
# 
# points(x=1:11, y=rep(6,11), pch=20, cex=(1:11/4), col=colorRampPalette(colors = c("mediumspringgreen","red"))(11)[1:11])
# text(x = 1:11, y=5.2)
# text("P Fire Class  ", x=6, y=4.5)
# 
# dev.off()


plot.niche_xy(cldnc, vpnc, fire_obs, fire_pred, 8,8, xlab="Cloud Cover", ylab="Vapour Pressure")


