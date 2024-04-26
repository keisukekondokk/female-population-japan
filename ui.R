####################################################
# (C) Keisuke Kondo
# Release Date: 2024-04-26
# 
# - global.R
# - ui.R
# - server.R
####################################################

dashboardPage(
  skin = "blue",
  #++++++++++++++++++++++++++++++++++++++
  #Header
  dashboardHeader(
    title = "若年女性人口変化率1980-2020",
    titleWidth = 350,
    tags$li(
      actionLink(
        "github",
        label = "",
        icon = icon("github"),
        href = "https://github.com/keisukekondokk/female-population-japan",
        onclick = "window.open('https://github.com/keisukekondokk/female-population-japan', '_blank')"
      ),
      class = "dropdown"
    )
  ),
  #++++++++++++++++++++++++++++++++++++++
  #SideBar
  dashboardSidebar(width = 150,
                   sidebarMenu(
                     menuItem(
                       "地図",
                       tabName = "tab_map1",
                       icon = icon("map")),
                     menuItem(
                       "はじめに",
                       tabName = "info",
                       icon = icon("info-circle"))
                   )
  ),
  #++++++++++++++++++++++++++++++++++++++
  #Body
  dashboardBody(
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
    tags$style(type = "text/css", "html, body {margin: 0; width: 100%; height: 100%;}"),
    tags$style(type = "text/css", "h2 {font-weight: bold; margin-top: 20px;}"),
    tags$style(type = "text/css", "h3 {font-weight: bold; margin-top: 15px;}"),
    tags$style(type = "text/css", "h4, h5 {font-weight: bold; text-decoration: underline; margin-top: 10px;}"),
    tags$style(
      type = "text/css",
      "#map1 {margin: 0; height: calc(100vh - 50px) !important;}"
    ),
    tags$style(
      type = "text/css",
      ".panel {padding: 7px; background-color: #FFFFFF; opacity: 1;} .panel:hover {opacity: 1;}"
    ),
    tags$style(
      type = "text/css",
      "#buttonMapUpdate {color: #FFFFFF;}"
    ),
    #++++++++++++++++++++++++++++++++++++++
    #Tab
    tabItems(
      #++++++++++++++++++++++++++++++++++++++
      tabItem(
        tabName = "tab_map1",
        fluidRow(
          style = "margin-top: -20px; margin-bottom: -20px;",
          leafletOutput("map1") %>%
            withSpinner(color = getOption("spinner.color", default = "#3C8EBC"))
        )
      ),
      #++++++++++++++++++++++++++++++++++++++
      tabItem(
        tabName = "info",
        fluidRow(
          style = "margin-bottom: -20px; margin-left: -30px; margin-right: -30px;",
          column(
            width = 12,
            div(
              class = "mx-0 px-0 col-sm-12 col-md-12 col-lg-10 col-xl-10",
              box(
                width = NULL,
                title = h2(span(icon("info-circle"), "はじめに")),
                solidHeader = TRUE,
                p("はじめに、下記の利用規約等をご一読ください。"),
                #------------------------------------------------------------------
                h3(style = "border-bottom: solid 1px black;", span(icon("fas fa-file-alt"), "利用規約")),
                p(
                  "当サイトで公開している情報（以下「コンテンツ」）は、どなたでも自由に利用できます。コンテンツ利用に当たっては、本利用規約に同意したものとみなします。本利用規約の内容は、必要に応じて事前の予告なしに変更されることがありますので、必ず最新の利用規約の内容をご確認ください。"
                ),
                #--------------------
                h4("著作権"),
                p("本コンテンツの著作権は、近藤恵介に帰属します。"),
                #--------------------
                h4("第三者の権利"),
                p(
                  "本コンテンツは「政府統計の総合窓口（e-Stat）」(https://www.e-stat.go.jp/)より、「昭和55年国勢調査」、「令和2年国勢調査」、「統計地理情報システム」のデータに基づいて作成しています。本コンテンツを利用する際は、第三者の権利を侵害しないようにしてください。"
                ),
                #--------------------
                h4("免責事項"),
                p("(a) 作成にあたり細心の注意を払っていますが、本サイトの内容の完全性・正確性・有用性等についていかなる保証を行うものでありません。"),
                p("(b) 本サイトを利用したことによるすべての障害・損害・不具合等、作成者および作成者の所属するいかなる団体・組織とも、一切の責任を負いません。"),
                p("(c) 本サイトは、事前の予告なく変更、移転、削除等が行われることがあります。"),
                #--------------------
                h4("その他"),
                p("本コンテンツに関する問い合わせについて、下記のEmailより近藤恵介宛までご連絡ください。"),
                p("Email: kondo-keisuke@rieti.go.jp"),
                #------------------------------------------------------------------
                h3(style = "border-bottom: solid 1px black;", span(icon("user-circle"), "作成者")),
                p(
                  "近藤恵介", br(),
                  "独立行政法人経済産業研究所・上席研究員", br(),
                  "神戸大学経済経営研究所・准教授"
                ),
                #------------------------------------------------------------------
                h3(style = "border-bottom: solid 1px black;", span(icon("database"), "データ出所")),
                h4("令和2年国勢調査（e-Stat）：表番号2-7-1、男女，年齢（5歳階級），国籍総数か日本人別人口－全国，都道府県，市区町村（2000年（平成12年）市区町村含む）"),
                p(
                  "URL: ",
                  a(
                    href = "https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02",
                    "https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02",
                    .noWS = "outside"
                  ),
                  .noWS = c("after-begin", "before-end")
                ), 
                h4("昭和55年国勢調査（e-Stat）：表番号00101、男女の別（性別）（３），年齢５歳階級（２３），人口"),
                p(
                  "URL: ",
                  a(
                    href = "https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02",
                    "https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02",
                    .noWS = "outside"
                  ),
                  .noWS = c("after-begin", "before-end")
                ), 
                h4("統計地理情報システム（e-Stat）：都道府県・市区町村シェープファイル"),
                p(
                  "URL: ",
                  a(
                    href = "https://www.e-stat.go.jp/",
                    "https://www.e-stat.go.jp/gis",
                    .noWS = "outside"
                  ),
                  .noWS = c("after-begin", "before-end")
                ),
                #------------------------------------------------------------------
                h3(style = "border-bottom: solid 1px black;", span(icon("receipt"), "1980-2020年の比較について")),
                h4("20-39歳女性人口変化率"),
                p("人口戦略会議(2024)で提案された変数に対応して、昭和55年国勢調査と令和2年国勢調査の市区町村データを用いて、20-39歳女性人口の変化率(%)を地図上に可視化しています。"),
                h4("市区町村パネルデータの作成方法"),
                p("1980年（昭和55年）と2020年（令和2年）では市区町村の境界が異なるため、厳密には同じ自治体単位で人口を比較することができません。そこで令和2年国勢調査の調査日である2020年10月1日時点の自治体単位に基づいて、昭和55年国勢調査の市区町村人口を再集計し、異時点間の人口を比較しようとしています。データを解釈する際には注意してください。"),
                p("なお近藤(2019)による市区町村コンバータを用いて再集計をしています。英語版はKondo (2023)を参照してくだい。"),
                h4("注意事項"),
                p("近年、国勢調査では個人属性に関して不詳の割合が増えています。本来は20-39歳女性が不詳に分類されている場合もあるため、市区町村によって変化率を過少評価もしくは過大評価している可能性はあります。"),
                h4("参考文献"),
                HTML(
                  "<ul>
                    <li>近藤恵介 (2019) 市町村合併を考慮した市区町村パネルデータの作成, RIETIテクニカルペーパー No. 19-T-001.<br>
                    URL: <a href='https://www.rieti.go.jp/jp/publications/summary/19030013.html' target='_blank'>https://www.rieti.go.jp/jp/publications/summary/19030013.html</a></li>
                    <li>Kondo, Keisuke (2023) 
Municipality-level Panel Data and Municipal Mergers in Japan, RIETI Technical Paper No. 23-T-001.<br>
                    URL: <a href='https://www.rieti.go.jp/jp/publications/summary/23020001.html' target='_blank'>https://www.rieti.go.jp/jp/publications/summary/23020001.html</a></li>
                  </ul>"
                ),              #------------------------------------------------------------------
                h3(style = "border-bottom: solid 1px black;", span(icon("calendar"), "更新履歴")),
                p(
                  "2024年4月26日：ウェブ公開", br(),
                )
              )
            )
          )
        )
      )
    )
  )
)