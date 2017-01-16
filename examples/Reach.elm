module Reach exposing (..)

import Svg
import Html exposing (div)
import Plot exposing (..)
import Plot.Line as Line
import Plot.Area as Area
import Plot.Axis as Axis


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


data3 : List ( Float, Float )
data3 =
    [ ( 0, 10 ), ( 0.5, 20 ), ( 1, 5 ), ( 1.5, 4 ), ( 2, 7 ), ( 2.5, 5 ), ( 3, 10 ), ( 3.5, 15 ) ]


main : Svg.Svg msg
main =
    div []
        [ plot
            [ size ( 600, 400 )
            , margin ( 40, 30, 40, 30 )
            , rangeLowest (always 1)
            , domainLowest (always 5)
            ]
            [ line
                [ Line.stroke "red"
                , Line.opacity 0.5
                , Line.strokeWidth 1
                ]
                data3
            , yAxis []
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 400 )
            , margin ( 40, 30, 40, 30 )
            ]
            [ area
                [ Area.stroke "red"
                , Area.fill "red"
                , Area.opacity 0.5
                , Area.strokeWidth 1
                , Area.smoothingBezier
                ]
                data3
            , verticalGrid []
            , horizontalGrid []
            , yAxis []
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 400 )
            , margin ( 40, 30, 40, 30 )
            , domainLowest (min 0)
            ]
            [ line
                [ Line.stroke "red"
                , Line.opacity 0.5
                , Line.strokeWidth 1
                , Line.smoothingBezier
                ]
                data3
            , verticalGrid []
            , horizontalGrid []
            , yAxis []
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 400 )
            , margin ( 40, 30, 40, 30 )
            , rangeLowest (always 0.5)
            , domainLowest (always 4)
            , domainHighest (\y -> y + 1)
            ]
            [ area
                [ Area.stroke "red"
                , Area.fill "red"
                , Area.opacity 0.5
                , Area.strokeWidth 1
                , Area.smoothingBezier
                ]
                data3
            , yAxis []
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        ]
