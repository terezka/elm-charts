module AreaChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ area [ areaStyle [ (Svg.Attributes.stroke Colors.blueStroke), (Svg.Attributes.fill Colors.blueFill) ] ] data
        , xAxis [ axisStyle [ (Svg.Attributes.stroke Colors.axisColor) ] ]
        ]


code : String
code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ area
                [ areaStyle
                    [ ( Svg.Attributes.stroke Colors.blueStroke )
                    , ( Svg.Attributes.fill Colors.blueFill )
                    ]
                ]
                data
            , xAxis [ axisStyle [ ( Svg.Attributes.stroke Colors.axisColor ) ] ]
            ]
    """
