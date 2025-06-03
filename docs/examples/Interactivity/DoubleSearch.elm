module Examples.Interactivity.DoubleSearch exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI


type alias Model =
  { hoveringDots : List (CI.One Datum CI.Dot)
  , hoveringBars : List (CI.One Datum CI.Bar)
  }


init : Model
init =
  { hoveringDots = []
  , hoveringBars = []
  }


type Msg
  = OnHover
      (List (CI.One Datum CI.Dot))
      (List (CI.One Datum CI.Bar))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hoveringDots hoveringBars ->
      { model
      | hoveringDots = hoveringDots
      , hoveringBars = hoveringBars
      }


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CE.on "mousemove" <|
        CE.map2 OnHover
          (CE.getNearest CI.dots)
          (CE.getNearest CI.bars)
    , CE.onMouseLeave
        (OnHover [] [])
    ]
    [ C.xLabels []
    , C.yLabels [ CA.withGrid ]

    , C.series .x
        [ C.stacked
          [ C.interpolated .p [] [ CA.circle ]
          , C.interpolated .q [] [ CA.circle ]
          ]
        ]
        data

    , C.bars
        [ CA.x1 .x1
        , CA.x2 .x2
        ]
        [ C.bar .z [ CA.color CA.purple, CA.striped [] ] ]
        data

    , C.each model.hoveringDots <| \p item ->
        [ C.tooltip item [] [] [] ]

    , C.each model.hoveringBars <| \p item ->
        [ C.label
            [ CA.color CA.purple
            , CA.moveUp 8
            , CA.fontSize 14
            ]
            [ S.text (String.fromFloat (CI.getY item)) ]
            (CI.getTop p item)
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Interactivity"
  , categoryOrder = 5
  , name = "Multiple tooltips"
  , description = "Add more than one search."
  , order = 17
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

