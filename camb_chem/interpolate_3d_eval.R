# R Script to interpolate model variable onto pressure
# grid and generate zonal mean.
# Takes input's:
# "var", "nc1" and "pres" from calling script 

# Alex Archibald, February, 2012
# Mohit, trying to optimise, Aug 2013

# Arguments  -------------------------------------------------------------- #
pmax <- length(pres)

# extract model co-ords
lonp  <- ncvar_get(nc1, "longitude")
latp  <- ncvar_get(nc1, "latitude")
levp  <- ncvar_get(nc1, "level_ht")
timep <- ncvar_get(nc1, "time")

lonv  <- ncvar_get(nc1, "longitude")
latv  <- ncvar_get(nc1, "latitude")
levv  <- ncvar_get(nc1, "level_ht")
timev <- ncvar_get(nc1, "time")

# check that the two variables have the same lengths
if ( length(lonp)  == length(lonv) )  xmax <- length(lonp)  else print("Longitudes not equal")
if ( length(latp)  == length(latv) )  ymax <- length(latp)  else print("Latitudes not equal")
if ( length(levp)  == length(levv) )  zmax <- length(levp)  else print("Levels not equal")
if ( length(timep) == length(timev) ) tmax <- length(timep) else print("Times not equal")

# set counters to NULL
it <- NULL
iy <- NULL
ix <- NULL
ip <- NULL

# set variables 
p1 <- NULL
p2 <- NULL
zm <- FALSE

# create empty array's to fill with data
newvv <- array(as.numeric(NA), dim=c(xmax,ymax,pmax,tmax))
pp    <- array(as.numeric(NA), dim=c(xmax,ymax,zmax,tmax))
vv    <- array(as.numeric(NA), dim=c(xmax,ymax,zmax,tmax))

# check for dimension missmatches
source("interp_error_checks.R")

# Main code here ----------------------------------------------------------- #
# Set time/domain independant values here
lptarget <- log(pres)

# loop over all time steps
print ("start interpolation to pressure levs")
for (it in 1:tmax) {
   print (paste("Time step: ",it,sep=""))

# read pressure and variable     
   pp <- ncvar_get( nc1,pres.code, start=c(1,1,1,it),count=c(xmax,ymax,zmax,1) )
#         print(str(pp))
   lpp <- log(pp/100.)  # Conversion to log press hPa

   vv <- ncvar_get( nc1,var,start=c(1,1,1,it),count=c(xmax,ymax,zmax,1) )
#        print(str(vv))

# loop over longitude and latitude
   for (iy in 1:ymax) {
     for (ix in 1:xmax) {

# loop over pressure
       for (ip in 1:pmax) {
         ptarget = lptarget[ip]
# determine the interval, loop over model levels and 
#  interpolate linear in log(p)
         for (iz in 2:zmax) {
           p1=lpp[ix,iy,iz-1]
           p2=lpp[ix,iy,iz  ]
           if ( ptarget < p1 ) {
             if ( ptarget >= p2 ) {

               newvv[ix,iy,ip,it] = vv[ix,iy,iz-1] + ( ( (vv[ix,iy,iz] - vv[ix,iy,iz-1] )/(p2-p1))*(ptarget-p1) )

#                       newvv(ix,iy,ip,1) = vv(ix,iy,iz-1,1) + (((vv(ix,iy,iz,1) - vv(ix,iy,iz-1,1)) / (p2-p1))*(ptarget-p1))
	    } # end if
	  } # end if/while
       }# end do model level loop
     } # end do pressure loop
    } # end do longitude loop 
  } # end do latitude loop
 } # end do loop over time
# end of main code --------------------------------------------- #
