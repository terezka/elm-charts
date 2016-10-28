module Docs exposing (..)

import Html exposing (div, text, h1, img, a, br)
import Html.Attributes exposing (style, src, href)
import Svg
import Svg.Attributes
import Plot exposing (..)
import AreaChart exposing (areaChart)
import MultiAreaChart exposing (multiAreaChart)


myCustomXTick : Float -> Svg.Svg a
myCustomXTick tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(0, 8)"
        , Svg.Attributes.style "text-anchor: middle;"
        ]
        [ Svg.tspan [] [ Svg.text "⚡️" ] ]


myCustomLabel : Float -> Svg.Svg a
myCustomLabel tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(-10, 4)"
        , Svg.Attributes.style "stroke: purple; text-anchor: end;"
        ]
        [ Svg.tspan [] [ Svg.text ((toString (round tick)) ++ " ms") ] ]


areaData : List ( Float, Float )
areaData =
    [ ( -50, 34 ), ( -30, 432 ), ( -20, 35 ), ( 2, 546 ), ( 10, 345 ), ( 30, -42 ), ( 90, 67 ), ( 120, 50 ) ]


lineData : List ( Float, Float )
lineData =
    [ ( -50, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -99 ), ( 30, -136 ), ( 90, -67 ), ( 120, 10 ) ]

data1 : List ( Float, Float )
data1 =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]

data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 10, 90 ), ( 20, 25 ), ( 30, 12 ), ( 40, 66 ), ( 50, 16 )]

data3 : List ( Float, Float )
data3 =
    [ ( 0, 5 ), ( 10, 20 ), ( 20, 10 ), ( 30, 12 ), ( 40, 20 ), ( 50, 0 )]

data4 : List ( Float, Float )
data4 =
    [ ( 0, 3 ), ( 1, 1 ), ( 2, 8 ), ( 3, 20 ), ( 4, 18 ), ( 5, 16 ), ( 6, 12 ), ( 7, 16 ) ]

main =
    div
        [ style
            [ ( "width", "800px" )
            , ( "margin", "80px auto" )
            , ( "font-family", "sans-serif" )
            , ( "color", "#7F7F7F" )
            , ( "font-weight", "200" )
            , ( "text-align", "center" )
            ]
        ]
        [ img [ src "logo.png", style [ ( "width", "100px" ), ( "height", "100px" ) ] ] []
        , h1 [ style [ ( "font-weight", "200" ) ] ] [ text "Elm Plot" ]
        , div
          [ style [ ( "margin", "40px auto 100px" ) ] ]
          [ text "Find it on Github "
          , br [] []
          , a
            [ href "https://github.com/terezka/elm-plot"
            , style [ ( "color", "#84868a" ) ]
            ]
            [ text "https://github.com/terezka/elm-plot" ]
          ]
        , div [ style [ ( "margin", "60px auto 10px" ) ] ] [ text "Simple Area Chart" ]
        , areaChart
        , div [ style [ ( "margin", "60px auto 10px" ) ] ] [ text "Multi Area Chart" ]
        , multiAreaChart
        , div [ style [ ( "margin", "60px auto 10px" ) ] ] [ text "Line Chart" ]
        , plot
          [ size ( 600, 250 ) ]
          [ line [ lineStyle [ ( "stroke", "#828da2" ) ] ] data1
          , line [ lineStyle [ ( "stroke", "#c7978f" ) ] ] data4
          , xAxis
              [ axisLineStyle [ ( "stroke", "#7F7F7F" ) ]
              , amountOfTicks 6
              ]
          ]
        , plot
            [ size ( 800, 500 ) ]
            [ horizontalGrid [ gridTickList [ -40, -20, 20, 40, 60, 80, 100 ], gridStyle [ ( "stroke", "#cee0e2" ) ] ]
            , verticalGrid [ gridTickList [ 200, 400, 600 ], gridStyle [ ( "stroke", "#cee0e2" ) ] ]
            , area [ areaStyle [ ( "stroke", "cornflowerblue" ), ( "fill", "#ccdeff" ) ] ] areaData
            , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
            , xAxis
                [ customViewTick myCustomXTick
                , axisLineStyle [ ( "stroke", "red" ) ]
                , tickList [ -20, 20, 40, 82 ]
                ]
            , yAxis
                [ customViewLabel myCustomLabel
                , amountOfTicks 5
                ]
            ]
        ]
