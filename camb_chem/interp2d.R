# R function to do 2d linear interpolation.
# This function requires the fields package to be installed.
# It should be able to deal with any regualr/irregular grid?!

# Alex Archibald, February 2012

require(fields)

interp2d <- function(old, newx, newy) {
  interp.surface.grid(list(x=seq(nrow(old)),y=seq(ncol(old)),z=old),
                      list(x=seq(1,nrow(old),length=newx),
                           y=seq(1,ncol(old),length=newy)))$z
}

