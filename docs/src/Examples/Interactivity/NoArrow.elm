module Examples.Interactivity.NoArrow exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


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
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        , C.scatter .z [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        ]
        data
    , C.each model.hovering <| \p item ->
        [ C.tooltip item [ CA.noArrow ] [] [] ]
    ]


meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Remove pointer"
  , description = "Don't add pointer to tooltip."
  , order = 8
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
  , Datum 4.0 0.2 1.2 3.0 4.1 5.5 7.9 8.1
  ]



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        , C.scatter .z [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        ]
        data
    , C.each model.hovering <| \\p item ->
        [ C.tooltip item [ CA.noArrow ] [] [] ]
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
    , CE.onMouseMove OnHover (CE.getNearest CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        , C.scatter .z [ CA.color "white", CA.size 20, CA.borderWidth 2 ]
        ]
        data
    , C.each model.hovering <| \\p item ->
        [ C.tooltip item [ CA.noArrow ] [] [] ]
    ]
  """