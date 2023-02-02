# -*- coding: utf-8 -*-
"""
Created on Thu Apr 9 14:15:10 2020

Week 1

Remember to check sizes of variables if you're having trouble with doing some-
thing that you found online

@author: John Stout
"""

#------------------------------------------------------------------------------
#                 Extracting & Visualizing Position Data
#------------------------------------------------------------------------------

# libraries for opening matlab files
import scipy.io as sio
import os

# define a variable representing the session directory
sessions_folder = 'C:/Users/uggriffin/Documents/GitHub/CodingClub/'
session = '/Data'
os.chdir(sessions_folder+session) # cd equivalent

# load Int and TimeVariables dictionaries
TimeVariables = sio.loadmat('VT1.mat')
IntVars       = sio.loadmat('Int_file.mat')

# If you want to isolate an element from the dictionary
ExtractedX = TimeVariables["ExtractedX"]
ExtractedY = TimeVariables["ExtractedY"]
TimeStamps = TimeVariables["TimeStamps"]
Int        = IntVars["Int"]

# convert data
import numpy as np                             # import numPy
numSamples = np.size(ExtractedX)               # how many samples total?
X_data = np.resize(ExtractedX,(numSamples,))   # reformat
Y_data = np.resize(ExtractedY,(numSamples,))

# load in matplotlib library
import matplotlib.pyplot as plt # a plotting library

# select a subset of data (data points from start to 50). We're not going to 
# plot this, but it's good to know how to do this
sampleX = X_data[:50]
sampleY = Y_data[:50]

# plot data
plt.title("Rat Position Data")
plt.xlabel("X-position (in pixels)")
plt.ylabel("Y-position (in pixels)")
plt.plot(X_data,Y_data)
plt.show()

#-----------------------------------------------------------------------------#
#                          Plot data trial-by-trial
#-----------------------------------------------------------------------------#

# this approach is a bit different from what we did earlier. We don't need to
# change the ExtractedX, Y, and timestamps variables

# plot data on a trial-by-trial basis
trialNum = np.size(Int,0)

# remember that python uses 0 indexing
Times = [] # initialize variable
Xdata = []
Ydata = []

# for loop - get x, y, and times for every trial
for i in range(0,trialNum): # notice that syntax may change, but concept doesn't
    idx          = np.where(np.logical_and(TimeStamps>Int[i,0], TimeStamps<Int[i,5]))
    Times.append(TimeStamps[idx])
    Xdata.append(ExtractedX[idx])
    Ydata.append(ExtractedY[idx])
    
# like in the matlab code, plot data on a trial-by-trial basis
for i in range(0,trialNum): # notice that syntax may change, but concept doesn't
    plt.plot(Xdata[i],Ydata[i])
    
plt.show()
    
#-----------------------------------------------------------------------------#
#                              Load in LFP data
#-----------------------------------------------------------------------------#

# load in LFP data
LFPdata = sio.loadmat('CSC14.mat')

# extract LFP
csc14 = LFPdata["Samples"]

# concatenate LFP data
csc14[0,:]



















