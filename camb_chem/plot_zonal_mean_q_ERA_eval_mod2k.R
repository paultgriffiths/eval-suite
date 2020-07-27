# R Script to plot model.1 vs Q ERA data 

# Alex Archibald, July 2011

# call the interpolate zm function and pass in the variable (var) to 
# be interpolated and the values (pres) to interpolate onto
var <- h2o.code

# define pressure levels to interpolate onto NOTE these are in hPa!!
pres <- c(1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,
500,450,400,350,300,250,225,200,175,150,125,100,70,50,30,20,10,7,5,3,2,1)


# ERA data
nc0 <- open.ncdf(paste(obs_dir, "ERA/data/erai_q_2000-2011_N48_P37.nc", sep="/"), readunlim=FALSE)

# extract/define variables
era.a  <- get.var.ncdf(nc0,"Q")
era.a <- era.a[,,,1:108]   # Extract Y2000-2008 to match autoassess
era.z  <- apply(era.a,c(2,3),mean,na.rm=T)
era.z <- era.z[,rev(1:length(pres))]
#

era.sd <- apply(era.a,c(2,3),function(x) sd(as.vector(x), na.rm=T))
era.sd  <- era.sd[,rev(1:length(pres))]
rm(era.a)

lat    <- get.var.ncdf(nc1, "latitude")
lon    <- get.var.ncdf(nc1, "longitude")
lat.era<- get.var.ncdf(nc0, "latitude")
lon.era<- get.var.ncdf(nc0, "longitude")
hgt    <- get.var.ncdf(nc0, "p")
z      <- seq(length(hgt))

# Interpolate onto pressure levels, as well as output grid 
lonp <- lon.era  ; latp <- lat.era   # set output res

source(paste(scr_dir, "interpolate_zm_plev.R", sep=""))

# define model tropopause height on pressure (using scale height from UKCA)
#M ht     <- get.var.ncdf(nc1, trop.pres.code)
#M ht     <- apply(ht, c(2), mean)*1E-2 # (convert to hPa)

# set the plotting field to the interpolated field
ukca.z <- apply(newvv, c(1,2), mean)
rm(newvv)
rm(var)

# create an array of % difference
#diff <- 100.0*((ukca.z-era.z)/era.z)
diff <- (log10(ukca.z) - log10(era.z) )

# create a mask of significance (diff/era.sd) - MD: not used
#M sig.mask <- ifelse( abs( ((ukca.z-era.z)/(era.sd))) > 1.0, TRUE, FALSE)

rm(ukca.z) ; rm(era.z)

# create a nice log scale for the y axis.
# This transfrmation was taken from the skewty.R function from the ozone sonde package
log.z <-  132.18199999999999 - 44.061 * log10(rev(hgt))
#M log.ht<-  132.18199999999999 - 44.061 * log10(ht)

hmax <- which(pres==100.0)
print(log.z[1:hmax])
print(pres[1:hmax])
# copy data for bias calcs
diff.raw <- diff

# set axis'
axis_x <- seq(from=-90, to=90, by=15)
axis_y <- z

# the y axis labels get a bit crowded so here is a cut down set:
y.labs <- c(1000,800,600,400,200,100)

# set limits for plots and data
zmin <- -0.5#-100.0
zmax <-  0.5# 100.0
diff[diff>=zmax] <- zmax
diff[diff<=zmin] <- zmin

xmin <- min(lat.era)
xmax <- max(lat.era)
# ###################################################################################################################################
pdf(file=paste(out_dir,"/",mod1.name,"-ERA_Q_log_diff_2k.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
filled.contour(lat.era, log.z[1:hmax], diff[,1:hmax], ylab="Altitude (hPa)", xlab="Latitude (degrees)", main=paste(mod1.name,"- ERA Q (2000-2008) bias ",sep=" "), zlim=c(zmin,zmax), col=heat.cols(20), xaxt="n", yaxt="n", xlim=c(xmax,xmin),
ylim=c(log.z[1],log.z[hmax]), key.title = title("Log(diff)"), plot.axes= {
contour(lat.era, log.z[1:hmax], diff[,1:hmax], method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, levels=seq(0,5,1)) #positive
contour(lat.era, log.z[1:hmax], diff[,1:hmax], method = "edge", labcex = 1, col = "black", add = TRUE, lty=2, levels=seq(-5,0,1)) #negative
#M lines(lat, log.ht, lwd=2, lty=2)
axis(side=1, axis_x, labels=TRUE, tick=TRUE)
axis(side=2, log.z[1:hmax], labels=FALSE, tick=TRUE)
axis(side=2, log.z[c(1,8,14,18,24,27)],   labels=sprintf("%1g", y.labs), tick=TRUE)
#points(pts$x[pts$mask], pts$y[pts$mask], cex = 0.8, pch=4, col="white")
grid() } )

par(xpd=T)
text(45,90, paste("Min =",sprintf("%1.3g", min(diff.raw, na.rm=T) ), "Mean =", sprintf("%1.3g", mean(diff.raw, na.rm=T) ), "Max =", sprintf("%1.3g", max(diff.raw, na.rm=T) ), sep=" ") )
par(xpd=F)

rm(diff)
rm(diff.raw)

dev.off()
