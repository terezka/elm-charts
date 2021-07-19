module Examples.BarCharts.Highlight exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : List (CI.One Datum CI.Bar) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.One Datum CI.Bar))


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
    , CE.onMouseMove OnHover (CE.getNearest CI.bars)
    , CE.onMouseLeave (OnHover [])
    , CA.padding { top = 10, bottom = 0, left = 0, right = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.bars
        [ CA.roundTop 0.2
        , CA.margin 0.1
        , CA.spacing 0.15
        ]
        [ C.bar .z [ CA.striped [], CA.borderWidth 1 ]
            |> C.amongst model.hovering (\_ -> [ CA.highlight 0.25 ])
        , C.bar .v []
            |> C.amongst model.hovering (\_ -> [ CA.highlight 0.25 ])
        ]
        data
    , C.each model.hovering <| \p item ->
        [ C.tooltip item [] [] [] ]
    ]


meta =
  { category = "Bar charts"
  , categoryOrder = 1
  , name = "Highlight"
  , description = "Add highlight to bar."
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
  , Datum 2.0 0.4 2.2 4.2 5.3 5.7 6.2 7.8
  , Datum 3.0 0.6 1.0 3.2 4.8 5.4 7.2 8.3
  ]



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CE.onMouseMove OnHover (CE.getNearest CI.bars)
    , CE.onMouseLeave (OnHover [])
    , CA.padding { top = 10, bottom = 0, left = 0, right = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.bars
        [ CA.roundTop 0.2
        , CA.margin 0.1
        , CA.spacing 0.15
        ]
        [ C.bar .z [ CA.striped [], CA.borderWidth 1 ]
            |> C.amongst model.hovering (\\_ -> [ CA.highlight 0.25 ])
        , C.bar .v []
            |> C.amongst model.hovering (\\_ -> [ CA.highlight 0.25 ])
        ]
        data
    , C.each model.hovering <| \\p item ->
        [ C.tooltip item [] [] [] ]
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
  { hovering : List (CI.One Datum CI.Bar) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.One Datum CI.Bar))


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
    , CE.onMouseMove OnHover (CE.getNearest CI.bars)
    , CE.onMouseLeave (OnHover [])
    , CA.padding { top = 10, bottom = 0, left = 0, right = 0 }
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]
    , C.bars
        [ CA.roundTop 0.2
        , CA.margin 0.1
        , CA.spacing 0.15
        ]
        [ C.bar .z [ CA.striped [], CA.borderWidth 1 ]
            |> C.amongst model.hovering (\\_ -> [ CA.highlight 0.25 ])
        , C.bar .v []
            |> C.amongst model.hovering (\\_ -> [ CA.highlight 0.25 ])
        ]
        data
    , C.each model.hovering <| \\p item ->
        [ C.tooltip item [] [] [] ]
    ]
  """