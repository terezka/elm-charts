module MultiAreaChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data1 : List ( Float, Float )
data1 =
    [ ( 0, 10 ), ( 10, 90 ), ( 20, 25 ), ( 30, 15 ), ( 40, 66 ), ( 50, 16 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 5 ), ( 10, 20 ), ( 20, 10 ), ( 30, 12 ), ( 40, 20 ), ( 45, 25 ), ( 50, 3 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ area [ areaStyle [ ( "stroke", Colors.skinStroke ), ( "fill", Colors.skinFill ) ] ] data1
        , area [ areaStyle [ ( "stroke", Colors.blueStroke ), ( "fill", Colors.blueFill ) ] ] data2
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickDelta 10
            ]
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ area
                [ areaStyle
                    [ ( "stroke", Colors.skinStroke )
                    , ( "fill", Colors.skinFill )
                    ]
                ]
                data1
            , area
                [ areaStyle
                    [ ( "stroke", Colors.blueStroke )
                    , ( "fill", Colors.blueFill )
                    ]
                ]
                data2
            , xAxis
                [ axisStyle [ ( "stroke", Colors.axisColor ) ]
                , tickDelta 10
                ]
            ]
    """
