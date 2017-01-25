module Internal.Area exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Plot.Types exposing (..)
import Internal.Stuff exposing (getEdgesX)
import Internal.Draw exposing (PathType(..), toPath, toLinePath, toStyle, toClipPathId)


type alias Config a =
    { style : Style
    , smoothing : SmoothingOption
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = []
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view meta { style, smoothing, customAttrs } points =
    let
        ( lowestX, highestX ) =
            getEdgesX points

        lowestY =
            clamp meta.scale.y.lowest meta.scale.y.highest 0

        instructions =
            List.concat
                [ [ M ( lowestX, lowestY ) ]
                , (toLinePath smoothing points)
                , [ L ( highestX, lowestY ) ]
                ]
                |> toPath meta

        attrs =
            (stdAttributes meta instructions style) ++ customAttrs
    in
        Svg.path attrs []


stdAttributes : Meta -> String -> Style -> List (Svg.Attribute a)
stdAttributes meta d style =
    [ Svg.Attributes.d (d ++ "Z")
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--area"
    , Svg.Attributes.clipPath ("url(#" ++ toClipPathId meta ++ ")")
    ]
