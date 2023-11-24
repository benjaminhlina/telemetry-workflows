# ---- load packages ----
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

# ---- bring in detection csv exported by VUE or Fathom ---- 

# suggested file path below, rename your rds

det <- read_rds(here("saved-data", 
                     "Innovasea-cleaned-telemetry-data", 
                     "cleaned_telemetry_file.rds"))

glimpse(det)


# ---- EXAMPLE 1: -----
# ---- run min lag for loop ---- 

# create vector of all fish we itterate over

fish_id <- unique(det$floy_tag)
# create blank list to dump results into 
min_lag_list <- list() 

# create min_lag for loop 

for (i in 1:length(fish_id)) { 
  # first we will filter each fish and then arrange them in chronological 
  # order 
  
  df <- det %>% 
    filter(floy_tag %in% fish_id[i]) %>% 
    arrange(detection_timestamp_utc)
  
  # run min_lag on each fish 
  df <- df %>% 
    min_lag(.)
  
  # need dump each fish into blank list we will use [[]] to put each fish in 
  min_lag_list[[i]] <- df
  
  
  message(paste("Completed min_lag for fish ", i, "out of ", length(fish_id))
  )
  }

# ---- combine min_lag results list ---- 
det_f <- bind_rows(min_lag_list)


glimpse(det_f)
# we can see we now have the column min_lag added 
# ---- Run for loop of false_detection ----- 
# create blank list to dump false_det results 

false_det_ls <- list()

for (i in 1:length(fish_id)) {
  # first we will filter each fish and then arrange them in chronological 
  # order 
  
  df_1 <- det_f %>% 
    filter(floy_tag %in% fish_id[i]) %>% 
    arrange(detection_timestamp_utc)
  
  # run min_lag on each fish 
  df_1 <- df_1 %>% 
    false_detections(tf = .$max_delay * 30)
  
  # need dump each fish into blank list we will use [[]] to put each fish in 
  false_det_ls[[i]] <- df_1
}

# ---- combine our list to have our final data frame ---

det_for <- bind_rows(false_det_ls)

glimpse(det_for)

# ---- now we can remove false detections -----
det_for <- det_for %>% 
  filter(passed_filter %in% 1) %>% 
  arrange(detection_timestamp_utc)

glimpse(det_for)

# ---- EXAMPLE 2: ------
# ---- RUN min_lag() purrr -----
# next we need to do a few things to run min_lag, first min_lag needs to be 
# run for each fish, second we need the mean_delay from those tags as a column
# prior to running min lag you need to have joined all the metadata for the fish
# and the receivers. Best approach is using left_join, and lining things up using 
# receiver_sn for receiver metadata and transmitter_sn for fish metadata. 
# Once I have it lined up I never refer to my fish by their transmitter_id or 
# transmitter_sn. Instead I refer to them by their external floy_tag. 

# once you have that lined up then we can do min_lag and false detections. 

det_m <- det %>% 
  group_by(floy_tag) %>% # we need to group by floy_tag first
  arrange(detection_timestamp_utc) %>% # then arrange timestamps in cronicaloigcal order
  split(.$floy_tag) %>% # we will then use split to split our dataframe into a list
  # this list will have fish as a seperate detection dataframe
  map(~ min_lag(.x)) %>% # then run min_lag on each fish. map will iterate over the list
  bind_rows(.id = "floy_tag") %>% # then rejoin the list into a dataframe by floy_gag
  ungroup() # lastly ungroup the dataframe

glimpse(det)

# ---- Run false_detection -----
# next we need to run false detection 
# same procedures above except one little change to our map call 
# we will use false_detections, this will put a 0-1 and create the column 
# passed_filter, 0 is a false detection. We also need to multiple the mean_delay
# or max_delay by 30 for the tf argument as this might change between tags. This is 
# for instance this is mean_delay (120 s * 30 = 3600)
det_map <- det_m %>% 
  group_by(floy_tag) %>% 
  arrange(detection_timestamp_utc) %>% 
  split(.$floy_tag) %>% 
  map(~ false_detections(det = .x, tf = .x$max_delay * 30)) %>% 
  bind_rows(.id = "floy_tag") %>% 
  ungroup()


glimpse(det_map)

# ---- now we can remove false detections -----
det_map <- det_map %>% 
  filter(passed_filter %in% 1) %>% 
  arrange(detection_timestamp_utc)

glimpse(det_map)


# ---- Now that we have removed false detections we can move to the next step ----

# write_rds(det_for, here::here("Saved-Data", 
#                           "Innovasea-cleaned-telemetry-data", 
#                           "false_detection_cleaned_telemetry_data.rds"))
# write_rds(det_map, here::here("Saved-Data", 
#                           "Innovasea-cleaned-telemetry-data", 
#                           "false_detection_cleaned_telemetry_data.rds"))
