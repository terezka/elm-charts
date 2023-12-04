module Examples.LineCharts.MultipleScales exposing (..)

{-| @LARGE -}
import Html as H
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 30, right = 30, bottom = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.yAxis [ CA.color CA.pink ]
    , C.series .x
        [ C.interpolated .y [ CA.color CA.pink ] [ CA.circle ]
        ]
        data
    , C.scale 
        []
        [ C.series .x [ C.interpolated .z [ CA.color CA.blue ] [ CA.circle ] ] data
        , C.yLabels [ CA.pinned .max, CA.flip ]
        , C.yAxis [ CA.pinned .max, CA.color CA.blue ]
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Line charts"
  , categoryOrder = 3
  , name = "Multiple Scales"
  , description = "Lines on different scales."
  , order = 17
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
  }

data : List Datum
data =
  [ Datum 1  2  120
  , Datum 2  10 50
  , Datum 3  5  100
  ]

