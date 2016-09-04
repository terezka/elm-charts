module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (viewSvgContainer, viewSvgLine, viewSvgText, startPath, toInstruction, getLowest, getHighest, byPrecision)
import Debug

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
totalTicksY = 13


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

    -- Prepare axis' coordinates and path for line
    axisPositionX = (0, originY)
    axisPositionY = (originX, 0)
    axisPathX = "M0.5, 0H" ++ (toString width)
    axisPathY = "M0.5, 0V" ++ (toString height)

    -- and their ticks coordinates
    dtX = toFloat (floor (totalX / totalTicksX))
    dtY = toFloat (floor (totalY / totalTicksY))
    lowestTickX = byPrecision dtX ceiling lowestX
    lowestTickY = byPrecision dtY floor lowestY
    ticksX = List.map (\i -> (lowestTickX + (toFloat i) * dtX)) [0..totalTicksX]
    ticksY = List.map (\i -> (lowestTickY + (toFloat i) * dtY)) [0..totalTicksY]

    toTickCoordsX = (\tickX -> (toSvgX tickX, 0))
    toTickCoordsY = (\tickY -> (0, toSvgY tickY))
  in
    Svg.svg
      [ Svg.Attributes.height (toString height)
      , Svg.Attributes.width (toString width)
      , style "padding: 50px;"
      ]
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords) series data)
      , viewAxis axisPositionX axisPathX toTickCoordsX ticksX
      , viewAxis axisPositionY axisPathY toTickCoordsY ticksY
      ]


viewAxis : Coord -> String -> (Float -> Coord) -> List Float -> Svg.Svg a
viewAxis (x, y) axisPath toTickCoords ticks =
  viewSvgContainer x y
    [ Svg.path [ d axisPath, style "stroke: #757575;" ] []
    , Svg.g []
      (List.map (\tick -> viewSvgLine (toTickCoords tick)) ticks)
    , Svg.g []
      (List.map (\tick -> viewSvgText (toTickCoords tick) (toString tick)) ticks)
    ]


{- Draw series -}
viewSeries : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeries toSvgCoords config data =
  let
    style' =
      "stroke: " ++ config.color ++ "; fill:" ++ config.areaColor

    allCoords = config.toCoords data
    allX = List.map fst allCoords
    (lowestX, highestX) = (getLowest allX, getHighest allX)

    coords =
      config.toCoords data
      |> List.map toSvgCoords
      |> List.map (\(x, y) -> (toString x, toString y))

    (highestSvgX, originY) = toSvgCoords (highestX, 0)
    (lowestSvgX, _) = toSvgCoords (lowestX, 0)

    (startInstruction, tail) =
      if config.serieType == Line then
        startPath coords
      else
        (toInstruction "M" [toString lowestSvgX, toString originY], coords)

    endInstruction =
      if config.serieType == Line then ""
      else
        (toInstruction "L" [toString highestSvgX, toString originY]) ++ " Z"

    instructions =
      tail
      |> List.map (\(x, y) -> toInstruction "L" [x, y])
      |> String.join ""
  in
    Svg.path [ d (startInstruction ++ instructions ++ endInstruction), style style' ] []
