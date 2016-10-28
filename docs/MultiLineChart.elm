module MultiLineChart exposing (multiLineChart)

import Svg
import Svg.Attributes
import Plot exposing (..)


data1 : List ( Float, Float )
data1 =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 3 ), ( 1, 1 ), ( 2, 8 ), ( 3, 20 ), ( 4, 18 ), ( 5, 16 ), ( 6, 12 ), ( 7, 16 ) ]


multiLineChart : Svg.Svg a
multiLineChart =
    plot
        [ size ( 600, 250 ) ]
        [ line [ lineStyle [ ( "stroke", "#828da2" ) ] ] data1
        , line [ lineStyle [ ( "stroke", "#c7978f" ) ] ] data2
        , xAxis
            [ axisLineStyle [ ( "stroke", "#7F7F7F" ) ]
            , amountOfTicks 6
            ]
        ]