#===============================================================
# 
# Name:     02 Stack FMData.R
# 
# Date:     11/04/2020
# 
# Author:   MT
# 
# Purpose:  Stack monthly EAD files
#
# Reference: https://capitalmarkets.fanniemae.com/media/9066/display
#
# Step 1: Packages, locations and names
# Step 2: Read in, stack data
#
#===============================================================


#===============================================================
# Step 1: Packages, locations and names

# Packages
library(data.table)
library(tidyverse)

# Prep data location
prep.loc='R:/FMData/02 PrepData/'

# Define file names
names=sort(paste0('prep_', sort(rep(2004:2011,4)),'Q', 1:4, '.csv'))
#===============================================================


#===============================================================
# Step 2: Read in, stack data
stack <-function(start, end){

  # Loop over each file
  for (j in start:end){
    
  	# Read in file
    filename=names[j]
    print(filename)
    stack.infile = fread(paste0(prep.loc, filename), sep = ",") %>%
      mutate(file=str_sub(filename,6,11))
  
  	# Stack the data
    if (j==1){
      stackData=stack.infile
    }
    else{
      stackData=bind_rows(stackData, stack.infile)
    }
  }

	# Write out file
	fwrite(stackData, file=paste0(prep.loc, 'stack_FM_EAD_Data.csv'))
	
}

# Loop over names
start=1
end  =length(names)
stack(start, end)
#===============================================================
