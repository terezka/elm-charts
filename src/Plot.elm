module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (viewSvgContainer, viewAxisPath, viewSvgLine, viewSvgText, startPath, toInstruction, getLowest, getHighest, byPrecision, coordToInstruction)
import Debug

-- TYPES

type SerieType = Line | Area

type alias SerieConfig data =
    { serieType : SerieType
    , color : String
    , areaColor : String
    , toCoords : data -> List (Float, Float)
    }


type alias PlotConfig data =
  { name : String
  , width : Int
  , height : Int
  , tickHeight : Int
  , series : List (SerieConfig data)
  }


type Axis = XAxis | YAxis

type alias Coord =
  (Float, Float)

type alias DoubleCoords =
  (Float, Float, Float, Float)

totalTicksX = 12
totalTicksY = 8


-- VIEW


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
  let
    (width, height) = (toFloat config.width, toFloat config.height)
    series = config.series

    -- Get axis' ranges
    allCoords = List.concat (List.map2 .toCoords series data)
    range = List.map fst allCoords
    domain = List.map snd allCoords
    (lowestX, highestX) = (getLowest range, getHighest range)
    (lowestY, highestY) = (getLowest domain, getHighest domain)

    -- Calculate the origin in terms of svg coordinates
    spanX = abs highestX + abs lowestX
    spanY = abs highestY + abs lowestY
    deltaX = width / spanX
    deltaY = height / spanY
    originX = abs lowestX * deltaX
    originY = abs highestY * deltaY

    -- Provide translators from cartesian coordinates to svg coordinates
    toSvgX = (\x -> (originX + x * deltaX))
    toSvgY = (\y -> (originY + y * deltaY * -1))
    toSvgCoords = (\(x, y) -> (toSvgX x, toSvgY y))

    -- Prepare axis' coordinates
    axisPositionX = (0, originY)
    axisPositionY = (originX, 0)

    -- and their ticks coordinates
    tickDeltaX = toFloat (floor (spanX / totalTicksX))
    tickDeltaY = toFloat (floor (spanY / totalTicksY))
    lowestTickX = byPrecision tickDeltaX ceiling lowestX
    lowestTickY = byPrecision tickDeltaY floor lowestY
    ticksX = List.map (\i -> (lowestTickX + (toFloat i) * tickDeltaX)) [0..totalTicksX]
    ticksY = List.map (\i -> (lowestTickY + (toFloat i) * tickDeltaY)) [0..totalTicksY]

  in
    viewFrame config
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords) series data)
      , viewAxis XAxis config axisPositionX toSvgX ticksX
      , viewAxis YAxis config axisPositionY toSvgY ticksY
      ]


viewFrame : PlotConfig data -> List (Svg.Svg a) -> Svg.Svg a
viewFrame { width, height } children =
  Svg.svg
    [ Svg.Attributes.height (toString height)
    , Svg.Attributes.width (toString width)
    , style "padding: 50px;"
    ]
    children


viewAxis : Axis -> PlotConfig data -> Coord -> (Float -> Float) -> List Float -> Svg.Svg a
viewAxis axis { tickHeight, width, height } position toSvgValue ticks =
  let
    toTickCoords =
      case axis of
        XAxis -> (\x -> (toSvgValue x, 0, 0, tickHeight))
        YAxis -> (\y -> (0, toSvgValue y, -tickHeight, 0))

    ticksView =
      Svg.g [] (List.map (toTickCoords >> viewSvgLine) ticks)

    labelDisplacement =
      if axis == XAxis then (0, 20) else (-20, 5)

    labelsView =
      viewSvgContainer labelDisplacement
        (List.map (\tick -> viewSvgText (toTickCoords tick) (toString tick)) ticks)

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
