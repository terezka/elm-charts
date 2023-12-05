module Examples.LineCharts.MultipleScales exposing (..)

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
    , C.scale 
        []
        [ C.series .x [ C.interpolated .z [] [ CA.cross, CA.border "white", CA.borderWidth 2 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip ]
        , C.yAxis [ CA.pinned .max ]
        , C.xTicks [ CA.withGrid ]
        ]
    , C.series .x
        [ C.interpolated .y [] [ CA.cross, CA.border "white", CA.borderWidth 2 ] ]
        data
    , C.yLabels []
    , C.yAxis []
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




