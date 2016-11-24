module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Area as Area
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Meta as Meta
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickConfig : Int -> Float -> List Tick.StyleAttribute
toTickConfig index tick =
    if isOdd index then
        [ tickLength 7, tickStyle [ ( "stroke", "#e4e3e3" ) ] ]
    else
        [ tickLength 10, tickStyle [ ( "stroke", "#b9b9b9" ) ] ]


toLabelConfig : Int -> Float -> List Label.StyleAttribute
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
        [ Meta.size ( 600, 250 ), Meta.style [ ( "padding", "40px" ) ] ]
        [ line
            [ Line.style
                [ ( "stroke", Colors.pinkStroke )
                , ( "stroke-width", "2px" )
                ]
            ]
            data
        , xAxis
            [ Axis.style [ ( "stroke", Colors.axisColor ) ]
            , Axis.tick
                [ Tick.values [ 0, 2, 5 ]
                , Tick.viewFromDynamicConfig toTickConfig
                ]
            , Axis.label
                [ Label.viewFromDynamicConfig toLabelConfig ]
            ]
        , yAxis
            [ Axis.style [ ( "stroke", Colors.axisColor ) ]
            , Axis.tick
                [ Tick.viewFromCustomHtml specialTick
                , Tick.removeZero
                ]
            ]
        ]
