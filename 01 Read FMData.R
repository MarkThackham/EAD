#===============================================================
# 
# Name:     01 Read FMData.R
# 
# Date:     11/04/2020
# 
# Author:   MT
# 
# Purpose:  Read in and create monthly EAD files
#
# Reference: https://capitalmarkets.fanniemae.com/media/9066/display
#
# Step 1: Packages, locations and names
# Step 2: Read in, prepare and and ouptut data
#
#===============================================================


#===============================================================
# Step 1: Packages, locations and names

# Packages
library(data.table)
library(tidyverse)

# Raw data location
raw.loc='R:/FMData/01 Data/'

# Prep data location
prep.loc='R:/FMData/02 PrepData/'

# Define variable names
varNames <- c("POOL_ID", "LOAN_ID", "ACT_PERIOD", "CHANNEL", "SELLER", "SERVICER",
              "MASTER_SERVICER", "ORIG_RATE", "CURR_RATE", "ORIG_UPB", "ISSUANCE_UPB",
              "CURRENT_UPB", "ORIG_TERM", "ORIG_DATE", "FIRST_PAY", "LOAN_AGE",
              "REM_MONTHS", "ADJ_REM_MONTHS", "MATR_DT", "OLTV", "OCLTV",
              "NUM_BO", "DTI", "CSCORE_B", "CSCORE_C", "FIRST_FLAG", "PURPOSE",
              "PROP", "NO_UNITS", "OCC_STAT", "STATE", "MSA", "ZIP", "MI_PCT",
              "PRODUCT", "PPMT_FLG", "IO", "FIRST_PAY_IO", "MNTHS_TO_AMTZ_IO",
              "DLQ_STATUS", "PMT_HISTORY", "MOD_FLAG")

# Define file names
names=sort(paste0(sort(rep(2004:2011,4)),'Q', 1:4, '.csv'))
#===============================================================


#===============================================================
# Step 2: Read in, prepare and and ouptut data
readin_readout <-function(filename){

  #--------------------
	# Read in file
  print(filename)
  infile = fread(paste0(raw.loc, filename), sep = "|", select=1:42) 
	names(infile)=varNames
	#--------------------
	
	#--------------------
	# Select frist default at 6 months arrears
	infile2=infile %>%
	  # Remove unnecessary features
	  select(-POOL_ID, -SERVICER, -MASTER_SERVICER, -ISSUANCE_UPB, -FIRST_PAY_IO, -MNTHS_TO_AMTZ_IO,) %>%
	  
	  # Create date
	  mutate(temp1=str_pad(ACT_PERIOD, width=6, side='left', pad='0')) %>%
	  mutate(DATE=paste0(str_sub(temp1,3,-1),str_sub(temp1,1,2)))  %>%
	  select(-temp1) %>%
	  
	  # Create numerical DLQ_STATUS
	  mutate(DLQ_STATUS_NUM=suppressWarnings(as.numeric(DLQ_STATUS))) %>%
	  
	  # Arrange and group  
	  arrange(LOAN_ID, DATE) %>%
	  group_by(LOAN_ID) %>%
	  
	  # Lag12 and Lag24 Balance
	  mutate(LAG12_CURRENT_UPB=lag(CURRENT_UPB,12), LAG24_CURRENT_UPB=lag(CURRENT_UPB,24)) %>%
	  
	  # Filter for the first episode of 6 months arrears
	  filter(DLQ_STATUS_NUM==6) %>%
	  filter(row_number()==1) %>%
	  
	  # Ungroup and output data.frame
	  ungroup %>% as.data.frame()
	#--------------------
	
	#--------------------
	# Write out file
	fwrite(infile2, file=paste0(prep.loc, 'prep_', filename))
	#--------------------
}

# Loop over names
start=1
end  =length(names)
for (j in start:end){
  try(readin_readout(names[j]))
}
#===============================================================
