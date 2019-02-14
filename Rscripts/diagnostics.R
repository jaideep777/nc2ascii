rm(list=ls())

library(ncdf4)
library(chron)
rm(list = ls())
#### PREDICTED FIRES - CALIBRATION ####

fire_dir = "/home/jaideep/codes/PureNN_fire"
output_dir = "merged_models"
model_dir = "best_nohistory"
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
dft_file = nc_open(filename = "/home/jaideep/Data/forest_type/MODIS/dft_MODIS_global_12lev_agri-bar_lt0.5_1deg.nc")
dft = ncvar_get(dft_file, "ft")


tsnc  = NcCreateOneShot(paste0(data_dir,"/Fire/ts.2003-2015.nc"), var_name = "ts")
tsnc  = NcClipTime(tsnc,  start_date, end_date)

vpnc  = NcCreateOneShot(paste0(data_dir,"/Fire/vp.2003-2015.nc"), var_name = "vp")
vpnc  = NcClipTime(vpnc,  start_date, end_date)

cldnc  = NcCreateOneShot(paste0(data_dir,"/Fire/cld.2003-2015.nc"), var_name = "cld")
cldnc  = NcClipTime(cldnc,  start_date, end_date)

gppl1nc  = NcCreateOneShot(paste0(data_dir,"/Fire/gppl1.2003-2015.nc"), var_name = "gppl1")
gppl1nc  = NcClipTime(cldnc,  start_date, end_date)

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
gppl1_slice = apply(X = gppl1nc$data, MARGIN = c(1,2), FUN = mean)*12
gfedl1_slice = apply(X = gfedl1nc$data, MARGIN = c(1,2), FUN = mean)*12



fire_pred_filename = paste0(fire_dir,"/",output_dir, "/", model_dir, "/", fire_pred_file)
fire_pred = NcCreateOneShot(filename = fire_pred_filename, var_name = "fire")
fire_pred$time = fire_pred$time - 15
fire_pred$time = as.Date("2003-1-15") + 365.2524/12*(0:155)
fire_pred = NcClipTime(fire_pred, start_date, end_date)
# fire_pred$data = fire_pred$data - 0.000
# fire_pred$data[fire_pred$data < 0.00] = 0

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
slice_obs = apply(X = fire_obs$data, FUN = function(x){mean(x, na.rm=T)}, MARGIN = c(1,2))*slices_per_yr_obs

dft_rep    = array(dim = dim(fire_pred$data), data = rep(dft, dim(fire_pred$data)[3]) )
regions_rep = array(dim = dim(fire_pred$data), data = rep(regions, dim(fire_pred$data)[3]) )

######

           # 'grey10'   # Barren 
ftcols = c('aquamarine',  # NLE
           'green4',      # BLE
           'darkseagreen1',  # NLD
           'green2',         # BLD
           'grey10',        # Mixed
           'pink',          # CLosed shrublands
           'pink3',         # Open shrublands
           'darkolivegreen3',  # Woody savannas
           'yellow1',         # Savannas
           'darkgoldenrod1',    # Grasslands
           'magenta',          # croplands
           'grey10')    # Mixed

par(mfrow=c(6,2), mar=c(4,4,1,1), oma=c(1,1,1,1))
for (i in 1:11){
  plot(log(1+as.numeric(pop_slice[dft==i & regions == 11]))~log(1e-5+as.numeric(slice_obs[dft==i & regions==11])), col=addTrans(ftcols[i], 100), pch=20, main=pftnames_modis[i], xlim=c(-12,0), ylim=c(0,8))
}


par(mfrow=c(6,2), mar=c(4,4,1,1), oma=c(1,1,1,1))
for (i in 1:11){
  plot(log(1e-5+as.numeric(gfedl1_slice[dft==i & regions == 2]))~log(1e-5+as.numeric(slice_obs[dft==i & regions==2])), col=addTrans(ftcols[i], 100), pch=20, main=pftnames_modis[i], xlim=c(-12,0), ylim=c(-12,0))
}

for (r1 in c(1,2,3,4,5,8,9,11,12,14)){
  png(paste0("~/codes/PureNN_fire/figures/diagnostics/ba_vv_prevba/", r1, "_", regions_names[r1], ".png"), width=800, height=830)
  par(mfrow=c(5,2), mar=c(4,4,1,1), oma=c(1,1,3,1), cex.lab=1.2, cex.axis=1.2)
  for (i in (1:11)[-3]){
    
#              i= 7
              
              ba =  log(1e-5+as.numeric(fire_obs$data[dft_rep==i]))
              pba = log(1e-5+as.numeric(gfedl1nc$data[dft_rep==i])*12)
              
              ba_extreme = ba[pba > -2]
              pba_extreme = pba[pba > -2]
              
              dat = data.frame(baex = ba_extreme, pbaex = pba_extreme)
              dat = dat[complete.cases(dat),]
              
              cat(cor(dat$baex,dat$pbaex) , "\n")
              
             plot(y=ba_extreme,
                  x=pba_extreme, 
                  col=addTrans(ftcols[i], 100), pch=20, 
                  main=pftnames_modis[i], 
                  xlim=c(-12,0), ylim=c(-12,0), cex=1.5,
                  xlab = "Prev year BA",
                  ylab = "Current BA")
  }
  mtext(regions_names[r1], side=3, line=1, outer=T)
  dev.off()
}

png(paste0("~/codes/PureNN_fire/figures/diagnostics/ba_vv_prevba/", r1, "_globe", ".png"), width=800, height=830)
par(mfrow=c(5,2), mar=c(4,4,1,1), oma=c(1,1,3,1))
for (i in (1:11)[-3]){
  smoothScatter(y=ba_extreme,
       x=pba_extreme, 
       col=addTrans(ftcols[i], 100), pch=".", 
       main=pftnames_modis[i], 
       xlim=c(-12,0), ylim=c(-12,0),
       xlab = "Prev year BA",
       ylab = "Current BA")
}
mtext("Globe", side=3, line=1, outer=T)
dev.off()




