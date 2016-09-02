module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, x1, x2, y1, y2)
import String

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
