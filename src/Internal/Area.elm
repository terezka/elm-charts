module Internal.Area exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Stuff exposing (getEdgesX)
import Internal.Draw exposing (..)


type alias Config a =
    { style : Style
    , smoothing : Smoothing
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = []
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view { toSvgCoords, scale } { style, smoothing, customAttrs } points =
    let
        ( lowestX, highestX ) =
            getEdgesX points

        svgCoords =
            List.map toSvgCoords points

        areaEnd =
            clamp scale.y.lowest scale.y.highest 0

        ( highestSvgX, originY ) =
            toSvgCoords ( highestX, areaEnd )

        ( lowestSvgX, _ ) =
            toSvgCoords ( lowestX, areaEnd )

        startInstruction =
            toInstruction "M" [ lowestSvgX, originY ]

        endInstructions =
            toInstruction "L" [ highestSvgX, originY ]

        instructions =
            toLineInstructions smoothing svgCoords

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
