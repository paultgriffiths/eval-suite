# R script to plot model profiles vs observations
# Alex Archibald, February,  2012

# Subset the model and obs into three domains:
# -80:-30, -30:30, 30:80
# Mean over time and longitude (the obs are generally
# zonal means)

# function to find the index in the input file 
# for the latitude bands
find.lat <- function(lat, x) {
which(lat>=x)[1]	
}

# Extract model variables and define constants, 
# loop vars
lat  <- ncvar_get(nc1, "latitude")
lon  <- ncvar_get(nc1, "longitude")
hgt  <- ncvar_get(nc1, "level_ht")*1.0E-3
time <- ncvar_get(nc1, "time")
ppm  <- 1.0E6
ppb  <- 1.0E9
ppt  <- 1.0E12

#if ( (mod1.type=="CheS") | (mod1.type=="CheST") ) {
#top.height <- which(hgt>=60.)[1] }

#if ( (mod1.type=="CheT") ) {
#top.height <- which(hgt>=60.)[1] }
top.height <- which(hgt>=60.)[1]


# define the latitudes to extract data over:
#sh.min   <- -90; sh.max   <- -60
# for ENDGame grids: latitude points not at -90,+90
nlat  = length(ncvar_get(nc1, "latitude"))
sh.min   <- lat[1]; sh.max   <- -60
mh.min   <- -60; mh.max   <- -30
trop.min <- -30; trop.max <- 30
nh.min   <-  30; nh.max   <- 60
uh.min   <-  60; uh.max   <- lat[nlat]
# ###################################################################################################################################
# S. Hemisphere subsets: Pass into generic script
first.lat <- sh.min
last.lat  <- sh.max
location  <- "sh"
source("get_model_profiles.R")
source("get_ace_profiles.R")
source("get_uars_profiles.R")
source("get_mipas_profiles.R")
source("get_tes_profiles.R")
source("get_mls_profiles.R")

# N. Hemisphere subsets: Pass into generic script
first.lat <- nh.min
last.lat  <- nh.max
location  <- "nh"
source("get_model_profiles.R")
source("get_ace_profiles.R")
source("get_uars_profiles.R")
source("get_mipas_profiles.R")
source("get_tes_profiles.R")
source("get_mls_profiles.R")

# Tropical subsets: Pass into generic script
first.lat <- trop.min
last.lat  <- trop.max
location  <- "trop"
source("get_model_profiles.R")
source("get_ace_profiles.R")
source("get_uars_profiles.R")
source("get_mipas_profiles.R")
source("get_tes_profiles.R")
source("get_mls_profiles.R")

# S. Hemisphere mid latitude subsets: Pass into generic script
first.lat <- mh.min
last.lat  <- mh.max
location  <- "mh"
source("get_model_profiles.R")
source("get_ace_profiles.R")
source("get_uars_profiles.R")
source("get_mipas_profiles.R")
source("get_tes_profiles.R")
source("get_mls_profiles.R")

# N. Hemisphere mid latitude subsets: Pass into generic script
first.lat <- uh.min
last.lat  <- uh.max
location  <- "uh"

source("get_model_profiles.R")
source("get_ace_profiles.R")
#source("get_uars_profiles.R")
#source("get_mipas_profiles.R")
source("get_tes_profiles.R")
#source("get_mls_profiles.R")
# ###################################################################################################################################
pdf(paste(out_dir,"/",mod1.name,"_profiles.pdf", sep=""),width=21,height=14,paper="special",onefile=TRUE,pointsize=22)

  par (fig=c(0,1,0,1), # Figure region in the device display region (x1,x2,y1,y2)
       omi=c(0,0,0.3,0), # global margins in inches (bottom, left, top, right)
       mai=c(1.0,1.0,0.35,0.1)) # subplot margins in inches (bottom, left, top, right)
  layout(matrix(1:10, 2, 5, byrow = TRUE))

# ~~~~~~~~~~~~~~~~ O3 ~~~~~~~~~~~~~~~
plot(sh.mod.o3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="Ozone (ppm)", xlim=c(0,12), main="90S - 60S")
# Add the obs data
lines(sh.ace.o3.z*ppm, ace.hgt, lwd=2, col="blue")
lines(sh.uars.o3.z, uars.hgt, lwd=2, col="black")
lines(sh.mls.o3.z*ppm, mls.hgt, lwd=2, col="orange")
#lines(sh.mipas.o3.z, mipas.hgt, lwd=2, col="green")
lines(sh.tes.o3.z*ppm, tes.hgt, lwd=2, col="pink")
grid()
legend("bottomright", c(mod1.name, "ACE", "UARS", "MLS", "MIPAS", "TES"), lwd=1, col=c("red","blue","black","orange","green","pink"), bty="n" )

rm(sh.mod.o3.z);rm(sh.ace.o3.z);rm(sh.uars.o3.z);rm(sh.mls.o3.z)
rm(sh.mipas.o3.z); rm(sh.tes.o3.z)

plot(mh.mod.o3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="Ozone (ppm)", xlim=c(0,12), main="60S - 30S")
# Add the obs data
lines(mh.ace.o3.z*ppm, ace.hgt, lwd=2, col="blue")
lines(mh.uars.o3.z, uars.hgt, lwd=2, col="black")
lines(mh.mls.o3.z*ppm, mls.hgt, lwd=2, col="orange")
lines(mh.mipas.o3.z, mipas.hgt, lwd=2, col="green")
lines(mh.tes.o3.z*ppm, tes.hgt, lwd=2, col="pink")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS", "MLS", "MIPAS", "TES"), lwd=1, col=c("red","blue","black","orange","green","pink"), bty="n" )

rm(mh.mod.o3.z);rm(mh.ace.o3.z);rm(mh.uars.o3.z);rm(mh.mls.o3.z)
rm(mh.mipas.o3.z); rm(mh.tes.o3.z)

plot(trop.mod.o3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="Ozone (ppm)", xlim=c(0,12), main="30S - 30N")
# Add the obs data
lines(trop.ace.o3.z*ppm, ace.hgt, lwd=2, col="blue")
lines(trop.uars.o3.z, uars.hgt, lwd=2, col="black")
lines(trop.mls.o3.z*ppm, mls.hgt, lwd=2, col="orange")
lines(trop.mipas.o3.z, mipas.hgt, lwd=2, col="green")
lines(trop.ace.o3.z*ppm, ace.hgt, lwd=2, col="pink")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS", "MLS", "MIPAS", "TES"), lwd=1, col=c("red","blue","black","orange","green","pink"), bty="n" )

rm(trop.mod.o3.z);rm(trop.ace.o3.z);rm(trop.uars.o3.z);rm(trop.mls.o3.z)
rm(trop.mipas.o3.z); rm(trop.tes.o3.z)

plot(uh.mod.o3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="Ozone (ppm)", xlim=c(0,12), main="30N - 60N")
# Add the obs data
lines(uh.ace.o3.z*ppm, ace.hgt, lwd=2, col="blue")
#lines(uh.uars.o3.z, uars.hgt, lwd=2, col="black")
#lines(uh.mls.o3.z*ppm, mls.hgt, lwd=2, col="orange")
#lines(uh.mipas.o3.z, mipas.hgt, lwd=2, col="green")
#lines(uh.tes.o3.z*ppm, tes.hgt, lwd=2, col="pink")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS", "MLS", "MIPAS", "TES"), lwd=1, col=c("red","blue","black","orange","green","pink"), bty="n" )

rm(uh.mod.o3.z);rm(uh.ace.o3.z);rm(uh.uars.o3.z);rm(uh.mls.o3.z)
rm(uh.mipas.o3.z); rm(uh.tes.o3.z)

plot(nh.mod.o3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="Ozone (ppm)", xlim=c(0,12), main="60N - 90N")
# Add the obs data
lines(nh.ace.o3.z*ppm, ace.hgt, lwd=2, col="blue")
lines(nh.uars.o3.z, uars.hgt, lwd=2, col="black")
lines(nh.mls.o3.z*ppm, mls.hgt, lwd=2, col="orange")
#lines(nh.mipas.o3.z, mipas.hgt, lwd=2, col="green")
lines(nh.tes.o3.z*ppm, tes.hgt, lwd=2, col="pink")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS", "MLS", "MIPAS", "TES"), lwd=1, col=c("red","blue","black","orange","green","pink"), bty="n" )

rm(nh.mod.o3.z);rm(nh.ace.o3.z);rm(nh.uars.o3.z);rm(nh.mls.o3.z)
rm(nh.mipas.o3.z); rm(nh.tes.o3.z)
gc()

# ~~~~~~~~~~~~~~~~ HONO2 ~~~~~~~~~~~~~~~
plot(sh.mod.hno3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="HONO2 (ppb)", xlim=c(0,12), main="90S - 60S")
# Add the obs data
lines(sh.ace.hno3.z*ppb, ace.hgt, lwd=2, col="blue")
lines(sh.uars.hno3.z, uars.hgt, lwd=2, col="black")
grid()
legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(sh.mod.hno3.z);rm(sh.ace.hno3.z);rm(sh.uars.hno3.z)

plot(mh.mod.hno3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="HONO2 (ppb)", xlim=c(0,12), main="60S - 30S")
# Add the obs data
lines(mh.ace.hno3.z*ppb, ace.hgt, lwd=2, col="blue")
lines(mh.uars.hno3.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(mh.mod.hno3.z);rm(mh.ace.hno3.z);rm(mh.uars.hno3.z)

plot(trop.mod.hno3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="HONO2 (ppb)", xlim=c(0,12), main="30S - 30N")
# Add the obs data
lines(trop.ace.hno3.z*ppb, ace.hgt, lwd=2, col="blue")
lines(trop.uars.hno3.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(trop.mod.hno3.z);rm(trop.ace.hno3.z);rm(trop.uars.hno3.z)

plot(uh.mod.hno3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="HONO2 (ppb)", xlim=c(0,12), main="30N - 60N")
# Add the obs data
lines(uh.ace.hno3.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(uh.uars.hno3.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(uh.mod.hno3.z);rm(uh.ace.hno3.z);rm(uh.uars.hno3.z)

plot(nh.mod.hno3.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="HONO2 (ppb)", xlim=c(0,12), main="60N - 90N")
# Add the obs data
lines(nh.ace.hno3.z*ppb, ace.hgt, lwd=2, col="blue")
lines(nh.uars.hno3.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(nh.mod.hno3.z);rm(nh.ace.hno3.z);rm(nh.uars.hno3.z)
gc()

# ~~~~~~~~~~ NO2 ~~~~~~~~~~~~~~~~~~~~~~~~~~
plot(sh.mod.no2.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="NO2 (ppb)", xlim=c(0,10), main="90S - 60S")
# Add the obs data
lines(sh.ace.no2.z*ppb, ace.hgt, lwd=2, col="blue")
lines(sh.uars.no2.z, uars.hgt, lwd=2, col="black")
grid()
legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(sh.mod.no2.z);rm(sh.ace.no2.z);rm(sh.uars.no2.z)

plot(mh.mod.no2.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="NO2 (ppb)", xlim=c(0,10), main="60S - 30S")
# Add the obs data
lines(mh.ace.no2.z*ppb, ace.hgt, lwd=2, col="blue")
lines(mh.uars.no2.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(mh.mod.no2.z);rm(mh.ace.no2.z);rm(mh.uars.no2.z)

plot(trop.mod.no2.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="NO2 (ppb)", xlim=c(0,10), main="30S - 30N")
# Add the obs data
lines(trop.ace.no2.z*ppb, ace.hgt, lwd=2, col="blue")
lines(trop.uars.no2.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(trop.mod.no2.z);rm(trop.ace.no2.z);rm(trop.uars.no2.z)

plot(uh.mod.no2.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="NO2 (ppb)", xlim=c(0,10), main="30N - 60N")
# Add the obs data
lines(uh.ace.no2.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(uh.uars.no2.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(uh.mod.no2.z);rm(uh.ace.no2.z);rm(uh.uars.no2.z)

plot(nh.mod.no2.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="NO2 (ppb)", xlim=c(0,10), main="60N - 90N")
# Add the obs data
lines(nh.ace.no2.z*ppb, ace.hgt, lwd=2, col="blue")
lines(nh.uars.no2.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(nh.mod.no2.z);rm(nh.ace.no2.z);rm(nh.uars.no2.z)
gc()

# ~~~~~~~~ Parameters only from StratChem runs ~~~~~~~~
#
if ( (mod1.type=="CheS") | (mod1.type=="CheST") ) {
# ~~~~~~~~~~ H2O ~~~~~~~~~~~~~~~~~~~~~~~~~~
plot(sh.mod.h2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="H2O (ppm)", xlim=c(0,300), main="90S - 60S")
# Add the obs data
lines(sh.ace.h2o.z*ppm, ace.hgt, lwd=2, col="blue")
lines(sh.uars.h2o.z, uars.hgt, lwd=2, col="black")
grid()
legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(sh.mod.h2o.z);rm(sh.ace.h2o.z);rm(sh.uars.h2o.z)

plot(mh.mod.h2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="H2O (ppm)", xlim=c(0,300), main="60S - 30S")
# Add the obs data
lines(mh.ace.h2o.z*ppm, ace.hgt, lwd=2, col="blue")
lines(mh.uars.h2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(mh.mod.h2o.z);rm(mh.ace.h2o.z);rm(mh.uars.h2o.z)

plot(trop.mod.h2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="H2O (ppm)", xlim=c(0,300), main="30S - 30N")
# Add the obs data
lines(trop.ace.h2o.z*ppm, ace.hgt, lwd=2, col="blue")
lines(trop.uars.h2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(trop.mod.h2o.z);rm(trop.ace.h2o.z);rm(trop.uars.h2o.z)

plot(uh.mod.h2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="H2O (ppm)", xlim=c(0,300), main="30N - 60N")
# Add the obs data
lines(uh.ace.h2o.z*ppm, ace.hgt, lwd=2, col="blue")
#lines(uh.uars.h2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(uh.mod.h2o.z);rm(uh.ace.h2o.z);rm(uh.uars.h2o.z)

plot(nh.mod.h2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="H2O (ppm)", xlim=c(0,300), main="60N - 90N")
# Add the obs data
lines(nh.ace.h2o.z*ppm, ace.hgt, lwd=2, col="blue")
lines(nh.uars.h2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(nh.mod.h2o.z);rm(nh.ace.h2o.z);rm(nh.uars.h2o.z)
gc()

# ~~~~~~~~~~~~ Hcl ~~~~~~~~~~~~~~~~~~~~~~~~
#plot(sh.mod.hcl.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
#ylab="Altitude /km", xlab="HCl (ppb)", xlim=c(0,10), main="90S - 60S")
## Add the obs data
#lines(sh.ace.hcl.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(sh.uars.hcl.z, uars.hgt, lwd=2, col="black")
#grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

#plot(mh.mod.hcl.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
#ylab="Altitude /km", xlab="HCl (ppb)", xlim=c(0,10), main="60S - 30S")
## Add the obs data
#lines(mh.ace.hcl.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(mh.uars.hcl.z, uars.hgt, lwd=2, col="black")
#grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )
#
#plot(trop.mod.hcl.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
#ylab="Altitude /km", xlab="HCl (ppb)", xlim=c(0,10), main="30S - 30N")
## Add the obs data
#lines(trop.ace.hcl.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(trop.uars.hcl.z, uars.hgt, lwd=2, col="black")
#grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )
#
#plot(uh.mod.hcl.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
#ylab="Altitude /km", xlab="HCl (ppb)", xlim=c(0,10), main="30N - 60N")
## Add the obs data
#lines(uh.ace.hcl.z*ppb, ace.hgt, lwd=2, col="blue")
##lines(uh.uars.hcl.z, uars.hgt, lwd=2, col="black")
#grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )
#
#plot(nh.mod.hcl.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
#ylab="Altitude /km", xlab="HCl (ppb)", xlim=c(0,10), main="60N - 90N")
## Add the obs data
#lines(nh.ace.hcl.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(nh.uars.hcl.z, uars.hgt, lwd=2, col="black")
#grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

# ~~~~~~~~~~ N2O ~~~~~~~~~~~~~~~~~~~~~~~~~~
plot(sh.mod.n2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="N2O (ppb)", xlim=c(0,400), main="90S - 60S")
# Add the obs data
lines(sh.ace.n2o.z*ppb, ace.hgt, lwd=2, col="blue")
lines(sh.uars.n2o.z, uars.hgt, lwd=2, col="black")
grid()
legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(sh.mod.n2o.z);rm(sh.ace.n2o.z);rm(sh.uars.n2o.z)

plot(mh.mod.n2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="N2O (ppb)", xlim=c(0,400), main="60S - 30S")
# Add the obs data
lines(mh.ace.n2o.z*ppb, ace.hgt, lwd=2, col="blue")
lines(mh.uars.n2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(mh.mod.n2o.z);rm(mh.ace.n2o.z);rm(mh.uars.n2o.z)

plot(trop.mod.n2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="N2O (ppb)", xlim=c(0,400), main="30S - 30N")
# Add the obs data
lines(trop.ace.n2o.z*ppb, ace.hgt, lwd=2, col="blue")
lines(trop.uars.n2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(trop.mod.n2o.z);rm(trop.ace.n2o.z);rm(trop.uars.n2o.z)

plot(uh.mod.n2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="N2O (ppb)", xlim=c(0,400), main="30N - 60N")
# Add the obs data
lines(uh.ace.n2o.z*ppb, ace.hgt, lwd=2, col="blue")
#lines(uh.uars.n2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(uh.mod.n2o.z);rm(uh.ace.n2o.z);rm(uh.uars.n2o.z)

plot(nh.mod.n2o.z[1:top.height], hgt[1:top.height], type = "l", col="red", lwd=2,
ylab="Altitude /km", xlab="N2O (ppb)", xlim=c(0,400), main="60N - 90N")
# Add the obs data
lines(nh.ace.n2o.z*ppb, ace.hgt, lwd=2, col="blue")
lines(nh.uars.n2o.z, uars.hgt, lwd=2, col="black")
grid()
#legend("bottomright", c(mod1.name, "ACE", "UARS"), lwd=1, col=c("red","blue","black"), bty="n" )

rm(nh.mod.n2o.z);rm(nh.ace.n2o.z);rm(nh.uars.n2o.z)
gc()
}  # if CheS or CheST

dev.off()

