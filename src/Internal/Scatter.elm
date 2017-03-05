module Internal.Scatter exposing (..)

import Svg
import Svg.Attributes
import Plot.Types exposing (..)
import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Internal.Animation as Animation


type alias Config a =
    { animated : Bool
    , animationInterval : Int
    , style : Style
    , customAttrs : List (Svg.Attribute a)
    , radius : Int
    }


defaultConfig : Config a
defaultConfig =
    { animated = False
    , animationInterval = 2000
    , style = [ ( "fill", "transparent" ) ]
    , customAttrs = []
    , radius = 5
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view meta { animated, animationInterval, style, radius } points =
    let
        svgPoints =
            List.map meta.toSvgCoords points

        totalHeight =
            meta.scale.y.length + meta.scale.y.offset.lower + meta.scale.y.offset.upper

        totalWidth =
            meta.scale.x.length + meta.scale.x.offset.lower + meta.scale.x.offset.upper

        animationId =
            "scatter-radius-growth-" ++ meta.id
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style) ]
            (List.map (toSvgCircle radius animated animationId animationInterval) svgPoints)


toSvgCircle : Int -> Bool -> String -> Int -> Point -> Svg.Svg a
toSvgCircle radius animated animationId interval ( x, y ) =
    Svg.circle
        [ Svg.Attributes.cx (toString x)
        , Svg.Attributes.cy (toString y)
        , Svg.Attributes.r (toString radius)
        ]
        (if animated then
            [ Animation.radiusGrowth { id = animationId, radius = radius, interval = interval } ]
         else
            []
        )
