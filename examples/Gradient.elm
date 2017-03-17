module Gradient exposing (..)

import Svg
import Svg.Attributes as Attrs
import Plot exposing (..)



data : List ( Float, Float )
data =
    [ ( 0, 10 ), ( 2, 12 ), ( 4, 27 ), ( 6, 25 ), ( 8, 46 ) ]


defs : List (Svg.Svg msg)
defs =
    [ Svg.linearGradient
        [ Attrs.id "Gradient" ]
        [ Svg.stop [ Attrs.offset "0%", Attrs.stopColor "rgba(253, 185, 231, 0.5)" ] []
        , Svg.stop [ Attrs.offset "50%", Attrs.stopColor "#e4eeff", Attrs.stopOpacity "0.5" ] []
        , Svg.stop [ Attrs.offset "100%", Attrs.stopColor "#cfd8ea" ] []
        ]
    ]


customArea : Series (List ( Float, Float )) msg
customArea =
  { axis = normalAxis
  , interpolation = Monotone (Just "url(#Gradient)") [ Attrs.stroke "transparent" ]
  , toDataPoints = List.map (\( x, y ) -> clear x y)
  }


main : Svg.Svg a
main =
    viewSeriesCustom
      { defaultSeriesPlotCustomizations | defs = defs }
      [ customArea ]
      data
