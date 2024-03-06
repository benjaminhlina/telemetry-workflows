# ---- load packages ----
{
  library(data.table)
  library(dplyr)
  library(here)
  library(glatos)
  library(lubridate)
  library(purrr)
  library(readr)
  library(stringr) 
  library(tidyr)
  source(here("functions", 
              "min_lag_lotek.R"))
  source(here("functions",
              "false_detection_lotek.R"))
}
# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned-telemetry-data", 
                     "lotek_telemetry_joined_metadata.rds"))

glimpse(dat)

# ---- make station number as a factor -----
dat <- dat %>% 
  mutate(
    station = as.character(station)
  ) %>% 
  arrange(hex, date_time)
glimpse(dat)

# ----- min_lag_lotek filter ----
# creates a time variable that is raw time (seconds since jan 1 1970)
# ensure the dataset is sorted properly, first it orders by tag ID 
# and then by date_time 

# create vector of ids 


dat <- min_lag_lotek(dat)

glimpse(dat)

# ---- interval filter ---- 
# false detections from glatos looks at whether min_lag exceeds the tf value 
dat_glatos <- false_detections(det = dat, tf = 20 * 30)

# false detection function in from this work flow for lotek uses a binned 
# alternating interval approach and tag power appraoch. 
# (e.g., if detections aren't heard within 15-25s, 35-45 s, all the way to 
# 1200 s, they are false). and If the tag power is less than 10 it flags as 
# false  
dat_lotek <- false_detections_lotek(det = dat)


# ---- rename ---- 
dat_lotek <- dat_lotek %>% 
  rename(
    animal_id = hex,
    detection_timestamp_utc = date_time,
    deploy_lat = rec_lat, 
    deploy_long = rec_long
  ) %>% 
  mutate(
    
  )

# ---- save detection data that have been ided for false detections ---- 

write_rds(dat_lotek, here("saved-data", 
                     "Lotek-cleaned-telemetry-data", 
                     "lotek_detections_false_detection_cleaned.rds"))
