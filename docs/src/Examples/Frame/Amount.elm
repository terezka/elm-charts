module Examples.Frame.Amount exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks [ CA.amount 4 ]
    , C.xLabels [ CA.amount 4 ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Amount of labels/ticks"
  , description = "Change the number of labels or ticks."
  , order = 6
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


smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks [ CA.amount 4 ]
    , C.xLabels [ CA.amount 4 ]
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks [ CA.amount 4 ]
    , C.xLabels [ CA.amount 4 ]
    ]
  """