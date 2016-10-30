module CustomTickChart exposing (customTickChart)

import Svg
import Svg.Attributes
import Plot exposing (..)


isOdd : Float -> Bool
isOdd n =
    rem (round n) 2 > 0


customTick : Float -> Svg.Svg a
customTick tick =
    let
        length =
            if isOdd tick then
                7
            else
                10

        color =
            if isOdd tick then
                "#e4e3e3"
            else
                "#b9b9b9"
    in
        Svg.line
            [ Svg.Attributes.style ("stroke: " ++ color)
            , Svg.Attributes.y2 (toString length)
            ]
            []


customLabel : Float -> Svg.Svg a
customLabel tick =
    let
        length =
            if isOdd tick then
                7
            else
                10

        text =
            if isOdd tick then
                ""
            else
                ((toString tick) ++ " s")
    in
        Svg.text'
            [ Svg.Attributes.transform ("translate(0, 27)")
            , Svg.Attributes.style "text-anchor: middle; stroke: #969696;"
            ]
            [ Svg.tspan [] [ Svg.text text ] ]


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


customTickChart : Svg.Svg a
customTickChart =
    plot
        [ size ( 600, 250 ) ]
        [ line [ lineStyle [ ( "stroke", "#b6c9ef" ), ( "stroke-width", "2px" ) ] ] data
        , xAxis [ axisStyle [ ( "stroke", "#b9b9b9" ) ], viewTick customTick, viewLabel customLabel ]
        ]
