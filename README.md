This is a matlab function, created with Matlab version 2017a.

[Y]=runPredAbdSC14_weekly_v2(tstart,tend,str1)

The function requires the matlab file “matForEstAbdOf14SCs_lakeLanier_v2.mat”, and will save the result in the outfile “str1”.

This function predicts the abundances of 14 SC groups in Lake Lanier over time. The available data were collected from 8/7/2010 to 10/15/2015. The function predicts the abundances of the SCs for 6 more years, assuming the environmental conditions do not change.

The function requires 3 inputs:
Tstart: time (day) to start the simulation. The number is in the range of [1, 365*6]. The first day refers to 8/1/1010. If the input is smaller than 1, it will be set to 1. If the input is larger than 365*6, it will be set to 365*6.

Tend: time (day) to stop the simulation. The number is in the range of [2, 365*12]. The first day refers to 8/1/1010. If tstart=tend, the simulation will run for 1 year.

Str1: name of the output file. The output has the following format: <day#>, <abundance of SC1-SC14 by model#1> , <abundance of SC1-SC14 by model#2> , … ,  <abundance of SC1-SC14 by model#10>
    
	
Chemical conditions and SC initial abundances can be modified. 
The initial abundances of the SCs can be modified by modifying the x0 vector. Remember to put in % value (no more than 100 or less than 0).

The water temperature (column #1 in chem matrix) (in degree C) is converted by degreeC/22.0335.

The pH (chem table, column#2) converting to the value used in the table by (pH*(-0.0175)+6.9992)/-52.3704.

The phosphate concentration (mg/L) should be scaled to fold-changes; the mean value is 0.871.
