module Plot.Line exposing (..)

{-|
 Attributes for altering the view of your line serie.

    myLineSerie : Plot.Element (Interaction YourMsg)
    myLineSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
            , opacity 0.5
            , customAttrs
                [ Svg.Events.onClick <| Custom MyClickMsg ]
            ]
            lineDataPoints


# Definition
@docs Attribute

# Styling
@docs stroke, strokeWidth, opacity

# Other
@docs customAttrs

-}

import Svg
import Internal.Types exposing (Style)
import Internal.Line as Internal
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


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
