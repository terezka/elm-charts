module Examples.Interactivity.MultipleScales exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Svg as S


type alias Model =
  { hovering : List (CI.One Datum CI.Dot) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.One Datum CI.Dot))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 20, right = 20, bottom = 10 }
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] ]
        data
    , C.withPlane <| \p ->
        case model.hovering of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

          [] ->
            []
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
  [ Datum 0.1 2.0 4.0 4.6 690 7.3 95
  , Datum 0.2 3.0 4.2 5.2 620 7.0 67
  , Datum 0.8 4.0 4.6 5.5 520 7.2 81
  , Datum 1.0 2.0 4.2 5.3 570 6.2 78
  , Datum 1.2 5.0 3.5 4.9 590 6.7 82
  , Datum 2.0 2.0 3.2 4.8 345 7.2 81
  , Datum 2.3 1.0 4.3 5.3 510 7.8 71
  , Datum 2.8 3.0 2.9 5.4 390 7.6 95
  , Datum 3.0 2.0 3.6 5.8 460 6.5 69
  , Datum 4.0 1.0 4.2 4.5 530 6.3 70
  ]




meta =
  { category = "Interactivity"
  , categoryOrder = 3
  , name = "Multiple Scales"
  , description = "Tooltips on different scales."
  , order = 17
  }


smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 20, right = 20, bottom = 10 }
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] ]
        data
    , C.withPlane <| \\p ->
        case model.hovering of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

          [] ->
            []
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Svg as S


type alias Model =
  { hovering : List (CI.One Datum CI.Dot) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.One Datum CI.Dot))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, left = 20, right = 20, bottom = 10 }
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        [ CA.domain [ CA.likeData ] ]
        [ C.series .x [ C.scatter .q [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .w [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] ]
        data
    , C.withPlane <| \\p ->
        case model.hovering of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

          [] ->
            []
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
  [ Datum 0.1 2.0 4.0 4.6 690 7.3 95
  , Datum 0.2 3.0 4.2 5.2 620 7.0 67
  , Datum 0.8 4.0 4.6 5.5 520 7.2 81
  , Datum 1.0 2.0 4.2 5.3 570 6.2 78
  , Datum 1.2 5.0 3.5 4.9 590 6.7 82
  , Datum 2.0 2.0 3.2 4.8 345 7.2 81
  , Datum 2.3 1.0 4.3 5.3 510 7.8 71
  , Datum 2.8 3.0 2.9 5.4 390 7.6 95
  , Datum 3.0 2.0 3.6 5.8 460 6.5 69
  , Datum 4.0 1.0 4.2 4.5 530 6.3 70
  ]

  """