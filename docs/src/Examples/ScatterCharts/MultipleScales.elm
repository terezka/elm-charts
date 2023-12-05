module Examples.ScatterCharts.MultipleScales exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Chart as C
import Chart.Attributes as CA
import Svg as S


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 10, right = 30, bottom = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.orange ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.cross, CA.borderWidth 3, CA.color CA.pink, CA.border "white", CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.pink ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.cross, CA.borderWidth 3, CA.color CA.orange, CA.border "white", CA.size 12 ] ]
        data
    ]


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
  [ Datum 0.1 2.0 4.0 4.6 690 7.3 80.0
  , Datum 0.2 3.0 4.2 5.2 620 7.0 60.7
  , Datum 0.8 4.0 4.6 5.5 520 7.2 80.1
  , Datum 1.0 2.0 4.2 5.3 570 6.2 70.8
  , Datum 1.2 5.0 3.5 4.9 590 6.7 80.2
  , Datum 2.0 2.0 3.2 4.8 540 7.2 80.3
  , Datum 2.3 1.0 4.3 5.3 510 7.8 70.1
  , Datum 2.8 3.0 2.9 5.4 390 7.6 90.5
  , Datum 3.0 2.0 3.6 5.8 460 6.5 60.9
  , Datum 4.0 1.0 4.2 4.5 530 6.3 70.0
  ]



meta =
  { category = "Scatter charts"
  , categoryOrder = 3
  , name = "Multiple Scales"
  , description = "Scatters on different scales."
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






smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 10, right = 30, bottom = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.orange ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.cross, CA.borderWidth 3, CA.color CA.pink, CA.border "white", CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.pink ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.cross, CA.borderWidth 3, CA.color CA.orange, CA.border "white", CA.size 12 ] ]
        data
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Chart as C
import Chart.Attributes as CA
import Svg as S


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 10, right = 30, bottom = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.orange ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.cross, CA.borderWidth 3, CA.color CA.pink, CA.border "white", CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.pink ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.cross, CA.borderWidth 3, CA.color CA.orange, CA.border "white", CA.size 12 ] ]
        data
    ]


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
  [ Datum 0.1 2.0 4.0 4.6 690 7.3 80.0
  , Datum 0.2 3.0 4.2 5.2 620 7.0 60.7
  , Datum 0.8 4.0 4.6 5.5 520 7.2 80.1
  , Datum 1.0 2.0 4.2 5.3 570 6.2 70.8
  , Datum 1.2 5.0 3.5 4.9 590 6.7 80.2
  , Datum 2.0 2.0 3.2 4.8 540 7.2 80.3
  , Datum 2.3 1.0 4.3 5.3 510 7.8 70.1
  , Datum 2.8 3.0 2.9 5.4 390 7.6 90.5
  , Datum 3.0 2.0 3.6 5.8 460 6.5 60.9
  , Datum 4.0 1.0 4.2 4.5 530 6.3 70.0
  ]

  """