module PlotGrid exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Grid as Grid
import Plot.Line as Line
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
    "Grids"


id : String
id =
    "PlotGrid"


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 0 ), ( 2, 14 ) ]


view : Svg.Svg a
view =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ verticalGrid
            [ Grid.lines
                [ Line.stroke axisColorLight ]
            ]
        , horizontalGrid
            [ Grid.lines
                [ Line.stroke axisColorLight ]
            , Grid.values [ 4, 8, 12 ]
            ]
        , xAxis
            [ Axis.line [ Line.stroke axisColor ]
            , Axis.tickDelta 0.5
            ]
        , line
            [ Line.stroke pinkStroke
            , Line.strokeWidth 3
            ]
            data
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
            [ verticalGrid
                [ Grid.lines
                    [ Line.stroke axisColorLight ]
                ]
            , horizontalGrid
                [ Grid.lines
                    [ Line.stroke axisColorLight ]
                , Grid.values [ 4, 8, 12 ]
                ]
            , xAxis
                [ Axis.line [ Line.stroke axisColor ]
                , Axis.tickDelta 0.5
                ]
            , line
                [ Line.stroke blueStroke
                , Line.strokeWidth 2
                ]
                data
            ]
    """
