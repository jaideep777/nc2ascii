
fire_dir = "~/codes/PureNN_fire"
source(paste0(fire_dir,"/Rscripts/utils.R"))

xlim = c(60.5,100.5)
ylim = c(5,50)
ptsiz = 11  # 12 for india

dat1 = read.delim("/home/jaideep/codes/PureNN_fire/train_data_from_globalfiles_bil.txt")
dat2 = read.delim("/home/jaideep/codes/PureNN_fire/output_ssaplus_pureNN/train_data.txt")
dat3 = read.delim("/home/jaideep/codes/PureNN_fire/train_data_from_globalfiles_cg.txt")

dat4 = read.delim("/home/jaideep/codes/PureNN_fire/output_africa/train_data.txt")

# png(paste0(fire_dir, "/fire_aggregateData/output",suffix,"/lmois.png"), width = 400, height = 500)
# par(mfrow = c(1,2), cex.lab=1.2, cex.axis=1.2)
# with( dat_good[dat_good$date == as.Date("2007-01-07"),],
#       plot.colormap(X=lon, Y=lat, Z = lmois, zlim = c(-0.01,1.01), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
# )
# dev.off()


with( dat1,
      plot.colormap(X=lon, Y=lat, Z = log(1+pop), zlim = c(-0.01,11), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
with( dat2,
      plot.colormap(X=lon, Y=lat, Z = log(1+pop), zlim = c(-0.01,11), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)

plot(dat$ba~dat$ba0.5)

with( dat1[as.Date(dat1$date) == as.Date("2006-06-15"),],
      plot.colormap(X=lon, Y=lat, Z = pr, zlim = c(-0.01,65), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
with( dat2[as.Date(dat2$date) == as.Date("2006-06-15"),],
      plot.colormap(X=lon, Y=lat, Z = pr, zlim = c(-0.01,65), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
with( dat3[as.Date(dat3$date) == as.Date("2006-06-15"),],
      plot.colormap(X=lon, Y=lat, Z = pr, zlim = c(-0.01,65), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)


plot(dat1$ftmap0~dat3$ftmap0, pch=".")


with( dat1[as.Date(dat1$date) == as.Date("2006-08-16"),],
      plot.colormap(X=lon, Y=lat, Z = gfed, zlim = c(-0.01,0.2), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
with( dat2[as.Date(dat2$date) == as.Date("2006-08-16"),],
      plot.colormap(X=lon, Y=lat, Z = gfed, zlim = c(-0.01,0.2), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)
with( dat3[as.Date(dat3$date) == as.Date("2006-08-16"),],
      plot.colormap(X=lon, Y=lat, Z = gfed, zlim = c(-0.01,0.2), col = rainbow(100), cex = ptsiz, xlim = xlim, ylim = ylim)
)


xlim = c(0,50)
ylim = c(-30,20)
ptsiz = 11  # 12 for india

with( dat4[as.Date(dat4$date) == as.Date("2006-08-16"),],
      plot.colormap(X=lon, Y=lat, Z = gfed, zlim = c(-0.01,0.5), col = rainbow(100)[1:90], cex = ptsiz, xlim = xlim, ylim = ylim)
)

Y = read.delim("/home/jaideep/codes/PureNN_fire/output_africa/mod1_full/y_predic_ba_eval.txt", header=F, sep=" ")

