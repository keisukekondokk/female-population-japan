####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - 市区町村パネルデータの作成
####################################################

#Packages
library(tidyverse)

#市区町村コンバータ
dfTemp <- readr::read_csv("data/csv_municipality_converter/municipality_converter_jp.csv")
dfMuniConv <- dfTemp %>%
  dplyr::select(merge_id_muni, id_muni2020, name_muni2020)
rm(dfTemp)

#昭和55年国勢調査
df1980 <- readr::read_csv("data/csv_pop/original/population_census_1980.csv", skip = 10)

#データ整形
dfTemp1980 <- df1980 %>%
  dplyr::mutate(year = 1980) %>%
  dplyr::rename(cl_code_gender = `男女Ａ030001 コード`) %>%
  dplyr::rename(cl_name_gender = `男女Ａ030001`) %>%
  dplyr::rename(code_muni = `市区町村２．９030005 コード`) %>%
  dplyr::rename(name_muni = `市区町村２．９030005`) %>%
  dplyr::rename(pop_total = `総数【人】`) %>%
  dplyr::rename(pop_age20_24 = `２０－２４歳【人】`) %>%
  dplyr::rename(pop_age25_29 = `２５－２９歳【人】`) %>%
  dplyr::rename(pop_age30_34 = `３０－３４歳【人】`) %>%
  dplyr::rename(pop_age35_39 = `３５－３９歳【人】`) %>%
  dplyr::rename(pop_ageunknown = `年齢不詳【人】`) %>%
  dplyr::select(year, cl_code_gender, cl_name_gender, code_muni, name_muni, starts_with("pop"))

#変数追加
dfFemale1980 <- dfTemp1980 %>%
  dplyr::mutate(cl_code_gender = as.numeric(cl_code_gender))  %>%
  dplyr::filter(cl_code_gender == 2) %>%
  dplyr::mutate(code_muni = as.numeric(code_muni)) %>%
  dplyr::mutate(pop_age20_39 = pop_age20_24 + pop_age25_29 + pop_age30_34 + pop_age35_39) %>%
  dplyr::mutate(pop_ageunknown = str_replace_all(pop_ageunknown, ",", "")) %>%
  dplyr::mutate(pop_ageunknown = if_else(pop_ageunknown == "***", NA_character_, pop_ageunknown)) %>%
  dplyr::mutate(pop_ageunknown = as.numeric(pop_ageunknown))

#2020年市区町村コードを追加
dfFemaleTemp1980 <- dfFemale1980 %>%
  dplyr::left_join(dfMuniConv, by = c("code_muni" = "merge_id_muni")) %>%
  dplyr::filter(is.na(id_muni2020)==0)

#2020年単位で再集計
dfFemaleAgg1980 <- dfFemaleTemp1980 %>%
  dplyr::group_by(id_muni2020) %>%
  dplyr::summarise(
    year = first(year),
    id_muni2020 = first(id_muni2020),
    name_muni2020 = first(name_muni2020),
    pop_total = sum(pop_total),
    pop_age20_39 = sum(pop_age20_39),
    pop_ageunknown = sum(pop_ageunknown)
  )

#保存
readr::write_csv(dfFemaleAgg1980, "data/csv_pop/population_census_1980_female_age20_39.csv")




