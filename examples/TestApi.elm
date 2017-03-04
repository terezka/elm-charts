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



main : Html msg
main =
  view
      [ line (List.map (\{ x, y } -> circle x y)) ]
      [ { x = 0, y = 2 }
      , { x = 2, y = 4 }
      , { x = 3, y = -1 }
      ]
