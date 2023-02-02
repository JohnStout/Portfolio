# Week 1 R 
# Make sure to install necessary packages!
# install.packages("R.matlab")

# set working directory
setwd("X:/03. Lab Procedures and Protocols/Matlab Practice/Session X")

# load R.matlab library
library(R.matlab)

# load VT data
VTdata = readMat("VT1.mat")
ExtractedX = VTdata$ExtractedX
ExtractedY = VTdata$ExtractedY
TimeStamps = VTdata$TimeStamps

# load Int file
IntData = readMat("Int_file.mat")
Int = IntData$Int






