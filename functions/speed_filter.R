library(purrr)
library(sf)

speed_filter <- function(dets = NULL, 
                         id = "animal_id",
                         lon_name = "mean_longitude", 
                         lat_name = "mean_latitude", 
                         prj = NULL,
                         utm_epsg = NULL, 
                         n_det = NULL, 
                         max_dist = NULL
) {
  
  if(!(any(names(dets) %in% c("animal_id", 
                              "mean_longitude", 
                              "mean_latitude")))) {
    dets$animal_id <- dets[[id]]
    dets[[id]] <- NULL
    
    dets$mean_longitude <- dets[[lon_name]]
    dets[[lon_name]] <- NULL
    
    dets$mean_latitude <- dets[[lat_name]]
    dets[[lat_name]] <- NULL
  }
  
  if(is.null(utm_epsg)) {
    
    utm_epsg <- 32610
  } 
  if(is.null(prj)) {
    prj <- 4326
    
  }
  if(is.null(n_det)) {
    n_det <- 2
    
  }
  if(is.null(max_dist)) {
    max_dist <- 10000
    
  }
  # dets <- dtc
  fish <- sort(unique(dets$animal_id))
  # i <- 1
  
  for(i in 1:length(fish)){
    dtc2.i <- dets[dets$animal_id %in% fish[i], ]
    
    # dtc2.i <- dtc2.i |>
    #   arrange(location, first_detection, last_detection)
    dets$dist_m <- NA
    dets$tstep <- NA
    
    if(nrow(dtc2.i) > 1){
      llon <- as.vector(dtc2.i$mean_longitude)
      llat <- as.vector(dtc2.i$mean_latitude)
      lon <- append(NA, llon)
      lon <- as.vector(lon[-length(lon)])
      lat <- append(NA, llat)
      lat <- as.vector(lat[-length(lat)])
      
      to_from <- data.frame(lon, lat, llon, llat)
      
      # to_from
  
      
      to_from_sf <- to_from |> 
        na.omit() |>
        purrr::pmap(make_line) |> 
        st_as_sfc(crs = prj) |>
        st_sf()
      
      st_geometry(to_from_sf) <- "geometry"
      
      to_from_sf <- sf::st_transform(to_from_sf, crs = utm_epsg)
      
      to_from_sf$dist_m <- st_length(to_from_sf) |> 
        as.numeric() 
      
      to_from_sf
      
      dtc2.i$dist_m <- append(NA, to_from_sf$dist_m) 
      
      cur_time <- as.vector(dtc2.i$first_detection)
      pt <- append(NA, as.vector(dtc2.i$last_detection))
      pt <- as.vector(pt[-length(pt)])
      dtc2.i$tstep <- cur_time - pt
      
      
      
      dets[row.names(dtc2.i), ] <- dtc2.i
      
    } 
    # dets[is.na(dets)] <- 0
    
    dets <- dets[order(dets$animal_id, dets$first_detection), ]
    dets$speed <- dets$dist_m / dets$tstep
  }
  dets_2 <- dets %>%
    mutate(
      passed_filter_speed = if_else(num_detections >= n_det & dist_m < max_dist, 
                                  false = 1, true = 0)
      )
  
  return(dets_2)
}
