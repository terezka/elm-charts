module Plot.Hint exposing (..)

import Internal.Hint as Internal
import Plot.Types exposing (HintInfo)
import Helpers exposing (..)
import Svg
import Svg.Attributes
import Html
import Html.Attributes


{-| The type representing a hint configuration.
-}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
removeLine : Attribute msg
removeLine config =
    { config | showLine = False }


{-| -}
viewCustom : (HintInfo -> Bool -> Html.Html msg) -> Attribute msg
viewCustom view config =
    { config | view = view }
