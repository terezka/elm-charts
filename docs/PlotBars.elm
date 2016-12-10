module PlotBars exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Bars as Bars
import Plot.Pile as Pile
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
    , fileName = fileName
    }


title : String
title =
    "Bars"


fileName : String
fileName =
    "PlotBars"


data : List ( Float, Float )
data =
    [ ( 0, 20 ), ( 1, 10 ), ( 2, 40 ) ]


labels : List ( Int, String )
labels =
    [ ( 0, "A" ), ( 1, "B" ), ( 2, "C" ) ]


formatter : ( Int, Float ) -> String
formatter ( index, tick ) =
    List.filter (\( i, label ) -> i == index) labels
        |> List.head
        |> Maybe.withDefault ( 0, "-" )
        |> Tuple.second


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ pile
            [ Pile.maxBarWidthPer 85 ]
            [ Pile.bars
                [ Bars.fill Common.blueFill ]
                (List.map (\( x, y ) -> ( x, y * 2 )) data)
            , Pile.bars
                [ Bars.fill Common.skinFill ]
                (List.map (\( x, y ) -> ( x, y * 3 )) data)
            , Pile.bars
                [ Bars.fill Common.pinkFill ]
                data
            ]
        , xAxis
            [ Axis.line [ Line.stroke Common.axisColor ]
            , Axis.tick [ Tick.delta 1 ]
            , Axis.label
                [ Label.view
                    [ Label.format formatter
                    , Label.stroke "#969696"
                    ]
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
            [ pile
                [ Pile.maxBarWidthPer 85 ]
                [ Pile.bars
                    [ Bars.fill Common.blueFill ]
                    data1
                , Pile.bars
                    [ Bars.fill Common.skinFill ]
                    data2
                , Pile.bars
                    [ Bars.fill Common.pinkFill ]
                    data3
                ]
            , xAxis
                [ Axis.line [ Line.stroke Common.axisColor ]
                , Axis.tick [ Tick.delta 1 ]
                , Axis.label
                    [ Label.view
                        [ Label.format formatter
                        , Label.stroke "#969696"
                        ]
                    ]
                ]
            ]
    """
