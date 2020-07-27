# R Script to calculate the tropospheric ozone burden

# Alex Archibald, February 2012

# extract vars
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
hgt   <- ncvar_get(nc1, "level_ht")
time  <- ncvar_get(nc1, "time")

if ( exists("modhgt") == FALSE ) source("load_grid_info.R")

o3      <- ncvar_get(nc1,o3.code) # kg/kg o3

# Get model tropopause height and/or mask information
source("get_trophgt_msk.R")

# If missing
if ( max(mask) == -999. ) {
 print("GET_O3_BURDEN cannot continue without Tropospheric mask")
 q()
}

mass    <- ncvar_get(nc1,air.mass) # kg air

# Calc the burden ########################################################################################################

# mask out troposphere and convert to molecules 
# n.molecules = NA(molecules/mol) * mass(g) / mmr(g/mol) )
o3.mass <- (o3 * mass * mask)

# Calc the burden in Tg
o3.burden <- sum( (o3.mass)*1E-9) / length(time)

