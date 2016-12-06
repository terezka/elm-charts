module MultiAreaChart exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors
import Plot.Area as Area
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Areas"


fileName : String
fileName = "MultiAreaChart"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 20 ), ( 10, 65 ), ( 20, 35 ), ( 30, 85 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 10, 50 ), ( 20, 0 ), ( 30, 75 ) ]


view : Svg.Svg a
view =
    plot
        [ size ( 380, 300 )
        , margin ( 10, 20, 40, 20 )
        , domain ( Just 0, Nothing )
        ]
        [ area
            [ Area.stroke Colors.skinStroke
            , Area.fill Colors.skinFill
            ]
            data1
        , area
            [ Area.stroke Colors.blueStroke
            , Area.fill Colors.blueFill
            ]
            data2
        , xAxis
            [ Axis.line [ Line.stroke Colors.axisColor ]
            , Axis.tick [ Tick.delta 10 ]
            ]
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 300 ) ]
            [ area
                [ Area.style
                    [ ( "stroke", Colors.skinStroke )
                    , ( "fill", Colors.skinFill )
                    ]
                ]
                data1
            , area
                [ Area.style
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
