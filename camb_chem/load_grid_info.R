# R script to obtain static grid-related parameters

# Alex Archibald, March 2012
# Mohit, Aug 2013 - made more generalised

# Inputs: 
# nc1 = the netcdf file of your model data
# nc4-5 = the UM anciliary info about various model grids
# These should contain info on the heights of the grid boxes,
# volumes, and areas.

# Outputs:
# vol 	= array(lon,lat,hgt) of grid box volumes in m^3
# gb.sa = array(lon,lat) of grid box surface area in m^2 
# modhgt= array(lon,lat,hgt) of grid box heights in m
# number of longitude, latitude, levels and level_heights

nlong = length(ncvar_get(nc1, "longitude"))
nlat  = length(ncvar_get(nc1, "latitude"))
#mlev = length(ncvar_get(nc1, "hybrid_ht"))
mlev = length(ncvar_get(nc1, "model_level_number"))
lev_hgt <- ncvar_get(nc1, "level_ht")

nam2d = paste(nlong,nlat,sep="x")
nam3d = paste(nlong,nlat,mlev,sep="x")

# Open 2d & 3d files to read data
nc4 <- nc_open(paste(geo_dir,"/sfarea_",nam2d,".nc",sep=""))
nc5 <- nc_open(paste(geo_dir,"/geovol_",nam3d,".nc",sep="")) 

gb.sa   <- ncvar_get(nc4,"Area") 		# surface area of grid boxes in m^2
modhgt  <- ncvar_get(nc5,"geop_theta")       # height of model grid in m 
vol     <- ncvar_get(nc5,"vol_theta")	# volume of grid boxes in m^3

