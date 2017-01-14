module PlotHint exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Bars as Bars
import Plot.Hint as Hint
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = title
    , code = code
    , id = id
    , view = ViewInteractive id view
    }


title : String
title =
    "Hints"


id : String
id =
    "PlotHint"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


view : State -> Svg.Svg (Interaction msg)
view state =
    plotInteractive
        [ size plotSize
        , margin ( 10, 20, 40, 40 )
        ]
        [ bars
            [ Bars.maxBarWidthPer 85 ]
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
            [ Axis.line [ Line.stroke axisColor ]
            , Axis.tickDelta 1
            ]
        , hint
            [ Hint.lineStyle [ ( "background", "#b9b9b9" ) ] ]
            (getHoveredValue state)
        ]


code : String
code =
    """
    view : State -> Svg.Svg (Interaction msg)
    view state =
        plotInteractive
            [ size plotSize
            , margin ( 10, 20, 40, 40 )
            ]
            [ bars
                [ Bars.maxBarWidthPer 85 ]
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
                [ Axis.line [ Line.stroke axisColor ]
                , Axis.tickDelta 1
                ]
            , hint
                [ Hint.lineStyle [ ( "background", "#b9b9b9" ) ] ]
                (getHoveredValue state)
            ]
    """
