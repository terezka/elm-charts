module PlotExample exposing (..)

import Plot

main =
  Plot.viewPlot plotConfig dataHere


type alias SeriesData =
  { x : List Float, y : List Float }


dataHere : List SeriesData
dataHere =
  [ { x = [ -1, 1, 3, 9, 14 ], y = [ -2, 10, 6, 1, 1 ] }
  , { x = [ -4, 0, 2, 3, 10, 14 ], y = [ -7, 2, 4, 6, 5, 7 ] }
  ]


plotConfig : Plot.PlotConfig SeriesData
plotConfig =
  Plot.PlotConfig "Great plot" 200 400 serieConfigs


serieConfigs : List (Plot.SerieConfig SeriesData)
serieConfigs =
  [ Plot.SerieConfig "mediumvioletred" "red" (\{x, y} -> List.map2 (,) x y)
  , Plot.SerieConfig "cornflowerblue" "blue" (\{x, y} -> List.map2 (,) x y)
  ]
