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
  source(here("functions", 
              "make_linestring.R"))
  source(here("functions", 
              "speed_filter.R"))
}
# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned_telemetry-data", 
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

glimpse(dat)


# ---- interval filter ---- 
dat <- false_detections_lotek(dets = dat)


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

glimpse(dat)

# ----- create detection events filter ----- 
dtc <- detection_events(dat, 
                        location_col = "station", 
                        time_sep = 3600 * 1, 
                        condense = TRUE) 

glimpse(dtc)

# ---- development of speed filter to come ---- 

dtc_speed <- speed_filter(dets = dtc)


glimpse(dtc_speed)

dtc_speed %>% 
  filter(passed_filter_speed %in% 0)
