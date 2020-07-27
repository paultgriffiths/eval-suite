# Obtain Tropospheric mask (UKCA diag) or generate from tropo hgt (Sec30)
# Wrapper to calc_trop_mask routine

if ( exists("mask") == FALSE ) {

# Check if 3-D tropospheric mask is present in model o/p
tmid <- var_exists(nc1, tropmsk.code)
thid <- var_exists(nc1, troppse.code)  # also check for tropopause hgt
if ( identical(TRUE,tmid) )  {                      # -1 if variable missing
print("Tropospheric Mask found in output, reading") 
mask <- ncvar_get(nc1, tropmsk.code )
 } 
}   # Mask = false

if ( exists("trophgt") == FALSE ) {
# Check if 2-D tropopause ht is present & calc mask if req
 if ( identical(TRUE,thid) )  {
   print("Tropopause Height in output, reading") 
   trophgt <- ncvar_get(nc1, troppse.code )
   if ( exists("mask") == FALSE ) {
   print("Creating Tropospheric Mask from Tropopause Height") 
   source("calc_trop_mask.R")
   }  # Mask exists?
 }   # Trop hgt in file ? 
}    # Trop hgt exists ?

# If both missing
if ( thid+tmid < 0 ) {
print(paste("  ERROR: Both tropospheric mask ",tropmsk.code," and Tropopause hgt ",troppse.code," missing from output"))
mask <- -999.
trophgt <- -999.
# q()

# **** Tempopary workaround ***********
# use trophgt data from climatological data
#print(" WARNING: Using climatological data for Tropopause hgt")
#nlong = length(ncvar_get(nc1, "longitude")) 
#nlat  = length(ncvar_get(nc1, "latitude"))  
#nc2    <- nc_open(paste(geo_dir,"/tropohgt_",nlong,"x",nlat,".nc",sep=""), readunlim=FALSE)
#trophgt  <- ncvar_get(nc2, troppse.code )
#source("calc_trop_mask.R")
#return(0)
# ****************************************
} # Trophgt+mask missing check

# for downstream scripts calling this routine for tropopause hgt
if ( thid < 0 ) {   # Tropopause hgt not in file
  trophgt <- -999.0 
} 
