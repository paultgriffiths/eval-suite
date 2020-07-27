# R Script to plot the tropospheric OH mixing ratio
# similar to that in Lawrence et al., 2001

# Alex Archibald, February 2012

# constants and loop variables
nav <- 6.02214179E23 
i   <- NULL
accmip_oh <- "1.17 (+/- 0.1) e+06"
# ACCMIP multi-model mean converted from 11.7 +/- 1.0 * 10^5 molec/cm3 for
# consistency to 10^6 unit used here
nhsh_ref <- "0.97 +/- 0.12"
#OH NH/SH ratio from Patra et al 2014, for 2004-2011

if ( exists("modhgt") == FALSE ) source("load_grid_info.R")

# Get model tropopause height and/or mask information
source("get_trophgt_msk.R")

# If missing
if ( max(mask) == -999. ) {
 print("PLOT_OH_LAWRENCE cannot continue without Tropospheric mask")
 q()
}

# ################# Extract Variables ######################################
lat <- ncvar_get(nc1, "latitude")
hgt <- ncvar_get(nc1, "level_ht")
lon <- ncvar_get(nc1, "longitude")
time <- ncvar_get(nc1, "time")

# extract OH from data frames (kg/kg)
oh <- ncvar_get(nc1,oh.code)
# time mean
oh <- apply(oh,c(1,2,3),mean) 

# extract mass in grid boxes (kg)
mass <- ncvar_get(nc1,air.mass) 
# time mean
mass <- apply(mass,c(1,2,3),mean) 

# extract pressure
pres <- ncvar_get(nc1, pres.code)
pres <- apply(pres,c(1,2,3),mean) # time mean

# convert vol from m3 -> cm3
vol <- vol*1E6
# ##############################################################################

# calculate OH in molecules cm^-3 and apply tropospheric mask
# oh.cc <- (nav*oh*mass)/(vol*16e-3)
oh.cc <- (nav*oh*mass)/(vol*17e-3)

# caluclate the mean value:
mask.zm <- apply(mask,c(1,2,3), mean)
mask.zm[mask.zm==0.0] <- NA
# bug--mean.oh <- sprintf("%1.3g", mean((oh.cc * mask.zm ), na.rm=T) )
# need to apply a correction for airmass/volume
mean.oh <- sprintf("%1.3g", 
       sum( (oh.cc * vol * mask.zm), na.rm=T) / sum( (vol * mask.zm), na.rm=T)
       )

# Zonally mean fields
oh.cc <- apply(oh.cc,c(2,3),mean)
pres  <- apply(pres,c(2,3),mean)/100.0 # convert to hPa

# generate a series of lists of model heights to average up to
bottom <- NULL 
middle <- NULL 
top    <- NULL 

# calculate the height of the model level that has pressure greater than X
for (i in 1:length(lat) ) {
bottom[i] <- max(which(pres[i,] > 750 ) ) 
middle[i] <- max(which(pres[i,] > 500 ) ) 
top[i]    <- max(which(pres[i,] > 250 ) ) 
} # end of for

# remove infinites
bottom[bottom==-Inf] <- 1

# calculate the index's of the latitudes
left   <- which(lat >= -30)
centre <- which(lat >= 0)
right  <- which(lat >= 30)

# assign empty vectors to place data in
ex.1 <- NULL; ex.2 <- NULL; ex.3 <- NULL; ex.4 <- NULL; ex.5 <- NULL; ex.6 <- NULL
ex.7 <- NULL; ex.8 <- NULL; ex.9 <- NULL; ex.10 <- NULL; ex.11 <- NULL; ex.12 <- NULL

oh.1 <- NULL; oh.2 <- NULL; oh.3 <- NULL; oh.4 <- NULL; oh.5 <- NULL; oh.6 <- NULL
oh.7 <- NULL; oh.8 <- NULL; oh.9 <- NULL; oh.10 <- NULL; oh.11 <- NULL; oh.12 <- NULL

sd.1 <- NULL; sd.2 <- NULL; sd.3 <- NULL; sd.4 <- NULL; sd.5 <- NULL; sd.6 <- NULL
sd.7 <- NULL; sd.8 <- NULL; sd.9 <- NULL; sd.10 <- NULL; sd.11 <- NULL; sd.12 <- NULL

for (i in 1:length(lat) ){
# extract the OH over latatudes 
ex.1 <- (oh.cc[1:left[1],1:bottom[i]])*1e-6
ex.2 <- (oh.cc[left[1]:centre[1],1:bottom[i]])*1e-6
ex.3 <- (oh.cc[centre[1]:right[1],1:bottom[i]])*1e-6
ex.4 <- (oh.cc[right[1]:length(lat),1:bottom[i]])*1e-6
ex.5 <- (oh.cc[1:left[1],bottom[i]:middle[i]])*1e-6
ex.6 <- (oh.cc[left[1]:centre[1],bottom[i]:middle[i]])*1e-6
ex.7 <- (oh.cc[centre[1]:right[1],bottom[i]:middle[i]])*1e-6
ex.8 <- (oh.cc[right[1]:length(lat),bottom[i]:middle[i]])*1e-6
ex.9 <- (oh.cc[1:left[1],middle[i]:top[i]])*1e-6
ex.10 <- (oh.cc[left[1]:centre[1],middle[i]:top[i]])*1e-6
ex.11 <- (oh.cc[centre[1]:right[1],middle[i]:top[i]])*1e-6
ex.12 <- (oh.cc[right[1]:length(lat),middle[i]:top[i]])*1e-6
} # end for

#### Extract data for hemispheric ratio #############

# calculate index of North, South hemisphere
north <- which (lat >= 0.)
south <- which (lat < 0.)
ex.h <- NULL ; oh.n <- NULL
j = length(north)
ex.h <- ( oh.cc[north[1]:north[j],] ) # *1e-6, not req - common factor
oh.n <- mean(as.vector(ex.h),na.rm=T)

ex.h <- NULL ; oh.s <- NULL
j = length(south)
ex.h <- ( oh.cc[south[1]:south[j],] ) #*1e-6
oh.s <- mean(as.vector(ex.h),na.rm=T)
rm(ex.h)

#print(paste(oh.n,oh.s,oh.n/oh.s,sep=" "))
nhsh.oh <- sprintf("%1.3g", (oh.n/oh.s))
#print(paste('NH:SH', nhsh.oh,sep=" "))

# calculate the mean 
oh.1 <- mean(as.vector(ex.1),na.rm=T)
oh.2 <- mean(as.vector(ex.2),na.rm=T)
oh.3 <- mean(as.vector(ex.3),na.rm=T)
oh.4 <- mean(as.vector(ex.4),na.rm=T)
oh.5 <- mean(as.vector(ex.5),na.rm=T)
oh.6 <- mean(as.vector(ex.6),na.rm=T)
oh.7 <- mean(as.vector(ex.7),na.rm=T)
oh.8 <- mean(as.vector(ex.8),na.rm=T)
oh.9 <- mean(as.vector(ex.9),na.rm=T)
oh.10 <- mean(as.vector(ex.10),na.rm=T)
oh.11 <- mean(as.vector(ex.11),na.rm=T)
oh.12 <- mean(as.vector(ex.12),na.rm=T)

# calculate the standard deviation
sd.1 <- sd(as.vector(ex.1))
sd.2 <- sd(as.vector(ex.2))
sd.3 <- sd(as.vector(ex.3))
sd.4 <- sd(as.vector(ex.4))
sd.5 <- sd(as.vector(ex.5))
sd.6 <- sd(as.vector(ex.6))
sd.7 <- sd(as.vector(ex.7))
sd.8 <- sd(as.vector(ex.8))
sd.9 <- sd(as.vector(ex.9))
sd.10 <- sd(as.vector(ex.10))
sd.11 <- sd(as.vector(ex.11))
sd.12 <- sd(as.vector(ex.12))

# ################### Plot the results #########################################

title1 <- expression("[OH] Air mass weighted") 
title2 <- expression( "(10"^6*" molecules cm"^-3*")" ) 
title3 <- expression("Red: Spivakovsky values") 
title4 <- expression( "Values in ( ): Std dev" ) 
title51 <- expression( "molec/cm3" ) 
title5 <- paste("ACCMIP Multi-model Mean=",accmip_oh,title51,sep=" ")
title6 <- paste(" Patra et al 2014: ",nhsh_ref) 

pdf(file=paste(out_dir, "/",mod1.name,"_Lawrence_plot.pdf",sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

plot(lat, 1:length(lat), type="l", lwd=1.5, col="white", xlim=c(-90,90), yaxt="n", ylim=c(1,4), xlab="Latitude", ylab="Pressure (hPa)", 
main=(paste("UKCA",mod1.name,sep=" " )) )
par(xpd=T)
text(-70.0,4.4,title1,cex=0.7)
text(-30.0,4.4,title2,cex=0.7)
text(60.0,4.4,title3,cex=0.7,col="red")
text(60.0,4.3,title4,cex=0.7)
text(-60.0,4.3,paste("Mean OH=",mean.oh,title51, sep=" "),cex=0.8 )
text(-60.0,4.2,title5,cex=0.75,col="blue" )
text(40.0,4.2,paste("NH:SH ratio=",nhsh.oh,title6,sep=" "),cex=0.75) 
par(xpd=F)
axis(side=2, at=c(1,2,3,4), labels=c(1000,750,500,250), tick=TRUE) 

# add the mean OH
text(-60,1.5,format((oh.1),digits=2))
text(-15,1.5,format(oh.2,digits=2))
text(15,1.5,format(oh.3,digits=2))
text(60,1.5,format(oh.4,digits=2))

text(-60,2.5,format(oh.5,digits=2))
text(-15,2.5,format(oh.6,digits=2))
text(15,2.5,format(oh.7,digits=2))
text(60,2.5,format(oh.8,digits=2))

text(-60,3.5,format(oh.9,digits=2))
text(-15,3.5,format(oh.10,digits=2))
text(15,3.5,format(oh.11,digits=2))
text(60,3.5,format(oh.12,digits=2))

# add the Spivakovsky data
text(-60,1.4, 0.47, cex=0.6, col="red")
text(-15,1.4, 1.44, cex=0.6, col="red")
text(15,1.4, 1.52, cex=0.6, col="red")
text(60,1.4, 0.76, cex=0.6, col="red")

text(-60,2.4, 0.72, cex=0.6, col="red")
text(-15,2.4, 2.00, cex=0.6, col="red")
text(15,2.4, 1.99, cex=0.6, col="red")
text(60,2.4, 0.88, cex=0.6, col="red")

text(-60,3.4, 0.64, cex=0.6, col="red")
text(-15,3.4, 1.43, cex=0.6, col="red")
text(15,3.4, 1.36, cex=0.6, col="red")
text(60,3.4, 0.64, cex=0.6, col="red")

# add the standard deviation of the OH
text(-60,1.2, paste( "(", format(sd.1,digits=2), ")",sep="" ) )
text(-15,1.2, paste( "(", format(sd.2,digits=2), ")",sep="" ) )
text(15,1.2, paste( "(", format(sd.3,digits=2), ")",sep="" ) )
text(60,1.2, paste( "(", format(sd.4,digits=2), ")",sep="" ) )

text(-60,2.2, paste( "(", format(sd.5,digits=2), ")",sep="" ) )
text(-15,2.2, paste( "(", format(sd.6,digits=2), ")",sep="" ) )
text(15,2.2, paste( "(", format(sd.7,digits=2), ")",sep="" ) )
text(60,2.2, paste( "(", format(sd.8,digits=2), ")",sep="" ) )

text(-60,3.2, paste( "(", format(sd.9,digits=2), ")",sep="" ) )
text(-15,3.2, paste( "(", format(sd.10,digits=2), ")",sep="" ) )
text(15,3.2, paste( "(", format(sd.11,digits=2), ")",sep="" ) )
text(60,3.2, paste( "(", format(sd.12,digits=2), ")",sep="" ) )

abline(h=1, lty=2)          
abline(h=2, lty=2)
abline(h=3, lty=2)
abline(h=4, lty=2)
abline(v=-30, lty=2)
abline(v=0, lty=2)
abline(v=30, lty=2)

dev.off()

rm(oh); rm(oh.cc); rm(mean.oh)
rm(ex.1);rm(ex.2);rm(ex.3);rm(ex.4);rm(ex.5);rm(ex.6);rm(ex.7);rm(ex.8)
rm(ex.9);rm(ex.10);rm(ex.11);rm(ex.12)
gc()
