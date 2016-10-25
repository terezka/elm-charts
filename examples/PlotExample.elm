module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (plot, dimensions, area, line, xAxis, yAxis, amountOfTicks, customViewTick, customViewLabel, stroke, fill)


myCustomXTick : Plot.Point -> Float -> Svg.Svg a
myCustomXTick ( x, y ) tick =
    Svg.g []
        [ Svg.line
            [ Svg.Attributes.style "stroke: red;"
            , Svg.Attributes.x1 (toString x)
            , Svg.Attributes.y1 (toString y)
            , Svg.Attributes.x2 (toString x)
            , Svg.Attributes.y2 (toString (y + 7))
            ]
            []
        ]


myCustomLabel : Plot.Point -> Float -> Svg.Svg a
myCustomLabel ( x, y ) tick =
    let
        label =
            if tick == 0
            then ""
            else (toString (round tick)) ++ " ms"
    in
        Svg.text'
            [ Svg.Attributes.transform "translate(0, 4)"
            , Svg.Attributes.x (toString x) -- Maybe just allow special style and child for label?
            , Svg.Attributes.y (toString y) -- Then we don't have to add x y attrs everytime
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
        , xAxis [ customViewTick myCustomXTick ]
        , yAxis [ customViewLabel myCustomLabel, amountOfTicks 5 ]
        ]
