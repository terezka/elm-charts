module Internal.Plot exposing (..)

import Internal.Base as Base
import Plot


view : Plot.Customizations msg -> Base.Plot -> List (Svg.Svg msg) -> Svg.Svg msg


viewClipPath : Plot.Customizations msg -> Base.Plot -> Svg.Svg msg
