def methane_lifetime(ch4_mmr,ohch4_flx,tropmask,airmass,gridvol,
                      flux_scale=3.0):

   ''' Assess Methane Lifetime against Literature recommended values '''

   ''' Arguments:
        ch4_mmr: Methane Mass mix ratio
        ohch4_flx : OH+CH4 reaction flux - UKCA diagnostic
        tropmask : Tropospheric mask - 3-D array = 1 in tropospheric gridcells
                                                 = 0 in stratospheric cells
        airmass : Air mass of each Grid cell
        gridvol : Grid box volumes (Grid cell area x cell heights) m3
        flux_scale: scaling to account for UM/UKCA timestep ratio, default=3.0
       Returns:
        Dictionary with Total Lifetime and Lifetime vs OH as defined by ACCMIP
   '''
    
   # Original R script from Alex Archibald, February 2012
   # Adapted for Python M Dalvi, Apr 2016
    
   # Reference values:
   # ACCMIP's Methane lifetime against OH : 
   # Total burden of CH4 / tropospheric loss of methane by OH = 9.3 +/- 0.9 years 
   #    using a subset of models (full ensemble gives 9.8+/-1.6 years)
   #
   # ACCMIP's Total methane lifetime : Total burden of CH4 / total loss of methane
   #                                    = 8.2 +/- 0.8 years
   #
   # ACCMIP definition: total loss of methane = tropospheric loss by OH 
   #                                            + 30 Tg/yr (due to soil sink) 
   #                                            + 40 Tg/yr (stratospheric loss). 

   # Voulgarakis et al., Analysis of present day and future OH and methane 
   # lifetime in the ACCMIP simulations, Atmos. Chem. Phys., 13, 2563-2587, 2013

   #Observation-based estimate for methane lifetime against OH = 11.2 +/- 1.3 yr
   # Prather, M. J., Holmes, C. D., and Hsu, J.: Reactive greenhouse gas scenarios
   #: Systematic exploration of uncertainties and the role of atmospheric 
   # chemistry, Geophys. Res. Lett., 39, L09803, doi:10.1029/2012GL051440, 2012.


   # Constants
   nav = 6.02214179e+23   # Avagadro No. 

   f_sec2yr = 86400.* 30.* 12. # factor for seconds to years conversion
                          # assumes 12 months of data and 360-day calendar
   mole2kg_ohch4 = 16.0e-3  # Factor OHCH4 flux moles/gridcell --> kg/gridcell

   ch4_loss_soil  = 30.0 * 1.0e+9   #Tg/yr -> kg/yr
   ch4_loss_strat = 40.0 * 1.0e+9

   # Setup output metric dictionary
   metric = {}     
   # Check tropmask array
   if tropmask.data.min() < 0. or tropmask.data.max() > 1.:
      raise EvalError('Unexpected values in Trop-Mask array')

   # Obtain Total OH+CH flux
            
   if flux_scale == None or flux_scale <= 0.:   # Ensure a proper scaling factor
      flux_scale = 1.0

   # Convert to tropospheric, kg/gridcell 
   fohch4_trop = ohch4_flx * tropmask * flux_scale * mole2kg_ohch4
   tcoord = fohch4_trop.coord(axis='T',dim_coords=True)     # Get time coord
   fohch4_tavg = fohch4_trop.collapsed(tcoord, iris.analysis.MEAN)  
                                                           # Mean over time axis
   fohch4_sum = np.ma.sum(fohch4_tavg.data)  # Global sum, cube not needed
   fohch4_ann = fohch4_sum * f_sec2yr        # Kg/yr
   #print ' OH+CH4 global ',fohch4_sum, fohch4_ann
   fohch4_tavg = 'a'                        # Free memory
   fohch4_trop = 'b'

   # Obtain Total CH4 burden and Lifetime vs OH
   ch4_tot = ch4_mmr * airmass
   tcoord = ch4_tot.coord(axis='T',dim_coords=True)
   ch4_tavg = ch4_tot.collapsed(tcoord, iris.analysis.MEAN)  
   ch4_sum = np.ma.sum(ch4_tavg.data)    
   #print ' CH4_tot Global ',ch4_sum
   ch4_tavg = 'a'                        

   tau_v_oh = ch4_sum / fohch4_ann
   metric[' Methane Lifetime vs OH '] = '{0:.2f}'.format(tau_v_oh)

   # Obtain Total Lifetime = Total burden / Loss (OH,soil, strat)
   ch4_loss_tot = fohch4_ann + ch4_loss_soil + ch4_loss_strat
   #print ' Total Methane Loss ',ch4_loss_tot
   tau_ch4_tot = ch4_sum / ch4_loss_tot
   metric[' Total Methane Lifetime '] = '{0:.2f}'.format(tau_ch4_tot)

   # Obtain Tropospheric burden and Lifetime (Old method, for comparison)
   ch4_trop = ch4_tot * tropmask
   ch4_tot = 'b'
   tcoord = ch4_trop.coord(axis='T',dim_coords=True)
   ch4_trop_tavg = ch4_trop.collapsed(tcoord, iris.analysis.MEAN)  
   ch4_trop_sum = np.ma.sum(ch4_trop_tavg.data)    
   #print ' CH4_trop Global ',ch4_trop_sum
   ch4_trop_tavg = 'a'                        
   ch4_trop = 'b'

   tau_trop_v_oh = ch4_trop_sum / fohch4_ann
   print ' Trop-only Lifetime vs OH ',tau_trop_v_oh
                    
   return metric
# End def Methane Lifetime
