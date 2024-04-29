# 若年女性人口変化率1980-2020


人口戦略会議(2024)で提案された変数に対応して、昭和55年国勢調査と令和2年国勢調査を用いて、1980年から2020年の間の20歳から39歳までの女性人口の変化率を地図上で可視化しています。  

Webアプリ：若年女性人口変化率1980-2020  
URL: https://keisuke-kondo.shinyapps.io/female-population-japan/

[![若年女性人口変化率1980-2020](www/female-population-japan.png "若年女性人口変化率1980-2020")](https://keisuke-kondo.shinyapps.io/female-population-japan/)

1980年（昭和55年）と2020年（令和2年）では市区町村の境界が異なるため、厳密には同じ自治体単位で人口を比較することができません。そこで令和2年国勢調査の調査日である2020年10月1日時点の自治体単位に基づいて、昭和55年国勢調査の市区町村人口を再集計し、異時点間の人口を比較しようとしています。データを解釈する際には注意してください。なお近藤(2019)による市区町村コンバータを用いて再集計をしています。

### 参考文献

- 近藤恵介 (2019) 市町村合併を考慮した市区町村パネルデータの作成, RIETIテクニカルペーパー No. 19-T-001.  
URL: https://www.rieti.go.jp/jp/publications/summary/19030013.html（2024年4月26日確認）
- 人口戦略会議 (2024)「地方自治体「持続可能性」分析レポート」、  
URL: https://www.hit-north.or.jp/information/2024/04/24/2171/（2024年4月26日確認）

## 作成者

近藤恵介  
独立行政法人経済産業研究所・上席研究員  
神戸大学経済経営研究所・准教授  
URL: https://keisukekondokk.github.io/  


## 利用規約
当サイトで公開している情報（以下「コンテンツ」）は、どなたでも自由に利用できます。コンテンツ利用に当たっては、本利用規約に同意したものとみなします。本利用規約の内容は、必要に応じて事前の予告なしに変更されることがありますので、必ず最新の利用規約の内容をご確認ください。

### 著作権
本コンテンツの著作権は、近藤恵介に帰属します。

### 第三者の権利
本コンテンツは「政府統計の総合窓口（e-Stat）」([https://www.e-stat.go.jp/](https://www.e-stat.go.jp/))より、「昭和55年国勢調査」、「令和2年国勢調査」、「統計地理情報システム」のデータに基づいて作成しています。本コンテンツを利用する際は、第三者の権利を侵害しないようにしてください。

### 免責事項
<ul>
<li>作成にあたり細心の注意を払っていますが、本サイトの内容の完全性・正確性・有用性等についていかなる保証を行うものでありません。</li>
<li>本サイトを利用したことによるすべての障害・損害・不具合等、作成者および作成者の所属するいかなる団体・組織とも、一切の責任を負いません。</li>
<li>本サイトは、事前の予告なく変更、移転、削除等が行われることがあります。</li>
</ul>

### その他
ここに記載された見解や意見は近藤恵介個人のものであり、必ずしも近藤恵介が所属する組織の見解を反映するものではありません。

本コンテンツに関する問い合わせについて、下記のEmailより近藤恵介宛までご連絡ください。  
Email: kondo-keisuke@rieti.go.jp

## ディレクトリ

<pre>
.
├── data //データファイル格納ディレクトリ
├── www //画像
├── .gitignore
├── LICENSE
├── _make_panel_data.R //昭和55年国勢調査と令和2年国勢調査からパネルデータを作成
├── _make_panel_data_1980.R //昭和55年国勢調査からデータセット作成
├── _make_panel_data_2020.R //令和2年国勢調査からデータセット作成
├── female-population-japan.Rproj
├── ui.R //Shiny App
├── global.R //Shiny App
├── server.R //Shiny App
└── README.md
</pre>

### パネルデータ

#### CSV (UTF-8)
- 全年齢総人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_total_age20_39.csv

- 20-39歳男性人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_male_age20_39.csv

- 20-39歳女性人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_female_age20_39.csv

#### EXCEL
- 全年齢総人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_total_age20_39.xlsx

- 20-39歳男性人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_male_age20_39.xlsx

- 20-39歳女性人口  
URL: https://github.com/keisukekondokk/female-population-japan/blob/main/data/csv_pop/population_census_panel_1980_2020_female_age20_39.xlsx



## データ出所

### 令和2年国勢調査（e-Stat）：表番号2-7-1、男女，年齢（5歳階級），国籍総数か日本人別人口－全国，都道府県，市区町村（2000年（平成12年）市区町村含む）

URL: https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02

### 昭和55年国勢調査（e-Stat）：表番号00101、男女の別（性別）（３），年齢５歳階級（２３），人口

URL: https://www.e-stat.go.jp/stat-search?page=1&toukei=00200521&bunya_l=02

### 統計地理情報システム（e-Stat）：都道府県・市区町村シェープファイル

URL: https://www.e-stat.go.jp/gis


## 更新履歴

2024年4月26日：ウェブ公開  
