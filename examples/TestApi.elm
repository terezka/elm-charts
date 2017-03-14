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
  rangeFrameDot (viewCircle 5 pinkStroke) x y


data : List ( Float, Float )
data =
    List.map (\v -> ( toFloat v / 8, sin (toFloat v / 8) )) (List.range 0 100)


barData : List ( List Float )
barData =
  [ [ 1, 4, 6 ]
  , [ 1, 5, 6 ]
  , [ 2, 10, 6 ]
  , [ 4, -2, 6 ]
  , [ 5, 14, 6 ]
  ]


barData2 : List Float
barData2 =
  [ 2, 4, 6, 7, 8, 9, 4, 5 ]


main : Html msg
main =
  viewBars (grouped (List.map2 group [ "g1", "g3", "g3" ])) barData
