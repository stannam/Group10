
# Load data 
Data <- read_csv(here::here("data", "fire_archive_M6_96619.csv"))
date_data <- Data %>%
  select(acq_date) %>%
  unique()

map_data <- Data %>%
  select(latitude, longitude, frp, brightness, acq_date) 

# Plot funciton 
first_date <- date_data %>% slice(1)

make_plot <- function(input_date = first_date){
  input_date <- pull(input_date)
  select_data <- filter(map_data, acq_date %in% input_date)
  
  select_data <- select_data %>% select(-acq_date)
  
  # make the plot!
  world <- map_data("world", region = "Australia")
  
  p <- ggplot() +
    geom_polygon(world, mapping = aes(x=long,y=lat,group = group, fill = 5), alpha = 0.3) +
    scale_fill_continuous(guide = FALSE) +
    geom_point(select_data,mapping = aes(x=longitude,y=latitude, size = frp, color=brightness), alpha = 0.5) +
    xlab ("Longitude, degree(East as positive)") +
    ylab ("Latitude, degree(North as positive)") +
    ggtitle('Brightness and Radiation Power vs. Geometric info') +
    geom_polygon(fill="lightgray", colour = "white")+
    theme(plot.title = element_text(hjust = 0.5, size = 14), legend.title = element_text(size=12))

  ggplotly(p)
  
}

# Dash Components
dropdown_list <- dccDropdown(
  id = 'map_dropdown',
  options=list(
    list(label = "By_Date", value = '1'),
    list(label = "All", value = '2')
  ),
  value = '1'
)

graph <- dccGraph(
  id = 'map_graph_by_date',
  figure = make_plot()
)

slider <- dccRangeSlider(
  id = 'map_slider',
  min = 1,
  max = 61,
  marks = list(
    "1" = as.Date(1, origin = "2019-08-10"),
    "11" = as.Date(11, origin = "2019-08-10"),
    "21" = as.Date(21, origin = "2019-08-10"),
    "31" = as.Date(31, origin = "2019-08-10"),
    "41" = as.Date(41, origin = "2019-08-10"),
    "51" = as.Date(51, origin = "2019-08-10"),
    "61" = as.Date(61, origin = "2019-08-10")
  ),
  value = list(1,11)
)

# slider <- dccSlider(
#   id = 'map_slider',
#   min = 1,
#   max = 61,
#   marks = list(
#     "1" = list('label' = as.Date(1, origin = "2019-08-10")),
#     "11" = list('label' = as.Date(11, origin = "2019-08-10")),
#     "21" = list('label' = as.Date(21, origin = "2019-08-10")),
#     "31" = list('label' = as.Date(31, origin = "2019-08-10")),
#     "41" = list('label' = as.Date(41, origin = "2019-08-10")),
#     "51" = list('label' = as.Date(51, origin = "2019-08-10")),
#     "61" = list('label' = as.Date(61, origin = "2019-08-10"))
#   ),
#   value = 1
# )

map_markdown <- dccMarkdown(
  "Here is the wildfire condition upon the location.
  
  Date could be selected through the slider below the map. To see the fire condition over all time, select 'All' in the dropdown list on the left. 
  
  "
)

## sidebar
map_sidebar <- htmlDiv(
  list(
    htmlH3('Select by date or all:'),
    dropdown_list
  ),
  style = list('padding' = 10,
               'flex-basis' = '20%')
)

## main div
map_maindiv <- htmlDiv(
  id = 'map_maindiv',
  list(
    # Show the map by date by default
    htmlH2('Fire on each day on map'),
    map_markdown,
    htmlH4(id = 'slider_label'),
    graph,
    slider
  ),
  style = list('padding' = 10,
             'flex-basis' = '80%',
             'justify-content' = 'center')
)

tab_map <- htmlDiv(
  list(
    map_sidebar,
    map_maindiv
  ),
  style = list('display' = 'flex')
)