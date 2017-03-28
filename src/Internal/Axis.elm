module Internal.Axis exposing (..)

import Svg exposing (Svg, Attribute, g)
import Internal.Base
import Axis


viewHorizontal : Plot -> Maybe Axis.Customizations -> Svg msg
viewHorizontal _ =
  g [] []


viewVertical : Plot -> Maybe Axis.Customizations -> Svg msg
viewVertical _ =
  g [] []
