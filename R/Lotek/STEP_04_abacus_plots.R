# ---- Load packages ----
{
  library(dplyr)
  library(ggplot2)
  library(glatos)
  library(ggtext)
  library(here)
  library(janitor)
  library(lubridate)
  library(purrr)
  library(readr) 
  library(stringr)
  library(tidyr)
  
}

# ---- bring in cleaned telemetry data ---- 
det <- read_rds(here::here("Saved-Data", 
                           "Lotek-cleaned-telemetry-data", 
                           "lotek_detections_false_detection_cleaned.rds"))

glimpse(det)

det <- det %>% 
  mutate(
    station = factor(station)
  ) %>% 
  filter(passed_filter == 1)

# ---- create abacus plot for each floy tag using for loop as example

fish_id <- unique(det$animal_id) 

for (i in 1:length(fish_id)) {
  
  # first we will filter our dataframe by fish id
  df <- det %>% 
    filter(animal_id %in% fish_id[i])
  # create our plot 
  p <- ggplot(data = df, aes(x = detection_timestamp_utc, y = station)) +
    geom_point(aes(fill = station), shape = 21, size = 3, alpha = 0.5) +
    geom_line(aes(group = 1)) + # we can remove line if it's distracting 
    scale_fill_viridis_d(begin = 0.25, end = 0.75,
                         option = "D", name = "Receiver") +
    theme_bw(
      base_size = 15
    ) +
    theme(panel.grid = element_blank(),
          plot.title = element_text(hjust = 0.5)
    ) +
    labs(
      title = paste("Floy Tag:", unique(df$animal_id), sep = " "),
      x = "Date",
      y = "Receiver")
  
  # then save our plot 
  ggsave(filename = here("plots", 
                         "Lotek", 
                         "abacus plots", 
                         paste0(unique(df$animal_id), ".png")), 
         height = 7, 
         width = 11
  )
}
dev.off() # clear cached images if any might error and that's fine 

# ---- create abacus plot for each floy tag using map from purrr ---- 

# we will first take our detections and split them by floy tag
# next we will iterate over ggsave using purrr::map, with our plot ggplot call 
# as the plot argument

det %>% 
  split(.$animal_id) %>% 
  map(~ ggsave( 
    filename = here("plots", 
                    "Lotek", 
                    "abacus plots", 
                    paste0(unique(.$animal_id),'.png')), 
    height = 7, 
    width = 11, 
    plot = 
      ggplot(data = ., aes(x = detection_timestamp_utc, y = station)) +
      geom_point(aes(fill = station), shape = 21, size = 3, alpha = 0.5) +
      geom_line(aes(group = 1)) + # we can remove line if it's distracting 
      scale_fill_viridis_d(begin = 0.25, end = 0.75,
                           option = "D", name = "Receiver") +
      theme_bw(
        base_size = 15
      ) +
      theme(panel.grid = element_blank(),
            plot.title = element_text(hjust = 0.5)
      ) +
      labs(
        title = paste("Floy Tag:", unique(.$animal_id), sep = " "),
        x = "Date",
        y = "Receiver")
  )
  )
