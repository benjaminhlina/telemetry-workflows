library(purrr)
library(sf)

speed_filter <- function(dets, 
                         id = "animal_id",
                         prj = 4326,
                         utm_epsg = 36210, 
                         ) {
  
  if(!any(names(dets) %in% c("animal_id"))) {
    dets$animal_id <- dets[[id]]
    dets[[id]] <- NULL
  }
  
  dets <- dtc
  fish <- sort(unique(dets$animal_id))
  for(i in 1:length(fish)){
    dtc2.i <- dets[dets$animal_id %in% fish[i], ]
    
    if(nrow(dtc2.i) > 1){
      llon <- as.vector(dtc2.i$mean_longitude)
      llat <- as.vector(dtc2.i$mean_latitude)
      lon <- append(NA, llon)
      lon <- as.vector(lon[-length(lon)])
      lat <- append(NA, llat)
      lat <- as.vector(lat[-length(lat)])
      
      to_from <- data.frame(lon, lat, llon, llat)
      
      to_from
      to <- data.frame(lon, lat)
      from <- data.frame(llon, llat) 
      
      to_from
      # to_sf <- to |> 
      #   na.omit() |> 
      #   st_as_sf(coords = c("lon", "lat"), 
      #            crs = 4326) |>
      #   st_transform(crs = 32618)
      # from_sf <- from |> 
      #   na.omit() |> 
      #   st_as_sf(coords = c("llon", "llat"), 
      #            crs = 4326) |>
      #   st_transform(crs = 32618)
      
      to_from_sf <- to_from |> 
        na.omit() |>
        purrr::pmap(make_line) |> 
        st_as_sfc(crs = prj) |>
        st_sf() %>% 
        st_transform(crs = utm_epsg)
      st_geometry(to_from_sf) <- "geometry"
      
      to_from_sf$dist_m <- st_length(to_from_sf) |> 
        as.numeric()
    
      to_from_sf
      
      }
  }
}
complete.cases()