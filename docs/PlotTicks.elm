module PlotTicks exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
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
    "Custom ticks and labels"


fileName : String
fileName =
    "PlotTicks"


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


toLabelStyle : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelStyle ( index, tick ) =
    if isOdd index then
        [ Label.format (always "") ]
    else
        [ Label.format (\( _, v ) -> toString v ++ " s")
        , Label.stroke "#969696"
        ]


view : Svg.Svg a
view =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 20 )
        ]
        [ line
            [ Line.stroke pinkStroke
            , Line.strokeWidth 2
            ]
            data
        , xAxis
            [ Axis.line [ Line.stroke axisColor ]
            , Axis.tick [ Tick.viewDynamic toTickStyle ]
            , Axis.label [ Label.viewDynamic toLabelStyle ]
            ]
        ]


code : String
code =
    """
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


    toLabelStyle : ( Int, Float ) -> List (Label.StyleAttribute msg)
    toLabelStyle ( index, tick ) =
        if isOdd index then
            [ Label.format (always "") ]
        else
            [ Label.format (\\( _, v ) -> toString v ++ " s")
            , Label.stroke "#969696"
            ]


    view : Svg.Svg a
    view =
        plot
            [ size plotSize
            , margin ( 10, 20, 40, 20 )
            ]
            [ line
                [ Line.stroke pinkStroke
                , Line.strokeWidth 2
                ]
                data
            , xAxis
                [ Axis.line [ Line.stroke axisColor ]
                , Axis.tick [ Tick.viewDynamic toTickStyle ]
                , Axis.label [ Label.viewDynamic toLabelStyle ]
                ]
            ]
    """
