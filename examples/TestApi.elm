module TestApi exposing (..)

import Html exposing (Html, div)
import Svg.Plot exposing (..)


blueFill : String
blueFill =
    "#e4eeff"


blueStroke : String
blueStroke =
    "#cfd8ea"


skinFill : String
skinFill =
    "#feefe5"


skinStroke : String
skinStroke =
    "#f7e0d2"


pinkFill : String
pinkFill =
    "#fdb9e7"


pinkStroke : String
pinkStroke =
    "#ff9edf"


myDot : { x : Float, y : Float } -> DataPoint msg
myDot { x, y } =
  { view = Just (viewCircle 5 pinkStroke)
  , glitter = rangeFrameGlitter x y
  , x = x
  , y = y
  }


data : List ( Float, Float )
data =
    List.map (\v -> ( toFloat v / 8, sin (toFloat v / 8) )) (List.range 0 100)


interpolation : Interpolation
interpolation =
  Monotone (Just pinkFill) []


toDot : ( Float, Float ) -> DataPoint msg
toDot ( x, y ) =
  emptyDot x y


main : Html msg
main =
  viewCustom
    { defaultPlotCustomizations | grid = { horizontal = decentGrid, vertical = emptyGrid } }
    [ custom normalAxis interpolation (List.map toDot) ] data
