# ---- load packages ----
{
  library(data.table)
  library(dplyr)
  library(here)
  library(lubridate)
  library(purrr)
  library(readr)
  library(stringr) 
  library(tidyr)
}
# ---- bring in detection data ----

dat <- read_rds(here("saved-data", 
                     "Lotek-cleaned_telemetry-data", 
                     "lotek_telemetry_joined_metadata.rds"))

glimpse(dat)


# ----- Min_LAG filter #### ----

df$min_lag <- as.numeric(NA)

df$time <- as.numeric(df$detection_datetime) 
# creates a time variable that is raw time (seconds since jan 1 1970)
glimpse(df)
df <- df[order(df$hex, df$detection_datetime),] # ensure the dataset is sorted properly, first it orders by tag ID and then by date_time 

# vector of fish IDs
fish <- sort(unique(df$hex)) #list of fish IDs that the loop is going to go through one at a time
fish #all 23 fish

#loop: Creates Min-lag values = number of seconds between subsequent detections of a tag on the same reciever

glimpse(df)
#names(df)[names(df) == 'station'] <- 'Station'
df$station <- as.character(df$station)
for(i in 1:length(fish)){ # go through each fish one at a time. 
  
  df.i <- df[df$hex==fish[i],] # subset data for fish i, 5095 - number of detections for fish 45, will change for each fish as it goes through the loop but it ends on the last fish 
  recn1 <- as.character(sort(unique(df.i$station))) #vector of receiver names
  
  for(k in 1:length(recn1)){ # go through each receiver name one at a time
    
    ro<-which(df.i$station==recn1[k])
    df.k <- df.i[ro,] # subset all data from this fish and receiver combo, 11 detections for that fish on that receiver
    if(nrow(df.k)==1){
      df.k$min_lag <- -5
      df.i[row.names(df.k),] <- df.k #insert dum.k back into dum.i
    }
    
    if(nrow(df.k)>1){ #as long as there are more than one detections for this fish and receiver, do the following
      
      cur_time <- as.vector(df.k$time) #vector of detection times, in s (which are in order)
      pt <- append(NA, cur_time) #corresponding vector of previous times, created by adding an NA to the front of the vector
      pt <- as.vector(pt[-length(pt)]) #remove the last value so that the vector will be same length as "current time" vector
      nt <- append(cur_time, NA) #corresponding vector of next times, created by adding an NA to the end of the vector
      nt <- as.vector(nt[-1]) #remove the first value so that the vector will be same length as "current time" vector
      
      #create a vector that is the minimum time elapsed since last detection or to next detections
      #at the same time, add that vector to empty cells in the 'lag' variable in the dataframe dum.k
      df.k$min_lag <- pmin(abs(cur_time-nt), abs(cur_time-pt), na.rm=TRUE) 
      
      df.i[row.names(df.k),] <- df.k #insert dum.k back into dum.i
      
    }
  } #end of loop going through each receiver
  
  df[row.names(df.i),] <- df.i #insert data from fish i back into the overall dataframe
  
}

#evaluating min lag parametres
mean(df$min_lag, na.rm=TRUE)
min(df$min_lag, na.rm=TRUE)
max(df$min_lag, na.rm=TRUE)
median(df$min_lag, na.rm=TRUE)
length(which(is.na(df$min_lag)))
length(df$min_lag)
length(which(df$min_lag==-5)) #37 -- we will delete these; they are illogical 
length(which(df$min_lag>1200)) #30 x 20 s interval range;then double for 60 s on and off; we will delete these 6495

#current number of "true" detections - 101028 (size of df)

foo <- df[df$min_lag<601,] #keeps the rows where the values for the min lag are less than 600
nrow(foo) #92289/101028 - only 8.65% detections are false!! 
foo <- foo[!foo$min_lag==-5,] #remove low power detections
nrow(foo) # 94495/101028

length(unique(foo$dec)) #20
length(unique(foo$hex)) #20
#the min lag filter removed 3 tagged jess fish

#interval filter ####
hist(foo$min_lag, xlim = c(0,30), breaks=10000)
hist(foo$min_lag, xlim = c(0,50), breaks=10000)
sort(unique(foo[foo$min_lag<20,]$min_lag))

with(df[df$min_lag<610,], table(min_lag)) #lots of detections at '0'

#can just kick out any detections before 20
#or go interval by interval and truly delete sound
#foo <- foo[!foo$min_lag<19,]
#hist(foo$min_lag, xlim = c(0,100), breaks=10000)


library(dplyr)

dets <- runif(1000, 0, 1200) |> 
  data.frame(dets = _)

key <- data.frame(
  start = seq(15, 1200, by = 20),
  end = seq(25, 1220, by = 20)
)

dets |> 
  right_join(key, by = join_by(between(dets, start, end)))








nrow(df) #175342
nrow(foo) #67894
df <- foo
foo <- NULL
nrow(df)

#CAN GO ROW BY ROW ALSO BUT SEEMS TO JUST KICK OUT TRUE ONES
foo <- df[(df$min_lag >= 15 & df$min_lag <= 25) | (df$min_lag >= 35 & df$min_lag <= 45) | (df$min_lag >= 55 & df$min_lag <= 65) | (df$min_lag >= 75 & df$min_lag <= 85) | (df$min_lag >= 95 & df$min_lag <= 105) | (df$min_lag >= 115 & df$min_lag <= 125) | (df$min_lag >= 135 & df$min_lag <= 145) | (df$min_lag >= 155 & df$min_lag <= 165) | (df$min_lag >= 175 & df$min_lag <= 185) | (df$min_lag >= 195 & df$min_lag <= 205) | (df$min_lag >= 215 & df$min_lag <= 225) | (df$min_lag >= 235 & df$min_lag <= 245) | (df$min_lag >= 255 & df$min_lag <= 265) | (df$min_lag >= 275 & df$min_lag <= 285) | (df$min_lag >= 295 & df$min_lag <= 305) | (df$min_lag >= 315 & df$min_lag <= 325) | (df$min_lag >= 335 & df$min_lag <= 345) | (df$min_lag >= 355 & df$min_lag <= 365) | (df$min_lag >= 375 & df$min_lag <= 385) | (df$min_lag >= 395 & df$min_lag <= 405) | (df$min_lag >= 415 & df$min_lag <= 425) | (df$min_lag >= 435 & df$min_lag <= 445) | (df$min_lag >= 455 & df$min_lag <= 465) | (df$min_lag >= 475 & df$min_lag <= 485) | (df$min_lag >= 495 & df$min_lag <= 505) | (df$min_lag >= 515 & df$min_lag <= 525) | (df$min_lag >= 535 & df$min_lag <= 545) | (df$min_lag >= 555 & df$min_lag <= 565) | (df$min_lag >= 575 & df$min_lag <= 585) | (df$min_lag >= 595 & df$min_lag <= 600),] #has to go to 1200 now
nrow(foo) #10231
nrow(df) #67894; true interval filter kicked out another 9000 detections

hist(foo$min_lag, xlim = c(0,100), breaks=10000)
with(foo[foo$min_lag<100,], table(min_lag))

nrow(df) #67894
nrow(foo) #58718
View(foo)
df <- foo
foo <- NULL
nrow(df) #58718

getwd()