module Examples.LineCharts.Missing exposing (..)

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
        [ C.interpolatedMaybe .y [ CA.stepped ] []
        ]
        data
    ]
{-| @SMALL END -}


type alias Datum =
  { x : Float
  , y : Maybe Float
  , z : Maybe Float
  }

data : List Datum
data =
  [ Datum 1  (Just 2) (Just 1)
  , Datum 2  (Just 3) (Just 2)
  , Datum 3  (Just 4) (Just 3)
  , Datum 4  Nothing (Just 4)
  , Datum 5  (Just 2) (Just 3)
  , Datum 6  (Just 4) (Just 1)
  , Datum 7  (Just 5) (Just 2)
  , Datum 8  (Just 6) Nothing
  , Datum 9  (Just 5) (Just 4)
  , Datum 10 (Just 4) (Just 3)
  ]


{-| @LARGE END -}


meta =
  { category = "Line charts"
  , categoryOrder = 3
  , name = "Missing data"
  , description = "Handle missing data."
  , order = 4
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


