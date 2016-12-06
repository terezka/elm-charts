module HorizontalBarChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors
import Tuple exposing (..)


data : List ( Float, Float )
data =
    [ ( 12, 0 ), ( 5, 1 ), ( 7, 2 ), ( 2, 3 ), ( 9, 4 ), ( 3, 5 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ bar
            [ barStyle
                [ ( "stroke", Colors.blueStroke )
                , ( "fill", Colors.blueFill )
                ]
            , barOrientation BarHorizontal
            ]
            data
        , yAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickValues (List.map second data)
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
                , barOrientation BarHorizontal
                ]
                data
            , yAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ]
                    , tickValues (List.map second data)
                    ]
            ]
     """
