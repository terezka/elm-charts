module Examples.Interactivity.TrickyTooltip exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : List (CI.Many Datum CI.Bar) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.Many Datum CI.Bar))


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
    , CA.padding { top = 0, bottom = 0, left = 10, right = 10 }
    , CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearest
        |> CE.onMouseMove OnHover
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.yLabels [ CA.withGrid, CA.pinned .min ]
    , C.xLabels []
    , C.bars
        []
        [ C.bar .w []
        , C.stacked
            [ C.bar .p []
            , C.bar .q []
            ]
        ]
        data
    , C.each model.hovering <| \p bin ->
        let stacks = CI.apply CI.stacks (CI.getMembers bin)
            toTooltip stack = C.tooltip stack [ CA.onLeftOrRight ] [] []
        in
        List.map toTooltip stacks
    ]


meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Multiple tooltips for single group"
  , description = "Add tooltip for each stack in hovered bin."
  , order = 20
  }



type alias Datum =
  { x : Float
  , x1 : Float
  , y : Float
  , z : Float
  , v : Float
  , w : Float
  , p : Float
  , q : Float
  }


data : List Datum
data =
  [ Datum 0.0 0.0 1.2 4.0 4.6 6.9 7.3 8.0
  , Datum 2.0 1.0 2.2 4.2 5.3 5.7 6.2 7.8
  , Datum 3.0 2.0 1.0 3.2 4.8 5.4 7.2 8.3
  , Datum 4.0 3.0 1.2 3.0 4.1 5.5 7.9 8.1
  ]



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, bottom = 0, left = 10, right = 10 }
    , CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearest
        |> CE.onMouseMove OnHover
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.yLabels [ CA.withGrid, CA.pinned .min ]
    , C.xLabels []
    , C.bars
        []
        [ C.bar .w []
        , C.stacked
            [ C.bar .p []
            , C.bar .q []
            ]
        ]
        data
    , C.each model.hovering <| \\p bin ->
        let stacks = CI.apply CI.stacks (CI.getMembers bin)
            toTooltip stack = C.tooltip stack [ CA.onLeftOrRight ] [] []
        in
        List.map toTooltip stacks
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : List (CI.Many Datum CI.Bar) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.Many Datum CI.Bar))


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
    , CA.padding { top = 0, bottom = 0, left = 10, right = 10 }
    , CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearest
        |> CE.onMouseMove OnHover
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.yLabels [ CA.withGrid, CA.pinned .min ]
    , C.xLabels []
    , C.bars
        []
        [ C.bar .w []
        , C.stacked
            [ C.bar .p []
            , C.bar .q []
            ]
        ]
        data
    , C.each model.hovering <| \\p bin ->
        let stacks = CI.apply CI.stacks (CI.getMembers bin)
            toTooltip stack = C.tooltip stack [ CA.onLeftOrRight ] [] []
        in
        List.map toTooltip stacks
    ]
  """