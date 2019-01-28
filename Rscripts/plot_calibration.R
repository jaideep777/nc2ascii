rm(list = ls())
#### PREDICTED FIRES - CALIBRATION ####

fire_dir = "~/codes/PureNN_fire"
output_dir = "output_globe"
model_dir = "CEAS_mod7_rdtp4_cld_cruvp_pop_prevnpp"

for (model_dir in list.files(path = paste0(fire_dir,"/",output_dir), no.. = T, pattern = "mod")){
cat(model_dir, "\n")

region_name = strsplit(model_dir, split = "_")[[1]][1]
regions_list = list(BONA = c(1), TCAM = c(2,3), AF=c(8,9), SA = c(4,5), SEAS=c(12), CEAS= c(11), AUS = c(14))
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

#### calibration ####

# setwd(paste0("/home/jaideep/codes/FIRE_CODES/figures/",dataset))

plot_calib = function(datf, name, min=2e-4, max=2e-1, nscale = 200){
  tot.ba.pred = sum(datf$ba.pred)
  tot.ba.obs = sum(datf$ba)
  
  insuff_data = which(table(datf$baclass_pred)<10)
  for (i in 1:length(insuff_data)){
    datf$baclass_pred[datf$baclass_pred == as.numeric(names(insuff_data[i]))] = NA
  }
  datf = datf[complete.cases(datf),]
  if (nrow(datf) > 100){
    f = function(x){
      # y = log10(log(1+x))
      # y[log(1+x)==0]=-9
      # y
      log10(1e-7+x)
    }
    
  #  par(mfrow = c(1,2), mar=c(4,4,1,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5)
    obs_ba.predc = tapply(X = datf$ba, INDEX = datf$baclass_pred, FUN=mean)
    pred_ba.predc = tapply(X = datf$ba.pred, INDEX = datf$baclass_pred, FUN=mean)
    obs_ba.predc = obs_ba.predc[-1]
    pred_ba.predc = pred_ba.predc[-1]
    n.obs = tapply(X = datf$ba.pred, INDEX = datf$baclass_pred, FUN=length)
    
    # nscale = sum(n.obs)/120
    # plot(obs_ba.predc~pred_ba.predc, log="xy", xlab = "Classwise mean\npredicted BA", ylab = "Classwise mean\nobserved BA", xlim=c(min,max), ylim=c(min,max), cex=1.5, lwd=2)
    # points(obs_ba.predc~pred_ba.predc, cex=n.obs[-1]/nscale, pch=20, col=addTrans("black",trans = 30))
    # abline(0,1,col="red", lwd=2)
    
    #a = summary(lm(obs_ba.predc~pred_ba.predc))
    #mtext(text = sprintf("r = %.2f", a$adj.r.squared), cex=1.5, side=3, adj = 0.1, padj = 2)
    # nmse = 1-sum(log(obs_ba.predc[-1])-log(pred_ba.predc[-1]))^2/var(log(obs_ba.predc[-1]))/(length(obs_ba.predc[-1])-1)
    # r = cor(obs_ba.predc, pred_ba.predc)
    # mtext(text = sprintf("E = %.2f", nmse), cex=1., side=3, adj = 0.1, padj = 2, col="blue")
    # mtext(text = sprintf("r = %.2f", r), cex=1., side=3, adj = 0.1, padj = 4, col="blue")
    
    
    # dat0 = datf
    # dat0$ba[dat0$ba==0] = NA
    # dat0$ba.pred[dat0$ba.pred==0]=NA
    smoothScatter(f(datf$ba)~f(datf$ba.pred), pch=20, cex=0.2, xlab = "Predicted BA", ylab = "Observed BA", xlim=c(-6,0), ylim=c(-6,0), log="", colramp = colorRampPalette(c("white","grey", "blue", "red", "yellow")), nrpoints = 0)
    # abline(lm(f(datf$ba)~f(datf$ba.pred)), lwd=3)
    # abline(lm((datf$ba)~f(datf$ba.pred)), col="grey", lwd=3) 
    abline(0,1, col=rgb(1,0.5,0.5), lwd=2)
    points(f((obs_ba.predc))~f((pred_ba.predc)), cex=1.5, lwd=2, col="white")
    points(f((obs_ba.predc))~f((pred_ba.predc)), cex=1.1, lwd=2, col="black")
    
    b = summary(lm(datf$ba~datf$ba.pred))
    nmse_act = sum(f(datf$ba)-f(datf$ba.pred))^2/var(f(datf$ba))/(length(f(datf$ba))-1)
    r_act = cor(f(datf$ba), f(datf$ba.pred))
  #  r_act = cor(f(datf$ba), f(datf$ba.pred))
      
    # b = summary(lm(datf$ba~datf$ba.pred))
    # nmse_act = 1-sum(f(datf$ba)-f(datf$ba.pred))^2/var(f(datf$ba))/(length(f(datf$ba))-1)
    # r_act = cor(f(datf$ba), f(datf$ba.pred))
    # mtext(text = sprintf("r = %.2f", b$adj.r.squared), cex=1.5, side=3, adj = 0.1, padj = 2)
    # mtext(text = sprintf("E = %.2f", nmse_act), cex=1., side=3, adj = 0.1, padj = 2, col="blue")
    mtext(text = sprintf("r = %.2f", r_act), cex=0.8, side=3, adj = 0.025, padj = 1.8, col="blue")
    mtext(text = sprintf("O ~ %.1f Mha", sum(datf$ba)*55.5e3^2*1e-10), cex=0.65, side=3, adj = 0.025, padj = 4.)
    mtext(text = sprintf("P ~ %.1f Mha", sum(datf$ba.pred)*55.5e3^2*1e-10), cex=0.65, side=3, adj = 0.025, padj = 5.5)
    title(sub = paste("N = ", nrow(datf),")"), main = name, cex=1.)  
  }
  else{
    plot(1,1, xaxt="n", yaxt="n", main=name)  
  }
  
}



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

setwd(paste0(fire_dir,"/",output_dir,"/",model_dir,"/figures" ))

png(filename = paste0(model_dir,"_PFTwise_calibration_",dataset,".png"), width = 400*6, height = 400*6, res=300)
par(mfrow = c(4,3), mar=c(2,4,2,1), oma=c(4,4,1,1), cex.axis=1.5, cex.lab=1.5, mgp=c(4,1,0))
plot_calib(datg, "All vegetation", nscale=50, max = 1)  # X
for (i in c(1:11)){
  if (length(which(as.numeric(names(table(datg$dft)))==i)) > 0) plot_calib(datg[datg$dft==pfts_modis[i],], pftnames_modis[i], nscale=50, max = 1)  # X
  else plot(1,1, xaxt="n", yaxt="n", main=pftnames_modis[i])  
}
mtext("log10(Predicted burned fraction)", side = 1, outer = TRUE, line = 1)
mtext("log10(Observed burned fraction)", side = 2, outer = TRUE, line = 0)
dev.off()


# 
# pfts_ssaplus = c(0, 1, 6, 10, 2, 7, 9, 11)
# pftnames_ssaplus = c("Barren", "NLE", "SCX", "AGR", "BLE", "MD", "GR", "MX")


# png(filename = "PFTwise_1.png", width = 300*6, height = 500*6, res=300)
# par(mfrow = c(5,2), mar=c(2,3,4,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5, mgp=c(4,1,0))
# for (i in 1:10){
#   plot_calib(datf[datf$dft==pfts_modis[i],], pftnames_modis[i], nscale=50, max = 1)  # X
# }
# dev.off()

# png(filename = "PFTwise_2.png", width = 300*6, height = 500*6, res=300)
# par(mfrow = c(4,2), mar=c(5,7,4,1), oma=c(1,1,1,1), cex.axis=1.5, cex.lab=1.5, mgp=c(4,1,0))
# for (i in 5:8){
#   plot_calib(datf[datf$dft==pfts_ssaplus[i],], pftnames_ssaplus[i], nscale = 50, max = 1)  # X
# }
# dev.off()



}