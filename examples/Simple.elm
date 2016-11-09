module Simple exposing (..)

import Plot exposing (..)
import Svg
import Svg.Attributes


lineData : List ( Float, Float )
lineData =
    [ ( -52, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -20 ), ( 30, 10 ), ( 40, 136 ), ( 90, 167 ), ( 125, 120 ) ]


lineData2 =
    [ ( -1, 2 ), ( 0, 3 ), ( 4, 5 ), ( 5, 3 ) ]


plot1 =
    plot
        [ padding ( 40, 40 ) ]
        [ verticalGrid [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , horizontalGrid [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
        , yAxis []
        , xAxis []
        ]


main =
    plot1
