module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (viewSvgLine, startPath, toInstruction, getLowest, getHighest)
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
  , height : Int
  , width : Int
  , series : List (SerieConfig data)
  }


type alias Coords =
  (Float, Float)

type alias DoubleCoords =
  (Float, Float, Float, Float)


totalTicksX = 10
totalTicksY = 5


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
  let
    (width, height) = (toFloat config.width, toFloat config.height)
    series = config.series

    -- Get axis' ranges
    allCoords = List.concat (List.map2 .toCoords series data)
    allX = List.map fst allCoords
    (lowestX, highestX) = (getLowest allX, getHighest allX)
    allY = List.map snd allCoords
    (lowestY, highestY) = (getLowest allY, getHighest allY)

    -- Calculate the origin in terms of svg coordinates
    totalX = abs highestX + abs lowestX
    totalY = abs highestY + abs lowestY
    originX = width * (abs lowestX / totalX)
    originY = height * (abs highestY / totalY)
    deltaX = width / totalX
    deltaY = height / totalY

    -- Provide translators from cartesian coordinates to svg coordinates
    toSvgX = (\x -> toString (originX + x * deltaX))
    toSvgY = (\y -> toString (originY + y * deltaY * -1))
    toSvgCoords = (\(x, y) -> (toSvgX x, toSvgY y))

    -- Prepare axis' coordinates and their ticks coordinates
    axisCoordsX = (0, originY, width, originY)
    dtx = width / totalTicksX
    toTickCoordsX = (\index -> (index * dtx, originY, index * dtx, originY + 5))

    axisCoordsY = (originX, 0, originX, height)
    dty = height / totalTicksY
    toTickCoordsY = (\index -> (originX, index * dty, originX - 5, index * dty))
  in
    Svg.svg
      [ Svg.Attributes.height (toString height)
      , Svg.Attributes.width (toString width)
      , style "padding: 50px;"
      ]
      [ Svg.g [] (List.map2 (viewSeries toSvgCoords highestX) series data)
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
-- TODO: It is wrong to use the highest X, use the start and and of series
viewSeries : ((Float, Float) -> (String, String)) -> Float -> SerieConfig data -> data -> Svg.Svg a
viewSeries toSvgCoords highestX config data =
  let
    style' =
      "fill: none; stroke: " ++ config.color ++ "; fill:" ++ config.areaColor

    coords =
      config.toCoords data
      |> List.map toSvgCoords

    (endX, originY) = toSvgCoords (highestX, 0)

    (startInstruction, tail) =
      if config.serieType == Line then
        startPath coords
      else
        (toInstruction "M" ["0", originY], coords)

    endInstruction =
      if config.serieType == Line then ""
      else
        (toInstruction "L" [endX, originY]) ++ " Z"

    instructions =
      tail
      |> List.map (\(x, y) -> toInstruction "L" [x, y])
      |> String.join ""
  in
    Svg.path [ d (startInstruction ++ instructions ++ endInstruction), style style' ] []
