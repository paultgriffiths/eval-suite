# R script to plot and calculate the 
# lightning NOx.

# Alex Archibald, July 2012

# loop vars
i <- NULL; j <- NULL
nav      <- 6.02214179E23 

# extract/define variables
lon   <- ncvar_get(nc1,"longitude") 
lat   <- ncvar_get(nc1, "latitude")
#hgt   <- ncvar_get(nc1, "hybrid_ht")*1E-3
hgt   <- ncvar_get(nc1, "level_ht")*1.0E-3
time  <- ncvar_get(nc1, "time")

lgt   <- ncvar_get(nc1, lgt.em.code)

# volume
if ( exists("vol") == FALSE )source("load_grid_info.R")

# define empty arrays
flux.zm.nrm <- array(NA, dim=c(length(lon), length(lat), length(hgt), length(time)) )

# calc the total lightning NOx source (Tg N/yr) (assuming have 12 months data)
total <- sum(lgt*86400*30*14)/1E12

# calc surface integrated flux
srf <- apply(lgt, c(1,2), sum)
srf <- srf*14*1E9 # Mg of N
srf <- srf/gb.sa # Mg of N /m2 /yr

# find the index for the mid latitude in the array
midlon <- which(lon>=180.0)[1]
maxlon <- length(lon)
dellon <- lon[2]-lon[1]
# reform array - makes it look nicer on map
srf <- abind(srf[midlon:maxlon,], srf[1:midlon-1,], along=1)

#  calc the zonal mean distribution (normalised)
for (i in 1: length(time) ) {
flux.zm.nrm[,,,i] <- lgt[,,,i]/(vol) }
#flux.zm.nrm[,,,i] <- lgt[,,,i]/(vol*1E6) }
flux.zm.nrm <- apply(flux.zm.nrm*nav, c(2,3), mean)

# plot params
plot.breaks.zm  <- c(0,1,10,100,200,500,1000,2000,3000,4000,5000,6000)
plot.breaks.srf <- c(0,0.01,0.1,1,2,5,10,20,50,100,150)
# ######################################################################################################
# plot the fields

pdf(file=paste(out_dir,"/",mod1.name,"_lightning.pdf", sep=""), width=7,height=10,paper="special")

par(mfrow=c(2,1))
par(oma=c(0, 0, 1, 0)) 
par(mgp = c(2, 0.5, 0))

image(seq(-180,180-dellon,dellon), lat, srf, main=paste(mod1.name, " total column", sep=""),
xlab="", ylab="Latitude (degrees)", col=lgt.cols(10), ylim=c(-80,90), breaks=plot.breaks.srf )
map("world", add=T)
grid()
box()
par(xpd=T)
text(40,-75, paste("Total =",sprintf("%1.3g", total ), "Tg(N)/yr", sep=" ") )
text(-135,94, expression(paste("ng-N/m"^"2","/yr", sep="") ))
color.legend(-180,-110,180,-100,legend=plot.breaks.srf, rect.col=lgt.cols(10), gradient="x", align="rb")
par(xpd=F)

image(lat, hgt, flux.zm.nrm, main=paste(mod1.name, " zonal mean", sep=""), ylim=c(0,20), 
xlab="", ylab="Altitude (km)", col=lgt.cols(11), breaks=plot.breaks.zm )
grid()
box()
par(xpd=T)
text(-70,21, expression(paste("molecules cm"^"-3"," s"^"-1", sep="") ))
color.legend(-90,-5,90,-3,legend=plot.breaks.zm, rect.col=lgt.cols(11), gradient="x", align="rb")
par(xpd=F)


dev.off()
