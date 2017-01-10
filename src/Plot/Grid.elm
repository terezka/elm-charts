module Plot.Grid exposing (..)

{-|
 Attributes for altering the view of your grid.

    myGrid : Plot.Element (Interaction YourMsg)
    myGrid =
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
@docs lines, classes

# Values
@docs values

# Others
@docs customAttrs

-}

import Svg
import Plot.Types exposing (Style)
import Internal.Grid as Internal exposing (Config, Values(..), defaultConfigX)
import Internal.Line as LineInternal
import Plot.Line as Line


{-| -}
type alias Attribute a =
    Config a -> Config a


{-| Specify a list of ticks where you want grid lines drawn.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.values [ 2, 4, 6 ] ]

 If values are not specified with this attribute, the grid will mirror the ticks.
-}
values : List Float -> Attribute a
values values config =
    { config | values = CustomValues values }


{-| Configure the view of the grid lines.
-}
lines : List (Line.Attribute msg) -> Attribute msg
lines attrs config =
    { config | linesConfig = List.foldr (<|) LineInternal.defaultConfig attrs }


{-| Adds classes to the grid container.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.classes [ "my-grid" ] ]
-}
classes : List String -> Attribute a
classes classes config =
    { config | classes = classes }


{-| Add your own attributes to your gridlines. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
