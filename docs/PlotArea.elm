module PlotArea exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Common
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
title =
    "Areas"


fileName : String
fileName =
    "PlotArea"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 20 ), ( 10, 65 ), ( 20, 35 ), ( 30, 85 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 10, 50 ), ( 20, 0 ), ( 30, 75 ) ]


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ area
            [ Area.stroke Common.skinStroke
            , Area.fill Common.skinFill
            ]
            data1
        , area
            [ Area.stroke Common.blueStroke
            , Area.fill Common.blueFill
            ]
            data2
        , xAxis
            [ Axis.line [ Line.stroke Common.axisColor ]
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
                    [ ( "stroke", Common.skinStroke )
                    , ( "fill", Common.skinFill )
                    ]
                ]
                data1
            , area
                [ Area.style
                    [ ( "stroke", Common.blueStroke )
                    , ( "fill", Common.blueFill )
                    ]
                ]
                data2
            , xAxis
                [ axisStyle [ ( "stroke", Common.axisColor ) ]
                , tickDelta 10
                ]
            ]
    """
