module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (transform, height, width, style, x, y, x1, x2, y1, y2)
import String

modulus : Float -> Float -> Float
modulus divider value =
  value - (toFloat (round (value / divider)))


byPrecision : Float -> (Float -> Int) -> Float -> Float
byPrecision precision operation value =
  toFloat (operation (value / precision)) * precision


getHighest : List Float -> Float
getHighest values =
  Maybe.withDefault 1 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
  min 0 (Maybe.withDefault 0 (List.minimum values))


viewSvgContainer : Float -> Float -> List (Svg.Svg a) -> Svg.Svg a
viewSvgContainer x y children =
  Svg.g [ transform (toTranslate x y)] children


viewSvgLine : (Float, Float, Float, Float) -> Svg.Svg a
viewSvgLine (x1', y1', x2', y2') =
  Svg.line
    [ x1 (toString x1')
    , y1 (toString y1')
    , x2 (toString x2')
    , y2 (toString y2')
    , style "stroke: #757575;"
    ]
    []


viewSvgText : (Float, Float, Float, Float) -> String -> Svg.Svg a
viewSvgText (x1', y1', x2', y2') label =
  viewSvgContainer  x2' y2'
    [ Svg.text'
      [ x (toString 0)
      , y (toString 10)
      , style "stroke: #757575;"
      ]
      [ Svg.tspan [] [ Svg.text label ] ]
    ]


toTranslate : Float -> Float -> String
toTranslate x y =
   "translate(" ++ (toString x) ++ ", " ++ (toString y) ++ ")"


toInstruction : String -> List String -> String
toInstruction instructionType coords =
  let
    coordsString =
      String.join "," coords
  in
    instructionType ++ " " ++ coordsString


startPath : List (String, String) -> (String, List (String, String))
startPath data =
  let
    (x, y) = Maybe.withDefault ("0","0") (List.head data)
    tail = Maybe.withDefault [] (List.tail data)
  in
    (toInstruction "M" [x, y], tail)
