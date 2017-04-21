module Simple exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Series exposing (..)
import Colors exposing (..)


data =
  { first =
    [ ( 1, 2 )
    , ( 2, 5 )
    , ( 5, 3 )
    , ( 7, 9 )
    ]
  , second =
    [ ( 1, 3 )
    , ( 2, 4 )
    , ( 5, 2 )
    , ( 7, 0 )
    ]
  }



main : Html msg
main =
  div [ style [ ("padding", "40px" ) ] ]
    [ view
      [ { axis = axis defaultAxisView
        , interpolation = Linear [ fill blueFill, stroke blueStroke ]
        , toDots = .second >> List.map (\(x, y) -> dot viewCircle x y)
        }
      , { axis = axis defaultAxisView
        , interpolation = Monotone [ fill pinkFill ]
        , toDots = .first >> List.map (\(x, y) -> dot viewCircle x y)
        }
      ]
      data
    ]


viewCircle : Svg msg
viewCircle =
  Svg.circle
    [ Attributes.r "5"
    , Attributes.stroke "transparent"
    , Attributes.fill "pink"
    ]
    []
