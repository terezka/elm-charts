module PlotExample exposing (..)

import Html exposing (Html, button, div, text)
import Debug

type alias Serie =
    { color : String
    , xValues : List Int
    , yValues : List Int
    }

main =
  viewPlot
    "Great name"
    [ { color = "blue", xValues = [ 0, 2, 3, 4 ], yValues = [ 2, 4, 6, 7 ] }
    , { color = "red", xValues = [ 4, 3, 2, 9 ], yValues = [ 8, 4, 6, 7 ] }
    ]


viewPlot : String -> List Serie -> Html a
viewPlot name series =
  let
    highestX =
      List.map .xValues series
        |> List.concat
        |> List.maximum
  in
    div []
      [ div [] [ text name ]
      , div [] [ text (toString highestX) ]
      , div [] (List.map viewSerie series)
      ]


viewSerie : Serie -> Html a
viewSerie { color, xValues, yValues } =
  div []
    [ div [] [ text (viewValues xValues) ]
    , div [] [ text (viewValues yValues) ]
    ]


viewValues : List Int -> String
viewValues values =
  List.head values
    |> Maybe.withDefault 0
    |> toString
