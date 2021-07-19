module Examples.Frame.OnlyInts exposing (..)


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
    , CA.range
        [ CA.highest 3 CA.exactly
        , CA.lowest 0 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Only integers"
  , description = "Only show integer labels."
  , order = 8
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
    , CA.range
        [ CA.highest 3 CA.exactly
        , CA.lowest 0 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
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
    , CA.range
        [ CA.highest 3 CA.exactly
        , CA.lowest 0 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
    ]
  """