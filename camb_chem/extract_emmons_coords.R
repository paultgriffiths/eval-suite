# R code to extract model co-ords from observation data
# Alex Archibald, January 2012

# ############################## functions to extract the data ##############################################################################
# extract the longitudes
get.lon  <- function(data) { as.numeric(subset(obs.dat, short.name == data, select=lon.min) ) }
get.dlon <- function(data) { as.numeric(round(( (subset(obs.dat, short.name == data, select=lon.max)) - (subset(obs.dat, short.name == data, select=lon.min)) )/dlon) ) }
find.lon <- function(min.lon) { as.numeric( ifelse ( min.lon<0, (round( ((min.lon+360)/dlon)-0.5))+1, (round( ((min.lon/dlon)-0.5) ))+1  ) ) }

# extract the latitudes
get.lat  <- function(data) { as.numeric( subset(obs.dat, short.name == data, select=lat.min) ) }
get.dlat <- function(data) { as.numeric( round(( (subset(obs.dat, short.name == data, select=lat.max)) - (subset(obs.dat, short.name == data, select=lat.min)) )/dlat) ) }
find.lat <- function(min.lat) { as.numeric( (round (  ((min.lat +90)/dlat)  ))+1 ) } 

# extract the dates
find.mon <- function(data) { as.numeric(format((subset(obs.dat, short.name == data, select=start.date )), format = "%m")) }
del.mon <- function(data) { (as.numeric(format((subset(obs.dat, short.name == data, select=end.date )), format = "%m")) ) - 
                            (as.numeric(format((subset(obs.dat, short.name == data, select=start.date )), format = "%m")) ) }

# generate some new variables based on the data that is being requested
# in this case data is the short.name of the aircraft campaign being analysed
lon1   <- NULL
lat1   <- NULL
mon    <- NULL
d.mon  <- NULL
d.lon1 <- NULL
d.lat1 <- NULL

# set the variables 
  lon1   <- find.lon(get.lon(data)) 
  d.lon1 <- get.dlon(data) 
  lat1   <- find.lat(get.lat(data)) 
  d.lat1 <- get.dlat(data) 
  mon    <- find.mon(data) 
  d.mon  <- del.mon(data)

# some checks to get rid of 0's -- not elegent
if (lon1 == 0 )    lon1 <- 1
if (d.lon1 == 0 )  d.lon1 <- 1
if (lat1 == 0 )    lat1 <- 1
if (d.lat1 == 0 )  d.lat1 <- 1
if (mon == 0 )     mon <- 1
if (d.mon == 0 )   d.mon <- 1


