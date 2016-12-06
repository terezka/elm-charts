module PlotSticky exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
import Common


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Sticky axis"


fileName : String
fileName = "PlotSticky"


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickAttrs : ( Int, Float ) -> List (Tick.StyleAttribute msg)
toTickAttrs ( index, tick ) =
    [ Tick.length 7
    , Tick.stroke "#e4e3e3"
    ]


toLabelAttrs : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrs ( index, tick ) =
    [ Label.format (\( _, v ) -> toString v ++ " ms") ]


toLabelAttrsY1 : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrsY1 ( index, tick ) =
    if not <| isOdd index
    then [ Label.format (always "") ]
    else 
        [ Label.format (\( _, v ) -> toString (v * 10) ++ " x")
        , Label.displace (-5, 0)
        ]


toLabelAttrsY2 : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrsY2 ( index, tick ) =
    if isOdd index
    then [ Label.format (always "") ]
    else [ Label.format (\( _, v ) -> toString (v / 5) ++ "k") ]
        


view : Svg.Svg a
view =
    plot
        [ size Common.plotSize
        , margin ( 10, 20, 40, 20 )
        , padding ( 0, 20 )
        , domain ( Just -21, Nothing )
        ]
        [ line
            [ Line.stroke Common.pinkStroke
            , Line.strokeWidth 2
            ]
            data
        , xAxis
            [ Axis.tick
                [ Tick.viewDynamic toTickAttrs
                , Tick.values [ 3, 6 ]
                ]
            , Axis.label [ Label.viewDynamic toLabelAttrs ]
            , Axis.cleanCrossings
            ]
        , yAxis
            [ Axis.positionHighest
            , Axis.cleanCrossings
            , Axis.tick [ Tick.viewDynamic toTickAttrs ]
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


    toTickAttrs : Int -> Float -> List TickViewAttr
    toTickAttrs index tick =
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
                    [ ( "stroke", Common.pinkStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data
            , xAxis
                [ axisStyle [ ( "stroke", Common.axisColor ) ]
                , tickConfigViewFunc toTickAttrs
                , labelConfigViewFunc toLabelAttrs
                ]
            ]
    """
