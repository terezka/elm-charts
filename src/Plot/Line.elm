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
    { config | style = ( "stroke-width", toString strokeWidth ++ "px" ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> Attribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Add your own attributes. For events, read _insert link, please tell me if I forget_
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
