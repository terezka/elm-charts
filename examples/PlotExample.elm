module PlotExample exposing (..)

import Svg
import Svg.Attributes
import Plot exposing (..)


myCustomXTick : Float -> Svg.Svg a
myCustomXTick tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(0, 8)"
        , Svg.Attributes.style "text-anchor: middle;" ]
        [ Svg.tspan [] [ Svg.text "✨" ] ]


myCustomLabel : Float -> Svg.Svg a
myCustomLabel tick =
    Svg.text'
        [ Svg.Attributes.transform "translate(0, 4)"
        , Svg.Attributes.style "stroke: purple; text-anchor: end;"
        ]
        [ Svg.tspan [] [ Svg.text ((toString (round tick)) ++ " ms") ] ]


areaData =
    [ ( -50, 34 ), ( -30, 432 ), ( -20, 35 ), ( 2, 546 ), ( 10, 345 ), ( 30, -42 ), ( 90, 67 ), ( 120, 50 ) ]


lineData =
    [ ( -50, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -99 ), ( 30, -136 ), ( 90, -67 ), ( 120, 10 ) ]


main =
    plot
        [ dimensions ( 800, 500 ) ]
        [ horizontalGrid [ gridTicks (Just [ -40, -20, 20, 40, 60, 80, 100 ]), gridStyle [ ("stroke", "chartreuse")] ]
        , area [ stroke "cornflowerblue", fill "#ccdeff" ] areaData
        , line [ stroke "mediumvioletred" ] lineData
        , xAxis
            [ customViewTick myCustomXTick
            , axisLineStyle [ ( "stroke", "red" ) ]
            , tickList [ -20, 20, 40, 82 ]
            ]
        , yAxis
            [ customViewLabel myCustomLabel
            , amountOfTicks 5
            ]
        ]
