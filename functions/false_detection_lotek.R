false_detections_lotek <- function(dets, 
                                   min_lag_col = "min_lag", 
                                   id = "hex",
                                   timestamp = "date_time",
                                   start_min = 15, 
                                   start_max = 25,
                                   end_min = 1200, 
                                   end_max = 1220, 
                                   interval = 20, 
                                   power = 10) {
  
  
  if(!any(names(dets) %in% c("hex", "date_time", "min_lag"))) {
    dets$hex <- dets[[id]]
    dets[[id]] <- NULL
    
    dets$date_time <- dets[[timestamp]]
    dets[[timestamp]] <- NULL
    
    dets$min_lag <- dets[[min_lag_col]]
    dets[[min_lag_col]] <- NULL
   
  }
  
  # key <- data.frame(
  #   start = seq(starts, tf, by = intervals),
  #   end = seq(ends, tf_ends, by = intervals)
  # )
  # key
  
  # dets <- data %>%
  #   mutate(
  #     passed_filter = case_when(
  #       !is.na(min_lag) & min_lag >= tf ~ 0,
  #       min_lag %in% -5 ~ 0,
  #       .default = 1,
  #     )
  #   )
  # dets
  key <- data.frame(
    start = seq(start_min, end_min, by = interval),
    end = seq(start_max, end_max, by = interval)
  )
  dets_1 <- dets %>%  
    right_join(key, by = join_by(between(min_lag, start, end))) %>% 
    dplyr::select(hex, date_time, min_lag, start, end) %>% 
    filter(date_time != is.na(date_time)) %>% 
    mutate(
      passed_filter = 1
    )
  
  dets_2 <- dets %>% 
    left_join(dets_1, by = c("hex", "date_time", "min_lag"))
  
  dets_2$passed_filter[is.na(dets_2$passed_filter)] <- 0
  # unique(dets_2$passed_filter)
  dets_2 <- dets_2 %>%
    mutate(
      passed_filter_pwr = if_else(power >= 10 & passed_filter %in% 1, 
                                  false = 0, true = 1)
      )
  # glimpse(dets_2)
  nr <- nrow(dets_2)
  # summary(dets_2$min_lag)
  message(paste0("The filter identified ", nr - sum(dets_2$passed_filter), 
                 " (", round((nr - sum(dets_2$passed_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false based on interval filter evaluating min_lag"))
  message(paste0("The filter identified ", nr - sum(dets_2$passed_filter_pwr), 
                 " (", round((nr - sum(dets_2$passed_filter_pwr))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false based on interval filter evaluating min_lag and power."))
  return(dets_2)
}

