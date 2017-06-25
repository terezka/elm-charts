module Hint exposing (Hint, View(..))

import Html exposing (Html)
import Svg.Coordinates exposing (Point)

{-| -}
type View
    = Aligned (List Point -> Html Never)
    | Single (Point -> Html Never)


{-| -}
type alias Hint msg =
  { proximity : Maybe Float
  , view : View
  , msg : Maybe Point -> msg
  , model : Maybe Point
  }
