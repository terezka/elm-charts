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
    , min : Int
    , max : Int
    , scale : Int
    }


init : Model 
init = 
    { isVertical = False
    , min = 0
    , max = 10
    , scale = 10
    }


setVertical : Bool -> Model -> Model
setVertical bool model =
    { model | isVertical = bool }


setMinRange : Int -> Model -> Model 
setMinRange min model =
    { model | min = min }

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
        ticksNo = length / (toFloat model.scale) |> round
        tickLength = if model.isVertical then -10 else 10
        ticks = List.map (\i -> let start = moveA base (i*model.scale) in (moveP start tickLength, start)) [0..ticksNo]
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
