####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - 市区町村パネルデータの作成
####################################################

#Packages
library(tidyverse)
library(writexl)

#市区町村コンバータ
dfTemp <- readr::read_csv("data/csv_municipality_converter/municipality_converter_jp.csv")
dfMuniConv <- dfTemp %>%
  dplyr::select(merge_id_muni, id_muni2020, name_muni2020)
rm(dfTemp)

#令和2年国勢調査
df2020 <- readr::read_csv("data/csv_pop/original/population_census_2020.csv", skip = 10)

#データ整形
dfTemp2020 <- df2020 %>%
  dplyr::mutate(year = 2020) %>%
  dplyr::rename(cl_code_gender = `男女 コード`) %>%
  dplyr::rename(cl_name_gender = `男女`) %>%
  dplyr::rename(code_muni = `全国，都道府県，市区町村（2000年市区町村含む） コード`) %>%
  dplyr::rename(name_muni = `全国，都道府県，市区町村（2000年市区町村含む）`) %>%
  dplyr::rename(pop_total = `総数`) %>%
  dplyr::rename(pop_age20_24 = `20～24歳`) %>%
  dplyr::rename(pop_age25_29 = `25～29歳`) %>%
  dplyr::rename(pop_age30_34 = `30～34歳`) %>%
  dplyr::rename(pop_age35_39 = `35～39歳`) %>%
  dplyr::rename(pop_ageunknown = `年齢「不詳」`) %>%
  dplyr::mutate(pop_total = str_replace_all(pop_total, ",", "")) %>%
  dplyr::mutate(pop_age20_24 = str_replace_all(pop_age20_24, ",", "")) %>%
  dplyr::mutate(pop_age25_29 = str_replace_all(pop_age25_29, ",", "")) %>%
  dplyr::mutate(pop_age30_34 = str_replace_all(pop_age30_34, ",", "")) %>%
  dplyr::mutate(pop_age35_39 = str_replace_all(pop_age35_39, ",", "")) %>%
  dplyr::mutate(pop_ageunknown = str_replace_all(pop_ageunknown, ",", "")) %>%
  dplyr::mutate(pop_total = if_else(pop_total == "-", NA_character_, pop_total)) %>%
  dplyr::mutate(pop_age20_24 = if_else(pop_age20_24 == "-", NA_character_, pop_age20_24)) %>%
  dplyr::mutate(pop_age25_29 = if_else(pop_age25_29 == "-", NA_character_, pop_age25_29)) %>%
  dplyr::mutate(pop_age30_34 = if_else(pop_age30_34 == "-", NA_character_, pop_age30_34)) %>%
  dplyr::mutate(pop_age35_39 = if_else(pop_age35_39 == "-", NA_character_, pop_age35_39)) %>%
  dplyr::mutate(pop_ageunknown = if_else(pop_ageunknown == "-", NA_character_, pop_ageunknown)) %>%
  dplyr::mutate(pop_total = as.numeric(pop_total)) %>%
  dplyr::mutate(pop_age20_24 = as.numeric(pop_age20_24)) %>%
  dplyr::mutate(pop_age25_29 = as.numeric(pop_age25_29)) %>%
  dplyr::mutate(pop_age30_34 = as.numeric(pop_age30_34)) %>%
  dplyr::mutate(pop_age35_39 = as.numeric(pop_age35_39)) %>%
  dplyr::mutate(pop_ageunknown = as.numeric(pop_ageunknown)) %>%
  dplyr::select(year, cl_code_gender, cl_name_gender, code_muni, name_muni, starts_with("pop"))

#変数追加
listDf2020 <- lapply(0:2, function(x){
  dfTemp2020 %>%
    dplyr::mutate(cl_code_gender = as.numeric(cl_code_gender)) %>%
    dplyr::filter(cl_code_gender == x) %>%
    dplyr::mutate(code_muni = as.numeric(code_muni)) %>%
    dplyr::mutate(flag_drop = str_detect(name_muni, "（旧：.+）")) %>%
    dplyr::filter(flag_drop == 0) %>%
    dplyr::mutate(pop_age20_39 = dplyr::select(., pop_age20_24, pop_age25_29, pop_age30_34, pop_age35_39) %>% rowSums(na.rm = TRUE)) %>%
    dplyr::mutate(pop_age20_39 = if_else(pop_age20_39 == 0, NA_real_, pop_age20_39)) 
})


#2020年市区町村コードを追加
listDfTemp2020 <- lapply(1:3, function(x){
  listDf2020[[x]] %>%
    dplyr::left_join(dfMuniConv, by = c("code_muni" = "merge_id_muni")) %>%
    dplyr::filter(is.na(id_muni2020) == 0)
})

#2020年単位で再集計
listDfAgg2020 <- lapply(1:3, function(x){
  listDfTemp2020[[x]] %>%
    dplyr::group_by(id_muni2020) %>%
    dplyr::summarise(
      year = first(year),
      id_muni2020 = first(id_muni2020),
      name_muni2020 = first(name_muni2020),
      cl_code_gender = first(cl_code_gender), 
      pop_total = sum(pop_total),
      pop_age20_39 = sum(pop_age20_39),
      pop_ageunknown = sum(pop_ageunknown)
    )
})
  
#保存
readr::write_csv(listDfAgg2020[[1]], "data/csv_pop/population_census_2020_total_age20_39.csv")
writexl::write_xlsx(listDfAgg2020[[1]], "data/csv_pop/population_census_2020_total_age20_39.xlsx")
#保存
readr::write_csv(listDfAgg2020[[2]], "data/csv_pop/population_census_2020_male_age20_39.csv")
writexl::write_xlsx(listDfAgg2020[[2]], "data/csv_pop/population_census_2020_male_age20_39.xlsx")
#保存
readr::write_csv(listDfAgg2020[[3]], "data/csv_pop/population_census_2020_female_age20_39.csv")
writexl::write_xlsx(listDfAgg2020[[3]], "data/csv_pop/population_census_2020_female_age20_39.xlsx")

