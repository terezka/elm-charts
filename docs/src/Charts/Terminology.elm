module Charts.Terminology exposing (view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S
import Svg.Attributes as SA
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS



view : H.Html msg
view =
  C.chart
    [ CA.height 350
    , CA.width 1000
    , CA.margin { top = 0, bottom = 15, left = 25, right = 0 }
    , CA.padding { top = 40, bottom = 30, left = 0, right = 0 }
    ]
    [ C.grid []
    , C.yLabels [ CA.withGrid ]
    , C.xAxis [ CA.noArrow ]

    , C.bars
        [ CA.margin 0.2
        , CA.spacing 0.15
        ]
        [ C.stacked
            [ C.bar .a [ CA.opacity 0.8, CA.borderWidth 1 ]
            , C.bar .b [ CA.opacity 0.8, CA.borderWidth 1 ]
            ]
        , C.bar .c [ CA.opacity 0.8, CA.borderWidth 1 ]
        ]
        data

    , C.line [ CA.color "#888", CA.tickLength 7, CA.x1 2.5, CA.x2 3.5, CA.y1 4, CA.moveDown 20 ]
    , C.label [ CA.moveDown 15 ] [ S.text "bin" ] { x = 3, y = 4 }

    , C.line [ CA.color "#888", CA.tickLength 7, CA.x1 2.5, CA.x2 2.7, CA.y1 3, CA.moveUp 15 ]
    , C.label [ CA.moveUp 20 ] [ S.text "bin margin" ] { x = 2.6, y = 3 }

    , C.line [ CA.color "#888", CA.tickLength 7, CA.x1 2.925, CA.x2 3.075, CA.y1 3, CA.moveUp 15 ]
    , C.label [ CA.moveUp 20 ] [ S.text "bin spacing" ] { x = 3, y = 3 }

    , C.line [ CA.color "#888", CA.tickLength 7, CA.tickDirection 360, CA.x1 0.5, CA.y1 0, CA.y2 3, CA.moveRight 26 ]
    , C.label [ CA.rotate 90, CA.moveRight 18 ] [ S.text "stack" ] { x = 0.5, y = 1.5 }

    , C.line [ CA.color "#888", CA.tickLength 7, CA.tickDirection 360, CA.x1 1.5, CA.y1 0, CA.y2 2, CA.moveRight 26 ]
    , C.label [ CA.rotate 90, CA.moveRight 18 ] [ S.text "bar #1 in stack" ] { x = 1.5, y = 1 }
    , C.line [ CA.color "#888", CA.tickLength 7, CA.tickDirection 360, CA.x1 1.5, CA.y1 2, CA.y2 4, CA.moveRight 26 ]
    , C.label [ CA.rotate 90, CA.moveRight 18 ] [ S.text "bar #2 in stack" ] { x = 1.5, y = 3 }
    , C.line [ CA.color "#888", CA.tickLength 7, CA.tickDirection 360, CA.x1 2, CA.y1 0, CA.y2 1, CA.moveRight 5 ]
    , C.label [ CA.rotate 90 ] [ S.text "bar" ] { x = 2, y = 0.5 }

    , C.line [ CA.color "#888", CA.x1 4, CA.y1 0, CA.x2Svg -10, CA.y2Svg -10, CA.break, CA.flip, CA.moveDown 15, CA.moveLeft 10 ]
    , C.label [ CA.moveDown 37, CA.moveLeft 25 ] [ S.text "bin label" ] { x = 4, y = 0 }
    , C.binLabels .label [ CA.moveDown 20 ]

    , C.eachBar <| \p bar ->
        if (CI.getData bar).label == "D"
        then
          [ C.label [ CA.moveDown 20, CA.color "white" ] [ S.text (String.fromFloat (CI.getY bar)) ] (CI.getTop p bar)
          , C.line [ CA.x1 (CI.getTop p bar).x, CA.y1 (CI.getTop p bar).y, CA.x2Svg -25, CA.moveDown 16, CA.moveLeft 10, CA.color "#888" ]
          , C.label [ CA.moveDown 10, CA.moveLeft 40, CA.alignRight, CA.rotate 90 ] [ S.text "bar label" ] (CI.getTop p bar)
          ]
        else []

    , C.eachStack <| \p stack ->
        if (CI.getOneData stack).label == "D" then
          let total = List.sum <| List.map CI.getY (CI.getMembers stack) in
          [ C.label [ CA.moveUp 10 ] [ S.text (String.fromFloat total) ] (CI.getTop p stack)
          , C.line [ CA.x1 (CI.getTop p stack).x, CA.y1 (CI.getTop p stack).y, CA.x2Svg -15, CA.y2Svg 10, CA.moveUp 13, CA.moveLeft 8, CA.color "#888", CA.break, CA.flip ]
          , C.label [ CA.moveUp 30 ] [ S.text "stack label" ] (CI.getTop p stack)
          ]
        else
          []
    ]


type alias Data =
  { x : Float
  , y : Float
  , z : Float
  , a : Float
  , b : Float
  , c : Float
  , label : String
  }


data : List Data
data =
  [ Data 1 4 3 2 1 2 "A"
  , Data 2 5 2 2 2 1 "B"
  , Data 3 4 3 2 1 2 "C"
  , Data 4 8 2 1 2 2 "D"
  ]

