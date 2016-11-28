module Plot.Grid exposing (Attribute, values, style, classes)

{-|
 Attributes for altering the view of your grid.

# Definition
@docs Attribute

# Styling
@docs style, classes

# Values
@docs values

-}

import Internal.Grid as Internal exposing (Config, Values(..), defaultConfigX)
import Plot.Types exposing (Style)


{-| -}
type alias Attribute =
    Config -> Config


{-| Specify a list of ticks where you want grid lines drawn.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.values [ 2, 4, 6 ] ]

 If values are not specified with this attribute, the grid will mirror the ticks.
-}
values : List Float -> Attribute
values values config =
    { config | values = CustomValues values }


{-| Adds styles to the gridlines.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.style myStyles ]

-}
style : Style -> Attribute
style style config =
    { config | style = defaultConfigX.style ++ style }


{-| Adds classes to the grid.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.classes [ "my-grid" ] ]
-}
classes : List String -> Attribute
classes classes config =
    { config | classes = classes }
