module Plot.Bars exposing (..)

{-|
 Attributes for altering the view of your bars serie.

    myBarsSerie : Plot.Element (Interaction YourMsg)
    myBarsSerie =
        pile
            []
            [ Pile.bars
                [ Bars.fill "pink"
                , Bars.opacity 0.5
                ]
                data
            ]


# Definition
@docs Attribute

# Styling
@docs opacity, fill

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


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
