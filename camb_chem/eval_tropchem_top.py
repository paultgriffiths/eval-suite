#!/usr/bin/env python2.7

# This script launches the main TropChem Evaluation script as a 
# batch job on the Lotus server

# Arguments:
# Requires the names of 12 UM monthly mean pp files (full path) as argument.

from sys import path as syspath
from sys import stdout as sysout
from subprocess import *
import random
import os
syspath.append('/home/users/mcdalvi/eval_v2')     # Top level folder
from lib.eval_utils import *

# Machine specfic settings
main_scr = '/home/users/mcdalvi/eval_v2/camb_chem/eval_tropchem.py'
                                           # Main Script

# Job file --random element to allow multiple eval 
# processes by user.
jid = str(random.randint(100,999))
jobfile = 'eval_'+jid+'.sub'

#------------------ End Settings -------------------------#

# %%%%%%%%%%%%%%%%%%%%%%% Main Script %%%%%%%%%%%%%%%%%%%%%

if __name__ == '__main__' :

    # Arguments/ help setup
    from optparse import OptionParser
    agparse = OptionParser()
    usage = "%prog -i <ppfiles> [-s STASHlist] "+\
            "[-m trmap] [--eval_only] [--noclean]"
    agparse = OptionParser(usage=usage)
    agparse.add_option('-i',dest="ppfile",
        action='callback',callback = argm_callback,
        help='Required: ppfiles (12) from year to analyse -full path-')
    agparse.add_option('-s',dest="stashlist",default=" ",
        help='Optional: STASHcodes list, '+\
              'if UKCA items differ from vn9.2 STASHmaster')
    agparse.add_option('-m',dest="trmaps",default=" ",
        help='Optional :Var<->STASH mapping file, '+\
              'if UKCA items differ from vn9.2 STASHmaster')
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
    optargs = ""
    if options.trmaps != " ":
       optargs = optargs + " -m " + options.trmaps 
    
    if options.stashlist != " ":
       optargs = optargs + " -s " + options.stashlist 

       optargs = optargs + " -f " + str(options.scale_fac)

    if options.eval_only == True:
       optargs = optargs + " --eval_only"

    if options.noclean == True:
       optargs = optargs + " --noclean"

    # Get current location to specify log files
    inidir = os.getenv('PWD')
    logfile = inidir+'/'+jid+'.log'

    # Warning about methane lifetime script fixes.
    print ' '
    print ' %%%%%%%%%%%%%%%%%%%%% WARNING %%%%%%%%%%%%%%%%%%%%%%%%%% '
    print ' '
    print '  A fix has been added to the  CH4 lifetime calculation   '
    print '  which can increase the modelled values significantly.   '
    print '  Please keep this in mind while comparing with runs      '
    print '  evaluated prior to 11-Oct-2017 or repeat evaluation for '
    print '  the previous runs.                                      '
    print ' '
    print ' Note: The CH4_lifetime script will now only work if the  '
    print '       Whole Atmosphere Air mass diagnostic (50-063) was  '
    print '       requested in model output via STASH                '
    print ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% '
    print ' '

    # Create Lotus job submission file 
    f = open(jobfile,'w')
    f.write('#!/bin/bash\n')

    f.write('#BSUB -o '+logfile+'\n')
    f.write('#BSUB -e '+logfile+'\n')
    f.write('#BSUB -q short-serial\n')
    f.write('#BSUB -W 06:00\n')

    #  Main command
    ppfiles = ''    # Need to unravel ppfiles as a string 
    for fl in options.ppfile:
      ppfiles = ppfiles+' '+fl

    bcmd = main_scr + ' -i' + ppfiles + ' ' + optargs
    f.write('\n'+bcmd+'\n')

    f.close()

    # Actual job submit command
    bcmd = 'bsub -q short-serial -o tropeval_'+jid+'.out < '+jobfile
    #print bcmd
    ret = call(bcmd,shell=True)
    if ret == 0:
      print '**  Job submitted. Check for status with '+\
              'command `bjobs`.'
      print '**  Log files : tropeval_'+jid+'.out, '+logfile+' and \n'+\
            'in the ./Plots_TC/<jobid> folder'
    else:
      print '  ERROR in Job submission. '
# End Main

