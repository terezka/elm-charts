module Examples.Frontpage.BasicBar exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xLabels [ CA.withGrid, CA.ints ]
    , C.yLabels [ CA.withGrid ]
    , C.bars
        [ CA.x1 .x ]
        [ C.bar .z [ CA.striped [] ]
        , C.bar .y []
        ]
        [ { x = 1, y = 3, z = 1 }
        , { x = 2, y = 2, z = 3 }
        , { x = 3, y = 4, z = 2 }
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Basic"
  , categoryOrder = 1
  , name = "Bar chart"
  , description = "Make a basic bar chart."
  , order = 1
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

