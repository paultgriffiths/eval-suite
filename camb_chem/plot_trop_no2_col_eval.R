# R Script to calculate the tropospheric no2 column using
# tropopause mask.

# Alex Archibald, February 2012

# OMI trop NO2 column in 10^15 molecules/cm2
#nc0 <- nc_open(paste(obs.dir, "OMI/NO2/OMI_NO2_2005_N48.nc", sep=""))

# extract vars
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
#hgt   <- ncvar_get(nc1, "hybrid_ht")
time  <- ncvar_get(nc1, "time")

# define constants and loop vars and arrays
nav     <- 6.02214179E23 
mmr.no2 <- 30.0e-3 # in kg
no2.col <- array(NA, dim=c(length(lon),length(lat),length(time)) ) 
m <- NULL

#source(paste(script.dir, "check_model_dims.R", sep=""))

no2     <- ncvar_get(nc1,no2.code) # kg/kg no2
##trophgt <- ncvar_get(nc1,trop.hgt.code)
#omi.no2 <- ncvar_get(nc0, "OMI_NO2") # OMI trop NO2 in molecules cm-2 (E15)
#sat.lat <- ncvar_get(nc0, "latitude")

# #####################################################################
# Check to see if a trop. mask and mass exist?
#if ( exists("mask") == TRUE) print("Tropospheric Mask exists, carrying on") else (source(paste(script.dir, "calc_trop_mask.R", sep="")))
#if ( exists("mass") == TRUE) print("Tropospheric Mass exists, carrying on") else (mass <- ncvar_get(nc1,air.mass) )
mass     <- ncvar_get(nc1,air.mass.watm)  # kg air - whole atmosphere
mask     <- ncvar_get(nc1,tropmsk.code)
# Start calculate column ############################################################################################################
# mask out troposphere and convert to molecules 
# n.molecules = NA(molecules/mol) * mass(g) / mmr(g/mol) )
no2.mass <- (no2 * mass * mask)

# convert to molecules 
no2.mol <- nav * (no2.mass/mmr.no2) 

# NO2 column = sum in vertical (kg)
no2.mol <- apply(no2.mol,c(1,2,4),sum)

# loop over each month
# divide by area (molecules/m2) 
for (m in 1:length(time)) {
  no2.col[,,m] <- (no2.mol[,,m] /  gb.sa[,])
} 

# apply zonal mean
no2.col <- apply(no2.col, c(1,2), mean) / (100 * 100 * 1E15) 
#omi.no2 <- apply(omi.no2, c(1,2), mean, na.rm=T)

# End calculate column #############################################################################################################

# set axis'
axis_x <- seq(from=-180, to=180, by=30)
axis_y <- seq(from=-90, to=90, by=15)

zlim   <- seq(0,20,1)
nlevels<- 21
levels <- pretty(zlim, nlevels)

# set all high values to 20 for plots
no2.raw <- no2.col
no2.col[no2.col>20]<-20.0
#omi.no2[omi.no2<0.]<-NA

# find the index for the mid latitude in the array
midlon <- which(lon>=180.0)[1]
maxlon <- length(lon)
dellon <- lon[2]-lon[1]
no2.col  <- abind(no2.col[midlon:maxlon,], no2.col[1:midlon-1,], along=1)
# ###################################################################################################################################
pdf(file=paste(out_dir,'/',mod1.name,"_Trop_NO2_col.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
filled.contour(seq(-180,(180-dellon),dellon), lat, no2.col, ylab="Latitude (degrees)", xlab="Longitude (degrees)", main=bquote(paste( "", .(mod1.name), ~ "tropospheric" ~ NO[2], " column", sep=" ")), 
zlim=c(0,20), col=col.cols(length(levels)-1), xaxt="n",nlevels=nlevels, 
plot.axes= {
#contour(1:12, lat, no2.col, method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, levels=seq(0,70,5))
#contour(lon, lat, no2.col, method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, lwd=1, levels=seq(0,20,1))
axis(side=1, axis_x, labels=TRUE, tick=TRUE)
axis(side=2, axis_y, labels=TRUE, tick=TRUE)
map("world", add=T)
grid() } )

par(xpd=T)
text(-120,95, paste("Min =",sprintf("%1.3g", min(no2.raw) ), "Mean =", sprintf("%1.3g", mean(no2.raw) ), "Max =", sprintf("%1.3g", max(no2.raw) ), sep=" ") )
text(x=70,y=95, expression(paste("10"^"15", " (molecules cm"^"-2",")", sep="") ), font=2)
par(xpd=F)

dev.off()

