module PlotComposed exposing (view, code, id)

import Svg
import Plot exposing (..)
import Plot.Area as Area
import Plot.Line as Line
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Hint as Hint
import Plot.Label as Label
import Common exposing (..)


id : String
id =
    "ComposedPlot"


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


dataScat : List ( Float, Float )
dataScat =
    [ ( -8, 50 ), ( -7, 45 ), ( -6.5, 70 ), ( -6, 90 ), ( -4, 81 ), ( -3, 106 ), ( -1, 115 ), ( 0, 140 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


filterLabels : Axis.LabelInfo -> Bool
filterLabels { index } =
    not (isOdd index)


toTickStyle : Axis.LabelInfo -> List (Tick.StyleAttribute msg)
toTickStyle { index } =
    if isOdd index then
        [ Tick.length 7
        , Tick.stroke "#e4e3e3"
        ]
    else
        [ Tick.length 10
        , Tick.stroke "#b9b9b9"
        ]


labelStyle : List (Label.StyleAttribute msg)
labelStyle =
    [ Label.fontSize 12
    , Label.displace ( 0, -2 )
    ]


view : State -> Svg.Svg (Interaction c)
view state =
    plotInteractive
        [ size ( 800, 400 )
        , padding ( 40, 40 )
        , margin ( 15, 20, 40, 15 )
        ]
        [ horizontalGrid
            [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
        , verticalGrid
            [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
        , area
            [ Area.stroke skinStroke
            , Area.fill skinFill
            , Area.opacity 0.5
            , Area.smoothingBezier
            ]
            (List.map (\( x, y ) -> ( x, toFloat <| round (y * 2.1) )) data1)
        , area
            [ Area.stroke blueStroke
            , Area.fill blueFill
            , Area.smoothingBezier
            ]
            data1
        , line
            [ Line.stroke pinkStroke
            , Line.smoothingBezier
            , Line.strokeWidth 2
            ]
            (List.map (\( x, y ) -> ( x, toFloat <| round y * 3 )) data1)
        , scatter
            []
            dataScat
        , yAxis
            [ Axis.anchorInside
            , Axis.cleanCrossings
            , Axis.positionLowest
            , Axis.line
                [ Line.stroke "#b9b9b9" ]
            , Axis.tickDelta 50
            , Axis.label
                [ Label.view labelStyle
                , Label.format (\{ value } -> toString value ++ " °C")
                ]
            ]
        , xAxis
            [ Axis.cleanCrossings
            , Axis.line
                [ Line.stroke "#b9b9b9" ]
            , Axis.tickDelta 2.5
            , Axis.tick
                [ Tick.viewDynamic toTickStyle ]
            , Axis.label
                [ Label.view
                    [ Label.fontSize 12
                    , Label.stroke "#b9b9b9"
                    ]
                , Label.format (\{ value } -> toString value ++ " x")
                ]
            ]
        , xAxis
            [ Axis.positionLowest
            , Axis.line [ Line.stroke "#b9b9b9" ]
            , Axis.tick
                [ Tick.viewDynamic toTickStyle ]
            , Axis.label
                [ Label.view
                    [ Label.fontSize 12
                    , Label.stroke "#b9b9b9"
                    ]
                , Label.format
                    (\{ value, index } ->
                        if isOdd index then
                            ""
                        else
                            toString value ++ " t"
                    )
                ]
            ]
        , hint
            [ Hint.lineStyle [ ( "background", "#b9b9b9" ) ] ]
            (getHoveredValue state)
        ]


code : String
code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    filterLabels : Axis.LabelInfo -> Bool
    filterLabels { index } =
        not (isOdd index)


    toTickStyle : Axis.LabelInfo -> List (Tick.StyleAttribute msg)
    toTickStyle { index } =
        if isOdd index then
            [ Tick.length 7
            , Tick.stroke "#e4e3e3"
            ]
        else
            [ Tick.length 10
            , Tick.stroke "#b9b9b9"
            ]


    labelStyle : List (Label.StyleAttribute msg)
    labelStyle =
        [ Label.fontSize 12
        , Label.displace ( 0, -2 )
        ]


    view : State -> Svg.Svg (Interaction c)
    view state =
        plotInteractive
            [ size ( 800, 400 )
            , padding ( 40, 40 )
            , margin ( 15, 20, 40, 15 )
            ]
            [ horizontalGrid
                [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
            , verticalGrid
                [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
            , area
                [ Area.stroke skinStroke
                , Area.fill skinFill
                , Area.opacity 0.5
                ]
                data1
            , area
                [ Area.stroke blueStroke
                , Area.fill blueFill
                ]
                data1
            , line
                [ Line.stroke pinkStroke
                , Line.strokeWidth 2
                ]
                data2
            , scatter
                []
                data3
            , yAxis
                [ Axis.anchorInside
                , Axis.cleanCrossings
                , Axis.positionLowest
                , Axis.line
                    [ Line.stroke "#b9b9b9" ]
                , Axis.tickDelta 50
                , Axis.label
                    [ Label.view labelStyle
                    , Label.format (\\{ value } -> toString value ++ " °C")
                    ]
                ]
            , xAxis
                [ Axis.cleanCrossings
                , Axis.line
                    [ Line.stroke "#b9b9b9" ]
                , Axis.tickDelta 2.5
                , Axis.tick
                    [ Tick.viewDynamic toTickStyle ]
                , Axis.label
                    [ Label.view
                        [ Label.fontSize 12
                        , Label.stroke "#b9b9b9"
                        ]
                    , Label.format (\\{ value } -> toString value ++ " x")
                    ]
                ]
            , xAxis
                [ Axis.positionLowest
                , Axis.line [ Line.stroke "#b9b9b9" ]
                , Axis.tick
                    [ Tick.viewDynamic toTickStyle ]
                , Axis.label
                    [ Label.view
                        [ Label.fontSize 12
                        , Label.stroke "#b9b9b9"
                        ]
                    , Label.format
                        (\\{ value, index } ->
                            if isOdd index then
                                ""
                            else
                                toString value ++ " t"
                        )
                    ]
                ]
            , hint
                [ Hint.lineStyle [ ( "background", "#b9b9b9" ) ] ]
                (getHoveredValue state)
            ]
    """
