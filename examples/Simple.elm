module Simple exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill)
import Series exposing (..)


data : List ( Float, Float )
data =
  [ ( 1, 3 )
  , ( 2, 4 )
  , ( 5, 2 )
  , ( 7, 0 )
  ]


main : Html msg
main =
  div [ style [ ("padding", "40px" ) ] ]
    [ view { dependentAxis = defaultAxis }
      [ { axis = axis defaultAxis
        , interpolation = Linear [ fill "rgba(204, 130, 224, 0.1)" ]
        , toDots = List.map (\(x, y) -> dot viewCircle x y)
        }
      , { axis = axis defaultAxis
        , interpolation = Monotone [ fill "rgba(204, 130, 224, 0.1)" ]
        , toDots = List.map (\(x, y) -> dot viewCircle x y)
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
