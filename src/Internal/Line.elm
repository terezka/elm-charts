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
view meta { style, smoothing, customAttrs } points =
    let
        instructions =
            case points of
                p1 :: rest ->
                    M p1 :: (toLinePath smoothing (p1 :: rest)) |> toPath meta

                _ ->
                    ""

        attrs =
            (stdAttributes meta instructions style) ++ customAttrs
    in
        Svg.path attrs []


stdAttributes : Meta -> String -> Style -> List (Svg.Attribute a)
stdAttributes meta d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    , Svg.Attributes.clipPath ("url(#" ++ toClipPathId meta ++ ")")
    ]
