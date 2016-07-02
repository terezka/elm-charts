module Data exposing (..)

import String
import Svg exposing (circle, path)
import Svg.Attributes exposing (cx, cy, r, fill, d, style)

import Types exposing (..)
import Axis exposing (Dimensions)


type alias Model = DataSet


init : DataSet -> Model 
init data =
   data 


view : Model -> Dimensions -> Svg.Svg a
view model dimenstions =
    --Svg.g [] (List.map viewDataPoint model)
    Svg.g [] [ (viewPath model) ]


viewDataPoint : DataPoint -> Svg.Svg a
viewDataPoint point =
  circle
    [ cx (toString point.x)
    , cy (toString point.y)
    , r "2"
    , fill "red"
    ]
    []


viewPath : DataSet -> Svg.Svg a
viewPath points =
    let commands = List.map (\point -> (toString point.x) ++ "," ++ (toString point.y)) points
        direction = "M" ++ (String.join " L" commands)
    in 
        path [ style "stroke: red; fill: none;", d direction ] [] 
