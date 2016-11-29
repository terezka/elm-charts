module Plot.Area exposing (..)

{-|
 Attributes for altering the view of your area serie.

    myAreaSerie : Plot.Element (Interaction YourMsg)
    myAreaSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
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
@docs stroke, strokeWidth, opacity, fill

# Other
@docs customAttrs

-}

import Svg
import Internal.Area as Internal
import Internal.Types exposing (Style)


{-| -}
type alias Attribute a =
    Internal.Config a -> Internal.Config a


{-| Set the stroke color. -}
stroke : String -> Attribute a
stroke stroke config =
    { config | style = ( "stroke", stroke ) :: config.style }


{-| Set the stroke width (in pixels). -}
strokeWidth : Int -> Attribute a
strokeWidth strokeWidth config =
    { config | style = ( "stroke-width", toString strokeWidth ++ "px" ) :: config.style }


{-| Set the fill color. -}
fill : String -> Attribute a
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity. -}
opacity : Float -> Attribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Add your own attributes. -}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }

