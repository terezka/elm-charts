module Plot.Grid exposing (Attribute, values, mirrorTicks, style, classes)

import Internal.Grid as Internal exposing (Config, Values(..), defaultConfigX)
import Plot.Types exposing (Style)


{-| The type representing an grid configuration.
-}
type alias Attribute =
    Config -> Config


{-| Adds grid lines where the ticks on the corresponding axis are.

    main =
        plot
            []
            [ vertical [ gridMirrorTicks ]
            , xAxis []
            ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridValues` attribute, then this attribute will have no effect.
-}
mirrorTicks : Attribute
mirrorTicks config =
    { config | values = MirrorTicks }


{-| Specify a list of ticks where you want grid lines drawn.

    plot [] [ vertical [ gridValues [ 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridMirrorTicks` attribute, then this attribute will have no effect.
-}
values : List Float -> Attribute
values values config =
    { config | values = CustomValues values }


{-| Specify styles for the gridlines.

    plot
        []
        [ vertical
            [ gridMirrorTicks
            , gridStyle myStyles
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
style : Style -> Attribute
style style config =
    { config | style = defaultConfigX.style ++ style }


{-| Specify classes for the grid.

    plot
        []
        [ vertical
            [ gridMirrorTicks
            , gridClasses [ "my-class" ]
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
classes : List String -> Attribute
classes classes config =
    { config | classes = classes }
