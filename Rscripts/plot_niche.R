rm(list=ls())

library(ncdf4)
library(chron)
rm(list = ls())
#### PREDICTED FIRES - CALIBRATION ####

fire_dir = "/home/jaideep/codes/PureNN_fire"
output_dir = "output_globe_runs_v1"
model_dir = "AF_mod9_cruts_rdtp4_cld_cruvp_pop"
data_dir= "/home/jaideep/Data/Fire"

# for (model_dir in list.files(path = paste0(fire_dir,"/",output_dir), no.. = T, pattern = "mod")){
cat(model_dir, "\n")

region_name = strsplit(model_dir, split = "_")[[1]][1]
regions_list = list(BONA = c(1), TCAM = c(2,3), SA = c(4,5), AF=c(8,9), CEAS= c(11), SEAS=c(12), AUS = c(14))
reg = get(region_name, regions_list)

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

dataset = "eval"
datg = read.fireData_gfed(dataset = dataset, dir=paste0(fire_dir, "/",output_dir, "/", model_dir), regions=reg)


###

plot.niche = function(datf, name="", max.baclass=25){
  # png(filename = paste0("niche(",model,"_",name,").png"), width = 400*3, height = 500*3, res = 300)
  png(filename = paste0("niche(",model,"_",name,").png"), width = 512*3, height = 790*3, res = 300)
  
  par(mfrow = c(4,2), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5)
  

  regnc = nc_open(paste0("~/Data/Fire_BA_GFED4.1s/ancil/basis_regions_1deg.nc"))  
  regions = ncvar_get(regnc, varid = "region")

  tsnc  = NcCreateOneShot(paste0(data_dir,"/ts.2003-2015.nc"), var_name = "ts")
  vpnc  = NcCreateOneShot(paste0(data_dir,"/vp.2003-2015.nc"), var_name = "vp")
  cldnc = NcCreateOneShot(paste0(data_dir,"/cld.2003-2015.nc"), var_name = "cld")

  af = regions
  af[af != 8 & af != 9] = NA
  
#  af_rep = array(data = rep(af, dim(tsnc$data)[3]), dim = dim(tsnc$data))

  x_bins = seq(min(datf$cru_ts), max(datf$cru_ts), length.out=50)
  y_bins = seq(min(datf$cru_vp), max(datf$cru_vp), length.out=50)
  tsclass = cut(datf$cru_ts, breaks = x_bins)
  vpclass = cut(datf$cru_vp, breaks = y_bins)
  mat      = tapply(X = (datf$ba),      INDEX = list(tsclass, vpclass), FUN = mean)
  mat_pred = tapply(X = (datf$ba.pred), INDEX = list(tsclass, vpclass), FUN = mean)
  
  t_ts  = apply(X = tsnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})
  t_vp  = apply(X = vpnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})
  t_cld = apply(X = cldnc$data, MARGIN = 3, FUN = function(x) {mean(x[which(!is.na(af))], na.rm=T)})

  niche_cols = createPalette(c("green4", "green", "limegreen", "cyan", "mediumspringgreen","yellow","orange", "red", "brown", "black"),c(0,0.2,0.5,1,2,5,10,20,50, 100)*1000, n = 1000) #gfed
  image(z=mat, x=x_bins, y=y_bins, zlim=c(0, 0.5), col=niche_cols)
  image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), col=niche_cols)

  t_ts_yr = tapply(X = t_ts, INDEX = strftime(tsnc$time, "%Y"), FUN = mean)
  t_vp_yr = tapply(X = t_vp, INDEX = strftime(vpnc$time, "%Y"), FUN = mean)

  mod_ts = lm(t_ts~seq(1,156))
  mod_vp = lm(t_vp~seq(1,156))
  image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), xlim = c(min(t_ts), max(t_ts)), ylim = c(min(t_vp), max(t_vp)), col=niche_cols)
  points(x=fitted(mod_ts), y = fitted(mod_vp), pch = 20, col=colorRampPalette(c("black", "white"))(156))
  # points(x=(t_ts_yr), y = (t_vp_yr), pch = 20, cex=1, col=colorRampPalette(c("black", "white"))(156/12))
#   subplot( 
# #    function(){
#       image(z=mat_pred, x=x_bins, y=y_bins, zlim=c(0, 0.5), xlim = c(min(t_ts), max(t_ts)), ylim = c(min(t_vp), max(t_vp)), col=niche_cols),
#  #     points(x=fitted(mod_ts), y = fitted(mod_vp), pch = 20, col=colorRampPalette(c("black", "white"))(156))
#   #  },
#     x=grconvertX(c(0.75,1), from='npc'),
#     y=grconvertY(c(0,0.25), from='npc'),
#     type='fig', pars=list( mar=c(1.5,1.5,0,0)+0.1) )
  

  # plot(datf$rh~datf$ts, pch=20, cex=0.1, col=col.obs, xlim=c(270-273.16,320-273.16), xlab = "Temperature", ylab="Rel Humidity")
  # points(datf$rh~datf$ts, pch=20, cex=datf$baclass/4, col=col.obs)
  # plot(datf$rh~datf$ts, pch=20, cex=0.1, col=col.pred, xlim=c(270-273.16,320-273.16), xlab = "Temperature", ylab="Rel Humidity")
  # points(datf$rh~datf$ts, pch=20, cex=datf$baclass_pred/4, col=col.pred)
  

  # plot(datf$agri_frac~datf$forest_frac, pch=20, cex=0.1, col=col.obs, xlab = "Pop dens", ylab="Agri Frac")
  # points(datf$agri_frac~datf$forest_frac, pch=20, cex=datf$baclass/4, col=col.obs)
  # plot(datf$agri_frac~datf$forest_frac, pch=20, cex=0.1, col=col.pred, xlab = "Pop dens", ylab="Agri Frac")
  # points(datf$agri_frac~datf$forest_frac, pch=20, cex=datf$baclass_pred/3, col=col.pred)

  # plot(datf$forest_frac~datf$logpop, pch=20, cex=0.1, col=col.obs, xlab = "Pop dens", ylab="Forest Frac")
  # points(datf$forest_frac~datf$logpop, pch=20, cex=datf$baclass/4, col=col.obs)
  # plot(datf$forest_frac~datf$logpop, pch=20, cex=0.1, col=col.pred, xlab = "Pop dens", ylab="Forest Frac")
  # points(datf$forest_frac~datf$logpop, pch=20, cex=datf$baclass_pred/3, col=col.pred)
  # 
  dev.off()
}

setwd(paste0(fire_dir,"/fire_aggregateData/output",suffix,"/figures" ))

plot.niche(datf, "ALL")  # MIXED


png(filename = paste0("niche_scale.png"), width = 512*3, height = 790*3, res = 300)

par(mfrow = c(4,2), mar=c(4,5,1,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5)

plot(x=1:11, y=rep(3,11), xlim=c(0,12), ylim=c(1,7), pch=20, cex=(1:11/4), col=colorRampPalette(colors = c("mediumspringgreen","red"))(11)[1:11])
text(x = 1:11, y=2.2)
text("O Fire Class  ", x=6, y=1.5)

points(x=1:11, y=rep(6,11), pch=20, cex=(1:11/4), col=colorRampPalette(colors = c("mediumspringgreen","red"))(11)[1:11])
text(x = 1:11, y=5.2)
text("P Fire Class  ", x=6, y=4.5)

dev.off()
