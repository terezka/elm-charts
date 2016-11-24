module Test exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Label as Label
import Plot.Tick as Tick
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
        [ Tick.length 7, Tick.style [ ( "stroke", "#e4e3e3" ) ] ]
    else
        [ Tick.length 10, Tick.style [ ( "stroke", "#b9b9b9" ) ] ]


toLabelConfig : Int -> Float -> List Label.StyleAttribute
toLabelConfig index tick =
    if isOdd index then
        [ Label.format (\_ _ -> "") ]
    else
        [ Label.format (\i l -> toString l ++ " s")
        , Label.style [ ( "stroke", "#969696" ) ]
        , Label.displace ( 0, 27 )
        ]


specialTick : Int -> Float -> Svg.Svg a
specialTick _ _ =
    Svg.text_
        [ Svg.Attributes.transform "translate(5, 5)"
        , Svg.Attributes.style "stroke: #969696; font-size: 12px; text-anchor: end;"
        ]
        [ Svg.tspan [] [ Svg.text "🌟" ] ]


chart : Plot.State -> Svg.Svg Msg
chart model =
    plotStatic
        [ Meta.size ( 600, 250 )
        , Meta.margin ( 0, 40, 40, 40 )
        ]
        [ line
            [ Line.style [ ( "stroke", Colors.pinkStroke ), ( "stroke-width", "2px" ) ] ]
            data
        , xAxis
            [ Axis.style [ ( "stroke", Colors.axisColor ) ]
            , Axis.tick [ Tick.viewDynamic toTickConfig ]
            , Axis.label [ Label.viewDynamic toLabelConfig ]
            ]
        , yAxis
            [ Axis.style [ ( "stroke", Colors.axisColor ) ]
            , Axis.tick
                [ Tick.viewCustom specialTick
                , Tick.removeZero
                ]
            ]
        ]
