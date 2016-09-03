module PlotExample exposing (..)

import Plot

main =
  Plot.viewPlot plotConfig dataHere


type alias SeriesData =
  { x : List Float, y : List Float }


dataHere : List SeriesData
dataHere =
  [ { x = [ -1, 1, 3, 9, 12 ], y = [ -2, 10, 6, 1, 3 ] }
  , { x = [ -4, 0, 2, 3, 10, 14 ], y = [ -7, 2, 4, 6, 5, 7 ] }
  ]


plotConfig : Plot.PlotConfig SeriesData
plotConfig =
  Plot.PlotConfig "Great plot" 200 400 serieConfigs


serieConfigs : List (Plot.SerieConfig SeriesData)
serieConfigs =
  [ Plot.SerieConfig Plot.Area "cornflowerblue" "#ccdeff" (\{x, y} -> List.map2 (,) x y)
  , Plot.SerieConfig Plot.Line "mediumvioletred" "transparent" (\{x, y} -> List.map2 (,) x y)
  ]
