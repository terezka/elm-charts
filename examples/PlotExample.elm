module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Debug


isOdd : Float -> Bool
isOdd n =
    rem (round (abs n)) 2 > 0


type Orientation
    = X
    | Y


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


formatTickX : Float -> String
formatTickX tick =
    if tick == 0 then
        ""
    else if isOdd tick then
        ""
    else
        let
            abbrivated =
                (abs tick * 2) > 10

            formatted =
                if abbrivated then
                    tick / 10 * 2
                else
                    tick * 200

            abbrivation =
                if abbrivated then
                    "k t"
                else
                    " t"
        in
            (toString formatted) ++ abbrivation


formatTickY : Float -> String
formatTickY tick =
    if tick == 0 then
        ""
    else
        (toString tick) ++ " °C"


customLabel : Orientation -> Float -> Svg.Svg a
customLabel orientation tick =
    let
        length =
            if isOdd tick then
                7
            else
                10

        text =
            if orientation == X then
                formatTickX tick
            else
                formatTickY tick

        style =
            if orientation == X then
                "text-anchor: middle;"
            else
                "text-anchor: end;"

        displacement =
            if orientation == X then
                "0, 27"
            else
                "-10, 5"
    in
        Svg.text'
            [ Svg.Attributes.transform ("translate(" ++ displacement ++ ")")
            , Svg.Attributes.style (style ++ " stroke: #969696; font-size: 12px;")
            ]
            [ Svg.tspan [] [ Svg.text text ] ]


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( -10, 34 ), ( -9, 38 ), ( -8, 40 ), ( -7, 41 ), ( -6, 50 ), ( -5, 52 ), ( -4, 53 ), ( -3, 49 ), ( -2, 42 ), ( -1, 52 ), ( -0.5, 53 ), ( 0.5, 46 ), ( 1, 40 ), ( 2, 36 ), ( 3, 31 ), ( 4, 25 ), ( 5, 29 ), ( 6, 37 ), ( 7, 43 ), ( 8, 48 ), ( 9, 58 ), ( 10, 64 ) ]


main : Svg.Svg a
main =
    plot
        [ size ( 600, 250 ), padding ( 40, 60 ) ]
        [ verticalGrid [ gridTickList [ -30, 30, 70 ], gridStyle [ ( "stroke", "#e2e2e2" ) ] ]
        , area [ areaStyle [ ( "stroke", "#e6d7ce" ), ( "fill", "#feefe5" ) ] ] data1
        , line [ lineStyle [ ( "stroke", "#b6c9ef" ) ] ] data2
        , yAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ], stepSize 20, customViewLabel (customLabel Y) ]
        , xAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ], customViewTick customTick, customViewLabel (customLabel X) ]
        ]
