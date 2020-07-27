# R script to extract profiles from Zonal Mean
# MLS data
 
# open data
nc0 <- nc_open(paste(obs_dir,"MLS/mls_o3_2006-2007.nc",sep="/"))

# extract variables (MLS height in hPa's)
mls.hgt <- ncvar_get(nc0,"Pressure")
mls.hgt <- -7.2*log(mls.hgt/1000.0)
mls.lat <- ncvar_get(nc0, "latitude")
mls.lon <- ncvar_get(nc0, "longitude")
mls.time<- ncvar_get(nc0, "t")

start.lat<- find.lat(mls.lat, first.lat)
end.lat  <- find.lat(mls.lat,  last.lat)

# extract observed variables (these are already zonal means so only need to average
# over the latitude dimension -- keep height)

assign(paste(location,".mls.o3.z",sep=""), apply( (ncvar_get(nc0, "MLS_O3", start=c(1, start.lat, 1, 1), count=c(length(mls.lon), end.lat-start.lat, length(mls.hgt), length(mls.time)))), c(2), mean, na.rm=T) )

