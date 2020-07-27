# Functions, routines specific to TOMS and HALOE analysis

import numpy as np
import numpy.ma as ma
import scipy.stats as scistat
import matplotlib.pyplot as plt
import iris
#import iris.quickplot as qplt
import iris.plot as iplt

from lib.eval_utils import *

class TH_error(Exception): pass

def get_niwa_obs(o3_file, conv_fact=1.0e6, monthly_mean=True):
   """ Reads NIWA data and returns as monthly means, if requested """
    
   # o3_file - expects NetCDF data
   niwao3, = iris.load(o3_file)

   # Apply any conversion requested - default :mole/mole volume to ppmv
   niwao3.data = niwao3.data * conv_fact  

   if monthly_mean:
        
      # Collapse data to multi-annual monthly mean
      # Add 'month' aux coord and tag records by months
      #  for easier meaning over the years.
      #  --verified with explicit meaning at sample pts
       import iris.coord_categorisation as ircat

       ircat.add_month(niwao3, 'time', name='month')
       niwao3m = niwao3.aggregated_by('month', iris.analysis.MEAN)
       niwao3m.rename(niwao3.name()) 
       return niwao3m
   else:
       return niwao3
# End Def get_niwa_o3

def get_haloe_obs(filename,glat,plevs,species=None,nmonth=12,minval=0.0):
   """ Read HALOE data from ascii files """
    
   """
       Arguments:
       filename : Ascii file for required parameter
       glat : 1xnlat array of latitude coordinates
       plevs: 1xnplev array of pressure heights
       species: optional - Name of the species read in
       nmonth: optional - num of time records - default 12
       minval : optional -reset values in cells to be >= this.
       Returns:
       Cube with HALOE values for given species
   """          
   
   if not species:
     species = 'haloe_Unknown'

   try:
      f = open(filename, 'r')
   except:
      raise TH_error('ERROR opening HALOE datafile: '.format(filename))

   haloe = f.read()        # Reads whole file as a string
   f.close()
   haloe = haloe.split()   # remove white spaces from input string 
                
   d = np.zeros([nmonth,len(glat),len(plevs)],dtype=np.float32)
   ad = np.zeros([nmonth,len(plevs),len(glat)],dtype=np.float32)
   i = 0
   for l in range(len(plevs)):
    for y in range(len(glat)):   
     for t in range(nmonth):
       d[t,y,l] = max(minval,float(haloe[i]))   # Convert to float values
       ad[t,l,y] = d[t,y,l]     
       i = i +1
            
   #ad = d.reshape((nmonth,len(plevs),len(glat)))  # Get to standard (t,z,y,[x]) shape
   haloe = 'a'   # free mem
   
   # Setup coords and generate a cube from input values
   dm_plev = iris.coords.DimCoord(plevs,
                 standard_name='air_pressure',units='hPa') 
   dm_glat = iris.coords.DimCoord(glat,
                 standard_name='latitude',units='-') 
   dm_time = iris.coords.DimCoord(np.arange(nmonth),
                 standard_name='time',units='month') 

   haloe_out = iris.cube.Cube(ad,var_name=species,
              attributes={'source':'HALOE '+filename},
              dim_coords_and_dims=[(dm_time,0),(dm_plev,1),(dm_glat,2)] )

   return haloe_out
# End def get_haloe_obs

# Plot species, overlaying measurement contours
def zonalplt_colcont(mod_zmval,obs_zmval,clevs,c_color,title=None,
                     ylog=False,ylimits=None):
   """ Create zonal plot with colors vs contours """
       
   cf = iplt.contourf(mod_zmval,clevs,colors=c_color)
   plot = plt.gca()
   if title:
     plot.set_title(title)
   else:
     plot.set_title('Colours-Model,Contour-Obs')

   if ylog:
     plot.set_yscale('log')         # convert Y to log
   if ylimits != None: 
     plot.set_ylim(ylimits)         # reverse if required
   plot.set_ylabel('Height (hPa)',linespacing=0.5)            
   cl = iplt.contour(obs_zmval,clevs,
             linewidths=1.0, colors='black', linestyles='-')
   plot.clabel(cl,inline=1,fmt='%1.2f',fontsize=8)

   colorbar = plt.colorbar(cf,orientation='vertical')
# End def zonalplt_colcont
   
        
def scatterplt_bands(mod_val,obs_val,xlimits=None,title=None,species=None):
   """ Scatter plot split by latitude bands """
    
   # Define latitude bands and symbols for plotting
   lat_band = [90.0, 60.0, 30.0, -30.0, -60.0, -90.0]
   band_sym = ['+','o','*','^','s']
   band_col = ['black','red','blue','magenta','green']
   band_lab = ['>60N', '30N-60N', '30S-30N', '30S-60S', '<60S']

   for l in range(1,len(lat_band)):
      bandc = iris.Constraint(latitude = lambda cell: lat_band[l-1] >= cell >= lat_band[l])
      model_grp = mod_val.extract(bandc)
      obs_grp = obs_val.extract(bandc)     
      plt.scatter(obs_grp.data.flatten(), model_grp.data.flatten(),label=band_lab[l-1],
                   marker=band_sym[l-1], facecolors='none', linewidths=0.6,
                   edgecolors=band_col[l-1])   # facecolors --> filling

   # Plot settings
   
   plot = plt.gca()
   if title:
     plot.set_title(title,fontweight='bold')

   if xlimits:
     xlims = xlimits
   else:
     xlims = [obs_val.data.min(),obs_val.data.max()]
            
   ylims = xlims
   plot.set_xlim(xlims)
   plot.set_xlabel('Obs '+species)
   plot.set_ylabel('Model '+species, linespacing=0.8)
   plot.set_ylim(ylims)
   plot.legend(loc='upper left',fontsize='small')

   # 1-to-1 line
   plot.plot(xlims,ylims,'k-')

   # Best fit line (y = mx + c)
   # scipy.stats.linregress: returns slope, intercept, r_value, p_value, std_err 
   res = scistat.linregress(obs_val.data.flatten(),mod_val.data.flatten())

   #plt.plot(xlims,xlims*res[0]+res[1],'b-')
   plot.plot(obs_val.data.flatten(),obs_val.data.flatten()*res[0]+res[1],'b-')
   # Plot stats - use x-data extents to derive location
   tx = xlims[1]*0.541
   ty1 = xlims[1]*0.06
   ty2 = xlims[1]*0.12
   r2 = 'r2 = {0:5.3f}'.format(res[2]**2)
   plot.text( tx, ty1, r2, fontweight='bold')
   stderr = 'std_err = {0:5.3f}'.format(res[4])
   plot.text( tx, ty2, stderr, fontweight='bold')
   #plt.show()

# End def scatterplt_bands

def get_toms_o3col(filename,num_years=28,num_lat=36,species='Column_Ozone',minval=0.0):
   """ Read TOMS Ozone Column data from ascii file """
    
   """
       Arguments:
       filename : Ascii file for required parameter
       num_years, num_lat : (optional) Number of years and latitude bands
             for data expected in the file -required to declare arrays
       species: optional - Name of the species read in
       minval : optional -reset values in cells to be >= this.
       Returns:
       Cube with TOMS data values for given species, averaged over months
       tyear: Years for which data is available (currently unused)
   """          
   
   vname = 'TOMS_'+species

   try:
      f = open(filename, 'r')
   except:
      raise TH_error('ERROR opening TOMS datafile: '.format(filename))

   """ Expected File Format
       YYYY TOMS + SBUV MOD Rev 02 Zonal Means
                    Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
       lat1a lat1b  V1  v2  ....
      ..........
       latna latnb
       YYYY TOMS + SBUV MOD Rev 02 Zonal Means
   """
   
   d1 = 2          # start position of o3 values in data-line (after lat bounds)
    
   # Variables to hold data 
   tyear = np.zeros(1,dtype=np.uint16)   
   nyr = 0     
   nlat = 0                     # lat-band counter         
   vlat    = np.zeros(1,dtype=np.float32)    # latitude values
   val_mon = np.zeros(12,dtype=np.float32)   # monthly data for one latitude band
   toms_in = np.zeros((num_years,12,num_lat),dtype=np.float32) # All input data
   
   first = True           # for one-time ops, eg. store lat values
   # Loop over records and extract information 
   for line in f:
     toms1 = line.split()
     if toms1[1] == 'TOMS':   # line containing year
       tyear = np.append(tyear,int(toms1[0]))
       nyr = nyr + 1         # increment num year        
       if nyr > num_years:
          raise TH_error(
           'ERROR: TOMS file has more data-years than specified (arg num_years) '
           .format(num_years) )
     elif toms1[0] == 'Jan':
       # Line with month names --do dummy work
       if nlat > 0:
         first = False
       nlat = 0            # reset lat counter
     else:                 # actual data line
       nlat = nlat + 1
       if nlat > num_lat:
         raise TH_error(
          'ERROR: TOMS file has more lat-bands than specified (num_lat) '
         .format(num_lat) )
       if first:           # Store lat coordinates
         lt = (float(toms1[0]) + float(toms1[1])) / 2. # centre of grid
         vlat = np.append(vlat,lt)
                
       for m in range(12):    # Read in oz_col values, add to input array
          val_mon[m] = float(toms1[d1+m])          
       toms_in[nyr-1,:,nlat-1] = val_mon[:] 
                           
   #log_msg('NLAT: '+str(nlat)+' NYR: '+str(nyr))
   f.close()
   
   # mask 0. values as these are missing data
   toms_in=ma.masked_values(toms_in, 0.)
   
   # Generate monthly means for each lat band
   toms_out = np.zeros((12,nlat),dtype=np.float32) # data out (month,lat)
   for m in range(12):
     for l in range(nlat):
       toms_out[m,l] = np.mean(toms_in[:,m,l]) 

   # np.mean above creates NaNs - remove them
   toms_out=ma.fix_invalid(toms_out)

   toms_in = 'a'

   # Setup coords and generate a cube from averaged file values
   dm_glat = iris.coords.DimCoord(vlat[1:],
                 standard_name='latitude',units='-') 
   dm_time = iris.coords.DimCoord(np.arange(12),
                 standard_name='time',units='month') 

   cube_out = iris.cube.Cube(toms_out,var_name=vname,units='DU',
              attributes={'source':'TOMS '+filename,
                          'Period':str(tyear[1])+'-'+str(tyear[nyr])},
              dim_coords_and_dims=[(dm_time,0),(dm_glat,1)] )
   return cube_out
#End def get_toms_o3col

def plot_niwa_haloe(mod_cube, press_cube, obsfile, month=0,obs='haloe',
                    haloe_lat=None, haloe_levs=None, obs_fact=1.0,
                    clevels=None, ccolour=None, ylog=False, x_limits=None, 
                    y_limits=None, title=None, species='spc', 
                    out_dir='None',pltfile_prefix=None):
    """ Create zonal-countour and scatter plots for spc vs Haloe or Niwa """
    
    """ Arguments:
          mod_cube  : Cube with model values
          press_cube: Cube with pressure values -for model-> press lev
          obsfile   : File with obs/measurement data
          month     : month to plot --assumes 12-monthly input
        Optional
          obs=      : Default ='haloe', can be 'niwa'
          haloe_lat=: Latitudes for Haloe data
          haloe_levs: Pressure levels for Haloe data
          obs_fact= : Any factor apply to obs (can be done outside for model)
          clevels=  : Contour levels to plot
          ccolour=  : Colour scale for filled contoours
          ylog=     : Whether to plot Y-axis as logarithmic
          x_limits= : X extents to use for scatter plot (should be > data limits)
          y_limits= : Y extents to use for Zonal plot
          title=    : Top-level title for plot
          species=  : Species name --for axis labels
          out_dir=   : Folder for output files
          pltfile_prefix= : Prefix for the output/ plot file. 
                            The month and format '.ps'
    """
    
    cmonth = { 0:'Jan', 1:'Feb', 2:'Mar', 3:'Apr', 4:'May', 5:'Jun',
           6:'Jul', 7:'Aug', 8:'Sep', 9:'Oct', 10:'Nov', 11:'Dec' }

    # Check that model and pressure cubes contain 12 (monthly) values
    if mod_cube.shape[0] != 12 :
       raise TH_error('Plot_niwa_haloe: 12 months data expected. Found '
                      .format(mod_cube.shape[0]) )
    
    # Extract measurement data --default Haloe, else Niwa if specified
    if obs == 'niwa':
       obs_cube = get_niwa_obs(obsfile, monthly_mean=True)
    else:
       obs_cube = get_haloe_obs(obsfile,haloe_lat,haloe_levs,species=species)
    
    # Apply factor if supplied
    obs_cube.data[...] = obs_cube.data[...] * obs_fact
    
    # Convert model and pressure cubes to zonal means --for specified month
    press_zm = press_cube[month,:,:,:].collapsed('longitude',iris.analysis.MEAN)
    model_zm = mod_cube[month,:,:,:].collapsed('longitude',iris.analysis.MEAN)

    # Get species onto (pressure) levels of obs data --if not already on p_levs
    try:
      dumm = mod_cube.coord('air_pressure')
      model_zmpl = model_zm
    except:
      ptarget = np.array(obs_cube.coord('air_pressure').points,dtype=np.float32)
      model_zmpl = vinterp_ht_pr_zm(model_zm,press_zm,ptarget)

    #Setup figure for plots and default titles, names
    plt.figure(figsize=(10,7.2))
    if title == None:
      ctitle = 'Model vs '+obs+' '+cmonth[month]
    else:
      ctitle = title+' '+cmonth[month]
    plt.suptitle(ctitle,x=0.7,y=0.3,fontsize=15)

    if species == None:
      species = 'spc'
    
    if pltfile_prefix == None:
      plotfile = out_dir+'/'+'model_spc_vs'+obs+'_'+cmonth[month]+'.ps'
    else:
      plotfile = out_dir+'/'+pltfile_prefix+'_'+cmonth[month]+'.ps'

    # Generate the zonal filled/ contour plot
    plt.subplot(211)
    zonalplt_colcont(model_zmpl,obs_cube[month,:,:],clevels,ccolour,
                         ylog=ylog,ylimits=y_limits)
    
    mod_zmpl_obs = regrid_zm_cube(model_zmpl,obs_cube) # Get Model zonal means on Obs grid

    # For NIWA -- Ignore values at points > 100hPa --hardwired for now
    if obs == 'niwa':
      mod_zmpl_obs = mod_zmpl_obs.extract( iris.Constraint(coord_values={'air_pressure':lambda cell: cell <= 1.0e+2}) )
      obs_mon_data  = obs_cube[month,...].extract( iris.Constraint(coord_values={'air_pressure':lambda cell: cell <= 1.0e+2}) )
    else:
      obs_mon_data = obs_cube[month,...]
        
    plt.subplot(223)
    
    #scatter plot
    scatterplt_bands(mod_zmpl_obs,obs_mon_data,xlimits=x_limits,species=species)

    plt.savefig(plotfile)
    mod_zmpl_obs = 'a'   # free mem
    obs_cube = 'a'
    obs_mon_data = 'a'

# End def plot_niwa_haloe
