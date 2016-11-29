module Internal.Area exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Stuff exposing (getEdgesX)
import Internal.Draw exposing (..)


type alias Config a =
    { style : Style
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = []
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view { toSvgCoords } { style, customAttrs } points =
    let
        ( lowestX, highestX ) =
            getEdgesX points

        svgCoords =
            List.map toSvgCoords points

        ( highestSvgX, originY ) =
            toSvgCoords ( highestX, 0 )

        ( lowestSvgX, _ ) =
            toSvgCoords ( lowestX, 0 )

        startInstruction =
            toInstruction "M" [ lowestSvgX, originY ]

        endInstructions =
            toInstruction "L" [ highestSvgX, originY ]

        instructions =
            coordsToInstruction "L" svgCoords

        attrs =
            (stdAttributes (startInstruction ++ instructions ++ endInstructions) style) ++ customAttrs
    in
        Svg.path attrs []


stdAttributes : String -> Style -> List (Svg.Attribute a)
stdAttributes d style =
    [ Svg.Attributes.d (d ++ "Z")
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--area"
    ]
