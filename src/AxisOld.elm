module Axis exposing (..)

import Svg
import Svg.Attributes exposing (transform, x, y, dx, dy, x1, x2, y1, y2, width, height, stroke)

import Types exposing (Point, point)

import Debug


type alias Model = 
    { isVertical : Bool
    , min : Int
    , max : Int
    , scale : Int
    , length : Int
    }


init : Model 
init = 
    { isVertical = False
    , min = 0
    , max = 100
    , scale = 10
    , length = 300
    }


setVertical : Bool -> Model -> Model
setVertical bool model =
    { model | isVertical = bool }

setScale : Int -> Model -> Model 
setScale scale model =
    { model | scale = scale }

setMaxRange : Int -> Model -> Model 
setMaxRange max model =
    { model | max = max }

setLength : Int -> Model -> Model
setLength length model =
    { model | length = length }



-- View



zeroPoint : Point
zeroPoint =
    Types.point 0 0


{-| Move along or perpendicular relative to the axis operating -}

moveRelative : Model -> (Int -> Int -> Point -> Point)
moveRelative model =
    if model.isVertical then
        (\along perp point -> Types.point (point.x + perp) (point.y + along))
    else
        (\along perp point -> Types.point (point.x + along) (point.y + perp))


view : Model -> Svg.Svg a
view model =
    let 
        origin = (((model.min + model.max) |> toFloat) / (toFloat model.max)) |> round
        move = moveRelative model
        axisPoints = (move 0 origin zeroPoint, move model.length 0 zeroPoint)
     in
        Svg.g
          []
          [ Svg.g [] [ viewLine axisPoints ] ]


viewTick : (Point, Point, Point, Float) -> Svg.Svg a
viewTick (point1, point2, pointText, value) =
    Svg.g 
      [] 
      [ viewLine (point1, point2)
      , Svg.text' 
          [ x (toString pointText.x), y (toString pointText.y) ] 
          [ Svg.tspan [] [ Svg.text (toString value) ] ]
      ]


viewLine : (Point, Point) -> Svg.Svg a 
viewLine (point1, point2) =
    let
        attr = 
            [ stroke "red" ] ++ 
            [ x1 (toString point1.x)
            , y1 (toString point1.y)
            , x2 (toString point2.x)
            , y2 (toString point2.y) 
            ]
    in
        Svg.g [] [ Svg.line attr [] ]
