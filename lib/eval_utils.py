'''
 Module containing common utilities required 
 for UKCA evaluation
'''

import iris
import numpy as np

from sys import path as sys_path
sys_path.append('../..')
from etc.filepaths import *

class EvalError(Exception): pass 

# General log output function
def log_msg(cmessage):
    from sys import stdout as sysout
    sysout.write('\n'+cmessage)

# directory for stash=name maps
UKCA_DICT = {}
l_filled_ukca_dict = False

def get_stashc(cvar,stashmap):
   """Return the STASH code of given field name"""

   """
     Method:
      Read a standard stash_mapping file and return the stashcode
      corresponding to passed field name
     Arguments:
      cvar : Field name as string
      stashmap: Variable name - Stashcode mapping file

     Returns:
      STASH code as integer (for now m01sNNiXXX format)
   """ 

   # Check stash mappin file exists and is accessible
   try:
       sf = open(stashmap, 'r')
   except:
       raise EvalError("GetStashc:Error opening mapping file: {}"\
                       .format(stashmap))

   # File format
   # Line1 : Header/ version info
   # Line2--LineN: field_name = stashcode (ssiii)
   
   dline = sf.readline()  # skip
   for line in sf:
     dline = line.split()  # remove blanks
     if len(dline) != 3:
       log_msg('GetStashc:Incorrect format at '+dline[0]+'. Continuing.')
       continue
     if cvar == dline[0]:
       if int(dline[2]) <= 999:   # Sec0 item 
          sec = 0
          itm = int(dline[2])
       else:                      # Derive Sec and Item no.
          sec = int(dline[2])/1000
          itm = int(dline[2])%1000

      # Need to convert between int <-> str to ensure formatting
       return 'm01s'+str(sec).zfill(2)+'i'+str(itm).zfill(3)

   #End Loop over lines
   
   # If we are here, the item was not found
   log_msg(cvar)  #debug
   raise EvalError('GetStashc:Stashcode for '+cvar+\
                     ' not in mapping file.')

# End Def get_stashc 

def gen_stash_dict(stashmap):
   """
     Generate dictionary of stash = attributes for UKCA
   """

   """
     Output Structure:
     UKCA_DICT = {
       stashcode1 :
        { 'cube_name': short name,
          'long_name': long_name,
          'units': units
         },
       stashcode2 :
   """
 
   try:
      f = open(stashmap,'r')
   except:
      raise Evalerror('STASHmap file {} not found'.format(stashmap))

   # Output file -option available if faster
   ##fo = open('ukca_dict.py','w')

   dline = f.readline()  # copy header
   ##fo.write(dline)
   
   global UKCA_DICT 
   ##fo.write("UKCA_DICT = { \n")
   for line in f:
      dline = line.split()  # remove blanks

      UKCA_DICT[dline[0]] = { 'short_name': dline[1], \
        'long_name': dline[2], 'units': dline[3] }
    
      ##fo.write("  '"+dline[0]+"' : \n")
      ##fo.write("     { 'short_name': '"+dline[1]+"', \n")
      ##fo.write("       'long_name': '"+dline[2]+"', \n")
      ##fo.write("       'units': '"+dline[3]+"', \n")
      ##fo.write("     }, \n")
    
   f.close()
        
   ##fo.write("   } \n")
   ##fo.close

   return UKCA_DICT

# End def gen_stash_dict

def ukca_callback( cube, field, filename):
   """
     Add name,units, etc to UKCA fields not recognised by Iris
   """

   # Populate UKCA fields dictionary if not already done
   global l_filled_ukca_dict
   global UKCA_DICT
   if not l_filled_ukca_dict:
     UKCA_DICT = gen_stash_dict(stash_map_file)
     l_filled_ukca_dict = True

   stcode = str( cube.attributes['STASH'] )
   cname = cube.name()

   if cname.lower() == 'unknown':

     # Extract information from user dictionary
     if stcode in UKCA_DICT :
       var_attrib = UKCA_DICT[stcode]
       cube.rename(var_attrib['short_name'])
       cube.long_name = var_attrib['long_name']
       cube.units = var_attrib['units']
 
# End def ukca_callback 

def argm_callback(option, opt_str, value, parser):
   """
      Callback function to enable reading of multiple arguments
      into a single variable (e.g. list of files).
      Adapted from example in Python docs --> optparser section.
   """
   value = []

   for arg in parser.rargs:
      # stop on next option (-o,-s,-m)
      if arg[:1] == "-" and len(arg) > 1:
         break
      value.append(arg)

      # remove copied args from command-line
      # and populate destination variable
   del parser.rargs[:len(value)]
   setattr(parser.values, option.dest, value)

#end def argm_callback

def extract_cube_monthmean(infile,stash_codes):
   """ Extract specified fields, with multi-annual meaning if req """
    
   import iris.coord_categorisation as ircat
   # For easier categorisation of data into months

   # Extract fields and check --if less than 12, flag Error
   #   If more than (and multiple of) 12, derive multi-annual 
   #   monthly means and return
  
   fieldcons = []     # List of stash constraints
   for spc in stash_codes:
      fieldcons.append(iris.AttributeConstraint(STASH=spc))
        
   incubes = iris.load(infile,constraints = fieldcons,callback=ukca_callback)

   #### ---- For now, expect the coordinate to be called 'time' ----
   #####  %%% Future --use Iris terminology for 'first dimension' -need to find example  -- %%%%
   tdim = incubes[0].coord('time').shape[0]     
   log_msg('*** TDIM : {:d} months of data detected. ****'.format(tdim))
   if tdim < 12:
     raise Evalerror(
      'EXTR_CUBE: Atleast 12 (month) records expected. Found {:d}'.format(tdim) )
   # If records/ files > 12 and multiple of 12, attempt multi-annual meaning
   if tdim > 12 :
     if tdim % 12 != 0:
        raise Evalerror('EXTR_CUBE: Expected multiple of 12 (months).'+\
                           ' Found {:d}'.format(tdim) )

     log_msg('EXTR_CUBE: '+str(tdim/12)+' years of data detected.')
     log_msg(' Performing multi-annual mean\n')
     
     oucubes = []      # output cube list
     for n, cb in enumerate(incubes):
       # Add artificial/ auxilliary dim 'month' and average over this.
       # First check if this dimension already exists
       try:
         dumm = cb.coord('month')
       except:     
          # not found --add. %%%% Again assuming coord called 'time' %%%%%%
         ircat.add_month(cb, 'time', name='month')
                                
       incubes[n] = cb.aggregated_by('month', iris.analysis.MEAN)
   
   return incubes    
# End def extract_cube_monthmean

def coord_remove(incube,coord_name):
  """ Remove a specified (mostly auxillary) coordinate from cube """

  try:
     cord = incube.coord(coord_name)
     incube.remove_coord(coord_name)
  except:
     a = 1  # Do nothing

  return incube
# End def coord_remove

def get_gridbox_vol(incube):
  """ Calculate grid-box volumes for input cube """

  import iris.analysis.cartography as icarto

  if incube.ndim < 3:
    raise TC_error('GET_VOL: Cube must have at least 3 dimensions')

  # Array for grid box areas. Same for all levels so can
  # work on 2-D cube 
  if incube.ndim == 4:
    tcube = incube[0,0,:,:]
  else:
    tcube = incube[0,:,:]

  if not tcube.coord('latitude').has_bounds():
    tcube.coord('latitude').guess_bounds()
  if not tcube.coord('longitude').has_bounds():
    tcube.coord('longitude').guess_bounds()

  grid_areas = icarto.area_weights(tcube)
  tcube = 'a'

  nlat = incube.coord('latitude').shape[0]
  nlong = incube.coord('longitude').shape[0]
  nlevs = incube.coord('level_height').shape[0]

  # Obtain grid top-boundary heights, so that subtracting from lower
  # will give height of each grid-box (horizontally uniform)
  grid_top = np.zeros(nlevs+1, dtype=np.float32)
  grid_top[1:] = incube.coord('level_height').bounds[:,1] # top bound

  # Volume -area x height, always 3-D array (lat,long,hgt)
  vol_box = np.zeros([nlevs,nlat,nlong],dtype=np.float)

  for l in np.arange(nlevs):
    vol_box[l,:,:] = grid_areas[:,:] * (grid_top[l+1] - grid_top[l])

  # Setup coords and generate a cube from computed values
  dm_long = incube.coord('longitude')
  dm_lat  = incube.coord('latitude')
  dm_lev  = incube.coord('model_level_number')
  aux_hgt = incube.coord('level_height')

  oucube = iris.cube.Cube( vol_box,
             var_name='grid_cell_volume',units='m^3',
             dim_coords_and_dims=[(dm_lev,0),(dm_lat,1),(dm_long,2)],
             attributes= {'Source':'Derived from grid_area and level_height'} )
  
  oucube.add_aux_coord(incube.coord('level_height'),0)
    
  vol_box = np.zeros(1,dtype=np.int)
  return oucube

# End Def get_gridbox_vol

def vinterp_ht_pr_3d(src_cube,p_src,p_targ, min_value = 0.0):
   """ Interpolate 3-d data from heights onto pressure levels """
   
   """ 
     Arguments:
     src_cube = cube that has to be mapped
     p_src    = cube containing pressure at each level of src_cube
     p_targ   = Target pressure levels (array-same units as p_src)
     Returns:
     cube with src_cube data on p_target levels
   """ 
    
   # Create output cube = copy of src cube with new levels
   # ****** Assume 3-D data for now *******
   if src_cube.ndim != 3:
        raise Evalerror('VINTERP_HT_PR3D: only 3-D data (long,lat,lev) can be processed.')

   slat = src_cube.coord('latitude')
   nlat = slat.shape[0] 
   slong = src_cube.coord('longitude')
   nlon = slong.shape[0] 
   # Verify that pressures values are on same grid 
   n_plat = p_src.coord('latitude').shape[0]
   n_plon = p_src.coord('longitude').shape[0]
      
   if nlon != n_plon or nlat != n_plat:
      raise Evalerror('VINTERP_HT_PR3D: Input data and pressures not on the same grid')
        
   nplev = len(p_targ) 
   # define pressure level dimension
   out_plev = iris.coords.DimCoord(p_targ,
                   standard_name='air_pressure',units=p_src.units) 
         
   # output cube         
   cube_out = iris.cube.Cube( np.zeros((nplev,nlat,nlon), np.float),
                  dim_coords_and_dims=[(out_plev,0),(slat,1),(slong,2)] ) 
   
   cube_out.rename(src_cube.name()+'_on_pressure_levels') 
   cube_out.units = src_cube.units 
   cube_out.attributes = src_cube.attributes
   
   cube_out.data[:,:,:] = min_value
   
   lpsrc = np.log(p_src.data)      # Use logP for interpolation
   lptarg = np.log(p_targ)
   
   # Find position of each p_targ among each column of p_src 
   for y in range(nlat):
     for x in range(nlon):
       
       alpha = np.zeros(nplev,dtype=np.float32)  # Interp coefficient
       lev1 = 1      # source data level to start search from --- optimisation
                
       for n, p_this in enumerate(lptarg):
         for cl in range(lev1,len(lpsrc)):
           p1 = lpsrc[cl-1,y,x]   # pressure below
           p2 = lpsrc[cl,y,x]
                  
           if p_this < p1 and p_this >= p2:
             alpha[n] = (p_this - p1) / (p2 - p1)
                  
             cube_out.data[n,y,x] =  src_cube.data[cl-1,y,x] + \
                             ( (src_cube.data[cl,y,x] - src_cube.data[cl-1,y,x]) * alpha[n] )
             lev1 = cl      # assume decreasing pressure in src and targ, so no need to search
                            # for next pressure in levels lower than the last one --optimisation
             break
         # End loop over source pressures
                                
         if cube_out.data[n,y,x] < min_value:
               cube_out.data[n,y,x] = min_value
       # End loop over target pressures
     # End loop over latitude
   # End loop over longitude
   lpsrc = 0         # free some mem
   lptarg = 0
    
   return cube_out
# End Def vinterp_ht_pr_3d

def vinterp_ht_pr_zm(src_cube,p_src,p_targ, min_value = 0.0):
   """ Interpolate 2-d data from heights onto pressure levels """
   
   """ 
     Arguments:
     src_cube = cube that has to be mapped
     p_src    = cube containing pressure at each level of src_cube
     p_targ   = Target pressure levels (array-same units as p_src)
     Returns:
     cube with src_cube data on p_target levels
   """ 
    
   # Create output cube = copy of src cube with new levels
   # ****** Assume 2-D data - zonal mean *******
   if src_cube.ndim != 2:
        raise Evalerror('VINTERP_HT_PR_ZM: only 2-D data (lat,lev) can be processed.')

   slat = src_cube.coord('latitude')
   nlat = slat.shape[0] 
  
   # Verify that pressures values are on same grid 
   n_plat = p_src.coord('latitude').shape[0]
   if nlat != n_plat:
      raise Evalerror('VINTERP_HT_PR_ZM: Input data and pressures not on the same grid')
        
   nplev = len(p_targ) 
   # define pressure level dimension
   out_plev = iris.coords.DimCoord(p_targ,
                   standard_name='air_pressure',units=p_src.units) 
         
   cube_out = iris.cube.Cube( np.zeros((nplev,nlat), np.float),
                  dim_coords_and_dims=[(out_plev,0),(slat, 1)] ) 
   
   cube_out.rename(src_cube.name()+'_on_pressure_levels') 
   cube_out.units = src_cube.units 
   cube_out.attributes = src_cube.attributes
   cube_out.data[:,:] = min_value
   
   lpsrc = np.log(p_src.data)      # Use LogP for interpolation
   lptarg = np.log(p_targ)
   
   # Find position of each p_targ among each column of p_src 
   for y in range(nlat):
      
     alpha = np.zeros(nplev,dtype=np.float32) # interp coefficient
     lev1 = 1      # source data level to start search from --- optimisation
                
     for n, p_this in enumerate(lptarg):
       for cl in range(lev1,len(lpsrc)):
         p1 = lpsrc[cl-1,y]   # press below
         p2 = lpsrc[cl,y]
                            
         if p_this < p1 and p_this >= p2:
           alpha[n] = (p_this - p1) / (p2 - p1)
                
           cube_out.data[n,y] =  src_cube.data[cl-1,y] + \
                          ( (src_cube.data[cl,y] - src_cube.data[cl-1,y]) * alpha[n] )
           lev1 = cl      # pressure  decr with n, so search for next only in levels after cl
           break
       # End loop over source pressures
                                
       if cube_out.data[n,y] < min_value:
            cube_out.data[n,y] = min_value
       # End loop over target pressures
   # End loop over latitude
   lpsrc = 0
   lptarg = 0
    
   return cube_out
# End Def vinterp_ht_pr_zm

def regrid_zm_cube(src_cube,targ_grid, min_value = 0.0):
   """ Map 2-D (Zonal Mean) data from one grid to another """
   
   """ 
     Arguments:
     src_cube = cube that has to be regridded
     targ_grid = cube containing target grid information
     Returns:
     cube with src_cube data regridded on target grid
   """ 
    
   # Create output cube = copy of src cube same levels but new grid 
   # ****** Assume 2-D data - zonal mean, so check **********
   slat = src_cube.coords(axis='y',dim_coords=True)  #src latitude coordinate
   if src_cube.ndim < 2 or len(slat) == 0 :
      raise Evalerror('REGRID_ZM_CUBE: Expecting atleast 2-D (lat,lev) data.')

   src_lat = slat[0].points        # source latitude points
                                   # Use slat[0] as cube.coords() returns a list
   tlat = targ_grid.coord('latitude')       # target latitude coordinate
   nlat = tlat.shape[0] 
   targ_lat = tlat.points          # array of target latitude values
        
   out_lev, = src_cube.coords(axis='z', dim_coords=True)    # Level coordinate
   nlev = out_lev.shape[0]   
   
   #   check if source data has time coordinate, so create 3-D cube
   tcoord = src_cube.coords(axis='t',dim_coords=True)
   if len(tcoord) == 1:
      ntime=tcoord[0].shape[0]
      cube_out = iris.cube.Cube( np.zeros( (ntime,nlev,nlat), np.float ),
                  dim_coords_and_dims=[(tcoord[0],0),(out_lev,1),(tlat,2)] ) 
   else:
      cube_out = iris.cube.Cube( np.zeros( (nlev,nlat), np.float ),
                  dim_coords_and_dims=[(out_lev,0),(tlat,1)] ) 
   
   cube_out.rename(src_cube.name())
   cube_out.units = src_cube.units 
   cube_out.attributes = src_cube.attributes
   cube_out.data[...] = min_value

   # Find position of each target latitude among src_lat array
   index_l = np.searchsorted(src_lat, targ_lat, side='left')

   alpha = np.zeros(nlat,dtype=np.float32)  # interp coefficient
   nslat = len(src_lat)
   for n, this_lat in enumerate(targ_lat):
      if index_l[n]+1 < nslat :
        if index_l[n] > 0:
          cl = index_l[n]-1   # cell to left
        else:
          cl = index_l[n]

        cr = cl + 1          # cell to right
        if this_lat == src_lat[cl]:   # exact match left
          alpha[n] = 0.
        elif this_lat == src_lat[cr]:
          alpha[n] = 1.
        else:
          alpha[n] = (this_lat - src_lat[cl]) / (src_lat[cr]- src_lat[cl])
            
      # use factor to grid data from src to target grid 
      # --*** Assumption: Latitude points same for all levels ****
      cube_out.data[...,n] = ( src_cube.data[...,cr] * alpha[n] ) + \
                            ( src_cube.data[...,cl] * (1. - alpha[n]) )
   # End loop over lat
         
   return cube_out
# End Def regrid_zm_cube       

 
