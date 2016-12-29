module PlotBars exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Bars as Bars
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
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
        , rangeLowest (always -0.5)
        , rangeHighest (\h -> h + 0.5)
        ]
        [ bars
            [ Bars.maxBarWidthPer 85
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
            , Axis.label
                [ Label.view
                    [ Label.formatFromList [ "1st", "2nd", "3rd", "4th" ] ]
                ]
            ]
        ]


code : String
code =
    """
    view : Svg.Svg a
    view =
        plot
            [ size Common.plotSize
            , margin ( 10, 20, 40, 20 )
            ]
            [ bars
                [ Bars.maxBarWidthPer 85 ]
                [ [ Bars.fill Common.blueFill ]
                , [ Bars.fill Common.skinFill ]
                , [ Bars.fill Common.pinkFill ]
                ]
                [ [ 1, 4, 5, 2 ]
                , [ 2, 1, 3, 5 ]
                , [ 4, 5, 2, 1 ]
                , [ 4, 5, 2, 3 ]
                ]
            , xAxis
                [ Axis.line [ Line.stroke Common.axisColor ]
                , Axis.tick [ Tick.delta 1 ]
                , Axis.label
                    [ Label.view
                        [ Label.stroke "#969696"
                        , Label.formatFromList [ "1st", "2nd", "3rd", "4th" ]
                        ]
                    ]
                ]
            ]
    """
