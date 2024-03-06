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
              "make_linestring.R"))
  source(here("functions", 
              "speed_filter.R"))
}

# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned-telemetry-data", 
                     "lotek_detections_false_detection_cleaned.rds"))

glimpse(dat)


# ----- create detection events filter ----- 
dtc <- detection_events(dat, 
                        location_col = "station", 
                        time_sep = 3600, 
                        condense = TRUE) 

glimpse(dtc)

# ---- swim-speed filter to come ---- 
# use this at your own discrestion as this is under development 

dtc_speed <- speed_filter(dets = dtc)


glimpse(dtc_speed)

dtc_speed %>% 
  filter(passed_filter_speed %in% 0)
