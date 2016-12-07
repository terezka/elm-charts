module PlotScatter exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Scatter as Scatter
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Line as Line
import Common


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title =
    "Scatters"


fileName : String
fileName =
    "PlotScatter"


data : List ( Float, Float )
data =
    [ ( 0, 10 ), ( 2, 12 ), ( 4, 27 ), ( 6, 25 ), ( 8, 46 ) ]


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 40 )
        ]
        [ scatter
            [ Scatter.stroke Common.pinkStroke
            , Scatter.fill Common.pinkFill
            , Scatter.radius 8
            ]
            data
        , xAxis
            [ Axis.line
                [ Line.stroke Common.axisColor ]
            , Axis.tick
                [ Tick.delta 2 ]
            ]
        ]


code : String
code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ scatter
                [ scatterStyle
                    [ ( "stroke", Common.pinkStroke )
                    , ( "fill", Common.pinkFill )
                    ]
                , scatterRadius 8
                ]
                data
            , xAxis [ axisStyle [ ( "stroke", Common.axisColor ) ] ]
            ]
    """
