module Container exposing (..)

import Svg
import Svg.Attributes exposing (width, height)

view : List (Svg.Svg a) -> Svg.Svg a
view children =
    Svg.svg [ width "400", height "300" ] children
