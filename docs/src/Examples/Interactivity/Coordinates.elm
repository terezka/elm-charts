module Examples.Interactivity.Coordinates exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Svg as CS
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : Maybe CE.Point }


init : Model
init =
  { hovering = Nothing }


type Msg
  = OnHover (Maybe CE.Point)


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
    , CE.onMouseMove (OnHover << Just) CE.getCoords
    , CE.onMouseLeave (OnHover Nothing)
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]

    , case model.hovering of
        Just coords ->
          C.series .x
            [ C.scatter .y
                [ CA.cross
                , CA.borderWidth 2
                , CA.border "white"
                , CA.size 12
                ]
            ]
            [ coords ]

        Nothing ->
          C.none

    , case model.hovering of
        Just coords ->
          C.labelAt CA.middle .max []
            [ S.text ("x: " ++ String.fromFloat coords.x)
            , S.text (" y: " ++ String.fromFloat coords.y)
            ]

        Nothing ->
          C.none
    ]


meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Basic coordinates"
  , description = "Get the hovered coordinates."
  , order = -1
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
    , CE.onMouseMove (OnHover << Just) CE.getCoords
    , CE.onMouseLeave (OnHover Nothing)
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]

    , case model.hovering of
        Just coords ->
          C.series .x
            [ C.scatter .y
                [ CA.cross
                , CA.borderWidth 2
                , CA.border "white"
                , CA.size 12
                ]
            ]
            [ coords ]

        Nothing ->
          C.none

    , case model.hovering of
        Just coords ->
          C.labelAt CA.middle .max []
            [ S.text ("x: " ++ String.fromFloat coords.x)
            , S.text (" y: " ++ String.fromFloat coords.y)
            ]

        Nothing ->
          C.none
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Svg as CS
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : Maybe CE.Point }


init : Model
init =
  { hovering = Nothing }


type Msg
  = OnHover (Maybe CE.Point)


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
    , CE.onMouseMove (OnHover << Just) CE.getCoords
    , CE.onMouseLeave (OnHover Nothing)
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]

    , case model.hovering of
        Just coords ->
          C.series .x
            [ C.scatter .y
                [ CA.cross
                , CA.borderWidth 2
                , CA.border "white"
                , CA.size 12
                ]
            ]
            [ coords ]

        Nothing ->
          C.none

    , case model.hovering of
        Just coords ->
          C.labelAt CA.middle .max []
            [ S.text ("x: " ++ String.fromFloat coords.x)
            , S.text (" y: " ++ String.fromFloat coords.y)
            ]

        Nothing ->
          C.none
    ]
  """