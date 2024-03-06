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
  # source(here("functions", 
  #             "false_detection_lotek.R"))
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
dat <- false_detections(det = dat, tf = 20 * 30)


# ---- rename ---- 
dat <- dat %>% 
  rename(
    animal_id = hex,
    detection_timestamp_utc = date_time,
    deploy_lat = rec_lat, 
    deploy_long = rec_long
  ) %>% 
  mutate(
    
  )

# ---- save detection data that have been ided for false detections ---- 

write_rds(dat, here("saved-data", 
                     "Lotek-cleaned-telemetry-data", 
                     "lotek_detections_false_detection_cleaned.rds"))
