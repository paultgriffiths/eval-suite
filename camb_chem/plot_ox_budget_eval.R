# R script to plot and calculate the ox budget
# in the troposphere.

# Alex Archibald, February 2012


# define constants and conv. factors
conv.factor <- 60*60*24*30*48*(1e-12)

# extract variables
lon   <- ncvar_get(nc1, "longitude")
lat   <- ncvar_get(nc1, "latitude")
hgt   <- ncvar_get(nc1, "level_ht")
time  <- ncvar_get(nc1, "time")

# Get model tropopause height and/or mask information

# Check if 2-D tropopause ht is present
thid <- var_exists(nc1, troppse.code)
if ( identical(TRUE,thid) )  { 
trophgt <- ncvar_get(nc1, troppse.code )
L_plot_troppse <- TRUE          # Whether to plot tropopause line
} else {
L_plot_troppse <- FALSE
}

if ( L_plot_troppse ) ht <- apply(trophgt, c(2), mean)*1E-3 # km

# Check if mask exists
source("get_trophgt_msk.R")
if ( max(mask) < 0. ) {
 print("PLOT_OX_BUDGET cannot continue without Tropospheric mask")
 q()
} 


# ################################################################################################################
# define empty arrays 
net.p.std <- array(NA, dim=c(length(lon), length(lat), length(hgt), length(time)) )
net.l.std <- array(NA, dim=c(length(lon), length(lat), length(hgt), length(time)) )

# extract ozone production terms
p1.1 <- ncvar_get(nc1,ho2no.code) * mask * flux_scale_fac  
   ## multiply fluxes by a factor to account for difference in UM(stash) and
   # UKCA calling frequency -- Set in top-level script or user input
p1.2 <- ncvar_get(nc1,meo2no.code) * mask * flux_scale_fac
p1.3 <- ncvar_get(nc1,ro2no.code) * mask * flux_scale_fac
p1.4 <- ncvar_get(nc1,ohrcooh.code) * mask * flux_scale_fac
p1.5 <- ncvar_get(nc1,ohrono2.code) * mask * flux_scale_fac
p1.6 <- ncvar_get(nc1,hvrono2.code) * mask * flux_scale_fac
p1.7 <- ncvar_get(nc1,ohpan.code) * mask * flux_scale_fac

# sum the terms
net.p     <- (p1.1 + p1.2 + p1.3 + p1.4 + p1.5 + p1.6 + p1.7)

# loop over time and standardise the flux terms:
# moles/grdibox/s -> moles/m3/s
for (i in 1:length(time) ) {
net.p.std <- (net.p[,,,i]/vol) }

# calc the total production
o3.prod.yrt = sum(p1.1 + p1.2 + p1.3 + p1.4 + p1.5 + p1.6 + p1.7)*conv.factor

prod.ls <- c( sum(p1.1), sum(p1.2), sum(p1.3), sum (sum(p1.4) + sum(p1.5) + sum(p1.6) + sum(p1.7)) ) 

# Free memory
rm(p1.1); rm(p1.2); rm(p1.3); rm(p1.4); rm(p1.5); rm(p1.6); rm(p1.7)
gc()
 
# extract ozone loss terms (apply flux scale factor)
l1.1 <- ncvar_get(nc1,o1dh2o.code) * mask * flux_scale_fac
l1.2 <- ncvar_get(nc1,mlr.code) * mask * flux_scale_fac
l1.3 <- ncvar_get(nc1,ho2o3.code) * mask * flux_scale_fac
l1.4 <- ncvar_get(nc1,oho3.code) * mask * flux_scale_fac
l1.5 <- ncvar_get(nc1,o3alk.code) * mask * flux_scale_fac
l1.6 <- ncvar_get(nc1,n2o5h2o.code) * mask * flux_scale_fac
l1.7 <- ncvar_get(nc1,no3loss.code) * mask * flux_scale_fac
# 2d fields
l1.8 <- ncvar_get(nc1,o3.dd.code)  * flux_scale_fac
l1.9 <- ncvar_get(nc1,noy.dd.code) * flux_scale_fac
# 3d noy wet dep
l1.10 <- ncvar_get(nc1,noy.wd.code) * mask * flux_scale_fac

# sum the terms
net.l <- (l1.1 + l1.2 + l1.3 + l1.4 + l1.5 + l1.6 + l1.7)

# loop over time and standardise the flux terms:
# moles/grdibox/s -> moles/m3/s
for (i in 1:length(time) ) {
net.l.std <- (net.l[,,,i]/vol) }

# calculate the 3d and 2d (deposition) loss 
o3.loss1.yrt = sum(l1.1 + l1.2 + l1.3 + l1.4 + l1.5 + l1.6 + l1.7)*conv.factor
o3.loss2.yrt = (sum(l1.8 + l1.9)  + sum(l1.10))*conv.factor

loss.ls <- c( sum(l1.1), sum(l1.2), sum(l1.3), sum(l1.4), sum(l1.5), sum(sum(l1.6) + sum(l1.7)), sum(l1.8), sum(sum(l1.9) + sum(l1.10)) ) 

# creata a map of the dry deposition (O3 + NOy)
dd.map <- (l1.8 + l1.9)
dd.map <- apply(dd.map,c(1,2),mean)

rm(l1.1);rm(l1.2);rm(l1.3);rm(l1.4);rm(l1.5);rm(l1.6);rm(l1.7);rm(l1.8)
rm(l1.9); rm(l1.10) 
gc()

ncp     <- apply( (net.p.std - net.l.std), c(2,3), mean, na.rm=T )

# subset the data so that some of the high values are omited..
ncp.90 <- ncp
ncp.90[ncp.90>=quantile(ncp, 0.95)] <- quantile(ncp, 0.95)
ncp.90[ncp.90<=quantile(ncp, 0.05)] <- quantile(ncp, 0.05)

ncp.map <- apply( (net.p - net.l), c(1,2), mean, na.rm=T )

# ################################################################################
# Write these values on the plot

o3.netchem <-  o3.prod.yrt - o3.loss1.yrt 
ste.inf    <-  o3.prod.yrt - o3.loss1.yrt - o3.loss2.yrt

# diagnosed STE (moles/grid cell/s), if present
qid2 <- var_exists(nc1, ste.code)
if ( identical(TRUE,qid2) ) {
ste.diag <- ncvar_get(nc1, ste.code) * mask
ste.diag <- sum(ste.diag)*conv.factor
} else {
  ste.diag = -999.
}

# nice format for output
ox.prod    <- sprintf("%1.3g", (o3.prod.yrt) )
ox.loss    <- sprintf("%1.3g", (o3.loss1.yrt) )
ox.loss.dd <- sprintf("%1.3g", (o3.loss2.yrt) )
ox.netchem <- sprintf("%1.3g", (o3.prod.yrt - o3.loss1.yrt) )
ste.inf    <- sprintf("%1.3g", (o3.prod.yrt - o3.loss1.yrt - o3.loss2.yrt)*-1.0 ) # To get a positive flux
ox.prod    <- sprintf("%1.3g", (o3.prod.yrt) )
ste.diagn  <- sprintf("%1.3g", (ste.diag) )

# Calc the burden in Tg
if ( exists("o3.burden") == TRUE) print("Tropospheric Ozone burden exists, carrying on") else (source("get_trop_o3_burden.R"))

tau.o3     <- sprintf("%1.3g", ((o3.burden/(o3.loss1.yrt + o3.loss2.yrt))*360) ) # convert to days
# ################################################################################
# some extra bits and bobs for the plot

# set a nice scale
minmax <- function (x) pmax( max(x), abs(min(x)) )
zlim <- c(-minmax(ncp.90), minmax(ncp.90))

# find index of hgt which is greater than 20 km's 
hindex   <- which((hgt/1000.)>20)[1]
# ###################################################################################################################################
pdf(file=paste(out_dir,"/",mod1.name,"_ox_budget.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

# overplot the data 
image.plot(lat, hgt[1:hindex]/1000, ncp.90[,1:hindex], xlab="Latitude (degrees)", ylab="Altitude (km)", 
main=paste("UKCA",mod1.name,"Ox Net Chemical Production", sep=" "), 
zlim=zlim, col=heat.cols(23) )
# add tropopause
if ( L_plot_troppse ) lines(lat, ht, lwd=2, lty=2)

par(xpd=T)
text(x=-60,y=20, paste("Ox Prod = ", ox.prod, "Tg/yr", sep="") )
text(x=-60,y=19, paste("Ox Loss = ", ox.loss, "Tg/yr", sep="") )
text(x=-60,y=18, paste("Ox Net  = ", ox.netchem, "Tg/yr", sep="") )
text(x= 50,y=19, paste("STE inferred = ",  ste.inf, "Tg/yr", sep="") )
text(x= 50,y=18, paste("STE diag.    = ",  ste.diagn, "Tg/yr", sep="") )
text(x= 60,y=17, paste("Lifetime = ",  tau.o3, "days", sep="") )

par(xpd=F)

dev.off()

# ###################################################################################################################################
# set lims
zlim <- c(0, minmax(dd.map))

# find the index for the mid latitude in the array
midlon <- which(lon>=180.0)[1]
maxlon <- length(lon)
dellon <- lon[2]-lon[1]
# reform array - makes it look nicer on map
dd.map <- abind(dd.map[midlon:maxlon,], dd.map[1:midlon-1,], along=1)

pdf(file=paste(out_dir,"/",mod1.name,"_ox_dep_map.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)
# overplot the data 
image.plot(seq(-180,(180-dellon),dellon), lat, dd.map, xlab="Longitude (degrees)", ylab="Latitude (degrees)", 
main=paste("UKCA Ox deposition",mod1.name, sep=" "), 
zlim=zlim, col=col.cols(23) )
map("world", add=T)

par(xpd=T)
text(x=-90,95, paste("Total Ox Deposition = ", ox.loss.dd, " Tg/yr", sep="") )

par(xpd=F)

dev.off()

# delete arrays ########
rm(net.l); rm(net.l.std)
rm(net.p); rm(net.p.std)
rm(dd.map)
gc()

# ###################################################################################################################################
pdf(file=paste(out_dir,"/",mod1.name,"_ox_budget_sources_sinks.pdf", sep=""),width=8,height=6,paper="special",onefile=TRUE,pointsize=12)

par(mfrow=c(1,2))

lbls1   <- c("HO2+NO", "MeO2+NO", "RO2+NO", "Other")
pct     <- round(prod.ls/sum(prod.ls)*100)
lbls    <- paste(lbls1, pct) # add percents to labels
lbls    <- paste(lbls,"%",sep="") # ad % to labels

bp <- barplot(pct, names.arg=lbls1, col=rainbow(length(lbls1)), las=2, ylab = "Contribution (%)", xlab="", ylim=c(0,75),
main=paste(mod1.name, "Production of Tropospheric Ox", sep=" ") )
grid()
box()
text(bp, 0, round(pct, 1),cex=1,pos=3)

lbls1   <- c("O1D+H2O", "Minor", "HO2+O3", "OH+O3", "O3+Alk", "NxOy", "O3dry", "NOydep")
pct     <- round(loss.ls/sum(loss.ls)*100)
lbls    <- paste(lbls1, pct) # add percents to labels
lbls    <- paste(lbls,"%",sep="") # ad % to labels

bp <- barplot(pct, names.arg=lbls1, col=rainbow(length(lbls1)), las=2, ylab = "Contribution (%)", xlab="", ylim=c(0,50), 
main=paste(mod1.name, "Loss of Tropospheric Ox", sep=" ") )
grid()
box()
text(bp, 0, round(pct, 1),cex=1,pos=3)

dev.off()

