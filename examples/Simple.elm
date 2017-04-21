module Simple exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Series exposing (..)
import Colors exposing (..)
import Axis exposing (..)

data =
  { first =
    [ ( -4.2, 20 )
    , ( 2, 50 )
    , ( 5, 30 )
    , ( 7, 90 )
    ]
  , second =
    [ ( 1, 30 )
    , ( 2, 40 )
    , ( 5, 20 )
    , ( 7.8, 0 )
    ]
  }


{-| -}
defaultAxisView : AxisView
defaultAxisView =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = decentPositions >> List.map gridMark
  , mirror = False
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
