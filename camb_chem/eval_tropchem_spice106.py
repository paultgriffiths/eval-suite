#!/usr/bin/env python

# This script launches the main TropChem Evaluation script as a 
# batch job on the UKMO SPICE server

# Modified to match UM10.6 output from UKCA as: 
#  - Fluxes are now output on correct timestep, no need to scale
#  - STASH codes of some items have changed since vn10.3

# Arguments:
# Requires the names of 12 UM monthly mean pp files (full path) as argument.

from sys import path as syspath
from sys import stdout as sysout
from subprocess import *
import random
import os

# Machine specfic settings
main_scr = '/home/h02/hadzm/eval_v2/camb_chem/eval_tropchem.py'
test_scr = '/home/h02/hadzm/eval_v2/camb_chem/eval_tropchem_test.py'
                                           # Main Script

# Random tag element to allow multiple eval 
# processes by user.
jid = str(random.randint(100,999))

#------------------ End Settings -------------------------#

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

# %%%%%%%%%%%%%%%%%%%%%%% Main Script %%%%%%%%%%%%%%%%%%%%%

if __name__ == '__main__' :

    # Arguments/ help setup
    from optparse import OptionParser
    agparse = OptionParser()
    usage = "%prog -i <ppfiles> [-s STASHlist] "+\
            "[-m trmap] [--eval_only] [--noclean] [--test]"
    agparse = OptionParser(usage=usage)
    agparse.add_option('-i',dest="ppfile",
        action='callback',callback = argm_callback,
        help='Required: ppfiles (12) from year to analyse -full path-')
    agparse.add_option('-s',dest="stashlist",default=" ",
        help='Optional: STASHcodes list, '+\
              'if UKCA items differ from vn10.6 STASHmaster')
    agparse.add_option('-m',dest="trmaps",default=" ",
        help='Optional :Var<->STASH mapping file, '+\
              'if UKCA items differ from vn10.6 STASHmaster')
    agparse.add_option('-f',dest="scale_fac",default=1.0,
        help='Optional :Diagnostic Scale factor, '+\
         'to account for UM:UKCA call frequency (default=1.0 after vn10.6)')
    #agparse.add_option("--eval_only", action="store_true",
    #    dest="eval_only",default='False',
    #    help='Optional: Only carry out Evaluation, skipping the extraction. '+\
    #         ' Useful when extract is ok but evaluation has failed previously')
    agparse.add_option("--test", action="store_true",
        dest="run_test",default='False',
        help='Optional: Run a test version, which can be used to plot'+\
             ' only selected assessments')
    #agparse.add_option("--nocopy", action="store_true", 
    #    dest="noscp",default='False',
    #    help='Optional: Do not copy data to /scratch. If model output is in '+\
    #      ' $LOCALDATA files have to be scped to /scratch. Hence do not use'+\
    #      ' this option when output is in $LOCALDATA.')

    (options, args) = agparse.parse_args() 

    # Check arguments - at least 12 pp files, full path

    if options.ppfile == None or \
      len(options.ppfile) < 12 :
       agparse.print_help()
       sysout.write(' ')
       exit(1)
    
    # Check for '../' or './' 
    if options.ppfile[0][0] != '/':
       sysout.write('Relative path detected. Pl. specify full'+\
                    ' path for input files.\n')
       exit(2)       

    # Set default values
         
    # Process optional arguments
    optargs = ""
    if options.trmaps != " ":
       optargs = optargs + " -m " + options.trmaps 
    else:
       optargs = optargs + " -m /home/h02/hadzm/eval_v2/etc/ukca_stdname_vn103"

    if options.stashlist != " ":
       optargs = optargs + " -s " + options.stashlist 
    else:
       optargs = optargs + " -s /home/h02/hadzm/eval_v2/camb_chem/stash_eval_v103.lst"
      
    optargs = optargs + " -f " + str(options.scale_fac)

    if options.run_test == True:
       main_scr = test_scr

    # Store current environment to copy back results 
    inidir = os.getenv('PWD')
    userid = os.getenv('USER')
    pcid = os.getenv('HOSTNAME') # orig host to copy back data

    topdir = '/scratch/'+userid+'/eval_'+jid  # Exec folder
    jobfile = topdir+'/eval_'+jid+'.sub'  # job submission file
    logfile = topdir+'/'+jid+'.log'  # Log file

    # **** Note: *** Changing to folder for all further ops
    try:
       os.makedirs(topdir)
    except:
       sysout.write('ERROR creating temporary folder '+topdir)
       exit(3)

    os.chdir(topdir)
    
    # Copy data to /scratch area if in $LOCALDATA (not visible from SPICE)
    l_scp = False
    if '/data/local' in options.ppfile[0][0:11] or \
       '/var/tmp' in options.ppfile[0][0:8]:
      l_scp = True

      tmpdir = topdir+'/input'
      try:
         os.makedirs(tmpdir)
      except:
         sysout.write('ERROR creating temporary folder '+tmpdir)
         exit(4)
      
      # Need to unravel ppfiles as a string before passing to main script.
      # If using scp, replace original pathnames with tempdir 
      ppfiles = ''    
      for fl in options.ppfile:
        fil = os.path.basename(fl)
        ppfiles = ppfiles+' '+tmpdir+'/'+fil
    
    else:    # unravel filenames normally
      ppfiles = ''    # Need to unravel ppfiles as a string 
      for fl in options.ppfile:
        ppfiles = ppfiles+' '+fl

    # Write to job submission file 
    f = open(jobfile,'w')
    f.write('#!/bin/bash -l\n')

    f.write('#SBATCH --job-name=tc_eval_'+jid+'\n')
    f.write('#SBATCH --output='+logfile+'\n')
    f.write('#SBATCH --error='+logfile+'\n')
    f.write('#SBATCH --qos=normal\n')
    f.write('#SBATCH --mem=10240\n')
    f.write('#SBATCH --time=06:00:00\n')
    # Load scitools module, hardwired for now
    f.write('\nmodule load scitools/production-os43-1\n')
    f.write('module load R\n')

    # if copy requested - scp each input file to tempdir
    if l_scp:
      f.write('\n')
      for fl in options.ppfile:
        f.write('scp '+pcid+':'+fl+' '+tmpdir+'/'+'\n')
      f.write('\n')
 
    #  Main command
    bcmd = main_scr + ' -i' + ppfiles + ' ' + optargs
    f.write('\n'+bcmd+'\n')

    # Regardless of success/failure: delete temp folder and
    #  copy back top-level folder to original user location
    if l_scp :
       f.write('\n rm -rf '+tmpdir+'\n')

    f.write('\nmv ukca_evaluation_v2.Rout '+' ./Plots_TC/'+jid+'.Rout \n')
    f.write('\ncp '+logfile+' '+jobfile+' ./Plots_TC/ \n')
    f.write('scp -r '+topdir+'/Plots_TC '+pcid+':'+inidir+'\n')

    f.close()

    # Actual job submit command
    bcmd = 'sbatch '+jobfile
    sysout.write('\n'+bcmd+'\n')
    #ret = 0
    ret = call(bcmd,shell=True)
    if ret == 0:
      sysout.write(' \n**  Job submitted. Check for status with '+\
              'command `squeue`.')
      sysout.write('**  Log files : '+jid+'.log and \n'+\
            'in the ./Plots_TC/<jobid> folder\n')
    else:
      sysout.write('  ERROR in Job submission. ')
# End Main

