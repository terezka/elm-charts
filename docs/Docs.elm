module Docs exposing (..)

import Html exposing (div, text, h1, img, a, br)
import Html.Attributes exposing (style, src, href)
import Svg
import Svg.Attributes
import Plot exposing (..)
import AreaChart exposing (areaChart)
import MultiAreaChart exposing (multiAreaChart)
import GridChart exposing (gridChart)
import MultiLineChart exposing (multiLineChart)
import CustomTickChart exposing (customTickChart)
import ComposedChart exposing (composedChart)


viewTitle title =
    div [ style [ ( "margin", "70px auto 10px" ) ] ] [ text title ]

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
        , viewTitle "Simple Area Chart"
        , areaChart
        , viewTitle "Multi Area Chart"
        , multiAreaChart
        , viewTitle "Line Chart"
        , multiLineChart
        , viewTitle "Grid"
        , gridChart
        , viewTitle "Custom ticks and labels"
        , customTickChart
        , viewTitle "Composable"
        , composedChart
        ]
