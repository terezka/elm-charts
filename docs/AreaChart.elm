module AreaChart exposing (areaChart)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


areaChart : Svg.Svg a
areaChart =
    plot
        [ size ( 600, 250 ) ]
        [ area [ areaStyle [ ( "stroke", Colors.blueStroke ), ( "fill", Colors.blueFill ) ] ] data
        , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
        ]
