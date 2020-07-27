# R script to plot and calculate the zonal 
# mean age of air.

# Alex Archibald, March 2012


# define constants and conv. factors
conv.factor <- 60*60*24*30*12 # assumes a 360 day calendar
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
hgt   <- ncvar_get(nc1, "level_ht")
time  <- ncvar_get(nc1, "time")

# Check if Age-of-air exists (not available if tropospheric chem runs)
agid <- var_exists(nc1, age.air)
if ( agid < 0 )  {
 print("Age-of-air field not found in model output")
 print("PLOT_AGEAIR cannot continue")
 q()
}

aoa.nc  <- nc_open(paste(obs_dir,"MIPAS/test.nc",sep="/"), readunlim=F)
aoa     <- ncvar_get(aoa.nc, "AGE")
aoa.sd  <- ncvar_get(aoa.nc, "AGESTD")
aoa.lat <- rev(ncvar_get(aoa.nc, "lat"))
aoa.alt <- ncvar_get(aoa.nc, "altitude")

# The MIPAS data is for 2002-2010 and is already monthly 
# averaged zonal means. Here we combine those into 
# one average and reorder the array.
aoa.m   <- apply(aoa, c(2,1), mean, na.rm=T)
aoa.m   <- aoa.m[rev(1:length(aoa.lat)),]
aoa.std <- apply(aoa.sd, c(2,1), mean, na.rm=T)
aoa.std <- aoa.std[rev(1:length(aoa.lat)),]

# define model tropopause height on pressure (using scale height from UKCA)
#source("get_trophgt_msk.R")
#ht     <- apply(trophgt, c(2), mean)*1E-3 # km

#ht     <- ncvar_get(nc1, "ht")
#ht     <- apply(ht, c(2), mean)*1E-3 # km

age   <- ncvar_get(nc1, age.air) # *3.0 ## NOTE I made a mistake in my umui job set up so have had to multiply fluxes (here) by three!!
age   <- (apply(age, c(2,3), mean))/conv.factor

# Get level at 23 km
lev23   <- which((hgt/1000.)>22.5)[1]
print(paste("Level for 23km ",lev23))

# The model AoA is set such that the value of air at the tropopause 
# is 0.0 years. Therefore, we bias subtract the obs to account for this
aoa.m <- aoa.m - mean(aoa.m[16:20,13:18])

# Subset the model and obs for the CCMVal plots
trop.mean.ukca  <- apply(age[tail(which(lat<= -10.0),1):which(lat>= 10.0)[1],], c(2), mean)
trop.mean.mipas <- apply(aoa.m[tail(which(aoa.lat<= -10.0),1):which(aoa.lat>= 10.0)[1],], c(2), mean)
trop.stdev.mipas<- apply(aoa.std[tail(which(aoa.lat<= -10.0),1):which(aoa.lat>= 10.0)[1],], c(2), mean)

midlat.mean.ukca  <- apply(age[tail(which(lat<= 35.0),1):which(lat>= 45.0)[1],], c(2), mean)
midlat.mean.mipas <- apply(aoa.m[tail(which(aoa.lat<= 35.0),1):which(aoa.lat>= 45.0)[1],], c(2), mean)
midlat.stdev.mipas<- apply(aoa.std[tail(which(aoa.lat<= 35.0),1):which(aoa.lat>= 45.0)[1],], c(2), mean)

age23 <- age[,lev23]
aoa23 <- aoa.m[,23]

rm(age); rm(aoa.m); gc()

# ###################################################################################################################################
pdf(file=paste(out_dir,"/",mod1.name,"_age_of_air_ccmval.pdf", sep=""),width=6,height=7,paper="special",onefile=TRUE,pointsize=12)
par(mfrow=c(2,2))
par(oma=c(0,0,1,0)) 
par(mgp = c(2, 1, 0))

# plot the data 
plot(trop.mean.ukca, hgt/1000, xlab="Mean Age (years)", ylab="Altitude (km)", 
xlim=c(0,7), ylim=c(16,34), col="red", type="l", lwd=1.5, main="Tropical Mean Age Profile" ) 
# add the obs
lines(trop.mean.mipas, aoa.alt, lwd=2, type="o", pch=15)
arrows( (trop.mean.mipas-trop.stdev.mipas), aoa.alt, (trop.mean.mipas+trop.stdev.mipas), aoa.alt, length=0.0, code=2 )
grid()

title(main=paste("UKCA",mod1.name,"Mean Age of Air", sep=" "), outer=T, col.main="black")

# plot the data 
plot(midlat.mean.ukca, hgt/1000, xlab="Mean Age (years)", ylab="Altitude (km)", 
xlim=c(0,7), ylim=c(16,34), col="red", type="l", lwd=1.5, main="Midlatitude Mean Age Profile" ) 
# add the obs
lines(midlat.mean.mipas, aoa.alt, lwd=2, type="o", pch=15)
arrows( (midlat.mean.mipas-midlat.stdev.mipas), aoa.alt, (midlat.mean.mipas+midlat.stdev.mipas), aoa.alt, length=0.0, code=2 )
grid()

# plot the data 
plot( (midlat.mean.ukca-trop.mean.ukca), hgt/1000, xlab="Mean Age Gradient (years)", ylab="Altitude (km)", 
xlim=c(0,3.5), ylim=c(16,34), col="red", type="l", lwd=1.5, main="Trop-Midlat Mean Age Gradient Profile" ) 
# add the obs
lines( (midlat.mean.mipas-trop.mean.mipas), aoa.alt, lwd=2, type="o", pch=15)
grid()
legend("bottomright", c(mod1.name, "SF6"), lwd=c(1,1), col=c("red", "black"), pch=c(0,15), bty="n", cex=0.85)

# plot the data 
plot(lat, age23, xlab="Latitude (degrees)", ylab="Mean Age (years)", 
xlim=c(-90,90), ylim=c(0,6), col="red", type="l", lwd=1.5, main="Mean Age, 23km (~50hPa)" ) 
# add the obs
lines(aoa.lat, aoa23, lwd=2, type="o", pch=15)
arrows( aoa.lat, (aoa23-aoa.std[,23]), aoa.lat, (aoa23+aoa.std[,23]), length=0.0, code=2 )
grid()

rm(trop.mean.ukca); rm(trop.mean.mipas); rm(trop.stdev.mipas)
rm(midlat.mean.ukca); rm(midlat.mean.mipas); rm(midlat.stdev.mipas)
gc()

dev.off()
