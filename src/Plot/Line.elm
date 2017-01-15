module Plot.Line exposing (..)

{-|
 Attributes for altering the view of your line serie.

    myLineSerie : Plot.Element (Interaction YourMsg)
    myLineSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
            , opacity 0.5
            , smoothing Cosmetic
            , customAttrs
                [ Svg.Events.onClick <| Custom MyClickMsg ]
            ]
            lineDataPoints


# Definition
@docs Attribute

# Styling
@docs stroke, strokeWidth, opacity, smoothingBezier

# Other
@docs customAttrs

-}

import Svg
import Internal.Line as Internal
import Internal.Types exposing (Smoothing(..))
import Internal.Draw exposing (..)


{-| -}
type alias Attribute a =
    Internal.Config a -> Internal.Config a


{-| Set the stroke color.
-}
stroke : String -> Attribute a
stroke stroke config =
    { config | style = ( "stroke", stroke ) :: config.style }


{-| Set the stroke width (in pixels).
-}
strokeWidth : Int -> Attribute a
strokeWidth strokeWidth config =
    { config | style = ( "stroke-width", toPixelsInt strokeWidth ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> Attribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Smooth line with [Bézier curves] (https://en.wikipedia.org/wiki/B%C3%A9zier_curve).
-}
smoothingBezier : Attribute a
smoothingBezier config =
    { config | smoothing = Bezier }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
