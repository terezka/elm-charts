module Axis exposing (..)

import Svg
import Svg.Attributes exposing (transform, x1, x2, y1, y2, width, height, stroke)

type alias Model = 
    { isVertical : Bool
    , min : Int
    , max : Int
    }


init : Model 
init = 
    { isVertical = False
    , min = 0
    , max = 10
    }


setVertical : Bool -> Model -> Model
setVertical bool model =
    { model | isVertical = bool }


setMinRange : Int -> Model -> Model 
setMinRange min model =
    { model | min = min }

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
         firstPoint = if model.isVertical then [ x1 "50", y1 "300" ] else [ x1 "50", y1 "50" ]
         secondPoint = if model.isVertical then [ x2 "300", y2 "300" ] else [ x2 "50", y2 "300" ]
         lineAttr =  [ stroke "red" ] ++ firstPoint ++ secondPoint
    in
        Svg.g
          []
          [ Svg.line lineAttr [] ]
