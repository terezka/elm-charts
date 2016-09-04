module PlotExample exposing (..)

import Plot

main =
  Plot.viewPlot plotConfig dataHere


type alias SeriesData =
  { x : List Float, y : List Float }


dataHere : List SeriesData
dataHere =
  [ { x = [ -50, -30, -20, 10, 30, 90, 120 ], y = [ -5, -20, -10, 100, 60, 10, 30 ] }
  , { x = [ -40, 0, 20, 30, 100, 140 ], y = [ -70, 20, 40, 60, 50, 70 ] }
  ]


plotConfig : Plot.PlotConfig SeriesData
plotConfig =
  Plot.PlotConfig "Great plot" 800 500 serieConfigs


serieConfigs : List (Plot.SerieConfig SeriesData)
serieConfigs =
  [ Plot.SerieConfig Plot.Area "cornflowerblue" "#ccdeff" (\{x, y} -> List.map2 (,) x y)
  , Plot.SerieConfig Plot.Line "mediumvioletred" "transparent" (\{x, y} -> List.map2 (,) x y)
  ]
