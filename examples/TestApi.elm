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


main : Html msg
main =
  view
      [ area (List.map (\{ x, y } -> diamond (x + 2) (y * 1.2)))
      , custom emptyAxis (Linear (Just pinkFill) []) (List.map myDot)
      ]
      [ { x = -3.1, y = 2.2 }
      , { x = 2.2, y = 4.2 }
      , { x = 3.5, y = -1.6 }
      , { x = 5.4, y = -0.8 }
      , { x = 6.8, y = 2.3 }
      ]
