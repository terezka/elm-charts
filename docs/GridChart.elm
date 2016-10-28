module GridChart exposing (gridChart)

import Svg
import Svg.Attributes
import Plot exposing (..)


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), (8, 31), ( 9, 37 ), (10, 42) ]


gridChart : Svg.Svg a
gridChart =
    plot
        [ size ( 600, 250 ) ]
        [ verticalGrid [ gridTickList [ 10, 20, 30, 40 ], gridStyle [ ( "stroke", "#e2e2e2" ) ] ]
        , horizontalGrid [ gridTickList [ 1, 3, 5, 7, 9 ], gridStyle [ ( "stroke", "#e2e2e2" ) ] ]
        , line [ lineStyle [ ( "stroke", "#b6c9ef" ), ( "stroke-width", "2px" ) ] ] data
        , xAxis
            [ axisLineStyle [ ( "stroke", "#7F7F7F" ) ]
            ]
        ]
