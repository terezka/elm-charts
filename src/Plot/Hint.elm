module Plot.Hint exposing (..)

{-|
 Attributes for altering the view of your hint.

 Notice that this element will only be rendered when using `plotInteractive`!

 P.S. You also have to add [elm-plot.css](https://github.com/terezka/elm-plot/tree/master/src/elm-plot.css)
 for it to look nice.

# Definition
@docs Attribute, HintInfo, IsLeftSide

# Styling
@docs viewCustom, lineStyle

-}

import Internal.Hint as Internal
import Internal.Types exposing (Value, Style)
import Html exposing (Html)


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| The available info provided to your hint view.
-}
type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe (List Value))
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
