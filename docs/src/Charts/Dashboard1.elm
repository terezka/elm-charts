module Charts.Dashboard1 exposing (Model, Msg, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time
import Data.Iris as Iris
import Data.Salary as Salary
import Data.Education as Education
import Dict
import Time
import DateFormat as F

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS
import Chart.Events

import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG


type alias Model =
  { hovering : List (CI.One Datum CI.Dot)
  , hoveringBars : List (CI.Many Datum CI.Bar)
  }


init : Model
init =
  { hovering = []
  , hoveringBars = []
  }


type Msg
  = OnHover
      (List (CI.One Datum CI.Dot))
      (List (CI.Many Datum CI.Bar))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering hoveringBars ->
      { model | hovering = hovering, hoveringBars = hoveringBars }



view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 490
    , CA.margin { top = 0, bottom = 18, left = 10, right = 0 }
    , CA.padding { top = 10, bottom = 0, left = 0, right = 35 }
    , CE.on "mousemove" <|
        CE.map2 OnHover
          (CE.getNearestX CI.dots)
          (CE.getWithinX 8 <| CI.andThen CI.bins CI.bars)
    , CE.onMouseLeave (OnHover [] [])
    ]
    [ C.grid [ CA.dashed [ 3, 2 ] ]
    , C.xLabels [ CA.withGrid, CA.times Time.utc, CA.amount 20, CA.fontSize 10 ]
    , C.yLabels
        [ CA.withGrid, CA.pinned .max, CA.moveUp 7, CA.moveRight 10, CA.fontSize 10
        , CA.format (\i -> String.fromFloat (i / 1000) ++ "k")
        ]

    , C.barsMap Bar
        [ CA.x1 (\d -> d.x + 150000)
        , CA.noGrid
        , CA.roundTop 0.2
        , CA.ungroup
        ]
        [ C.barMaybe .y [ CA.color "#7b4dffAF", CA.gradient [ "#7b4dff6F", "#7b4dff1F" ] ]
            |> C.named "Requests"
        , C.barMaybe .z [ CA.color "#666", CA.gradient [ "#bfc2c9", "#bfc2c96F" ] ]
            |> C.named "Sales"
        ]
        barData

    , C.seriesMap Dot .x
        [ C.interpolated .y
            [ CA.monotone, CA.color "#7b4dff", CA.width 1.5, CA.opacity 0.2 ]
            [ CA.color "white", CA.borderWidth 1.5, CA.circle ]
            |> C.named "Customers"
            |> C.amongst (CI.filter justDot model.hovering) (\_ -> [ CA.color "#7b4dff", CA.border "white" ])
        ]
        lineData

    , C.each model.hoveringBars <| \p stack ->
        let eachBar bar =
              if CI.isReal bar then
                C.label
                  [ CA.moveDown 16
                  , CA.fontSize 10
                  , CA.color "rgba(255, 255, 255, 0.4)"
                  ]
                  [ S.text (String.fromInt (round (CI.getY bar / 1000)) ++ "k") ]
                  (CI.getTop p bar)

              else
                C.label
                  [ CA.moveUp 15
                  , CA.fontSize 10
                  , CA.color "rgb(120, 120, 120)"
                  ]
                  [ S.text "No data" ]
                  (CI.getTop p bar)
        in
        List.map eachBar (CI.getMembers stack)

    , C.each model.hovering <| \p dot ->
        let xValue = Time.millisToPosix (round (CI.getX dot))
            rows = CI.getTooltip dot ++ List.concatMap CI.getTooltip (List.concatMap CI.getMembers model.hoveringBars)
            header =
              H.div
                [ HA.style "padding" "5px 0 5px 0"
                , HA.style "color" "rgb(120, 120, 120)"
                ]
                [ H.text (formatFullTime Time.utc xValue) ]

            withPadding i = H.div [ HA.style "padding" "2px 0" ] [ i ]
            body = H.div [ HA.style "padding-bottom" "5px" ] (List.map withPadding rows)
        in
        [ C.tooltip dot
            [ CA.onLeftOrRight, CA.offset 8, CA.center ]
            [ HA.style "font-size" "14px"
            ]
            [ header, body ]
        ]
    ]


type Datum
  = Bar BarDatum
  | Dot DotDatum


justDot : Datum -> Maybe DotDatum
justDot datum =
  case datum of
    Bar _ -> Nothing
    Dot dot -> Just dot


type alias BarDatum =
  { x : Float
  , y : Maybe Float
  , z : Maybe Float
  }


barData : List BarDatum
barData =
  [ BarDatum 1612440000000 (Just 100342) (Just 20231)
  , BarDatum 1612440300000 (Just 124731) (Just 13802)
  , BarDatum 1612440600000 (Just 151421) (Just 23038)
  , BarDatum 1612440900000 (Just 92132) (Just 14047)
  , BarDatum 1612441200000 (Just 53970) (Just 13406)
  , BarDatum 1612441500000 (Just 30122) (Just 0)
  , BarDatum 1612441800000 (Just 66130) (Just 23094)
  , BarDatum 1612442100000 (Just 87002) (Just 18120)
  , BarDatum 1612442400000 Nothing Nothing
  , BarDatum 1612442700000 (Just 102032) (Just 30379)
  , BarDatum 1612443000000 (Just 122101) (Just 34092)
  ]



type alias DotDatum =
  { x : Float
  , y : Float
  }


lineData : List DotDatum
lineData =
  [ DotDatum 1612440000000 140000
  , DotDatum 1612440300000 135000
  , DotDatum 1612440600000 160000
  , DotDatum 1612440900000 95000
  , DotDatum 1612441200000 74000
  , DotDatum 1612441500000 32000
  , DotDatum 1612441800000 86000
  , DotDatum 1612442100000 83000
  , DotDatum 1612442400000 60000
  , DotDatum 1612442700000 92000
  , DotDatum 1612443000000 72000
  , DotDatum 1612443300000 52000
  , DotDatum 1612443600000 62000
  ]



formatFullTime : Time.Zone -> Time.Posix -> String
formatFullTime =
    F.format
        [ F.monthNameFull
        , F.text " "
        , F.dayOfMonthSuffix
        , F.text " "
        , F.yearNumber
        , F.text " "
        , F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        ]
