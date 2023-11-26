# ---- load packages ----
{
  library(chron)
  library(data.table)
  library(dplyr)
  library(devtools)
  library(geosphere)
  library(glatos)
  library(here)
  library(lubridate)
  library(plotrix)
  library(purrr)
  library(readr)
  library(readxl)
  library(stringr) 
  library(tidyr)
  library(writexl)
  library(janitor)
}
# ---- bring in detection data ----
# suppper fast load !!! 
dat <- list.files(path = "./data/Lotek/WHS Host exports",
                  pattern = "*.csv", 
                  full.names = TRUE) %>% 
  map_df(~read_csv(., col_types = cols(.default = "c"), id = "id")) %>% 
  mutate(
    id = str_replace(id, "./data/Lotek/WHS Host exports/", ""), 
    id = str_replace(id, ".csv", "")
  ) %>%
  janitor::clean_names()
glimpse(dat) 
# ---- import tag metadata ----
tag_data <- read_csv(here("Data",
                          "Lotek", 
                          "Metadata",
                          "fish_tagging_metadata.csv")) %>% 
  janitor::clean_names()
glimpse(tag_data) 

# ---- Import rec metadata ---- 
rec_data <- read_csv(here("data", 
                          "Lotek", 
                          "Metadata", 
                          "rec_metadata.csv")) %>% 
  janitor::clean_names() %>% 
  rename(
    rec_id = id,
    deploy_datetime = deploy_datetime_5, 
    deploy_time = deploy_datetime_6, 
    rec_notes = notes
  )
glimpse(rec_data)
# ---- convert dat from raw Julian to posixct ----
dat <- dat %>% 
  mutate(
    time = as.numeric(time)
  )
# lotek is not actually in utc, it is in whatever computer was in
# note that although the R believes the date & time  from WHS host is UTC
# this is not correct. It is in Ottawa (EST) time (confirmed with LOTEK). 
# Unless 
dat <- dat %>% 
  mutate(
    time = chron(time, origin = c(month = 1, day = 0, year = 1900),
                 format = c(dates = "y-m-d", times = "h:m:s")) %>%
      as.character() %>% 
      str_replace("[(\\)]", "") %>%
      str_replace(".{1}$", "") %>%
      ymd_hms(tz = "EST")
  )

names(dat)[names(dat) == "time"] <- "date_time" #rename

glimpse(dat) # look at data again to see what format everything is in 
# and check the time and date are now in POSIX (dttm)
# date_time is correct EXCEPT it is 24 hours ahead of 
# when the detection truly occurred
# need to create a new column with the correct times
dat <- dat %>% 
  mutate(
    date_time_24hr = date_time - 86400
)
# this column is the real day time
# Filtering code for 20-second interval rate fish for winter 2022-2023 
# (spring 2023 downloads)
# recs were 60 seconds on 60 seconds off
# 10-minute min_lag filter based on 20-second tag interval rate; 3600-second event filter

# ---- write rds ---- 

write_rds(dat, here("saved-data", 
                    "Lotek-cleaned_telemetry-data", 
                    "lotek_cleaned_telemetry_file.rds"))
