#### UTILS FOR FIRE PROJECT ####

#' @param xfrac The fraction over from the left side.
#' @param yfrac The fraction down from the top.
#' @param label The text to label with.
#' @param pos Position to pass to text()
#' @param ... Anything extra to pass to text(), e.g. cex, col.
add_label <- function(xfrac, yfrac, label, pos = 4, ...) {
  u <- par("usr")
  x <- u[1] + xfrac * (u[2] - u[1])
  y <- u[4] - yfrac * (u[4] - u[3])
  text(x, y, label, pos = pos, ...)
}

# labels <- c("A", "B", "C", "D", "E", "F", "G", "H", "I")
# par(mfrow = c(1, 2), mar = c(2, 2.5, 0, 0))
# for(i in 1:2) {
#   plot(1)
#   add_label(0.00, 0.08, labels[i], cex=1.5, pos=4)
# }


createPalette <- function(cols, values, n=100){
  nval = length(values)
  dv = values[2:nval] - values[2:nval-1]
  ncols = round(dv*n/sum(dv))
  cols1 = c()
  for (i in 1:(length(dv))){
    cols_sec = colorRampPalette(colors=c(cols[i],cols[i+1]))(ncols[i]+1)
    cols_sec = cols_sec[-length(cols_sec)]
    cols1 = c(cols1,  cols_sec)
  }
  if (sum(ncols) < n) cols1[n] = cols1[n-1]
  if (sum(ncols) > n) cols1 = cols1[1:n]
  cols1
}

plot.colorbar <- function(cols, values, n=1000, log=""){
  cols = createPalette(cols,values,n)
  vals = seq(values[1], values[length(values)], length.out = 1000)
  image(x=log(vals), y=1, z=matrix(data = vals, ncol=1), zlim = c(values[1], values[length(values)]), col = cols, xaxt="n")
  axis(side = 1, labels = (vals[seq(1,n,length.out = 10)]), at = log(vals[seq(1,n,length.out = 10)]))
}

addTrans <- function(color,trans)
{
  # This function adds transparancy to a color.
  # Define transparancy with an integer between 0 and 255
  # 0 being fully transparant and 255 being fully visable
  # Works with either color and trans a vector of equal length,
  # or one of the two of length 1.
  
  if (length(color)!=length(trans)&!any(c(length(color),length(trans))==1)) stop("Vector lengths not correct")
  if (length(color)==1 & length(trans)>1) color <- rep(color,length(trans))
  if (length(trans)==1 & length(color)>1) trans <- rep(trans,length(color))
  
  num2hex <- function(x)
  {
    hex <- unlist(strsplit("0123456789ABCDEF",split=""))
    return(paste(hex[(x-x%%16)/16+1],hex[x%%16+1],sep=""))
  }
  rgb <- rbind(col2rgb(color),trans)
  res <- paste("#",apply(apply(rgb,2,num2hex),2,paste,collapse=""),sep="")
  return(res)
}

NcCreateOneShot<- function(filename,var_name, glimits = numeric(0)){
  
  if(length(glimits) < 4){
    lon0 = -180
    lonf = 360
    lat0 = -90
    latf = 90
  } else {
    lon0 = glimits[1]
    lonf = glimits[2]
    lat0 = glimits[3]
    latf = glimits[4]
  }
  
  ncin<- nc_open(filename)
  fire_array<-ncvar_get(ncin,var_name)
  # cat(dim(fire_array))
  
  lon<- ncvar_get(ncin, "lon")
  lat<- ncvar_get(ncin, "lat")
  
  latSN = T
  if (lat[2] < lat[1]) latSN=F
  
  if (!latSN) {
    lat = lat[seq(length(lat), 1, by=-1)]
    if (length(dim(fire_array)) == 2) {
      fire_array = fire_array[,seq(length(lat), 1, by=-1)]
    }
    else{
      fire_array = fire_array[,seq(length(lat), 1, by=-1),]
    } 
  }
  
  # ilon0 = which(lon<=lon0)[length(which(lon<=lon0))]
  # if (length(ilon0) == 0){ ilon0 = 0 }
  # ilonf = which(lon>=lonf)[1]
  # if (length(ilonf) == 0){ ilonf = length(lon) }
  # ilat0 = which(lat<=lat0)[length(which(lat<=lat0))]
  # if (length(ilat0) == 0){ ilat0 = 0 }
  # ilatf = which(lat>=latf)[1]
  # if (length(ilatf) == 0){ ilatf = length(lat) }

  ilon0 = max(1, length(which(lon<=lon0)))
  ilonf = length(which(lon<=lonf))
  ilat0 = max(1, length(which(lat<=lat0)))
  ilatf = length(which(lat<=latf))

  time<- ncvar_get(ncin,"time")
  tunits <- ncatt_get(ncin,"time","units")
  tustr <- strsplit(tunits$value, " ")
  tdstr <- strsplit(unlist(tustr)[3], "-")
  tmonth <- as.integer(unlist(tdstr)[2])
  tday <- as.integer(unlist(tdstr)[3])
  tyear <- as.integer(unlist(tdstr)[1])
  tscale = 0
  if(tustr[[1]][1] == "hours"){
    tscale = 24
  } else if (tustr[[1]][1] == "days"){
    tscale = 1
  } else {
    cat("Error: time unit not days or hours")
  }
  time_div<-chron(time/tscale,origin=c(tmonth, tday, tyear))
  time1<- as.Date(time_div)
  
  if (length(dim(fire_array)) == 2){
    dat = fire_array[ilon0:ilonf,ilat0:ilatf]
  }
  else{
    dat = fire_array[ilon0:ilonf,ilat0:ilatf,]
  }
  
  list(data=dat,
       lons=lon[ilon0:ilonf],
       lats=lat[ilat0:ilatf],
       time=time1,
       month = as.numeric(strftime(time1, format = "%m"))
  )
  
}


NcClipTime = function(ncset, start, end){
  time_sel = which(ncset$time >= as.Date(start) & ncset$time <= as.Date(end))
  ncset$data = ncset$data[,,time_sel]
  ncset$time = ncset$time[time_sel]
  ncset$month = ncset$month[time_sel]
  ncset  
}

plot.netcdf = function(dat, zlim, col, ilev=1, shp = NULL, ...){
  if (length(dim(dat$data)) > 2) dat$data = dat$data[,,ilev]
  image(x=dat$lon, y=dat$lat, z=dat$data, zlim=zlim, col=col, xlab="Lon", ylab="Lat")
  if (!is.null(shp)) plot(shp, add=T)
  image(x=seq(zlim[1],zlim[2],length.out=1000), y=1, z=matrix(seq(zlim[1],zlim[2],length.out=1000)), zlim = zlim, col=col, yaxt="n", ...)
}


plot.colormap = function(X,Y,Z, zlim, col, cex, xlim, ylim, ...){
  dataramp = seq(zlim[1],zlim[2], length.out=length(col) )
  colbreaks = as.numeric(cut(Z, breaks = dataramp))  
  layout(rbind(1,1,1,1,1,2))
  par(mar=c(4,5,1,1), oma=c(1,1,1,1), cex.lab=1.8, cex.axis=1.8)
  image(x=seq(xlim[1],xlim[2],length.out = 100), y=seq(ylim[1],ylim[2],length.out = 100), z=matrix(nrow = 100, ncol=100), zlim=c(0,1), ...)
  points(Y~X, pch=".", col=col[colbreaks], cex=cex)  
  # plot(shp, add=T)
  # image(x= dataramp, z = matrix(ncol=1, data=dataramp), zlim = zlim, col = col, xlab="", ylab="", yaxt="n" )  
}

plot.colormap1 = function(X,Y,Z, zlim, col, cex, xlim, ylim, ...){
  dataramp = seq(zlim[1],zlim[2], length.out=length(col) )
  cols = col[Z+1]
  layout(rbind(1,1,1,1,1,2))
  par(mar=c(4,5,1,1), oma=c(1,1,1,1), cex.lab=1.8, cex.axis=1.8)
  image(x=seq(xlim[1],xlim[2],length.out = 100), y=seq(ylim[1],ylim[2],length.out = 100), z=matrix(nrow = 100, ncol=100), zlim=c(0,1), ...)
  points(Y~X, pch=".", col=cols, cex=cex)  
  # plot(shp, add=T)
  image(x= dataramp, z = matrix(ncol=1, data=dataramp), zlim = zlim, col = col, xlab="", ylab="", yaxt="n" )  
}


mids = function(x){
  x[-length(x)] + diff(x)/2
}


# read.fireData = function(dataset, dir){
#   datf = read.csv(file = paste0(dir,"/../",dataset,"_forest.csv"))
#   
#   daty = read.delim(paste0(dir,"/y_predic_ba_",dataset,".txt"), header=F, sep=" ")
#   # nfires_classes = c(0,1,sqrt(fire_classes[2:length(fire_classes)]* c(fire_classes[3:length(fire_classes)])))
#   # nfires_pred = apply(X=daty, MARGIN=1, FUN=function(x){sum(nfires_classes*x)})
#   
#   ba_classes = c(0,2^(seq(log2(2^0), log2(2^10), length.out=11)))/1024
#   ba_classes_mids = c(0, 0.5/1024, sqrt(ba_classes[3:length(ba_classes)-1]*ba_classes[3:length(ba_classes)]))
#   datf$ba.pred = apply(X=daty, MARGIN=1, FUN=function(x){sum(ba_classes_mids*x)})
#   datf$ba.pred = datf$ba.pred - 0.002
#   datf$ba.pred[datf$ba.pred < 0] = 0;
#   datf$baclass_pred = sapply(datf$ba.pred,FUN = function(x){length(which(x>ba_classes))})
#   
#   datf  
# }

read.fireData_gfed = function(dataset, dir, regions=NULL){
  datf = read.csv(file = paste0(dir,"/../",dataset,"_forest.csv"))
  
  if (!is.null(regions)){
    ids = rep(FALSE, nrow(datf))
    for (r in regions){
      ids[datf$region == r] = TRUE
    }
    datf = datf[ids, ]
  }    

  daty = read.delim(paste0(dir,"/y_predic_ba_",dataset,".txt"), header=F, sep=" ")
  # nfires_classes = c(0,1,sqrt(fire_classes[2:length(fire_classes)]* c(fire_classes[3:length(fire_classes)])))
  # nfires_pred = apply(X=daty, MARGIN=1, FUN=function(x){sum(nfires_classes*x)})
  
  # ba_classes = c(0,2^(seq(log2(2^0), log2(2^10), length.out=11)))/1024
  # ba_classes_mids = c(0, 0.5/1024, sqrt(ba_classes[3:length(ba_classes)-1]*ba_classes[3:length(ba_classes)]))
  ba_classes = c(0, seq(-6,0,by=0.25))
  ba_classes_mids = 10^(ba_classes[-1] - diff(ba_classes)/2)
  ba_classes_mids[1] = 0

  datf$ba.pred = apply(X=daty, MARGIN=1, FUN=function(x){sum(ba_classes_mids*x)})
  datf$ba.pred = datf$ba.pred - 0.000
  datf$ba.pred[datf$ba.pred < 0] = 0;
  datf$baclass_pred = sapply(log10(datf$ba.pred),FUN = function(x){length(which(x>ba_classes))})
  
  datf$ba = datf$gfed
  datf$baclass = datf$gfedclass
  
  datf  
}


split.dataset = function(N, fracs){
  ids = 1:N
  ids_test = sample(ids, size= fracs[3]*N, replace = F)
  ids_eval = sample(ids[-ids_test], size= fracs[2]*N, replace = F)
  ids_train = ids[-c(ids_test,ids_eval)]
  list(train=ids_train, eval=ids_eval,test=ids_test)  
}


# denseNet = function(x, weights_file){
#   r = readLines(weights_file, skipNul = T)
#   s = unlist(strsplit(r, split = " "))
#   w = as.numeric(s[-which(s=="")])
#   
#   nh = w[1]
#   neurons = w[2:(3+nh)]
#   nl = length(neurons)
#   
#   count = 3+nh
#   
#   weights = list()
#   biases = list()
#   
#   weights[[1]] = matrix(data= w[count + 1:(neurons[1]^2) ], nrow=neurons[1], byrow = T)
#   count = count + neurons[1]^2
#   biases[[1]] = w[count + 1:(neurons[1]) ]
#   count = count + neurons[1]
#   
#   for (l in 2:nl){
#     weights[[l]] = matrix(data= w[count + 1:(neurons[l]*neurons[l-1]) ], ncol=neurons[l], byrow = T)
#     count = count + neurons[l]*neurons[l-1]
#     biases[[l]] = w[count + 1:(neurons[l]) ]
#     count = count + neurons[l]
#   }
#   
#   x = x%*%weights[[1]] + biases[[1]]
#   for (l in 2:(nl-1)){
#     x = x%*%weights[[l]] + biases[[l]]
#     x[x<0] = exp(x[x<0])-1
#   }
#   x = x%*%weights[[nl]] + biases[[nl]]
#   y = t(apply(X = x, MARGIN = 1, FUN = function(x) {exp(x-max(x))/sum(exp(x-max(x)))} ))
#   y
# }
