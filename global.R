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
if(!require(DT)) install.packages("DT")

#Dataframe
df <- readr::read_csv("data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv")

#サマリー
stat <- summary(df$ratio_pop_age20_39)
cntNumMuni_Positive <- sum(as.integer(df$ratio_pop_age20_39 >= 0), na.rm = TRUE)
cntNumMuni_LessThan50 <- sum(as.integer(df$ratio_pop_age20_39 < -50), na.rm = TRUE)
cntNumMuni_Negative_100to75 <- sum(as.integer(df$ratio_pop_age20_39 >= -100 & df$ratio_pop_age20_39 < -75), na.rm = TRUE)
cntNumMuni_Negative_75to50 <- sum(as.integer(df$ratio_pop_age20_39 >= -75 & df$ratio_pop_age20_39 < -50), na.rm = TRUE)
cntNumMuni_Negative_50to25 <- sum(as.integer(df$ratio_pop_age20_39 >= -50 & df$ratio_pop_age20_39 < -25), na.rm = TRUE)
cntNumMuni_Negative_00to25 <- sum(as.integer(df$ratio_pop_age20_39 >= -25 & df$ratio_pop_age20_39 < 0), na.rm = TRUE)
cntNumMuni_Positive_00to25 <- sum(as.integer(df$ratio_pop_age20_39 >= 0 & df$ratio_pop_age20_39 < 25), na.rm = TRUE)
cntNumMuni_Positive_25to50 <- sum(as.integer(df$ratio_pop_age20_39 >= 25 & df$ratio_pop_age20_39 < 50), na.rm = TRUE)
cntNumMuni_Positive_50to75 <- sum(as.integer(df$ratio_pop_age20_39 >= 50 & df$ratio_pop_age20_39 < 75), na.rm = TRUE)
cntNumMuni_Positive_75to100 <- sum(as.integer(df$ratio_pop_age20_39 >= 75 & df$ratio_pop_age20_39 < 100), na.rm = TRUE)
cntNumMuni_Positive_100to200 <- sum(as.integer(df$ratio_pop_age20_39 >= 100 & df$ratio_pop_age20_39 < 200), na.rm = TRUE)
cntNumMuni_NA <- sum(as.integer(is.na(df$ratio_pop_age20_39)), na.rm = TRUE)
cntNumMuni <- c(
  cntNumMuni_Negative_100to75, 
  cntNumMuni_Negative_75to50, 
  cntNumMuni_Negative_50to25,
  cntNumMuni_Negative_00to25,
  cntNumMuni_Positive_00to25,
  cntNumMuni_Positive_25to50,
  cntNumMuni_Positive_50to75,
  cntNumMuni_Positive_75to100,
  cntNumMuni_Positive_100to200,
  cntNumMuni_NA
)
  
#Leaflet用の凡例
breaks <- c(-100, -75, -50, -25, 0, 25, 50, 75, 100, 200)
breaks_label <- sapply(1:length(breaks), function(x) { paste0(sprintf("%3.1f", breaks[x-1]), " - ", sprintf("%3.1f", breaks[x])) })[-1]
breaks_label_legend <- sapply(1:length(breaks_label), function(x){ paste0(breaks_label[x], " (", cntNumMuni[x], ")")})
pal1 <- leaflet::colorBin("Blues", domain = 1:10, bins = 10)
pal2 <- leaflet::colorBin("Reds", domain = 1:10, bins = 10)
color_val <- c(pal1(8), pal1(6), pal1(3), pal1(2), pal2(3), pal2(4), pal2(6), pal2(7), pal2(8))
leg_color_val <- c("#000000", color_val)
leg_breaks_label <- c(paste0("NA (", cntNumMuni_NA, ")"), breaks_label_legend)
df_pal <- data.frame(color_value = leg_color_val, color_label = leg_breaks_label, stringsAsFactors = F)

#Shapefile
sfPref <- st_transform(read_sf(paste0("data/shp_pref/shp_poly_2005_pref00.shp"), crs = 4326))
sfMuni <- st_transform(read_sf(paste0("data/shp_city/shp_poly_2020_pref00_city_seirei.shp"), crs = 4326))

#地図描画用Shapefile
sfMuni <- sfMuni %>%
  dplyr::left_join(df, by = c("codeMuni" = "id_muni2020") ) %>%
  dplyr::mutate(ratio_color_group = cut(ratio_pop_age20_39, breaks = breaks, labels = breaks_label_legend)) %>%
  dplyr::mutate(ratio_color_group = as.character(ratio_color_group)) %>%
  dplyr::left_join(df_pal, by = c("ratio_color_group" = "color_label"))%>%
  dplyr::mutate(ratio_color_group = if_else(is.na(ratio_color_group), paste0("NA (", cntNumMuni_NA, ")"), ratio_color_group)) %>%
  dplyr::rename(ratio_color_value = color_value) %>%
  dplyr::mutate(ratio_color_value = if_else(is.na(ratio_color_value), "#000000", ratio_color_value)) 
