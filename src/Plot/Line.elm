module Plot.Line exposing (..)

{-|
 Attributes for altering the view of your line serie.

# Definition
@docs Attribute

# Styling
@docs style

-}

import Internal.Types exposing (Style)
import Internal.Line as Internal


{-| -}
type alias Attribute =
    Internal.Config -> Internal.Config


{-| Add styles to your line serie.

    main =
        plot
            []
            [ line
                [ lineStyle [ ( "stroke", "deeppink" ) ] ]
                lineDataPoints
            ]
-}
style : Style -> Attribute
style style config =
    { config | style = ( "fill", "transparent" ) :: style }
