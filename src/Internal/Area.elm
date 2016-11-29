module Internal.Area exposing (..)

import Plot.Types exposing (..)
import Helpers exposing (..)
import Svg
import Svg.Attributes


type alias Config =
    { style : Style }


defaultConfig : Config
defaultConfig =
    { style = [] }


view : Meta -> Config -> List Point -> Svg.Svg a
view { toSvgCoords } { style } points =
    let
        range =
            List.map Tuple.first points

        ( lowestX, highestX ) =
            ( getLowest range, getHighest range )

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
            coordToInstruction "L" svgCoords
    in
        Svg.path
            [ Svg.Attributes.d (startInstruction ++ instructions ++ endInstructions ++ "Z")
            , Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class "elm-plot__serie--area"
            ]
            []
