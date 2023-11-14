# load packages ----
{
  library(dplyr)
  library(ggplot2)
  library(glatos)
  library(here)
  library(lubridate)
  library(purrr)
  library(readr) 
  library(stringr)
  library(tidyr)
  
}

# bring in detection csv exported by VUE or Fathom ---- 

# suggested file path belwo 

det <- read_csv(here("Data", 
                     "Telemetry Downloads", 
                     "YOUR_FILE_NAME_01_DATE.csv"))


# add in column that is transmitter code space ----- 

dat$transmitter_codespace <- dat$transmitter_id

glimpse(dat)



# remove dashes from both receiver and trasmitter columns ----
dat$receiver <- dat$receiver_sn %>% 
  str_replace(".*-", "")

dat$transmitter <- dat$transmitter_id %>% 
  str_replace(".*-", "")

glimpse(dat)



# if else statment to properly get codespaces -----
# first create vector of the length of each string to test against 


unique(det$transmitter_codespace)

cs_lgth <- str_length(det$transmitter_codespace)
unique(cs_lgth)
# you need to see if the length of the code spaces differed for instance it could
# be A69-9002-10683. The codespace is A69-9002. We need to drop the tag ID from
# the codespace column. To do so we first neeed to determine the length of the 
# string for each each full transmition. then we need to remove the last characters
# prior to the last dash and the dash. In the below example it was 5 or 6 
# characters...I am not sure what your's will be but you will need to change 
# 13 to the correct length of cs_lenght. If you have more than 2 cs_lgths, 
# we can write a case_when statement to do this. Depending on the number 
# of characters you need to remove, change 5 and 6 below. 

# use if_else to have it search for when the length of the code space
# equals 13 characters and have it remove those last 6 characters 
# then if it equals 13 have it only remove the last 5 characters 
# 

det <- det %>% 
  mutate(
    transmitter_codespace = if_else(cs_lgth %in% 13,  
                                    det$transmitter_codespace %>%
                                      str_replace(".{5}$", ""), 
                                    det$transmitter_codespace %>%
                                      str_replace(".{6}$", ""))
  )


# next we need to do a few things to run min_lag, first min_lag needs to be 
# run for each fish, second we need the mean_delay from those tags as a column
# prior to running min lag you need to have joined all the metadata for the fish
# and the receivers. Best approach is using left_join, and lining things up using 
# receiver_sn for receiver metadata and transmitter_sn for fish metadata. 
# Once I have it lined up I never refer to my fish by their transmitter_id or 
# transmitter_sn. Instead I refer to them by their external floy_tag. 

# once you have that lined up then we can do min_lag and false detections. 

det <- det %>% 
  group_by(floy_tag) %>% # we need to group by floy_tag first
  arrange(detection_timestamp_utc) %>% # then arrange timestamps in cronicaloigcal order
  split(.$floy_tag) %>% # we will then use split to split our dataframe into a list
  # this list will have fish as a seperate detection dataframe
  map(~ min_lag(.x)) %>% # then run min_lag on each fish. map will iterate over the list
  bind_rows(.id = "floy_tag") %>% # then rejoin the list into a dataframe by floy_gag
  ungroup() # lastly ungroup the dataframe

# next we need to run false detection 
# same proceedures above except one little change to our map call 
# we will use false_detections, this will put a 0-1 and create the column 
# passed_filter, 0 is a false detection. We also need to multiple the mean_delay
# by 30 for the tf argument as this might change between tags. This is 
# for instance this is mean_dealy (120 s * 30 = 3600)
det <- det %>% 
  group_by(floy_tag) %>% 
  arrange(detection_timestamp_utc) %>% 
  split(.$floy_tag) %>% 
  map(~ false_detections(det = .x, tf = mean_delay * 30)) %>% 
  bind_rows(.id = "floy_tag") %>% 
  ungroup()


det

# now we can remove false detections 
det <- det %>% 
  filter(passed_filter %in% 1)