module Plot.Hint exposing (..)

{-|
 Attributes for altering the view of your hint.

# Definition
@docs Attribute

# Styling
@docs viewCustom, HintInfo, IsLeftSide, removeLine

-}
import Internal.Hint as Internal
import Html exposing (Html)


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| The available info provided to your hint view. -}
type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe Float)
    }


{-| -}
type alias IsLeftSide =
    Bool


{-| Removes the line indication of the hovered value. -}
removeLine : Attribute msg
removeLine config =
    { config | showLine = False }


{-| Uses your own view to display the hint box. -}
viewCustom : (HintInfo -> IsLeftSide -> Html msg) -> Attribute msg
viewCustom view config =
    { config | view = view }
