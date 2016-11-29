module AreaChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot as Plot exposing (..)
import Plot.Area as Area
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 5 ), ( 1, 20 ), ( 2, 10 ), ( 3, 12 ), ( 4, 20 ), ( 5, 25 ), ( 6, 3 ) ]


chart : Svg.Svg msg
chart =
    Plot.plot
        [ size ( 600, 300 )
        , margin ( 10, 20, 40, 20 )
        ]
        [ area
            [ Area.stroke Colors.blueStroke
            , Area.fill Colors.blueFill
            ]
            data
        , xAxis [ Axis.view [ Axis.style [ ( "stroke", Colors.axisColor ) ] ] ]
        ]


code =
    """
    chart : Svg.Svg msg
    chart =
        plot
            [ size ( 600, 300 ) ]
            [ area
                [ Area.style
                    [ ( "stroke", Colors.blueStroke )
                    , ( "fill", Colors.blueFill )
                    ]
                ]
                data
            , xAxis [ Axis.style [ ( "stroke", Colors.axisColor ) ] ]
            ]
    """
