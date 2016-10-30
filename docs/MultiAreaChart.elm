module MultiAreaChart exposing (multiAreaChart)

import Svg
import Svg.Attributes
import Plot exposing (..)


data1 : List ( Float, Float )
data1 =
    [ ( 0, 10 ), ( 10, 90 ), ( 20, 25 ), ( 30, 15 ), ( 40, 66 ), ( 50, 16 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 5 ), ( 10, 20 ), ( 20, 10 ), ( 30, 12 ), ( 40, 20 ), ( 50, 0 ) ]


multiAreaChart : Svg.Svg a
multiAreaChart =
    plot
        [ size ( 600, 250 ) ]
        [ area [ areaStyle [ ( "stroke", "#cfd8ea" ), ( "fill", "#e4eeff" ) ] ] data1
        , area [ areaStyle [ ( "stroke", "#e6d7ce" ), ( "fill", "#feefe5" ) ] ] data2
        , xAxis
            [ axisStyle [ ( "stroke", "#7F7F7F" ) ]
            , tickTotal 6
            ]
        ]
