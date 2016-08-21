module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style)

import Debug

type alias SerieConfig data =
    { color : String
    , areaColor : String
    , toX : data -> List Int
    , toY : data -> List Int
    }


type alias PlotConfig data =
  { name : String
  , height : Int
  , width : Int
  , series : List (SerieConfig data)
  }


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
  let
    plotDims' = plotDims config data
  in
    Svg.svg
      [ Svg.Attributes.height (toString config.height)
      , Svg.Attributes.width (toString config.width)
      , style "padding: 50px;"
      ]
      [ viewAxis AlongX config data ]


type alias PlotDims =
  { originX : Float
  , originY : Float
  , deltaX : Float
  , deltaY : Float
  }


type Direction = AlongX | AlongY


plotDims : PlotConfig data -> List data -> PlotDims
plotDims config data =
  let
    (lowestX, highestX) = axisDim AlongX config.series data
    (lowestY, highestY) = axisDim AlongY config.series data

    totalX =  abs highestX + abs lowestX
    originX = (toFloat config.width) * (abs lowestX / totalX)
    totalY =  (abs highestY + abs lowestY)
    originY = (toFloat config.height) * (abs highestY / totalY)

    deltaX = (toFloat config.width) / totalX
    deltaY = (toFloat config.height) / totalY
  in
    PlotDims originX originY deltaX deltaY


axisDim : Direction -> List (SerieConfig data) -> List data -> (Float, Float)
axisDim direction series data =
  let
    toValues = if direction == AlongX then .toX else .toY
    allValues = List.concat (List.map2 toValues series data)
    highest = toFloat (Maybe.withDefault 1 (List.maximum allValues))
    lowest = toFloat (Maybe.withDefault 0 (List.minimum allValues))
  in
    if lowest > 0 then (0, highest) else (lowest, highest)


viewAxis : Direction -> PlotConfig data -> List data -> Svg.Svg a
viewAxis direction { height, width, series } data =
  let
    toValues = if direction == AlongX then .toX else .toY

  in
     Svg.g [] []


concatValues : (SerieConfig data -> data -> List Int) -> List (SerieConfig data) -> List data -> List Int
concatValues toValues series data =
  List.concat (List.map2 toValues series data)
