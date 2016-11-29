module Internal.Line exposing (..)

import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Svg
import Svg.Attributes


type alias Config =
    { style : Style }


defaultConfig : Config
defaultConfig =
    { style = [ ( "fill", "transparent" ) ] }


view : Meta -> Config -> List Point -> Svg.Svg a
view { toSvgCoords } { style } points =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, tail ) =
            startPath svgPoints

        instructions =
            coordsToInstruction "L" svgPoints
    in
        Svg.path
            [ Svg.Attributes.d (startInstruction ++ instructions)
            , Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class "elm-plot__serie--line"
            ]
            []
