module PlotComposed exposing (view, code)

import Svg
import Svg.Attributes
import Svg.Events
import Plot exposing (..)
import Plot.Area as Area
import Plot.Line as Line
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Hint as Hint
import Plot.Pile as Pile
import Plot.Bars as Bars
import Plot.Label as Label
import Debug
import Common


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


dataScat : List ( Float, Float )
dataScat =
    [ ( -8, 50 ), ( -7, 45 ), ( -6.5, 70 ), ( -6, 90 ), ( -4, 81 ), ( -3, 106 ), ( -1, 115 ), ( 0, 140 ) ]



isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


filterLabels : ( Int, Float ) -> Bool
filterLabels ( index, _ ) =
    not (isOdd index)


toTickStyle : ( Int, Float ) -> List (Tick.StyleAttribute msg)
toTickStyle ( index, tick ) =
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
    [ Label.format (\( _, v ) -> toString v ++ " °C")
    , Label.fontSize 12
    , Label.displace (0, -2)
    ]


view : State -> Svg.Svg (Interaction c)
view state =
    plotInteractive
        [ size ( 800, 400 )
        , padding ( 40, 40 )
        , margin ( 10, 20, 40, 15 )
        , id "PlotComposed"
        ]
        [ horizontalGrid
            [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
        , verticalGrid
            [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
        , pile
            []
            [ Pile.bars
                [ Bars.fill Common.blueFill ]
                (List.map (\(x, y) -> (x / 2 - 2.5, y*2)) data1)
            
            , Pile.bars
                [ Bars.fill Common.skinFill ]
                (List.map (\(x, y) -> (x / 2 - 2.5, y*3)) data1)
            , Pile.bars
                [ Bars.fill Common.pinkFill ]
                (List.map (\(x, y) -> (x / 2 - 2.5, y)) data1)
            ]
        , area
            [ Area.stroke Common.skinStroke
            , Area.fill Common.skinFill
            , Area.opacity 0.5
            ]
            (List.map (\( x, y ) -> ( x, toFloat <| round (y * 2.1) )) data1)
        , area
            [ Area.stroke Common.blueStroke
            , Area.fill Common.blueFill
            ]
            data1
        , line
            [ Line.stroke Common.pinkStroke
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
            , Axis.tick
                [ Tick.delta 50 ]
            , Axis.label
                [ Label.view labelStyle ]
            ]
        , xAxis
            [ Axis.cleanCrossings
            , Axis.line
                [ Line.stroke "#b9b9b9" ]
            , Axis.tick
                [ Tick.viewDynamic toTickStyle
                , Tick.delta 2.5
                ]
            , Axis.label
                [ Label.view
                    [ Label.format (\( _, v ) -> toString v ++ " x")
                    , Label.fontSize 12
                    , Label.stroke "#b9b9b9"
                    ]
                ]
            ]
        , xAxis
            [ Axis.positionLowest
            , Axis.line [ Line.stroke "#b9b9b9" ]
            , Axis.tick
                [ Tick.viewDynamic toTickStyle ]
            , Axis.label
                [ Label.view
                    [ Label.format (\( _, v ) -> toString v ++ " t")
                    , Label.fontSize 12
                    , Label.stroke "#b9b9b9"
                    ]
                , Label.filter filterLabels
                ]
            ]
        , hint
            [ Hint.lineStyle [ ( "background", "#b9b9b9") ] ]
            (getHoveredValue state)
        ]


code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    filterLabels : ( Int, Float ) -> Bool
    filterLabels ( index, _ ) =
        not (isOdd index)


    toTickStyle : ( Int, Float ) -> List Tick.StyleAttribute
    toTickStyle ( index, tick ) =
        if isOdd index then
            [ Tick.length 7
            , Tick.style [ ( "stroke", "#e4e3e3" ) ]
            ]
        else
            [ Tick.length 10
            , Tick.style [ ( "stroke", "#b9b9b9" ) ]
            ]


    labelStyle : List Label.StyleAttribute
    labelStyle =
        [ Label.format (\\( _, v ) -> toString v ++ " °C")
        , Label.style
            [ ( "stroke", "#969696" )
            , ( "font-size", "12px" )
            ]
        , Label.displace ( -15, 5 )
        ]


    view : State -> Svg.Svg (Interaction c)
    view state =
        plotInteractive
            [ size ( 600, 400 )
            , padding ( 40, 40 )
            , margin ( 10, 20, 40, 50 )
            , id "PlotComposed"
            ]
            [ horizontalGrid
                [ Grid.lines [ Line.stroke "#f2f2f2" ] ]
            , area
                [ Area.stroke Common.skinStroke
                , Area.fill Common.skinFill
                , Area.opacity 0.5
                ]
                data0
            , area
                [ Area.stroke Common.blueStroke
                , Area.fill Common.blueFill
                ]
                data1
            , line
                [ Line.stroke Common.pinkStroke
                , Line.strokeWidth 2
                ]
                data2
            , yAxis
                [ Axis.anchorInside
                , Axis.cleanCrossings
                , Axis.positionLowest
                , Axis.line
                    [ Line.stroke "#b9b9b9" ]
                , Axis.tick
                    [ Tick.delta 50 ]
                , Axis.label
                    [ Label.view labelStyle ]
                ]
            , xAxis
                [ Axis.cleanCrossings
                , Axis.line
                    [ Line.stroke "#b9b9b9" ]
                , Axis.tick
                    [ Tick.viewDynamic toTickStyle
                    , Tick.delta 2.55
                    ]
                , Axis.label
                    [ Label.view
                        [ Label.format (\\( _, v ) -> toString v ++ " t")
                        , Label.fontSize 12
                        , Label.stroke "#b9b9b9"
                        ]
                    ]
                ]
            , xAxis
                [ Axis.positionLowest
                , Axis.line [ Line.stroke "#b9b9b9" ]
                , Axis.tick
                    [ Tick.viewDynamic toTickStyle ]
                , Axis.label
                    [ Label.view
                        [ Label.format (\\( _, v ) -> toString v ++ " t")
                        , Label.fontSize 12
                        , Label.stroke "#b9b9b9"
                        ]
                    , Label.filter filterLabels
                    ]
                ]
            , hint
                [ Hint.lineStyle [ ( "background", "#b9b9b9") ] ]
                (getHoveredValue state)
            ]
    """
