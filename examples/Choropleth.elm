module Main exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, svg, g, circle, text_, text, tspan)
import Choropleth exposing (..)
import Colors exposing (..)
import Array


map : Choropleth (List Float) msg
map =
  { toTiles = List.map tile
  , pattern = america
  , width = 300
  , height = 200
  , colors =
    { scale = Chunks (Array.fromList [ "rgb(27, 120, 55)", "rgb(127, 191, 123)", "rgb(217, 240, 211)", "rgb(231, 212, 232)", "rgb(175, 141, 195)", "rgb(118, 42, 131)" ])
    , missing = grey
    }
  }


{-| -}
tile : Float -> Tile msg
tile value =
  { content = Nothing
  , attributes = []
  , value = Just value
  }



main : Svg msg
main =
  div
    [ style [ ("padding", "40px" ) ] ]
    [ Choropleth.view map data ]



-- DATA


data : List Float
data =
  [ 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9,6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 2, 1, 3, 6, 8, 9 ]
