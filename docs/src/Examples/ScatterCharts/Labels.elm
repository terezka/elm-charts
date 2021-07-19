module Examples.ScatterCharts.Labels exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, bottom = 0, left = 30, right = 10 }
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
            |> C.variation (\i d -> [ CA.size (d.w * 30) ])
        ]
        data

    , C.eachDot <| \p dot ->
        [ C.label
            [ CA.moveDown 4, CA.color (CI.getColor dot) ]
            [ S.text (String.fromFloat (CI.getData dot).w) ]
            (CI.getCenter p dot)
        ]
    ]


meta =
  { category = "Scatter charts"
  , categoryOrder = 2
  , name = "Labels"
  , description = "Add labels to each dot."
  , order = 9
  }


type alias Model =
  ()


init : Model
init =
  ()


type Msg
  = Msg


update : Msg -> Model -> Model
update msg model =
  model


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  , v : Float
  , w : Float
  , p : Float
  , q : Float
  }


data : List Datum
data =
  [ Datum 0.6 2.0 4.0 4.6 6.9 7.3 8.0
  , Datum 0.7 3.0 4.2 5.2 6.2 7.0 8.7
  , Datum 0.8 4.0 4.6 5.5 5.2 7.2 8.1
  , Datum 1.0 2.0 4.2 5.3 5.7 6.2 7.8
  , Datum 1.2 5.0 3.5 4.9 5.9 6.7 8.2
  , Datum 2.0 2.0 3.2 4.8 5.4 7.2 8.3
  , Datum 2.3 1.0 4.3 5.3 5.1 7.8 7.1
  , Datum 2.8 3.0 2.9 5.4 3.9 7.6 8.5
  , Datum 3.0 2.0 3.6 5.8 4.6 6.5 6.9
  , Datum 4.0 1.0 4.2 4.5 5.3 6.3 7.0
  ]



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, bottom = 0, left = 30, right = 10 }
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
            |> C.variation (\\i d -> [ CA.size (d.w * 30) ])
        ]
        data

    , C.eachDot <| \\p dot ->
        [ C.label
            [ CA.moveDown 4, CA.color (CI.getColor dot) ]
            [ S.text (String.fromFloat (CI.getData dot).w) ]
            (CI.getCenter p dot)
        ]
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, bottom = 0, left = 30, right = 10 }
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.opacity 0.2, CA.borderWidth 1 ]
            |> C.variation (\\i d -> [ CA.size (d.w * 30) ])
        ]
        data

    , C.eachDot <| \\p dot ->
        [ C.label
            [ CA.moveDown 4, CA.color (CI.getColor dot) ]
            [ S.text (String.fromFloat (CI.getData dot).w) ]
            (CI.getCenter p dot)
        ]
    ]
  """