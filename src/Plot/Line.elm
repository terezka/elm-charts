module Plot.Line exposing (..)

import Plot.Types exposing (..)
import Helpers exposing (..)
import Svg
import Svg.Attributes



--## Line configuration
--@docs LineAttr, lineStyle


type alias Config =
    { style : Style }


{-| The type representing a line configuration.
-}
type alias Attribute =
    Config -> Config


{-| Add styles to your line serie.

    main =
        plot
            []
            [ line
                [ lineStyle [ ( "fill", "deeppink" ) ] ]
                lineDataPoints
            ]
-}
style : Style -> Attribute
style style config =
    { config | style = ( "fill", "transparent" ) :: style }


toConfig : List Attribute -> Config
toConfig attrs =
    List.foldr (<|) defaultConfig attrs


defaultConfig : Config
defaultConfig =
    { style = [] }


view : PlotProps -> Config -> List Point -> Svg.Svg a
view { toSvgCoords } { style } points =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, tail ) =
            startPath svgPoints

        instructions =
            coordToInstruction "L" svgPoints
    in
        Svg.path
            [ Svg.Attributes.d (startInstruction ++ instructions)
            , Svg.Attributes.style (toStyle style)
            ]
            []