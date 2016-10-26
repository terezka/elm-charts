module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (plot, dimensions, area, line, xAxis, yAxis, amountOfTicks, tickList, customViewTick, customViewLabel, stroke, fill)


myCustomXTick : Float -> Svg.Svg a
myCustomXTick tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(0, 8)"
        , Svg.Attributes.style "text-anchor: middle;" ]
        [ Svg.tspan [] [ Svg.text "✨" ] ]


myCustomLabel : Float -> Svg.Svg a
myCustomLabel tick =
    let
        label =
            if tick == 0 then
                ""
            else
                (toString (round tick)) ++ " ms"
    in
        Svg.text'
            [ Svg.Attributes.transform "translate(0, 4)"
            , Svg.Attributes.style "stroke: purple; text-anchor: end;"
            ]
            [ Svg.tspan [] [ Svg.text label ] ]


areaData =
    [ ( -50, 34 ), ( -30, 432 ), ( -20, 35 ), ( 2, 546 ), ( 10, 345 ), ( 30, -42 ), ( 90, 67 ), ( 120, 50 ) ]


lineData =
    [ ( -50, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -99 ), ( 30, -136 ), ( 90, -67 ), ( 120, 10 ) ]


main =
    plot
        [ dimensions ( 800, 500 ) ]
        [ area [ stroke "cornflowerblue", fill "#ccdeff" ] areaData
        , line [ stroke "mediumvioletred" ] lineData
        , xAxis
            [ customViewTick myCustomXTick
            , tickList [ -20, 20, 40, 82 ]
            ]
        , yAxis
            [ customViewLabel myCustomLabel
            , amountOfTicks 5
            ]
        ]
