# ---- Load packages ----
{
  library(dplyr)
  library(ggplot2)
  library(glatos)
  library(here)
  library(janitor)
  library(lubridate)
  library(purrr)
  library(readr) 
  library(stringr)
  library(tidyr)
  
}

# ---- Bring in downloaded data exported from VUE ----
# these files will often be quite large but for the purpose of this tutorial
# I've sampled the first 100 detections for each receiver for each download 


# grab entire file list from folder
file.list <- list.files(here::here("Data",
                                   "Innovasea",
                                   "Vue or Fathom exports"), 
                        full.names = TRUE,
)
file.list

# ---- Import data -----
# use map_df function from purrr to proforma a for loop to import 
# and combine into a single data frame 
# the ID column creates teh file names an id-column with the file-names 

dat <- map_df(file.list, read_csv, .id = "id") %>%
  clean_names()
# view data after import 
glimpse(dat)

dat %>% 
  arrange(date_and_time_utc)
# ---- Drop blank columns -----

dat <- dat %>% 
  select(id:sensor_unit, -transmitter_name) %>% 
  rename(
    transmitter_id = transmitter,
    receiver_sn = receiver, 
    detection_timestamp_utc = date_and_time_utc
  )

# ---- Bring in receiver location ----

rl <- read_csv(here::here("Data", 
                          "Innovasea",
                          "Metadata",
                          "receiver_metadata.csv")) %>%
  clean_names()

glimpse(rl) 

# convert serial number of receiver to character to properly line up data 
rl <- rl %>% 
  mutate(
    sn = as.character(sn)
  )


# ---- Bring in metadata for tagged fish -----
fish_tag_data <- read_csv(here::here("data", 
                                     "Innovasea",
                                     "metadata",
                                     "fish_tagging_metadata.csv")) %>%
  clean_names()
glimpse(fish_tag_data)
# ---- For this example we will just grab just lake trout -----
lt_tagged <- fish_tag_data %>%
  filter(species %in% "LT") 

glimpse(lt_tagged)


# ---- remove any transmitter serial columns that have NA ------

lt_tagged <- lt_tagged %>% 
  filter(transmitter_serial != is.na(transmitter_serial))

# change tag date into posxict 
lt_tagged <- lt_tagged %>% 
  mutate(tag_date = dmy(tag_date))


# ---- Filter out detections so only LKT are present ------

dat <- dat %>% 
  arrange(detection_timestamp_utc)

dat$transmitter_serial <- as.character(dat$transmitter_serial) 



# ---- Remove Transmitters that were not in the system (False Detection) ----- 
# remove false detections from whole dataframe and sort just for species


dat <- dat %>%
  filter(transmitter_serial %in% lt_tagged$transmitter_serial)

glimpse(dat)

# ---- Add in column that is transmitter code space ----- 

dat$transmitter_codespace <- dat$transmitter_id

glimpse(dat)



# ---- remove dashes from both receiver and transmitter columns ----
dat$receiver_sn <- dat$receiver_sn %>% 
  str_replace(".*-", "")

dat$transmitter_id <- dat$transmitter_id %>% 
  str_replace(".*-", "")

glimpse(dat)



# ---- if else statement to properly get codespaces -----
# first create vector of the length of each string to test against 




cs_lgth <- str_length(dat$transmitter_codespace)
unique(cs_lgth)
# you need to see if the length of the code spaces differed for instance it could
# be A69-9002-10683. The codespace is A69-9002. We need to drop the tag ID from
# the codespace column. To do so we first need to determine the length of the 
# string for each each full transmission. then we need to remove the last characters
# prior to the last dash and the dash. In the below example it was 5 or 6 
# characters...I am not sure what your's will be but you will need to change 
# 13 to the correct length of cs_lgth). If you have more than 2 cs_lgths, 
# we can write a case_when statement to do this. Depending on the number 
# of characters you need to remove, change 5 and 6 below. 

# use if_else to have it search for when the length of the code space
# equals 13 characters and have it remove those last 6 characters 
# then if it equals 13 have it only remove the last 5 characters 

# for this example the code space is all the same so n need to 
dat <- dat %>% 
  mutate(
    transmitter_codespace = str_replace(transmitter_codespace, ".{6}$", "")
    )



# ---- join receiver metadata --------
# we need to add the receiver locations, and lat and lon 
# We need to join by the file ID (each download will have a different lat lon)
# for the same receiver as the deployment lat and lon will shift ever so slight
# We will take the average of the lat and lon. We will match up downlaod_group 
# with ID and the receiver serial number 
#
# NOTE: if you do not have multiple gps points for each time you downloaded and 
# deployed the receiver then just line up by serial number of the receiver

glimpse(dat)
glimpse(rl)


dat <- dat %>% 
  left_join(rl, by = c("id" = "download_group", "receiver_sn" = "sn"))

glimpse(dat)
# congrats we now have the lat and lon of each receiver download lined up 

# ---- take the mean lat and lon of the receiver ----
# if you did not take multiple gps points for each time you downloaded and 
# deployed the receiver then you can skip this part 

dat <- dat %>% 
  group_by(receiver_sn) %>% 
  mutate(
    lon_mean = mean(long, na.rm = TRUE),
    lat_mean = mean(lat, na.rm = TRUE)
  ) %>% 
  ungroup()

glimpse(dat)

# ---- join fish metadata -------- 
# We now are going to join the fish metadata by trasmitter serial number 
# Going forward we will not refer to the fish by the transmitter serial number 
# but instead by its floy_tag number

glimpse(dat)

# we only need specific columns from lt_tagged 

lt_tagged <- lt_tagged %>% 
  dplyr::select(floy_tag, tag_date, species, basin, latitude, longitude, 
                tl, fl, girth, weight, sex, scales, fin, vemco_tag:transmitter_serial, 
                comments) %>% 
  mutate(
    transmitter_serial = as.character(transmitter_serial) # we will convert to 
    # transmitter_serial in detection data frame 
  ) %>% 
  rename(fish_basin = basin)

# now we join our detection dataframe with our fish metadata
dat <- dat %>% 
  left_join(lt_tagged, by = "transmitter_serial")

glimpse(dat)

# ----- CONGRATULATIONS! now detection data can move tp the next SCRIPT once saved
# ---- Once Clean export data -----
write_rds(dat, here("Saved-Data", 
                    "Innovasea-Cleaned-Telemetry-Data", 
                    "cleaned_telemetry_file.rds"))
