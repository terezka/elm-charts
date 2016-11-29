module Plot.Hint exposing (..)

{-|
 Attributes for altering the view of your hint.

# Definition
@docs Attribute

# Styling
@docs viewCustom, HintInfo, IsLeftSide, lineStyle

-}

import Internal.Hint as Internal
import Internal.Types exposing (Style)
import Html exposing (Html)


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| The available info provided to your hint view.
-}
type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe Float)
    }


{-| -}
type alias IsLeftSide =
    Bool


{-| Add styles to the line indicating the hovered value.
-}
lineStyle : Style -> Attribute msg
lineStyle style config =
    { config | lineStyle = style }


{-| Uses your own view to display the hint box.
-}
viewCustom : (HintInfo -> IsLeftSide -> Html msg) -> Attribute msg
viewCustom view config =
    { config | view = view }
