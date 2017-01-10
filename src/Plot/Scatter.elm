module Plot.Scatter exposing (..)

{-|
 Attributes for altering the view of your scatter serie.

    myScatterSerie : Plot.Element (Interaction YourMsg)
    myScatterSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
            , fill "purple"
            , opacity 0.5
            , radius 10
            , customAttrs
                [ Svg.Events.onClick <| Custom MyClickMsg
                , Svg.Events.onMouseOver <| Custom Glow
                ]
            ]
            scatterDataPoints

# Definition
@docs Attribute

# Styling
@docs stroke, strokeWidth, fill, opacity, radius

# Other
@docs customAttrs

-}

import Svg
import Internal.Scatter as Internal
import Plot.Types exposing (Style)


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


{-| Set the radius of your points.
-}
radius : Int -> Attribute a
radius radius config =
    { config | radius = radius }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
