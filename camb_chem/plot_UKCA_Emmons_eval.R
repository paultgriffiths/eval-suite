# R analysis script used to compare UKCA model 
# data to observations.

# Alex Archibald, CAS, Jan 2012

# exract the physical dimensions from the two files 
lon  <- ncvar_get(nc1, "longitude")
lat  <- ncvar_get(nc1, "latitude")
hgt  <- ncvar_get(nc1, "level_ht")
time <- ncvar_get(nc1, "time")

# determine the grid spacing
dlon = lon[2] - lon[1]
dlat = lat[2] - lat[1]
# print(dlon) ; print(dlat)
#xmax <- length(lon)
#ymax <- length(lat)

#if ( (xmax) == 96 )  dlon <- 3.75 
#if ( (xmax) == 192 ) dlon <- 1.875 
#if ( (ymax) == 73 )  dlat <- 2.50 
#if ( (ymax) == 145 ) dlat <- 1.25 

# height in km's to pass to plots
hgt <- hgt/1000.
hgt.10 <- which(hgt>=10.0)[1]

# ##################################################################################
# generate an array of NOx (kg/kg) from the two simulations 
no.1temp <- ncvar_get(nc1, no.code)
no2.1temp<- ncvar_get(nc1, no2.code)

nox1 <- (no.1temp + no2.1temp)
rm(no.1temp); rm(no2.1temp)

mm.nox <- (16+14) + (16+16+14)
# ##################################################################################
#  
# The plots compare the model runs with statistical 
# data compiled from aircraft campaigns

source("read_campaign_dat.R")
# source("plot_Emmons_HCHO_eval.R")
# source("plot_Emmons_PAN_eval.R")
# source("plot_Emmons_H2O2_eval.R")
source("plot_Emmons_HNO3_eval.R")
# source("plot_Emmons_O3_eval.R")
source("plot_Emmons_CO_eval.R")
source("plot_Emmons_NOx_eval.R")

rm(nox1);gc()
