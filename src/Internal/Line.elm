module Internal.Line exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Draw exposing (..)


type alias Config a =
    { style : Style
    , smoothing : Smoothing
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = [ ( "fill", "transparent" ), ( "stroke", "black" ) ]
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view { toSvgCoords } { style, smoothing, customAttrs } points =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, _ ) =
            startPath svgPoints

        instructions =
            toLineInstructions smoothing svgPoints

        attrs =
            (stdAttributes (startInstruction ++ instructions) style) ++ customAttrs
    in
        Svg.path attrs []


stdAttributes : String -> Style -> List (Svg.Attribute a)
stdAttributes d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    ]
