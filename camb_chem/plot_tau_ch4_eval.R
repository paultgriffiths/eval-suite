# R script to plot and calculate the methane 
# lifetime in the troposphere.

# Alex Archibald, February 2012

# loop vars
i <- NULL; j <- NULL
nav      <- 6.02214179E23 

# Reference values:
#ACCMIP's Methane lifetime against OH : 
# Total burden of CH4 / tropospheric loss of methane by OH = 9.3 +/- 0.9 years 
#    using a subset of models (full ensemble gives 9.8+/-1.6 years)
#
# ACCMIP's Total methane lifetime : Total burden of CH4 / total loss of methane
#                                    = 8.2 +/- 0.8 years
#
# ACCMIP definition: total loss of methane = tropospheric loss by OH 
#                                            + 30 Tg/yr (due to soil sink) 
#                                            + 40 Tg/yr (stratospheric loss). 

# Voulgarakis et al., Analysis of present day and future OH and methane 
# lifetime in the ACCMIP simulations, Atmos. Chem. Phys., 13, 2563-2587, 2013

#Observation-based estimate for methane lifetime against OH = 11.2 +/- 1.3 yr
# Prather, M. J., Holmes, C. D., and Hsu, J.: Reactive greenhouse gas scenarios
#: Systematic exploration of uncertainties and the role of atmospheric 
# chemistry, Geophys. Res. Lett., 39, L09803, doi:10.1029/2012GL051440, 2012.

# factor for seconds to years conversion
f_sec2yr <- 60.*60.*24.*30.*12. # assumes you supply 12 months of data
                                # and 360-day calendar

ch4_loss.soil <- 30.0  * 1.0e+9   #Tg/yr -> kg/yr
ch4_loss.strat <- 40.0 * 1.0e+9

# extract/define variables
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
hgt   <- ncvar_get(nc1, "level_ht")*1E-3
time  <- ncvar_get(nc1, "time")

# define empty arrays
flux.zm.nrm <- array(NA, dim=c(length(lon), length(lat), length(hgt), length(time)) )

# Get model tropopause height and/or mask information
L_plot_troppse <- TRUE
source("get_trophgt_msk.R")
if ( max(trophgt) == -999. ) L_plot_troppse <- FALSE # Dont plot tropopause line

# If both missing
if ( max(mask) == -999. ) {
 print("PLOT_TAU_CH4 cannot continue without Tropospheric mask")
 q()
} 

#ht     <- ncvar_get(nc1, "ht")
if ( L_plot_troppse ) ht   <- apply(trophgt, c(2), mean)*1E-3 # km

if ( exists("modhgt") == FALSE )source("load_grid_info.R") 

# #####################################################################
# Check to see if air mass exists?
mmid <- var_exists(nc1, air.mass.watm )
if ( identical(TRUE,mmid) ) { 
print("Air Mass exists, carrying on") 
mass <- ncvar_get(nc1, air.mass.watm )
} else {
print(paste("  ERROR: Air mass diagnostic ",air.mass," not in output"))
 print("PLOT_TAU_CH4 cannot continue")
 q()
}

# #####################################################################
# extract the grid box volumes and convert to cm3
if ( exists("vol") == FALSE )source("load_grid_info.R") 
gbvol <- vol * 100 * 100 * 100

# CH4 in kg in troposphere
# check to see if you have methane as a variable or if you 
# have to calculate it based as a constant fraction of air
if (mod1.type=="CheT") { 
ch4 <- mass * f.ch4
ch4_trop <- mass * f.ch4 * mask
} else {
#print ("Fetching variable methane...")
ch4 <- ncvar_get(nc1, ch4.code)

# check the mask structure:
if ( (identical( dim(ch4) , dim (mass) )) == TRUE ) { 
#print("Methane and Mass identical dims...")
ch4 <- ch4 * mass                  # Total burden
ch4_trop <- ch4 * mask      # Tropospheric burden
} else {
# loop over time and multiply by mass (kg)
for (i in 1:length(time) ) {
  ch4[,,,i] <- ch4[,,,i] * mass
  ch4_trop[,,,i] <- ch4[,,,i] * mass * mask
}  }
}  # end if mod.type = CheT

# flux is in moles/gridcell/s --> kg/gridcell/s
flux <- ncvar_get(nc1, oh.ch4.rxn.code) * 16.0e-3 # kg/mole
flux <- flux * flux_scale_fac ## NOTE Scale factor applied to account for 
       # UM(STASH)/UKCA calling frequency. Factor is set in top-level
       # script or user input
# Tropospheric OH-CH4 loss as per ACCMIP definition
flux.trop <- flux * mask  

# Calculate tau CH4 = sum{CH4(kg)} / sum{OH+CH4(kg/s)}
ch4.tavg <- apply(ch4,c(1,2,3),mean)  # Average over time
ch4.sum <- sum(ch4.tavg)
rm(ch4); rm(ch4.tavg)

flux.tavg <- apply(flux.trop,c(1,2,3),mean)
flux.sum <- sum(flux.tavg)
rm(flux); rm(flux.tavg)

ch4_trop.tavg <- apply(ch4_trop,c(1,2,3),mean)
ch4_trop.sum <- sum(ch4_trop.tavg)
rm(ch4_trop); rm(ch4_trop.tavg)

# Lifetime vs OH 
tau_v_oh  <- ch4.sum / flux.sum 
tau_trop_v_oh  <- ch4_trop.sum / flux.sum

tau.ch4_v_oh <- sprintf("%1.3g", tau_v_oh/f_sec2yr) # /s -> /yr
tau.ch4_trop_v_oh <- sprintf("%1.3g", tau_trop_v_oh/f_sec2yr)

# Get total CH4 loss and lifetime (ACCMIP definition)
# Total Loss = OH + Soil + Stratosphere - all in Kg/yr 
ch4_loss.tot <- (flux.sum*f_sec2yr) + ch4_loss.soil + ch4_loss.strat

#pch4.sum <-  sprintf("%1.3g",ch4.sum*1.0e-9)
#pflux.sum <- sprintf("%1.3g",(flux.sum*f_sec2yr*1.0e-9))
#pch4_loss.tot <- sprintf("%1.3g",ch4_loss.tot*1.0e-9)
#print(paste("Tot ",pch4.sum, pflux.sum,pch4_loss.tot,sep=" : "))

# Lifetime -- CH4 (kg) / CH4Loss (kg/yr)
tau.tot = ch4.sum / ch4_loss.tot 
tau_ch4.tot = sprintf("%1.3g",tau.tot)

rm(ch4.sum); rm(flux.sum)

# extract the reaction fluxes to plot as a zonal mean
flux.zm <- ncvar_get(nc1, oh.ch4.rxn.code)

# loop over time and multiply by the volumes
for (j in 1:length(time) ) {
  flux.zm.nrm[,,,j] <- ( flux.zm[,,,j] * gbvol ) #* nav
}

# generate zonal mean in moles/cm^3
flux.zm.nrm <- apply(flux.zm.nrm, c(2,3), mean)

# ############################################################################
# some extra bits and bobs for the plot

# find index of hgt which is greater than 20 km's 
hindex   <- which((hgt)>=20)[1]
# #############################################################################
pdf(file=paste(out_dir,"/",mod1.name,"_tau_ch4.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
image.plot(lat, hgt[1:hindex], 100*(flux.zm.nrm[,1:hindex]/sum(flux.zm.nrm[,1:hindex])), xlab="Latitude (degrees)", ylab="Altitude (km)", 
main=paste("UKCA",mod1.name, sep=" "), 
zlim=c(0,0.4), ylim=c(0,21), col=col.cols(43) )
# add tropopause
if ( L_plot_troppse ) lines(lat, ht, lwd=2, lty=2)

par(xpd=T)
text(x=0.0,y=22, expression(paste("% ",CH[4]," + OH flux (moles cm"^-3*"", " s"^-1*"", ")",sep="") ),cex=0.8 )

# Print Lifetime values from the different methods
text(x=0,y=20,"Methane lifetime values",cex=0.9 )
text(x=-45,y=19, paste("Trop-only vs OH= ", tau.ch4_trop_v_oh, " yr", sep=""),cex=0.8 )
text(x=-45,y=18, paste("Whole Atm vs OH = ", tau.ch4_v_oh, " yr", sep=""),cex=0.8 )
text(x=45,y=18, "ACCMIP Whole Atm vs OH = 9.3 +/- 0.9 yr",cex=0.8 )
# Values for Total methane lifetime
text(x=-45,y=17, paste("Whole Atm vs Total (OH+soil+strat) = ", tau_ch4.tot, " yr", sep=""),cex=0.8 )
text(x=45,y=17, "ACCMIP vs  Total = 8.2 +/- 0.8 yr",cex=0.8 )
par(xpd=F)

dev.off()

rm(flux);rm(flux.zm);rm(flux.zm.nrm)
gc()
