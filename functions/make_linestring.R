make_line <- function(lon, lat, llon, llat) {
  # if(!any(names(dets) %in% c("lon", "lat", "llon", "llat"))) {
  #   dets$hex <- dets[[id]]
  #   dets[[id]] <- NULL
  #   
  #   dets$date_time <- dets[[timestamp]]
  #   dets[[timestamp]] <- NULL
  #   
  #   dets$min_lag <- dets[[min_lag_col]]
  #   dets[[min_lag_col]] <- NULL
  #   
  # }
  st_linestring(matrix(c(lon, llon, lat, llat), 2, 2,))
}