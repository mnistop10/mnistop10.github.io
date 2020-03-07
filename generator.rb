require 'json'
require 'nokogiri'

States = {
  "AL" => "Alabama",
  "AK" => "Alaska",
  "AZ" => "Arizona",
  "AR" => "Arkansas",
  "CA" => "California",
  "CO" => "Colorado",
  "CT" => "Connecticut",
  "DE" => "Delaware",
  "FL" => "Florida",
  "GA" => "Georgia",
  "HI" => "Hawaii",
  "ID" => "Idaho",
  "IL" => "Illinois",
  "IN" => "Indiana",
  "IA" => "Iowa",
  "KS" => "Kansas",
  "KY" => "Kentucky",
  "LA" => "Louisiana",
  "ME" => "Maine",
  "MD" => "Maryland",
  "MA" => "Massachusetts",
  "MI" => "Michigan",
  "MN" => "Minnesota",
  "MS" => "Mississippi",
  "MO" => "Missouri",
  "MT" => "Montana",
  "NE" => "Nebraska",
  "NV" => "Nevada",
  "NH" => "New Hampshire",
  "NJ" => "New Jersey",
  "NM" => "New Mexico",
  "NY" => "New York",
  "NC" => "North Carolina",
  "ND" => "North Dakota",
  "OH" => "Ohio",
  "OK" => "Oklahoma",
  "OR" => "Oregon",
  "PA" => "Pennsylvania",
  "RI" => "Rhode Island",
  "SC" => "South Carolina",
  "SD" => "South Dakota",
  "TN" => "Tennessee",
  "TX" => "Texas",
  "UT" => "Utah",
  "VT" => "Vermont",
  "VA" => "Virginia",
  "WA" => "Washington",
  "WV" => "West Virginia",
  "WI" => "Wisconsin",
  "WY" => "Wyoming"
}

def create_cell(json, b, cell)
  if json[cell].class == String
    b.td {
      b.text json[cell]
    }
  else
    b.td {
      b.span(class: "dotted", title: json[cell]['title'], ontouchstart: "t(event)") {
        b.text json[cell]['text']
      }
    }
  end
  nil
end

JSON_DATA = File.open("data.json") { |f| JSON.parse f.read }

builder = Nokogiri::HTML::Builder.new(:encoding => 'UTF-8') do |b|
  b.html(lang: "en") {
    b.head {
      b.title "MN is Top 10"
      b.link(href: "/style.css", rel: "stylesheet", type: "text/css")
      b.script "function t(e) { alert(e.target.title); }"
    }
    b.body {
      b.header {
        b.div(id: "hdiv") {
          b.a(class: "hlink current", href: "/") {
            b.text "MN is top 10!"
          }
          b.a(class: "hlink", href: "/about") {
            b.text "About"
          }
          b.a(class: "hlink", target: "_blank", href: "https://github.com/mnistop10/mnistop10.github.io") {
            b.text "GitHub"
          }
        }
      }
      b.div(id: "main") {
        b.p_ {
          b.text "Categories: "
          JSON_DATA['categories'].keys.each_with_index do |cat, i|
            if i > 0
              b.text ", "
            end
            b.a(href: "\##{cat.downcase.gsub(/\s/, '')}") {
              b.text cat
            }
          end
        }
        JSON_DATA['categories'].keys.each do |cat|
          b.h2(id: cat.downcase.gsub(/\s/, '')) {
            b.text cat
          }
          b.table {
            b.tr {
              [
                ["Ranking", "tc-statistic"],
                ["#", "tc-rank"],
                ["Value", "tc-value"],
                ["Who's beating MN?", "tc-beatenby"],
                ["Source", "tc-source"]
              ].each { |th| b.th(class: th[1]) { b.text th[0] } }
            }
            JSON_DATA['categories'][cat].each do |ranking|
              b.tr {
                ["ranking", "#", "value"].each { |cell| create_cell(ranking, b, cell) }
                b.td {
                  ranking['beaten_by'].each_with_index do |x, i|
                    if i > 0
                      b.text ", "
                    end
                    b.span(class: "dotted", title: "#{States[x[0]]}: #{x[1]}", ontouchstart: "t(event)") {
                      b.text x[0]
                    }
                  end
                }
                b.td {
                  b.a(href: ranking['source']['link'], target: "_blank") {
                    b.text ranking['source']['text']
                  }
                }
              }
            end
          }
        end
      }
    }
  }
end

p File.open("index.html", 'w') { |f| f.write builder.to_html }
