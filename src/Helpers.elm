module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, x1, x2, y1, y2)
import String

getHighest : List Float -> Float
getHighest values =
  Maybe.withDefault 1 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
  min 0 (Maybe.withDefault 0 (List.minimum values))


viewSvgLine : (Float, Float, Float, Float) -> Svg.Svg a
viewSvgLine (x1', y1', x2', y2') =
  Svg.line
    [ x1 (toString x1')
    , y1 (toString y1')
    , x2 (toString x2')
    , y2 (toString y2')
    , style "stroke:red;"
    ]
    []


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
