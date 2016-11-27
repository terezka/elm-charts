module Plot.Line exposing (..)

import Plot.Types exposing (Style)
import Internal.Line as Internal


{-| The type representing a line configuration.
-}
type alias Attribute =
    Internal.Config -> Internal.Config


{-| Add styles to your line serie.

    main =
        plot
            []
            [ line
                [ lineStyle [ ( "fill", "deeppink" ) ] ]
                lineDataPoints
            ]
-}
style : Style -> Attribute
style style config =
    { config | style = ( "fill", "transparent" ) :: style }
