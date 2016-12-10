module PlotHint exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
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
        , margin ( 10, 20, 40, 20 )
        , Plot.id "PlotHint"
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
            , Axis.tick
                [ Tick.delta 1 ]
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
            , margin ( 10, 20, 40, 20 )
            , id "PlotHint"
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
                , Axis.tick
                    [ Tick.delta 1 ]
                ]
            , hint
                [ Hint.lineStyle [ ( "background", "#b9b9b9" ) ] ]
                (getHoveredValue state)
            ]
    """
