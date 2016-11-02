module Simple exposing (..)

import Plot exposing (..)


lineData : List ( Float, Float )
lineData =
    [ ( -50, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -20 ), ( 30, 10 ), ( 40, 136 ), ( 90, 167 ), ( 120, 120 ) ]


main =
    plot
        [ size ( 800, 500 ), padding ( 40, 40 ) ]
        [ line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
        , xAxis []
        , yAxis [ tickTotal 5 ]
        ]
