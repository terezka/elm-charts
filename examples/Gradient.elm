module Gradient exposing (..)

import Svg
import Svg.Attributes as Attrs
import Plot exposing (..)
import Plot.Area as Area
import Plot.Axis as Axis


-- Example inspired by https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Gradients


data : List ( Float, Float )
data =
    [ ( 0, 10 ), ( 2, 12 ), ( 4, 27 ), ( 6, 25 ), ( 8, 46 ) ]


defs : (Point -> Point) -> Svg.Svg msg
defs _ =
    Svg.defs []
        [ Svg.linearGradient
            [ Attrs.id "Gradient" ]
            [ Svg.stop [ Attrs.offset "0%", Attrs.stopColor "red" ] []
            , Svg.stop [ Attrs.offset "50%", Attrs.stopColor "black", Attrs.stopOpacity "0.5" ] []
            , Svg.stop [ Attrs.offset "100%", Attrs.stopColor "blue" ] []
            ]
        ]


main : Svg.Svg a
main =
    plot
        [ size ( 600, 300 )
        , margin ( 10, 20, 40, 40 )
        ]
        [ custom defs
        , area
            [ Area.fill "url(#Gradient)"
            ]
            data
        , xAxis
            [ Axis.tickDelta 2
            ]
        ]
