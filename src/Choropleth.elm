module Choropleth exposing (Choropleth, Tile, ColorScale(..), view, america)

{-|
@docs Choropleth, Tile, ColorScale, view

@docs america
-}

import Svg exposing (Svg, Attribute, svg, g, path, rect, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke, transform, style)
import Svg.Tiles as Tiles exposing (..)
import Array exposing (Array)



{-| -}
type alias Choropleth data msg =
  { toTiles : data -> List (Tile msg)
  , pattern : Pattern
  , width : Int
  , height : Int
  , colors :
    { scale : ColorScale
    , missing : String
    }
  }


type alias Pattern =
  { tilesPerRow : Int
  , indices : List Int
  }


{-| -}
type alias Tile msg =
  { content : Maybe (Svg msg)
  , attributes : List (Attribute msg)
  , value : Maybe Float
  }


{-| -}
type ColorScale
  = Gradient Int Int Int
  | Chunks (Array String)


{-| -}
view : Choropleth data msg -> data -> Svg msg
view { toTiles, pattern, width, height, colors } data =
  let
    tiles =
      toTiles data

    tileWidth =
      toFloat <| Tiles.tileWidth width pattern.tilesPerRow

    tileHeight =
      toFloat <| Tiles.tileHeight height pattern.tilesPerRow (List.maximum pattern.indices |> Maybe.withDefault 1)

    proportion =
      Tiles.proportion identity (List.filterMap .value tiles)

    tileColor value =
      case value of
        Just float ->
          colorScale colors.scale (proportion float)

        Nothing ->
          colors.missing

    xCoord =
      Tiles.tileXCoord tileWidth pattern.tilesPerRow

    yCoord =
      Tiles.tileYCoord tileHeight pattern.tilesPerRow

    tileAttributes { value, attributes } =
      attributes ++ [ fill (tileColor value) ]

    toRougeTile index tile =
      Tiles.Tile tile.content (tileAttributes tile) index
  in
    svg
      [ Attributes.width (toString width)
      , Attributes.height (toString height)
      ]
      [ g [ Attributes.class "elm-plot__choropleth" ]
          [ Tiles.view
              { tiles = List.map2 toRougeTile pattern.indices tiles
              , tilesPerRow = pattern.tilesPerRow
              , tileWidth = tileWidth
              , tileHeight = tileHeight
              }
          ]
      ]



-- PATTERNS


{-| -}
america : Pattern
america =
  { tilesPerRow = 11
  , indices = [ 0, 10, 16, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 56, 57, 58, 59, 60, 61, 62, 69, 70, 71, 72, 73, 77, 80, 85 ]
  }



-- BORING FUNCTIONS


colorScale : ColorScale -> Float -> String
colorScale scale =
  case scale of
    Gradient r g b ->
      gradient r g b

    Chunks colors ->
      chunk colors


translate : Float -> Float -> String
translate x y =
  "translate(" ++ toString x ++ ", " ++ toString y ++ ")"


gradient : Int -> Int -> Int -> Float -> String
gradient r g b opacity =
  "rgba("
    ++ toString r
    ++ ", "
    ++ toString g
    ++ ", "
    ++ toString b
    ++ ", "
    ++ toString opacity
    ++ ")"


chunk : Array String -> Float -> String
chunk colors proportion =
  Array.get (chunkColorIndex colors proportion) colors
    |> Maybe.withDefault "-- doesn't happen (hopefully) --"


chunkColorIndex : Array String -> Float -> Int
chunkColorIndex colors proportion =
  proportion
    * toFloat (Array.length colors)
    |> round
    |> max 0
    |> min (Array.length colors - 1)
