# R script to perform a Tilmes (2011)
# comparison of model O3 to sondes.

# Alex Archibald, CAS, July 2012
# Modified August 2015 to include ENS ACCMIP data
# changes plotting to use a function

# constants and vars
conv <- 1E9

# logical to interpolat ozone field onto pressure levels
interp.field <- FALSE

if (interp.field==TRUE) {

# extract variables
lon <- get.var.ncdf(nc1, "longitude")
lat <- get.var.ncdf(nc1, "latitude")
lev <- get.var.ncdf(nc1, "hybrid_ht")*1E-3
time <- get.var.ncdf(nc1, "t") 

# do pressure interpolation of ozone field onto fixed levels 
pres <- c(1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300,250,225,200,175,150,125,100,70,50,30,20,10)

var  <- o3.code

# interpolate the field
source(paste(script.dir, "interpolate_3d_eval.R", sep=""))

# set the plotting field to the interpolated field
o3 <- newvv*(conv/mm.o3)

# clean up arrays
rm(newvv); rm(var)
} else {
# import the saved pressure interpolated model o3 data
nc0 <- open.ncdf(paste(out.dir, mod1.name, "_pres_interp_ozone.nc",sep=""))
}
# import the ACCMIP ENS fields
nca <- open.ncdf(paste(obs.dir, "ACCMIP/ENS/vmro3RF_ACCMIP-monthly_ENS_acchist_r1i1p1_2000slice.nc", sep=""))

# extract variables from UKCA
lon <- get.var.ncdf(nc0, "longitude")
lat <- get.var.ncdf(nc0, "latitude")
lev <- get.var.ncdf(nc0, "pressure")
time <- get.var.ncdf(nc0, "time") 
o3 <- re.grid.map(get.var.ncdf(nc0, o3.code), lon)*(conv/mm.o3)

# extract variables from ACCMIP
lon.a <- get.var.ncdf(nca, "lon")
lat.a <- get.var.ncdf(nca, "lat")
lev.a <- get.var.ncdf(nca, "lev")
time.a <- get.var.ncdf(nca, "time") 
o3.accmip <- re.grid.map(get.var.ncdf(nca, "vmro3RF"), lon.a)*conv


# find the index for the mid latitude in the array
midlon <- which(lon>=180.0)[1]
maxlon <- length(lon)
dellon <- lon[2]-lon[1]
dellat <- lat[2] - lat[1]
# reform array - centers the array on the meridian
#o3  <- abind(o3[midlon:maxlon,,,], o3[1:midlon-1,,,], along=1)
lon <- seq(-180,180-dellon,dellon)

# set up labels for months
monthNames <- format(seq(as.POSIXct("2005-01-01"),by="1 months",length=12), "%b")

# ================================================================== 
# extract the obs
sh.pol.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/sh_polar1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
sh.pol.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/sh_polar1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
sh.mid.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/sh_midlat1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
sh.mid.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/sh_midlat1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
tropics2.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/tropics21995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
tropics2.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/tropics21995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
tropics3.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/tropics31995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
tropics3.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/tropics31995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
eastus.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/eastern_us1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
eastus.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/eastern_us1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
japan.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/japan1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
japan.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/japan1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
westeu.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/west_europe1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
westeu.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/west_europe1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
canada.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/canada1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
canada.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/canada1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
nh.pol.e.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/nh_polar_east1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
nh.pol.e.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/nh_polar_east1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])
nh.pol.w.mean <- t(read.table(paste(obs.dir, "Tilmes_Ozone/nh_polar_west1995_2011.asc", sep=""), skip=33, header=FALSE, nrows=26)[,2:13])
nh.pol.w.sd   <- t(read.table(paste(obs.dir, "Tilmes_Ozone/nh_polar_west1995_2011.asc", sep=""), skip=114, header=FALSE, nrows=26)[,2:13])

# source the observation locations
fields <- read.csv(paste(script.dir, "tilmes_locations.R", sep=""))
# ================================================================== 

# convert observation lats and lons to model grid boxes
fields$mLat1 <- (round (  ((fields$lat1 +90)/dellat)  ))+1
fields$mLat2 <- (round (  ((fields$lat2 +90)/dellat)  ))+1

fields$mLon1 <- ifelse ( fields$lon1<0, (round( ((fields$lon1+360)/dellon)-0.5))+1, (round( ((fields$lon1/dellon)-0.5) ))+1  )
fields$mLon2 <- ifelse ( fields$lon2<0, (round( ((fields$lon2+360)/dellon)-0.5))+1, (round( ((fields$lon2/dellon)-0.5) ))+1  )

# convert observation lats and lons to ACCMIP grid boxes (NB 5x5 grid box spacing)
fields$aLat1 <- (round (  ((fields$lat1 +90)/5)  ))+1
fields$aLat2 <- (round (  ((fields$lat2 +90)/5)  ))+1

fields$aLon1 <- ifelse ( fields$lon1<0, (round( ((fields$lon1+360)/5)-0.5))+1, (round( ((fields$lon1/5)-0.5) ))+1  )
fields$aLon2 <- ifelse ( fields$lon2<0, (round( ((fields$lon2+360)/5)-0.5))+1, (round( ((fields$lon2/5)-0.5) ))+1  )

# use split to convert the location data frame into a series of data frames split by the
# region
stations <- split(fields[], fields$region)

# ================================================================== 
# extract the model fields (mean and sd)
sh.pol.mod.mean <- apply(o3[stations$sh.pol$mLon1:stations$sh.pol$mLon2, stations$sh.pol$mLat1:stations$sh.pol$mLat2, ,], c(3,4), mean, na.rm=T)
sh.mid.mod.mean <- apply(o3[stations$sh.mid$mLon1:stations$sh.mid$mLon2, stations$sh.mid$mLat1:stations$sh.mid$mLat2, ,], c(3,4), mean, na.rm=T)
tropics2.mod.mean <- apply(o3[stations$tropics2$mLon1:stations$tropics2$mLon2, stations$tropics2$mLat1:stations$tropics2$mLat2, ,], c(3,4), mean, na.rm=T)
tropics3.mod.mean <- apply(o3[stations$tropics3$mLon1:stations$tropics3$mLon2, stations$tropics3$mLat1:stations$tropics3$mLat2, ,], c(3,4), mean, na.rm=T)
eastus.mod.mean <- apply(o3[stations$eastus$mLon1:stations$eastus$mLon2, stations$eastus$mLat1:stations$eastus$mLat2, ,], c(3,4), mean, na.rm=T)
japan.mod.mean <- apply(o3[stations$japan$mLon1:stations$japan$mLon2, stations$japan$mLat1:stations$japan$mLat2, ,], c(3,4), mean, na.rm=T)
westeu.mod.mean <- apply(o3[stations$westeu$mLon1:stations$westeu$mLon2, stations$westeu$mLat1:stations$westeu$mLat2, ,], c(3,4), mean, na.rm=T)
canada.mod.mean <- apply(o3[stations$canada$mLon1:stations$canada$mLon2, stations$canada$mLat1:stations$canada$mLat2, ,], c(3,4), mean, na.rm=T)
nh.pol.e.mod.mean <- apply(o3[stations$nh.pol.e$mLon1:stations$nh.pol.e$mLon2, stations$nh.pol.e$mLat1:stations$nh.pol.e$mLat2, ,], c(3,4), mean, na.rm=T)
nh.pol.w.mod.mean <- apply(o3[stations$nh.pol.w$mLon1:stations$nh.pol.w$mLon2, stations$nh.pol.w$mLat1:stations$nh.pol.w$mLat2, ,], c(3,4), mean, na.rm=T)

sh.pol.mod.sd <- apply(o3[stations$sh.pol$mLon1:stations$sh.pol$mLon2, stations$sh.pol$mLat1:stations$sh.pol$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
sh.mid.mod.sd <- apply(o3[stations$sh.mid$mLon1:stations$sh.mid$mLon2, stations$sh.mid$mLat1:stations$sh.mid$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
tropics2.mod.sd <- apply(o3[stations$tropics2$mLon1:stations$tropics2$mLon2, stations$tropics2$mLat1:stations$tropics2$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
tropics3.mod.sd <- apply(o3[stations$tropics3$mLon1:stations$tropics3$mLon2, stations$tropics3$mLat1:stations$tropics3$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
eastus.mod.sd <- apply(o3[stations$eastus$mLon1:stations$eastus$mLon2, stations$eastus$mLat1:stations$eastus$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
japan.mod.sd <- apply(o3[stations$japan$mLon1:stations$japan$mLon2, stations$japan$mLat1:stations$japan$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
westeu.mod.sd <- apply(o3[stations$westeu$mLon1:stations$westeu$mLon2, stations$westeu$mLat1:stations$westeu$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
canada.mod.sd <- apply(o3[stations$canada$mLon1:stations$canada$mLon2, stations$canada$mLat1:stations$canada$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
nh.pol.e.mod.sd <- apply(o3[stations$nh.pol.e$mLon1:stations$nh.pol.e$mLon2, stations$nh.pol.e$mLat1:stations$nh.pol.e$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
nh.pol.w.mod.sd <- apply(o3[stations$nh.pol.w$mLon1:stations$nh.pol.w$mLon2, stations$nh.pol.w$mLat1:stations$nh.pol.w$mLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )

# ================================================================== 
# extract the ACCMIP o3
sh.pol.accmip.mean <- apply(o3.accmip[stations$sh.pol$aLon1:stations$sh.pol$aLon2, stations$sh.pol$aLat1:stations$sh.pol$aLat2, ,], c(3,4), mean, na.rm=T)
sh.mid.accmip.mean <- apply(o3.accmip[stations$sh.mid$aLon1:stations$sh.mid$aLon2, stations$sh.mid$aLat1:stations$sh.mid$aLat2, ,], c(3,4), mean, na.rm=T)
tropics2.accmip.mean <- apply(o3.accmip[stations$tropics2$aLon1:stations$tropics2$aLon2, stations$tropics2$aLat1:stations$tropics2$aLat2, ,], c(3,4), mean, na.rm=T)
tropics3.accmip.mean <- apply(o3.accmip[stations$tropics3$aLon1:stations$tropics3$aLon2, stations$tropics3$aLat1:stations$tropics3$aLat2, ,], c(3,4), mean, na.rm=T)
eastus.accmip.mean <- apply(o3.accmip[stations$eastus$aLon1:stations$eastus$aLon2, stations$eastus$aLat1:stations$eastus$aLat2, ,], c(3,4), mean, na.rm=T)
japan.accmip.mean <- apply(o3.accmip[stations$japan$aLon1:stations$japan$aLon2, stations$japan$aLat1:stations$japan$aLat2, ,], c(3,4), mean, na.rm=T)
westeu.accmip.mean <- apply(o3.accmip[stations$westeu$aLon1:stations$westeu$aLon2, stations$westeu$aLat1:stations$westeu$aLat2, ,], c(3,4), mean, na.rm=T)
canada.accmip.mean <- apply(o3.accmip[stations$canada$aLon1:stations$canada$aLon2, stations$canada$aLat1:stations$canada$aLat2, ,], c(3,4), mean, na.rm=T)
nh.pol.e.accmip.mean <- apply(o3.accmip[stations$nh.pol.e$aLon1:stations$nh.pol.e$aLon2, stations$nh.pol.e$aLat1:stations$nh.pol.e$aLat2, ,], c(3,4), mean, na.rm=T)
nh.pol.w.accmip.mean <- apply(o3.accmip[stations$nh.pol.w$aLon1:stations$nh.pol.w$aLon2, stations$nh.pol.w$aLat1:stations$nh.pol.w$aLat2, ,], c(3,4), mean, na.rm=T)

sh.pol.accmip.sd <- apply(o3.accmip[stations$sh.pol$aLon1:stations$sh.pol$aLon2, stations$sh.pol$aLat1:stations$sh.pol$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
sh.mid.accmip.sd <- apply(o3.accmip[stations$sh.mid$aLon1:stations$sh.mid$aLon2, stations$sh.mid$aLat1:stations$sh.mid$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
tropics2.accmip.sd <- apply(o3.accmip[stations$tropics2$aLon1:stations$tropics2$aLon2, stations$tropics2$aLat1:stations$tropics2$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
tropics3.accmip.sd <- apply(o3.accmip[stations$tropics3$aLon1:stations$tropics3$aLon2, stations$tropics3$aLat1:stations$tropics3$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
eastus.accmip.sd <- apply(o3.accmip[stations$eastus$aLon1:stations$eastus$aLon2, stations$eastus$aLat1:stations$eastus$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
japan.accmip.sd <- apply(o3.accmip[stations$japan$aLon1:stations$japan$aLon2, stations$japan$aLat1:stations$japan$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
westeu.accmip.sd <- apply(o3.accmip[stations$westeu$aLon1:stations$westeu$aLon2, stations$westeu$aLat1:stations$westeu$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
canada.accmip.sd <- apply(o3.accmip[stations$canada$aLon1:stations$canada$aLon2, stations$canada$aLat1:stations$canada$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
nh.pol.e.accmip.sd <- apply(o3.accmip[stations$nh.pol.e$aLon1:stations$nh.pol.e$aLon2, stations$nh.pol.e$aLat1:stations$nh.pol.e$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
nh.pol.w.accmip.sd <- apply(o3.accmip[stations$nh.pol.w$aLon1:stations$nh.pol.w$aLon2, stations$nh.pol.w$aLat1:stations$nh.pol.w$aLat2, ,], c(3,4), function(x) sd(as.vector(x), na.rm=T) )
# ================================================================== 
# calc stats
# correlation
cor.sh.pol.250 <- cor(sh.pol.mean[,11], sh.pol.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.500 <- cor(sh.pol.mean[,6], sh.pol.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.700 <- cor(sh.pol.mean[,4], sh.pol.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.900 <- cor(sh.pol.mean[,2], sh.pol.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.sh.mid.250 <- cor(sh.mid.mean[,11], sh.mid.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.500 <- cor(sh.mid.mean[,6], sh.mid.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.700 <- cor(sh.mid.mean[,4], sh.mid.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.900 <- cor(sh.mid.mean[,2], sh.mid.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.tropics2.250 <- cor(tropics2.mean[,11], tropics2.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.500 <- cor(tropics2.mean[,6], tropics2.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.700 <- cor(tropics2.mean[,4], tropics2.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.900 <- cor(tropics2.mean[,2], tropics2.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.tropics3.250 <- cor(tropics3.mean[,11], tropics3.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.500 <- cor(tropics3.mean[,6], tropics3.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.700 <- cor(tropics3.mean[,4], tropics3.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.900 <- cor(tropics3.mean[,2], tropics3.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.eastus.250 <- cor(eastus.mean[,11], eastus.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.eastus.500 <- cor(eastus.mean[,6], eastus.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.eastus.700 <- cor(eastus.mean[,4], eastus.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.eastus.900 <- cor(eastus.mean[,2], eastus.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.japan.250 <- cor(japan.mean[,11], japan.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.japan.500 <- cor(japan.mean[,6], japan.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.japan.700 <- cor(japan.mean[,4], japan.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.japan.900 <- cor(japan.mean[,2], japan.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.westeu.250 <- cor(westeu.mean[,11], westeu.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.westeu.500 <- cor(westeu.mean[,6], westeu.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.westeu.700 <- cor(westeu.mean[,4], westeu.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.westeu.900 <- cor(westeu.mean[,2], westeu.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.canada.250 <- cor(canada.mean[,11], canada.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.canada.500 <- cor(canada.mean[,6], canada.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.canada.700 <- cor(canada.mean[,4], canada.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.canada.900 <- cor(canada.mean[,2], canada.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.nh.pol.e.250 <- cor(nh.pol.e.mean[,11], nh.pol.e.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.500 <- cor(nh.pol.e.mean[,6], nh.pol.e.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.700 <- cor(nh.pol.e.mean[,4], nh.pol.e.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.900 <- cor(nh.pol.e.mean[,2], nh.pol.e.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

cor.nh.pol.w.250 <- cor(nh.pol.w.mean[,11], nh.pol.w.mod.mean[21,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.500 <- cor(nh.pol.w.mean[,6], nh.pol.w.mod.mean[16,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.700 <- cor(nh.pol.w.mean[,4], nh.pol.w.mod.mean[12,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.900 <- cor(nh.pol.w.mean[,2], nh.pol.w.mod.mean[5,],use="pairwise.complete.obs",method="pearson")

# mean bias error:
mbe.sh.pol.250 <- mbe(sh.pol.mod.mean[21,], sh.pol.mean[,11])
mbe.sh.pol.500 <- mbe(sh.pol.mod.mean[16,],sh.pol.mean[,6])
mbe.sh.pol.700 <- mbe(sh.pol.mod.mean[12,],sh.pol.mean[,2])
mbe.sh.pol.900 <- mbe(sh.pol.mod.mean[5,],sh.pol.mean[,2])

mbe.sh.mid.250 <- mbe(sh.mid.mod.mean[21,],sh.mid.mean[,11])
mbe.sh.mid.500 <- mbe(sh.mid.mod.mean[16,],sh.mid.mean[,6])
mbe.sh.mid.700 <- mbe(sh.mid.mod.mean[12,],sh.mid.mean[,2])
mbe.sh.mid.900 <- mbe(sh.mid.mod.mean[5,],sh.mid.mean[,2])

mbe.tropics2.250 <- mbe(tropics2.mod.mean[21,],tropics2.mean[,11])
mbe.tropics2.500 <- mbe(tropics2.mod.mean[16,],tropics2.mean[,6])
mbe.tropics2.700 <- mbe(tropics2.mod.mean[12,],tropics2.mean[,2])
mbe.tropics2.900 <- mbe(tropics2.mod.mean[5,],tropics2.mean[,2])

mbe.tropics3.250 <- mbe(tropics3.mod.mean[21,],tropics3.mean[,11])
mbe.tropics3.500 <- mbe(tropics3.mod.mean[16,],tropics3.mean[,6])
mbe.tropics3.700 <- mbe(tropics3.mod.mean[12,],tropics3.mean[,2])
mbe.tropics3.900 <- mbe(tropics3.mod.mean[5,],tropics3.mean[,2])

mbe.eastus.250 <- mbe(eastus.mod.mean[21,],eastus.mean[,11])
mbe.eastus.500 <- mbe(eastus.mod.mean[16,],eastus.mean[,6])
mbe.eastus.700 <- mbe(eastus.mod.mean[12,],eastus.mean[,2])
mbe.eastus.900 <- mbe(eastus.mod.mean[5,],eastus.mean[,2])

mbe.japan.250 <- mbe(japan.mod.mean[21,],japan.mean[,11])
mbe.japan.500 <- mbe(japan.mod.mean[16,],japan.mean[,6])
mbe.japan.700 <- mbe(japan.mod.mean[12,],japan.mean[,2])
mbe.japan.900 <- mbe(japan.mod.mean[5,],japan.mean[,2])

mbe.westeu.250 <- mbe(westeu.mod.mean[21,],westeu.mean[,11])
mbe.westeu.500 <- mbe(westeu.mod.mean[16,],westeu.mean[,6])
mbe.westeu.700 <- mbe(westeu.mod.mean[12,],westeu.mean[,2])
mbe.westeu.900 <- mbe(westeu.mod.mean[5,],westeu.mean[,2])

mbe.canada.250 <- mbe(canada.mod.mean[21,],canada.mean[,11])
mbe.canada.500 <- mbe(canada.mod.mean[16,],canada.mean[,6])
mbe.canada.700 <- mbe(canada.mod.mean[12,],canada.mean[,2])
mbe.canada.900 <- mbe(canada.mod.mean[5,],canada.mean[,2])

mbe.nh.pol.e.250 <- mbe(nh.pol.e.mod.mean[21,],nh.pol.e.mean[,11])
mbe.nh.pol.e.500 <- mbe(nh.pol.e.mod.mean[16,],nh.pol.e.mean[,6])
mbe.nh.pol.e.700 <- mbe(nh.pol.e.mod.mean[12,],nh.pol.e.mean[,2])
mbe.nh.pol.e.900 <- mbe(nh.pol.e.mod.mean[5,],nh.pol.e.mean[,2])

mbe.nh.pol.w.250 <- mbe(nh.pol.w.mod.mean[21,],nh.pol.w.mean[,11])
mbe.nh.pol.w.500 <- mbe(nh.pol.w.mod.mean[16,],nh.pol.w.mean[,6])
mbe.nh.pol.w.700 <- mbe(nh.pol.w.mod.mean[12,],nh.pol.w.mean[,2])
mbe.nh.pol.w.900 <- mbe(nh.pol.w.mod.mean[5,],nh.pol.w.mean[,2])
# ############################################################################################################################################
pdf(file=paste(out.dir,mod1.name,"_Tilmes_ozone.pdf", sep=""),width=12,height=9,paper="special",onefile=TRUE,pointsize=13)

par (fig=c(0,1,0,1), # Figure region in the device display region (x1,x2,y1,y2)
       omi=c(0.3,0.8,0.8,0.05), # global margins in inches (bottom, left, top, right)
       mai=c(0.01,0.01,0.01,0.01), # subplot margins in inches (bottom, left, top, right)
       mgp=c(2, 0.5, 0) )
layout(matrix(1:40, 4, 10, byrow = TRUE))


plot.tilmes <- function(obs.mean, obs.sd, mod.mean, mod.sd, 
                        cor.mod, mbe.mod, ylim, xt, yt,
                        accmip.mean, accmip.sd ) {
  # function to plot one of the panels of the multi panel tilmes plot. 
  if(missing(accmip.mean)) {
    if(missing(accmip.sd)) {
      # basic plots without accmip data
      plot(1:12, obs.mean, type="l", lwd=3, ylim=ylim, ylab="", xlab="", yaxt="n", 
           xaxt="n" )
      grid()
      polygon( c(1:12, rev(1:12)), c(obs.mean+obs.sd, rev(obs.mean-obs.sd)),
               border=NA, col=rgb(169/256,169/256,169/256,0.5) )
      # add the observations
      lines(obs.mean)
      # add the ukca
      lines(1:12, mod.mean, lwd=3, col="red")
      arrows( 1:12, (mod.mean-mod.sd), 1:12, (mod.mean+mod.sd), 
              length = 0.0, code =2, col="red" )  
      # add legend
      legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.mod),
                                "\nmbe =", sprintf("%1.3g", mbe.mod), "%", sep="")), cex=0.9, bty="n")
      # add x axis
      if(xt == TRUE) axis(side=1, 1:12, labels=monthNames, tick=TRUE, las=1)
      # add y axis
      if(yt == TRUE) axis(side=2, pretty(ylim), labels=pretty(ylim), tick=TRUE, las=1)
    }} # end if missing
  else { # we are plotting the model, obs and accmip data
    plot(1:12, obs.mean, type="l", lwd=3, ylim=ylim, ylab="", xlab="", yaxt="n", 
         xaxt="n" )
    grid()
    polygon( c(1:12, rev(1:12)), c(obs.mean+obs.sd, rev(obs.mean-obs.sd)),
             border=NA, col=rgb(169/256,169/256,169/256,0.5) )
    # add the observations
    lines(obs.mean)
    # add the ukca
    lines(1:12, mod.mean, lwd=3, col="red")
    arrows( 1:12, (mod.mean-mod.sd), 1:12, (mod.mean+mod.sd), 
            length = 0.0, code =2, col="red" )  
    # add legend
    legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.mod),
                              "\nmbe =", sprintf("%1.3g", mbe.mod), "%", sep="")), cex=0.9, bty="n")
    # add x axis
    if(xt == TRUE) axis(side=1, 1:12, labels=monthNames, tick=TRUE, las=1)
    # add y axis
    if(yt == TRUE) axis(side=2, pretty(ylim), labels=pretty(ylim), tick=TRUE, las=1)
    # add the ACCMIP data
    lines(1:12, accmip.mean, lwd=3, col="blue")
    arrows( 1:12, (accmip.mean-accmip.sd), 1:12, 
            (accmip.mean+accmip.sd), length = 0.0, code =2, col="blue" )
  } # end else
}


################## 250 hPa plots ################################################
ylim <- c(0,600)
plot.tilmes(sh.pol.mean[,11], sh.pol.sd[,11], sh.pol.mod.mean[21,], sh.pol.mod.sd[21,], 
            cor.sh.pol.250, mbe.sh.pol.250, ylim, xt=FALSE, yt=TRUE,
            sh.pol.accmip.mean[17,], sh.mid.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "South \nPole") 
text(-4,300, "Ozone (ppb)", srt=90)
par(xpd=F)

plot.tilmes(sh.mid.mean[,11], sh.mid.sd[,11], sh.mid.mod.mean[21,], sh.mid.mod.sd[21,],
            cor.sh.mid.250, mbe.sh.mid.250, ylim, xt=FALSE, yt=FALSE,
            sh.mid.accmip.mean[17,], sh.mid.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "Southern \nMidlat") 
par(xpd=F)

plot.tilmes(tropics2.mean[,11], tropics2.sd[,11], tropics2.mod.mean[21,], tropics2.mod.sd[21,], 
            cor.tropics2.250, mbe.tropics2.250, ylim, xt=FALSE, yt=FALSE,
            tropics2.accmip.mean[17,], tropics2.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "Tropics2") 
par(xpd=F)

plot.tilmes(tropics3.mean[,11], tropics3.sd[,11], tropics3.mod.mean[21,], tropics3.mod.sd[21,], 
            cor.tropics3.250, mbe.tropics3.250, ylim, xt=FALSE, yt=FALSE,
            tropics3.accmip.mean[17,], tropics3.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "Tropics3") 
par(xpd=F)

plot.tilmes(eastus.mean[,11], eastus.sd[,11], eastus.mod.mean[21,], eastus.mod.sd[21,], 
            cor.eastus.250, mbe.eastus.250, ylim, xt=FALSE, yt=FALSE,
            eastus.accmip.mean[17,], eastus.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "East US") 
text(12,780, paste(mod1.name, "Tilmes ozone sonde comparison", sep=" "), font=2 ) 
par(xpd=F)

plot.tilmes(japan.mean[,11], japan.sd[,11], japan.mod.mean[21,], japan.mod.sd[21,],
            cor.japan.250, mbe.japan.250, ylim, xt=FALSE, yt=FALSE,
            japan.accmip.mean[17,], japan.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "Japan") 
par(xpd=F)


plot.tilmes(westeu.mean[,11], westeu.sd[,11], westeu.mod.mean[21,], westeu.mod.sd[21,], 
            cor.westeu.250, mbe.westeu.250, ylim, xt=FALSE, yt=FALSE, 
            westeu.accmip.mean[17,], westeu.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "West EU") 
par(xpd=F)


plot.tilmes(canada.mean[,11], canada.sd[,11], canada.mod.mean[21,], canada.mod.sd[21,], 
            cor.canada.250, mbe.canada.250, ylim, xt=FALSE, yt=FALSE,
            canada.accmip.mean[17,], canada.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "Canada") 
par(xpd=F)

plot.tilmes(nh.pol.e.mean[,11], nh.pol.e.sd[,11], nh.pol.e.mod.mean[21,], nh.pol.e.mod.sd[21,], 
            cor.nh.pol.e.250, mbe.nh.pol.e.250, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.e.accmip.mean[17,], nh.pol.e.accmip.sd[17,] )
par(xpd=NA)
text(6,680, "North Pole East") 
par(xpd=F)

plot.tilmes(nh.pol.w.mean[,11], nh.pol.w.sd[,11], nh.pol.w.mod.mean[21,], nh.pol.w.mod.sd[21,], 
            cor.nh.pol.w.250, mbe.nh.pol.w.250, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.w.accmip.mean[17,], nh.pol.w.accmip.sd[17,] )
legend("bottomleft", "250 hPa",bty="n")
par(xpd=NA)
text(6,680, "North Pole West") 
par(xpd=F)


# ################################################### 500 hPa plots ################################################################################
ylim <- c(0,120)
#obs <- 6; mod <- 16; accmip <- 20

plot.tilmes(sh.pol.mean[,6], sh.pol.sd[,6], sh.pol.mod.mean[16,], sh.pol.mod.sd[16,], 
            cor.sh.pol.500, mbe.sh.pol.500, ylim, xt=FALSE, yt=TRUE,
            sh.pol.accmip.mean[20,], sh.mid.accmip.sd[20,] )
par(xpd=NA)
text(-4,60, "Ozone (ppb)", srt=90)
par(xpd=F)

plot.tilmes(sh.mid.mean[,6], sh.mid.sd[,6], sh.mid.mod.mean[16,], sh.mid.mod.sd[16,],
            cor.sh.mid.500, mbe.sh.mid.500, ylim, xt=FALSE, yt=FALSE,
            sh.mid.accmip.mean[20,], sh.mid.accmip.sd[20,] )

plot.tilmes(tropics2.mean[,6], tropics2.sd[,6], tropics2.mod.mean[16,], tropics2.mod.sd[16,], 
            cor.tropics2.500, mbe.tropics2.500, ylim, xt=FALSE, yt=FALSE,
            tropics2.accmip.mean[20,], tropics2.accmip.sd[20,] )

plot.tilmes(tropics3.mean[,6], tropics3.sd[,6], tropics3.mod.mean[16,], tropics3.mod.sd[16,], 
            cor.tropics3.500, mbe.tropics3.500, ylim, xt=FALSE, yt=FALSE,
            tropics3.accmip.mean[20,], tropics3.accmip.sd[20,] )

plot.tilmes(eastus.mean[,6], eastus.sd[,6], eastus.mod.mean[16,], eastus.mod.sd[16,], 
            cor.eastus.500, mbe.eastus.500, ylim, xt=FALSE, yt=FALSE,
            eastus.accmip.mean[20,], eastus.accmip.sd[20,] )

plot.tilmes(japan.mean[,6], japan.sd[,6], japan.mod.mean[16,], japan.mod.sd[16,],
            cor.japan.500, mbe.japan.500, ylim, xt=FALSE, yt=FALSE,
            japan.accmip.mean[20,], japan.accmip.sd[20,] )

plot.tilmes(westeu.mean[,6], westeu.sd[,6], westeu.mod.mean[16,], westeu.mod.sd[16,], 
            cor.westeu.500, mbe.westeu.500, ylim, xt=FALSE, yt=FALSE, 
            westeu.accmip.mean[20,], westeu.accmip.sd[20,] )

plot.tilmes(canada.mean[,6], canada.sd[,6], canada.mod.mean[16,], canada.mod.sd[16,], 
            cor.canada.500, mbe.canada.500, ylim, xt=FALSE, yt=FALSE,
            canada.accmip.mean[20,], canada.accmip.sd[20,] )

plot.tilmes(nh.pol.e.mean[,6], nh.pol.e.sd[,6], nh.pol.e.mod.mean[16,], nh.pol.e.mod.sd[16,], 
            cor.nh.pol.e.500, mbe.nh.pol.e.500, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.e.accmip.mean[20,], nh.pol.e.accmip.sd[20,] )

plot.tilmes(nh.pol.w.mean[,6], nh.pol.w.sd[,6], nh.pol.w.mod.mean[16,], nh.pol.w.mod.sd[16,], 
            cor.nh.pol.w.500, mbe.nh.pol.w.500, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.w.accmip.mean[20,], nh.pol.w.accmip.sd[20,] )
legend("bottomleft", "500 hPa",bty="n")

# ################################################### 700 hPa plots ################################################################################
ylim <- c(0,120)
#obs <- 4; mod <- 12; accmip <- 22

plot.tilmes(sh.pol.mean[,4], sh.pol.sd[,4], sh.pol.mod.mean[12,], sh.pol.mod.sd[12,], 
            cor.sh.pol.700, mbe.sh.pol.700, ylim, xt=FALSE, yt=TRUE,
            sh.pol.accmip.mean[22,], sh.mid.accmip.sd[22,] )
par(xpd=NA)
text(-4,60, "Ozone (ppb)", srt=90)
par(xpd=F)

plot.tilmes(sh.mid.mean[,4], sh.mid.sd[,4], sh.mid.mod.mean[12,], sh.mid.mod.sd[12,],
            cor.sh.mid.700, mbe.sh.mid.700, ylim, xt=FALSE, yt=FALSE,
            sh.mid.accmip.mean[22,], sh.mid.accmip.sd[22,] )

plot.tilmes(tropics2.mean[,4], tropics2.sd[,4], tropics2.mod.mean[12,], tropics2.mod.sd[12,], 
            cor.tropics2.700, mbe.tropics2.700, ylim, xt=FALSE, yt=FALSE,
            tropics2.accmip.mean[22,], tropics2.accmip.sd[22,] )

plot.tilmes(tropics3.mean[,4], tropics3.sd[,4], tropics3.mod.mean[12,], tropics3.mod.sd[12,], 
            cor.tropics3.700, mbe.tropics3.700, ylim, xt=FALSE, yt=FALSE,
            tropics3.accmip.mean[22,], tropics3.accmip.sd[22,] )

plot.tilmes(eastus.mean[,4], eastus.sd[,4], eastus.mod.mean[12,], eastus.mod.sd[12,], 
            cor.eastus.700, mbe.eastus.700, ylim, xt=FALSE, yt=FALSE,
            eastus.accmip.mean[22,], eastus.accmip.sd[22,] )

plot.tilmes(japan.mean[,4], japan.sd[,4], japan.mod.mean[12,], japan.mod.sd[12,],
            cor.japan.700, mbe.japan.700, ylim, xt=FALSE, yt=FALSE,
            japan.accmip.mean[22,], japan.accmip.sd[22,] )

plot.tilmes(westeu.mean[,4], westeu.sd[,4], westeu.mod.mean[12,], westeu.mod.sd[12,], 
            cor.westeu.700, mbe.westeu.700, ylim, xt=FALSE, yt=FALSE, 
            westeu.accmip.mean[22,], westeu.accmip.sd[22,] )

plot.tilmes(canada.mean[,4], canada.sd[,4], canada.mod.mean[12,], canada.mod.sd[12,], 
            cor.canada.700, mbe.canada.700, ylim, xt=FALSE, yt=FALSE,
            canada.accmip.mean[22,], canada.accmip.sd[22,] )

plot.tilmes(nh.pol.e.mean[,4], nh.pol.e.sd[,4], nh.pol.e.mod.mean[12,], nh.pol.e.mod.sd[12,], 
            cor.nh.pol.e.700, mbe.nh.pol.e.700, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.e.accmip.mean[22,], nh.pol.e.accmip.sd[22,] )

plot.tilmes(nh.pol.w.mean[,4], nh.pol.w.sd[,4], nh.pol.w.mod.mean[12,], nh.pol.w.mod.sd[12,], 
            cor.nh.pol.w.700, mbe.nh.pol.w.700, ylim, xt=FALSE, yt=FALSE, 
            nh.pol.w.accmip.mean[22,], nh.pol.w.accmip.sd[22,] )
legend("bottomleft", "700 hPa",bty="n")

# ################################################### 900 hPa plots ################################################################################
ylim <- c(0,80)
#obs <- 2; mod <- 5 

plot.tilmes(sh.pol.mean[,4], sh.pol.sd[,4], sh.pol.mod.mean[12,], sh.pol.mod.sd[12,], 
            cor.sh.pol.900, mbe.sh.pol.900, ylim, xt=TRUE, yt=TRUE)
par(xpd=NA)
text(-4,40, "Ozone (ppb)", srt=90)
par(xpd=F)

plot.tilmes(sh.mid.mean[,4], sh.mid.sd[,4], sh.mid.mod.mean[12,], sh.mid.mod.sd[12,],
            cor.sh.mid.900, mbe.sh.mid.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(tropics2.mean[,4], tropics2.sd[,4], tropics2.mod.mean[12,], tropics2.mod.sd[12,], 
            cor.tropics2.900, mbe.tropics2.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(tropics3.mean[,4], tropics3.sd[,4], tropics3.mod.mean[12,], tropics3.mod.sd[12,], 
            cor.tropics3.900, mbe.tropics3.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(eastus.mean[,4], eastus.sd[,4], eastus.mod.mean[12,], eastus.mod.sd[12,], 
            cor.eastus.900, mbe.eastus.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(japan.mean[,4], japan.sd[,4], japan.mod.mean[12,], japan.mod.sd[12,],
            cor.japan.900, mbe.japan.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(westeu.mean[,4], westeu.sd[,4], westeu.mod.mean[12,], westeu.mod.sd[12,], 
            cor.westeu.900, mbe.westeu.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(canada.mean[,4], canada.sd[,4], canada.mod.mean[12,], canada.mod.sd[12,], 
            cor.canada.900, mbe.canada.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(nh.pol.e.mean[,4], nh.pol.e.sd[,4], nh.pol.e.mod.mean[12,], nh.pol.e.mod.sd[12,], 
            cor.nh.pol.e.900, mbe.nh.pol.e.900, ylim, xt=TRUE, yt=FALSE)

plot.tilmes(nh.pol.w.mean[,4], nh.pol.w.sd[,4], nh.pol.w.mod.mean[12,], nh.pol.w.mod.sd[12,], 
            cor.nh.pol.w.900, mbe.nh.pol.w.900, ylim, xt=TRUE, yt=FALSE)
legend("bottomleft", "900 hPa",bty="n")

dev.off()

