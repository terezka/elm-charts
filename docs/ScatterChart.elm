module ScatterChart exposing (chart, code)

import Svg
import Plot exposing (..)
import Plot.Scatter as Scatter
import Plot.Axis as Axis
import Plot.Line as Line
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 20 ), ( 1, 15 ), ( 2, 20 ), ( 3, 20 ), ( 4, 31 ), ( 5, 36 ), ( 6, 35 ), ( 7, 40 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 300 )
        , margin ( 10, 20, 40, 40 )
        , domain ( Just 0, Nothing )
        ]
        [ scatter
            [ Scatter.stroke Colors.pinkStroke
            , Scatter.fill Colors.pinkFill
            , Scatter.radius 8
            ]
            data
        , xAxis [ Axis.line [ Line.stroke Colors.axisColor ] ]
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