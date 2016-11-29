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
@docs stroke, strokeWidth, opacity

# Values
@docs values

# Others
@docs classes, customAttrs

-}

import Svg
import Internal.Grid as Internal exposing (Config, Values(..), defaultConfigX)
import Internal.Types exposing (Style)


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


{-| Set the stroke color. -}
stroke : String -> Attribute a
stroke stroke config =
    { config | style = ( "stroke", stroke ) :: config.style }


{-| Set the stroke width (in pixels). -}
strokeWidth : Int -> Attribute a
strokeWidth strokeWidth config =
    { config | style = ( "stroke-width", toString strokeWidth ++ "px" ) :: config.style }


{-| Set the opacity. -}
opacity : Float -> Attribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Adds classes to the grid container.

    myGrid : Plot.Element msg
    myGrid =
        verticalGrid [ Grid.classes [ "my-grid" ] ]
-}
classes : List String -> Attribute a
classes classes config =
    { config | classes = classes }


{-| Add your own attributes to your gridlines. For events, read _insert link, please tell me if I forget_ -}
customAttrs : List (Svg.Attribute a) -> Attribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
