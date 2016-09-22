module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (
  viewSvgContainer,
  viewAxisPath,
  viewSvgLine,
  viewSvgText,
  startPath,
  toInstruction,
  getLowest,
  getHighest,
  byPrecision,
  coordToInstruction)


-- TYPES

type SerieType = Line | Area

type alias SerieConfig data =
    { serieType : SerieType
    , color : String
    , areaColor : String
    , toCoords : data -> List (Float, Float)
    }


type alias PlotConfig data =
  { dimensions : (Int, Int)
  , tickHeight : Int
  , series : List (SerieConfig data)
  }


type alias Coord =
  (Float, Float)


type Axis = XAxis | YAxis


-- TODO: Move to config
totalTicks = 
  (12, 6)


-- VIEW


type alias AxisProps =
  { axis : Axis
  , getValue : Coord -> Float
  , lowestValue : Float
  , highestValue : Float
  , span : Float
  , origin : Float
  , toSvg : Float -> Float
  }


getAxisProps : Axis -> PlotConfig data -> List data -> AxisProps
getAxisProps axis { dimensions, series } data =
  let
    getValue = 
      case axis of
        XAxis -> fst
        YAxis -> snd

    values =
      List.map2 .toCoords series data
      |> List.concat
      |> List.map getValue

    edgeValues = 
      (getLowest values, getHighest values)

    (lowestValue, highestValue) =
      edgeValues
  
    span =
      abs lowestValue + abs highestValue

    delta =
      (toFloat (getValue dimensions)) / span

    origin =
      abs (getValue edgeValues) * delta

    toSvg =
      case axis of
        XAxis ->
          (\x -> origin + delta * x)
        YAxis ->
          (\y -> origin - delta * y)
  in
    AxisProps
      axis
      getValue
      lowestValue
      highestValue
      span
      origin
      toSvg



viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
  let
    xAxis =
      getAxisProps XAxis config data

    yAxis =
      getAxisProps YAxis config data

    toSvgCoords =
      (\(x, y) -> (xAxis.toSvg x, yAxis.toSvg y))

    axisPositionX = (0, yAxis.origin)
    axisPositionY = (xAxis.origin, 0)

  in
    viewFrame config
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords) config.series data)
      , viewAxis xAxis config axisPositionX 
      , viewAxis yAxis config axisPositionY
      ]


viewFrame : PlotConfig data -> List (Svg.Svg a) -> Svg.Svg a
viewFrame { dimensions } children =
  let
    (width, height) = dimensions
  in
    Svg.svg
      [ Svg.Attributes.height (toString height)
      , Svg.Attributes.width (toString width)
      , style "padding: 50px;"
      ]
      children


viewAxis : AxisProps -> PlotConfig data -> Coord -> Svg.Svg a
viewAxis { axis, getValue, span, lowestValue, toSvg } { tickHeight, dimensions } position =
  let
    tickDelta = 
      toFloat (floor (span / (getValue totalTicks)))

    lowestTick =
      byPrecision tickDelta ceiling lowestValue

    tickIndexes =
      [0..(getValue totalTicks)]

    ticks =
      List.map (\i -> (lowestTick + i * tickDelta)) tickIndexes 

    toTickCoords =
      case axis of
        XAxis -> (\x -> (toSvg x, 0, 0, tickHeight))
        YAxis -> (\y -> (0, toSvg y, -tickHeight, 0))

    ticksView =
      Svg.g [] (List.map (toTickCoords >> viewSvgLine) ticks)

    displacement =
      if axis == XAxis then (0, 20) else (-20, 5)

    labelsView =
      viewSvgContainer displacement
        (List.map (\tick -> viewSvgText (toTickCoords tick) (toString tick)) ticks)

    (width, height) =
      dimensions

    axisPath =
      case axis of
        XAxis -> toInstruction "H" [toFloat width]
        YAxis -> toInstruction "V" [toFloat height]

  in
    viewSvgContainer position
      [ viewAxisPath axisPath
      , ticksView
      , labelsView
      ]


viewSeries : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeries toSvgCoords config data =
  case config.serieType of
    Line -> viewSeriesLine toSvgCoords config data
    Area -> viewSeriesArea toSvgCoords config data


{- Draw area series -}
viewSeriesArea : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeriesArea toSvgCoords config data =
  let
    allCoords = config.toCoords data
    range = List.map fst allCoords
    (lowestX, highestX) = (getLowest range, getHighest range)

    svgCoords = List.map toSvgCoords allCoords
    (highestSvgX, originY) = toSvgCoords (highestX, 0)
    (lowestSvgX, _) = toSvgCoords (lowestX, 0)

    startInstruction = toInstruction "M" [lowestSvgX, originY]
    endInstructions = toInstruction "L" [highestSvgX, originY]
    instructions = coordToInstruction "L" svgCoords

    style' =
      String.join "" ["stroke: ", config.color, "; fill:", config.areaColor]
  in
    Svg.path
      [ d (startInstruction ++ instructions ++ endInstructions ++ "Z"), style style' ]
      []


{- Draw line series -}
viewSeriesLine : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeriesLine toSvgCoords config data =
  let
    svgCoords = List.map toSvgCoords (config.toCoords data)
    (startInstruction, tail) = startPath svgCoords
    instructions = coordToInstruction "L" svgCoords
    style' = String.join "" ["stroke: ", config.color, "; fill: none;"]
  in
    Svg.path [ d (startInstruction ++ instructions), style style' ] []
