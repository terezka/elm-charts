module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (viewSvgLine, startPath, toInstruction, getLowest, getHighest, byPrecision)
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


type alias Coord =
  (Float, Float)

type alias DoubleCoords =
  (Float, Float, Float, Float)


totalTicksX = 18
totalTicksY = 15


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
    axisCoordsX = (0, originY, width, originY)
    axisCoordsY = (originX, 0, originX, height)

    -- and their ticks coordinates
    dtX = toFloat (floor (totalX / totalTicksX))
    dtY = toFloat (floor (totalY / totalTicksY))
    offsetX = originX + (deltaX * (byPrecision dtX ceiling lowestX))
    offsetY = originY - (deltaY * (byPrecision dtY floor highestY))
    dtSvgX = deltaX * dtX
    dtSvgY = deltaY * dtY

    toTickCoordsX =
      (\index ->
        let tickX = offsetX + index * dtSvgX
        in (tickX, originY, tickX, originY + 5)
      )
    toTickCoordsY =
      (\index ->
        let tickY = offsetY + index * dtSvgY
        in (originX, tickY, originX - 5, tickY)
      )

  in
    Svg.svg
      [ Svg.Attributes.height (toString height)
      , Svg.Attributes.width (toString width)
      , style "padding: 50px;"
      ]
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords) series data)
      , viewAxis axisCoordsX toTickCoordsX totalTicksX
      , viewAxis axisCoordsY toTickCoordsY totalTicksY
      ]


viewAxis : DoubleCoords -> (Float -> DoubleCoords) -> Int -> Svg.Svg a
viewAxis axisCoords toTickCoords amountOfTicks =
  Svg.g []
    [ viewSvgLine axisCoords
    , Svg.g []
      (List.map (\index -> viewSvgLine (toTickCoords (toFloat index))) [0..amountOfTicks])
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
