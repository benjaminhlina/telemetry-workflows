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


# ---- interval filter ---- 
dat <- false_detections_lotek(dets = dat)


# ---- rename ---- 
dat <- dat %>% 
  rename(
    animal_id = hex,
    detection_timestamp_utc = date_time,
    deploy_lat = rec_lat, 
    deploy_long = rec_long
  ) 


# ----- create detection events filter ----- 
dtc <- detection_events(dat, 
                        location_col = "station", 
                        time_sep = 3600 * 1, 
                        condense = TRUE) 

dtc

# ----- DO NOT UNCOMMENT AS THIS CODE IS IN DEVELOPMENT ------






# View(dtc)
# 
# dtc2 <- dtc2[order(dtc2$animal_id, dtc2$first_detection),] 
# #make sure to order the dataframe before conducting the distance filter 
# glimpse(dtc)
# View(dtc)
# 
# #speed filter
# 
# dtc2$dist <- as.numeric(NA)
# dtc2$tstep <- as.numeric(NA) # variable for number of s from previous detection (on any receiver)
# geosphere::distHaversine(c(-76.056, 44.892833), c(-76.026416, 44.896157)) 
# #2362.144 - looking at distance between those two particular points we were interested in, draws a direct line so isn't quite the best but is decent 
# View(dtc) #nothing in dist or tstep as of now, jsut a bunch of NAs
# 
# geosphere::distHaversine(c(-76.31968, 44.64725), c(-76.295572, 44.702990))
# 
# fish <- sort(unique(dtc$animal_id)) #49 fish made it past the filter 
# length(unique(fish))
# glimpse(dtc)
# i <- 1 
# for(i in 1:length(fish)){
#   dtc2.i <- dtc[dtc$animal_id==fish[i],]
#   
#   if(nrow(dtc2.i)>1){
#     llon <- as.vector(dtc2.i$mean_longitude)
#     llat <- as.vector(dtc2.i$mean_latitude)
#     lon <- append(NA, llon)
#     lon <- as.vector(lon[-length(lon)])
#     lat <- append(NA, llat)
#     lat <- as.vector(lat[-length(lat)])
#     t <- data.frame(lon, lat, llon, llat)
#     
#     t
#     m <- make_line(lon = t$plon, lat = t$plat, llon = t$curlon, llat = t$curlat)
#     dtc2.i$dist <- geosphere::distHaversine(cbind(plon, plat), cbind(curlon, curlat))
#     
#     cur_time <- as.vector(dtc2.i$first_detection)
#     pt <- append(NA, as.vector(dtc2.i$last_detection))
#     pt <- as.vector(pt[-length(pt)])
#     dtc2.i$tstep <- cur_time-pt
#     
#     dtc2[row.names(dtc2.i),] <- dtc2.i
#   }
#   
# }
# 
# 
