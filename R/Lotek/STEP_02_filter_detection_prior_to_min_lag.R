# ---- load packages ----
{
  library(dplyr)
  library(here)
  library(lubridate)
  library(readr)
}
# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned_telemetry-data", 
                     "lotek_telemetry-joined_metadata.rds"))

glimpse(dat)

# ---- Check if tags were detected BEFORE they were deployed ----
dat <- dat %>%
  group_by(hex) %>%
  arrange(date_time) %>%
  mutate(
    before_release = if_else(date_time < release_date,
                             false = 1, true = 0)
  ) %>% 
  ungroup()

# ----- filter out detections heard before deployed or didn't have a hex ----
dat <- dat %>% 
  filter(before_release == 1)

# ---- Export out our filtered data ---- 

write_rds(dat, here("saved-data", 
               "Lotek-cleaned-telemetry-data", 
               "lotek_telemetry_joined_metadata_filtered.rds"))
