# R script to extract profiles from Zonal Mean
# TES data
 
# open data
nc0 <- nc_open(paste(obs_dir,"TES/tes_o3_2005.nc",sep="/"))

# extract variables (TES height in hPa's)
tes.hgt <- ncvar_get(nc0,"Pressure")
tes.hgt <- -7.2*log(tes.hgt/1000.0)
tes.lat <- ncvar_get(nc0, "latitude")
tes.lon <- ncvar_get(nc0, "longitude")
tes.time<- ncvar_get(nc0, "t")

start.lat<- find.lat(tes.lat, first.lat)
end.lat  <- find.lat(tes.lat,  last.lat)

# extract observed variables (these are already zonal means so only need to average
# over the latitude dimension -- keep height)

assign(paste(location,".tes.o3.z",sep=""), apply( (ncvar_get(nc0, "TES_O3", start=c(1, start.lat, 1, 1), count=c(length(tes.lon), end.lat-start.lat, length(tes.hgt), length(tes.time)))), c(2), mean, na.rm=T) )

