# R Script to interpolate model variable onto pressure
# grid and generate zonal mean.
# Takes input's:
# "var", "nc1", "pres" and "lonp,latp" from calling script 
# Output = newvv
# Alex Archibald, February, 2012
# Mohit D: Optmise, make resolution independant

# This version also includes a call to a routine to do a 
# 2d interpolation of the model field (lon, lat) to the obs
# grid (i.e. N96-N48 transform)
source(paste(scr_dir,"interp2d.R",sep=""))

# Arguments  ----------------------------------------------------------- #
pmax <- length(pres)

if ( exists("lonp") == FALSE ) {
 print("ERROR:interpolate_zm_plev:output lat/lon not defined-latp,lonp")
 q()
} 
# extract model co-ords
lonv  <- ncvar_get(nc1, "longitude")
latv  <- ncvar_get(nc1, "latitude")
levv  <- ncvar_get(nc1, "model_level_number")
timev <- ncvar_get(nc1, "time")

# Set output dimensions (latp, lonp from calling script)
xmax <- length(lonp) 
ymax <- length(latp) 
zmax <- length(levv) 
tmax <- length(timev)

# set counters to NULL
it <- NULL; iy <- NULL; ix <- NULL; ip <- NULL
i <- NULL; j <- NULL

# set variables 
p1 <- NULL; p2 <- NULL; zm <- FALSE

# create empty array's to fill with data
print (paste(xmax,ymax,zmax,tmax,pmax,sep=":"))
newvv  <- array(as.numeric(NA), dim=c(ymax,pmax,tmax))
pp     <- array(as.numeric(NA), dim=c(ymax,zmax,tmax))
vv     <- array(as.numeric(NA), dim=c(ymax,zmax,tmax))
pp.rgd2<- array(as.numeric(NA), dim=c(xmax,ymax,zmax,tmax))
vv.rgd2<- array(as.numeric(NA), dim=c(xmax,ymax,zmax,tmax))

# check for dimension missmatches --not useful, since latp /= latv
# MD source(paste(scr_dir, "interp_error_checks.R", sep=""))

# extract the model variables and if required, regrid onto output grid
vv.rgd <- ncvar_get(nc1, var)
pp.rgd <- ncvar_get(nc1, pres.code) 
if ( (length(latv) != ymax) | (length(lonv) != xmax) ) {  # dims not same   
for (i in 1:length(levv) ) {
 for (j in 1:length(timev) )  {
vv.rgd2[,,i,j] <- interp2d(vv.rgd[,,i,j], newx=xmax, newy=ymax)
pp.rgd2[,,i,j] <- interp2d(pp.rgd[,,i,j], newx=xmax, newy=ymax)
} }

} else {                              # no regridding required
vv.rgd2 <- vv.rgd
pp.rgd2 <- pp.rgd
}
rm(vv.rgd) ; rm(pp.rgd)

# Main code here ----------------------------------------------------------- #
# loop over all time steps
print ("Interpolate_plev;start loop over pressure")
ptarget <- log(pres)
for (it in 1:tmax) {
   print (paste("Time step: ",it,sep=""))

# read pressure and variable     
  pp <- pp.rgd2[,,,it:1]
  pp <- apply(pp,c(2,3),mean)    # take zonal mean
#   print(str(pp))
  lpp <- log(pp/100.)            # NOTE conversion to hPa

  vv <- vv.rgd2[,,,it:1] 
  vv <- apply(vv,c(2,3),mean)
#   print(str(vv))

# loop over pressure
  for (ip in 1:pmax) {

# determine the interval, loop over model levels and interpolate linear in log(p)
    for (iz in 2:zmax) {
     # loop over latitude  
      for (iy in 1:ymax) {
        p1 = lpp[iy,iz-1]
        p2 = lpp[iy,iz]
  #     print(paste(ip,iy,iz,p1,p2,ptarget[ip],sep=","))
        if ( ptarget[ip] <= p1) {
          if ( ptarget[ip] >= p2 )  {
             newvv[iy,ip,it] = vv[iy,iz-1] + ( ( (vv[iy,iz] - vv[iy,iz-1] )/(p2-p1))*(ptarget[ip]-p1) )

           } # end if p2
         } # end if p1
       }# end do latitude loop
     } # end do level loop
   } # end do pressure loop
 } # end do loop over time

rm(pp); rm(pp.rgd2); rm(lpp); rm(vv); rm(vv.rgd2)
# end of main code ----------------------------------------------------- #
