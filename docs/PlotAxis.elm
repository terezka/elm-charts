module PlotAxis exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
import Colors


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Sticky axis"


fileName : String
fileName = "PlotAxis"


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


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


toLabelAttrs : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrs ( index, tick ) =
    if isOdd index then
        [ Label.format (always "") ]
    else
        [ Label.format (\( _, v ) -> toString v ++ " ms")
        ]


toLabelAttrsY1 : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrsY1 ( index, tick ) =
    if isOdd index then
        [ Label.format (always "") ]
    else
        [ Label.format (\( _, v ) -> toString (v * 10) ++ " x")
        , Label.displace (-5, 0)
        ]


toLabelAttrsY2 : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrsY2 ( index, tick ) =
    [ Label.format (\( _, v ) -> toString (v / 5) ++ " k") ]
        


view : Svg.Svg a
view =
    plot
        [ size ( 380, 300 )
        , margin ( 10, 20, 40, 20 )
        , domain ( Just -21, Nothing )
        ]
        [ line
            [ Line.stroke Colors.pinkStroke
            , Line.strokeWidth 2
            ]
            data
        , xAxis
            [ Axis.tick [ Tick.viewDynamic toTickStyle ]
            , Axis.label [ Label.viewDynamic toLabelAttrs ]
            , Axis.cleanCrossings
            ]
        , yAxis
            [ Axis.positionHighest
            , Axis.cleanCrossings
            , Axis.tick [ Tick.viewDynamic toTickStyle ]
            , Axis.label [ Label.viewDynamic toLabelAttrsY1 ]
            ]
        , yAxis
            [ Axis.positionLowest
            , Axis.cleanCrossings
            , Axis.anchorInside
            , Axis.label [ Label.viewDynamic toLabelAttrsY2 ]
            ]
        ]


code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    toTickStyle : Int -> Float -> List TickViewAttr
    toTickStyle index tick =
        if isOdd index then
            [ tickLength 7, tickStyle [ ( "stroke", "#e4e3e3" ) ] ]
        else
            [ tickLength 10, tickStyle [ ( "stroke", "#b9b9b9" ) ] ]


    toLabelAttrs : Int -> Float -> List LabelViewAttr
    toLabelAttrs index tick =
        if isOdd index then
            [ labelFormat (always "") ]
        else
            [ labelFormat (\\l -> toString l ++ " s")
            , labelStyle [ ( "stroke", "#969696" ) ]
            , labelDisplace ( 0, 27 )
            ]


    chart : Svg.Svg a
    chart =
        plot
            [ size ( 380, 300 ) ]
            [ line
                [ lineStyle
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data
            , xAxis
                [ axisStyle [ ( "stroke", Colors.axisColor ) ]
                , tickConfigViewFunc toTickStyle
                , labelConfigViewFunc toLabelAttrs
                ]
            ]
    """
