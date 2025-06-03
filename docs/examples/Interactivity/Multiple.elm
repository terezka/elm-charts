module Examples.Interactivity.Multiple exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hovering : List (CI.One Datum CI.Any) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.One Datum CI.Any))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CE.onMouseMove OnHover (CE.getNearest CI.any)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]

    , C.bars
        [ CA.x1 .x1
        , CA.x2 .x2
        ]
        [ C.bar .z [ CA.opacity 0.3, CA.borderWidth 1 ]
        ]
        data

    , C.series .x
        [ C.interpolated .p [] []
        , C.interpolated .q [] []
        ]
        data

    , C.each model.hovering <| \p item ->
        [ C.tooltip item [] [] [] ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Mixed chart types"
  , description = "Add a tooltip for bars and series."
  , order = 13
  }



type alias Datum =
  { x : Float
  , x1 : Float
  , x2 : Float
  , y : Float
  , z : Float
  , v : Float
  , w : Float
  , p : Float
  , q : Float
  }


data : List Datum
data =
  [ Datum 0.0 0.0 1.0 1.2 4.0 4.6 6.9 7.3 8.0
  , Datum 2.0 1.0 2.0 2.2 4.2 5.3 5.7 6.2 7.8
  , Datum 3.0 2.0 3.0 1.0 3.2 4.8 5.4 7.2 8.3
  , Datum 4.0 3.0 4.0 1.2 3.0 4.1 5.5 7.9 8.1
  ]

