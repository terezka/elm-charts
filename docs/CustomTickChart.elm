module CustomTickChart exposing (customTickChart)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


getTickColor : Int -> String
getTickColor fromZero =
    if isOdd fromZero then
        "#e4e3e3"
    else
        "#b9b9b9"


getTickLength : Int -> Int
getTickLength fromZero =
    if isOdd fromZero then
        7
    else
        10


viewTick : Int -> Float -> Svg.Svg a
viewTick fromZero _ =
    Svg.line
        [ Svg.Attributes.style ("stroke: " ++ getTickColor fromZero)
        , Svg.Attributes.y2 (toString (getTickLength fromZero))
        ]
        []


viewLabelEven : Float -> Svg.Svg a
viewLabelEven tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(0, 27)"
        , Svg.Attributes.style "text-anchor: middle; stroke: #969696;"
        ]
        [ Svg.tspan [] [ Svg.text ((toString tick) ++ " s") ] ]


viewLabel : Int -> Float -> Svg.Svg a
viewLabel fromZero tick =
    if isOdd fromZero then
        Svg.text ""
    else
        viewLabelEven tick


customTickChart : Svg.Svg a
customTickChart =
    plot
        [ size ( 600, 250 ) ]
        [ line
            [ lineStyle
                [ ( "stroke", Colors.skinStroke )
                , ( "stroke-width", "2px" )
                ]
            ]
            data
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickCustomViewIndexed viewTick
            , labelCustomViewIndexed viewLabel
            ]
        ]


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]
