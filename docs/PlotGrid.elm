module PlotGrid exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Grid as Grid
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
    "Grids"


fileName : String
fileName =
    "PlotGrid"


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 0 ), ( 2, 14 ) ]


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ verticalGrid
            [ Grid.lines
                [ Line.stroke Common.axisColorLight ]
            ]
        , horizontalGrid
            [ Grid.lines
                [ Line.stroke Common.axisColorLight ]
            , Grid.values [ 4, 8, 12 ]
            ]
        , xAxis
            [ Axis.line [ Line.stroke Common.axisColor ]
            , Axis.tick [ Tick.delta 0.5 ]
            ]
        , line
            [ Line.stroke Common.blueStroke
            , Line.strokeWidth 2
            ]
            data
        ]


code =
    """
    view : Svg.Svg a
    view =
        plot
            [ size Common.plotSize
            , margin ( 10, 20, 40, 20 )
            ]
            [ verticalGrid
                [ Grid.lines
                    [ Line.stroke Common.axisColorLight ]
                ]
            , horizontalGrid
                [ Grid.lines
                    [ Line.stroke Common.axisColorLight ]
                , Grid.values [ 4, 8, 12 ]
                ]
            , xAxis
                [ Axis.line [ Line.stroke Common.axisColor ]
                , Axis.tick [ Tick.delta 0.5 ]
                ]
            , line
                [ Line.stroke Common.blueStroke
                , Line.strokeWidth 2
                ]
                data
            ]
    """
