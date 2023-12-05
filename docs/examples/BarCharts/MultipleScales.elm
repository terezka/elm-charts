module Examples.BarCharts.MultipleScales exposing (..)

{-| @LARGE -}
import Html as H
import Chart as C
import Chart.Attributes as CA
import Svg as S


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 30, right = 30, bottom = 0 }
    ]
    [ C.xLabels []
    , C.xAxis [ CA.noArrow ]
    , C.yLabels [ CA.color CA.purple ]
    , C.bars [ CA.margin 0.45 ] [ C.bar .z [] ] data
    , C.scale
        [] 
        [ C.bars [] [ C.bar .x [ CA.opacity 0.5 ] ] data
        , C.yLabels [ CA.pinned .max, CA.flip, CA.color CA.pink ]
        ]
    ]
{-| @SMALL END -}


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }

data : List Datum
data =
  [ Datum 1 2  120
  , Datum 2 10 50
  , Datum 3 5  100
  ]

{-| @LARGE END -}


meta =
  { category = "Bar charts"
  , categoryOrder = 3
  , name = "Multiple Scales"
  , description = "Bars with different y axes."
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




