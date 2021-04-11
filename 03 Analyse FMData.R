#===============================================================
# 
# Name:     03 Analyse FMData
# 
# Date:     12/04/2020
# 
# Author:   MT
# 
# Purpose:  Stack monthly EAD files
#
# Reference: https://capitalmarkets.fanniemae.com/media/9066/display
#
# Step 1: Packages, locations and names
# Step 2: Read in and prepare stacked data
# Step 3: Read out final modeling dataset
#
#===============================================================


#===============================================================
# Step 1: Packages, locations and names

# Packages
library(data.table)
library(scales)
library(tidyverse)

# Prep data location
prep.loc='R:/FMData/02 PrepData/'

# Define file names
filename=paste0(prep.loc, 'stack_FM_EAD_Data.csv')

options(scipen=999)

#===============================================================


#===============================================================
# Step 2: Read in and prepare stacked data
fmdata = fread(filename, sep = ",")

# Remove unecessary features, reorder some features
fmdata2 = fmdata %>%
  
  # Rename EAD and FILE
  mutate(EAD=CURRENT_UPB, FILE=file) %>%
  
  # Remove unnecessary features
  select(-ACT_PERIOD, -SELLER, -CURR_RATE, -LOAN_AGE, -REM_MONTHS, 
         -ADJ_REM_MONTHS, -PMT_HISTORY, MOD_FLAG, -DLQ_STATUS_NUM, 
         -CURRENT_UPB, -LAG12_CURRENT_UPB, -LAG24_CURRENT_UPB, 
         -DLQ_STATUS, -MOD_FLAG, -file)%>%
  
  # Reorder features
  relocate(LOAN_ID, DATE, FILE, EAD) %>%
  
  # Remove implausible values of EAD
  filter(EAD>=1000)
#===============================================================


#===============================================================
# Step 3: Read out final modeling dataset

# Split data
fmdata2a=fmdata2 %>% filter(row_number()>=1      & row_number()>=180000)
fmdata2b=fmdata2 %>% filter(row_number()>=180001 & row_number()>=360000)
fmdata2c=fmdata2 %>% filter(row_number()>=360001 & row_number()>=540000)
fmdata2d=fmdata2 %>% filter(row_number()>=540001 & row_number()>=720000)

# Write out files
fwrite(fmdata2a, file=paste0(prep.loc, 'Final_FM_EAD_Data_1.csv'))
fwrite(fmdata2b, file=paste0(prep.loc, 'Final_FM_EAD_Data_2.csv'))
fwrite(fmdata2c, file=paste0(prep.loc, 'Final_FM_EAD_Data_3.csv'))
fwrite(fmdata2d, file=paste0(prep.loc, 'Final_FM_EAD_Data_4.csv'))
#===============================================================
