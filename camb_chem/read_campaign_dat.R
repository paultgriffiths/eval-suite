# R script to read in campaign data
# Alex Archibald, CAS, January 2012

library(gdata) # required to trim character white space

# this data file can be added to -- just follow the format!
obs.dat <- read.csv(paste(obs_dir,"Emmons/campaign_data.csv",sep="/"))

# format data
obs.dat$start.date <- as.Date(obs.dat$start.date, format="%Y/%m/%d")
obs.dat$end.date   <- as.Date(obs.dat$end.date, format="%Y/%m/%d")
obs.dat$short.name <- trim(as.character(obs.dat$short.name))

