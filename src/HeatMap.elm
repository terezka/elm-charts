module HeatMap exposing (HeatMap, Tile, ColorScale(..), view)

{-|
@docs HeatMap, Tile, ColorScale, view
-}

import Svg exposing (Svg, Attribute, svg, g, path, rect, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke, transform, style)
import Array exposing (Array)



{-| -}
type alias HeatMap data msg =
  { toTiles : data -> List (Tile msg)
  , tilesPerRow : Int
  , vertical : Axis
  , horizontal : Axis
  , width : Float
  , height : Float
  , colors :
    { scale : ColorScale
    , missing : String
    }
  }


{-| -}
type alias Axis =
  { labels : List (Svg Never)
  , position : Position
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

    lowestValue =
      List.filterMap .value tiles
        |> List.minimum
        |> Maybe.withDefault 0

    highestValue =
      List.filterMap .value tiles
        |> List.maximum
        |> Maybe.withDefault lowestValue

    tileWidth =
      width / toFloat tilesPerRow

    tilesPerColumn =
      ceiling (toFloat (List.length tiles) / toFloat tilesPerRow)

    tileHeight =
      height / toFloat tilesPerColumn

    proportion value =
      (value - lowestValue) / (highestValue - lowestValue)

    tileColor value =
      case value of
        Just float ->
          colorScale colors.scale (proportion float)

        Nothing ->
          colors.missing

    tileXCoord index =
      tileWidth * toFloat (index % tilesPerRow)

    tileYCoord index =
      tileHeight * toFloat (index // tilesPerRow)

    tileAttributes { value, index, attributes } =
      [ Attributes.stroke "white"
      , Attributes.strokeWidth "1px"
      ]
      ++ attributes ++
      [ Attributes.width (toString tileWidth)
      , Attributes.height (toString tileHeight)
      , Attributes.fill (tileColor value)
      ]

    viewTile tile =
      g [ Attributes.class "elm-plot__heat-map__tile"
        , transform (translate (tileXCoord tile.index) (tileYCoord tile.index))
        ]
        [ rect (tileAttributes tile) []
        , viewJust tile.content
        ]

    viewHorizontalLabel index view =
      g [ transform (translate (tileWidth * toFloat index) height)
        , style "text-anchor: middle;"
        ]
        [ view ]

    viewVerticalLabel index view =
      g [ transform (translate 0 (height - tileHeight * toFloat index))
        , style "text-anchor: start;"
        ]
        [ view ]
  in
    svg
      [ Attributes.width (toString width)
      , Attributes.height (toString height)
      ]
      [ g [ Attributes.class "elm-plot__heat-map" ] (List.map viewTile tiles)
      , Svg.map never <| g [] (List.indexedMap viewHorizontalLabel horizontal.labels)
      , Svg.map never <| g [] (List.indexedMap viewVerticalLabel vertical.labels)
      ]


colorScale : ColorScale -> Float -> String
colorScale scale =
  case scale of
    Gradient r g b ->
      gradient r g b

    Chunks colors ->
      chunk colors


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



-- BORING FUNCTIONS


viewJust : Maybe (Svg msg) -> Svg msg
viewJust view =
  g [ transform (translate 5 15) ] [ Maybe.withDefault (text "") view ]


translate : Float -> Float -> String
translate x y =
  "translate(" ++ toString x ++ ", " ++ toString y ++ ")"


chunkColorIndex : Array String -> Float -> Int
chunkColorIndex colors proportion =
  proportion
    * toFloat (Array.length colors)
    |> round
    |> max 0
    |> min (Array.length colors - 1)
