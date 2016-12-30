module PlotBars exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Bars as Bars
import Plot.Axis as Axis
import Plot.Tick as Tick
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
    "Bars"


id : String
id =
    "PlotBars"


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 30 )
        , padding ( 0, 20 )
        ]
        [ bars
            [ Bars.maxBarWidth 9
            , Bars.stackByY
            ]
            [ [ Bars.fill Common.blueFill ]
            , [ Bars.fill Common.skinFill ]
            , [ Bars.fill Common.pinkFill ]
            ]
            (Bars.toBarData
                { yValues = .values
                , xValue = Nothing
                }
                [ { values = [ 1, 3, 2 ] }
                , { values = [ 2, 1, 4 ] }
                , { values = [ 4, 2, 1 ] }
                , { values = [ 4, 5, 2 ] }
                ]
            )
        , xAxis
            [ Axis.line [ Line.stroke Common.axisColor ]
            , Axis.tick [ Tick.delta 1 ]
            ]
        ]


code : String
code =
    """
    view : Svg.Svg a
    view =
        plot
            [ size Common.plotSize
            , margin ( 10, 20, 40, 30 )
            , padding ( 0, 20 )
            ]
            [ bars
                [ Bars.maxBarWidth 9
                , Bars.stackByY
                ]
                [ [ Bars.fill Common.blueFill ]
                , [ Bars.fill Common.skinFill ]
                , [ Bars.fill Common.pinkFill ]
                ]
                (Bars.toBarData
                    { yValues = .values
                    , xValue = Nothing
                    }
                    [ { values = [ 1, 3, 2 ] }
                    , { values = [ 2, 1, 4 ] }
                    , { values = [ 4, 2, 1 ] }
                    , { values = [ 4, 5, 2 ] }
                    ]
                )
            , xAxis
                [ Axis.line [ Line.stroke Common.axisColor ]
                , Axis.tick [ Tick.delta 1 ]
                ]
            ]

    """
