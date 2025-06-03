module Charts.Dashboard5 exposing (Model, Msg, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time
import Data.Iris as Iris
import Data.Iris as Salary
import Data.Education as Education
import Dict
import Time

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS

import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG

import Chart.Events


type alias Model =
  { hovering : List (CI.One Iris.Datum CI.Dot)
  }


init : Model
init =
  { hovering = []
  }


type Msg
  = OnHover (List (CI.One Iris.Datum CI.Dot))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 230
    , CA.width 350
    , CA.margin { top = 5, bottom = 10, left = 10, right = 0 }
    , CA.padding { top = 15, bottom = 10, left = 15, right = 15 }
    , CA.domain [ CA.likeData ]
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.grid [ CA.dashed [ 5, 5 ] ]
    , C.yTicks []
    --, C.yLabels [ CA.ints, CA.fontSize 8, CA.moveRight 2 ]
    , C.xTicks [ CA.amount 8 ]
    --, C.xLabels [ CA.ints, CA.fontSize 8, CA.moveUp 5 ]
    , C.xAxis []
    , C.yAxis []

    , C.series .sepalLength
        [ C.scatter .sepalWidth [ CA.circle, CA.size 12, CA.opacity 0.6, CA.color CA.pink ]
            |> C.variation (\i d -> [ CA.size (d.petalLength * 1.5) ])
            |> C.named "Setosa"
        ]
        Iris.setosa

    , C.series .sepalLength
        [ C.scatter .sepalWidth [ CA.circle, CA.size 12, CA.opacity 0.6, CA.color CA.purple ]
            |> C.variation (\i d -> [ CA.size (d.petalLength * 1.5) ])
            |> C.named "Versicolor"
        ]
        Iris.versicolor

    , C.series .sepalLength
        [ C.scatter .sepalWidth [ CA.circle, CA.size 12, CA.opacity 0.6, CA.color CA.blue ]
            |> C.variation (\i d -> [ CA.size (d.petalLength * 1.5) ])
            |> C.named "Virginica"
        ]
        Iris.virginica

    , C.legendsAt .max .max
          [ CA.column
          , CA.moveLeft 10
          , CA.alignRight
          , CA.spacing 1
          , CA.background "white"
          , CA.border CA.gray
          , CA.borderWidth 1
          , CA.htmlAttrs [ HA.style "padding" "4px 8px" ]
          ]
          [ CA.spacing 6, CA.fontSize 12 ]

    --, C.labelAt CA.middle .max
    --    [ CA.fontSize 9, CA.moveDown 2, CA.color "#aaa" ]
    --    [ S.text "The Iris flower: Sepal length vs. sepal width" ]

    , C.each model.hovering <| \p dot ->
        let datum = CI.getData dot in
        [ C.tooltip dot
            [ CA.offset 1 ]
            []
            [ H.div
                [ HA.style "color" (CI.getColor dot)
                , HA.style "text-align" "center"
                , HA.style "padding-bottom" "4px"
                , HA.style "border-bottom" "1px solid lightgray"
                , HA.style "font-size" "12px"
                ]
                [ H.text (Iris.species datum) ]
            , H.table
                [ HA.style "color" "rgb(90, 90, 90)"
                , HA.style "width" "100%"
                , HA.style "font-size" "12px"
                , HA.style "font-weight" "normal"
                ]
                [ H.tr []
                    [ H.td [] []
                    , H.td [ HA.style "text-align" "right", HA.style "color" "rgb(120, 120, 120)" ] [ H.text "Length" ]
                    , H.td [ HA.style "text-align" "right", HA.style "color" "rgb(120, 120, 120)"  ] [ H.text "Width" ]
                    ]
                , H.tr []
                    [ H.td [ HA.style "text-align" "left", HA.style "color" "rgb(120, 120, 120)"  ] [ H.text "Sepal" ]
                    , H.td [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.sepalLength ++ " cm") ]
                    , H.td [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.sepalWidth ++ " cm")]
                    ]
                , H.tr []
                    [ H.td [ HA.style "text-align" "left", HA.style "color" "rgb(120, 120, 120)"  ] [ H.text "Petal" ]
                    , H.td [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.petalLength ++ " cm") ]
                    , H.td [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.petalWidth ++ " cm") ]
                    ]
                ]
            ]
          ]
    ]
