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

#Shapefile
sfPref0 <- st_transform(read_sf(paste0("data/shp_pref/shp_poly_2005_pref00.shp"), crs = 4326))
sfMuni0 <- st_transform(read_sf(paste0("data/shp_city/shp_poly_2020_pref00_city_seirei.shp"), crs = 4326))

#Dataframe
dfTotal <- readr::read_csv("data/csv_pop/population_census_panel_1980_2020_total_age20_39.csv")
dfMale <- readr::read_csv("data/csv_pop/population_census_panel_1980_2020_male_age20_39.csv")
dfFemale <- readr::read_csv("data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv")