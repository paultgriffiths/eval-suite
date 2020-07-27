# R script to perform a Tilmes (2011)
# comparison of model O3 to sondes.

# Alex Archibald, CAS, July 2012


# constants and vars
conv <- 1.0E9

# logical to interpolat ozone field onto pressure levels
interp.field <- TRUE
#interp.field <- FALSE

if (interp.field==TRUE) {

# extract variables
lon <- ncvar_get(nc1, "longitude")
lat <- ncvar_get(nc1, "latitude")
lev <- ncvar_get(nc1, "level_ht")*1.0E-3
time <- ncvar_get(nc1, "time") 

# do pressure interpolation of ozone field onto fixed levels 
pres <- c(1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300,250,225,200,175,150,125,100,70,50,30,20,10)
# 4 press only
pres <- c(900,700,500,250)

var  <- o3.code

# interpolate the field
source("interpolate_3d_eval.R")

# set the plotting field to the interpolated field
o3 <- newvv*(conv/mm.o3)

# clean up arrays
rm(newvv); rm(var)
} else {
# import the saved pressure interpolated model o3 data
#nc0 <- nc_open(paste("/nerc/ukca/aarchi/", mod1.name, "/", mod1.name, "_pres_interp_ozone.nc",sep=""))
nc0 <- nc_open(mod_prs_file)

# extract variables
lon <- ncvar_get(nc0, "longitude")
lat <- ncvar_get(nc0, "latitude")
lev <- ncvar_get(nc0, "pressure")
o3 <- ncvar_get(nc0, o3.code)*(conv/mm.o3)

 }  # interp.field = T/F

# Set levels of model var that correspond to required pressure
#m250 = 21; m500 = 16; m700 = 12; m900 = 5
m250 = 4; m500 = 3; m700 = 2; m900 = 1

# find the index for the mid latitude in the array
midlon <- which(lon>=180.0)[1]
maxlon <- length(lon)
dellon <- lon[2]-lon[1]
dellat <- lat[2] - lat[1]
# reform array - centers the array on the meridian
o3  <- abind(o3[midlon:maxlon,,,], o3[1:midlon-1,,,], along=1)
lon <- seq(-180,180-dellon,dellon)

# set up labels for months
monthNames <- format(seq(as.POSIXct("2005-01-01"),by="1 months",length=12), "%b")

# extract the obs
sh.pol.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/sh_polar1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
sh.pol.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/sh_polar1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
sh.mid.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/sh_midlat1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
sh.mid.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/sh_midlat1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
tropics2.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/tropics21995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
tropics2.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/tropics21995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
tropics3.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/tropics31995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
tropics3.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/tropics31995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
eastus.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/eastern_us1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
eastus.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/eastern_us1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
japan.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/japan1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
japan.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/japan1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
westeu.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/west_europe1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
westeu.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/west_europe1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
canada.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/canada1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
canada.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/canada1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
nh.pol.e.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/nh_polar_east1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
nh.pol.e.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/nh_polar_east1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])
nh.pol.w.mean <- t(read.table(paste(obs_dir,"Tilmes_Ozone/nh_polar_west1995_2011.asc",sep="/"), skip=33, header=FALSE, nrows=26)[,2:13])
nh.pol.w.sd   <- t(read.table(paste(obs_dir,"Tilmes_Ozone/nh_polar_west1995_2011.asc",sep="/"), skip=114, header=FALSE, nrows=26)[,2:13])

# source the model locations
fields <- read.csv("tilmes_locations.R")

# convert "real" lats and longs to model grid boxes
fields$mLat1 <- (round (  ((fields$lat1 +90)/dellat)  ))+1
fields$mLat2 <- (round (  ((fields$lat2 +90)/dellat)  ))+1

fields$mLon1 <- ifelse ( fields$lon1<0, (round( ((fields$lon1+360)/dellon)-0.5))+1, (round( ((fields$lon1/dellon)-0.5) ))+1  )
fields$mLon2 <- ifelse ( fields$lon2<0, (round( ((fields$lon2+360)/dellon)-0.5))+1, (round( ((fields$lon2/dellon)-0.5) ))+1  )

# use split to convert the location data frame into a series of data frames split by the
# region
stations <- split(fields[], fields$region)

# extract the model fields
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

# calc stats
# correlation
cor.sh.pol.250 <- cor(sh.pol.mean[,11], sh.pol.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.500 <- cor(sh.pol.mean[,6], sh.pol.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.700 <- cor(sh.pol.mean[,4], sh.pol.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.sh.pol.900 <- cor(sh.pol.mean[,2], sh.pol.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.sh.mid.250 <- cor(sh.mid.mean[,11], sh.mid.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.500 <- cor(sh.mid.mean[,6], sh.mid.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.700 <- cor(sh.mid.mean[,4], sh.mid.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.sh.mid.900 <- cor(sh.mid.mean[,2], sh.mid.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.tropics2.250 <- cor(tropics2.mean[,11], tropics2.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.500 <- cor(tropics2.mean[,6], tropics2.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.700 <- cor(tropics2.mean[,4], tropics2.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.tropics2.900 <- cor(tropics2.mean[,2], tropics2.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.tropics3.250 <- cor(tropics3.mean[,11], tropics3.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.500 <- cor(tropics3.mean[,6], tropics3.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.700 <- cor(tropics3.mean[,4], tropics3.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.tropics3.900 <- cor(tropics3.mean[,2], tropics3.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.eastus.250 <- cor(eastus.mean[,11], eastus.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.eastus.500 <- cor(eastus.mean[,6], eastus.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.eastus.700 <- cor(eastus.mean[,4], eastus.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.eastus.900 <- cor(eastus.mean[,2], eastus.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.japan.250 <- cor(japan.mean[,11], japan.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.japan.500 <- cor(japan.mean[,6], japan.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.japan.700 <- cor(japan.mean[,4], japan.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.japan.900 <- cor(japan.mean[,2], japan.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.westeu.250 <- cor(westeu.mean[,11], westeu.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.westeu.500 <- cor(westeu.mean[,6], westeu.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.westeu.700 <- cor(westeu.mean[,4], westeu.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.westeu.900 <- cor(westeu.mean[,2], westeu.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.canada.250 <- cor(canada.mean[,11], canada.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.canada.500 <- cor(canada.mean[,6], canada.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.canada.700 <- cor(canada.mean[,4], canada.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.canada.900 <- cor(canada.mean[,2], canada.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.nh.pol.e.250 <- cor(nh.pol.e.mean[,11], nh.pol.e.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.500 <- cor(nh.pol.e.mean[,6], nh.pol.e.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.700 <- cor(nh.pol.e.mean[,4], nh.pol.e.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.e.900 <- cor(nh.pol.e.mean[,2], nh.pol.e.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

cor.nh.pol.w.250 <- cor(nh.pol.w.mean[,11], nh.pol.w.mod.mean[m250,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.500 <- cor(nh.pol.w.mean[,6], nh.pol.w.mod.mean[m500,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.700 <- cor(nh.pol.w.mean[,4], nh.pol.w.mod.mean[m700,],use="pairwise.complete.obs",method="pearson")
cor.nh.pol.w.900 <- cor(nh.pol.w.mean[,2], nh.pol.w.mod.mean[m900,],use="pairwise.complete.obs",method="pearson")

# mean bias error:
mbe.sh.pol.250 <- mean(sh.pol.mod.mean[m250,]-sh.pol.mean[,11])
mbe.sh.pol.500 <- mean(sh.pol.mod.mean[m500,]-sh.pol.mean[,6])
mbe.sh.pol.700 <- mean(sh.pol.mod.mean[m700,]-sh.pol.mean[,4])
mbe.sh.pol.900 <- mean(sh.pol.mod.mean[m900,]-sh.pol.mean[,2])

mbe.sh.mid.250 <- mean(sh.mid.mod.mean[m250,]-sh.mid.mean[,11])
mbe.sh.mid.500 <- mean(sh.mid.mod.mean[m500,]-sh.mid.mean[,6])
mbe.sh.mid.700 <- mean(sh.mid.mod.mean[m700,]-sh.mid.mean[,4])
mbe.sh.mid.900 <- mean(sh.mid.mod.mean[m900,]-sh.mid.mean[,2])

mbe.tropics2.250 <- mean(tropics2.mod.mean[m250,]-tropics2.mean[,11])
mbe.tropics2.500 <- mean(tropics2.mod.mean[m500,]-tropics2.mean[,6])
mbe.tropics2.700 <- mean(tropics2.mod.mean[m700,]-tropics2.mean[,4])
mbe.tropics2.900 <- mean(tropics2.mod.mean[m900,]-tropics2.mean[,2])

mbe.tropics3.250 <- mean(tropics3.mod.mean[m250,]-tropics3.mean[,11])
mbe.tropics3.500 <- mean(tropics3.mod.mean[m500,]-tropics3.mean[,6])
mbe.tropics3.700 <- mean(tropics3.mod.mean[m700,]-tropics3.mean[,4])
mbe.tropics3.900 <- mean(tropics3.mod.mean[m900,]-tropics3.mean[,2])

mbe.eastus.250 <- mean(eastus.mod.mean[m250,]-eastus.mean[,11])
mbe.eastus.500 <- mean(eastus.mod.mean[m500,]-eastus.mean[,6])
mbe.eastus.700 <- mean(eastus.mod.mean[m700,]-eastus.mean[,4])
mbe.eastus.900 <- mean(eastus.mod.mean[m900,]-eastus.mean[,2])

mbe.japan.250 <- mean(japan.mod.mean[m250,]-japan.mean[,11])
mbe.japan.500 <- mean(japan.mod.mean[m500,]-japan.mean[,6])
mbe.japan.700 <- mean(japan.mod.mean[m700,]-japan.mean[,4])
mbe.japan.900 <- mean(japan.mod.mean[m900,]-japan.mean[,2])

mbe.westeu.250 <- mean(westeu.mod.mean[m250,]-westeu.mean[,11])
mbe.westeu.500 <- mean(westeu.mod.mean[m500,]-westeu.mean[,6])
mbe.westeu.700 <- mean(westeu.mod.mean[m700,]-westeu.mean[,4])
mbe.westeu.900 <- mean(westeu.mod.mean[m900,]-westeu.mean[,2])

mbe.canada.250 <- mean(canada.mod.mean[m250,]-canada.mean[,11])
mbe.canada.500 <- mean(canada.mod.mean[m500,]-canada.mean[,6])
mbe.canada.700 <- mean(canada.mod.mean[m700,]-canada.mean[,4])
mbe.canada.900 <- mean(canada.mod.mean[m900,]-canada.mean[,2])

mbe.nh.pol.e.250 <- mean(nh.pol.e.mod.mean[m250,]-nh.pol.e.mean[,11])
mbe.nh.pol.e.500 <- mean(nh.pol.e.mod.mean[m500,]-nh.pol.e.mean[,6])
mbe.nh.pol.e.700 <- mean(nh.pol.e.mod.mean[m700,]-nh.pol.e.mean[,4])
mbe.nh.pol.e.900 <- mean(nh.pol.e.mod.mean[m900,]-nh.pol.e.mean[,2])

mbe.nh.pol.w.250 <- mean(nh.pol.w.mod.mean[m250,]-nh.pol.w.mean[,11])
mbe.nh.pol.w.500 <- mean(nh.pol.w.mod.mean[m500,]-nh.pol.w.mean[,6])
mbe.nh.pol.w.700 <- mean(nh.pol.w.mod.mean[m700,]-nh.pol.w.mean[,4])
mbe.nh.pol.w.900 <- mean(nh.pol.w.mod.mean[m900,]-nh.pol.w.mean[,2])
# ############################################################################################################################################
pdf(file=paste(out_dir,"/",mod1.name,"_Tilmes_ozone.pdf", sep=""),width=12,height=9,paper="special",onefile=TRUE,pointsize=13)

par (fig=c(0,1,0,1), # Figure region in the device display region (x1,x2,y1,y2)
       omi=c(0.3,0.8,0.8,0.05), # global margins in inches (bottom, left, top, right)
       mai=c(0.01,0.01,0.01,0.01), # subplot margins in inches (bottom, left, top, right)
       mgp=c(2, 0.5, 0) )
layout(matrix(1:40, 4, 10, byrow = TRUE))


# 250 hPa plots
plot(1:12, sh.pol.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.pol.mean[,11]+sh.pol.sd[,11], rev(sh.pol.mean[,11]-sh.pol.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.pol.mean[,11])
lines(1:12, sh.pol.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (sh.pol.mod.mean[m250,]-sh.pol.mod.sd[m250,]), 1:12, (sh.pol.mod.mean[m250,]+sh.pol.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.pol.250)," 
mbe =", sprintf("%1.3g", mbe.sh.pol.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "South \nPole") 
text(-4,300, "Ozone (ppbv)", srt=90)
par(xpd=F)

plot(1:12, sh.mid.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.mid.mean[,11]+sh.mid.sd[,11], rev(sh.mid.mean[,11]-sh.mid.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.mid.mean[,11])
lines(1:12, sh.mid.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (sh.mid.mod.mean[m250,]-sh.mid.mod.sd[m250,]), 1:12, (sh.mid.mod.mean[m250,]+sh.mid.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.mid.250)," 
mbe =", sprintf("%1.3g", mbe.sh.mid.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "Southern \nMidlat") 
par(xpd=F)


plot(1:12, tropics2.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics2.mean[,11]+tropics2.sd[,11], rev(tropics2.mean[,11]-tropics2.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics2.mean[,11])
lines(1:12, tropics2.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (tropics2.mod.mean[m250,]-tropics2.mod.sd[m250,]), 1:12, (tropics2.mod.mean[m250,]+tropics2.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics2.250)," 
mbe =", sprintf("%1.3g", mbe.tropics2.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "Tropics2") 
par(xpd=F)


plot(1:12, tropics3.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics3.mean[,11]+tropics3.sd[,11], rev(tropics3.mean[,11]-tropics3.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics3.mean[,11])
lines(1:12, tropics3.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (tropics3.mod.mean[m250,]-tropics3.mod.sd[m250,]), 1:12, (tropics3.mod.mean[m250,]+tropics3.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics3.250)," 
mbe =", sprintf("%1.3g", mbe.tropics3.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "Tropics3") 
par(xpd=F)


plot(1:12, eastus.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(eastus.mean[,11]+eastus.sd[,11], rev(eastus.mean[,11]-eastus.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(eastus.mean[,11])
lines(1:12, eastus.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (eastus.mod.mean[m250,]-eastus.mod.sd[m250,]), 1:12, (eastus.mod.mean[m250,]+eastus.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.eastus.250)," 
mbe =", sprintf("%1.3g", mbe.eastus.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "East US") 
text(12,780, paste(mod1.name, "Tilmes ozone sonde comparison", sep=" "), font=2 ) 
par(xpd=F)


plot(1:12, japan.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(japan.mean[,11]+japan.sd[,11], rev(japan.mean[,11]-japan.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(japan.mean[,11])
lines(1:12, japan.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (japan.mod.mean[m250,]-japan.mod.sd[m250,]), 1:12, (japan.mod.mean[m250,]+japan.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.japan.250)," 
mbe =", sprintf("%1.3g", mbe.japan.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "Japan") 
par(xpd=F)


plot(1:12, westeu.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(westeu.mean[,11]+westeu.sd[,11], rev(westeu.mean[,11]-westeu.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(westeu.mean[,11])
lines(1:12, westeu.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (westeu.mod.mean[m250,]-westeu.mod.sd[m250,]), 1:12, (westeu.mod.mean[m250,]+westeu.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.westeu.250)," 
mbe =", sprintf("%1.3g", mbe.westeu.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "West EU") 
par(xpd=F)


plot(1:12, canada.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(canada.mean[,11]+canada.sd[,11], rev(canada.mean[,11]-canada.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(canada.mean[,11])
lines(1:12, canada.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (canada.mod.mean[m250,]-canada.mod.sd[m250,]), 1:12, (canada.mod.mean[m250,]+canada.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.canada.250)," 
mbe =", sprintf("%1.3g", mbe.canada.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "Canada") 
par(xpd=F)


plot(1:12, nh.pol.e.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.e.mean[,11]+nh.pol.e.sd[,11], rev(nh.pol.e.mean[,11]-nh.pol.e.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.e.mean[,11])
lines(1:12, nh.pol.e.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (nh.pol.e.mod.mean[m250,]-nh.pol.e.mod.sd[m250,]), 1:12, (nh.pol.e.mod.mean[m250,]+nh.pol.e.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.e.250)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.e.250), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(6,680, "North Pole East") 
par(xpd=F)


plot(1:12, nh.pol.w.mean[,11], type="l", lwd=3, ylim=c(0,600), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.w.mean[,11]+nh.pol.w.sd[,11], rev(nh.pol.w.mean[,11]-nh.pol.w.sd[,11])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.w.mean[,11])
lines(1:12, nh.pol.w.mod.mean[m250,], lwd=3, col="red")
arrows( 1:12, (nh.pol.w.mod.mean[m250,]-nh.pol.w.mod.sd[m250,]), 1:12, (nh.pol.w.mod.mean[m250,]+nh.pol.w.mod.sd[m250,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.w.250)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.w.250), " ppbv", sep="")), cex=0.9, bty="n")
legend("bottomleft", "250 hPa",bty="n")
par(xpd=NA)
text(6,680, "North Pole West") 
par(xpd=F)


# ################################################### 500 hPa plots ################################################################################
plot(1:12, sh.pol.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.pol.mean[,6]+sh.pol.sd[,6], rev(sh.pol.mean[,6]-sh.pol.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.pol.mean[,6])
lines(1:12, sh.pol.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (sh.pol.mod.mean[m500,]-sh.pol.mod.sd[m500,]), 1:12, (sh.pol.mod.mean[m500,]+sh.pol.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.pol.500)," 
mbe =", sprintf("%1.3g", mbe.sh.pol.500), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(-4,60, "Ozone (ppbv)", srt=90)
par(xpd=F)

plot(1:12, sh.mid.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.mid.mean[,6]+sh.mid.sd[,6], rev(sh.mid.mean[,6]-sh.mid.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.mid.mean[,6])
lines(1:12, sh.mid.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (sh.mid.mod.mean[m500,]-sh.mid.mod.sd[m500,]), 1:12, (sh.mid.mod.mean[m500,]+sh.mid.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.mid.500)," 
mbe =", sprintf("%1.3g", mbe.sh.mid.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, tropics2.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics2.mean[,6]+tropics2.sd[,6], rev(tropics2.mean[,6]-tropics2.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics2.mean[,6])
lines(1:12, tropics2.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (tropics2.mod.mean[m500,]-tropics2.mod.sd[m500,]), 1:12, (tropics2.mod.mean[m500,]+tropics2.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics2.500)," 
mbe =", sprintf("%1.3g", mbe.tropics2.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, tropics3.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics3.mean[,6]+tropics3.sd[,6], rev(tropics3.mean[,6]-tropics3.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics3.mean[,6])
lines(1:12, tropics3.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (tropics3.mod.mean[m500,]-tropics3.mod.sd[m500,]), 1:12, (tropics3.mod.mean[m500,]+tropics3.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics3.500)," 
mbe =", sprintf("%1.3g", mbe.tropics3.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, eastus.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(eastus.mean[,6]+eastus.sd[,6], rev(eastus.mean[,6]-eastus.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(eastus.mean[,6])
lines(1:12, eastus.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (eastus.mod.mean[m500,]-eastus.mod.sd[m500,]), 1:12, (eastus.mod.mean[m500,]+eastus.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.eastus.500)," 
mbe =", sprintf("%1.3g", mbe.eastus.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, japan.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(japan.mean[,6]+japan.sd[,6], rev(japan.mean[,6]-japan.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(japan.mean[,6])
lines(1:12, japan.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (japan.mod.mean[m500,]-japan.mod.sd[m500,]), 1:12, (japan.mod.mean[m500,]+japan.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.japan.500)," 
mbe =", sprintf("%1.3g", mbe.japan.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, westeu.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(westeu.mean[,6]+westeu.sd[,6], rev(westeu.mean[,6]-westeu.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(westeu.mean[,6])
lines(1:12, westeu.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (westeu.mod.mean[m500,]-westeu.mod.sd[m500,]), 1:12, (westeu.mod.mean[m500,]+westeu.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.westeu.500)," 
mbe =", sprintf("%1.3g", mbe.westeu.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, canada.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(canada.mean[,6]+canada.sd[,6], rev(canada.mean[,6]-canada.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(canada.mean[,6])
lines(1:12, canada.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (canada.mod.mean[m500,]-canada.mod.sd[m500,]), 1:12, (canada.mod.mean[m500,]+canada.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.canada.500)," 
mbe =", sprintf("%1.3g", mbe.canada.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, nh.pol.e.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.e.mean[,6]+nh.pol.e.sd[,6], rev(nh.pol.e.mean[,6]-nh.pol.e.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.e.mean[,6])
lines(1:12, nh.pol.e.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (nh.pol.e.mod.mean[m500,]-nh.pol.e.mod.sd[m500,]), 1:12, (nh.pol.e.mod.mean[m500,]+nh.pol.e.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.e.500)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.e.500), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, nh.pol.w.mean[,6], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.w.mean[,6]+nh.pol.w.sd[,6], rev(nh.pol.w.mean[,6]-nh.pol.w.sd[,6])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.w.mean[,6])
lines(1:12, nh.pol.w.mod.mean[m500,], lwd=3, col="red")
arrows( 1:12, (nh.pol.w.mod.mean[m500,]-nh.pol.w.mod.sd[m500,]), 1:12, (nh.pol.w.mod.mean[m500,]+nh.pol.w.mod.sd[m500,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.w.500)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.w.500), " ppbv", sep="")), cex=0.9, bty="n")
legend("bottomleft", "500 hPa",bty="n")

# ################################################### 700 hPa plots ################################################################################
plot(1:12, sh.pol.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.pol.mean[,4]+sh.pol.sd[,4], rev(sh.pol.mean[,4]-sh.pol.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.pol.mean[,4])
lines(1:12, sh.pol.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (sh.pol.mod.mean[m700,]-sh.pol.mod.sd[m700,]), 1:12, (sh.pol.mod.mean[m700,]+sh.pol.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.pol.700)," 
mbe =", sprintf("%1.3g", mbe.sh.pol.700), " ppbv", sep="")), cex=0.9, bty="n")
par(xpd=NA)
text(-4,60, "Ozone (ppbv)", srt=90)
par(xpd=F)

plot(1:12, sh.mid.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.mid.mean[,4]+sh.mid.sd[,4], rev(sh.mid.mean[,4]-sh.mid.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.mid.mean[,4])
lines(1:12, sh.mid.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (sh.mid.mod.mean[m700,]-sh.mid.mod.sd[m700,]), 1:12, (sh.mid.mod.mean[m700,]+sh.mid.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.mid.700)," 
mbe =", sprintf("%1.3g", mbe.sh.mid.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, tropics2.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics2.mean[,4]+tropics2.sd[,4], rev(tropics2.mean[,4]-tropics2.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics2.mean[,4])
lines(1:12, tropics2.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (tropics2.mod.mean[m700,]-tropics2.mod.sd[m700,]), 1:12, (tropics2.mod.mean[m700,]+tropics2.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics2.700)," 
mbe =", sprintf("%1.3g", mbe.tropics2.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, tropics3.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics3.mean[,4]+tropics3.sd[,4], rev(tropics3.mean[,4]-tropics3.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics3.mean[,4])
lines(1:12, tropics3.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (tropics3.mod.mean[m700,]-tropics3.mod.sd[m700,]), 1:12, (tropics3.mod.mean[m700,]+tropics3.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics3.700)," 
mbe =", sprintf("%1.3g", mbe.tropics3.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, eastus.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(eastus.mean[,4]+eastus.sd[,4], rev(eastus.mean[,4]-eastus.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(eastus.mean[,4])
lines(1:12, eastus.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (eastus.mod.mean[m700,]-eastus.mod.sd[m700,]), 1:12, (eastus.mod.mean[m700,]+eastus.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.eastus.700)," 
mbe =", sprintf("%1.3g", mbe.eastus.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, japan.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(japan.mean[,4]+japan.sd[,4], rev(japan.mean[,4]-japan.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(japan.mean[,4])
lines(1:12, japan.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (japan.mod.mean[m700,]-japan.mod.sd[m700,]), 1:12, (japan.mod.mean[m700,]+japan.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.japan.700)," 
mbe =", sprintf("%1.3g", mbe.japan.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, westeu.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(westeu.mean[,4]+westeu.sd[,4], rev(westeu.mean[,4]-westeu.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(westeu.mean[,4])
lines(1:12, westeu.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (westeu.mod.mean[m700,]-westeu.mod.sd[m700,]), 1:12, (westeu.mod.mean[m700,]+westeu.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.westeu.700)," 
mbe =", sprintf("%1.3g", mbe.westeu.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, canada.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(canada.mean[,4]+canada.sd[,4], rev(canada.mean[,4]-canada.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(canada.mean[,4])
lines(1:12, canada.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (canada.mod.mean[m700,]-canada.mod.sd[m700,]), 1:12, (canada.mod.mean[m700,]+canada.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.canada.700)," 
mbe =", sprintf("%1.3g", mbe.canada.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, nh.pol.e.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.e.mean[,4]+nh.pol.e.sd[,4], rev(nh.pol.e.mean[,4]-nh.pol.e.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.e.mean[,4])
lines(1:12, nh.pol.e.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (nh.pol.e.mod.mean[m700,]-nh.pol.e.mod.sd[m700,]), 1:12, (nh.pol.e.mod.mean[m700,]+nh.pol.e.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.e.700)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.e.700), " ppbv", sep="")), cex=0.9, bty="n")

plot(1:12, nh.pol.w.mean[,4], type="l", lwd=3, ylim=c(0,120), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.w.mean[,4]+nh.pol.w.sd[,4], rev(nh.pol.w.mean[,4]-nh.pol.w.sd[,4])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.w.mean[,4])
lines(1:12, nh.pol.w.mod.mean[m700,], lwd=3, col="red")
arrows( 1:12, (nh.pol.w.mod.mean[m700,]-nh.pol.w.mod.sd[m700,]), 1:12, (nh.pol.w.mod.mean[m700,]+nh.pol.w.mod.sd[m700,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.w.700)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.w.700), " ppbv", sep="")), cex=0.9, bty="n")
legend("bottomleft", "700 hPa",bty="n")

# ################################################### 900 hPa plots ################################################################################
plot(1:12, sh.pol.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.pol.mean[,2]+sh.pol.sd[,2], rev(sh.pol.mean[,2]-sh.pol.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.pol.mean[,2])
lines(1:12, sh.pol.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (sh.pol.mod.mean[m900,]-sh.pol.mod.sd[m900,]), 1:12, (sh.pol.mod.mean[m900,]+sh.pol.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.pol.900)," 
mbe =", sprintf("%1.3g", mbe.sh.pol.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)
par(xpd=NA)
text(-4,40, "Ozone (ppbv)", srt=90)
par(xpd=F)

plot(1:12, sh.mid.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(sh.mid.mean[,2]+sh.mid.sd[,2], rev(sh.mid.mean[,2]-sh.mid.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(sh.mid.mean[,2])
lines(1:12, sh.mid.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (sh.mid.mod.mean[m900,]-sh.mid.mod.sd[m900,]), 1:12, (sh.mid.mod.mean[m900,]+sh.mid.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.sh.mid.900)," 
mbe =", sprintf("%1.3g", mbe.sh.mid.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, tropics2.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics2.mean[,2]+tropics2.sd[,2], rev(tropics2.mean[,2]-tropics2.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics2.mean[,2])
lines(1:12, tropics2.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (tropics2.mod.mean[m900,]-tropics2.mod.sd[m900,]), 1:12, (tropics2.mod.mean[m900,]+tropics2.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics2.900)," 
mbe =", sprintf("%1.3g", mbe.tropics2.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, tropics3.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(tropics3.mean[,2]+tropics3.sd[,2], rev(tropics3.mean[,2]-tropics3.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(tropics3.mean[,2])
lines(1:12, tropics3.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (tropics3.mod.mean[m900,]-tropics3.mod.sd[m900,]), 1:12, (tropics3.mod.mean[m900,]+tropics3.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.tropics3.900)," 
mbe =", sprintf("%1.3g", mbe.tropics3.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, eastus.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(eastus.mean[,2]+eastus.sd[,2], rev(eastus.mean[,2]-eastus.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(eastus.mean[,2])
lines(1:12, eastus.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (eastus.mod.mean[m900,]-eastus.mod.sd[m900,]), 1:12, (eastus.mod.mean[m900,]+eastus.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.eastus.900)," 
mbe =", sprintf("%1.3g", mbe.eastus.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, japan.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(japan.mean[,2]+japan.sd[,2], rev(japan.mean[,2]-japan.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(japan.mean[,2])
lines(1:12, japan.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (japan.mod.mean[m900,]-japan.mod.sd[m900,]), 1:12, (japan.mod.mean[m900,]+japan.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.japan.900)," 
mbe =", sprintf("%1.3g", mbe.japan.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, westeu.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(westeu.mean[,2]+westeu.sd[,2], rev(westeu.mean[,2]-westeu.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(westeu.mean[,2])
lines(1:12, westeu.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (westeu.mod.mean[m900,]-westeu.mod.sd[m900,]), 1:12, (westeu.mod.mean[m900,]+westeu.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.westeu.900)," 
mbe =", sprintf("%1.3g", mbe.westeu.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, canada.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(canada.mean[,2]+canada.sd[,2], rev(canada.mean[,2]-canada.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(canada.mean[,2])
lines(1:12, canada.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (canada.mod.mean[m900,]-canada.mod.sd[m900,]), 1:12, (canada.mod.mean[m900,]+canada.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.canada.900)," 
mbe =", sprintf("%1.3g", mbe.canada.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, nh.pol.e.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.e.mean[,2]+nh.pol.e.sd[,2], rev(nh.pol.e.mean[,2]-nh.pol.e.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.e.mean[,2])
lines(1:12, nh.pol.e.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (nh.pol.e.mod.mean[m900,]-nh.pol.e.mod.sd[m900,]), 1:12, (nh.pol.e.mod.mean[m900,]+nh.pol.e.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.e.900)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.e.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)

plot(1:12, nh.pol.w.mean[,2], type="l", lwd=3, ylim=c(0,80), ylab="", xlab="", yaxt="n", xaxt="n" )
grid()
polygon( c(1:12, rev(1:12)), c(nh.pol.w.mean[,2]+nh.pol.w.sd[,2], rev(nh.pol.w.mean[,2]-nh.pol.w.sd[,2])), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(nh.pol.w.mean[,2])
lines(1:12, nh.pol.w.mod.mean[m900,], lwd=3, col="red")
arrows( 1:12, (nh.pol.w.mod.mean[m900,]-nh.pol.w.mod.sd[m900,]), 1:12, (nh.pol.w.mod.mean[m900,]+nh.pol.w.mod.sd[m900,]), length = 0.0, code =2, col="red" )
legend("topleft", c(paste("r = ",sprintf("%1.3g", cor.nh.pol.w.900)," 
mbe =", sprintf("%1.3g", mbe.nh.pol.w.900), " ppbv", sep="")), cex=0.9, bty="n")
axis(side=1, 1:12,   labels=monthNames, tick=TRUE, las=1)
legend("bottomleft", "900 hPa",bty="n")

dev.off()
