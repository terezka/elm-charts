module Charts.Dashboard7 exposing (Model, Msg, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time

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
  { hovering : List (CI.One Datum CI.Dot)
  }


init : Model
init =
  { hovering = []
  }


type Msg
  = OnHover (List (CI.One Datum CI.Dot))


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
    , CA.margin { top = 0, bottom = 45, left = 0, right = 20 }
    , CA.padding { top = 5, bottom = 5, left = 0, right = 0 }
    , CE.onMouseMove OnHover (CE.getNearest (CI.andThen CI.real CI.dots))
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.grid []
    , C.yTicks [ CA.height 0 ]
    , C.generate 5 C.floats .y [] <| \p y ->
        [ C.yLabel [ CA.fontSize 10, CA.flip, CA.y y, CA.x p.x.max ] [ S.text (String.fromFloat y ++ "k")] ]

    , C.xAxis [ CA.noArrow ]
    , C.xLabels [ CA.noGrid, CA.uppercase, CA.fontSize 10, CA.amount 8 ]
    , C.xTicks [ CA.noGrid, CA.amount 8 ]

    , C.labelAt .max .max [ CA.moveRight 7 ] [ S.text "Population" ]

    , C.each model.hovering <| \p dot ->
        [ C.line [ CA.x1 (CI.getX dot), CA.dashed [ 3, 3 ], CA.width 1.5 ] ]

    , let isMemberOfBin datum =
            List.member datum (List.map CI.getData model.hovering)
      in
      C.series .year
        [ C.interpolated .manhattan [ CA.linear, CA.width 2, CA.color orange ] []
            |> C.variation (\_ d -> if isMemberOfBin d then [ CA.circle, CA.size 8 ] else [])
            |> C.amongst model.hovering (\_ -> [ CA.color "white", CA.borderWidth 2, CA.size 18, CA.highlight 0.5, CA.highlightColor orange ])
            |> C.named "Manhattan"
        , C.interpolated .bronx [ CA.linear, CA.width 2, CA.color green ] []
            |> C.variation (\_ d -> if isMemberOfBin d then [ CA.circle, CA.size 8 ] else [])
            |> C.amongst model.hovering (\_ -> [ CA.color "white", CA.borderWidth 2, CA.size 18, CA.highlight 0.5, CA.highlightColor green ])
            |> C.named "Bronx"
        , C.interpolated .brooklyn [ CA.linear, CA.width 2, CA.color blue ] []
            |> C.variation (\_ d -> if isMemberOfBin d then [ CA.circle, CA.size 8 ] else [])
            |> C.amongst model.hovering (\_ -> [ CA.color "white", CA.borderWidth 2, CA.size 18, CA.highlight 0.5, CA.highlightColor blue ])
            |> C.named "Brooklyn"
        , C.interpolated .queens [ CA.linear, CA.width 2, CA.color pink ] []
            |> C.variation (\_ d -> if isMemberOfBin d then [ CA.circle, CA.size 8 ] else [])
            |> C.amongst model.hovering (\_ -> [ CA.color "white", CA.borderWidth 2, CA.size 18, CA.highlight 0.5, CA.highlightColor pink ])
            |> C.named "Queens"
        , C.interpolated .statenIsland [ CA.linear, CA.width 2, CA.color purple ] []
            |> C.variation (\_ d -> if isMemberOfBin d then [ CA.circle, CA.size 8 ] else [])
            |> C.amongst model.hovering (\_ -> [ CA.color "white", CA.borderWidth 2, CA.size 18, CA.highlight 0.5, CA.highlightColor purple ])
            |> C.named "Staten Island"
        ]
        data

    , C.each model.hovering <| \p dot ->
        [ C.tooltip dot [ CA.onTop, CA.offset 8 ] []
            [ H.span
                [ HA.style "color" "#777" ]
                [ H.text <| String.fromFloat (CI.getX dot) ]
            , H.text ": "
            , H.text <| String.fromFloat (CI.getY dot) ++ "k"
            ]

        ]

    , C.legendsAt .min .min
        [ CA.spacing 10
        , CA.moveUp 25
        , CA.htmlAttrs [ HA.style "max-width" "350px", HA.style "flex-flow" "wrap" ]
        ]
        [ CA.fontSize 10
        , CA.spacing 5
        ]
    ]


orange = "#ff9800"
green = "#02a09b"
blue = "#047ae8"
pink = "#ed3c91"
purple = "#6501e9"


type alias Datum =
  { year : Float
  , total : Float
  , manhattan : Float
  , bronx : Float
  , brooklyn : Float
  , queens : Float
  , statenIsland : Float
  }


data : List Datum
data =
  [ Datum 1930 6930 1867 1265 2560 1079 158
  , Datum 1935 6945 1882 1280 2575 1084 164
  , Datum 1940 7455 1890 1395 2698 1297 174
  , Datum 1950 7892 1960 1451 2738 1551 192
  , Datum 1960 7782 1698 1425 2627 1810 222
  , Datum 1970 7896 1539 1472 2602 1987 295
  , Datum 1980 7072 1428 1169 2231 1891 352
  , Datum 1990 7323 1488 1204 2301 1952 379
  , Datum 2000 8008 1537 1333 2465 2229 443
  ]

