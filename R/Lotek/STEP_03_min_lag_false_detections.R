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
}
# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned_telemetry-data", 
                     "lotek_telemetry_joined_metadata.rds"))

glimpse(dat)

# ---- make station number as a factor -----
dat <- dat %>% 
  mutate(
    station = as.factor(station)
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



t <- false_detections_lotek(dets = dat, end_min = 1200, end_max = 1220, 
                            start_min = 15, start_max = 25, interval = 20)

glimpse(t)



tes <- dat %>% 
  group_by(hex) %>% 
  arrange(date_time) %>% 
  ungroup() %>% 
  split(.$hex) %>% 
  map(~ false_detections_lotek(dets = ., end_min = 1200, end_max = 1220, 
                               start_min = 15, start_max = 25, interval = 20)) %>% 
  bind_rows()

glimpse(tes)



