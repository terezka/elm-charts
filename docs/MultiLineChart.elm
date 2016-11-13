module MultiLineChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data1 : List ( Float, Float )
data1 =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 36 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 3 ), ( 1, 2 ), ( 2, 8 ), ( 2.5, 15 ), ( 3, 18 ), ( 4, 17 ), ( 5, 16 ), ( 5.5, 15 ), ( 6.5, 14 ), ( 7.5, 13 ), ( 8, 12 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ line [ lineStyle [ ( "stroke", Colors.blueStroke ), ( "stroke-width", "2px" ) ] ] data2
        , line [ lineStyle [ ( "stroke", Colors.pinkStroke ), ( "stroke-width", "2px" ) ] ] data1
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            ]
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ line
                [ lineStyle
                    [ ( "stroke", Colors.blueStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data2
            , line
                [ lineStyle
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data1
            , xAxis
                [ axisStyle [ ( "stroke", Colors.axisColor ) ]
                ]
            ]
    """
