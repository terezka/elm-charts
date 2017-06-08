module Main exposing (main)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, Attribute)
import Svg.Attributes as Attributes exposing (fill, stroke, strokeWidth)
import Grouped exposing (..)
import Axis exposing (..)
import Colors exposing (..)



colors : List (List (Attribute msg))
colors =
  [ [ stroke transparent ]
  , [ stroke transparent, fill blueFill ]
  , [ stroke transparent, fill "#f1ccf7" ]
  ]


group : Int -> List Float -> Group msg
group index data =
  { bars = List.map2 (Bar ) colors data
  , label = "No. " ++ toString (index + 1)
  }


dependentAxis : DependentAxis
dependentAxis =
  { position = \min max -> min
  , line = Nothing
  , marks = \_ -> List.map dependentMark [ 0, 1, 2, 3, 4, 5 ]
  , mirror = False
  }


dependentMarkView : Float -> DependentMarkView
dependentMarkView position =
  { grid = Nothing
  , junk = Just (fullLine [ stroke "white", strokeWidth "2px" ])
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


dependentMark : Float -> DependentMark
dependentMark position =
  { position = position
  , view = dependentMarkView position
  }


main : Html msg
main =
  div [ style [ ("padding", "40px" ) ] ]
    [ viewCustom
        { independentAxis =
            { line = Just simpleLine
            , mark =
                { label = stringLabel
                , tick = Just simpleTick
                }
            }
        , dependentAxis = dependentAxis
        }
        { toGroups = List.indexedMap group
        , width = 0.9
        }
        data
    ]



-- DATA


data : List (List Float)
data =
  [ [ 2, 3, 1 ], [ 5, 1, 4 ], [ 1, 5, 3 ] ]
