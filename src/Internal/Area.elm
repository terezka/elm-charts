module Internal.Area exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Plot.Types exposing (..)
import Internal.Stuff exposing (getEdgesX)
import Internal.Draw exposing (PathType(..), toPath, toLinePath, toStyle, toClipPathId)
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
    { style = []
    , animated = False
    , animationInterval = 2000
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view meta { animated, animationInterval, style, smoothing, customAttrs } points =
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

        totalHeight =
            meta.scale.y.length + meta.scale.y.offset.lower + meta.scale.y.offset.upper

        totalWidth =
            meta.scale.x.length + meta.scale.x.offset.lower + meta.scale.x.offset.upper

        animationId =
            "area-left-to-right-" ++ meta.id
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
    [ Svg.Attributes.d (d ++ "Z")
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--area"
    , Svg.Attributes.clipPath ("url(#" ++ toClipPathId meta ++ ")")
    ]
