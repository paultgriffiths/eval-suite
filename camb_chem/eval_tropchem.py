#!/usr/bin/env python

# This script launches R programs to evaluate model output 
# mainly for Tropospheric Chem parameters

# Arguments:
# Requires 12 UM monthly mean pp files (full path) as argument.

# Version-1 : MohitD - Dec 2012, based on routines from Alex/Cambridge.
# Version-2 : MohitD - May 2015, use Iris for ppfile extraction.

from sys import path as syspath

import os
from subprocess import *

#syspath.append('/home/h02/hadzm/eval_v2')     # Top level folder
#syspath.append('/home/mdalvi/eval_v2')   # Top folder Postproc
syspath.append('/home/users/mcdalvi/eval_v2')     # Top level folder
from lib.eval_utils import *

# Machine specfic settings
#scr_dir = '/home/h02/hadzm/eval_v2/camb_chem/'
                                           # Script dir
#obs_dir= '/data/users/hadzm/EvalData/Obs'        # Base for Obs data
#geo_dir= '/data/users/hadzm/EvalData/plotting'   # Res dependant data dir
                                               # (area/volume/orog)
#rusr_lib= '/home/h02/hadzm/R/x86_64-redhat-linux-gnu-library/3.0' 
                                               # R user-installed libs
#PP_NC= '/home/h02/hadzm/test/pptonc/extr_pp_nc_m.py' 
                                               # PPtoNC conversion scr

# Machine specfic settings- Postproc
#scr_dir = '/home/mdalvi/eval_v2/camb_chem/'
                                           # Script dir
#obs_dir= '/projects/ukca-meto/mdalvi/EvalData/Obs'   # Base for Obs data
#geo_dir= '/projects/ukca-meto/mdalvi/EvalData/plotting'  
                                               # Res dependant data dir
                                               # (area/volume/orog)
#rusr_lib= '/home/mdalvi/R/x86_64-redhat-linux-gnu-library/3.0' 
                                               # R user-installed libs
#PP_NC= '/home/mdalvi/test/pptonc/extr_pp_nc_m.py' 
                                               # PPtoNC conversion scr

# Machine specfic settings - JASMIN
scr_dir = '/home/users/mcdalvi/eval_v2/camb_chem/'
                                           # Script dir
obs_dir= '/gws/nopw/j04/ukca_vol1/mcdalvi/EvalData/Obs'
                                           # Base for Obs data
geo_dir= '/gws/nopw/j04/ukca_vol1/mcdalvi/EvalData/plotting'   
                                           # Res dependant data dir
                                           # (area/volume/orog)
rnc_lib= '/usr/lib64'                      # NetCDF libs for R
rusr_lib= '/home/users/mcdalvi/R/x86_64-redhat-linux-gnu-library/o3.5' 
                                          # R user-installed libs
PP_NC= '/home/users/mcdalvi/utils/pptonc/extr_pp_nc_m.py' 
                                          # PPtoNC conversion scr

# Default settings
out_dir = 'Plots_TC'                   # Default output dir
ofile_suffix= '_evaluation_output.nc'  # Suffix for NetCDF intermed file
slist= scr_dir+'stash_eval_sec50.lst'  # STASH codes required
trlist= scr_dir+'tr_codes_iris.R'      # R-->NetCDF var mapping  
run_type= 'CheST'                      # Req for some analysis
main_rscr= 'ukca_evaluation_v2.R'      # Top Script name
rset_file= 'R_paths'                   # Run Settings File
okfile= 'Rsuccess'                     # file to check R success
 # Diagnostic scale factor - to account for differences in UKCA call 
 #   frequency and STASH sampling frequency
scale_factor = 3.0                     # default - every 3 timesteps

#------------------ End Settings -------------------------#

# %%%%%%%%%%%%%%%%%%%%%%% Main Script %%%%%%%%%%%%%%%%%%%%%

if __name__ == '__main__' :

    # Arguments/ help setup
    from optparse import OptionParser
    agparse = OptionParser()
    usage = "%prog -i <ppfiles> [-s STASHlist] "+\
        "[-m trmap] [-f scale_fac] [--eval_only] [--noclean]"
    agparse = OptionParser(usage=usage)
    agparse.add_option('-i',dest="ppfile",
        action='callback',callback = argm_callback,
        help='Required: ppfiles (12) from year to analyse -full path-')
    agparse.add_option('-s',dest="stashlist",default=" ",
        help='Optional: STASHcodes list, '+\
              'e.g. if model run is pre-vn8.5')
    agparse.add_option('-m',dest="stashmap",default=" ",
        help='Optional :Stash-Variable name mapping file, '+\
              'e.g. if model run is pre-vn8.5')
    agparse.add_option('-f',dest="scale_fac",default=3.0,
        help='Optional :Diagnostic Scale factor, '+\
         'to account for UM:UKCA call frequency (default=3.0 for 1:3)')
    agparse.add_option("--eval_only", action="store_true", 
        dest="eval_only",default='False',
        help='Optional: Only carry out Evaluation, skipping the extraction. '+\
             ' Useful when extract is ok but evaluation has failed previously')
    agparse.add_option("--noclean", action="store_true", 
        dest="noclean",default='False',
        help='Optional: Do not delete extracted NetCDF data after completion')

    (options, args) = agparse.parse_args() 

    # Check arguments - at least 12 pp files, full path

    if options.ppfile == None or \
      len(options.ppfile) < 12 :
       agparse.print_help()
       exit(1)

    if '../' in options.ppfile[0]:
       log_msg('Relative path detected. Pl. specify full'+\
                    ' path for input files.\n')
       exit(2)       

    # Process optional arguments
    stmap = ""
    if options.stashmap != " ":
       stmap = " -m "+options.stashmap 

    if options.stashlist != " ":
       slist = options.stashlist 

    scale_factor = options.scale_fac
    log_msg(' +++ Scaling Reaction fluxes by '+str(scale_factor)+\
                   ' for UM:UKCA call freq difference +++ ')
    log_msg(' +++ This factor can be changed by using -f option +++ ')
    
## ------------ Part-1: Preprocessing ---------------------

    # Extract job-id from name of sample file
    fname = os.path.basename(options.ppfile[0])
    jobid = fname[0:5]

    # create temporary data & plot directory 
    out_dir = os.getcwd() +'/'+ out_dir +'/'+ jobid
    if not os.path.exists(out_dir):
       try:
          os.makedirs(out_dir)
       except:
          log_msg('ERROR creating output folder '+out_dir)
          log_msg('Check permissions.')
          exit(3)

    okfile= out_dir+'/'+okfile
    if os.path.isfile(okfile) :
       os.remove(okfile)    # Delete success file if exists

    rlog = out_dir+'/R.log'
    out_file = out_dir+'/'+jobid+ofile_suffix

    # If only Evaluation is requested, check that nc file exists
    if options.eval_only == True:
      if not os.path.isfile(out_file) :
         log_msg(' ERROR: Eval_only specified, but NetCDF file missing')
         log_msg(' Looking for: '+out_file+'\n')
         exit(4)
    else:                    # Do extraction step         
      if os.path.isfile(out_file) :
         os.remove(out_file)    # Delete data file if exists

      # Extract required fields to NetCDF using iris script
      log_msg('******* Extracting fields from model output *******')
      log_msg('   This will take some time (upto ~30 minutes) \n')

      # Call PP->NC script to extract --need to unravel list as strings
      # Multi-annual monthly means by default
      pnclog = out_dir+'/pp2nc.log'
      infiles = ''
      for fl in options.ppfile:
         infiles = infiles+' '+fl
      convcmd = PP_NC+' -i '+infiles+' -o '+out_file+' -s '+slist\
                    +stmap+' --monthly >'+pnclog+' 2>&1 '
      #log_msg(convcmd)
      ret = call(convcmd,shell=True)
      if ret < 0:
        log_msg('Error executing pptonc '+str(-ret))
        exit(5)

      if not os.path.isfile(out_file):
        log_msg('Error extracting to NetCDF. See '+pnclog+'\n')
        exit(6)

      log_msg('**** Preprocessing completed *****\n')

##--------------------- PART 2: RUN EVALUATION -------------------------

    log_msg('**** Beginning Analysis *****\n')
    # Environment settings for R. Append to LD_LIB_PATH if one exists
    try:
       os.environ["LD_LIBRARY_PATH"] = os.environ["LD_LIBRARY_PATH"]+':'+rnc_lib
    except:
       os.environ["LD_LIBRARY_PATH"] = rnc_lib
    #os.environ["R_LIBS"] = os.environ["R_LIBS"]+':'+rusr_lib
    os.environ["R_LIBS"] = rusr_lib
    os.environ["R_LIBS_USER"] = rusr_lib
    os.environ["PATHS_FILE"] = rset_file
    os.environ["R_SCRDIR"] = scr_dir

    # Create runtime settings file for R (sourced by main_scr)
    f = open(rset_file,'w')
    f.write('\n')

    rcmd = 'mod1.name <- "'+jobid+'"'
    f.write(rcmd+'\n')

    rcmd = 'mod1.datafile <- "'+out_file+'"'
    f.write(rcmd+'\n')

    rcmd = 'scr_dir <- "'+scr_dir+'"'
    f.write(rcmd+'\n')

    rcmd = 'tr_codes <- "'+trlist+'"'
    f.write(rcmd+'\n')

    rcmd = 'obs_dir <- "'+obs_dir+'"'
    f.write(rcmd+'\n')

    rcmd = 'geo_dir <- "'+geo_dir+'"'
    f.write(rcmd+'\n')

    rcmd = 'out_dir <- "'+out_dir+'"'
    f.write(rcmd+'\n')

    rcmd = 'r_log <- "'+rlog+'"'
    f.write(rcmd+'\n')

    rcmd = 'flux_scale_fac <- '+str(scale_factor)
    f.write(rcmd+'\n')

    f.close()

    # Actual R command
    rcmd = 'R CMD BATCH --no-save --no-restore '+scr_dir+'/'+main_rscr
    #rcmd = '/project/ukmo/rhel6/R/R-3.3.1/bin/R CMD BATCH --no-save --no-restore '+scr_dir+'/'+main_rscr
    ret = call(rcmd,shell=True)

    # Check for presence of file denoting completion
    if os.path.isfile(okfile) :
       log_msg ('   Done: Plots will be found in '+out_dir+'\n')
    # ~~~~~ remove batch file if successful ~~~~~~
       os.remove(rset_file)
    # ~~~~~ remove intermediate NetCDF file unless specified ~~~~~~~
       if options.noclean == False:
          os.remove(out_file)
    else:
       log_msg ('  ERROR in Analysis with R '+str(-ret)+'\n' )
       log_msg ('  Check for errors in '+rlog)
       log_msg ('    and in '+main_rscr+'.out \n')
       exit(7)

    log_msg('  Check '+rlog+' for any warnings')
# End Main

