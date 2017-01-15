module PlotBars exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Bars as Bars
import Plot.Axis as Axis
import Plot.Line as Line
import Plot.Label as Label
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


formatter : Bars.LabelInfo -> String
formatter { index, xValue, yValue } =
    toString index ++ ": (" ++ toString xValue ++ ", " ++ toString yValue ++ ")"


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 30 )
        , padding ( 0, 20 )
        ]
        [ bars
            [ Bars.maxBarWidth 30
            , Bars.stackByY
            , Bars.label
                [ Label.formatFromList [ "A", "B", "C" ]
                , Label.view
                    [ Label.displace ( 0, 13 )
                    , Label.fontSize 10
                    ]
                ]
            ]
            [ [ Bars.fill Common.blueFill ]
            , [ Bars.fill Common.skinFill ]
            , [ Bars.fill Common.pinkFill ]
            ]
            (Bars.toBarData
                { yValues = .values
                , xValue = Nothing
                }
                [ { values = [ 40, 30, 20 ] }
                , { values = [ 20, 30, 40 ] }
                , { values = [ 40, 20, 10 ] }
                , { values = [ 40, 50, 20 ] }
                ]
            )
        , xAxis
            [ Axis.line [ Line.stroke Common.axisColor ]
            , Axis.tickDelta 1
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
                [ Bars.maxBarWidth 30
                , Bars.stackByY
                , Bars.label
                    [ Label.formatFromList [ "A", "B", "C" ]
                    , Label.view
                        [ Label.displace ( 0, 13 )
                        , Label.fontSize 10
                        ]
                    ]
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
                , Axis.tickDelta 1
                ]
            ]
    """
