"""
  Module containing functions that are required mainly for 
  Toprchem evaluation, but could also be applied elsewhere.
"""

import iris

def check_strattrop(infile):
  """ Check if the model output is from a StratTrop(CheST)
      or TropIsop (CheT) run.
      Method:- Crude, checks for following species in file:
      ClO, N2O --> CheST; NOy (34004) --> CheT
      
      Returns True for StratTrop/ CheST
  """
  
  stash_codes_str = [ 'm01s34i042', 'm01s34i049'] # ClO, N2O
  stc_trop = 'm01s34i004' # NO2/NOy
    
  fieldcons = []     # List of stash constraints
  for spc in stash_codes_str:
     fieldcons.append(iris.AttributeConstraint(STASH=spc))
        
  stcubes = iris.load_cubes(infile,constraints = fieldcons)
  if len(stcubes) == len(stash_codes_str):
     stcubes = 'a'
     return True
  else:
     # Assume not StratTrop - confirm if Trop
     fieldcons = iris.AttributeConstraint(STASH=stc_trop)
     trcube =  iris.load_cube(infile,constraints = fieldcons)
     if trcube != None:
        trcube = 'a'
        return False
     else:   # Something wrong, not all diagnostics in place
        print 'CHK_STRATTROP: Diagnostics missing -Not able to determine'
        return True   # Default --may cause failure in some scripts

# End def check_strattrop

def cube_to_r(incube, reverse_dims=True):
   """ Convert a cube or numpy array to a data struct recognised by R """
   """
       Arguments:
         incube:- single data cube 
         reverse_dims : Reverse dimensions? -default True
       Returns :- Data structure that can be passed 
                  to a R function
   """

   from rpy2.robjects.numpy2ri import numpy2ri
   
   # Check if input data is a cube, otherwise 
   # handle it as a numpy array
   if isinstance(incube,iris.cube.Cube):
      in_data = incube.data
   else:
      in_data = incube
            
   # Reverse dimensions if requested
   if reverse_dims:
      in_data = in_data.transpose()    # numpy method
   
   # Convert to R structure --recognises only numpy array
   return numpy2ri(in_data)
       
# end def cube_to_r

