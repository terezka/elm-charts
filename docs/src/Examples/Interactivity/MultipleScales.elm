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
  , hovering : List (CI.One Datum CI.Dot) 
  }


init : Model
init =
  { coords = Nothing, hovering = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords hovering ->
      { model | coords = Just coords, hovering = hovering }

    OnMouseLeave ->
      { model | coords = Nothing, hovering = [] }


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
          (CE.getNearest 50 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 100 ]
    , CA.domain [ CA.window 0 100 ] 
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , case model.coords of
        Just coords ->
          C.svg <| \p ->
            let pointSvg = CS.fromCartesian p coords in
            S.g []
              [ S.circle
                  [ SA.r "50"
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        Nothing ->
          C.none
    , C.scale 
        [ CA.range [ CA.window 0 100 ]
        , CA.domain [ CA.window 0 100 ] 
        ]
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 1 ] 
                |> C.amongst model.hovering (\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 1 ] 
            |> C.amongst model.hovering (\d -> [ CA.highlight 0.1 ])
        ]
        data
    --, C.withPlane <| \p ->
    --    case model.hovering of 
    --      first :: rest -> 
    --        [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

    --      [] ->
    --        []
    ]


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }


data : List Datum
data =
  [ Datum 11 90 95
  , Datum 12 20 67
  , Datum 18 20 81
  , Datum 10 70 78
  , Datum 22 90 82
  , Datum 10 45 81
  , Datum 33 10 71
  , Datum 18 90 95
  , Datum 40 60 69
  , Datum 10 30 70
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
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearest 50 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 100 ]
    , CA.domain [ CA.window 0 100 ] 
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , case model.coords of
        Just coords ->
          C.svg <| \\p ->
            let pointSvg = CS.fromCartesian p coords in
            S.g []
              [ S.circle
                  [ SA.r "50"
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        Nothing ->
          C.none
    , C.scale 
        [ CA.range [ CA.window 0 100 ]
        , CA.domain [ CA.window 0 100 ] 
        ]
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 1 ] 
                |> C.amongst model.hovering (\\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 1 ] 
            |> C.amongst model.hovering (\\d -> [ CA.highlight 0.1 ])
        ]
        data
    --, C.withPlane <| \\p ->
    --    case model.hovering of 
    --      first :: rest -> 
    --        [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

    --      [] ->
    --        []
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
  , hovering : List (CI.One Datum CI.Dot) 
  }


init : Model
init =
  { coords = Nothing, hovering = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords hovering ->
      { model | coords = Just coords, hovering = hovering }

    OnMouseLeave ->
      { model | coords = Nothing, hovering = [] }


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
          (CE.getNearest 50 CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 100 ]
    , CA.domain [ CA.window 0 100 ] 
    ]
    [ C.xLabels []
    , C.yLabels [ CA.pinned .min, CA.color CA.pink ]
    , C.yAxis [ CA.pinned .min ]
    , case model.coords of
        Just coords ->
          C.svg <| \\p ->
            let pointSvg = CS.fromCartesian p coords in
            S.g []
              [ S.circle
                  [ SA.r "50"
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        Nothing ->
          C.none
    , C.scale 
        [ CA.range [ CA.window 0 100 ]
        , CA.domain [ CA.window 0 100 ] 
        ]
        [ C.series .x 
            [ C.scatter .z [ CA.circle, CA.borderWidth 1, CA.color CA.blue, CA.border CA.blue, CA.opacity 0.2, CA.borderOpacity 0.7, CA.size 1 ] 
                |> C.amongst model.hovering (\\d -> [ CA.highlight 0.1 ])
            ] data
        , C.yLabels [ CA.withGrid, CA.pinned .max, CA.flip, CA.color CA.blue ]
        , C.yAxis [ CA.pinned .max ]
        ]
    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 1, CA.color CA.pink, CA.border CA.pink, CA.borderOpacity 0.7, CA.opacity 0.2, CA.size 1 ] 
            |> C.amongst model.hovering (\\d -> [ CA.highlight 0.1 ])
        ]
        data
    --, C.withPlane <| \\p ->
    --    case model.hovering of 
    --      first :: rest -> 
    --        [ C.tooltip first [ CA.onTop ] [] (List.concatMap CI.getTooltip model.hovering) ]

    --      [] ->
    --        []
    ]


type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  }


data : List Datum
data =
  [ Datum 11 90 95
  , Datum 12 20 67
  , Datum 18 20 81
  , Datum 10 70 78
  , Datum 22 90 82
  , Datum 10 45 81
  , Datum 33 10 71
  , Datum 18 90 95
  , Datum 40 60 69
  , Datum 10 30 70
  ]

  """