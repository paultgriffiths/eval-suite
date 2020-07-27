# R functions for use in UKCA evaluation
# Alex Archibald, NCAR/NCAS/University of Cambridge, September 2013

# With contributions from, Oliver Squire, Zadie Stock and Christoph Knote

# Called from ukca_evaluation.R
# requires:
# nc1 to be defined
# lat.dim.name, lon.dim.name, hgt.dim.name and time.dim.name

# function to go through the netCDF file and extract the longitude dimension
getLon <- function(ncfile){
  lon.dim.name <- ifelse(names(ncfile$dim)[1]=="longitude", "longitude", "lon")
  lon <- get.var.ncdf(ncfile, lon.dim.name)
  return(lon)
}

# function to go through the netCDF file and extract the longitude dimension
getLat <- function(ncfile){
  lat.dim.name <- ifelse(names(ncfile$dim)[2]=="latitude", "latitude", "lat")
  lat <- get.var.ncdf(ncfile, lat.dim.name)
  return(lat)
}

# function to go through the netCDF file and extract the vertical dimension
getAlt <- function(ncfile){
  alt.dim.name <- ifelse(names(ncfile$dim)[3]=="hybrid_ht", "hybrid_ht", "levels")
  alt <- get.var.ncdf(ncfile, alt.dim.name)
  return(alt)
}

# function to go through the netCDF file and extract the time dimension - assume it's the last!
getDate <- function(ncfile){
  time.dim.name <- ifelse(names(ncfile$dim)[length(ncfile$dim)]=="time", "time", "t")
  time <- get.var.ncdf(ncfile, time.dim.name)
  date <- as.Date(time, origin=strsplit(ncfile$dim$time$units, "since ")[[1]][2])
  return(date)
}


getColor <- function(value,cols,breaks) {
  # Function for finding the color interval of a value
  # based on the current plotting paramaters. 
  # Used for overplotting coloured points on a map.
  foundIdx <- findInterval(value, breaks)
  # safe guard to be within array bounds
  foundIdx <- max(1,min(length(cols), foundIdx))
  foundCol <- cols[foundIdx]
  return(foundCol)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
interp2d <- function(old, oldlon, oldlat, newdx, newdy) {
  # R function to do 2d linear interpolation.
  # It should be able to deal with any regualr/irregular grid?!  
  require(fields)
  if(missing(newdy)) {
    message("new dy is missing, assuming dx")
    newdy <- newdx
  }
  newx <- length(seq(min(oldlon), max(oldlon), newdx))
  newy <- length(seq(min(oldlat), max(oldlat), newdy))
  interp.surface.grid(list(x=seq(nrow(old)),y=seq(ncol(old)),z=old),
                      list(x=seq(1,nrow(old),length=newx),
                           y=seq(1,ncol(old),length=newy)))$z
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
find.lon <- function (x) {
  # Function to retrieve the model grid box from an 
  # observation longitude (in degrees). NB Assumes a 
  # 360 degree longitude grid that starts at the Greenwhich Meridian.
  # Check to see if the observed longitude is < 0 
  require(ncdf)
  del.lon <- get.var.ncdf(ncfile, lon.dim.name)[2] - get.var.ncdf(ncfile, lon.dim.name)[1]
  ifelse ( x<0, (round( ((x+360)/del.lon)-0.5))+1, 
           (round( ((x/del.lon)-0.5) ))+1  )[1] 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
find.lat <- function (y) {
  # Function to retrieve the model grid box from an 
  # observation latitude (in degrees). 
  # NB Assumes a 180 degree latitude grid that starts at the South Pole.
  require(ncdf)
  del.lat <- get.var.ncdf(ncfile, lat.dim.name)[2] - get.var.ncdf(ncfile, lat.dim.name)[1]
  round (  (((y +90)/del.lat)  )+1)[1] 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
minmax <- function (x) {
  # Function to calculate the absolute max/min of an argument
  pmax( max(x), abs(min(x)) )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
filled.contour3 <-  function (x = seq(0, 1, length.out = nrow(z)),
            y = seq(0, 1, length.out = ncol(z)), z, xlim = range(x, finite = TRUE), 
            ylim = range(y, finite = TRUE), zlim = range(z, finite = TRUE), 
            levels = pretty(zlim, nlevels), nlevels = 20, color.palette = cm.colors, 
            col = color.palette(length(levels) - 1), plot.title, plot.axes, 
            key.title, key.axes, asp = NA, xaxs = "i", yaxs = "i", las = 1, 
            axes = TRUE, frame.plot = axes,mar, ...)   {  
    # modification by Ian Taylor of the filled.contour function
    # to remove the key and facilitate overplotting with contour()
    # further modified by Carey McGilliard and Bridget Ferris
    # to allow multiple plots on one page  
    if (missing(z)) {
      if (!missing(x)) {
        if (is.list(x)) {
          z <- x$z
          y <- x$y
          x <- x$x
        }
        else {
          z <- x
          x <- seq.int(0, 1, length.out = nrow(z))
        }
      }
      else stop("no 'z' matrix specified")
    }
    else if (is.list(x)) {
      y <- x$y
      x <- x$x
    }
    if (any(diff(x) <= 0) || any(diff(y) <= 0)) 
      stop("increasing 'x' and 'y' values expected")
    plot.new()
    plot.window(xlim, ylim, "", xaxs = xaxs, yaxs = yaxs, asp = asp)
    if (!is.matrix(z) || nrow(z) <= 1 || ncol(z) <= 1) 
      stop("no proper 'z' matrix specified")
    if (!is.double(z)) 
      storage.mode(z) <- "double"
    .filled.contour(as.double(x), as.double(y), z, as.double(levels), 
                            col = col)
    # changes following changes to R from version 3+
    #.Internal(filledcontour(as.double(x), as.double(y), z, as.double(levels), 
    #                        col = col))
    if (missing(plot.axes)) {
      if (axes) {
        title(main = "", xlab = "", ylab = "")
        Axis(x, side = 1)
        Axis(y, side = 2)
      }
    }
    else plot.axes
    if (frame.plot) 
      box()
    if (missing(plot.title)) 
      title(...)
    else plot.title
    invisible()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
mbe <- function(mod, obs) {
  # Mean bias error in %
  # Need to pass in vectors of model values and observed values
  mbe <- NULL
  if(length(mod)==length(obs)) {
      mbe <- (sum(mod-obs)/length(mod))/(mean(obs))*100    
  } else {
    print("Error! Mismatch between lengths of model and obs")
  }
  return(mbe)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
minor.ticks.axis <- function(ax,n,t.ratio=0.5,mn,mx,...){
  # R function for adding logorithmic minor ticks to a plot
  # Taken from http://stackoverflow.com/questions/6955440/displaying-minor-logarithmic-ticks-in-x-axis-in-r
  
  # to use do:
  # minor.ticks.axis(1,9,mn=0,mx=8)
  # where 1 refers to the axis (i.e. bottom==1,left==2,right==3,top==4)
  # where 9 refers to the number of minor tick marks
  # There are two extra parameters, mn and mx for the minimum and the maximum on the 
  # logarithmic scale (mn=0 thus means the minimum is 10^0 or 1 !)
  lims <- par("usr")
  if(ax %in%c(1,3)) lims <- lims[1:2] else lims[3:4]
  
  major.ticks <- pretty(lims,n=5)
  if(missing(mn)) mn <- min(major.ticks)
  if(missing(mx)) mx <- max(major.ticks)
  
  major.ticks <- major.ticks[major.ticks >= mn & major.ticks <= mx]
  
  labels <- sapply(major.ticks,function(i)
    as.expression(bquote(10^ .(i)))
  )
  axis(ax,at=major.ticks,labels=labels,...)
  
  n <- n+2
  minors <- log10(pretty(10^major.ticks[1:2],n))-major.ticks[1]
  minors <- minors[-c(1,n)]
  
  minor.ticks = c(outer(minors,major.ticks,`+`))
  minor.ticks <- minor.ticks[minor.ticks > mn & minor.ticks < mx]
  
  
  axis(ax,at=minor.ticks,tcl=par("tcl")*t.ratio,labels=FALSE)
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
get.nc.var <- function(nc.file, nc.var,...) {
  # R function to open netCDF file and extract variable
  require(ncdf)
  nc1 <- open.ncdf(nc.file)
  var <- get.var.ncdf(nc1, nc.var)
  print(paste("dimensions ", nc.var, cat(dim(var)) ))
  print(paste("Max ", nc.var," = ", max(var, na.rm=T)))
  print(paste("Min ", nc.var," = ", min(var, na.rm=T)))
  return(var)
}

#O3 <- get.nc.var("~/Desktop/xgywn_evaluation_output.nc", "tracer1")
#o3 <- O3[,10,1,1]
#lon <- get.nc.var("~/Desktop/xgywn_evaluation_output.nc", "longitude")
#lon2find <- c(121, 260, 5, 98)

# R function to linearly interpolate variable
approx.var <- function(var, vardim, approx2,...) {
  out <- approx(vardim, var, approx2)$y
  return(out)
}

#interp.o3 <- approx.var(o3, lon, lon2find)

re.grid.map <- function(data.array, data.lon) {
  # reformat the data to be centred on Greenwhich 
  require(abind)
  midlon <- which(data.lon>=180.0)[1]
  maxlon <- length(data.lon)
  # check for size of array
  if(length(dim(data.array))==4) {
    new.array <- abind(data.array[midlon:maxlon,,,], data.array[1:midlon-1,,,], along=1)
  }
  if(length(dim(data.array))==3) {
    new.array <- abind(data.array[midlon:maxlon,,], data.array[1:midlon-1,,], along=1)
  }
  if(length(dim(data.array))==2) {
    new.array <- abind(data.array[midlon:maxlon,], data.array[1:midlon-1,], along=1)
  }
  return(new.array)
} # end function
