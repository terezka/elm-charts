module SmoothLines exposing (..)

import Svg
import Html exposing (h1, p, text, div, node)
import Html.Attributes
import Plot.Types exposing (..)
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis


data1 : List ( Float, Float )
data1 =
    [ ( 0, 0 ), ( 1, 1 ), ( 2, 2 ), ( 3, 3 ), ( 4, 5 ), ( 5, 8 ), ( 6, 13 ), ( 7, 21 ), ( 8, 34 ), ( 9, 55 ), ( 10, 87 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 40 ), ( 1, 45 ), ( 2, 35 ), ( 3, 50 ), ( 4, 30 ), ( 5, 55 ), ( 6, 20 ), ( 7, 60 ), ( 8, 15 ), ( 9, 65 ), ( 10, 10 ) ]


data3 : List ( Float, Float )
data3 =
    [ ( 0, 60 )
    , ( 1, 60 )
    , ( 1, 80 )
    , ( 2, 80 )
    , ( 2, 60 )
    , ( 3, 60 )
    , ( 3, 80 )
    , ( 4, 80 )
    , ( 4, 60 )
    , ( 5, 60 )
    , ( 5, 80 )
    , ( 6, 80 )
    , ( 6, 60 )
    , ( 7, 60 )
    , ( 7, 80 )
    , ( 8, 80 )
    , ( 8, 60 )
    , ( 9, 60 )
    , ( 9, 80 )
    , ( 10, 80 )
    ]


data4 : List Point
data4 =
    [ ( 0, 0 ), ( 0.2, 80 ), ( 0.4, 20 ), ( 0.6, 50 ), ( 0.8, 10 ), ( 3, 30 ), ( 6, 40 ), ( 10, 50 ) ]


main : Html.Html msg
main =
    Html.div
        [ Html.Attributes.style [ ( "margin", "0 auto" ), ( "width", "600px" ), ( "text-align", "center" ) ] ]
        [ h1 [] [ text "Example with smooth lines" ], viewPlot ]


viewPlot : Svg.Svg msg
viewPlot =
    plot
        [ size ( 600, 300 )
        , margin ( 100, 100, 40, 100 )
        , id "PlotHint"
        , style [ ( "position", "relative" ) ]
        ]
        [ line
            [ Line.stroke "#556270"
            , Line.strokeWidth 1
            ]
            data1
        , line
            [ Line.stroke "#C44D58"
            , Line.strokeWidth 2
            , Line.smoothingBezier
            ]
            data1
        , line
            [ Line.stroke "#556270"
            , Line.strokeWidth 1
            ]
            data2
        , line
            [ Line.stroke "#4ECDC4"
            , Line.strokeWidth 2
            , Line.smoothingBezier
            ]
            data2
        , line
            [ Line.stroke "#556270"
            , Line.strokeWidth 1
            ]
            data3
        , line
            [ Line.stroke "#C7F464"
            , Line.strokeWidth 2
            , Line.smoothingBezier
            ]
            data3
        , line
            [ Line.stroke "#556270"
            , Line.strokeWidth 1
            ]
            data4
        , line
            [ Line.stroke "#FF6B6B"
            , Line.strokeWidth 2
            , Line.smoothingBezier
            ]
            data4
        , xAxis
            [ Axis.line
                [ Line.stroke "#556270" ]
            , Axis.tickDelta 1
            ]
        ]
