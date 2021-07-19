# elm-charts-alpha

Make charts! Alpha version, so liable to changes.

```elm

import Chart as C
import Chart.Attributes as CA

main : Svg msg
main =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xTicks []
    , C.yTicks []
    , C.xLabels []
    , C.yLabels []
    , C.xAxis []
    , C.yAxis []
    , C.series .x
        [ C.scatter .y []
        , C.scatter .z []
        ]
        data
    ]
```