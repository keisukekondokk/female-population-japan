####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - 市区町村パネルデータの作成
####################################################

#Packages
library(tidyverse)
library(writexl)

#Dataframe
listDf1980 <- lapply(c("total", "male", "female"), function(x){
  filename1980 <- paste0("data/csv_pop/population_census_1980_", x, "_age20_39.csv")
  df1980 <- read_csv(filename1980)
})

#Dataframe
listDf2020 <- lapply(c("total", "male", "female"), function(x){
  filename2020 <- paste0("data/csv_pop/population_census_2020_", x, "_age20_39.csv")
  df2020 <- read_csv(filename2020)
})

#Wide形式パネルデータ
listDf <- lapply(1:3, function(x){
  listDf1980[[x]] %>%
    dplyr::select(-year) %>%
    dplyr::left_join(listDf2020[[x]] %>% dplyr::select(id_muni2020, starts_with("pop")), by = "id_muni2020", suffix = c("_1980", "_2020"))
})

#変化率の計算
listDf <- lapply(1:3, function(x){
  listDf[[x]] %>%
    dplyr::mutate(ratio_pop_total = 100 * (pop_total_2020 / pop_total_1980 - 1) ) %>%
    dplyr::mutate(ratio_pop_age20_39 = 100 * (pop_age20_39_2020 / pop_age20_39_1980 - 1) )
})

#保存
readr::write_csv(listDf[[1]], "data/csv_pop/population_census_panel_1980_2020_total_age20_39.csv")
writexl::write_xlsx(listDf[[1]], "data/csv_pop/population_census_panel_1980_2020_total_age20_39.xlsx")
#保存
readr::write_csv(listDf[[2]], "data/csv_pop/population_census_panel_1980_2020_male_age20_39.csv")
writexl::write_xlsx(listDf[[2]], "data/csv_pop/population_census_panel_1980_2020_male_age20_39.xlsx")
#保存
readr::write_csv(listDf[[3]], "data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv")
writexl::write_xlsx(listDf[[3]], "data/csv_pop/population_census_panel_1980_2020_female_age20_39.xlsx")
