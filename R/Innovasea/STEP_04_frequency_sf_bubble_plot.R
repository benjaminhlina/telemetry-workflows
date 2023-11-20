# ---- Load packages ----
{
  library(dplyr)
  library(ggplot2)
  library(here)
  library(lubridate)
  library(readr) 
  library(sf)
}

# ---- bring in cleaned telemetry data ---- 
det <- read_rds(here::here("Saved-Data", 
                           "Innovasea-cleaned-telemetry-data", 
                           "false_detection_cleaned_telemetry_data.rds"))

glimpse(det)

det <- det %>% 
  mutate(
    name = factor(name)
  ) 



# ---- create summary dataframe ---- 

det_summary <- det %>% 
  group_by(
    name, lat_mean, lon_mean
  ) %>% 
  summarise(
    n = n()
  ) %>% 
  ungroup()

det_summary
# ---- create into sf object ---- 
det_summary <- st_as_sf(det_summary, coords = c("lon_mean", "lat_mean"), 
                        crs = 4326)

# ---- plot sf object ---- 

ggplot() + 
  geom_sf(data = det_summary, aes(size = n)) + 
  scale_size(name = "Frequency", breaks = seq(0, 200, 25)) 
