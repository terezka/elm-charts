module Examples.LineCharts.Stepped exposing (..)

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
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.interpolated .y [ CA.stepped ] []
        , C.interpolated .z [ CA.stepped ] []
        ]
        data
    ]
{-| @SMALL END -}


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }

data : List Datum
data =
  [ Datum 1  2 1
  , Datum 2  3 2
  , Datum 3  4 3
  , Datum 4  3 4
  , Datum 5  2 3
  , Datum 6  4 1
  , Datum 7  5 2
  , Datum 8  6 3
  , Datum 9  5 4
  , Datum 10 4 3
  ]


{-| @LARGE END -}


meta =
  { category = "Line charts"
  , categoryOrder = 3
  , name = "Stepped"
  , description = "Use a stepped interpolation."
  , order = 3
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


