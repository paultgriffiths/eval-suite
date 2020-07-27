# R script to generate a tropospheric mask

# You will need to pass in:
# nc1, and the dimensions of the model variable (lon,lat,ht,time)

print("Creating tropospheric Mask")

if ( exists("trophgt") == TRUE) print("Tropopause height exists, carrying on") else ( trophgt <- ncvar_get(nc1,"ht") )
if ( exists("modhgt") == TRUE) print("Model hybrid heights exist, carrying on") else ( modhgt  <- ncvar_get(nc5,"geop_theta") )

# define loop vars
i <- NULL; j <- NULL; k <- NULL; l <- NULL; m <- NULL; n <- NULL

# Calculate mask  ############################################################################################################
mask <- array(0, dim=c(length(lon),length(lat),length(hgt),length(time)))

grhgt <- ncvar_get(nc1,"level_ht")  # Gridbox hgt

#Roughly set a mask between 4 - 20 km
k1 <- -1 ; k2 <- -1
for (k in 1:length(hgt)) {
  if ( grhgt[k-1] < 4000 && grhgt[k+1] >= 4000 )   k1 = k
  if ( grhgt[k-1] <= 20000 && grhgt[k+1] > 20000 ) k2 = k
}
  mask[,,1:k1,] = 1 ; mask[,,k2:length(hgt),] = 0

# generate trop mask -- remove strat
for (l in 1:length(time)) {
  for (k in k1:k2)         {
   for (j in 1:length(lat)) {
     for (i in 1:length(lon)) {
        mask[i,j,k,l] <- ifelse(modhgt[i,j,k] <= trophgt[i,j,l], 1, 0) 
      }
     }
   }
}
print("Created tropospheric Mask")
