module Element exposing (Element(..))

import Plot.Types exposing (Point)
import Plot.Base as Base
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Grid.Config as Grid
import Plot.Area as Area
import Plot.Line as Line
import Plot.Tooltip as Tooltip


type Element msg
    = Axis (Axis.Config msg)
    | Tooltip (Tooltip.Config msg) (Maybe Point)
    | Grid Grid.Config
    | Line Line.Config (List Point)
    | Area Area.Config (List Point)