module PlotExample exposing (..)

import Html exposing (Html, button, div, text)
import Debug

type alias SerieConfig data =
    { color : String
    , areaColor : String
    , toX : data -> List Int
    , toY : data -> List Int
    }


type alias PlotConfig data =
  { name: String
  , height : Int
  , width : Int
  , series : List (SerieConfig data)
  }


main =
  viewPlot plotConfig dataHere

type alias SeriesData =
  { x : List Int, y : List Int }

dataHere : List SeriesData
dataHere =
  [ { x = [ 0, 2, 3, 4 ], y = [ 2, 4, 6, 7 ] }
  , { x = [ 15, 3, 9, 4 ], y = [ 10, 6, 1, 8 ] }
  ]


plotConfig : PlotConfig SeriesData
plotConfig =
  PlotConfig "Great plot" 200 400 serieConfigs


serieConfigs : List (SerieConfig SeriesData)
serieConfigs =
  [ SerieConfig "red" "magneta" .x .y
  , SerieConfig "blue" "ariel" .x .y
  ]


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot { name, series } data =
  let
    highestX = maxValue .toX series data
    highestY = maxValue .toY series data
  in
    div []
      [ div [] [ text name ]
      , div [] [ text (toString highestX) ]
      , div [] (List.map2 viewSerie series data)
      ]


viewSerie : SerieConfig data -> data -> Html msg
viewSerie { color, toX, toY } data =
  div []
    [ div [] [ text (viewValues (toX data)) ]
    , div [] [ text (viewValues (toY data)) ]
    ]


viewValues : List Int -> String
viewValues values =
  List.head values
    |> Maybe.withDefault 0
    |> toString


maxValue : (SerieConfig data -> data -> List Int) -> List (SerieConfig data) -> List data -> Int
maxValue toValues series data =
  List.map2 toValues series data
    |> List.concat
    |> List.maximum
    |> Maybe.withDefault 0
