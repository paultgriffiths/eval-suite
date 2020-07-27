# R Script to plot model.1 vs halo hcl data 

# Alex Archibald, July 2012

# call the interpolate zm function and pass in the variable (var) to 
# be interpolated and the values (pres) to interpolate onto
var <- hcl.code
conv <- 1E9

# define pressure levels to interpolate onto NOTE these are in hPa!!
pres <- c(1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,
500,450,400,350,300,250,225,200,175,150,125,100,70,50,30,20,10,7,5,3,2,1,
0.7,0.5,0.3,0.2,0.1)

# extract the halo Obs
nc0 <- open.ncdf(paste(obs_dir, "UARS/uars_clim.nc", sep="/"))
halo.hcl <- get.var.ncdf(nc0, "tr05")
halo.hcl <- apply(halo.hcl, c(1,2), mean)

# extract/define variables
lat    <- get.var.ncdf(nc1, "latitude")
halo.lat<- get.var.ncdf(nc0, "latitude")
halo.lon <- get.var.ncdf(nc0, "longitude")
hgt    <- get.var.ncdf(nc0, "z")

lonp <- halo.lon ; latp <- halo.lat
source(paste(scr_dir, "interpolate_nozm_plev.R", sep=""))

# define model tropopause height on pressure (using scale height from UKCA)
#ht     <- get.var.ncdf(nc1, trop.pres.code)
#ht     <- apply(ht, c(2), mean)*1E-2 # (convert to hPa)

# set the plotting field to the interpolated field
hcl.zm <- apply(newvv, c(1,2), mean)*(conv/mm.hcl)
rm(newvv)
rm(var)

# create a nice log scale for the y axis.
# This transfrmation was taken from the skewty.R function from the ozone sonde package
log.z <-  132.18199999999999 - 44.061 * log10(pres)
#log.ht<-  132.18199999999999 - 44.061 * log10(ht)
halo.hgt<- 132.18199999999999 - 44.061 * log10(hgt)
# ###################################################################################################################################
# set axis'
axis_x <- seq(from=-90, to=90, by=15)

# the y axis labels get a bit crowded so here is a cut down set:
y.labs <- c(1000,700,500,250,150,100,70,50,30,20,10,7,5,3,2,1,0.7,0.5,0.3,0.2,0.1)

# set limits for plots and data
zmin <- 0.0
zmax <- 5.0
hcl.zm[hcl.zm>=zmax] <- zmax
hcl.zm[hcl.zm<=zmin] <- zmin
# ###################################################################################################################################
pdf(file=paste(out_dir,mod1.name,"_HCl_Zonal_mean.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
filled.contour(lat, log.z, hcl.zm, ylab="Altitude (hPa)", xlab="Latitude (degrees)", main=paste("HALOE -",mod1.name,"HCl comparison",sep=" "), zlim=c(zmin,6), col=col.cols(12),
xaxt="n", yaxt="n",key.title = title("ppb"),
ylim=c(log.z[1],log.z[42]), plot.axes= {
contour(lat, log.z, hcl.zm, method = "edge", labcex = 1, col = "gray", cex=0.7, add = TRUE, lty=1, levels=seq(0,5,0.5)) 
contour(halo.lat, halo.hgt, halo.hcl, method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, levels=seq(0,5,0.5)) # obs
lines(lat, log.hgt, lwd=2, lty=2)
axis(side=1, axis_x, labels=TRUE, tick=TRUE)
axis(side=2, log.z, labels=FALSE, tick=TRUE)
axis(side=2, log.z[c(1,12,16,21,25,27:42)],   labels=sprintf("%1g", y.labs), tick=TRUE)
grid() } )

par(xpd=T)
text(-70,180, paste("Min =",sprintf("%1.3g", min(hcl.zm, na.rm=T) ), "Max =", sprintf("%1.3g", max(hcl.zm, na.rm=T) ), sep=" ") )
par(xpd=F)

dev.off()
