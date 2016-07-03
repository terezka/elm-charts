module Axis exposing (..)

import Svg
import Svg.Attributes exposing (transform, x, y, dx, dy, x1, x2, y1, y2, width, height, stroke)
import String
import Maybe

import Types exposing (Point, point, DataSetSingle)

import Debug


type alias Model = 
    { isVertical : Bool
    , min : Int
    , max : Int
    , scale : Int
    , length : Int
    }


init : DataSetSingle -> Model 
init axisPoints = 
    let
        max = Maybe.withDefault 1 (List.maximum axisPoints)
        minPoint = Maybe.withDefault 0 (List.minimum axisPoints)
        min = if minPoint > 0 then 0 else minPoint 
    in
        { isVertical = False
        , min = min
        , max = max
        , scale = 1
        , length = 400
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



-- Dimensions of graph based on both axis


type alias Dimensions =
    { originX : Int
    , originY : Int
    , deltaX : Int
    , deltaY : Int
    }


initDimensions : Model -> Model -> Dimensions
initDimensions xAxis yAxis =
    { originX = origin xAxis
    , originY = origin yAxis
    , deltaX = delta xAxis
    , deltaY = delta yAxis
    }


origin : Model -> Int
origin model = 
    if model.isVertical 
        then (abs model.max) * (delta model)
        else (abs model.min) * (delta model)


delta : Model -> Int
delta model =
    (toFloat model.length) / (toFloat (total model)) |> round |> Debug.log "delta"


total : Model -> Int
total model =
    abs model.max + abs model.min


-- View


view : Model -> Dimensions -> Svg.Svg a
view model dimensions =
    Svg.g [] [ viewAxis model dimensions, viewTicks model dimensions ]


viewAxis : Model -> Dimensions -> Svg.Svg a
viewAxis model dimensions =
    let points = 
          if model.isVertical 
          then (point dimensions.originX 0, point dimensions.originX model.length) 
          else (point 0 dimensions.originY, point model.length dimensions.originY) 
    in
        Svg.g [] [ viewLine points ] 


viewTicks : Model -> Dimensions -> Svg.Svg a
viewTicks model dimensions =
    let amount = (toFloat (total model)) / (toFloat model.scale) |> round
    in
        Svg.g [] (List.map (viewTick model dimensions) [0..amount])


viewTick : Model -> Dimensions -> Int -> Svg.Svg a
viewTick model dimensions index = 
    let value = 
            if model.isVertical
            then model.max - index * model.scale
            else model.min + index * model.scale

        movement =
            if model.isVertical
            then index * model.scale * dimensions.deltaY
            else index * model.scale * dimensions.deltaX

        coords = 
            if model.isVertical 
            then (point dimensions.originX movement, point (dimensions.originX-10) movement)
            else (point movement dimensions.originY, point movement (dimensions.originY+10))
        --value = index * model.scale

        displaced = snd coords
    in
        Svg.g 
          [] 
          [ viewLine coords
          , Svg.text' 
              [ x (toString displaced.x), y (toString displaced.y) ] 
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



