#' creates a time variable that is raw time (seconds since jan 1 1970)
#' ensure the dataset is sorted properly, first it orders by tag ID 
#' and then by date_time 
#' export 

library(dplyr)


min_lag_lotek <- function(data,
                          timestamp_name = "date_time", 
                          station = "station") {
  if(!any(names(data) %in% c("date_time", "station"))) {
    data$date_time <- data[[timestamp_name]]
    data[[timestamp_name]] <- NULL
    data$station <- data[[station]]
    data[[station]] <- NULL
  }
  
  data$min_lag <- as.numeric(NA)
  data$time <- as.numeric(data$date_time)
  
  data <- data[order(data$hex, data$date_time),]
  # vector of fish IDs
  fish <- sort(unique(data$hex)) 
  
  for(i in 1:length(fish)){ # go through each fish one at a time. 
    
    data_i <- data[data$hex %in% fish[i], ] # subset data for fish i, 5095 - number of detections for fish 45, will change for each fish as it goes through the loop but it ends on the last fish 
    rec_id <- as.character(sort(unique(data_i$station))) #vector of receiver names
    
    for(k in 1:length(rec_id)){ # go through each receiver name one at a time
      
      ro <- which(data_i$station %in% rec_id[k])
      data_k <- data_i[ro, ] 
      
      # if statnemtnet if d_ka only has one row then assin min_lag as -5 where
      # negative 5 comes from I have no idea 
      if(nrow(data) == 1){
        data_k$min_lag <- -5
        data_i[row.names(data_k), ] <- data_k #insert dum.k back into dum.i
      } else{ 
        # as long as there are more than one detections for this fish and receiver, 
        # do the following 
        
        # vector of detection times, in s (which are in order)
        cur_time <- as.vector(data_k$time) 
        # corresponding vector of previous times, created by adding 
        # an NA to the front of the vector
        pt <- append(NA, cur_time) 
        # remove the last value so that the vector will be same length 
        # as "current time" vector
        pt <- as.vector(pt[-length(pt)]) 
        # corresponding vector of next times, created by adding an NA to the end 
        # of the vector
        nt <- append(cur_time, NA) 
        # remove the first value so that the vector will be same length as 
        # "current time" vector
        nt <- as.vector(nt[-1]) 
        # create a vector that is the minimum time elapsed since last detection
        #  or to next detections
        # at the same time, add that vector to empty cells in the 'lag' variable 
        # in the dataframe dum.k
        data_k$min_lag <- pmin(abs(cur_time - nt), abs(cur_time - pt), na.rm = TRUE) 
        
        data_i[row.names(data_k),] <- data_k #insert dum.k back into dum.i
        
      }
    } 
    data[row.names(data_i),] <- data_i
  }#end of loop going through each receiver
  #insert data from fish i back into the overall dataframe
  
  return(data)
}





