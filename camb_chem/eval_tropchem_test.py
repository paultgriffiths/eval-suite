#!/usr/bin/env python2.7

# This script launches R programs to evaluate model output 
# mainly for Tropospheric Chem parameters

# Arguments:
# Requires 12 UM monthly mean pp files (full path) as argument.

# Version-1 : MohitD - Dec 2012, based on routines from Alex/Cambridge.
# Version-2 : MohitD - May 2015, use Iris for ppfile extraction.

from sys import path as syspath
from sys import stdout as sysout

import os
from subprocess import *

syspath.append('/home/h02/hadzm/eval_v2')     # Top level folder

from lib.eval_utils import *

# Machine specfic settings
scr_dir = '/home/h02/hadzm/eval_v2/camb_chem/'
                                           # Script dir
obs_dir= '/data/users/hadzm/EvalData/Obs'        # Base for Obs data
geo_dir= '/data/users/hadzm/EvalData/plotting'   # Res dependant data dir
                                               # (area/volume/orog)
rnc_lib= '/usr/local/sci/lib'                  # NetCDF libs for R
rusr_lib= '/home/h02/hadzm/R/x86_64-redhat-linux-gnu-library/3.0' 
                                               # R user-installed libs
PP_NC= '/home/h02/hadzm/test/pptonc/extr_pp_nc_m.py' 
                                               # PPtoNC conversion scr

# Machine specfic settings- Postproc
#scr_dir = '/home/mdalvi/eval_v2/camb_chem/'
                                           # Script dir
#obs_dir= '/projects/ukca-meto/mdalvi/EvalData/Obs'   # Base for Obs data
#geo_dir= '/projects/ukca-meto/mdalvi/EvalData/plotting'  
                                               # Res dependant data dir
                                               # (area/volume/orog)
#rnc_lib= '/usr/local/sci/lib'                  # NetCDF libs for R
#rusr_lib= '/home/mdalvi/R/x86_64-redhat-linux-gnu-library/3.0' 
                                               # R user-installed libs
#PP_NC= '/home/mdalvi/test/pptonc/extr_pp_nc_m.py' 
                                               # PPtoNC conversion scr

# Machine specfic settings - JASMIN
#scr_dir = '/home/users/mcdalvi/eval_v2/camb_chem/'
                                           # Script dir
#obs_dir= '/group_workspaces/jasmin2/ukca/vol1/mcdalvi/EvalData/Obs'
                                           # Base for Obs data
#geo_dir= '/group_workspaces/jasmin2/ukca/vol1/mcdalvi/EvalData/plotting'
                                           # Res dependant data dir
                                           # (area/volume/orog)
#rnc_lib= '/usr/lib64'                      # NetCDF libs for R
#rusr_lib= '/home/users/mcdalvi/R/x86_64-redhat-linux-gnu-library/3.1'
                                          # R user-installed libs
#PP_NC= '/home/users/mcdalvi/utils/pptonc/extr_pp_nc_m.py'
                                          # PPtoNC conversion scr

# Default settings
out_dir = 'Plots_TC'                   # Default output dir
ofile_suffix= '_evaluation_output.nc'  # Suffix for NetCDF intermed file
slist= scr_dir+'stash_eval_sec50.lst'  # STASH codes required
trlist= scr_dir+'tr_codes_iris.R'      # R-->NetCDF var mapping  
run_type= 'CheST'                      # Req for some analysis
main_rscr= 'ukca_evaluation_test.R'      # Top Script name
rset_file= 'R_paths'                   # Run Settings File
okfile= 'Rsuccess'                     # file to check R success
 # Diagnostic scale factor - to account for differences in UKCA call 
 #   frequency and STASH sampling frequency
scale_factor = 1.0                     # default =1 for vn10.6+
stmap103 = '/home/h02/hadzm/eval_v2/etc/ukca_stdname_vn103' 

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
    agparse.add_option('-m',dest="stashmap",default=stmap103,
        help='Optional :Stash-Variable name mapping file, '+\
              'e.g. if model run is pre-vn8.5')
    agparse.add_option('-f',dest="scale_fac",default=1.0,
        help='Optional :Diagnostic Scale factor, '+\
         'to account for UM:UKCA call frequency (e.g. 3.0 for 1:3)')
    agparse.add_option("--eval_only", action="store_true", 
        dest="eval_only",default='False',
        help='Optional: Only carry out Evaluation, skipping the extraction. '+\
             ' Useful when extract is ok but evaluation has failed previously')
    agparse.add_option("--noclean", action="store_true", 
        dest="noclean",default='False',
        help='Optional: Do not delete extracted NetCDF data after completion')

    (options, args) = agparse.parse_args() 

    # Check arguments - at least 12 pp files, full path
    #print 'Argument is ',options.ppfile
    print ' '   # readability

    if options.ppfile == None or \
      len(options.ppfile) < 12 :
       agparse.print_help()
       print ' '
       exit(1)

    if '../' in options.ppfile[0]:
       sysout.write('Relative path detected. Pl. specify full'+\
                    ' path for input files.\n')
       exit(2)       

    # Process optional arguments
    stmap = stmap103
    if options.stashmap != " ":
       stmap = " -m "+options.stashmap 

    if options.stashlist != " ":
       slist = options.stashlist 

    scale_factor = options.scale_fac
    sysout.write(' +++ Scaling Reaction fluxes by '+str(scale_factor)+\
                   ' for UM:UKCA call freq difference +++ \n')
    sysout.write(' +++ This factor can be changed by using -f option +++ \n')
    
## ------------ Part-1: Preprocessing ---------------------

    # Extract job-id from name of sample file
    fname = os.path.basename(options.ppfile[0])
    jobid = fname[0:5]
    #print 'Jobid : ',jobid

    # create temporary data & plot directory 
    out_dir = os.getcwd() +'/'+ out_dir +'/'+ jobid
    if not os.path.exists(out_dir):
       try:
          os.makedirs(out_dir)
       except:
          sysout.write('ERROR creating output folder '+out_dir)
          sysout.write('Check permissions.\n')
          exit(3)

    okfile= out_dir+'/'+okfile
    if os.path.isfile(okfile) :
       os.remove(okfile)    # Delete success file if exists

    rlog = out_dir+'/R.log'
    out_file = out_dir+'/'+jobid+ofile_suffix
    #print out_file
    # If only Evaluation is requested, check that nc file exists
    if options.eval_only == True:
      if not os.path.isfile(out_file) :
         sysout.write('\n ERROR: Eval_only specified, but NetCDF file missing')
         sysout.write(' Looking for: '+out_file+'\n')
         exit(4)
    else:                    # Do extraction step         
      if os.path.isfile(out_file) :
         os.remove(out_file)    # Delete data file if exists

      # Extract required fields to NetCDF using iris script
      sysout.write('\n******* Extracting fields from model output *******\n')
      sysout.write('   This will take some time (upto ~30 minutes) \n')

      # Call PP->NC script to extract --need to unravel list as strings
      # Multi-annual monthly means by default
      pnclog = out_dir+'/pp2nc.log'
      infiles = ''
      for fl in options.ppfile:
         infiles = infiles+' '+fl
      convcmd = PP_NC+' -i '+infiles+' -o '+out_file+' -s '+slist\
                    +stmap+' --monthly >'+pnclog+' 2>&1 '
      #print convcmd
      ret = call(convcmd,shell=True)
      if ret < 0:
        sysout.write('Error executing pptonc '+str(-ret))
        exit(5)

      if not os.path.isfile(out_file):
        sysout.write('Error extracting to NetCDF. See '+pnclog+'\n')
        exit(6)

      sysout.write('**** Preprocessing completed *****\n')

##--------------------- PART 2: RUN EVALUATION -------------------------

    sysout.write('**** Beginning Analysis *****\n')
    # Environment settings for R
    #os.environ["LD_LIBRARY_PATH"] = os.environ["LD_LIBRARY_PATH"]+':'+rnc_lib
    #os.environ["R_LIBS"] = os.environ["R_LIBS"]+':'+rusr_lib
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
       sysout.write ('   Done: Plots will be found in '+out_dir+'\n')
    # ~~~~~ remove batch file if successful ~~~~~~
       os.remove(rset_file)
    # ~~~~~ remove intermediate NetCDF file unless specified ~~~~~~~
       if options.noclean == False:
          os.remove(out_file)
    else:
       sysout.write ('  ERROR in Analysis with R '+str(-ret)+'\n' )
       sysout.write ('  Check for errors in '+rlog+'\n')
       sysout.write ('    and in '+main_rscr+'.out \n')
       exit(7)

    sysout.write('\n  Check '+rlog+' for any warnings')
# End Main

