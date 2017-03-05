module Internal.Line exposing (..)

import Svg
import Svg.Attributes
import Plot.Types exposing (..)
import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Internal.Animation as Animation


type alias Config a =
    { style : Style
    , animated : Bool
    , animationInterval : Int
    , smoothing : Smoothing
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = [ ( "fill", "transparent" ), ( "stroke", "black" ) ]
    , animated = False
    , animationInterval = 2000
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view meta { animated, animationInterval, style, smoothing, customAttrs } points =
    let
        instructions =
            case points of
                p1 :: rest ->
                    M p1 :: (toLinePath smoothing (p1 :: rest)) |> toPath meta

                _ ->
                    ""

        attrs =
            (stdAttributes meta instructions style) ++ customAttrs

        totalHeight =
            meta.scale.y.length + meta.scale.y.offset.lower + meta.scale.y.offset.upper

        totalWidth =
            meta.scale.x.length + meta.scale.x.offset.lower + meta.scale.x.offset.upper

        animationId =
            "line-left-to-right-" ++ meta.id
    in
        if animated then
            Svg.g []
                [ Animation.leftToRight
                    { id = animationId
                    , height = totalHeight
                    , width = totalWidth
                    , interval = animationInterval
                    }
                , Svg.path (attrs ++ [ Svg.Attributes.clipPath ("url(#" ++ animationId ++ ")") ]) []
                ]
        else
            Svg.path attrs []


stdAttributes : Meta -> String -> Style -> List (Svg.Attribute a)
stdAttributes meta d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    , Svg.Attributes.clipPath ("url(#" ++ toClipPathId meta ++ ")")
    ]
