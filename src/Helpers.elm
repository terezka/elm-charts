module Helpers exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (transform, height, width, style, d, x, y, x1, x2, y1, y2)
import String


getHighest : List Float -> Float
getHighest values =
    Maybe.withDefault 1 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
    min 0 (Maybe.withDefault 0 (List.minimum values))


coordToInstruction : String -> List ( Float, Float ) -> String
coordToInstruction instructionType coords =
    List.map (\( x, y ) -> toInstruction instructionType [ x, y ]) coords |> String.join ""


toInstruction : String -> List Float -> String
toInstruction instructionType coords =
    let
        coordsString =
            List.map toString coords
                |> String.join ","
    in
        instructionType ++ " " ++ coordsString


startPath : List ( Float, Float ) -> ( String, List ( Float, Float ) )
startPath data =
    let
        ( x, y ) =
            Maybe.withDefault ( 0, 0 ) (List.head data)

        tail =
            Maybe.withDefault [] (List.tail data)
    in
        ( toInstruction "M" [ x, y ], tail )
