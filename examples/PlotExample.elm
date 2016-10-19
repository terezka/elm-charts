module PlotExample exposing (..)

import Plot
import Svg
import Svg.Attributes
import Html exposing (Html)



myCustomTick : Plot.Coord -> Plot.Coord -> Svg.Svg a
myCustomTick (x1, y1) (x2, y2) =
    Svg.g []
        [ Svg.line
            [ Svg.Attributes.style "stroke: red;"
            , Svg.Attributes.x1 (toString x1)
            , Svg.Attributes.y1 (toString y1)
            , Svg.Attributes.x2 (toString x2)
            , Svg.Attributes.y2 (toString y2)
            ]
            []
        ]


viewCustomPlot : Plot.PlotConfig -> Plot.Calculations data -> Html a
viewCustomPlot { dimensions } { xAxis, yAxis, toSvgCoordsX, toSvgCoordsY, series } =
    Plot.viewPlotFrame dimensions
        [ Svg.g [] (List.map (Plot.viewSeries toSvgCoordsX) series)
        , Plot.viewAxis toSvgCoordsX [ Plot.customTick myCustomTick ] xAxis
        , Plot.viewAxis toSvgCoordsY [ Plot.customTick myCustomTick ] yAxis
        ]


areaConfig =
    Plot.SerieConfig Plot.Area "cornflowerblue" "#ccdeff" identity


areaData =
    [ (-50, 34), (-30, 432), (-20, 35), (2, 546), (10, 345), (30, 42), (90, 67), (120, 50) ]


lineConfig =
    Plot.SerieConfig Plot.Line "mediumvioletred" "transparent" identity


lineData =
    [ (-50, -34), (-30, 42), (-20, -35), (2, -46), (10, -45), (30, -42), (90, -67), (120, 50) ]


main =
    let
        series = [ (areaConfig, areaData), (lineConfig, lineData) ]
    in
        Plot.viewPlot viewCustomPlot { dimensions = (800, 500) } series

