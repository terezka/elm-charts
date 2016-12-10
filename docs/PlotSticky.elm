module PlotSticky exposing (plotExample)

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
    "Sticky axis"


fileName : String
fileName =
    "PlotSticky"


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
    if not <| isOdd index then
        [ Label.format (always "") ]
    else
        [ Label.format (\( _, v ) -> toString (v * 10) ++ " x")
        , Label.displace ( -5, 0 )
        ]


toLabelAttrsY2 : ( Int, Float ) -> List (Label.StyleAttribute msg)
toLabelAttrsY2 ( index, tick ) =
    if isOdd index then
        [ Label.format (always "") ]
    else
        [ Label.format (\( _, v ) -> toString (v / 5) ++ "k") ]


view : Svg.Svg a
view =
    plot
        [ size plotSize
        , margin ( 10, 20, 40, 20 )
        , padding ( 0, 20 )
        , domainLowest (always -21)
        ]
        [ line
            [ Line.stroke pinkStroke
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


code : String
code =
    """
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
        [ Label.format (\\( _, v ) -> toString v ++ " ms") ]


    toLabelAttrsY1 : ( Int, Float ) -> List (Label.StyleAttribute msg)
    toLabelAttrsY1 ( index, tick ) =
        if not <| isOdd index then
            [ Label.format (always "") ]
        else
            [ Label.format (\\( _, v ) -> toString (v * 10) ++ " x")
            , Label.displace ( -5, 0 )
            ]


    toLabelAttrsY2 : ( Int, Float ) -> List (Label.StyleAttribute msg)
    toLabelAttrsY2 ( index, tick ) =
        if isOdd index then
            [ Label.format (always "") ]
        else
            [ Label.format (\\( _, v ) -> toString (v / 5) ++ "k") ]


    view : Svg.Svg a
    view =
        plot
            [ size plotSize
            , margin ( 10, 20, 40, 20 )
            , padding ( 0, 20 )
            , domainLowest (always -21)
            ]
            [ line
                [ Line.stroke pinkStroke
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
    """
