# R script to extract and plot up Emmons type data
# Alex Archibald, CAS, January 2012

conv  <- 1E9 # units in ppb or ppt

data <- "intex.na.ec"
source("extract_emmons_coords.R")
intex.na.ec.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
intex.na.ec.mod.m1 <- apply(intex.na.ec.mod.1,c(3),quantile)

data <- "intex.na.ct"
source("extract_emmons_coords.R")
intex.na.ct.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
intex.na.ct.mod.m1 <- apply(intex.na.ct.mod.1,c(3),quantile)

data <- "intex.na.ne"
source("extract_emmons_coords.R")
intex.na.ne.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
intex.na.ne.mod.m1 <- apply(intex.na.ne.mod.1,c(3),quantile)

data <- "intex.na.wc"
source("extract_emmons_coords.R")
intex.na.wc.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
intex.na.wc.mod.m1 <- apply(intex.na.wc.mod.1,c(3),quantile)

data <- "op3"
source("extract_emmons_coords.R")
op3.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
op3.mod.m1 <- apply(op3.mod.1,c(3),quantile)

data <- "pem.t.b.ci"
source("extract_emmons_coords.R")
pem.t.b.ci.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
pem.t.b.ci.mod.m1 <- apply(pem.t.b.ci.mod.1,c(3),quantile)

data <- "pem.t.b.t"
source("extract_emmons_coords.R")
pem.t.b.t.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
pem.t.b.t.mod.m1 <- apply(pem.t.b.t.mod.1,c(3),quantile)

data <- "pem.w.b.j"
source("extract_emmons_coords.R")
pem.w.b.j.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
pem.w.b.j.mod.m1 <- apply(pem.w.b.j.mod.1,c(3),quantile)

data <- "trace.a.e.b"
source("extract_emmons_coords.R")
trace.a.e.b.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
trace.a.e.b.mod.m1 <- apply(trace.a.e.b.mod.1,c(3),quantile)

data <- "trace.a.e.b"
source("extract_emmons_coords.R")
trace.a.e.b.c.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
trace.a.e.b.c.mod.m1 <- apply(trace.a.e.b.c.mod.1,c(3),quantile)

data <- "trace.a.s.af"
source("extract_emmons_coords.R")
trace.a.s.af.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
trace.a.s.af.mod.m1 <- apply(trace.a.s.af.mod.1,c(3),quantile)

data <- "trace.a.w.a.c"
source("extract_emmons_coords.R")
trace.a.w.a.c.mod.1 <- ncvar_get(nc1,co.code,start=c(lon1,lat1,1,mon),count=c(d.lon1,d.lat1,60,d.mon))*(conv/mm.co)
trace.a.w.a.c.mod.m1 <- apply(trace.a.w.a.c.mod.1,c(3),quantile)

# ################## read obs ##################################################### #
intex.na.ec.data <- read.table(paste(obs_dir,"INTEX-NA/INTEX-NA_EC_co.stat",sep="/"))
intex.na.ec.dat.sd1 = intex.na.ec.data$V5 + intex.na.ec.data$V6
intex.na.ec.dat.sd2 = intex.na.ec.data$V5 - intex.na.ec.data$V6

intex.na.ct.data <- read.table(paste(obs_dir,"INTEX-NA/INTEX-NA_CT_co.stat",sep="/"))
intex.na.ct.dat.sd1 = intex.na.ct.data$V5 + intex.na.ct.data$V6
intex.na.ct.dat.sd2 = intex.na.ct.data$V5 - intex.na.ct.data$V6

intex.na.ne.data <- read.table(paste(obs_dir,"INTEX-NA/INTEX-NA_NE_co.stat",sep="/"))
intex.na.ne.dat.sd1 = intex.na.ne.data$V5 + intex.na.ne.data$V6
intex.na.ne.dat.sd2 = intex.na.ne.data$V5 - intex.na.ne.data$V6

intex.na.wc.data <- read.table(paste(obs_dir,"INTEX-NA/INTEX-NA_WC_co.stat",sep="/"))
intex.na.wc.dat.sd1 = intex.na.wc.data$V5 + intex.na.wc.data$V6
intex.na.wc.dat.sd2 = intex.na.wc.data$V5 - intex.na.wc.data$V6

op3.data <- read.csv(paste(obs_dir,"OP3/OP3_co.stat",sep="/"), header = F, skip=1)
op3.dat.sd1 = op3.data$V5 + op3.data$V6
op3.dat.sd2 = op3.data$V5 - op3.data$V6

pem.t.b.ci.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/PEM-Tropics-B/PEM-Tropics-B_P3_co_Christmas-Island.stat",sep="/"))
pem.t.b.ci.dat.sd1 = pem.t.b.ci.data$V5 + pem.t.b.ci.data$V6
pem.t.b.ci.dat.sd2 = pem.t.b.ci.data$V5 - pem.t.b.ci.data$V6

pem.t.b.t.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/PEM-Tropics-B/PEM-Tropics-B_P3_co_Tahiti.stat",sep="/"))
pem.t.b.t.dat.sd1 = pem.t.b.t.data$V5 + pem.t.b.t.data$V6
pem.t.b.t.dat.sd2 = pem.t.b.t.data$V5 - pem.t.b.t.data$V6

pem.w.b.j.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/PEM-West-B/PEM-West-B_DC-8_co_Japan.stat",sep="/"))
pem.w.b.j.dat.sd1 = pem.w.b.j.data$V5 + pem.w.b.j.data$V6
pem.w.b.j.dat.sd2 = pem.w.b.j.data$V5 - pem.w.b.j.data$V6

trace.a.e.b.data <- trace.a.e.b.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/TRACE-A/TRACE-A_DC-8_co_E-Brazil.stat",sep="/"))
trace.a.e.b.dat.sd1 = trace.a.e.b.data$V5 + trace.a.e.b.data$V6
trace.a.e.b.dat.sd2 = trace.a.e.b.data$V5 - trace.a.e.b.data$V6

trace.a.e.b.c.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/TRACE-A/TRACE-A_DC-8_co_E-Brazil-Coast.stat",sep="/"))
trace.a.e.b.c.dat.sd1 = trace.a.e.b.c.data$V5 + trace.a.e.b.c.data$V6
trace.a.e.b.c.dat.sd2 = trace.a.e.b.c.data$V5 - trace.a.e.b.c.data$V6

trace.a.s.af.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/TRACE-A/TRACE-A_DC-8_co_S-Africa.stat",sep="/"))
trace.a.s.af.dat.sd1 = trace.a.s.af.data$V5 + trace.a.s.af.data$V6
trace.a.s.af.dat.sd2 = trace.a.s.af.data$V5 - trace.a.s.af.data$V6

trace.a.w.a.c.data <- read.table(paste(obs_dir,"measurements/emmons_data/regional/TRACE-A/TRACE-A_DC-8_co_W-Africa-Coast.stat",sep="/"))
trace.a.w.a.c.dat.sd1 = trace.a.w.a.c.data$V5 + trace.a.w.a.c.data$V6
trace.a.w.a.c.dat.sd2 = trace.a.w.a.c.data$V5 - trace.a.w.a.c.data$V6

# ################ Plot data ###################################################### #
# output
pdf(file=paste(out_dir,"/",mod1.name,"_Emmons_CO_Multi.pdf",sep=""),width=16,height=24,pointsize=24)
#
par(mfrow=c(4,3))
par(oma=c(0,0,1,0)) 
par(mgp = c(2, 1, 0))

plot(intex.na.ec.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="intex.na.ec",1]), format(obs.dat[obs.dat$short.name=="intex.na.ec",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="intex.na.ec",5]), "-", (obs.dat[obs.dat$short.name=="intex.na.ec",6]),
"Lon", (obs.dat[obs.dat$short.name=="intex.na.ec",7]), "-", (obs.dat[obs.dat$short.name=="intex.na.ec",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (intex.na.ec.data$V5-intex.na.ec.data$V6), intex.na.ec.data$V1, (intex.na.ec.data$V5+intex.na.ec.data$V6), intex.na.ec.data$V1, length = 0.0, code =2 )
polygon(c(intex.na.ec.dat.sd1, rev(intex.na.ec.dat.sd2)), c(intex.na.ec.data$V1, rev(intex.na.ec.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(intex.na.ec.data$V5, intex.na.ec.data$V1, lwd=1.5)
# add model1
polygon(c(intex.na.ec.mod.m1[4,1:hgt.10], rev(intex.na.ec.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(intex.na.ec.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,intex.na.ec.data$V1+0.1, intex.na.ec.data$V2, las=2)
grid()

legend("topleft", c(mod1.name), lwd=2, col=c("red2"), bty="n", cex=0.85 )
title(main="\nEmmons CO comparison",outer=T, col.main="red")

plot(intex.na.ct.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="intex.na.ct",1]), format(obs.dat[obs.dat$short.name=="intex.na.ct",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="intex.na.ct",5]), "-", (obs.dat[obs.dat$short.name=="intex.na.ct",6]),
"Lon", (obs.dat[obs.dat$short.name=="intex.na.ct",7]), "-", (obs.dat[obs.dat$short.name=="intex.na.ct",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (intex.na.ct.data$V5-intex.na.ct.data$V6), intex.na.ct.data$V1, (intex.na.ct.data$V5+intex.na.ct.data$V6), intex.na.ct.data$V1, length = 0.0, code =2 )
polygon(c(intex.na.ct.dat.sd1, rev(intex.na.ct.dat.sd2)), c(intex.na.ct.data$V1, rev(intex.na.ct.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(intex.na.ct.data$V5, intex.na.ct.data$V1, lwd=1.5)
# add model1
polygon(c(intex.na.ct.mod.m1[4,1:hgt.10], rev(intex.na.ct.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(intex.na.ct.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,intex.na.ct.data$V1+0.1, intex.na.ct.data$V2, las=2)
grid()

plot(intex.na.ne.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="intex.na.ne",1]), format(obs.dat[obs.dat$short.name=="intex.na.ne",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="intex.na.ne",5]), "-", (obs.dat[obs.dat$short.name=="intex.na.ne",6]),
"Lon", (obs.dat[obs.dat$short.name=="intex.na.ne",7]), "-", (obs.dat[obs.dat$short.name=="intex.na.ne",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (intex.na.ne.data$V5-intex.na.ne.data$V6), intex.na.ne.data$V1, (intex.na.ne.data$V5+intex.na.ne.data$V6), intex.na.ne.data$V1, length = 0.0, code =2 )
polygon(c(intex.na.ne.dat.sd1, rev(intex.na.ne.dat.sd2)), c(intex.na.ne.data$V1, rev(intex.na.ne.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(intex.na.ne.data$V5, intex.na.ne.data$V1, lwd=1.5)
# add model1
polygon(c(intex.na.ne.mod.m1[4,1:hgt.10], rev(intex.na.ne.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(intex.na.ne.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,intex.na.ne.data$V1+0.1, intex.na.ne.data$V2, las=2)
grid()

plot(intex.na.wc.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="intex.na.wc",1]), format(obs.dat[obs.dat$short.name=="intex.na.wc",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="intex.na.wc",5]), "-", (obs.dat[obs.dat$short.name=="intex.na.wc",6]),
"Lon", (obs.dat[obs.dat$short.name=="intex.na.wc",7]), "-", (obs.dat[obs.dat$short.name=="intex.na.wc",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (intex.na.wc.data$V5-intex.na.wc.data$V6), intex.na.wc.data$V1, (intex.na.wc.data$V5+intex.na.wc.data$V6), intex.na.wc.data$V1, length = 0.0, code =2 )
polygon(c(intex.na.wc.dat.sd1, rev(intex.na.wc.dat.sd2)), c(intex.na.wc.data$V1, rev(intex.na.wc.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(intex.na.wc.data$V5, intex.na.wc.data$V1, lwd=1.5)
# add model1
polygon(c(intex.na.wc.mod.m1[4,1:hgt.10], rev(intex.na.wc.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(intex.na.wc.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,intex.na.wc.data$V1+0.1, intex.na.wc.data$V2, las=2)
grid()

plot(op3.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="op3",1]), format(obs.dat[obs.dat$short.name=="op3",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="op3",5]), "-", (obs.dat[obs.dat$short.name=="op3",6]),
"Lon", (obs.dat[obs.dat$short.name=="op3",7]), "-", (obs.dat[obs.dat$short.name=="op3",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (op3.data$V5-op3.data$V6), op3.data$V1, (op3.data$V5+op3.data$V6), op3.data$V1, length = 0.0, code =2 )
polygon(c(op3.dat.sd1, rev(op3.dat.sd2)), c(op3.data$V1, rev(op3.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(op3.data$V5, op3.data$V1, lwd=1.5)
# add model1
polygon(c(op3.mod.m1[4,1:hgt.10], rev(op3.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(op3.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,op3.data$V1+0.1, op3.data$V2, las=2)
grid()

plot(pem.t.b.ci.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="pem.t.b.ci",1]), format(obs.dat[obs.dat$short.name=="pem.t.b.ci",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="pem.t.b.ci",5]), "-", (obs.dat[obs.dat$short.name=="pem.t.b.ci",6]),
"Lon", (obs.dat[obs.dat$short.name=="pem.t.b.ci",7]), "-", (obs.dat[obs.dat$short.name=="pem.t.b.ci",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (pem.t.b.ci.data$V5-pem.t.b.ci.data$V6), pem.t.b.ci.data$V1, (pem.t.b.ci.data$V5+pem.t.b.ci.data$V6), pem.t.b.ci.data$V1, length = 0.0, code =2 )
polygon(c(pem.t.b.ci.dat.sd1, rev(pem.t.b.ci.dat.sd2)), c(pem.t.b.ci.data$V1, rev(pem.t.b.ci.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(pem.t.b.ci.data$V5, pem.t.b.ci.data$V1, lwd=1.5)
# add model1
polygon(c(pem.t.b.ci.mod.m1[4,1:hgt.10], rev(pem.t.b.ci.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(pem.t.b.ci.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,pem.t.b.ci.data$V1+0.1, pem.t.b.ci.data$V2, las=2)
grid()

plot(pem.t.b.t.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="pem.t.b.t",1]), format(obs.dat[obs.dat$short.name=="pem.t.b.t",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="pem.t.b.t",5]), "-", (obs.dat[obs.dat$short.name=="pem.t.b.t",6]),
"Lon", (obs.dat[obs.dat$short.name=="pem.t.b.t",7]), "-", (obs.dat[obs.dat$short.name=="pem.t.b.t",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (pem.t.b.t.data$V5-pem.t.b.t.data$V6), pem.t.b.t.data$V1, (pem.t.b.t.data$V5+pem.t.b.t.data$V6), pem.t.b.t.data$V1, length = 0.0, code =2 )
polygon(c(pem.t.b.t.dat.sd1, rev(pem.t.b.t.dat.sd2)), c(pem.t.b.t.data$V1, rev(pem.t.b.t.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(pem.t.b.t.data$V5, pem.t.b.t.data$V1, lwd=1.5)
# add model1
polygon(c(pem.t.b.t.mod.m1[4,1:hgt.10], rev(pem.t.b.t.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(pem.t.b.t.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,pem.t.b.t.data$V1+0.1, pem.t.b.t.data$V2, las=2)
grid()

plot(pem.w.b.j.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="pem.w.b.j",1]), format(obs.dat[obs.dat$short.name=="pem.w.b.j",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="pem.w.b.j",5]), "-", (obs.dat[obs.dat$short.name=="pem.w.b.j",6]),
"Lon", (obs.dat[obs.dat$short.name=="pem.w.b.j",7]), "-", (obs.dat[obs.dat$short.name=="pem.w.b.j",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (pem.w.b.j.data$V5-pem.w.b.j.data$V6), pem.w.b.j.data$V1, (pem.w.b.j.data$V5+pem.w.b.j.data$V6), pem.w.b.j.data$V1, length = 0.0, code =2 )
polygon(c(pem.w.b.j.dat.sd1, rev(pem.w.b.j.dat.sd2)), c(pem.w.b.j.data$V1, rev(pem.w.b.j.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(pem.w.b.j.data$V5, pem.w.b.j.data$V1, lwd=1.5)
# add model1
polygon(c(pem.w.b.j.mod.m1[4,1:hgt.10], rev(pem.w.b.j.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(pem.w.b.j.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,pem.w.b.j.data$V1+0.1, pem.w.b.j.data$V2, las=2)
grid()

plot(trace.a.e.b.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="trace.a.e.b",1]), format(obs.dat[obs.dat$short.name=="trace.a.e.b",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="trace.a.e.b",5]), "-", (obs.dat[obs.dat$short.name=="trace.a.e.b",6]),
"Lon", (obs.dat[obs.dat$short.name=="trace.a.e.b",7]), "-", (obs.dat[obs.dat$short.name=="trace.a.e.b",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (trace.a.e.b.data$V5-trace.a.e.b.data$V6), trace.a.e.b.data$V1, (trace.a.e.b.data$V5+trace.a.e.b.data$V6), trace.a.e.b.data$V1, length = 0.0, code =2 )
polygon(c(trace.a.e.b.dat.sd1, rev(trace.a.e.b.dat.sd2)), c(trace.a.e.b.data$V1, rev(trace.a.e.b.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(trace.a.e.b.data$V5, trace.a.e.b.data$V1, lwd=1.5)
# add model1
polygon(c(trace.a.e.b.mod.m1[4,1:hgt.10], rev(trace.a.e.b.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(trace.a.e.b.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,trace.a.e.b.data$V1+0.1, trace.a.e.b.data$V2, las=2)
grid()

plot(trace.a.e.b.c.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="trace.a.e.b.c",1]), format(obs.dat[obs.dat$short.name=="trace.a.e.b.c",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="trace.a.e.b.c",5]), "-", (obs.dat[obs.dat$short.name=="trace.a.e.b.c",6]),
"Lon", (obs.dat[obs.dat$short.name=="trace.a.e.b.c",7]), "-", (obs.dat[obs.dat$short.name=="trace.a.e.b.c",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (trace.a.e.b.c.data$V5-trace.a.e.b.c.data$V6), trace.a.e.b.c.data$V1, (trace.a.e.b.c.data$V5+trace.a.e.b.c.data$V6), trace.a.e.b.c.data$V1, length = 0.0, code =2 )
polygon(c(trace.a.e.b.c.dat.sd1, rev(trace.a.e.b.c.dat.sd2)), c(trace.a.e.b.c.data$V1, rev(trace.a.e.b.c.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(trace.a.e.b.c.data$V5, trace.a.e.b.c.data$V1, lwd=1.5)
# add model1
polygon(c(trace.a.e.b.c.mod.m1[4,1:hgt.10], rev(trace.a.e.b.c.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(trace.a.e.b.c.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,trace.a.e.b.c.data$V1+0.1, trace.a.e.b.c.data$V2, las=2)
grid()

plot(trace.a.s.af.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="trace.a.s.af",1]), format(obs.dat[obs.dat$short.name=="trace.a.s.af",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="trace.a.s.af",5]), "-", (obs.dat[obs.dat$short.name=="trace.a.s.af",6]),
"Lon", (obs.dat[obs.dat$short.name=="trace.a.s.af",7]), "-", (obs.dat[obs.dat$short.name=="trace.a.s.af",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (trace.a.s.af.data$V5-trace.a.s.af.data$V6), trace.a.s.af.data$V1, (trace.a.s.af.data$V5+trace.a.s.af.data$V6), trace.a.s.af.data$V1, length = 0.0, code =2 )
polygon(c(trace.a.s.af.dat.sd1, rev(trace.a.s.af.dat.sd2)), c(trace.a.s.af.data$V1, rev(trace.a.s.af.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(trace.a.s.af.data$V5, trace.a.s.af.data$V1, lwd=1.5)
# add model1
polygon(c(trace.a.s.af.mod.m1[4,1:hgt.10], rev(trace.a.s.af.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(trace.a.s.af.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,trace.a.s.af.data$V1+0.1, trace.a.s.af.data$V2, las=2)
grid()

plot(trace.a.w.a.c.mod.m1[3,1:hgt.10], hgt[1:hgt.10], type = "o", pch=13, col="white", lwd=1,xlab="CO (ppb)",
ylab="Altitude /km", 
main=paste( (obs.dat[obs.dat$short.name=="trace.a.w.a.c",1]), format(obs.dat[obs.dat$short.name=="trace.a.w.a.c",3], "%Y %m"), "\n", 
"Lat", (obs.dat[obs.dat$short.name=="trace.a.w.a.c",5]), "-", (obs.dat[obs.dat$short.name=="trace.a.w.a.c",6]),
"Lon", (obs.dat[obs.dat$short.name=="trace.a.w.a.c",7]), "-", (obs.dat[obs.dat$short.name=="trace.a.w.a.c",8]) ) ,
xlim=c(25,150))
# add obs
arrows( (trace.a.w.a.c.data$V5-trace.a.w.a.c.data$V6), trace.a.w.a.c.data$V1, (trace.a.w.a.c.data$V5+trace.a.w.a.c.data$V6), trace.a.w.a.c.data$V1, length = 0.0, code =2 )
polygon(c(trace.a.w.a.c.dat.sd1, rev(trace.a.w.a.c.dat.sd2)), c(trace.a.w.a.c.data$V1, rev(trace.a.w.a.c.data$V1)), border=NA, col=rgb(169/256,169/256,169/256,0.5) )
lines(trace.a.w.a.c.data$V5, trace.a.w.a.c.data$V1, lwd=1.5)
# add model1
polygon(c(trace.a.w.a.c.mod.m1[4,1:hgt.10], rev(trace.a.w.a.c.mod.m1[2,1:hgt.10])), c(hgt[1:hgt.10], rev(hgt[1:hgt.10])), border=NA, col=rgb(255/256,0,0,0.5) )
lines(trace.a.w.a.c.mod.m1[3,1:hgt.10], hgt[1:hgt.10], lwd=1.5, col="red2")
axis(4,trace.a.w.a.c.data$V1+0.1, trace.a.w.a.c.data$V2, las=2)
grid()

dev.off()
