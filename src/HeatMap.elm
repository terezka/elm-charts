module HeatMap exposing (HeatMap, Tile, ColorScale(..), view, Position(..))

{-|
@docs HeatMap, Tile, ColorScale, view
-}

import Svg exposing (Svg, Attribute, svg, g, path, rect, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke, transform, style)
import Svg.Tiles as Tiles exposing (..)
import Array exposing (Array)



{-| -}
type alias HeatMap data msg =
  { toTiles : data -> List (Tile msg)
  , tilesPerRow : Int
  , vertical : Axis
  , horizontal : Axis
  , width : Int
  , height : Int
  , colors :
    { scale : ColorScale
    , missing : String
    }
  }


{-| -}
type alias Axis =
  { labels : List (Svg Never)
  , position : Position
  , width : Float
  }


{-| -}
type Position = Upper | Lower


{-| -}
type alias Tile msg =
  { content : Maybe (Svg msg)
  , attributes : List (Attribute msg)
  , value : Maybe Float
  , index : Int
  }


{-| -}
type ColorScale
  = Gradient Int Int Int
  | Chunks (Array String)


{-| -}
view : HeatMap data msg -> data -> Svg msg
view { toTiles, tilesPerRow, vertical, horizontal, width, height, colors } data =
  let
    tiles =
      toTiles data

    tileWidth =
      toFloat <| Tiles.tileWidth (width - round vertical.width) tilesPerRow

    tileHeight =
      toFloat <| Tiles.tileHeight (height - round horizontal.width) tilesPerRow (List.length tiles)

    proportion =
      Tiles.proportion identity (List.filterMap .value tiles)

    tileColor value =
      case value of
        Just float ->
          colorScale colors.scale (proportion float)

        Nothing ->
          colors.missing

    xCoord =
      Tiles.tileXCoord tileWidth tilesPerRow

    yCoord =
      Tiles.tileYCoord tileHeight tilesPerRow

    tileAttributes { value, attributes } =
      attributes ++ [ fill (tileColor value) ]

    toRougeTile tile =
      Tiles.Tile tile.content (tileAttributes tile) tile.index


    -- HORIZONTAL AXIS

    ( marginTop, marginBottom, horizontalPosition ) =
      case horizontal.position of
        Lower ->
          ( 0, horizontal.width, toFloat height - horizontal.width )

        Upper ->
          ( horizontal.width, 0, 5 )

    horizontalLabelXCoord index =
      tileWidth * (toFloat index + 0.5)

    viewHorizontalLabel index view =
      g [ transform <| translate (horizontalLabelXCoord index) 0
        , style "text-anchor: middle;"
        ]
        [ view ]


    -- VERTICAL AXIS

    ( marginLeft, marginRight, verticalPosition, anchor, offset ) =
      case vertical.position of
        Lower ->
          ( vertical.width, 0, vertical.width, "end", -5 )

        Upper ->
          ( 0, vertical.width, toFloat width - vertical.width, "start", 5 )

    verticalLabelYCoord index =
      tileHeight * (toFloat index + 0.5) + 5

    viewVerticalLabel index view =
      g [ transform <| translate offset (verticalLabelYCoord index)
        , style <| "text-anchor: " ++ anchor ++ ";"
        ]
        [ view ]
  in
    svg
      [ Attributes.width (toString width)
      , Attributes.height (toString height)
      ]
      [ g [ Attributes.class "elm-plot__heat-map"
          , transform (translate marginLeft marginTop)
          ]
          [ Tiles.view
              { tiles = List.map toRougeTile tiles
              , tilesPerRow = tilesPerRow
              , tileWidth = tileWidth
              , tileHeight = tileHeight
              }
          ]
      , Svg.map never <|
          g [ transform <| translate marginLeft (horizontalPosition + 20) ]
            (List.indexedMap viewHorizontalLabel horizontal.labels)
      , Svg.map never <|
          g [ transform (translate verticalPosition marginTop) ]
            (List.indexedMap viewVerticalLabel vertical.labels)
      ]


colorScale : ColorScale -> Float -> String
colorScale scale =
  case scale of
    Gradient r g b ->
      gradient r g b

    Chunks colors ->
      chunk colors



-- BORING FUNCTIONS


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
