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
df1980 <- read_csv("data/csv_pop/population_census_1980_female_age20_39.csv")
df2020 <- read_csv("data/csv_pop/population_census_2020_female_age20_39.csv")

#Wide形式パネルデータ
df <- df1980 %>%
  dplyr::select(-year) %>%
  dplyr::left_join(df2020 %>% dplyr::select(id_muni2020, starts_with("pop")), by = "id_muni2020", suffix = c("_1980", "_2020"))

#変化率の計算
df <- df %>%
  dplyr::mutate(ratio_pop_total = 100 * (pop_total_2020 / pop_total_1980 - 1) ) %>%
  dplyr::mutate(ratio_pop_age20_39 = 100 * (pop_age20_39_2020 / pop_age20_39_1980 - 1) )

#保存
readr::write_csv(df, "data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv")
writexl::write_xlsx(df, "data/csv_pop/population_census_panel_1980_2020_female_age20_39.xlsx")
