module ScatterChart exposing (chart, code)

import Svg
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 40 ), ( 1, 35 ), ( 2, 32 ), ( 3, 36 ), ( 4, 31 ), ( 5, 20 ), ( 6, 15 ), ( 7, 16 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ scatter [ scatterStyle [ ( "stroke", Colors.pinkStroke ), ( "fill", Colors.pinkFill ) ], scatterRadius 8 ] data
        , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
        ]

code : String
code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ scatter
                [ scatterStyle
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "fill", Colors.pinkFill )
                    ]
                , scatterRadius 8
                ]
                data
            , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
            ]
    """
