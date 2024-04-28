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

  #withProgress
  withProgress(message = "データを読み込み中...", value = 0, {
    
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
          "<b>総女性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_total, 2), "% <br />",
          "<b>総女性人口(1980)：</b>　", format(sfMuni$pop_total_1980, big.mark = ",", scientific = FALSE), "人 <br />",
          "<b>総女性人口(2020)：</b>　", format(sfMuni$pop_total_2020, big.mark = ",", scientific = FALSE), "人 <br />"
        ),
        popupOptions = list(maxWidth = 500, closeOnClick = TRUE),
        label = paste0(sfMuni$nameMuni),
        labelOptions = labelOptions(
          style = list(
            "font-size" = "large"
          )
        ),
        group = "市区町村境界"
      ) %>%
      addPolygons(
        data = sfPref,
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
        overlayGroups = c("市区町村境界", "都道府県境界"),
        position = "topright",
        options = layersControlOptions(collapsed = TRUE)
      )
    
    #withProgress
    incProgress(0.8)
  })  
  
  #++++++++++++++++++++++++++++++++++++++
  #Ranking: Table1
  #++++++++++++++++++++++++++++++++++++++
  
  #DataTable
  dfDT <- df %>%
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
      )
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
      paste0(round(cntNumMuni_Positive)),
      "1980-2020年の過去40年間で20-39歳女性人口が増加した自治体数",
      icon = icon("money-check"),
      color = "red"
    )
  })
  
  #valueBox
  output$vBox2 <- renderValueBox({
    valueBox(
      paste0(round(cntNumMuni_LessThan50)),
      "1980-2020年の過去40年間で20-39歳女性人口が半減した自治体数",
      icon = icon("money-check"),
      color = "light-blue"
    )
  })
  
}
