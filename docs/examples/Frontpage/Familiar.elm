module Examples.Frontpage.Familiar exposing (..)

{-| @LARGE -}
import Html exposing (Html)
{-| @SMALL -}
import Chart exposing (..)
import Chart.Attributes as CA exposing (..)
import Time exposing (utc)


view : Model -> Html Msg
view _ =
  chart
    [ height 350
    , width 570
    , margin { top = 10, bottom = 30, left = 30, right = 10 }
    ]
    [ xLabels [ CA.times utc, amount 12 ]
    , yLabels [ withGrid, amount 6 ]
    , xAxis []
    , yAxis []
    , series .x
        [ interpolated .y [ width 2 ] []
        , interpolated .z [ width 2 ] []
        ]
        data
    ]
{-| @SMALL END -}
{-| @LARGE END -}



meta =
  { category = "Front page"
  , categoryOrder = 2
  , name = "Basic"
  , description = "Make a basic scatter chart."
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
  , y : Float
  , z : Float
  }


data : List Datum
data =
  let toDatum e t y =
        Datum t y (y + e)
  in
  [ toDatum 5 1622505600000 3.2
  , toDatum 6 1625097600000 5.6
  , toDatum 5 1627776000000 4.2
  , toDatum 7 1630454400000 7.6
  , toDatum 6 1633046400000 3.2
  , toDatum 8 1635724800000 12.8
  , toDatum 7 1638316800000 6.3
  , toDatum 9 1640995200000 16.3
  , toDatum 12 1643673600000 7.8
  , toDatum 13 1646092800000 28.5
  ]

