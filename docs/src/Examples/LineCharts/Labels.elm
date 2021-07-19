module Examples.LineCharts.Labels exposing (..)


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
    , CA.padding { top = 0, bottom = 0, left = 15, right = 15 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.interpolated .y [ CA.monotone ] [ CA.circle, CA.size 40 ]
        ]
        data

    , C.dotLabels [ CA.moveDown 4, CA.color "white" ]
    ]


meta =
  { category = "Line charts"
  , categoryOrder = 3
  , name = "Labels for each point"
  , description = "Add custom labels on each data point."
  , order = 12
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
  [ Datum 1  2 1 4.6 6.9 7.3 8.0
  , Datum 2  3 2 5.2 6.2 7.0 8.7
  , Datum 3  4 3 5.5 5.2 7.2 8.1
  , Datum 4  3 4 5.3 5.7 6.2 7.8
  , Datum 5  2 3 4.9 5.9 6.7 8.2
  , Datum 6  4 1 4.8 5.4 7.2 8.3
  , Datum 7  5 2 5.3 5.1 7.8 7.1
  , Datum 8  6 3 5.4 3.9 7.6 8.5
  , Datum 9  5 4 5.8 4.6 6.5 6.9
  , Datum 10 4 3 4.5 5.3 6.3 7.0
  ]



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, bottom = 0, left = 15, right = 15 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.interpolated .y [ CA.monotone ] [ CA.circle, CA.size 40 ]
        ]
        data

    , C.dotLabels [ CA.moveDown 4, CA.color "white" ]
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
    , CA.padding { top = 0, bottom = 0, left = 15, right = 15 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.interpolated .y [ CA.monotone ] [ CA.circle, CA.size 40 ]
        ]
        data

    , C.dotLabels [ CA.moveDown 4, CA.color "white" ]
    ]
  """