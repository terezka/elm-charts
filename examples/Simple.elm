module Simple exposing (..)

import Plot exposing (..)


lineData : List ( Float, Float )
lineData =
    [ ( -52, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -20 ), ( 30, 10 ), ( 40, 136 ), ( 90, 167 ), ( 125, 120 ) ]


main =
    plot
        [ ]
        [ xAxis
            [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , yAxis 
            [ gridValues [ -60, -30, 30, 60, 90, 120, 150, 180 ], gridStyle [ ( "stroke", "#ddd" ) ] ]
        , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData 
        ]
