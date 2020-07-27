# R Script to calculate the tropospheric ozone column using
# tropopause mask.

# Alex Archibald, February 2012

# OMI trop o3 column in DU
nc0 <- nc_open(paste(obs_dir, "OMI/O3/column/OMI_trop_O3_2005.nc", sep="/"))

# extract vars
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
#hgt   <- ncvar_get(nc1, "hybrid_ht")
time  <- ncvar_get(nc1, "time")
# define constants and loop vars and arrays
conv.fac <- 2.69E20 # molec.cm-2 -> DUnits
nav      <- 6.02214179E23 
mmr.o3   <- 48.0e-3 # in kg
o3.col   <- array(NA, dim=c(length(lon),length(lat),length(time)) ) 

#source(paste(scr_dir, "check_model_dims.R", sep=""))

o3      <- ncvar_get(nc1,o3.code) # kg/kg o3
#trophgt <- ncvar_get(nc1,trop.hgt.code)
source(paste(scr_dir, "get_trophgt_msk.R", sep=""))
mass    <- ncvar_get(nc1,air.mass.watm)    #,kg air- whole atmosphere
omi.o3  <- ncvar_get(nc0, "O3") # OMI trop ozone in DU
sat.lat <- ncvar_get(nc0, "latitude")

# #####################################################################
# Check to see if a trop. mask and mass exist?
#if ( exists("mask") == TRUE) print("Tropospheric Mask exists, carrying on") else (source(paste(script.dir, "calc_trop_mask.R", sep="")))
#if ( exists("mass") == TRUE) print("Tropospheric Mass exists, carrying on") else (mass <- ncvar_get(nc1,air.mass) )

# Start calculate column ############################################################################################################
# mask out troposphere and convert to molecules 
# n.molecules = NA(molecules/mol) * mass(g) / mmr(g/mol) )
o3.mass <- (o3 * mass * mask)

# convert to molecules 
o3.mol <- nav * (o3.mass/mmr.o3) 

# Ozone column = sum in vertical (kg)
o3.mol <- apply(o3.mol,c(1,2,4),sum)

# loop over each month
# divide by area (molecules/m2) and convert to DU
for (m in 1:length(time)) {
  o3.col[,,m] <- (o3.mol[,,m] /  gb.sa[,]) / conv.fac
} 

# apply zonal mean
o3.col <- apply(o3.col, c(3,2), mean)
omi.o3 <- apply(omi.o3, c(3,2), mean)

# set max o3 to 60 DU
o3.raw <- o3.col
o3.col[o3.col>=60] <- 60

# Calc the burden in Tg
o3.burden <- sum( (o3.mass)*1E-9) / length(time)
# End calculate column #############################################################################################################

# set dates for x axis
monthNames <- format(seq(as.POSIXct("2005-01-01"),by="1 months",length=12), "%b")

# set axis'
axis_x <- monthNames
axis_y <- seq(from=-90, to=90, by=15)
zlim   <- seq(0,60,5)
nlevels<- 25
levels <- pretty(zlim, nlevels)

o3.burd   <- sprintf("%1.3g", o3.burden )

# ###################################################################################################################################
pdf(file=paste(out_dir,'/',mod1.name,"_Trop_O3_col.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
filled.contour(1:12, lat, o3.col, ylab="Latitude (degrees)", xlab="Month", main=bquote(paste( "", .(mod1.name), ~ "tropospheric" ~ O[3], " column", sep=" ")),
zlim=c(0,60), col=col.cols(length(levels)-1), xaxt="n",nlevels=nlevels, key.title="(DU)",
plot.axes= {
#contour(1:12, lat, o3.col, method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, levels=seq(0,60,5))
contour(1:12, sat.lat, omi.o3/10, method = "edge", labcex = 1, col = "black", add = TRUE, lty=1, lwd=2, levels=seq(0,60,4))
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)
axis(side=2, axis_y, labels=TRUE, tick=TRUE)
grid() } )

par(xpd=T)
text(3,95, paste("Min =",sprintf("%1.3g", min(o3.raw) ), "Mean =", sprintf("%1.3g", mean(o3.raw) ), "Max =", sprintf("%1.3g", max(o3.raw) ), sep=" ") )
text(9,95, paste("Burden (Tg) = ", o3.burd, sep="") )
par(xpd=F)

dev.off()

