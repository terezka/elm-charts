module Plot.Bars exposing (..)

{-|
 Attributes for altering the view of your area serie.

    myAreaSerie : Plot.Element (Interaction YourMsg)
    myAreaSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
            , fill "red"
            , opacity 0.5
            , customAttrs
                [ Svg.Events.onClick <| Custom MyClickMsg
                , Svg.Events.onMouseOver <| Custom Glow
                ]
            ]
            areaDataPoints

# Definition
@docs Attribute

# Styling
@docs stroke, strokeWidth, opacity, fill, barsMaxWidth

# Other
@docs customAttrs

-}

import Svg
import Internal.Bars as Internal
import Internal.Types exposing (Style)


{-| -}
type alias Attribute a =
    Internal.Config a -> Internal.Config a


{-| Set the fill color.
-}
fill : String -> Attribute a
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> Attribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Add your own attributes.
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
