####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - global.R
# - ui.R
# - server.R
####################################################

server <- function(input, output, session) {
  ####################################
  ## VISUALIZATION
  ## - leaflet: Map
  ## - DT: datatable
  ####################################

  #++++++++++++++++++++++++++++++++++++++
  #Map: map1
  #++++++++++++++++++++++++++++++++++++++
  
  #Leaflet Object
  output$map1 <- renderLeaflet({
    #Leaflet    
    leaflet() %>%
      #Tile Layer from Mapbox
      addMapboxGL(
        accessToken = accessToken,
        style = styleUrl,
        setView = FALSE
      ) %>%
      setView(138.36834018134456, 38.01826932426196, zoom = 6)
  })
  
  #LeafletProxy
  map1_proxy <- leafletProxy("map1", session)

  #Switch Leaflet
  observeEvent(input$map1_button, {
    
    #---------------------------------------------------------------------------
    #LEAFLET for Button 1
    #---------------------------------------------------------------------------
    if(input$map1_button == 1) {
      
      #withProgress
      withProgress(message = "データを読み込み中...", value = 0, {
        
        #withProgress
        incProgress(0.2)
        
        #Dataframe
        df <- dfFemale
        
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
        cntNumMuni_Positive_100to200 <- sum(as.integer(df$ratio_pop_age20_39 >= 100 & df$ratio_pop_age20_39 < 300), na.rm = TRUE)
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
        breaks <- c(-100, -75, -50, -25, 0, 25, 50, 75, 100, 300)
        breaks_label <- sapply(1:length(breaks), function(x) { paste0(sprintf("%3.1f", breaks[x-1]), " - ", sprintf("%3.1f", breaks[x])) })[-1]
        breaks_label_legend <- sapply(1:length(breaks_label), function(x){ paste0(breaks_label[x], " (", cntNumMuni[x], ")")})
        pal1 <- leaflet::colorBin("Blues", domain = 1:10, bins = 10)
        pal2 <- leaflet::colorBin("Reds", domain = 1:10, bins = 10)
        color_val <- c(pal1(8), pal1(6), pal1(3), pal1(2), pal2(3), pal2(4), pal2(6), pal2(7), pal2(8))
        leg_color_val <- c("#000000", color_val)
        leg_breaks_label <- c(paste0("NA (", cntNumMuni_NA, ")"), breaks_label_legend)
        df_pal <- data.frame(color_value = leg_color_val, color_label = leg_breaks_label, stringsAsFactors = F)
        
        #地図描画用Shapefile
        sfMuni <- sfMuni0 %>%
          dplyr::left_join(df, by = c("codeMuni" = "id_muni2020") ) %>%
          dplyr::mutate(ratio_color_group = cut(ratio_pop_age20_39, breaks = breaks, labels = breaks_label_legend)) %>%
          dplyr::mutate(ratio_color_group = as.character(ratio_color_group)) %>%
          dplyr::left_join(df_pal, by = c("ratio_color_group" = "color_label"))%>%
          dplyr::mutate(ratio_color_group = if_else(is.na(ratio_color_group), paste0("NA (", cntNumMuni_NA, ")"), ratio_color_group)) %>%
          dplyr::rename(ratio_color_value = color_value) %>%
          dplyr::mutate(ratio_color_value = if_else(is.na(ratio_color_value), "#000000", ratio_color_value)) 
        
        #withProgress
        incProgress(0.5)
        
        #Leaflet
        map1_proxy %>%
          clearShapes() %>%
          clearControls() %>%
          #Polygon
          addPolygons(
            data = sfMuni,
            fillColor = ~ratio_color_value, 
            fillOpacity = 0.8,
            stroke = TRUE,
            color = "#FFFFFF", 
            weight = 1.0, 
            popup = paste0(
              "<b>市区町村コード：</b>　", sfMuni$codeMuni, "<br />",
              "<b>市区町村名：</b>　", sfMuni$nameMuni, "<br />",
              "<hr />",
              "<b>20-39歳女性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_age20_39, 2), "% <br />",
              "<b>20-39歳女性人口(1980)：</b>　", format(sfMuni$pop_age20_39_1980, big.mark = ",", scientific = FALSE), "人 <br />",
              "<b>20-39歳女性人口(2020)：</b>　", format(sfMuni$pop_age20_39_2020, big.mark = ",", scientific = FALSE), "人 <br />",
              "<hr />",
              "<b>全年齢女性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_total, 2), "% <br />",
              "<b>全年齢女性人口(1980)：</b>　", format(sfMuni$pop_total_1980, big.mark = ",", scientific = FALSE), "人 <br />",
              "<b>全年齢女性人口(2020)：</b>　", format(sfMuni$pop_total_2020, big.mark = ",", scientific = FALSE), "人 <br />"
            ),
            popupOptions = list(maxWidth = 500, closeOnClick = TRUE),
            label = paste0(sfMuni$nameMuni),
            labelOptions = labelOptions(
              style = list(
                "font-size" = "large"
              )
            ),
            group = "20-39歳女性人口変化率"
          ) %>%
          addPolygons(
            data = sfPref0,
            fill = FALSE, 
            color = "#303030", 
            weight = 2.5, 
            group = "都道府県境界",
          ) %>%
          addLegend(
            "topright",
            colors = rev(leg_color_val),
            labels = rev(leg_breaks_label),
            opacity = 1,
            title = "20-39歳女性人口変化率(%) <br /> (1980-2020年) <br /> ※括弧内の数値は自治体数"
          ) %>%
          addLayersControl(
            overlayGroups = c("20-39歳女性人口変化率", "都道府県境界"),
            position = "topright",
            options = layersControlOptions(collapsed = TRUE)
          )
        
        #withProgress
        incProgress(1.0)
      })
    }
    #---------------------------------------------------------------------------
    #LEAFLET for Button 2
    #---------------------------------------------------------------------------
    else if(input$map1_button == 2) {
      
      #withProgress
      withProgress(message = "データを読み込み中...", value = 0, {
        
        #withProgress
        incProgress(0.2)
        
        #SF Object
        #Dataframe
        df <- dfMale
        
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
        cntNumMuni_Positive_100to200 <- sum(as.integer(df$ratio_pop_age20_39 >= 100 & df$ratio_pop_age20_39 < 300), na.rm = TRUE)
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
        breaks <- c(-100, -75, -50, -25, 0, 25, 50, 75, 100, 300)
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
        sfMuni <- sfMuni0 %>%
          dplyr::left_join(df, by = c("codeMuni" = "id_muni2020") ) %>%
          dplyr::mutate(ratio_color_group = cut(ratio_pop_age20_39, breaks = breaks, labels = breaks_label_legend)) %>%
          dplyr::mutate(ratio_color_group = as.character(ratio_color_group)) %>%
          dplyr::left_join(df_pal, by = c("ratio_color_group" = "color_label"))%>%
          dplyr::mutate(ratio_color_group = if_else(is.na(ratio_color_group), paste0("NA (", cntNumMuni_NA, ")"), ratio_color_group)) %>%
          dplyr::rename(ratio_color_value = color_value) %>%
          dplyr::mutate(ratio_color_value = if_else(is.na(ratio_color_value), "#000000", ratio_color_value)) 
        
        #withProgress
        incProgress(0.5)
        
        #Leaflet
        map1_proxy %>%
          clearShapes() %>%
          clearControls() %>%
          #Polygon
          addPolygons(
            data = sfMuni,
            fillColor = ~ratio_color_value, 
            fillOpacity = 0.8,
            stroke = TRUE,
            color = "#FFFFFF", 
            weight = 1.0, 
            popup = paste0(
              "<b>市区町村コード：</b>　", sfMuni$codeMuni, "<br />",
              "<b>市区町村名：</b>　", sfMuni$nameMuni, "<br />",
              "<hr />",
              "<b>20-39歳男性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_age20_39, 2), "% <br />",
              "<b>20-39歳男性人口(1980)：</b>　", format(sfMuni$pop_age20_39_1980, big.mark = ",", scientific = FALSE), "人 <br />",
              "<b>20-39歳男性人口(2020)：</b>　", format(sfMuni$pop_age20_39_2020, big.mark = ",", scientific = FALSE), "人 <br />",
              "<hr />",
              "<b>全年齢男性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_total, 2), "% <br />",
              "<b>全年齢男性人口(1980)：</b>　", format(sfMuni$pop_total_1980, big.mark = ",", scientific = FALSE), "人 <br />",
              "<b>全年齢男性人口(2020)：</b>　", format(sfMuni$pop_total_2020, big.mark = ",", scientific = FALSE), "人 <br />"
            ),
            popupOptions = list(maxWidth = 500, closeOnClick = TRUE),
            label = paste0(sfMuni$nameMuni),
            labelOptions = labelOptions(
              style = list(
                "font-size" = "large"
              )
            ),
            group = "20-39歳男性人口変化率"
          ) %>%
          addPolygons(
            data = sfPref0,
            fill = FALSE, 
            color = "#303030", 
            weight = 2.5, 
            group = "都道府県境界",
          ) %>%
          addLegend(
            "topright",
            colors = rev(leg_color_val),
            labels = rev(leg_breaks_label),
            opacity = 1,
            title = "20-39歳男性人口変化率(%) <br /> (1980-2020年) <br /> ※括弧内の数値は自治体数"
          ) %>%
          addLayersControl(
            overlayGroups = c("20-39歳男性人口変化率", "都道府県境界"),
            position = "topright",
            options = layersControlOptions(collapsed = TRUE)
          )
        
        #withProgress
        incProgress(1.0)
      })
    }
    #---------------------------------------------------------------------------
    #LEAFLET for Button 3
    #---------------------------------------------------------------------------
    else if(input$map1_button == 3) {
      
      #withProgress
      withProgress(message = "データを読み込み中...", value = 0, {
        
        #withProgress
        incProgress(0.2)
        
        #Dataframe
        df <- dfTotal
        
        #サマリー
        stat <- summary(df$ratio_pop_total)
        cntNumMuni_Positive <- sum(as.integer(df$ratio_pop_total >= 0), na.rm = TRUE)
        cntNumMuni_LessThan50 <- sum(as.integer(df$ratio_pop_total < -50), na.rm = TRUE)
        cntNumMuni_Negative_100to75 <- sum(as.integer(df$ratio_pop_total >= stat['Min.'] & df$ratio_pop_total < -75), na.rm = TRUE)
        cntNumMuni_Negative_75to50 <- sum(as.integer(df$ratio_pop_total >= -75 & df$ratio_pop_total < -50), na.rm = TRUE)
        cntNumMuni_Negative_50to25 <- sum(as.integer(df$ratio_pop_total >= -50 & df$ratio_pop_total < -25), na.rm = TRUE)
        cntNumMuni_Negative_00to25 <- sum(as.integer(df$ratio_pop_total >= -25 & df$ratio_pop_total < 0), na.rm = TRUE)
        cntNumMuni_Positive_00to25 <- sum(as.integer(df$ratio_pop_total >= 0 & df$ratio_pop_total < 25), na.rm = TRUE)
        cntNumMuni_Positive_25to50 <- sum(as.integer(df$ratio_pop_total >= 25 & df$ratio_pop_total < 50), na.rm = TRUE)
        cntNumMuni_Positive_50to75 <- sum(as.integer(df$ratio_pop_total >= 50 & df$ratio_pop_total < 75), na.rm = TRUE)
        cntNumMuni_Positive_75to100 <- sum(as.integer(df$ratio_pop_total >= 75 & df$ratio_pop_total < 100), na.rm = TRUE)
        cntNumMuni_Positive_100to200 <- sum(as.integer(df$ratio_pop_total >= 100 & df$ratio_pop_total <= stat['Max.']), na.rm = TRUE)
        cntNumMuni_NA <- sum(as.integer(is.na(df$ratio_pop_total)), na.rm = TRUE)
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
        breaks <- c(-100, -75, -50, -25, 0, 25, 50, 75, 100, 300)
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
        sfMuni <- sfMuni0 %>%
          dplyr::left_join(df, by = c("codeMuni" = "id_muni2020") ) %>%
          dplyr::mutate(ratio_color_group = cut(ratio_pop_total, breaks = breaks, labels = breaks_label_legend)) %>%
          dplyr::mutate(ratio_color_group = as.character(ratio_color_group)) %>%
          dplyr::left_join(df_pal, by = c("ratio_color_group" = "color_label"))%>%
          dplyr::mutate(ratio_color_group = if_else(is.na(ratio_color_group), paste0("NA (", cntNumMuni_NA, ")"), ratio_color_group)) %>%
          dplyr::rename(ratio_color_value = color_value) %>%
          dplyr::mutate(ratio_color_value = if_else(is.na(ratio_color_value), "#000000", ratio_color_value)) 
        
        #withProgress
        incProgress(0.5)
        
        #Leaflet
        map1_proxy %>%
          clearShapes() %>%
          clearControls() %>%
          #Polygon
          addPolygons(
            data = sfMuni,
            fillColor = ~ratio_color_value, 
            fillOpacity = 0.8,
            stroke = TRUE,
            color = "#FFFFFF", 
            weight = 1.0, 
            popup = paste0(
              "<b>市区町村コード：</b>　", sfMuni$codeMuni, "<br />",
              "<b>市区町村名：</b>　", sfMuni$nameMuni, "<br />",
              "<hr />",
              "<b>全年齢総人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_total, 2), "% <br />",
              "<b>全年齢総人口(1980)：</b>　", format(sfMuni$pop_total_1980, big.mark = ",", scientific = FALSE), "人 <br />",
              "<b>全年齢総人口(2020)：</b>　", format(sfMuni$pop_total_2020, big.mark = ",", scientific = FALSE), "人 <br />"
            ),
            popupOptions = list(maxWidth = 500, closeOnClick = TRUE),
            label = paste0(sfMuni$nameMuni),
            labelOptions = labelOptions(
              style = list(
                "font-size" = "large"
              )
            ),
            group = "全年齢総人口変化率"
          ) %>%
          addPolygons(
            data = sfPref0,
            fill = FALSE, 
            color = "#303030", 
            weight = 2.5, 
            group = "都道府県境界",
          ) %>%
          addLegend(
            "topright",
            colors = rev(leg_color_val),
            labels = rev(leg_breaks_label),
            opacity = 1,
            title = "全年齢総人口変化率(%) <br /> (1980-2020年) <br /> ※括弧内の数値は自治体数"
          ) %>%
          addLayersControl(
            overlayGroups = c("全年齢総人口変化率", "都道府県境界"),
            position = "topright",
            options = layersControlOptions(collapsed = TRUE)
          )
        
        #withProgress
        incProgress(1.0)
      })
    }
    
  }, ignoreInit = FALSE)
  
  #++++++++++++++++++++++++++++++++++++++
  #Ranking: Table1
  #++++++++++++++++++++++++++++++++++++++

  #Stat Summary
  cntNumMuni_Female_Positive <- sum(as.integer(dfFemale$ratio_pop_age20_39 >= 0), na.rm = TRUE)
  cntNumMuni_Female_LessThan50 <- sum(as.integer(dfFemale$ratio_pop_age20_39 < -50), na.rm = TRUE)
  
  #DataTable
  dfDT <- dfFemale %>%
    dplyr::select(-pop_ageunknown_1980, -pop_ageunknown_2020) %>%
    dplyr::select(id_muni2020, name_muni2020, pop_total_1980, pop_total_2020, ratio_pop_total, pop_age20_39_1980, pop_age20_39_2020, ratio_pop_age20_39)
    
  #DataTable
  output$tableRatio <- renderDataTable({
    DT::datatable(
      dfDT, 
      class = 'cell-border stripe', 
      escape = FALSE,
      colnames = c(
        '市区町村<br />コード' = 'id_muni2020', 
        '市区町村名' = 'name_muni2020', 
        '総女性人口変化率<br />（1980-2020年）' = 'ratio_pop_total', 
        '総女性人口<br />（1980年）' = 'pop_total_1980', 
        '総女性人口<br />（2020年）' = 'pop_total_2020', 
        '20-39歳女性人口変化率<br />（1980-2020年）' = 'ratio_pop_age20_39', 
        '20-39歳女性人口<br />（1980年）' = 'pop_age20_39_1980', 
        '20-39歳女性人口<br />（2020年）' = 'pop_age20_39_2020'
      ),
      rownames = FALSE
    ) %>%
      DT::formatRound(columns = c(3, 4, 6, 7), digits = 0) %>%
      DT::formatRound(columns = c(5, 8), digits = 2)
    }, 
    options = list(
      autoWidth = TRUE, 
      scrollX = TRUE
    )
  )

  ## ++++++++++++++++++++++++++++++++++++++++++
  ## MAKE BOX
  ## ++++++++++++++++++++++++++++++++++++++++++
  
  #++++++++++++++++++++++++++++++++++++++
  #valueBox
  output$vBox1 <- renderValueBox({
    valueBox(
      paste0(round(cntNumMuni_Female_Positive)),
      "1980-2020年の過去40年間で20-39歳女性人口が増加した自治体数",
      icon = icon("map"),
      color = "red"
    )
  })
  
  #valueBox
  output$vBox2 <- renderValueBox({
    valueBox(
      paste0(round(cntNumMuni_Female_LessThan50)),
      "1980-2020年の過去40年間で20-39歳女性人口が半減した自治体数",
      icon = icon("map"),
      color = "light-blue"
    )
  })
  
}
