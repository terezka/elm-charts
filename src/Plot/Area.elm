module Plot.Area exposing (..)

{-|
 Attributes for altering the view of your area serie.

# Definition
@docs Attribute

# Styling
@docs style


-}

import Internal.Area as Internal
import Internal.Types exposing (Style)


{-| -}
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
