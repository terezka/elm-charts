module Examples.Frame.Times exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Time


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, bottom = 0, left = 0, right = 25 }
    , CA.range
        [ CA.lowest 1591974241000 CA.exactly
        , CA.highest 1623510241000 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.times Time.utc ]
    , C.xLabels [ CA.times Time.utc ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Timeline"
  , description = "Use dates as labels."
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
    , CA.padding { top = 10, bottom = 0, left = 0, right = 25 }
    , CA.range
        [ CA.lowest 1591974241000 CA.exactly
        , CA.highest 1623510241000 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.times Time.utc ]
    , C.xLabels [ CA.times Time.utc ]
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Time


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 10, bottom = 0, left = 0, right = 25 }
    , CA.range
        [ CA.lowest 1591974241000 CA.exactly
        , CA.highest 1623510241000 CA.exactly
        ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.times Time.utc ]
    , C.xLabels [ CA.times Time.utc ]
    ]
  """