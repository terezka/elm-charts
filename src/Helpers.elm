module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, x1, x2, y1, y2)


viewLine : Float -> Float -> Float -> Float -> Svg.Svg a
viewLine x1' y1' x2' y2' =
  Svg.line
    [ x1 (toString x1')
    , y1 (toString y1')
    , x2 (toString x2')
    , y2 (toString y2')
    , style "stroke:red;"
    ]
    []
