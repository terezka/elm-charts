module Graph exposing (..)

import Svg
import Svg.Attributes exposing (cx, cy, r, color, fill, x, y, width, height)
import Svg.Events exposing (onClick)

import Debug


type alias Model
  = List Point


type alias Point
  = { x : Int, y: Int }

type Msg
  = Clicked Point


update : Msg -> Model -> Model
update msg model =
  case msg of
    Clicked clickedPoint ->
      let dataset = List.filter (\point -> point /= clickedPoint) model
      in
        Debug.log "here" dataset


view : Model -> Svg.Svg Msg
view dataset =
  Svg.g [] (List.map viewPoint dataset)


viewPoint : Point -> Svg.Svg Msg
viewPoint point =
  Svg.circle
    [ cx (toString point.x)
    , cy (toString point.y)
    , r "2"
    , fill "red"
    , onClick (Clicked point) ]
    []
