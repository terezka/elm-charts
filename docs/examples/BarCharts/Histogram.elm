module Examples.BarCharts.Histogram exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Time


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xLabels [ CA.times Time.utc ]
    , C.yLabels [ CA.withGrid ]
    , C.bars
        [ CA.x1 .start
        , CA.x2 .end
        , CA.margin 0.02
        ]
        [ C.bar .y [] ]
        data
    ]
{-| @SMALL END -}
{-| @LARGE END -}

meta =
  { category = "Bar charts"
  , categoryOrder = 1
  , name = "Histogram"
  , description = "Make a histogram (control x value)."
  , order = 2
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
  { start : Float
  , end : Float
  , y : Float
  }


data : List Datum
data =
  [ Datum 1609459200000 1612137600000 2
  , Datum 1612137600000 1614556800000 3
  , Datum 1614556800000 1617235200000 4
  , Datum 1617235200000 1619827200000 6
  ]

