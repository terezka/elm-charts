module PlotArea exposing (plotExample)

import Svg
import Plot exposing (..)
import Common exposing (..)
import Plot.Area as Area
import Plot.Line as Line
import Plot.Axis as Axis


plotExample : PlotExample msg
plotExample =
    { title = title
    , code = code
    , view = ViewStatic view
    , id = id
    }


title : String
title =
    "Areas"


id : String
id =
    "PlotArea"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 20 ), ( 10, 65 ), ( 20, 35 ), ( 30, 85 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 10, 50 ), ( 20, 10 ), ( 30, 75 ) ]


view : Svg.Svg a
view =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ area
            [ Area.stroke skinStroke
            , Area.smoothingBezier
            , Area.fill skinFill
            ]
            data1
        , area
            [ Area.stroke blueStroke
            , Area.smoothingBezier
            , Area.fill blueFill
            ]
            data2
        , xAxis
            [ Axis.line [ Line.stroke axisColor ]
            , Axis.tickDelta 10
            ]
        ]


code : String
code =
    """
    view : Svg.Svg a
    view =
        plot
            [ size plotSize
            , margin ( 10, 20, 40, 20 )
            ]
            [ area
                [ Area.stroke skinStroke
                , Area.fill skinFill
                ]
                data1
            , area
                [ Area.stroke blueStroke
                , Area.fill blueFill
                ]
                data2
            , xAxis
                [ Axis.line [ Line.stroke axisColor ]
                , Axis.tickDelta 10
                ]
            ]
    """
