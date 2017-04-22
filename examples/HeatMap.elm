module Main exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, svg, g, circle, text_, text, tspan)
import HeatMap exposing (..)
import Axis exposing (..)


data : List Float
data =
  [ 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9,6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 2, 1, 3, 6, 8, 9 ]


heatmap : HeatMap (List Float) msg
heatmap =
  { toTiles = List.indexedMap tile
  , tilesPerRow = 10
  , horizontal =
      { labels = [ stringLabel "Hey", stringLabel "2", stringLabel "3" ]
      , position = Lower
      }
  , vertical =
      { labels = [ stringLabel "Hey", stringLabel "2", stringLabel "3" ]
      , position = Lower
      }
  , width = 300
  , height = 300
  , colors =
    { scale = Gradient 253 185 231
    , missing = "grey"
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
  div [ style [ ("padding", "40px" ) ] ] [ HeatMap.view heatmap data ]
