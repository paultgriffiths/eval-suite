# R control file used to run various
# model obs comparison scripts, useful for model evaluation.

# Alex Archibald, CAS, February 2012
# Mohit Dalvi, Met Office, Sep-2012 - Moved path information
#   to calling script. Sources a file $PATH_FILE for this.

# ##############################################################

#    ##   ##   ##   #   ######       ##
#    ##   ##   ##  #    ######     ##  ##
#    ##   ##   ## #     ##        ##    ##
#    ##   ##   ###      ##       ##      ##
#    ##   ##   ###      ##       ###########
#    #######   ## ##    ######   ##       ## 
#    #######   ##  ##   ######   ##       ##

# ##############################################################

# load the required libraries for the evaluation.
# These should be installed on the Linux system
library(ncdf)
library(abind)
library(fields)
library(plotrix)
library(maps)
library(gdata)
#library(gdata,lib.loc="/home/h02/hadzm/R/x86_64-redhat-linux-gnu-library/3.0")

# Required variables -- and variable names (NOT stash codes):
# latitude (degrees) -- latitude
# longitude (degrees) -- longitude
# height (m) -- hybrid_ht
# time (days) -- t

# Source file containing run-time parameters, paths, etc
source(Sys.getenv("PATHS_FILE"))

# Set working directory to script directory so all scripts are visible
swd = Sys.getenv("R_SCRDIR")
# print(swd)
setwd(swd)

# Create Log file
sink(r_log, append=FALSE, split=FALSE)

# The following variables will be required for input. The model resolution is 
# flexible, however, the scripts will require 12 months of ouput 
# (as monthly means) and that the following variables are ouput on the model 
# grid (vertical hybrid_ht as z co-ord).
# Now specified from calling script -default or user-defined
#source("tracer_var_codes_n.R")
source(tr_codes)

# set the fraction of CH4 in model run (can get from UMUI)
f.ch4 <- 9.75E-7
# ##############################################################

# give locations of netcdf files for input
print(paste("file is ",mod1.datafile))
nc1 <- open.ncdf(mod1.datafile, readunlim=FALSE) 

# set the directory where the R scripts are saved
run.path <- getwd()

# ##############################################################
# Determine type of run (Trop/Strat) as some parameters only in Strat
# Crude way, based on parameter search
qid1 <- varid.inq.ncdf(nc1, clo.code)
qid2 <- varid.inq.ncdf(nc1, n2o.code)

mod1.type <- "CheST"           # assume default
if ( qid1 + qid2  < 0 ) mod1.type <- "CheT"   # Trop only

# source a list of the molecular masses used in UKCA for tracers
source("get_mol_masses.R")

# Load grid related data (area,box vol, etc)
source("load_grid_info.R")

# set plotting colors
o3.col.cols  <- colorRampPalette(c("purple", "lightblue", "green", "yellow", "orange", "red","darkred"))
col.cols  <- colorRampPalette(c("white","purple", "lightblue", "green", "yellow", "orange", "red"))
temp.cols <- colorRampPalette(c("white","blue","green","yellow","red"))
heat.cols <- colorRampPalette(c("blue","white", "red"))
ecmwf.cols <- colorRampPalette(c("blue", "green", "white", "yellow", "red"))
cool.cols <- colorRampPalette(c("red","white", "blue"))
tau.cols  <- colorRampPalette(c("white", "yellow", "red"))
lgt.cols  <- colorRampPalette(c("white","mistyrose", "lightblue", "green", "yellow", "orange", "red"))
# ##############################################################

# Select which plots you want to make.

# plot zonal mean sp. humidity against ERA data
#  source("plot_zonal_mean_q_ERA_eval.R")

# plot tropospheric OH Lawrence style?
#  source("plot_trop_oh_lawrence_eval.R")
# source("plot_trop_oh_lawrence_eval_fix.R")

# plot Emmons type plots?
#  source("plot_UKCA_Emmons_eval.R")

# plot the tropospheric Ox budget?
# source("plot_ox_budget_eval.R")

# plot the tropospheric methane lifetime?
mmid <- varid.inq.ncdf(nc1, air.mass.watm )
#if ( mmid > 0 ) {
#  source("plot_tau_ch4_eval.R")
#} else {
#  print(paste("ERROR: Whole Air mass diagnostic 50-063 not in output"))
# print("PLOT_TAU_CH4 not called")
# pdf(file=paste(out_dir,"/",mod1.name,"_tau_ch4.pdf", sep=""))
# dev.off()
#}

# Only for stratospheric runs
#if ( (mod1.type=="CheS") | (mod1.type=="CheST") ) { 
# plot the age of air?
#source("plot_age_of_air_eval.R")

# plot zonal ClO?
#qid2 <- varid.inq.ncdf(nc1, clo.code)
# if ( qid2 > 0 ) {
# source("plot_zonal_mean_clo_eval.R")
#}
# }   # Run type = Stratospheric

# plot CO CMDL comparison
#  source("plot_CO_CMDL_eval.R")

# plot o3 against Tilme 2011 ozonesonde data
#  source("plot_tilmes_eval.R")

# plot model profiles against Sat data?
#  source("plot_tracer_profiles_eval.R")

# Plot tropospheric O3 column vs OMI
  source("plot_trop_o3_col_eval.R")

# Plot NO2 column vs OMI
#  source("plot_trop_no2_col_eval.R")

# Plot Lightning NOx
#mmid <- varid.inq.ncdf(nc1, lgt.em.code )
#if ( mmid > 0 ) {
#  source("plot_lightning_nox_eval.R")
#} else {
#  print(paste("INFO: Lightning NOx not plotted as diagnostic 50-081 not in output"))
#}
# Create file to denote success--i.e. having reached so far
# Existing file deleted externally
file.create(paste(out_dir,"Rsuccess",sep="/"))

# Close log file
sink()

q()
