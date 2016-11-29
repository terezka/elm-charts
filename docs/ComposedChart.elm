module ComposedChart exposing (chart, code)

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
import Plot.Label as Label
import Debug
import Colors


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


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
    , Label.stroke "#969696"
    , Label.fontSize 12
    , Label.displace ( -15, 5 )
    ]


chart : State -> Svg.Svg (Interaction c)
chart state =
    plotInteractive
        [ size ( 600, 400 )
        , padding ( 40, 40 )
        , margin ( 10, 20, 40, 20 )
        , id "ComposedChart"
        ]
        [ horizontalGrid
            [ Grid.stroke "#f2f2f2"
            ]
        , area
            [ Area.stroke Colors.skinStroke
            , Area.fill Colors.skinFill
            , Area.opacity 0.5
            ]
            (List.map (\( x, y ) -> ( x, toFloat <| round (y * 2.1) )) data1)
        , area
            [ Area.stroke Colors.blueStroke
            , Area.fill Colors.blueFill
            ]
            data1
        , line
            [ Line.stroke Colors.pinkStroke
            , Line.strokeWidth 2
            ]
            (List.map (\( x, y ) -> ( x, toFloat <| round y * 3 )) data1)
        , yAxis
            [ Axis.view
                [ Axis.style [ ( "stroke", "#b9b9b9" ) ] ]
            , Axis.tick
                [ Tick.removeZero
                , Tick.delta 50
                ]
            , Axis.label
                [ Label.view labelStyle ]
            ]
        , xAxis
            [ Axis.view
                [ Axis.style [ ( "stroke", "#b9b9b9" ) ] ]
            , Axis.tick
                [ Tick.removeZero
                , Tick.viewDynamic toTickStyle
                ]
            , Axis.label
                [ Label.view
                    [ Label.format (\( _, v ) -> toString v ++ " t")
                    , Label.fontSize 12
                    , Label.stroke "#b9b9b9"
                    ]
                , Label.filter filterLabels
                ]
            ]
        , hint [ Hint.lineStyle [ ( "background", Colors.pinkStroke ) ] ] (getHoveredValue state)
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


    chart : State -> Svg.Svg (Interaction c)
    chart { position } =
        plotInteractive
            [ size ( 600, 400 )
            , padding ( 40, 40 )
            , margin ( 10, 20, 40, 20 )
            , id "ComposedChart"
            ]
            [ horizontalGrid
                [ Grid.style [ ( "stroke", "#f2f2f2" ) ]
                ]
            , area
                [ Area.style
                    [ ( "stroke", Colors.skinStroke )
                    , ( "fill", Colors.skinFill )
                    , ( "opacity", "0.5" )
                    ]
                ]
                data1
            , area
                [ Area.style
                    [ ( "stroke", Colors.blueStroke )
                    , ( "fill", Colors.blueFill )
                    ]
                ]
                data2
            , line
                [ Line.style
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data3
            , yAxis
                [ Axis.view [ Axis.style [ ( "stroke", "#b9b9b9" ) ] ]
                , Axis.tick
                    [ Tick.removeZero
                    , Tick.delta 50
                    ]
                , Axis.label
                    [ Label.view labelStyle ]
                ]
            , xAxis
                [ Axis.view [ Axis.style [ ( "stroke", "#b9b9b9" ) ] ]
                , Axis.tick
                    [ Tick.removeZero
                    , Tick.viewDynamic toTickStyle
                    ]
                , Axis.label
                    [ Label.view
                        [ Label.format (\\( _, v ) -> toString v ++ " t")
                        , Label.style [ ( "font-size", "12px" ), ( "stroke", "#b9b9b9" ) ]
                        ]
                    , Label.filter filterLabels
                    ]
                ]
            , hint [ Hint.lineStyle [ ( "background", Colors.pinkStroke ) ] ] position
            ]
    """
