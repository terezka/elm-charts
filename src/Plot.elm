module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String

import Helpers exposing (viewLine)

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


type Direction = AlongX | AlongY


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
  let
    props = plotProps config data
  in
    Svg.svg
      [ Svg.Attributes.height (toString config.height)
      , Svg.Attributes.width (toString config.width)
      , style "padding: 50px;"
      ]
      [ viewAxis AlongX props
      , viewAxis AlongY props
      , Svg.g [] (List.map2 (viewSeries props) config.series data)
      ]


-- TODO: Instead of these props, save function to parse data coords into
-- svg coords, and the highest x/y values
type alias PlotProps =
  { originX : Float
  , originY : Float
  , deltaX : Float
  , deltaY : Float
  , width : Float
  , height : Float
  }


{- Calculate the origin and scale -}
plotProps : PlotConfig data -> List data -> PlotProps
plotProps config data =
  let
    (lowestX, highestX) = axisProps AlongX config.series data
    (lowestY, highestY) = axisProps AlongY config.series data

    totalX =  abs highestX + abs lowestX
    originX = (toFloat config.width) * (abs lowestX / totalX)
    totalY =  (abs highestY + abs lowestY)
    originY = (toFloat config.height) * (abs highestY / totalY)

    deltaX = (toFloat config.width) / totalX
    deltaY = (toFloat config.height) / totalY
  in
    PlotProps originX originY deltaX deltaY (toFloat config.width) (toFloat config.height)


{- Retrive range of axis from data -}
axisProps : Direction -> List (SerieConfig data) -> List data -> (Float, Float)
axisProps direction series data =
  let
    toValues = if direction == AlongX then .toX else .toY
    allValues = List.concat (List.map2 toValues series data)
    highest = toFloat (Maybe.withDefault 1 (List.maximum allValues))
    lowest = toFloat (Maybe.withDefault 0 (List.minimum allValues))
  in
    if lowest > 0 then (0, highest) else (lowest, highest)


{- Draw axis -}
viewAxis : Direction -> PlotProps -> Svg.Svg a
viewAxis direction { originX, originY, width, height } =
  let
    axis =
      if direction == AlongX then
        viewLine 0 originY width originY
      else
        viewLine originX 0 originX height
  in
     Svg.g [] [ axis ]


{- Translate data coordinates into Svg coordinates -}
toSvgCoord : PlotProps -> Direction -> Int -> String
toSvgCoord { originX, deltaX, originY, deltaY } direction value =
  if direction == AlongX then
    toString (originX + (toFloat value) * deltaX)
  else
    toString (originY + (toFloat value) * deltaY * -1)


{- Parse data coordinates to svg path instruction -}
toInstruction : PlotProps -> Int -> Int -> String
toInstruction props x y =
  "L " ++ (toSvgCoord props AlongX x) ++ " " ++ (toSvgCoord props AlongY y)


{- Draw series -}
viewSeries : PlotProps -> SerieConfig data -> data -> Svg.Svg a
viewSeries props config data =
  let
    style' =
      "fill: none; stroke: " ++ config.color ++ ";"

    instructions =
      List.map2 (toInstruction props) (config.toX data) (config.toY data)
        |> String.join ","
  in
    Svg.path [ d ("M 0 0" ++ instructions), style style' ] []
