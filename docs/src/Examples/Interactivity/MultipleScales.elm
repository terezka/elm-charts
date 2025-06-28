module Examples.Interactivity.MultipleScales exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Chart.Svg as CS
import Svg as S
import Svg.Attributes as SA


type alias Model =
  { coords : Maybe CE.Point
  , closest : List (CI.One Datum CI.Dot) 
  , surrounding : List (CI.One Datum CI.Dot)
  }


init : Model
init =
  { coords = Nothing, closest = [], surrounding = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot), List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords (closest, surrounding) ->
      { model | coords = Just coords, closest = closest, surrounding = surrounding }

    OnMouseLeave ->
      { model | coords = Nothing, closest = [], surrounding = [] }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndNearby 10 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        []
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] 
                |> C.amongst model.closest (\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
                |> C.amongst model.surrounding (\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] 
            |> C.amongst model.closest (\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
            |> C.amongst model.surrounding (\d -> [ CA.highlight 0.1 ])
        ]
        data
    , C.withPlane <| \p ->
        case model.closest of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.closest) ]

          [] ->
            []
    ]


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }


data : List Datum
data =
  [ Datum 0.1 600 100
  , Datum 0.2 520 67
  , Datum 0.8 520 81
  , Datum 1.0 300 50
  , Datum 1.2 590 82
  , Datum 2.0 345 81
  , Datum 2.3 510 70
  , Datum 2.8 390 95
  , Datum 3.0 460 69
  , Datum 4.0 500 70
  ]



meta =
  { category = "Interactivity"
  , categoryOrder = 3
  , name = "Multiple Scales"
  , description = "Tooltips on different scales."
  , order = 17.6
  }


smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndNearby 10 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        []
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] 
                |> C.amongst model.closest (\\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
                |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] 
            |> C.amongst model.closest (\\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
            |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1 ])
        ]
        data
    , C.withPlane <| \\p ->
        case model.closest of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.closest) ]

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
import Chart.Svg as CS
import Svg as S
import Svg.Attributes as SA


type alias Model =
  { coords : Maybe CE.Point
  , closest : List (CI.One Datum CI.Dot) 
  , surrounding : List (CI.One Datum CI.Dot)
  }


init : Model
init =
  { coords = Nothing, closest = [], surrounding = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot), List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords (closest, surrounding) ->
      { model | coords = Just coords, closest = closest, surrounding = surrounding }

    OnMouseLeave ->
      { model | coords = Nothing, closest = [], surrounding = [] }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndNearby 10 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , C.scale 
        []
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 12 ] 
                |> C.amongst model.closest (\\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
                |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 12 ] 
            |> C.amongst model.closest (\\d -> [ CA.highlight 0.1, CA.opacity 0.5 ])
            |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1 ])
        ]
        data
    , C.withPlane <| \\p ->
        case model.closest of 
          first :: rest -> 
            [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.closest) ]

          [] ->
            []
    ]


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }


data : List Datum
data =
  [ Datum 0.1 600 100
  , Datum 0.2 520 67
  , Datum 0.8 520 81
  , Datum 1.0 300 50
  , Datum 1.2 590 82
  , Datum 2.0 345 81
  , Datum 2.3 510 70
  , Datum 2.8 390 95
  , Datum 3.0 460 69
  , Datum 4.0 500 70
  ]
  """