# elm-charts

Make charts in all Elm. The package can draw charts at a variety of customizations, down to including your very own SVG elements, as well as editing the SVG made by the package. It has great support for interactivity, layering different charts, and adding irregular details.

You can check out the many examples at https://elm-charts.org!

Here is also a basic example to copy and play with.

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
    , C.bars [ C.bar identity [] ] [ 2, 4, 3 ]
    ]
```
