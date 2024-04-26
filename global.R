####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - global.R
# - ui.R
# - server.R
####################################################

#==============================================================================
#Global Environment
options(warn = -1)

## SET MAPBOX API
#Mapbox API--------------------------------------------
#Variables are defined on .Renviron
styleUrl <- Sys.getenv("MAPBOX_STYLE")
accessToken <- Sys.getenv("MAPBOX_ACCESS_TOKEN")
#Mapbox API--------------------------------------------

#Packages
if(!require(shiny)) install.packages("shiny")
if(!require(shinydashboard)) install.packages("shinydashboard")
if(!require(shinycssloaders)) install.packages("shinycssloaders")
if(!require(shinyWidgets)) install.packages("shinyWidgets")
if(!require(leaflet)) install.packages("leaflet")
if(!require(leaflet.mapboxgl)) install.packages("leaflet.mapboxgl")
if(!require(sf)) install.packages("sf")
if(!require(tidyverse)) install.packages("tidyverse")

#Dataframe
df <- readr::read_csv("data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv")

#Leaflet用の凡例
breaks <- c(-100, -75, -50, -25, 0, 25, 50, 75, 100, 200)
breaks_label <- sapply(1:length(breaks), function(x) { paste0(sprintf("%3.1f", breaks[x-1]), " - ", sprintf("%3.1f", breaks[x])) })[-1]
pal1 <- leaflet::colorBin("Blues", domain = 1:10, bins = 10)
pal2 <- leaflet::colorBin("Reds", domain = 1:10, bins = 10)
color_val <- c(pal1(8), pal1(6), pal1(3), pal1(2), pal2(3), pal2(4), pal2(6), pal2(7), pal2(8))
leg_color_val <- c(color_val, "#E5E5E5")
leg_breaks_label <- c(breaks_label, "NA")
df_pal <- data.frame(color_value = leg_color_val, color_label = leg_breaks_label, stringsAsFactors = F)

#Shapefile
sfPref <- st_transform(read_sf(paste0("data/shp_pref/shp_poly_2005_pref00.shp"), crs = 4326))
sfMuni <- st_transform(read_sf(paste0("data/shp_city/shp_poly_2020_pref00_city_seirei.shp"), crs = 4326))

#地図描画用Shapefile
sfMuni <- sfMuni %>%
  dplyr::left_join(df, by = c("codeMuni" = "id_muni2020") ) %>%
  dplyr::mutate(ratio_color_group = cut(ratio_pop_age20_39, breaks = breaks, labels = breaks_label)) %>%
  dplyr::mutate(ratio_color_group = as.character(ratio_color_group)) %>%
  dplyr::left_join(df_pal, by = c("ratio_color_group" = "color_label"))%>%
  dplyr::rename(ratio_color_value = color_value) %>%
  dplyr::mutate(ratio_color_value = if_else(is.na(ratio_color_value), "#E5E5E5", ratio_color_value)) 
