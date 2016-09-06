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
    allX = List.map fst allCoords
    allY = List.map snd allCoords
    (lowestX, highestX) = (getLowest allX, getHighest allX)
    (lowestY, highestY) = (getLowest allY, getHighest allY)

    -- Calculate the origin in terms of svg coordinates
    totalX = abs highestX + abs lowestX
    totalY = abs highestY + abs lowestY
    originX = width * (abs lowestX / totalX)
    originY = height * (abs highestY / totalY)
    deltaX = width / totalX
    deltaY = height / totalY

    -- Provide translators from cartesian coordinates to svg coordinates
    toSvgX = (\x -> (originX + x * deltaX))
    toSvgY = (\y -> (originY + y * deltaY * -1))
    toSvgCoords = (\(x, y) -> (toSvgX x, toSvgY y))

    -- Prepare axis' coordinates
    axisPositionX = (0, originY)
    axisPositionY = (originX, 0)

    -- and their ticks coordinates
    dtX = toFloat (floor (totalX / totalTicksX))
    dtY = toFloat (floor (totalY / totalTicksY))
    lowestTickX = byPrecision dtX ceiling lowestX
    lowestTickY = byPrecision dtY floor lowestY
    ticksX = List.map (\i -> (lowestTickX + (toFloat i) * dtX)) [0..totalTicksX]
    ticksY = List.map (\i -> (lowestTickY + (toFloat i) * dtY)) [0..totalTicksY]

  in
    Svg.svg
      [ Svg.Attributes.height (toString height)
      , Svg.Attributes.width (toString width)
      , style "padding: 50px;"
      ]
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords) series data)
      , viewAxis XAxis config axisPositionX toSvgX ticksX
      , viewAxis YAxis config axisPositionY toSvgY ticksY
      ]


viewAxis : Axis -> PlotConfig data -> Coord -> (Float -> Float) -> List Float -> Svg.Svg a
viewAxis axis config position toSvgValue ticks =
  let
    labelDisplacement =
      if axis == XAxis then (0, 20) else (-20, 5)

    axisPath =
      case axis of
        XAxis -> toInstruction "H" [toFloat config.width]
        YAxis -> toInstruction "V" [toFloat config.height]

    toTickCoords =
      case axis of
        XAxis -> (\x -> (toSvgValue x, 0))
        YAxis -> (\y -> (0, toSvgValue y))
  in
    viewSvgContainer position
      [ viewAxisPath axisPath -- Line
      , Svg.g [] -- Ticks
        (List.map (toTickCoords >> viewSvgLine) ticks)
      , viewSvgContainer labelDisplacement -- Labels
        (List.map (\tick -> viewSvgText (toTickCoords tick) (toString tick)) ticks)
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
    allX = List.map fst allCoords
    (lowestX, highestX) = (getLowest allX, getHighest allX)

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
