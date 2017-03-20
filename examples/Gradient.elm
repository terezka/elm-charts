module Gradient exposing (..)

import Svg exposing (Svg, linearGradient, stop)
import Svg.Attributes exposing (id, stroke, offset, stopColor, stopOpacity)
import Plot exposing (..)



data : List ( Float, Float )
data =
  [ ( 0, 10 ), ( 2, 12 ), ( 4, 27 ), ( 6, 25 ), ( 8, 46 ) ]


defs : List (Svg msg)
defs =
  [ linearGradient
    [ id "Gradient" ]
    [ stop [ offset "0%", stopColor "rgba(253, 185, 231, 0.5)" ] []
    , stop [ offset "50%", stopColor "#e4eeff", stopOpacity "0.5" ] []
    , stop [ offset "100%", stopColor "#cfd8ea" ] []
    ]
  ]


customArea : Series (List ( Float, Float )) msg
customArea =
  { axis = normalAxis
  , interpolation = Monotone (Just "url(#Gradient)") [ stroke "transparent" ]
  , toDataPoints = List.map (\( x, y ) -> clear x y)
  }


main : Svg.Svg a
main =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations | defs = defs }
    [ customArea ]
    data
