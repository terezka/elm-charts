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
    , id = id
    }


title : String
title =
    "Sticky axis"


id : String
id =
    "PlotSticky"


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickAttrs : List (Tick.StyleAttribute msg)
toTickAttrs =
    [ Tick.length 7
    , Tick.stroke "#e4e3e3"
    ]


toLabelAttrsY : Axis.LabelInfo -> List (Label.StyleAttribute msg)
toLabelAttrsY { index, value } =
    if not <| isOdd index then
        []
    else
        [ Label.displace ( -5, 0 ) ]


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
                [ Tick.view toTickAttrs ]
            , Axis.tickValues [ 3, 6 ]
            , Axis.line [ Line.stroke Common.axisColor ]
            , Axis.label
                [ Label.format (\{ value } -> toString value ++ " ms") ]
            , Axis.cleanCrossings
            ]
        , yAxis
            [ Axis.positionHighest
            , Axis.cleanCrossings
            , Axis.tick [ Tick.view toTickAttrs ]
            , Axis.line [ Line.stroke Common.axisColor ]
            , Axis.label
                [ Label.viewDynamic toLabelAttrsY
                , Label.format
                    (\{ index, value } ->
                        if not <| isOdd index then
                            ""
                        else
                            toString (value * 10) ++ " x"
                    )
                ]
            ]
        , yAxis
            [ Axis.positionLowest
            , Axis.cleanCrossings
            , Axis.anchorInside
            , Axis.line [ Line.stroke Common.axisColor ]
            , Axis.label
                [ Label.format
                    (\{ index, value } ->
                        if isOdd index then
                            ""
                        else
                            toString (value / 5) ++ "k"
                    )
                ]
            ]
        ]


code : String
code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    toTickAttrs : List (Tick.StyleAttribute msg)
    toTickAttrs =
        [ Tick.length 7
        , Tick.stroke "#e4e3e3"
        ]


    toLabelAttrsY : Axis.LabelInfo -> List (Label.StyleAttribute msg)
    toLabelAttrsY { index, value } =
        if not <| isOdd index then
            []
        else
            [ Label.displace ( -5, 0 ) ]


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
                    [ Tick.view toTickAttrs ]
                , Axis.tickValues [ 3, 6 ]
                , Axis.line [ Line.stroke axisColor ]
                , Axis.label
                    [ Label.format (\\{ value } -> toString value ++ " ms") ]
                , Axis.cleanCrossings
                ]
            , yAxis
                [ Axis.positionHighest
                , Axis.line [ Line.stroke axisColor ]
                , Axis.cleanCrossings
                , Axis.tick [ Tick.view toTickAttrs ]
                , Axis.label
                    [ Label.viewDynamic toLabelAttrsY
                    , Label.format
                        (\\{ index, value } ->
                            if not <| isOdd index then
                                ""
                            else
                                toString (value * 10) ++ " x"
                        )
                    ]
                ]
            , yAxis
                [ Axis.positionLowest
                , Axis.cleanCrossings
                , Axis.line [ Line.stroke axisColor ]
                , Axis.anchorInside
                , Axis.label
                    [ Label.format
                        (\\{ index, value } ->
                            if isOdd index then
                                ""
                            else
                                toString (value / 5) ++ "k"
                        )
                    ]
                ]
            ]
    """
