module Main exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg, svg, g, circle, text_, text, tspan)
import Choropleth exposing (..)
import Colors exposing (..)


map : Choropleth (List Float) msg
map =
  { toTiles = List.map tile
  , pattern = america
  , width = 300
  , height = 200
  , colors =
    { scale =
        Chunks
          [ "rgba(241, 204, 247, 0.35)"
          , "rgba(241, 204, 247, 0.55)"
          , "rgba(241, 204, 247, 0.75)"
          , "rgba(241, 204, 247, 0.95)"
          ]
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
    [ style [ ("padding"
    , "40px" ) ] ]
    [ Choropleth.view map data ]



-- DATA


data : List Float
data =
  [ 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 1, 2, 3, 6, 8, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 9, 6, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9,6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 6, 4, 2, 1, 4, 2, 1, 3, 6, 8, 9, 2, 1, 3, 6, 8, 9 ]
