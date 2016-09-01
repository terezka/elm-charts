module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, x1, x2, y1, y2)


viewSvgLine : String -> String -> String -> String -> Svg.Svg a
viewSvgLine x1' y1' x2' y2' =
  Svg.line
    [ x1 x1'
    , y1 y1'
    , x2 x2'
    , y2 y2'
    , style "stroke:red;"
    ]
    []
