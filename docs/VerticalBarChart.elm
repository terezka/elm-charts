module VerticalBarChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors
import Tuple exposing (..)


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ bar
            [ barStyle
                [ ( "stroke", Colors.blueStroke )
                , ( "fill", Colors.blueFill )
                ]
            ]
            data
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickValues (List.map first data)
            ]
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ bar
                [ barStyle
                    [ ( "stroke", Colors.blueStroke )
                    , ( "fill", Colors.blueFill )
                    ]
                ]
                data
            , xAxis
                [ axisStyle [ ( "stroke", Colors.axisColor ) ]
                , tickValues (List.map first data)
                ]
            ]
    """
