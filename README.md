# elm-charts

Make charts!

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