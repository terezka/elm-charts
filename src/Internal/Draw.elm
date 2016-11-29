module Internal.Draw exposing (..)

import Svg exposing (Svg, Attribute)
import Svg.Attributes
import Plot.Types exposing (Meta, Orientation)
import Helpers exposing (..)


fullLine : List (Attribute a) -> Meta -> Float -> Svg a
fullLine attributes { toSvgCoords, scale } value =
    let
        { lowest, highest } =
            scale

        begin =
            toSvgCoords ( lowest, value )

        end =
            toSvgCoords ( highest, value )
    in
        Svg.line (positionAttributes begin end ++ attributes) []


positionAttributes : (Float, Float) -> (Float, Float) -> List (Attribute a)
positionAttributes (x1, y1) (x2, y2) =
    [ Svg.Attributes.x1 (toString x1)
    , Svg.Attributes.y1 (toString y1)
    , Svg.Attributes.x2 (toString x2)
    , Svg.Attributes.y2 (toString y2)
    ]


classAttribute : String -> List String -> Attribute a
classAttribute base classes =
    (classBase base) :: classes
    |> String.join " "
    |> Svg.Attributes.class


classAttributeOriented : String -> Orientation -> List String -> Attribute a
classAttributeOriented base orientation classes =
    ((?) orientation (classBase base ++ "--x") (classBase base ++ "--y")) :: classes
    |> classAttribute base


classBase : String -> String
classBase base =
    "elm-plot__" ++ base
    