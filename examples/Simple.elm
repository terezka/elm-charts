module Simple exposing (..)

import Plot exposing (..)
import Svg
import Svg.Attributes


lineData : List ( Float, Float )
lineData =
    [ ( -52, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -20 ), ( 30, 10 ), ( 40, 136 ), ( 90, 167 ), ( 125, 120 ) ]


lineData2 =
    [ ( -1, 2 ), ( 0, 3 ), ( 4, 5 ), ( 5, 3 ) ]


plot1 =
    plot
        []
        [ xAxis [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , yAxis [ gridValues [ -60, -30, 30, 60, 90, 120, 150, 180 ], gridStyle [ ( "stroke", "#ddd" ) ] ]
        , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
        ]


plot2 =
    plot
        []
        [ xAxis
            [ gridMirrorTicks
            , gridStyle [ ( "stroke", "#ddd" ) ]
            , tickRemoveZero
            , axisStyle [ ( "stroke", "purple" ) ]
            ]
        , yAxis
            [ gridStyle [ ( "stroke", "#ddd" ) ]
            , tickRemoveZero
            ]
        , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
        ]


plot3 =
    plot [ padding ( 0, 0 ) ]
        [ xAxis [  ]
        , yAxis [ tickRemoveZero ]
        , area [ areaStyle [ ( "fill", "mediumvioletred" ), ( "opacity", "0.5" ), ( "stroke", "mediumvioletred" ) ] ] lineData2
        ]


axisStyleAttr : AxisAttr msg
axisStyleAttr =
    tickViewConfig
        { length = 5
        , width = 2
        , style = [ ( "stroke", "red" ) ]
        }


tickView : Float -> Svg.Svg a
tickView tick =
    Svg.text'
        [ Svg.Attributes.transform ("translate(-5, 10)") ]
        [ Svg.tspan
            []
            [ Svg.text "✨" ]
        ]

viewTick2 : Int -> Float -> Svg.Svg a
viewTick2 fromZero tick =
    Svg.text'
        [ Svg.Attributes.transform ("translate(-5, 10)") ]
        [ Svg.tspan
            []
            [ Svg.text (if rem (abs fromZero) 2 > 0 then "🌟" else "⭐") ]
        ]

main =
    plot [] [ xAxis [ tickCustomViewIndexed viewTick2 ] ]

