module Main exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, Attribute)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Grouped exposing (..)
import Axis exposing (..)
import Colors exposing (..)


data : List (List Float)
data =
  [ [ 2, 3, 1 ], [ 5, 1, 4 ], [ 1, 5, 3 ] ]


colors : List (List (Attribute msg))
colors =
  [ [], [ stroke blueStroke, fill blueFill ],  [ stroke "pink", fill "lightpink" ] ]


group : Int -> List Float -> Group msg
group index data =
  { bars = List.map2 (Bar ) colors data
  , label = "Disease no. " ++ toString index
  }


main : Html msg
main =
  div [ style [ ("padding", "40px" ) ] ]
    [ view
        { dependentAxis =
            { line = Just simpleLine
            , mark =
                { label = label
                , tick = Just simpleTick
                }
            }
        , independentAxis = defaultAxis
        }
        { toGroups = List.indexedMap group
        , width = 0.9
        }
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
