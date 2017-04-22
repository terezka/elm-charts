module Main exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Histogram exposing (..)
import Colors exposing (..)


main : Html msg
main =
  div [ style [ ("padding", "40px" ) ] ]
    [ viewCustom
        { dependentAxis = defaultDependentAxis
        , independentAxis = defaultIndependentAxis
        , intervalBegin = 23
        , interval = 2.1
        }
        [ List.map (Tuple.first >> Bar [ fill blueFill, stroke blueStroke ])
        , List.map (Tuple.second >> Bar [])
        ]
        data
    ]



-- DATA


data : List ( Float, Float )
data =
  [ ( 1, 3 )
  , ( 2, 4 )
  , ( 5, 2 )
  , ( 7, 6 )
  ]
