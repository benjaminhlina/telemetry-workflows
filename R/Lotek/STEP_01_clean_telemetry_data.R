#Filtering code for 20-second interval rate fish for winter 2022-2023 
#(spring 2023 downloads)
#recs were 60 seconds on 60 seconds off
#10-minute min_lag filter based on 20-second tag interval rate; 3600-second event filter

#load packages ----
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
#bring in detection data ----
#file.list <- list.files(path = "./filtered csv files/spring 2023",
#pattern = "*.csv",
#full.names = TRUE

# use map_df function from purrr to  perform a for loop to import and combine into a single dataframe
# only needed when you need an id-column with the file-names 
#df <- map_df(file.list, read_csv,
#col_names = TRUE, .id = "id") %>% 
#mutate(
#id = str_replace(id, "./filtered csv files/spring 2023/", ""), 
#id = str_replace(id, ".csv", "")
#) %>% 
#janitor::clean_names()
#str(df)

# suppper fast load !!! 
tbl <-
  list.files(path = "./filtered csv files/spring 2023",
             pattern = "*.csv", 
             full.names = TRUE) %>% 
  map_df(~read_csv(., col_types = cols(.default = "c"), id = "id")) %>% 
  mutate(
    id = str_replace(id, "./filtered csv files/spring 2023/", ""), 
    id = str_replace(id, ".csv", "")
  ) %>%
  janitor::clean_names()

tbl
df <- tbl
rm(tbl)
# view data after import ----
glimpse(df) #fraction of a second, power of transmission signal

#convert df from raw Julian to posixct ----
df$time <- as.numeric(df$time)

df$time <- chron(df$time, origin = c(month = 1, day = 0, year = 1900),
                 format = c(dates = "y-m-d", times = "h:m:s")) %>%
  as.character() %>% 
  str_replace("[(\\)]", "") %>%
  str_replace(".{1}$", "") %>%
  ymd_hms()

names(df)[names(df) == "time"] <- "date_time" #rename

glimpse(df) #look at data again to see what format everything is in 
#and check the time and date are now in POSIX (dttm)
#date_time is correct EXCEPT it is 24 hours ahead of 
#when the detection truly occurred
#need to create a new column with the correct times
df$date_time_24hr <- (df$date_time - 86400) #this column is the real day time
View(df)