module Main exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, svg, g, circle, text_, text, tspan)
import HeatMap exposing (..)
import Axis exposing (..)
import Colors exposing (..)


heatmap : HeatMap (List Float) msg
heatmap =
  { toTiles = List.indexedMap tile
  , tilesPerRow = 10
  , horizontal =
      { labels = List.map (toString >> stringLabel) (List.range 0 9)
      , position = Upper
      , width = 30
      }
  , vertical =
      { labels = List.map (toString >> (++) "no. " >> stringLabel) (List.range 0 10)
      , position = Upper
      , width = 50
      }
  , width = 600
  , height = 300
  , colors =
    { scale = Gradient 253 185 231
    , missing = grey
    }
  }


{-| -}
tile : Int -> Float -> Tile msg
tile index value =
  { content = Nothing
  , attributes = []
  , value = Just value
  , index = index
  }



main : Svg msg
main =
  div
    [ style [ ("padding", "40px" ) ] ]
    [ HeatMap.view heatmap data ]



-- DATA


data : List Float
data =
  [ 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9,6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 2, 1, 3, 6, 8, 9 ]
