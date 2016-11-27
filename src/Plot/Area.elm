module Plot.Area exposing (..)

import Internal.Area as Internal
import Plot.Types exposing (Style)


{-| The type representing an area attribute.
-}
type alias Attribute =
    Internal.Config -> Internal.Config


{-| Add styles to your area serie.

    main =
        plot
            []
            [ area
                [ areaStyle
                    [ ( "fill", "deeppink" )
                    , ( "stroke", "deeppink" )
                    , ( "opacity", "0.5" ) ]
                    ]
                ]
                areaDataPoints
            ]
-}
style : Style -> Attribute
style style config =
    { config | style = style }
