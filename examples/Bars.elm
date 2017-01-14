module Bars exposing (..)

import Svg
import Html exposing (div)
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Bars as Bars


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


main : Svg.Svg msg
main =
    div []
        [ plot
            [ size ( 600, 300 )
            , margin ( 100, 20, 40, 40 )
            ]
            [ bars
                [ Bars.maxBarWidth 20
                , Bars.stackByY
                ]
                [ [ Bars.fill "blue" ]
                , [ Bars.fill "red" ]
                , [ Bars.fill "green" ]
                ]
                (Bars.toBarData
                    { yValues = .values
                    , xValue = Nothing
                    }
                    [ { values = [ -1, -3, -2 ] }
                    , { values = [ -2, -1, -4 ] }
                    , { values = [ -4, -2, -1 ] }
                    , { values = [ -4, -5, -2 ] }
                    ]
                )
            , yAxis [ Axis.line [ Line.stroke "black" ] ]
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 300 )
            , margin ( 100, 20, 40, 40 )
            ]
            [ bars
                [ Bars.maxBarWidth 20
                , Bars.stackByY
                ]
                [ [ Bars.fill "blue" ]
                , [ Bars.fill "red" ]
                , [ Bars.fill "green" ]
                ]
                (Bars.toBarData
                    { yValues = .values
                    , xValue = Nothing
                    }
                    [ { values = [ 1, 3, 2 ] }
                    , { values = [ 2, 1, 4 ] }
                    , { values = [ 4, 2, 1 ] }
                    , { values = [ 4, 5, 2 ] }
                    ]
                )
            , yAxis [ Axis.line [ Line.stroke "black" ] ]
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 300 )
            , margin ( 100, 20, 40, 40 )
            ]
            [ bars
                [ Bars.maxBarWidthPer 85
                ]
                [ [ Bars.fill "blue" ]
                , [ Bars.fill "red" ]
                , [ Bars.fill "green" ]
                ]
                (Bars.toBarData
                    { yValues = .values
                    , xValue = Nothing
                    }
                    [ { values = [ -1, -3, -2 ] }
                    , { values = [ -2, -1, -4 ] }
                    , { values = [ -4, -2, -1 ] }
                    , { values = [ -4, -5, -2 ] }
                    ]
                )
            , yAxis [ Axis.line [ Line.stroke "black" ] ]
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        , plot
            [ size ( 600, 300 )
            , margin ( 100, 20, 40, 40 )
            ]
            [ bars
                [ Bars.maxBarWidthPer 85
                ]
                [ [ Bars.fill "blue" ]
                , [ Bars.fill "red" ]
                , [ Bars.fill "green" ]
                ]
                (Bars.toBarData
                    { yValues = .values
                    , xValue = Nothing
                    }
                    [ { values = [ 1, 3, 2 ] }
                    , { values = [ 2, 1, 4 ] }
                    , { values = [ 4, 2, 1 ] }
                    , { values = [ 4, 5, 2 ] }
                    ]
                )
            , yAxis [ Axis.line [ Line.stroke "black" ] ]
            , xAxis
                [ Axis.line [ Line.stroke "black" ]
                , Axis.tickDelta 1
                ]
            ]
        ]
