module Axis exposing (..)

import Svg
import Svg.Attributes exposing (transform, x1, x2, y1, y2, width, height, stroke)

import Debug

type alias Point =
    { x : Int, y : Int }


point : Int -> Int -> Point 
point x y =
    { x = x, y = y }


type alias Model = 
    { isVertical : Bool
    , max : Int
    , scale : Int
    }


init : Model 
init = 
    { isVertical = False
    , max = 100
    , scale = 10
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


type Msg =
    ClickRange


update : Msg -> Model -> Model 
update msg model =
    model


view : Model -> Svg.Svg Msg
view model =
    let 
        length = 290
        base = if model.isVertical then point 50 0 else point 50 length
        moveA = if model.isVertical then (\point y -> { point | y = point.y + y }) else (\point x -> { point | x = point.x + x })
        moveP = if model.isVertical then (\point x -> { point | x = point.x + x }) else (\point y -> { point | y = point.y + y })
        axis = (base, moveA base length)

        ticksNo = (toFloat model.max) / (toFloat model.scale) |> round
        tickDiff = length / (toFloat ticksNo) |> round
        tickLength = if model.isVertical then -10 else 10
        ticks = List.map (\i -> let start = moveA base (i*tickDiff) in (moveP start tickLength, start)) [0..ticksNo]
    in
        Svg.g
          []
          [ Svg.g [] [ viewLine axis ]
          , Svg.g [] (List.map viewLine ticks)
          ]


viewLine : (Point, Point) -> Svg.Svg Msg 
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
