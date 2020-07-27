# R code to do error checking for interpolation
# script. ATA, December 2011

# check to see if the data is a zonal mean.
   if (length(xmax) == 1) print(" ... we assume zonal mean pressure is supplied ... ")
   if (length(xmax) == 1) zm <- TRUE

# check that coordinates are identical -- this may be overkill...
   if ( zm == FALSE ) {    
      for (ix in 1:xmax ) {
      if ( lonv[ix] != lonp[ix] ) {
         print("longitude mismatch ...")
         break
          } # end if
         } # end do
      } # end if

   for (iy in 1:ymax) {
   if ( latv[iy] != latp[iy] ) {
      print("latitude mismatch ...")
      break
       } # end if
      } # end do

   for (iz in 1:zmax) {
   if ( levv[iz] != levp[iz] ) {
      print("level mismatch ...")
      break
       } # end if
      } # end do

   for (it in 1:tmax) {
   if ( timev[it] != timep[it] ) {
      print("time mismatch ...")
      break
       } # end if
      } # end do
