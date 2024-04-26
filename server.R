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
          "<b>20-39歳女性人口(1980)：</b>　", sfMuni$pop_age20_39_1980, "人 <br />",
          "<b>20-39歳女性人口(2020)：</b>　", sfMuni$pop_age20_39_2020, "人 <br />",
          "<hr />",
          "<b>総女性人口変化率(1980-2020年)：</b>　", round(sfMuni$ratio_pop_total, 2), "% <br />",
          "<b>総女性人口(1980)：</b>　", sfMuni$pop_total_1980, "人 <br />",
          "<b>総女性人口(2020)：</b>　", sfMuni$pop_total_2020, "人 <br />"
        ),
        popupOptions = list(maxWidth = 300, closeOnClick = TRUE),
        label = paste0(sfMuni$nameMuni),
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
        colors = rev(color_val),
        labels = rev(breaks_label),
        opacity = 1,
        title = "20-39歳女性人口変化率(%) <br /> (1980-2020年)"
      ) %>%
      addLayersControl(
        overlayGroups = c("市区町村境界", "都道府県境界"),
        position = "topright",
        options = layersControlOptions(collapsed = TRUE)
      )
    
    #withProgress
    incProgress(0.8)
  })  
}
