module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickConfig : Int -> Float -> List TickViewAttr
toTickConfig index tick =
    if isOdd index then
        [ tickLength 7, tickStyle [ ( "stroke", "#e4e3e3" ) ] ]
    else
        [ tickLength 10, tickStyle [ ( "stroke", "#b9b9b9" ) ] ]


toLabelConfig : Int -> Float -> List LabelViewAttr
toLabelConfig index tick =
    if isOdd index then
        [ labelFormat (always "") ]
    else
        [ labelFormat (\l -> toString l ++ " s")
        , labelStyle [ ( "stroke", "#969696" ) ]
        , labelDisplace ( 0, 27 )
        ]


specialTick : Float -> Svg.Svg a
specialTick _ =
    Svg.text_
        [ Svg.Attributes.transform "translate(5, 5)"
        , Svg.Attributes.style "stroke: #969696; font-size: 12px; text-anchor: end;"
        ]
        [ Svg.tspan [] [ Svg.text "🌟" ] ]



main : Svg.Svg a
main =
    plot
        [ size ( 600, 250 ), plotStyle [ ( "padding", "40px" ) ] ]
        [ line
            [ lineStyle
                [ ( "stroke", Colors.pinkStroke )
                , ( "stroke-width", "2px" )
                ]
            ]
            data
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickConfigViewFunc toTickConfig
            , labelConfigViewFunc toLabelConfig
            ]
        , yAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ]
            , tickCustomView specialTick
            , tickRemoveZero
            ]
        ]