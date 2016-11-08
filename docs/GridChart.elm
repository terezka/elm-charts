module GridChart exposing (gridChart)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 31 ), ( 9, 37 ), ( 10, 42 ) ]


gridChart : Svg.Svg a
gridChart =
    plot
        [ size ( 600, 250 ) ]
        [ xAxis
            [ axisStyle [ ("stroke", Colors.axisColor ) ]
            , gridMirrorTicks
            , gridStyle [ ("stroke", "#ddd" ) ]
            ]
        , line [ lineStyle [ ( "stroke", Colors.blueStroke ), ( "stroke-width", "2px" ) ] ] data
        ]