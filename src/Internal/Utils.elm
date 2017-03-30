module Internal.Utils exposing (..)

import Svg exposing (Svg, text)


{-| -}
viewMaybe : Maybe a -> (a -> Svg msg) -> Svg msg
viewMaybe a view =
  Maybe.withDefault (text "") (Maybe.map view a)
