# R script to extract profiles from Zonal Mean
# ACE data
 
# open data
nc0 <- nc_open(paste(obs_dir,"ACE/ACE_vn3.1_2006-2009_zm_combined.nc",sep="/"))

# extract variables (ACE height in km's)
ace.hgt  <- ncvar_get(nc0, "height") 
ace.lat  <- ncvar_get(nc0, "latitude")
ace.lon  <- ncvar_get(nc0, "longitude")
ace.time <- ncvar_get(nc0, "t")
start.lat<- find.lat(ace.lat, first.lat)
end.lat  <- find.lat(ace.lat,  last.lat)

# extract observed variables (these are already zonal means so only need to average
# over the latitude dimension -- keep height)

assign(paste(location,".ace.o3.z",sep=""), apply( (ncvar_get(nc0, "O3", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.h2o2.z",sep=""), apply( (ncvar_get(nc0, "H2O2", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.co.z",sep=""), apply( (ncvar_get(nc0, "CO", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.no.z",sep=""), apply( (ncvar_get(nc0, "NO", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
assign(paste(location,".ace.hno3.z",sep=""), apply( (ncvar_get(nc0, "HNO3", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
assign(paste(location,".ace.no2.z",sep=""), apply( (ncvar_get(nc0, "NO2", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.hcl.z",sep=""), apply( (ncvar_get(nc0, "HCl", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.clono2.z",sep=""), apply( (ncvar_get(nc0, "ClONO2", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
assign(paste(location,".ace.n2o.z",sep=""), apply( (ncvar_get(nc0, "N2O", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
#assign(paste(location,".ace.h2co.z",sep=""), apply( (ncvar_get(nc0, "H2CO", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )
assign(paste(location,".ace.h2o.z",sep=""), apply( (ncvar_get(nc0, "H2O", start=c(1, start.lat, 1, 1), count=c(length(ace.lon), end.lat-start.lat, length(ace.hgt), length(ace.time)))), c(2), mean, na.rm=T) )

