module PlotLines exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = title
    , code = code
    , view = ViewStatic view
    , id = id
    }


title : String
title =
    "Lines"


id : String
id =
    "PlotLines"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


view : Svg.Svg a
view =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 20 )
        , domainLowest (min 0)
        ]
        [ line
            [ Line.stroke blueStroke
            , Line.strokeWidth 2
            ]
            data1
        , line
            [ Line.stroke pinkStroke
            , Line.strokeWidth 2
            ]
            data2
        , xAxis
            [ Axis.line
                [ Line.stroke axisColor ]
            , Axis.tickDelta 1
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
            , domainLowest (min 0)
            ]
            [ line
                [ Line.stroke blueStroke
                , Line.strokeWidth 2
                ]
                data1
            , line
                [ Line.stroke pinkStroke
                , Line.strokeWidth 2
                ]
                data2
            , xAxis
                [ Axis.line
                    [ Line.stroke axisColor ]
                , Axis.tickDelta 1
                ]
            ]
    """
