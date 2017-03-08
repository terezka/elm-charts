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
    List.map (\v -> ( toFloat v, sin (toFloat v * pi / 20) )) (List.range 0 100)


main : Html msg
main =
  view
      [ custom normalAxis (Monotone Nothing []) (List.map (\( x, y ) -> emptyDot x y))
      ]
      data
