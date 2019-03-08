rm(list=ls())
# Simulation name ("" or "india" or "ssaplus" etc)

fire_dir    = "~/codes/PureNN_fire"
output_dir  = "output_globe"

source(paste0(fire_dir,"/Rscripts/utils.R"))

clamp = function(x, a,b){
  min(max(x,a),b)  
}

# clean up aggregated data in R and select forest grids only
datm = read.delim(paste0(fire_dir, "/",output_dir,"/train_data.txt"), header=T)
datm = datm[,-length(datm)]
datm[datm > 1e19] = NA
# ba_classes = c(0,2^(seq(log2(2^0), log2(2^10), length.out=11)))/1024
ba_classes = c(0, seq(-6,0,by=0.25))
datm$gfedclass = sapply(log10(datm$gfed),FUN = function(x){length(which(x>ba_classes))})
datm$trmm = NULL
datm[as.Date(datm$date) < as.Date("2002-1-1"), "gppl1"] = NA

datm$pop = log(1+datm$pop)
# datm$gfedl1 = log(1e-5+datm$gfedl1)
# datm$gfedl06 = log(1e-5+datm$gfedl06)
# datm$gfedl04 = log(1e-5+datm$gfedl04)
datm$pr = log(1+datm$pr)
# datm$prt1 = log(1+datm$prt1)
datm$rdtot = log(1+datm$rdtot)

# datm$rdtp3 = log(1+datm$rdtp3)
# datm$rdtp4 = log(1+datm$rdtp4)

# vp_sat = 6.1094 * exp( datm$ts / ( datm$ts + 243.4 ) * 17.625 )
# datm$rh = datm$vp / vp_sat
# datm$rh[datm$rh > 1] = 1

# cru_rh =  datm$cru_vp*100 / )

threshold_forest_frac = 0.3

dat_bad = datm[!complete.cases(datm),]
dat_good = datm[complete.cases(datm),]
# datf = dat_good[dat_good$forest_frac > threshold_forest_frac,]
datf = dat_good

xlim = c(min(datf$lon),max(datf$lon))
ylim = c(min(datf$lat),max(datf$lat))
ptsiz = 17  # 12 for india

# png(paste0(fire_dir, "/fire_aggregateData/output",suffix,"/lmois.png"), width = 400, height = 500)
# par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
# with( dat_good[dat_good$date == as.Date("2007-01-07"),],
#       plot.colormap(X=lon, Y=lat, Z = lmois, zlim = c(-0.01,1.01), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
# )
# dev.off()
ftypes = c('barren',
           'evergreen needleleaf forest',
           'evergreen broadleaf forest',
           'deciduous needleleaf forest',
           'deciduous broadleaf forest',
           'mixed forests',
           'closed shrublands',
           'open shrublands',
           'woody savannas',
           'savannas',
           'grasslands',
           'croplands',
           'mixed types')

ftcols = c('grey',        # barren
           'aquamarine',  # NLE
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
png(paste0(fire_dir, "/",output_dir,"/dft.png"), width = diff(xlim)*8, height = diff(ylim)*400/45)
par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
with( dat_good[as.Date(dat_good$date) == as.Date("2003-01-16"),],
      plot.colormap1(X=lon, Y=lat, Z = dft, zlim = c(0,12), col = ftcols, cex = ptsiz, xlim = xlim, ylim = ylim)
)
dev.off()

png(paste0(fire_dir, "/",output_dir,"/logpop.png"), width = diff(xlim)*8, height = diff(ylim)*400/45)
par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
with( dat_good[as.Date(dat_good$date) == as.Date("2003-01-16"),],
      plot.colormap(X=lon, Y=lat, Z = pop, zlim = c(-0.01,11), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
dev.off()

png(paste0(fire_dir, "/",output_dir,"/rd_tot.png"), width = diff(xlim)*8, height = diff(ylim)*400/45)
par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
with( dat_good[as.Date(dat_good$date) == as.Date("2003-01-16"),],
      plot.colormap(X=lon, Y=lat, Z = rdtot, zlim = c(-0.01,9), col = heat.colors(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
dev.off()


# png(paste0(fire_dir, "/fire_aggregateData/output",suffix,"/dxl.png"), width = 400, height = 500)
# par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
# with( dat_good[dat_good$date == as.Date("2007-01-07"),],
#       plot.colormap(X=lon, Y=lat, Z = dxl, zlim = c(-0.01,300), col = rainbow(100)[1:50], cex = ptsiz, xlim =xlim, ylim = ylim)
# )
# dev.off()

pos = which(datf$gfedclass>0)
neg = which(datf$gfedclass == 0)
neg_sub = sample(neg, size = min(4*length(pos), length(neg)), replace = F)

set.seed(1)
ids = sample(c(pos, neg_sub), size = length(c(pos, neg_sub)), replace = F) # shuffle indices

datf = datf[ids,]

# png(paste0(fire_dir, "/output",suffix,"/dft_datf.png"), width = 400, height = 500)
# par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
# with( datf[as.Date(dat_good$date) >= as.Date("2006-1-1") & as.Date(dat_good$date) <= as.Date("2006-12-31"),],
#       plot.colormap1(X=lon, Y=lat, Z = dft, zlim = c(0,12), col = rainbow(13), cex = ptsiz, xlim = xlim, ylim = ylim)
# )
# dev.off()

plot.cut.means_obs = function(obs, var, min, max, col.obs, col.pred, ...){
  brks = seq(min,max, length.out=21)
  cuts = cut(var, breaks = brks, include.lowest = T)
  plot(x= mids(brks), y=tapply(obs, INDEX = cuts, FUN = mean), col=col.obs, lwd=2, ... ,ylim = c(0,0.020))
  list(classsizes = tapply(obs, INDEX = cuts, FUN = length), 
       classvalues = tapply(obs, INDEX = cuts, FUN = mean),
       class = cuts
  )
}


ids_test = which( (as.Date(datf$date) >= as.Date("2005-1-1") & as.Date(datf$date) <= as.Date("2007-12-31")) )
                   # | datf$lon < -25)
# ids_test = which( (as.Date(datf$date) >= as.Date("2008-1-1") & as.Date(datf$date) <= as.Date("2011-12-31")) )
# ids_test = which(datf$date >= as.Date("2013-1-1"))

dat_test = datf[ids_test,]
datf_train_full = datf[-ids_test,]

lt = dim(datf_train_full)[1]
id_train = sample(1:lt, size = 0.7*lt, replace = F)
id_eval = (1:lt)[-id_train]

dat_train = datf_train_full[id_train, ]
dat_eval = datf_train_full[id_eval, ]

### oversample rare forest types 
tt = table(dat_train$dft)
sample_size = max(tt)


write.csv(x = dat_train, file=paste0(fire_dir, "/",output_dir,"/train_forest.csv"), row.names = F)
write.csv(x = dat_eval, file=paste0(fire_dir, "/",output_dir,"/eval_forest.csv"), row.names = F)
write.csv(x = dat_test, file=paste0(fire_dir, "/",output_dir,"/test_forest.csv"), row.names = F)

write(x = paste0("ID_", colnames(dat_train), " = ", 1:length(dat_train)-1), file=paste0(fire_dir, "/",output_dir,"/variables.py"), ncolumns = 1)


## Regions analysis
datm$fire = as.integer(datm$gfed > 0)

regions_list = list(BONA = c(1), TCAM = c(2,3), SA = c(4,5), AF=c(8,9), CEAS= c(11), SEAS=c(12), AUS = c(14), OTHER = c(6,7,10,13))
regions = c("BONA", #1
            "TCAM", #2
            "TCAM", #3
            "SA",
            "SA",
            "OTHER",
            "OTHER",
            "AF",
            "AF",
            "OTHER",
            "CEAS",
            "SEAS",
            "OTHER",
            "AUS")


# datm$region_short = sapply(X = datm$region, FUN = function(x){names(regions_list)[which(sapply(1:length(regions_list), function(i) any(regions_list[[i]] == x)))]})
datm$region_short = regions[datm$region]
# 
# par(mfrow = c(3,1), mar=c(4,2,2,2), oma=c(1,1,1,1), cex.lab=1.5, cex.axis= 1.5)
# for (i in c(5,6,7,14,31,11)){
#   boxplot(datm[,i]~datm$fire+datm$region_short, main=names(datm)[i], col=c("green4", "orange"), outline=F )
# }
# 
# 
# for (reg in unique(datm$region_short)){
#   png(filename = paste0(fire_dir, "/",output_dir,"/",reg,".png"), width=840, height=750)
#   pairs(datm[datm$region_short == reg, c(5,6,7,14,31,11)], panel=function(x,y) smoothScatter(x,y,add=T), main=reg)
#   dev.off()
# }
# 
# for (reg in unique(datm$dft)){
#   # png(filename = paste0(fire_dir, "/",output_dir,"/ft_",reg,".png"), width=840, height=750)
#   pairs(datm[datm$dft == reg, c(5,6,7,14,31,11)], panel=function(x,y) smoothScatter(x,y,add=T), main=reg)
#   # dev.off()
# }
# 
# 
# for (reg in unique(datm$dft)){
#   varids = sapply(X = c("gpp.l1", "gpp.l2", "pr.l1", "pr.l2"), FUN = function(x){which(names(datm) == x)})
#   pairs(datm[datm$dft == reg, varids], panel=function(x,y) smoothScatter(x,y,add=T), main=reg)
# }
# 
# for (reg in unique(datm$dft)){
#   varids = sapply(X = c("cru_ts", "cld", "pr", "cru_vp"), FUN = function(x){which(names(datm) == x)})
#   pairs(datm[datm$dft == reg, varids], panel=function(x,y) smoothScatter(x,y,add=T), main=reg)
# }

varids = sapply(X = c("gppm1", "gppl06", "gppl1"), FUN = function(x){which(names(datm) == x)})
pairs(datm[datm$region_short == "SEAS", varids], panel=function(x,y) smoothScatter(x,y,add=T), main="SEAS")
pairs(datm[datm$region_short == "SEAS", varids], panel=function(x,y) points(x,y,pch="."), main="SEAS")


