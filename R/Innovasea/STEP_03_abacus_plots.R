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
                           "Innovasea-cleaned-telemetry-data", 
                           "false_detection_cleaned_telemetry_data.rds"))

glimpse(det)

det <- det %>% 
  mutate(
    name = factor(name)
  ) 

# ---- create abacus plot for each floy tag using for loop as example

fish_id <- unique(det$floy_tag) 

for (i in 1:length(fish_id)) {
  
  # first we will filter our dataframe by fish id
  df <- det %>% 
    filter(floy_tag %in% fish_id[i])
  # create our plot 
  p <- ggplot(data = df, aes(x = detection_timestamp_utc, y = name)) +
    geom_point(aes(fill = name), shape = 21, size = 3, alpha = 0.5) +
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
      title = paste("Floy Tag:", unique(df$floy_tag), sep = " "),
      x = "Date",
      y = "Receiver")
  
  # then save our plot 
  ggsave(filename = here("plots", 
                         "Innovasea", 
                         "abacus plots", 
                         paste0(unique(df$floy_tag), ".png")), 
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
  split(.$floy_tag) %>% 
  map(~ ggsave( 
    filename = here("plots", 
                    "Innovasea", 
                    "abacus plots", 
                    paste0(unique(.$floy_tag),'.png')), 
    height = 7, 
    width = 11, 
    plot = 
      ggplot(data = ., aes(x = detection_timestamp_utc, y = name)) +
      geom_point(aes(fill = name), shape = 21, size = 3, alpha = 0.5) +
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
        title = paste("Floy Tag:", unique(.$floy_tag), sep = " "),
        x = "Date",
        y = "Receiver")
  )
  )
